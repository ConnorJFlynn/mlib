%compute King depolarization factor for air. 
% According to Bodhaine B.A., N.B. Wood, E.G. Dutton, J.R. Slusser. On Rayleigh Optical Depth Calculations. J. Atmos. Oceanic Tech. Vol 16, 1854-1861, 1999.
% see also  Bates D. R., 1984: Rayleigh Scattering by Air, Planet. Space Sci., Vol. 32, No. 6, 785-790. 
% input lambda in microns
% input CO2 in parts per volume by percent (e.g. use 0.036 for 360 ppm)

function [F]=F_air(lambda,C_CO2);

F=(78.084.*F_N2(lambda)+20.946.*F_O2(lambda)+0.934*1+C_CO2*1.15)/(78.084+20.946+0.934+C_CO2);

