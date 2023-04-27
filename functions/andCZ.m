function [res] = andCZ(C,S)
%ANDCZ Summary of this function goes here
%   Detailed explanation goes here
Z = [C.Z, zeros(size(S.Z)-[0,1])];
A = blkdiag(C.A,S.A);
A = [A; C.Z(:,2:end), -S.Z(:,2:end)];
b = [C.b; S.b; S.Z(:,1) - C.Z(:,1)];

res = conZonotope(Z,A,b);
end

