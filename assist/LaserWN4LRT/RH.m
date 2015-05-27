function [wv,rh]=RH(wv,temp,pres);
%
% dim of input temp,wv: [nprofs x nlevs]
%
%   temp...temperature in K
%    wv....water vapor mixing ratio [g/kg]
%
% output: 
%   wv ....wv corrected for saturation (if mr > dsat, mr=dsat)
%   rh....relative humidity in %
%
% local:
%   esat...saturation vapor pressure [mbar]
%   dsat...saturation mixing ratio [g/kg]
%----------------------------------------------------

%
rh=0;
clear mr dsat
   mr=wv;
   esat=0;

     t=temp;
     if t > 253
       esat=svpwat(t);   %saturation vapor pressure [mbar]
    else
      esat=svpice(t);
    end
    clear t
    
   dsat=(621.946*(esat./pres));
   wv(find(mr > dsat)) = dsat(find(mr >dsat));
 %
%    rh=(wv./esat)*100;
    rh=(wv./dsat)*100;
    clear mr dsat esat

%fprintf('Oversaturation Check finished\n');
%----------------------------------------------------
%
function s=svpwat(temp)

% routine to compute saturation vapor pressure over water
% input:  temp in Kelvin or Celsius
%  
%
% matlab version of Hal Woolf's fortran code 'svpwat.f'
%


tref=273.16;

a0=.999996876d0;
a1=-0.9082695004d-2;
a2=0.7873616869d-4;
a3=-0.6111795727d-6;
a4=0.4388418740d-8;
a5=-0.2988388486d-10;
a6=0.2187442495d-12;
a7=-0.1789232111d-14;
a8=0.1111201803d-16;
a9=-0.3099457145d-19;
b=0.61078d+1;



    t = temp;
   if(t > 100.)
    t = t - tref;
   end
	s=a0+t*(a1+t*(a2+t*(a3+t*(a4+t*(a5+t*(a6+t*(a7+t*(a8+t*a9))))))));
	s=b/s^8;
function s=svpice(temp)

% routine to compute saturation vapor pressure over ice
% Goff/Gratch formula
%
% input:  temp in Kelvin or Celsius
%  
%
% matlab version of Hal Woolf's fortran code 'svpice.f'
%


   tref=273.16;

   t = temp;
	if(t < 100.)
    t = t + tref;
   end

   targ = tref/t;
	vlog = -9.09718*(targ - 1.0) - 3.56654*log10(targ)+ 0.876793*(1.0 - t/tref) + 0.7858350;
	s = 10.^vlog;
