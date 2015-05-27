function [atten,tau] = ray_atten_profs(range, T, P, wavelength);
% [atten_prof,tau] = ray_atten_profs(range, T, P, wavelength);
% Provided with range, temperature, and pressure, this function returns vertical 
% profiles of the attenuated Rayleigh backscatter profile and Rayleigh
% optical depth tau
% Range in km (but will auto-correct if input as meters)
% T in Kelvin 
% P in hPa (1 atm = 101300 Pa = 1013 mB)
% wavelength in meters
% If no wavelength is supplied, 532nm = 523e-9 meters is default

if nargin >= 4
    lambda = wavelength;
else 
    lambda = 523e-9; %meter
end

%First convert range to km if necessary
if (max(range)>100)
    range = range / 1000;
end;

%Call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P,lambda);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + 0;
beta = beta_R + 0;
%Then calculate attenuated backscatter profile and optical depth tau
tau = cumtrapz(range, alpha); 
atten = beta .* exp(-2*tau);





