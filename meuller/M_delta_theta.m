function M = M_delta_theta(delta, theta)
% M = M_delta_theta(delta, theta)
% Returns the Mueller matrix for an arbitrary retardation delta 
% (in deg with 90 deg = quarter-wave) along theta degrees from slow axis
% Method: first compute retardation for quarter wave at theta.
% Then, take the real Nth root for N = deg.
% theta = theta * pi/180;
M_QW = M_QW_theta(theta);
N = 90/delta;
M = real(M_QW^(1/N));
return