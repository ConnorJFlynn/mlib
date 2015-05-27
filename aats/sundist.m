function sun_factor=SunDist(day,month,year);
%Paltridge and Platt, Radiative Processes in Climatology,1979 }
%See Bird, R. E. and C. Riordan, 1986: Simple Solar Spectral Model for Direct and Diffuse
%Irradiance on Horizontal and Tilted Planes at the Earth's Surface for Cloudless Atmospheres.
%J. Climate Appl. Meteorol., Vol. 25, 87-97.
%Written 14.7.1995 by B. Schmid

 angle=2*pi*(dayofyear(day,month,year)-1)/365;
 sun_factor=1.00011+0.034221*cos(angle)+0.00128*sin(angle) ...
             +0.000719*cos(2*angle)+0.000077*sin(2*angle);


