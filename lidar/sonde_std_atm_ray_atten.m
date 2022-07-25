function [attn_prof,tau, altitude, temperature, pressure] = sonde_std_atm_ray_atten(sonde, range);
% [attn_prof,tau,altitude,temperature,pressure] = sonde_ray_atten(sonde_fid);
% [attn_prof,tau,max_altitude,temperature,pressure] = sonde_ray_atten(sonde_fid, range);
%  
% This function requires an open sonde netcdf fid.  From this open file, 
% the temperature (tdry), pressure (pres), and altitude (alt) are retrieved.
% These profiles are extrapolated as necessary to extend fully from 0-30 km.
% Raleigh scattering and extintion coefficients alpha_ray and beta_ray are 
% calculated from the temperature and pressure profiles.  An attenuated
% Rayleigh scattering profile and integrated optical depth profile are produced for
% the sonde altitudes.
% Finally, if a range profile was supplied, the attenuated scattering, 
% optical depth, temperature, and pressure are interpolated to the match
% the supplied range up to the max_altitude of the sonde.
if (nargin == 0)||isempty(sonde)
    sonde_file = getfullname('*.nc;*.cdf','sonde','Select a sonde file');
    sonde = anc_load(sonde_file);
end
if isstruct(sonde)
   altitude = sonde.vdata.alt';
   temperature = sonde.vdata.tdry';% Temp is in C
   pressure = sonde.vdata.pres'; % pressure is already in hPa ~= mBarr
end
if (max(altitude) >= 1000) 
   altitude = altitude/1000; % convert from meter to km
end;
if (min(temperature) <= 0)
   temperature = temperature + 273.15; % convert from Celcius to Kelvin
end;


[altitude, i] = unique(altitude);
altitude = altitude';
temperature = temperature(i)';
pressure = pressure(i)';


std_alt=[0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
%std_temp=[301.15 288.16 277.19 266.22 252.29 238.35 224.42 210.49 203.15 207.38 211.75 216.11 220.47 224.83 229.19 233.55];
%std_press=[1012.9 803.23 631.1 491.12 377.68 286.18 213.29 156.03 112.04 80.491 58.235 42.42 31.103 22.948 17.034 12.717];

%extrapolate temperature and pressure over 0-30 km
num_alt = length(altitude);
low_alt = [1:ceil(num_alt/4)];
low_std_alt = find(std_alt<min(altitude));
if length(low_std_alt)>0
   P = polyfit(altitude(low_alt), (temperature(low_alt)), 1);
   low_alt_temp = (polyval(P,std_alt(low_std_alt)));
   P = polyfit(altitude(low_alt), log(pressure(low_alt)), 1);
   low_alt_pres = exp(polyval(P,std_alt(low_std_alt)));
   altitude = [std_alt(low_std_alt) altitude];
   temperature = [low_alt_temp temperature];
   pressure = [low_alt_pres pressure];
end
high_alt = [floor(0.75*num_alt):num_alt];
high_std_alt = find(std_alt>max(altitude));
if length(high_std_alt)>0
   P = polyfit(altitude(high_alt), (temperature(high_alt)), 1);
   high_alt_temp = (polyval(P,std_alt(high_std_alt)));
   P = polyfit(altitude(high_alt), log(pressure(high_alt)), 1);
   high_alt_pres = exp(polyval(P,std_alt(high_std_alt)));
   altitude = [altitude, std_alt(high_std_alt)];
   temperature = [temperature,high_alt_temp];
   pressure = [pressure, high_alt_pres];
end

min_height = min(altitude);
max_height = max(altitude);
%Okay, we have the profiles out to 30 km.  Now, interpolate to match the
%input range profile if one was supplied.
if (nargin>1) 
    %First convert range to km if necessary
    if (max(range)>100)
        range_km = range / 1000;
    else range_km = range;
    end;
    temperature = interp1(altitude, temperature, range_km, 'linear','extrap');
    pressure = real(exp(interp1(altitude, log(pressure), range_km,'linear','extrap')));
    altitude = range;
end;

%Then, with the TP profs, call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(temperature,pressure);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + 0;
beta = beta_R + 0;
%Then calculate attenuated backscatter profile and optical depth tau

tau = cumtrapz(altitude, alpha); 
attn_prof = beta .* exp(-2*tau);

