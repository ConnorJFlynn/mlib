function tau_r=rayleigh(lambda,press,idx_model_atm)

%function tau_r=rayleigh(lambda,press,idx_model_atm)
%Computes Rayleigh Scattering according to Bucholtz A., 1995: Appl. Optics., Vol. 34, No. 15 2765-2773
%lambda has to be in microns, pressure in hPa
%
% idx_model_atm:
% -------------
% 1=Tropical
% 2=Midlat Summer
% 3=Midlat Winter
% 4=Subarc Summer
% 5=Subarc Winter
% 6=1962 U.S. Stand Atm

 %Bucholz(95) Table 5 constants
  Coeff_model_atmo(1, 1) = .00652965;
  Coeff_model_atmo(1, 2) = .00868094;
  Coeff_model_atmo(2, 1) = .00651949;
  Coeff_model_atmo(2, 2) = .00866735;
  Coeff_model_atmo(3, 1) = .00653602;
  Coeff_model_atmo(3, 2) = .00868941;
  Coeff_model_atmo(4, 1) = .00648153;
  Coeff_model_atmo(4, 2) = .00861695;
  Coeff_model_atmo(5, 1) = .00649997;
  Coeff_model_atmo(5, 2) = .00864145;
  Coeff_model_atmo(6, 1) = .00650362;
  Coeff_model_atmo(6, 2) = .00864627;

A=Coeff_model_atmo(idx_model_atm,1);
B=3.55212;
C=1.35579;
D=0.11563;

tau_r=A./lambda.^(B+C*lambda+D./lambda);

i=find (lambda>0.500);
A=Coeff_model_atmo(idx_model_atm,2);
B=3.99668;
C=1.10298e-3;
D=2.71393e-2;

tau_r(i)=A./lambda(i).^(B+C*lambda(i)+D./lambda(i));

tau_r=(press/1013.25*tau_r')';


