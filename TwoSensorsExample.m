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
rng(9)
%% 5 conference


Ts =1;
A_true  = [0.9455   -0.2426;
    0.2486    0.9455];
B_true  = [0.1; 0];
Z_u         = zonotope( 0,3);
q=3;
% define observability matrices
% C       = cell(1,q);
% C{1}    = [0.3 0.4;
%     0.5 0.6];
% C{2}    = [0.9 -1.2;
%     0.1  0.2];
% C{3}    = [-0.8 0.2;
%     0.1  0.2];
C       = cell(1,q);
C{1}    = [1 0.4];
C{2}    = [0.9 -1.2];
C{3}    = [-0.8 0.2;
    0    0.7];

% define bounds on v(k) using zonotopes
Z_v_meas     = cell(1,q);
g_v_meas     = cell(1,q);
g_v_meas{1}  = 1.0;
g_v_meas{2}  = 1.0;
g_v_meas{3}  = 1.0;
Z_v_meas{1}  = zonotope(0,g_v_meas{1});
Z_v_meas{2}  = zonotope(0,g_v_meas{2});
Z_v_meas{3}  = zonotope([0;0],diag([g_v_meas{3},g_v_meas{3}]));
c_gam       = 0.02;
c_w         = 0.02;
Z_gamma     = zonotope( [0.0;0.0], blkdiag(c_gam, c_gam) );
Z_w         = zonotope( [0.0;0.0], blkdiag(c_w, c_w) );

% Init matrices
x       = zeros(2,N+1);
%z       = zeros(2,T);
t       = zeros(1,N+1);
gam     = zeros(2,N);
w       = zeros(2,N);
u       = zeros(1,N);


% %Z_v_meas{1}  = zonotope(0,c_v_meas{1});
% %Z_v_meas{2}  = zonotope(0,c_v_meas{2});
% for i =1:q
%     Z_v_meas{i}  = zonotope([0;0],diag([g_v_meas{i},g_v_meas{i}]));
% end


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

Z = conZonotope([[0;0] diag([10,10])  ],[],[]);
% h_measSet{1} = plotZono(Z,[1,2],'black');
%
% h_measSet{3} = plotZono(Z,[1,2],'black','*');
% h_result = plotZono(Z,[1,2],'red','*');
% legend('measSet1','measSet2','measSet3','result');
% Fresult =Z;
% measSet{1} =Z;
% measSet{2} =Z;
% measSet{3} =Z;
measUpdateGrp{1}=Z;
Linwid = 2;
Blacklinwid = 3;
h_measSet{2} = plotCZono(measUpdateGrp{1},[1,2],'black','+','LineWidth',Linwid);
legend('measSet1');

indexAtt = 1;
for k = 1:N

    %% Simulate true system
    disp("Timestep: " + t(k) )




    timeUpdateGrp={};
    for j=1:length(measUpdateGrp)
        %time update each set separately
        timeUpdateGrp{j}   = [A_true , B_true]*conZonotope(cartProd(measUpdateGrp{j},Z_u)) + Z_w;
    end


    indexAtt = mod(indexAtt,3)+1;
    u(k)        = randPoint(Z_u);
    u_zon       = zonotope(u(k),0);
    w(:,k)      = randPoint(Z_w);
    x(:,k+1)    = A_true*x(:,k) + B_true*u(k) + w(:,k);
    for i = 1:q
        % v{i}(k) = randPoint(Z_v_meas{i});
        y{i}(:,k) = C{i}*x(:,k) + randPoint(Z_v_meas{i});
        if i == indexAtt
            y{i}(:,k)= y{i}(:,k)+2+rand;
        end
    end

    


    %     [Fresult,Flambda] = intersectZonoZono(Fresult,C,Z_v_meas,y,'frobenius');



    for j=1:q
        measSet{j}   = measurement_zonotope(y{j}(:,k), C{j}, Z_v_meas{j});
    end



    %     for j=1:length(timeUpdateGrp)
    %         if(isIntersecting(timeUpdateGrp{j},measSet{2}) )
    %         [measSet{1},lambda{1}] = intersectZonoZono(measSet{1},C1,Z_v1,y1,'frobenius');
    %         [measSet{2},lambda{2}] = intersectZonoZono(measSet{2},C2,Z_v2,y2,'frobenius');
    %         [measSet{3},lambda{3}] = intersectZonoZono(measSet{3},C3,Z_v3,y3,'frobenius');
    %     end

    pause(0.01);

    %axis(axx{plotRun});
    % skip warning for extra legend entries




    index=1;
    measUpdateGrp={};
    doneAllFlag=0;
    %     if(isIntersecting(measSet{1},measSet{2}) & isIntersecting(measSet{1},measSet{3}) & isIntersecting(measSet{2},measSet{3}))
    %        measSetAll=measSet{1}&measSet{2}&measSet{3};
    %         for j=1:length(timeUpdateGrp)
    %             if (isIntersecting(measSetAll,timeUpdateGrp{j}))
    %                 measUpdateGrp{index}=measSetAll & timeUpdateGrp{j};
    %                 doneAllFlag =1;
    %                 index = index+1;
    %             end
    %         end
    %     end


    if doneAllFlag==0
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
    end



    %     for ii =1:length(measUpdateGrp)
    %         measUpdateGrp{ii} = reduce(measUpdateGrp{ii},'girard',2);
    %     end



    %     indexNew=1;
    %     measUpdateGrpNew{1}=measUpdateGrp{1};
    %     indexNew = indexNew+1;
    %     for ii=2:length(measUpdateGrp)
    %         if(isIntersecting(measUpdateGrpNew{indexNew-1},measUpdateGrp{ii}) )
    %             measUpdateGrpNew{indexNew-1}=measUpdateGrpNew{indexNew-1}&measUpdateGrp{ii};
    %         else
    %              measUpdateGrpNew{indexNew}=measUpdateGrp{ii};
    %              indexNew = indexNew+1;
    %         end
    %     end
    %     measUpdateGrp=measUpdateGrpNew;
    clf;


    bd = 25;
    % xlim([-bd bd]);
    % ylim([-bd bd]);
    grid on
    hold on
    box on

    hpoint = plot(x(1,k),x(2,k),'x','LineWidth',Blacklinwid+1);
    for j=1:3
        if j == indexAtt
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



    if indexAtt==3
        safeIndexStrA = '1$, ';
        safeIndexStrB = '2$'; 
    elseif indexAtt==2
        safeIndexStrA = '1$, ';
        safeIndexStrB = '3$';
    elseif indexAtt==1
        safeIndexStrA = '2$, ';
        safeIndexStrB = '3$';        
    end


    Yattstr =strcat(' $\mathcal{Y}^', num2str(indexAtt) ,'_k$');
    legend([hpoint,hMeasSet,hMeasSetAttacked,hTimeUpdate,hMeasUpdate],...
        'True state $x(k)$',strcat('Safe $\mathcal{Y}_k^',safeIndexStrA,' $\mathcal{Y}_k^',safeIndexStrB),strcat('Attacked',Yattstr),'Time update $\hat{\mathcal{X}}_{k|k-1}$','Meas. update $\hat{\mathcal{X}}_{k}$','Location','northwest','Interpreter','latex');

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
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    yticks(-5:2:7);
    xticks(-5:2:6);
    ylim([-5 7])
    xlim([-5.5 5.5])
    if SAVEMOVIE
        for i =1:5
            f = getframe(fig);
            writeVideo(vidObj,f);
        end
    end
    t(k+1)      = t(k) + Ts;

end

if SAVEMOVIE
    close(vidObj);
end