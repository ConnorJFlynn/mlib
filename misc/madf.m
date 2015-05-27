function [w, mad, abs_dev] = madf(A, thresh);
%[w, mad, abs_dev] = MADF(A, thresh);
% Requires A, threshold optional

if ~exist('thresh','var')
    thresh = 6;
end

A_bar = zeros(size(A));
mad = A_bar;
abs_dev = A_bar;
w = false(size(A));
goodA = isfinite(A);
if length(A(goodA))>0
%    A_bar = exp(mean(log(A(goodA)))); %geometric mean
   A_bar = mean(A(goodA));
   abs_dev(goodA) = abs(A(goodA)-A_bar);
   mad = mean(abs_dev(goodA));
   %%
   w(goodA) = abs_dev(goodA)<(thresh*mad);
   %%
end

