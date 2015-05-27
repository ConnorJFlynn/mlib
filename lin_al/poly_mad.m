function good = poly_mad(X,Y,N,good);
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?
if ~exist('good','var')
   good = ones(size(X));
end
[P,S,mu] = polyfit(X(good>0),Y(good>0),N);
val = polyval(P,X,S,mu);
AD = abs(val - Y);
MAD = mean(AD(good>0));
new_good = (AD < (6*MAD));
if any(good ~= new_good)
   good = poly_mad(X,Y,N,new_good);
end
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return