function [alpha_R, beta_R] = ray_a_b_lenoble(T, P, wavelength);
% function [alpha_R, beta_R] = ray_a_b(T, P);
% Returns Rayleigh backscatter and extinction coefficient in units of 1/(km*sr) 
% for a given temperature, pressure, and wavelength.
% T in Kelvin
% P in Pa (1 atm = 101300 Pa = 1013 mB)
% wavelength in meters
% If no wavelength is supplied, 532nm = 523e-9 meters is default
%
% For pure Rayleigh scattering, the extinction alpha is (8pi/3)*beta

%From Lenoble "Atmospheric Radiation Transfer" page 155 (12.27)
% Rayleigh tot scat alpha = (24pi^3/lambda^4) * ((m_s^2-1)/(m_s^2+2))^2 * ((6+3d)/(6-7d)) * N/(N_s^2)
% m_s ~=  1 + (77.46 + 0.459/lambda^2)* 1e-6 * P_o/T_o % where lambda[um], P_o[hPa] and T_o[K]
%   lambda = .523 % [um]
%   P_o = 1013.25 % [hPa]
%   T_o = 273.16 % [deg K]
% N_s = (N_A / R) * (P_o/T_o) % [K/J]
%   N_A = 6.023e23 % [1/mol]
%   R = 8.3143 % [J/(mol-K)]
% N = (N_A / R) * (P/T) % [K/J]

if (min(T)<0) 
   % negative temperatures, probably in Celcius. Converting to Kelvin.
   T = 273.15 + T;
end;
if (max(P)<1e4)
    %pressure is probably in hPa or mbarr.  Convert to Pa 
    P = P+100;
end;
    
%disp('Calculating Rayleigh Backscatter coefficient beta');
P_o = 101325; % [Pa]
T_o = 273.15; % [deg K]
if nargin >= 3
    lambda = wavelength;
else 
    lambda = 523e-9; %meter
end

lambda_um = lambda*1e6; % [um]
lambda_cm = lambda*100; %cm
mu = 1./lambda_cm;

m_s =  1 + (77.46 + 0.459./lambda_um.^2).* 1e-6 .* (P_o./100)./T_o ; % lambda[um], P_o[hPa] and T_o[K]

N_A = 6.023e23; % [1/mol]
R = 8.3143; % [J/(mol-K)]
N_no = (N_A ./ R);
%N_no = 0.7242996e22;
N_s = (N_no) .* (P_o./T_o); % [K/J]
N = (N_no) .* (P./T); % [K/J]

d = .0279; 
depol_factor = (6+3.*d)./(6-7.*d);% with d determined from P(90) = (1-d)/(1+d)
%depol_factor = 1.048; % depol factor may be as low as 1.023

alpha_R = 1000.*N.*(depol_factor).*(24.*pi.^3)./(lambda.^4) .* ((m_s.^2-1)./(m_s.^2+2)).^2 ./(N_s.^2);

%DP method, the snippet of code below is an alternate method from Donna Powell's thesis.  
% The index of refraction is differently parameterized, but the two methods agree 
% to the third decimal which is good enough for me.
% ao = 83.42;
% a1 = 185.08;
% a2 = 4.11;
% b1 = 1.14e5;
% b2 = 6.24e4;
% N_ro = (ao + a1/(1-(mu/b1)^2) + a2/(1-(mu/b2)^2))*(T_o +15)/(P_o/100); %pressure in mbar
% N_r = N_ro*(P./T)/100;
% n = N_r/1e6 + 1 ;%index of refraction as a function of range (via P,T profiles)

%alpha_R = 1000*((depol_factor)*(24*pi^3)/(lambda^4))*((n.^2-1)./(n.^2+2)).^2 ./N;

S_R = 8.*pi./3; %Extinction/backscatter ratio 

beta_R = alpha_R./S_R;

