function [alpha_a, beta_a, tau_new] = mpl_fernald(range, X, lidar_C, beta_R, Sa)
% [alpha_a, beta_a, tau_new] = mpl_fernald(range, X, lidar_C, alpha_R, beta_R, Sa)
% returns aerosol alpha, beta, new tau_aerosol
% requires:
% range
% X: attenuated lidar profile
% Bbsp: measured surface aerosol backscatter coef at lidar wavelength
% lidar_C: lidar calibration constants such that X./C = beta_prime
% beta_R: molecular backscatter coefficient profile
% accepts:
% Sa: aerosol extinction to backscatter ratio
% S = sigma / beta
% Sa = sigma_aerosol / beta_aerosol ; assume some value then iterate until integrated optical depth agrees.
% S_ray = sigma_ray / beta_rayh = 8*pi / 3
% This implementation assumes the calibration range is zero and that the transmittance to this point 
% is also zero.  Combined with a slant-sensing approach, this routine could be modified to use
% alternate calibration ranges, for example.

if (nargin < 5)
    Sa = 30;
end;

%  determine tau_R and tau_a
Sr = 8 * pi / 3;
alpha_R = Sr * beta_R;
tau_R_z = cumtrapz(range, alpha_R); 
atten_prof_R = beta_R .* exp(-2*tau_R_z);

% [, ] = atten_prof(range,alpha_R,beta_R);
%tau_cal = max(tau_R_z) + aod;
% tau_R = tau_R_z(length(tau_R_z));
% tau_a = tau_top - tau_R;beta(z_top)

z_top = length(X);
beta = zeros(size(X));
beta_prime = X./lidar_C;
Y(1) = beta_prime(1);
beta(1) = Y(1);
for z = 2:(z_top)
   Y(z) = beta_prime(z)*exp(-2*(Sa-Sr)*trapz(range(1:z),beta_R(1:z)));
   beta(z) = Y(z)/(1 - 2*Sa*trapz(range(1:z),Y(1:z)));
end

beta_a = beta - beta_R;
alpha_a = Sa * beta_a;

alpha = alpha_R + alpha_a;
tau_new = trapz(range,alpha_a);
%[Sa, tau_new]
