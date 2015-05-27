function [atm_temp, atm_press, range] = std_atm(range);
%function [atm_temp, atm_press, range] = std_atm(range);
%returns profiles of temperature (K) and pressure (hPa=mB) as a function of range in km.
%Max range is 30 km
%Standard Temp and Pressure Interpolation for range in km

alt=[0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
std_temp=[301.15 288.16 277.19 266.22 252.29 238.35 224.42 210.49 203.15 207.38 211.75 216.11 220.47 224.83 229.19 233.55];
std_press=[1012.9 803.23 631.1 491.12 377.68 286.18 213.29 156.03 112.04 80.491 58.235 42.42 31.103 22.948 17.034 12.717];
if nargin==0
   range = alt;
end
if max(range > 1000) % Then range was entered in meters
    range= range / 1000;
end;
atm_temp = 1e-99*ones(size(range));
atm_press = 1e-99*ones(size(range));

neg_range = find(range<0);
pos_range = find((range>=0)&(range<=30));

atm_temp(pos_range)=interp1(alt,std_temp,range(pos_range),'spline');
atm_press(pos_range)=interp1(alt,std_press,range(pos_range),'spline');
atm_temp(neg_range) = atm_temp(pos_range(1));
atm_press(neg_range) = atm_press(pos_range(1));