function n=n_N2(lambda)
%calculates refractive index for N2
%Bates D. R., 1984: Rayleigh Scattering by Air, Planet. Space Sci., Vol. 32, No. 6, 785-790.
%input wavelength in microns.

n_minus1=5989.242+3363266.3 ./(144-(1./lambda.^2));

i=find (lambda<0.254);
n_minus1(i)=6998.749+3233582.0 ./(144-(1./lambda(i).^2));

i=find (lambda>0.468);
n_minus1=6855.200+3243157.0 ./(144-(1./lambda.^2));

n=1+n_minus1/1e8;
