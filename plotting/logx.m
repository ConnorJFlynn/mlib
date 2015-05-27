function logx(ax);
%Applies log-scale to x-axis;
if ~exist('ax','var')
   ax = gca;
end
set(ax,'xscale','log');