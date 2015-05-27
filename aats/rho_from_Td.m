function [rho]=rho_from_Td(Td,T,p);
%This computes absolute humidity rho in g/m3 from Dewpoint, Td, Temperature, T, 
%both in C and pressure in mb or hPa.
%Boegel, 1977 p. 109

b=(8.082-Td/556).*Td./(256.1+Td);
a=1323.3*(1+1e-8.*p.*(570-T))./(T+273.15);
rho=a.*10.^b;