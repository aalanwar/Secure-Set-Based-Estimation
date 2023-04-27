% BuildingExample - Computes Secure set-based estimation 
% for the three-story building structure in the following paper
% Muhammad Umar B. Niazi, Michelle S. Chong, Amr Alanwar, Karl Johansson "Secure Set-Based State Estimation for Multi-Sensor Linear Systems under Adversarial Attacks"
%
%
%
% Author:       Amr Alanwar
% Written:      27-ِApril-2023
% Last update:  
% Last revision:---

%------------- BEGIN CODE --------------


clear all
close all

N=9;
rng(5)

% system parameters
M = diag([478350 478350 517790]);
D = 1e5 * [7.7626 -3.7304 0.6514;
    -3.7304 5.8284 -2.0266;
    0.6514 -2.0266 2.4458];
S = 1e8 * [4.3651 -2.3730 0.4144;
    -2.3730 3.1347 -1.2892;
    0.4144 -1.2892 0.9358];
G = [478350 478350 517790]';
H = [1 -1 0; 0 1 -1; 0 0 1];
% continuous time matrices
A_c = [zeros(3) eye(3); -M\S -M\D];
B1_c = [zeros(3,1); M\G]; % process noise w = B1_c * n, n(t)\in\mathbb{R}
B2_c = [zeros(3); M\H]; % control input B2_c * u
% discretization
delta = 1e-3; % sample time
A_d = expm(A_c*delta);
B1_d = A_c\(A_d-eye(6))*B1_c; % process noise w(k) = B1_d * n(k)
B2_d = A_c\(A_d-eye(6))*B2_c; % control input B2_d * u(k)
% output matrices
q=3;
C     = cell(1,q);
C{1}  = [1 -1 0 0 0 0; 1 0 -1 0 0 0; 0 0 0 1 0 0];
C{2}  = [-1 1 0 0 0 0; 0 1 -1 0 0 0; 0 0 0 0 1 0];
C{3}  = [-1 0 1 0 0 0; 0 -1 1 0 0 0; 0 0 0 0 0 1];



Ts =1;
A_true  = A_d;
B_true  = B2_d;
Z_u     = zonotope( [0;0;0], diag([10,10,10]) );


% define bounds on v(k) using zonotopes
Z_v_meas     = cell(1,q);
g_v_meas     = cell(1,q);
g_v_meas{1}  = 1.0;
g_v_meas{2}  = 1.0;
g_v_meas{3}  = 1.0;
Z_v_meas{1}  = zonotope(zeros(3,1),diag([g_v_meas{1},g_v_meas{1},g_v_meas{1}]));
Z_v_meas{2}  = zonotope(zeros(3,1),diag([g_v_meas{2},g_v_meas{2},g_v_meas{2}]));
Z_v_meas{3}  = zonotope(zeros(3,1),diag([g_v_meas{3},g_v_meas{3},g_v_meas{3}]));
c_w         = 500;%was 0.02
Z_w         = zonotope( zeros(1,1), diag(c_w*ones(1,1)) );

% intialize
x       = zeros(6,N+1);
t       = zeros(1,N+1);
w       = zeros(1,N);
u       = zeros(3,N);


for idx = 1:length(C)
    C_z_v = C{idx};
    [p_idx,~] = size(C_z_v);
    C_sizes{idx} = p_idx;
end
SAVEMOVIE = false;
if SAVEMOVIE
    vidObj = VideoWriter('video/SSBE.avi');
    vidObj.FrameRate=1;
    open(vidObj);
end


fig = figure('Renderer', 'painters', 'Position', [10 10 900 900]);
clf;
bd = 25;
% xlim([-bd bd]);
% ylim([-bd bd]);
grid on
hold on

% Initial constrained zonotope
Z = conZonotope([1 2 2 2 6 2 8;1 2 2 0 5 0 6;1 2 2 0 5 0 6 ;1 2 2 0 5 0 6 ;1 2 2 0 5 0 6 ;1 2 2 0 5 0 6  ],[],[]);
measUpdateGrp{1}=Z;
Linwid = 2;
Blacklinwid = 3;
plottingDim = [1,2];
h_measSet{2} = plotCZono(measUpdateGrp{1},plottingDim,'black','+','LineWidth',Linwid);
legend('measSet1');

indexAtt = 1;

upperBoundsArr = [];
lowerBoundsArr = [];
trueStateArr = [];


