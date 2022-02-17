function [alpha_R, beta_R] = ray_a_b_DP(T, P, wavelength);
% function [alpha_R, beta_R] = ray_a_b_DP(T, P);
% Returns Rayleigh backscatter and extinction coefficient in units of 1/(km*sr) 
% Requires T (K) and P in Pa (1 atm = 101300 Pa = 1013 mB)
% wavelength in meters
% If no wavelength is supplied, 532nm = 523e-9 meters is default
% For pure Rayleigh scattering, the extinction alpha is (8pi/3)*beta

if nargin==3 
  lambda = wavelength;
else
   lambda = 523e-9; %meters 
end;

if (min(T)<0) 
   % negative temperatures, probably in Celcius. Converting to Kelvin.
   T = 273.15 + T;
end;

%disp('Calculating Rayleigh Backscatter coefficient beta');
T_o = 273.15;
P_o = 101325;

lambda_cm = lambda*100; %cm
mu = 1./lambda_cm;

ao = 83.42;
a1 = 185.08;
a2 = 4.11;
b1 = 1.14e5;
b2 = 6.24e4;
% 
% N_no = 0.7242996e22;  %number per unit volume = N_A/R 6.023e23/8.314

% beta_o = (9 * pi^2/lambda^4)*(6+3*.0279)/(6-7*.0279); %
% beta_R = (beta_o./N_n).*((n.^2-1)./(n.^2+2)).^2;
% S_R=8*pi/3; %relationship between pure Rayleigh backscatter beta and extinction alpha
% alpha_R = beta_R * S_R;

N_A = 6.023e23; % [1/mol]
R = 8.3143; % [J/(mol-K)]
N_no = (N_A ./ R);
%N_no = 0.7242996e22;
N_s = (N_no) * (P_o./T_o); % [K/J]
N = (N_no) * (P./T); % [K/J]

d = .0279; 
depol_factor = (6+3*d)./(6-7*d);% with d determined from P(90) = (1-d)/(1+d)
%depol_factor = 1.048; % depol factor may be as low as 1.023


%DP method
N_ro = (ao + a1./(1-(mu./b1).^2) + a2./(1-(mu./b2).^2))*(T_o +15)./(P_o./100); %pressure in mbar
N_r = N_ro.*(P./T)./100;
n = N_r./1e6 + 1 ;%index of refraction as a function of range (via P,T profiles)

alpha_R = 1000*((depol_factor)*(24*pi.^3)./(lambda.^4)).*((n.^2-1)./(n.^2+2)).^2 ./N;

S_R = 8*pi./3; %Extinction/backscatter ratio 

beta_R = alpha_R./S_R;






