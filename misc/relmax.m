function [ri] = relmax(x)
% [ri] = relmax(x)
% returns indices of relative maxima sorted from highest to lowest
% If x is a matrix maxima are reported along first non-singleton dim
% or along dim in optional arg.
   dim = find((size(x)>1));
   if ~isempty(dim)
      dim= dim(1);
   else
      dim = 1;
   end
rmax = false(size(x));
rmax(1) = x(1)>=x(2);
rmax(end) = x(end)>=x(end-1);
rmax(2:end-1) = x(2:end-1)>=x(1:end-2) & x(2:end-1)>= x(3:end);
ri = find(rmax);
[~, ri_] = sort(x(rmax),dim,'descend');
ri = ri(ri_);

% %%
% plot([1:length(x)],x,'.b-', ri, rmax,'ro')
% %%
return
