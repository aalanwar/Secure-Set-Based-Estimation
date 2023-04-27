% illustrative example - Computes Secure set-based estimation 
% for the illustrative example in the following paper
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

N=10;
rng(5)

% Sampling time
Ts =1;
% system Matrices
A_true  = [1   0;1 1];
B_true  = [0.1; 0];
% Input zonotope
Z_u         = zonotope( 0, 10);
% Output Matrices
q=4;
C       = cell(1,q);
C{1}    = [1 0];
C{2}    = [1 1];
C{3}    = [0 1];
C{4}    = [1 2];
Cpairs = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};


% define noise zonotopes
Z_v_meas     = cell(1,q);
g_v_meas     = cell(1,q);
g_v_meas{1}  = 1.0;
g_v_meas{2}  = 1.0;
g_v_meas{3}  = 1.0;
g_v_meas{4}  = 1.0;
Z_v_meas{1}  = zonotope(0,g_v_meas{1});
Z_v_meas{2}  = zonotope(0,g_v_meas{2});
Z_v_meas{3}  = zonotope(0,g_v_meas{3});
Z_v_meas{4}  = zonotope(0,g_v_meas{4});
Z_v_meas_con = zonotope([0;0],diag([g_v_meas{1};g_v_meas{2}]));
c_w         = 0.02;
Z_w         = zonotope( [0.0;0.0], blkdiag(c_w, c_w) );

% True state
x       = zeros(2,N+1);
% Time
t       = zeros(1,N+1);
% Process noise
w       = zeros(2,N);
% Input
u       = zeros(1,N);


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
grid on
hold on

% initial zonotopes
Z = conZonotope([[1;1],diag([5;5])],[],[]);
measUpdateGrp{1}=Z;
Linwid = 2;
Blacklinwid = 3;
h_measSet{2} = plotCZono(measUpdateGrp{1},[1,2],'black','+','LineWidth',Linwid);
legend('measSet1');

indexAtt = 1;
for k = 1:N

    %% Simulate true system
    disp("Timestep: " + t(k) )



    u(k)        = 0;%randPoint(Z_u);
    u_zon       = zonotope(u(k),0);
    timeUpdateGrp={};
    for j=1:length(measUpdateGrp)
        %time update each set separately
        timeUpdateGrp{j}   = [A_true , B_true]*conZonotope(cartProd(measUpdateGrp{j},u_zon)) + Z_w;
    end

    % Indices of the sensor under attack
    indexAtt = mod(indexAtt,q)+1;
    indexAttP1 = mod(indexAtt,q)+1;

    % random noise
    w(:,k)      = randPoint(Z_w);
    % System dynamics
    x(:,k+1)    = A_true*x(:,k) + B_true*u(k) + w(:,k);
    for i = 1:q
        if i == indexAttP1
            continue;
        end
        y{i}(:,k) = C{i}*x(:,k) + randPoint(Z_v_meas{i});

        % add attack to the measurements
        if i == indexAtt
            y{i}(:,k) = y{i}(:,k)+2+rand;
            y{indexAttP1}(:,k) = C{indexAttP1}*x(:,k) + randPoint(Z_v_meas{i});
            y{indexAttP1}(:,k) = y{indexAttP1}(:,k)+2+rand;
        end
    end

    % Obtain measurement sets for pairs of sensors
    for j=1:length(Cpairs)
        Ccon = [C{Cpairs{j}(1)};C{Cpairs{j}(2)}];
        Ycon = [y{Cpairs{j}(1)}(:,k);y{Cpairs{j}(2)}(:,k)];
        measSet{j}   = measurement_zonotope(Ycon, Ccon, Z_v_meas_con);
    end


    pause(0.01);

    index=1;
    measUpdateGrp={};
    doneAllFlag=0;
    % intersection between timeupdate and measurement sets
    for ii=1:length(measSet)
        for j=1:length(timeUpdateGrp)
            if (isIntersecting(measSet{ii},timeUpdateGrp{j}))
                measUpdateGrp{index}=conZonotope(measSet{ii}) & conZonotope(timeUpdateGrp{j});
                index = index+1;
            end
        end
    end


    clf;
    bd = 25;

    % plotting
    grid on
    hold on
    box on

    hpoint = plot(x(1,k),x(2,k),'x','LineWidth',Blacklinwid+1);
    for j=1:length(Cpairs)
        if ( ismember(indexAtt,Cpairs{j})  ||  ismember(indexAttP1,Cpairs{j}) )
            hMeasSetAttacked=  plotZono(measSet{j},[1,2],'red','*','LineWidth',Linwid);
        else
            hMeasSet=  plotZono(measSet{j},[1,2],'blue','+','LineWidth',Linwid);
        end
    end

    for j=1:length(timeUpdateGrp)
        hTimeUpdate=  plotCZono(timeUpdateGrp{j},[1,2],'green','+','LineWidth',Linwid);
    end
    for j=1:length(measUpdateGrp)
        hMeasUpdate=plotCZono(measUpdateGrp{j},[1,2],'black','+','LineWidth',Blacklinwid);
    end

    attIndeces = [];
    for j=1:length(Cpairs)
        if ( ~ismember(indexAtt,Cpairs{j})  &&  ~ismember(indexAttP1,Cpairs{j}) )
            safeIndex =j;
        else
            attIndeces = [attIndeces j];
        end
    end

    YsafeStr = strcat('Safe $\mathcal{Y}_k^{\mathsf{J}_',num2str(safeIndex),'}$');

    YattStr = strcat('Attacked $\mathcal{Y}_k^{\mathsf{J}_',num2str(attIndeces(1)),'}$, ');
    for j=2:length(attIndeces)
        if j==length(attIndeces)
            YattStr  = strcat(YattStr,'$\mathcal{Y}_k^{\mathsf{J}_',num2str(attIndeces(j)),'}$');
        else
            YattStr  = strcat(YattStr,'$\mathcal{Y}_k^{\mathsf{J}_',num2str(attIndeces(j)),'}$, ');
        end
    end



    legend([hpoint,hMeasSet,hMeasSetAttacked,hTimeUpdate,hMeasUpdate],...
        'True state $x(k)$',YsafeStr,YattStr,'Time update $\hat{\mathcal{X}}_{k|k-1}$','Meas. update $\hat{\mathcal{X}}_{k}$','Location','northwest','Interpreter','latex');

    xlabel('$x_1(k)$','Interpreter','latex');
    ylabel('$x_2(k)$','Interpreter','latex');
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
    ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    yticks(-4:2:8);
    xticks(-7:2:7);
    ylim([-4 8])
    xlim([-7.5 7.5])
    if SAVEMOVIE
        for i =1:5
            f = getframe(fig);
            writeVideo(vidObj,f);
        end
    end

    %update the time
    t(k+1)      = t(k) + Ts;

end

if SAVEMOVIE
    close(vidObj);
end