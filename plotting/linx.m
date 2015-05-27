function linx(ax);
%Applies linear-scale to x-axis;
if ~exist('ax','var')
   ax = gca;
end
set(ax,'xscale','linear');