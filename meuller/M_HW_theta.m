function M = M_HW_theta(theta)
%M = M_HW_theta(theta)
%Returns the Mueller matrix for a half wave plate with fast axis at
%angle theta (degrees) measured from vertical, M_HW_theta(0) == M_HWV
%
% 
theta = theta * pi/180;
Row1 = [1,0,0,0];
Row2 = [0,(cos(2*theta).^2),(sin(2*theta))*cos(2*theta),(sin(2*theta))*(-1)];
Row3 = [0,(sin(2*theta))*cos(2*theta),(sin(2*theta).^2), cos(2*theta)];
Row4 = [0,sin(2*theta),cos(2*theta)*(-1),0];
M = [Row1;Row2;Row3;Row4];
M = M * M;
return