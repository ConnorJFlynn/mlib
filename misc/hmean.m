function [hbar,goodA] = hmean(A);
% hbar = hmean(A);
% Returns the harmonic mean of non-zero elements and boolean flag of
% included elements
% hbar = length(A)/sum(1./A);
good = isfinite(A)&(A~=0);
hbar = length(A(good))/sum(1./A(good));
