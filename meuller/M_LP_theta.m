function M = M_LP_theta(theta)
% M = M_LP_theta(theta)
% Returns Mueller matrix for linear polarizer aligned at theta degrees
theta = theta * pi/180;
Row1 = [1,cos(2*theta),sin(2*theta),0];
Row2 = [cos(2*theta),(cos(2*theta).^2),(sin(2*theta))*cos(2*theta),0];
Row3 = [sin(2*theta),(sin(2*theta))*cos(2*theta),(sin(2*theta).^2),0];
Row4 = [0, 0, 0, 0];
M = 0.5*[Row1;Row2;Row3;Row4];
return 