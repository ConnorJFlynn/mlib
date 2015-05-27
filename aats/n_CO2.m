function n=n_air(lambda)
%calculates refractive index for CO2 (T=15C P=1013.25)
%Bodhaine,1999 Eq 27 which is from Owens(1967)
%input wavelength in microns.

n_minus1=22822.1+117.8./lambda.^2+2406030./(130-(1./lambda.^2))+15997./(38.9-(1./lambda.^2));

n=1+n_minus1/1e8;
