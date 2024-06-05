function [good,P,S,mu] = rpoly_mad(X,Y,N,M,good);
% [good,P,S,mu] = rpoly_mad(X,Y,N,M,good);
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD (or specified M).
% Iterate until no points removed
if ~isavar('good')
   good = true(size(X));
end
if ~exist('N','var')
   N = 1;
end
if ~exist('M','var')
   M = 6;
end

if nargout >2
    [P,S,mu] = polyfit(X(good),Y(good),N);
    val = polyval(P,X,S,mu);
else
    P = polyfit(X(good),Y(good),N);
    val = polyval(P,X);
end

AD = abs(val - Y);
MAD = mean(AD(good));
new_good = (AD < (M.*MAD));
if any(good ~= new_good)&&sum(good)>N
   good = rpoly_mad(X,Y,N,M,new_good);
end
if nargout >2
    [P,S,mu] = polyfit(X(good),Y(good),N);
    val = polyval(P,X,S,mu);
else
    P = polyfit(X(good),Y(good),N);
    val = polyval(P,X);
end

return