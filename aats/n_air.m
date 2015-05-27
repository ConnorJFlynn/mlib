function n=n_air(lambda)
%calculates refractive index for standard air (T=15C)
%Bucholz, 1995 Eqs 4-5
%input wavelength in microns.

n_minus1=5791817./(238.0185-(1./lambda.^2))+167909./(57.362-(1./lambda.^2));

i=find (lambda<0.230);
n_minus1(i)=8060.51+2480990./(132.2745-(1./lambda(i).^2))+17455.7./(39.32957-(1./lambda(i).^2));

n=1+n_minus1/1e8;
