function [beta_r,sigma_r]=rayleigh_cross(lambda,p,T,gas)
%Computes Rayleigh Cross-section and Volume-Scattering Coefficient in
%Bucholz, 1995. Equations 1. and 9.
%lambda has to be in microns

N=2.54743e19 %[cm-3] molecular number density of standard air from Bucholz 288.15 K, 1013.25 mbar
%N=2.546899e19 %[cm-3] molecular number density of standard air from Bodhaine

Ts=288.15;
ps=1013.25;

switch gas
    case 'air'
    F_King=F_air(lambda,0.030); %King Factor
    n=n_air(lambda); %compute refractive index
case 'CO2'
    F_King=1.15;
    n=n_CO2(lambda); 
case 'N2'
    F_King=F_N2(lambda); %King Factor
    n=n_N2(lambda); 
end


lambda=lambda/1e4; %convert to cm
sigma_r=24*pi^3./(lambda.^4.*N.^2).*(n.^2-1).^2./(n.^2+2).^2.*F_King % Rayleigh scattering cross-section [cm^2]

beta_r=N.*1e5.*sigma_r*p/ps*Ts/T% [km^-1] 

