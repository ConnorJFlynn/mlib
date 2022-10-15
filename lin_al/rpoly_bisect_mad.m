function good = rpoly_bisect_mad(X,Y,N,M,good);
%good = rpoly_mad(X,Y,N,M,good);
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?
if ~exist('good','var')
   good = ones(size(X));
end
if ~exist('N','var')
   N = 1;
end
if ~exist('M','var')
   M = 6;
end
[P,S,mu] = polyfit(X(good>0),Y(good>0),N);
[P_,S_,mu_] = polyfit(Y(good>0),X(good>0),N);
val = polyval(P,X,S,mu);
AD = abs(val - Y);
MAD = mean(AD(good>0));
new_good = (AD < (M.*MAD));
if any(good ~= new_good)
   good = rpoly_bisect_mad(X,Y,N,M,new_good);
end
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return