function logy(ax);
%Applies log-scale to y-axis;
if ~exist('ax','var')
   ax = gca;
end
set(ax,'yscale','log');