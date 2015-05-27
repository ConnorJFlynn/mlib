 function [n]=Polystyrene(lambda);
 %computes refractive index of Polysterene Microspeheres according to Duke
 %Scientific Corporation, Technical Note - 007B December 1, 1996.
 % input lambda in microns.
 % output refractive index n (imaginary part is 0, because material is non-absorbing)
 A=1.5663;
 B=0.00785;
 C=0.000334;
 
 n=A+B./(lambda.^2)+C./(lambda.^2);