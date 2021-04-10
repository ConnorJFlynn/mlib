function A = test_overlap(r,R,d,L)

% A = area_overlap(r, R, d, L)
if ~isavar('r') r = 7; end
if ~isavar('R') R = 9; end
if ~isavar('d') d = [-30:.1:30]; end
if ~isavar('L') L = 250; end
A = area_overlap(r, R, d);
figure; plot( atand(d./L),A);
xlabel('deg'); ylabel('T');
title(sprintf('r = %g, R = %g, L = %g',r,R,L))

% 20 mm blank at end of 250 mm baffle with 25 mm OD....
% half-angle
