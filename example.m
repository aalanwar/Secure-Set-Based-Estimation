clear all
close all

q=3;
% define observability matrices
C       = cell(1,q);
C{1}    = [0.3 0.4;
           0.5 0.6];
C{2}    = [0.9 -1.2;
           0.1  0.2];
C{3}    = [-0.8 0.2;
           0.1  0.2];


% C{1}    = [1 0.4];
% C{2}    = [0.9 -1.2];
% C{3}    = [-0.8 0.2;
%            0    0.7];
% define bounds on v(k) using zonotopes
Z_v_meas     = cell(1,q);
g_v_meas     = cell(1,q);
g_v_meas{1}  = 1.0;
g_v_meas{2}  = 1.0;
g_v_meas{3}  = 1.0;
% Z_v_meas{1}  = zonotope(0,g_v_meas{1});
% Z_v_meas{2}  = zonotope(0,g_v_meas{2});
%Z_v_meas{3}  = zonotope([0;0],diag([g_v_meas{3},g_v_meas{3}]));


% %Z_v_meas{1}  = zonotope(0,c_v_meas{1});
% %Z_v_meas{2}  = zonotope(0,c_v_meas{2});
for i =1:q
Z_v_meas{i}  = zonotope([0;0],diag([g_v_meas{i},g_v_meas{i}]));
end


for idx = 1:length(C)
    C_z_v = C{idx};
    [p_idx,~] = size(C_z_v);
    C_sizes{idx} = p_idx;
end


Z = zonotope([1 2 2 2 6 2 8;1 2 2 0 5 0 6 ]);

y = {1, 2, 0.5};    

[Fresult,Flambda] = intersectZonoZono(Z,C,Z_v_meas,y,'frobenius');

C1{1}= C{1};
C2{1}= C{2};
C3{1}= C{3};
Z_v1{1}= Z_v_meas{1};
Z_v2{1}= Z_v_meas{2};
Z_v3{1}= Z_v_meas{3};
y1{1}= y{1};
y2{1}= y{2};
y3{1}= y{3};
[measSet{1},lambda{1}] = intersectZonoZono(Z,C1,Z_v1,y1,'frobenius');
[measSet{2},lambda{2}] = intersectZonoZono(Z,C2,Z_v2,y2,'frobenius');
[measSet{3},lambda{3}] = intersectZonoZono(Z,C3,Z_v3,y3,'frobenius');

%%just for comparison
%poly = mptPolytope([1 0;-1 0; 0 1;0 -1; 1 1;-1 -1],[3;7;5;1;5;1]);
%Zpoly = Z & poly;
index=1;

% for i =1:q
% p=C_sizes{i};
% %measSet{i} = lambda(:,index:index+p-1)*( -1*C{i}*Z + y{i} + -1*Z_v_meas{i});
% %measSet{i} = ( -1*C{i}*Z + y{i} + -1*Z_v_meas{i});
% measSet{i} = (  y{i} + -1*Z_v_meas{i});
% index=index+p;
% end
figure; hold on
plot(Z,[1 2],'r-');
%plot(x_est_opt,[1 2],'r-*');
plot(measSet{1},[1 2],'k-');
plot(measSet{2},[1 2],'k-+');
plot(measSet{3},[1 2],'k-*');
plot(Fresult,[1 2],'b-');

legend('zonotope','measSet1','measSet2','measSet3','result');
