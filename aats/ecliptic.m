function ecl_long=ecliptic(JD);

% This procedure calculates ecliptical longitude of the sun 
% Written 14.7.1995 by B. Schmid

ecl_long_1990 = 279.403303; %ecliptical longitude at epoch 1990.0 degrees
ecl_long_pg = 282.768422;   %ecliptical longitude of perigee     "   
eccentricity = 0.016713;    %eccentricity of orbit
days_since_1990=JD -2447891.5;
N= (360/365.242191*days_since_1990);
N=rem(N,360);
i=find(N<0);
N(i)=N(i)+360;  
mean_anomaly= N + ecl_long_1990 - ecl_long_pg;
i=find(mean_anomaly<0);
mean_anomaly(i)=mean_anomaly(i)+360;  
E= 360/pi*eccentricity*sin(mean_anomaly/180*pi);
ecl_long= N + E + ecl_long_1990;
ecl_long=rem(ecl_long,360);
i=find(ecl_long<0);
ecl_long(i)=ecl_long(i)+360;

