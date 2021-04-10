function good = rpoly_mad(X,Y,N,M,good);
%good = rpoly_mad(X,Y,N,M,good);
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?
if ~exist('good','var')
   good = true(size(X));
end
if ~exist('N','var')
   N = 1;
end
if ~exist('M','var')
   M = 6;
end
[P,S,mu] = polyfit(X(good),Y(good),N);

val = polyval(P,X,S,mu);
AD = abs(val - Y);
MAD = mean(AD(good));
new_good = (AD < (M.*MAD));
if any(good ~= new_good)&&sum(good>N)
   good = rpoly_mad(X,Y,N,M,new_good);
end
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return