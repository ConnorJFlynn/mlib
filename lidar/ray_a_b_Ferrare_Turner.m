function [alpha_R, beta_R] = ray_a_b_Ferrare_Turner(T, P, wavelength);
% function [alpha_R, beta_R] = ray_a_b_measures(T, P,wavelength);
% Returns Rayleigh backscatter and extinction coefficient in units of 1/(km*sr) 
% for a given temperature, pressure, and wavelength.
% T in Kelvin
% P in Pa (1 atm = 101300 Pa = 1013 mB)
% wavelength in nm
% If no wavelength is supplied, 532nm is default
%
% From IDL code written by Dave Turner of an algorithm by Rich Ferrare
% backscatter volume coefficient beta = Nd * sigma where Nd is the number density.
% The number density is found from the ideal gas law:
% PV = nRT = nkNT  ==> Nd = n*N*/V = P/k*T 
% For pure Rayleigh scattering, the extinction coef alpha is (8pi/3)*beta



if nargin >= 3
    lambda = wavelength;
else 
    lambda = 523; %meter
end

% IDL syntax from rayleigh_cross_section written by Dave Turner, logic by Rich Ferrare
% Using refractive index of air from Penndorf (1957) 
% lambda = 523
  wavem = lambda ./ 1000.0	; %Wavelength in microns
  wavec = wavem ./ 10000.0	; %Wavelength in centimeters
  zms1 = 6432.80;
  zms2 = 2949810.0 ./ (146.0 - wavem.^(-2));
  zms3 = 25540.0 ./ (41.0 - wavem.^(-2));
  zms  = 1.0 + ((zms1 + zms2 + zms3) ./ 1.0e8);
  zns  = 2.547e19;
  del  = 0.035;
  sigr1 = (8.0 * pi.^3 .* (((zms.*zms - 1.0).^2))) ./ (3.0 * (wavec.^4) .* zns .* zns);
  sigr2 = (6.0 + 3.0 .* del) ./ (6.0 - 7.0 .* del);
  sigr = sigr1 .* sigr2;

sigma_pi_Ray = sigr .* 3 ./(8.*pi);
boltzmanns_konstant = 1.381e-23; %units J/K
NumberDensity = 1e-6*P./(boltzmanns_konstant.*T); % Units molecules / cm^3
beta_R = sigma_pi_Ray .* NumberDensity; %units 1/(cm-sr)
beta_R = beta_R .* 1e5; % units now in inverse km
alpha_R = beta_R .* 8*pi./3;

