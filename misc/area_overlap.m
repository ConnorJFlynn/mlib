function A = area_overlap(r, R, d)
% r: radius of smaller circle
% R: radius of larger circle
% d: offset between circle centers?
d = abs(d);

part_1 = r.^2 .* (acos((d.^2 + r.^2 -R.^2)./(2.*d.*r)));
part_2 = R.^2 .* (acos((d.^2 + R.^2 -r.^2)./(2.*d.*R)));
part_3 = -0.5.*sqrt((r+R-d).*(d+r-R).*(d+R-r).*(d+r+R));

A = part_1 + part_2 + part_3;
A = A./ (pi.*r.^2);

return