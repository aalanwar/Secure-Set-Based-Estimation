function L = Hinf_observerGain(A,C)

nx = size(A,1);
ny = size(C,1);

B = [eye(nx) zeros(nx,ny)];
D = [zeros(ny,nx) eye(ny)];

P = sdpvar(nx,nx,'symmetric','real');
G = sdpvar(nx,ny);
gamma = sdpvar(1,1); 

Lmi1 = [P,      P*A-G*C,            P*B-G*D             zeros(nx);
    (P*A-G*C)', P,                  zeros(nx,nx+ny),    eye(nx);
    (P*B-G*D)', zeros(nx+ny,nx),    gamma*eye(nx+ny),   zeros(nx+ny,nx);
    zeros(nx),  eye(nx),            zeros(nx,nx+ny),    gamma*eye(nx)];

Constraint = [Lmi1>=0, P>=0, gamma>=0];
Objective = [gamma];
Options = sdpsettings('solver','sedumi');

diagnostics = optimize(Constraint, Objective, Options);

if diagnostics.problem == 0
    disp('Feasible from solver')
elseif diagnostics.problem == 1
    disp('Infeasible from solver')
else
    disp(':)')
%     disp('Something else happened')
end

P = double(P);
G = double(G);

L = P\G;