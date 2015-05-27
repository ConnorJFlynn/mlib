function [gbar,goodA ] = gmean(A);
% [gbar,goodA] = gmean(A);
% Returns the geometric mean of positive-definite elements and a boolean
% flag of included.
goodA = A>0;
gbar = exp(mean(log(A(goodA))));