for k = 1:N

    %% Simulate true system
    disp("Timestep: " + t(k) )


    %randPointExtreme
    u(:,k)      = randPoint(Z_u);
    u_zon       = zonotope(u(:,k),[]);

    timeUpdateGrp={};
    for j=1:length(measUpdateGrp)
        %time update each set separately
        timeUpdateGrp{j}   = [A_true , B_true]*(cartProd(measUpdateGrp{j},u_zon)) + B1_d* Z_w;
    end

    %index of the attacked sensor
    indexAtt = mod(indexAtt,3)+1;

    w(:,k)      = randPoint(Z_w);
    x(:,k+1)    = A_true*x(:,k) + B_true*u(:,k) + B1_d* w(:,k);
    for i = 1:q
        % v{i}(k) = randPoint(Z_v_meas{i});
        y{i}(:,k) = C{i}*x(:,k) + randPoint(Z_v_meas{i});
        if i == indexAtt
            y{i}(:,k)= y{i}(:,k)+3+rand;
        end
    end

    % obtain measurement set
    for j=1:q
        measSet{j}   = measurement_zonotope(y{j}(:,k), C{j}, Z_v_meas{j});
    end




    pause(0.01);

    index=1;
    measUpdateGrp={};
    doneAllFlag=0;



    %intersect between measurement and time update sets
    pairs = {[1 2],[1 3],[2 3]};
    for ii=1:length(pairs)
        if(isIntersecting(measSet{pairs{ii}(1)},measSet{pairs{ii}(2)}))
            measSetpair=conZonotope(measSet{pairs{ii}(1)})&conZonotope(measSet{pairs{ii}(2)});
            for j=1:length(timeUpdateGrp)
                if (isIntersecting(measSetpair,timeUpdateGrp{j}))


                    measUpdateGrp{index}=measSetpair & timeUpdateGrp{j};
                    index = index+1;

                end
            end
        end
    end

    % convert to intervals for plotting upper and lower bounds
    intMeas = interval(measUpdateGrp{1});
    upperBounds = intMeas.sup;
    lowerBounds = intMeas.inf;
    for j=2:length(measUpdateGrp)
        intMeas = interval(measUpdateGrp{j});
        upperBounds = max(upperBounds,intMeas.sup);
        lowerBounds = min(lowerBounds,intMeas.inf);
    end

    upperBoundsArr = [ upperBoundsArr,upperBounds ];
    lowerBoundsArr = [ lowerBoundsArr,lowerBounds ];
    trueStateArr = [trueStateArr, x(:,k)];
    clf;


    bd = 25;
    % xlim([-bd bd]);
    % ylim([-bd bd]);
    grid on
    hold on
    box on


    hpoint = plot(x(plottingDim(1),k),x(plottingDim(2),k),'x','LineWidth',Blacklinwid+1);
    for jj=1:3
        if jj == indexAtt
            hMeasSetAttacked=  plotZono(measSet{jj},plottingDim,'red','*','LineWidth',Linwid);
        else
            hMeasSet=  plotZono(measSet{jj},plottingDim,'blue','+','LineWidth',Linwid);
        end
    end

    for jj=1:length(timeUpdateGrp)
        hTimeUpdate=  plotCZono(timeUpdateGrp{jj},plottingDim,'green','+','LineWidth',Linwid);
    end
    for jj=1:length(measUpdateGrp)
        hMeasUpdate=plotCZono(measUpdateGrp{jj},plottingDim,'black','+','LineWidth',Blacklinwid);
    end



    if indexAtt==3
        safeIndexStrA = '1';
        safeIndexStrB = '2';
    elseif indexAtt==2
        safeIndexStrA = '1';
        safeIndexStrB = '3';
    elseif indexAtt==1
        safeIndexStrA = '2';
        safeIndexStrB = '3';
    end


    Yattstr  = strcat('Attacked $\mathcal{Y}_k^{\mathsf{J}_', num2str(indexAtt) ,'}$');
    YsafeStr = strcat('Safe $\mathcal{Y}_k^{\mathsf{J}_',safeIndexStrA,'}$',' $\mathcal{Y}_k^{\mathsf{J}_',safeIndexStrB,'}$');
    legend([hpoint,hMeasSet,hMeasSetAttacked,hTimeUpdate,hMeasUpdate],...
        'True state $x(k)$',YsafeStr,Yattstr,'Time update $\hat{\mathcal{X}}_{k|k-1}$','Meas. update $\hat{\mathcal{X}}_{k}$','Location','northwest','Interpreter','latex');

    xlabelstr=strcat(' $x_', num2str(plottingDim(1)) ,'(k)$');
    xlabel(xlabelstr,'Interpreter','latex');
    ylabelstr=strcat(' $x_', num2str(plottingDim(2)) ,'(k)$');
    ylabel(ylabelstr,'Interpreter','latex');
    warOrig = warning; warning('off','all');
    warning(warOrig);
    ax = gca;
    ax.FontSize = 26;
    %set(gcf, 'Position',  [50, 50, 800, 400])
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    yticks(-4:2:4);
    xticks(-4:2:4);
    ylim([-4 4])
    xlim([-4 4])
    if SAVEMOVIE
        for i =1:5
            f = getframe(fig);
            writeVideo(vidObj,f);
        end
    end
    t(k+1)      = t(k) + Ts;

end

%plotting upper and lower bounds
for iter = 1:6
    fig = figure('Renderer', 'painters', 'Position', [10 10 900 900]);
    clf;
    bd = 25;
    dims = iter;

    meanValues = (upperBoundsArr(dims,:) + lowerBoundsArr(dims,:))/2;

    errHand = errorbar(1:N,meanValues,abs(meanValues-lowerBoundsArr(dims,:)),abs(upperBoundsArr(dims,:)-meanValues),"LineStyle","none",'LineWidth',Linwid,'Color','black');
    hold on
    trueHand=plot(1:N,trueStateArr(dims,:),'x','LineWidth',Blacklinwid+1,'Color','blue');

    xlabel('Time Step')
    ylabel(strcat('$x_',string(dims),'(k)$'),'Interpreter','latex')

    legend([errHand,trueHand],'State interval','True state $x(k)$','Interpreter','latex')

    xlim([0,N+1])
    warOrig = warning; warning('off','all');
    warning(warOrig);
    ax = gca;
    ax.FontSize = 22;
    %set(gcf, 'Position',  [50, 50, 800, 400])
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3)-0.02;
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    xticks(0:1:11);
    ylim([-1.5 2])
end

if SAVEMOVIE
    close(vidObj);
end