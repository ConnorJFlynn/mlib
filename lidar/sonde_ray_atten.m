function [atten_bscat,tau, altitude, temperature, pressure] = sonde_ray_atten(sonde_fid, range);
% [atten_bscat,tau,altitude,temperature,pressure] = sonde_ray_atten(sonde_fid);
% [atten_bscat,tau,max_altitude,temperature,pressure] = sonde_ray_atten(sonde_fid, range);
%  
% This function requires an open sonde netcdf fid.  From this open file, 
% the temperature (tdry), pressure (pres), and altitude (alt) are retrieved.
% Raleigh scattering and extintion coefficients alpha_ray and beta_ray are 
% calculated from the temperature and pressure profiles.  An attenuated
% Rayleigh scattering profile and integrated optical depth profile are produced for
% the sonde altitudes.
% Finally, if a range profile was supplied, the attenuated scattering, 
% optical depth, temperature, and pressure are interpolated to the match
% the supplied range up to the max_altitude of the sonde.

altitude = nc_getvar(sonde_fid, 'alt');
if (max(altitude) >= 1000) 
   altitude = altitude/1000; % convert from meter to km
end;
temperature = nc_getvar(sonde_fid, 'tdry');
if (min(temperature) <= 0)
   temperature = temperature + 273.15; % convert from Celcius to Kelvin
end;
pressure = nc_getvar(sonde_fid, 'pres'); % pressure is already in hPa ~= mBarr

[altitude, i] = sort(altitude);
temperature = temperature(i);
pressure = pressure(i);
dups = find(diff(altitude)==0)+1;

altitude(dups) = [];
temperature(dups) = [];
pressure(dups) = [];
max_height = max(altitude);

%Then, with the TP profs, call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(temperature,pressure);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + 0;
beta = beta_R + 0;
%Then calculate attenuated backscatter profile and optical depth tau
tau = cumtrapz(altitude, alpha); 
atten_bscat = beta .* exp(-2*tau);

if (nargin>1) 
    %First convert range to km if necessary
    if (max(range)>100)
        range_km = range / 1000;
    else range_km = range;
    end;

    atten_bscat = interp1(altitude,atten_bscat,range_km,'spline',NaN);
    tau = interp1(altitude,tau,range_km,'spline',NaN);
    temperature = interp1(altitude, temperature, range_km, 'spline',NaN);
    pressure = interp1(altitude, pressure, range_km, 'spline',NaN);
    
    altitude = range(find(range<=max_height));

    bad_range = find((range_km > max_height)|(range_km <0));
    atten_bscat(bad_range) = []; 
    tau(bad_range) = [];
    temperature(bad_range) = [];
    pressure(bad_range) = [];
    altitude = max_height;
end;


