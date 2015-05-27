function [alpha_R, beta_R] = ray_a_b_measures(T, P, wavelength);
% function [alpha_R, beta_R] = ray_a_b_measures(T, P,wavelength);
% Returns Rayleigh backscatter and extinction coefficient in units of 1/(km*sr) 
% for a given temperature, pressure, and wavelength.
% T in Kelvin
% P in Pa (1 atm = 101300 Pa = 1013 mB)
% wavelength in nm
% If no wavelength is supplied, 532nm is default
%
% From Measures page 42, the Rayleigh backscatter cross section sigma is given by
%    sigma_pi_Ray = 5.45e-28 * (550/lambda)^4 
% and the backscatter volume coefficient beta is just
%    beta = Nd * sigma where Nd is the number density.
% The number density is found from the ideal gas law:
% PV = nRT = nkNT  ==> Nd = n*N*/V = P/k*T 
% For pure Rayleigh scattering, the extinction coef alpha is (8pi/3)*beta

if nargin >= 3
    lambda = wavelength;
else 
    lambda = 523; %meter
end

sigma_pi_Ray = 5.45e-28 * (550/lambda)^4 ; % Units cm^2/sr

boltzmanns_konstant = 1.381e-23; %units J/K
NumberDensity = 1e-6*P./(boltzmanns_konstant*T); % Units molecules / cm^3
beta_R = sigma_pi_Ray .* NumberDensity; %units 1/(cm-sr)
beta_R = beta_R * 1e5; % units now in inverse km
alpha_R = beta_R * 8*pi./3;

