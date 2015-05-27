% test BRDF parameters in AERONET inversion input files 
% info from here: http://www.umb.edu/spectralmass/terra_aqua_modis/v006/mcd43a1_brdif_albedo_model_parameters_product
% also described here: http://harvardforest.fas.harvard.edu/sites/harvardforest.fas.harvard.edu/files/publications/pdfs/Roman_RemoteSensEnviron_2009.pdf

% Black sky
g0_iso = 1;
g0_vol = -0.007574;
g0_geo = -1.284909;
g1_iso = 0;
g1_vol = -0.070987;
g1_geo = -0.166314;
g2_iso = 0;
g2_vol = 0.307588;
g2_geo =   0.041840;

f = [0.3    0    0];
f_iso = f(1); f_vol = f(2); f_geo = f(3);

SZA = 45;
SZA = SZA.*pi/180;
bsa = f_iso.*(g0_iso + g1_iso.*SZA.^2 + g2_iso.*SZA.^3) + f_vol.*(g0_vol + g1_vol.*SZA.^2 + g2_vol.*SZA.^3)...
    + f_geo.*(g0_geo + g1_geo.*SZA.^2 + g2_geo.*SZA.^3);
bsa = f_iso.*(g0_iso) + f_vol.*(g0_vol + g1_vol.*SZA.^2 + g2_vol.*SZA.^3) + f_geo.*(g0_geo + g1_geo.*SZA.^2 + g2_geo.*SZA.^3);
% white sky
g_iso = 1; g_vol =  0.189184; g_geo = -1.377622;

wsa = f_iso .* g_iso + f_vol .* g_vol + f_geo .* g_geo;