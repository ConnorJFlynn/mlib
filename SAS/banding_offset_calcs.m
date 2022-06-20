Sel = [0:90];
d2r = pi./180;
h = .25; 
R = 8;

val = atand(tand(Sel) + .25./8);

figure; plot(Sel, val-Sel ,'o')
%-- 6/19/2022 9:39 PM --%
atand(.25 / 8.0)

gamma = Sel + asind(sind(90-Sel).*h./R);

figure; plot(Sel, gamma-Sel,'x')

figure; plot(Sel, gamma-val,'rx')