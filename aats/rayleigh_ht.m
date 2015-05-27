function tau_r=rayleigh(lambda,press)
%Computes Rayleigh Scattering according to Hansen and Ttavis, 1974 Space Sci. rev. 527-610
%lambda has to be in microns, pressure in hPa

A=0.008569;
B=0.0113;
C=0.00013;
tau_r=A*lambda.^-4.*(1+B*lambda.^-2+C*lambda.^-4);
tau_r=(press/1013.25*tau_r')';



