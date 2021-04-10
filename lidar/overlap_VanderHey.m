function R = overlap_VanderHey(bo);
% bo is the location of the target as a fraction of the b-lens focal
% distance fb.  So it should be between 0:1.

% we want to place lens b so that the sp is at the focal point.
% and we want to select lens b such that 

% Not correct yet.  Unclear if relative distances are wrong or what.

if ~isavar('bo')  bo = [0.1:0.01:.999; end
fa = 1;
w = 3;  % Set w > fa
sp = fa.*w./(w-fa);

fb = .4;
b = fb.*bo;
ao = fb + sp - b*fb./(b-fb);
R = w + fa.*ao./(fa-ao);