clear all
close all

N=10;

Ts =1;
A_true  = [0.9455   -0.2426;
    0.2486    0.9455];
B_true  = [0.1; 0];
Z_u         = zonotope( 0, 10);
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

gcf2 = figure('Renderer', 'painters', 'Position', [10 10 700 700]);
    clf;
    bd = 25;
    % xlim([-bd bd]);
    % ylim([-bd bd]);
    grid on
    hold on

Z = zonotope([1 2 2 2 6 2 8;1 2 2 0 5 0 6 ]);
h_measSet{1} = plotZono(Z,[1,2],'black');
h_measSet{2} = plotZono(Z,[1,2],'black','+');
h_measSet{3} = plotZono(Z,[1,2],'black','*');
h_result = plotZono(Z,[1,2],'red','*');
legend('measSet1','measSet2','measSet3','result');
Fresult =Z;
measSet{1} =Z;
measSet{2} =Z;
measSet{3} =Z;
for k = 1:N

    %% Simulate true system
    disp("Timestep: " + t(k) )

    u(k)        = randPoint(Z_u);
    u_zon       = zonotope(u(k),0.01);

    w(:,k)      = randPoint(Z_w);
    x(:,k+1)    = A_true*x(:,k) + B_true*u(k) + w(:,k);
    for i = 1:q
        % v{i}(k) = randPoint(Z_v_meas{i});
        y{i}(:,k) = C{i}*x(:,k) + randPoint(Z_v_meas{i});
    end



    [Fresult,Flambda] = intersectZonoZono(Fresult,C,Z_v_meas,y,'frobenius');

    C1{1}= C{1};
    C2{1}= C{2};
    C3{1}= C{3};
    Z_v1{1}= Z_v_meas{1};
    Z_v2{1}= Z_v_meas{2};
    Z_v3{1}= Z_v_meas{3};
    y1{1}= y{1};
    y2{1}= y{2};
    y3{1}= y{3};

    [measSet{1},lambda{1}] = intersectZonoZono(measSet{1},C1,Z_v1,y1,'frobenius');
    [measSet{2},lambda{2}] = intersectZonoZono(measSet{2},C2,Z_v2,y2,'frobenius');
    [measSet{3},lambda{3}] = intersectZonoZono(measSet{3},C3,Z_v3,y3,'frobenius');


    updatePlotZono(h_measSet{1},measSet{1},[1,2],'k-');
    updatePlotZono(h_measSet{2},measSet{2},[1,2],'k-+');
    updatePlotZono(h_measSet{3},measSet{3},[1,2],'k-*');
    updatePlotZono(h_result,Fresult,[1,2],'r*-');
t(k+1)      = t(k) + Ts;

end
