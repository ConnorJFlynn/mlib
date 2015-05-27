function liny(ax);
%Applies linear-scale to y-axis;
if ~exist('ax','var')
   ax = gca;
end
set(ax,'yscale','linear');