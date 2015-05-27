function R=REFRAC(temp,press,altitude);

% This procedure calculates refraction in degrees (Meeus chap. 15)
%  Calculates refaction to add to the computed solar altitude to get
%  apparent altitude. Temp in K, pressure in hPa. Max error 0.07 min of arc
%  =0.001° 
% Written 14.7.1995 by B. Schmid
% Changed 5.1.1996 by B. Schmid pressure and Temp may be arrays of the same
%                   length as altitude 

R=zeros(size(altitude));
i=find(altitude>=0.0);
R(i)= (1.02./tan((altitude(i)+10.3./(altitude(i)+5.11))/180*pi)+0.0019279)/60.0.*press(i)/1010*283./temp(i);

return

% R(i)= (1.02 ./ tan((altitude(i)+10.3./(altitude(i)+5.11))/180*pi) + 0.0019279) ./ 60 .* (press(i)./1010) .* (283./temp(i));
 
