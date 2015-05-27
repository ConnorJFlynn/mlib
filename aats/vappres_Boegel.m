function ew = vappres(T);
%  Calculates water vapor vapor pressure using the Van Goff-Gratch Formula
%  (Boegel p 34).
%  T in Kelvin
Tt=273.16; % Triple point of water
log_ew=10.79574.*(1-Tt./T)-5.028.*log10(T/Tt)+1.50475e-4.*(1-10.^(-8.2969.*(T/Tt-1)))+0.42873*1e-3.*(10.^(4.76955.*(1-Tt./T))-1)+0.78614;
ew=10.^log_ew;
return
