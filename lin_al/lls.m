function [a, new_y] = lls(X,Y,w,eqn);
% Generalized linear least squares function with input points x, dependent values y, basis set given 
% the string array eq, and weights w
% If no weights, assumes ones.
% If no eq, assumes linear fit.

if nargin < 4;
    eqn = ['1' ; 'X'];
end
if nargin < 3
    w = ones(size(X));
end;

%first construct basis set
    [order,str_len] = size(eqn);
    base_e = zeros([length(X),order]);
    for i = order:-1:1
        base_e(:,i) = ones([length(X),1]).*eval(eqn(i));
    end 

%next construct b = y.*w;
b = Y.*w;

%then construct the design matrix A = base_e * w;

A = base_e .* (w*ones([1,order]));

alpha = A' * A;
beta = A' * b;

a = alpha \ beta;
new_y = base_e * a;