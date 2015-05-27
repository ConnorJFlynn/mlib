function [ri] = relmin(x,dim)
% [ri] = relmin(x,dim)
% returns indices of relative minima sorted from lowest
% If x is a matrix maxima are reported along first non-singleton dim
% or along dim in optional arg.
if ~exist('dim','var')
   dim = find(size(x)>1);
   if ~isempty(dim)
      dim= dim(1);
   else
      dim = 1;
   end
end
rmin = false(size(x));
rmin(1) = x(1)<=x(2);
rmin(end) = x(end)<=x(end-1);
rmin(2:end-1) = x(2:end-1)<=x(1:end-2) & x(2:end-1)<= x(3:end);
ri = find(rmin);
[rmin, ri_] = sort(x(rmin),dim);
ri = ri(ri_);

return