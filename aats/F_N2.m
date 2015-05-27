%compute King depolarization factor for N2. According to Bates D. R., 1984: Rayleigh Scattering by Air, Planet. Space Sci., Vol. 32, No. 6, 785-790.
% see also Bodhaine B.A., N.B. Wood, E.G. Dutton, J.R. Slusser. On Rayleigh Optical Depth Calculations. J. Atmos. Oceanic Tech. Vol 16, 1854-1861, 1999.
% input lambda in microns

function [F]=F_N2(lambda);

F=1.034+3.17e-4./lambda.^2;


