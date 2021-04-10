function [atten_bscat, tau, altitude, temperature, pressure] = get_sonde_ray_atten(range);
% [atten_bscat,tau,altitude,temperature,pressure] = get_sonde_ray_atten;
% [atten_bscat,tau,max_altitude,temperature,pressure] = get_sonde_ray_atten(range);
%  
% This function prompts the user for a sonde netcdf file and opens it retrieving
% the altitude (alt), temperature (tdry), and pressure (pres) profiles.
% Raleigh scattering and extintion coefficients alpha_ray and beta_ray are 
% calculated from the temperature and pressure profiles.  An attenuated
% Rayleigh scattering profile and integrated optical depth profile are produced for
% the sonde altitudes.
% Finally, if a range profile was supplied, the attenuated scattering, 
% optical depth, temperature, and pressure are interpolated to the match
% the supplied range up to the max_altitude of the sonde.
sonde_file = getfullname('*.nc;*.cdf','sonde','Select a sonde file');
sonde = anc_load(sonde_file);

if (nargin==0)
    [atten_bscat, tau, altitude, temperature, pressure] = sonde_ray_atten(sonde);
else 
    [atten_bscat, tau, max_altitude, temperature, pressure] = sonde_std_atm_ray_atten(sonde, range);
    altitude = max_altitude;  %pass max_altitude back instead of sonde altitude profile
end;
