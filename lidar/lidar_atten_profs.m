function [atten,tau,atm_trans] = lidar_atten_profs(range, T, P,wavelength, alpha_a, beta_a);
% [atten_prof,tau, atm_trans] = lidar_atten_profs(range, T, P, alpha_a, beta_a, wavelength);
% Provided with range, temperature, and pressure, this function returns vertical 
% profiles of the attenuated Rayleigh backscatter profile and Rayleigh
% optical depth tau
% Range in km (but will auto-correct if input as meters)
% (To compute top-down, invert range but nothing else.)
% T in Kelvin 
% P in hPa (1 hPa = 1 mB, 1 atm = 101300 Pa = 1013 mB)
% wavelength in meters
% If no wavelength is supplied, 532nm = 523e-9 meters is default
if ~exist('wavelength','var')
   lambda = 532e-9;
else
   lambda = wavelength;
end
if ~exist('alpha_a','var')
   alpha_a = zeros(size(T));
end
if ~exist('beta_a','var')
   beta_a = zeros(size(T));
end

if nargin >= 4
    lambda = wavelength;
else 
    lambda = 523e-9; %meter
end

   if max(P)>2000 %Pressure is probably in Pa
      P = P/100; % Convert Pa to mB
   elseif max(P)>50 && max(P)<200 %Pressure probably in kPa, convert to mB
      P = 10*P;
   elseif max(P)<10 %Pressure is probably in Barr
      P = 1000 * P;
   end

%First convert range to km if necessary
if (max(range)>100)
    range = range / 1000;
end;

%Call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P,lambda);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + alpha_a;
beta = beta_R + beta_a;
%Then calculate attenuated backscatter profile and optical depth tau
tau = zeros(size(range));
atm_trans = ones(size(range));
nonNaN = ~isNaN(alpha);
tau(nonNaN) = cumtrapz(range(nonNaN), alpha(nonNaN)); 
atm_trans(nonNaN) = exp(-tau(nonNaN));
atten = beta .* (atm_trans.^2);





