function [a, new_y] = testleast(X,Y,eq,w);
% Test of least squares function with input points x, dependent values y, basis set given 
% the string array eq, and weights w
% If no eq, assume linear fit

if nargin < 4;
    w = ones(size(X));
end
if nargin < 3
    eq = ['1' ; 'X'];
end;

%first construct basis set
    [order,str_len] = size(eq);
    base_e = zeros([length(X),order]);
    for i = 1:order
        base_e(:,i) = eval(eq(i,:));
    end 

%next construct b = y.*w;
b = Y.*w;

%then construct the design matrix A =base_e * w;

A = base_e .* (w*ones([1,order]));

alpha = A' * A;
beta = A' * b;

a = alpha \ beta;
new_y = base_e * a;