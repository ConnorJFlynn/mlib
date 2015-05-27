function [alpha_a, beta_a, tau_new] = mpl_klett(range, X, aod, lidar_C, beta_R, Sa)
% [beta_a, tau_new] = mpl_klett(range, X, aod, lidar_C, alpha_R, beta_R, Sa)
% returns aerosol backscatter coef beta and new tau_aerosol
% requires:
% range
% X: uncalibrated attenuated lidar profile, 
% aod: measured aerosol optical depth at lidar wavelength
% lidar_C: lidar calibration constants such that X/C = attenuated lidar profile beta_prime
% alpha_R, beta_R: molecular extinction and backscatter coefficient profiles
% accepts:
% Sa: aerosol extinction to backscatter ratio

if (nargin < 6)
   Sa = 30;
end;

%  determine tau_R_z and tau_top
Sr = 8 * pi / 3;
alpha_R = Sr * beta_R;
tau_R_z = cumtrapz(range, alpha_R); 
atten_prof_R = beta_R .* exp(-2*tau_R_z);

% [atten_prof_R, tau_R_z] = atten_prof(range,alpha_R,beta_R);

tau_top = max(tau_R_z) + aod;

z_top = length(X);
beta = zeros(size(X));
Y = zeros(size(X));
beta_prime = X./lidar_C;
Y(z_top) = beta_prime(z_top);
beta(z_top) = Y(z_top)./exp(-2*tau_top);
% beta(z_top) = profile(z_top)/(lidar_C*exp(-2*tau_top));
% Y(z_top) = profile(z_top);
for z = (z_top-1): -1: 1
   Y(z) = (beta_prime(z)*exp(2*(Sa-Sr)*trapz(range(z:z_top),beta_R(z:z_top))));
   beta(z) = Y(z)/(exp(-2*tau_top) + 2*Sa*trapz(range(z:z_top),Y(z:z_top)));
% !!  if beta(z)<0, beta(z) =0;
end

beta_a = beta - beta_R;
alpha_a = Sa * beta_a;

alpha = alpha_R + alpha_a;
tau_new = trapz(range,alpha_a);
%[Sa, tau_new]
