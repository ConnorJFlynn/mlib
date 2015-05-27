function [alpha, beta] = rayleigh(T,P,wavelength);
% [alpha, beta] = rayleigh(T,P,wavelength);
% Returns Rayleigh extinction and backscatter coefficients in 1/(km*sr).  
% Requires T (temperature in Kelvin) and P (pressure in mB)
% (1 atm = 101300 Pa = 1013 mB)
% If specified, wavelength must be in units of meters, e.g. 532nm = 5.23e-9
% For pure Rayleigh scattering, the extinction alpha is (8pi/3)*beta

if max(P)>2000 %Pressure is probably in Pa
   P = P/100; % Convert Pa to mB
end
if min(T)<=0 % Temperature is probably in C
   T = T + 273.15; %Convert C to K
end
if wavelength > 1 %Wavelength is probably in nm
   wavelength = 1e-9 * wavelength; % Convert from nm to m
end
 
%[alpha, beta] = ray_a_b(T, P, wavelength);
%[alpha, beta] = ray_a_b_DP(T, 100*P, wavelength);
%[alpha, beta] = ray_a_b_lenoble(T, 100*P, wavelength);
[alpha, beta] = ray_a_b_measures(T, 100*P, 1e9*wavelength);
%[alpha, beta] = ray_a_b_Ferrare_Turner(T, 100*P, 1e9*wavelength);
