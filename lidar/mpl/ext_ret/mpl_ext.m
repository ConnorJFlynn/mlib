function [alpha_a, beta_a, tau_new] = mpl_ext(range, profile, lidar_C, tau_top, alpha_R, beta_R, Sa)
% [alpha_a, beta_a, tau_new] = mpl_ext(profile, lidar_C, tau_net, alpha_R, beta_R)
% returns aerosol alpha, beta, and tau_aerosol
% requires:
%   range
%   attenuated profile
%   lidar_C
%   tau
%   alpha_R
%   beta_R
% accepts:
%   Sa: initial value (final value through iteration)
% S = sigma / beta
% Sa = sigma_aerosol / beta_aerosol ; assume some value then iterate until integrated optical depth agrees.
% S_ray = sigma_ray / beta_rayh = 8*pi / 3

if (nargin < 7)
    Sa = 30;
end;

%  determine tau_R and tau_a

% [atten_prof_R, tau_R_z] = atten_prof(range,alpha_R,beta_R);
tau_R_z = cumtrapz(range, alpha_R); 
atten_prof_R = beta_R .* exp(-2*tau_R_z);

% tau_R = tau_R_z(length(tau_R_z));
% tau_a = tau_top - tau_R;beta(z_top)

Sr = 8 * pi / 3;

z_top = length(profile);

beta(z_top) = profile(z_top)/(lidar_C*exp(-2*tau_top));
Y(z_top) = profile(z_top);
for z = (z_top-1): -1: 1
   Y(z) = profile(z)*exp(-2*(Sa-Sr)*trapz(fliplr(range(z:z_top)),beta_R(z:z_top)));
   beta(z) = Y(z)/(lidar_C*exp(-2*tau_top) - 2*Sa*trapz(fliplr(range(z:z_top)),Y(z:z_top)));
end

beta_a = beta - beta_R;
alpha_a = Sa * beta_a;

alpha = alpha_R + alpha_a;
tau_new = trapz(range,alpha);
