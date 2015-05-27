function y=planck_in_wl(lambda,T)
% y=planck_in_wl(lambda,T)
% lambda has to be in meters, T in Kelvin
%  (mW/m2/ster/cm)
h = 6.6260755e-34;
cc = 2.99792458e8;
k = 1.380658e-23;
%numer = 2*pi*h*(cc.^2);
numer = 2*h*(cc.^2);
exp_coef = h*cc./k;

lambda = lambda*100;%Converting from meters to cm.
c1 = 1.1910427e-5; % (mW/m2/ster/cm-4)
% c1 = 1.191044 x 10-5 (mW/m2/ster/cm-4)
% c1 = 2hc2 = 1.191044 x 10-8 W/(m2*ster*cm-4)
c2 = 1.4387752; %[K.cm]
%These units are drawn from Tim Schmit powerpoint

y = c1./((lambda.^5).*(exp(c2./(lambda.*T))-1));
% These numbers agree % with Tim Schmit, NOAA but disagree with the AATS function 
% to a factor of pi

% c1 = 2*pi*h*(cc.^2);
% % 2*pi*h*cc
% 
% c1=3.741884e4
% c2=1.438769*1e4
% x=c2./lambda/T;
% 
% y=c1./lambda.^5./(exp(x)-1);

return

