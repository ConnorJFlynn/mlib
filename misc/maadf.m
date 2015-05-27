function [w, mad, abs_dev] = maadf(A,A_bar, thresh);
%[w, mad, abs_dev] = maadf(A, thresh);
%Very similar to madf but takes a supplied target as the mean.
% Requires A, A_bar, 
% threshold optional

if ~exist('thresh','var')
    thresh = 6;
end

% A_bar = zeros(size(A));
mad = zeros(size(A));
abs_rdev = mad;
w = false(size(A));
goodA = isfinite(A);
if length(A(goodA))>0
%    A_bar = exp(mean(log(A(goodA)))); %geometric mean
%    A_bar = mean(A(goodA));
%    abs_dev(goodA) = abs((A(goodA)-A_bar));
   abs_rdev(goodA) = abs((A(goodA)-A_bar(goodA))./A_bar(goodA));
%    abs_rdev(goodA) = abs(log10(A(goodA)./A_bar));
   
%    mad = mean(abs_dev(goodA));
   madr = mean(abs_rdev(goodA));
   w(goodA) = abs_rdev(goodA)<(thresh*madr);
end

