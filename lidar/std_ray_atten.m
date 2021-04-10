function [atten_bscat,tau, ray_tod] = std_ray_atten(altitude_msl, wavelength);
% Usage: [atten_bscat,tau,ray_tod] = std_ray_atten(altitude_msl, wavelength);
% Provided with altitude_msl, this function returns the attenuated Rayleigh backscatter
% profile and rayleigh optical depth for the std atmosphere (max altitude_msl 30 km)
% This procedure calculates Rayleigh attenuated backscatter for a standard atm
% It also returns tod_ray (total Rayleigh optical depth) computed as:
% ! Rayleigh optical thickness (tau_r) computed from Equation 7 of Gordon et al. 
% !	
% !	Gordon, H.R., J.W. Brown and R.H. Evans, 1988, "Exact Rayleigh 
% !		Scattering calculations for use with the Nimbus 7 Coastal 
% !		Zone Color Scanner", Applied Optics, 27, 862-871
% !
% ! tau_r = 0.008569 * um^(-4) * (1.0 + (0.0113 * um^(-2)) + (0.00013 * um^(-4))) 
% !   where um = wavelength in micrometers
% !

%First convert altitude_msl to km if necessary
[altitude_msl_sorted, ii] = sort(altitude_msl);
if ~exist('altitude_msl','var')
   altitude_msl = 1:30;
end
if nargin<2
   wavelength = 523e-9;
end
   if wavelength > 1 %Wavelength is probably in nm
      wavelength = 1e-9 * wavelength; % Convert from nm to m
   end
if (max(altitude_msl)>100)
    altitude_msl_km = altitude_msl / 1000;
else altitude_msl_km = altitude_msl;
end;
%First, use std_atm for temperature (K) and pressure (mbar) as fn of altitude_msl (km) 
[T,P] = std_atm(altitude_msl_km);
%Then, with the TP profs, call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P,wavelength);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + 0;
beta = beta_R + 0;
%Then calculate attenuated backscatter profile and optical depth tau
um = wavelength*1e6;
tau(ii) = (cumtrapz(altitude_msl_km(ii), alpha(ii))); tau = tau';
atten_bscat = beta .* exp(-2*tau);
ray_tod = (0.008569 .* (um .^(-4))) * (1.0 + (0.0113 .* (um.^(-2))) + (0.00013 .* (um.^(-4)))) ;







