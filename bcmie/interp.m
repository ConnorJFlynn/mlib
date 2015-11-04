% interp(xvals, yvals, newx) interpolates to newx
function newy = interp(xval, yval, newx)

% Start return matrix
newy = nan(size(newx));

% Sort xval
[xval, xidx] = sort(xval);
yval = yval(xidx);
dydx = diff(yval)./diff(xval);

% Loop through x-values, one x-interval at a time
for i=1:(length(xval)-1)
    idx = find(newx>=xval(i) & newx<=xval(i+1));
    ycalc = yval(i) + (newx(idx) - xval(i)) * dydx(i);
    newy(idx) = ycalc;
end

return
