function params = gen_sams_params(vis, nir)
%params = gen_sams_params(vis, nir)
% Accepts or loads paired SASZe vis and NIR files
% Computes Leblanc parameters useful for cloud retrievals and phase 

% Step one might be to stitch the VIS and NIR together.
% Not sure what value if any these parameters have for cloud-free case

%
Ln = sasnir.vdata.zenith_radiance;
Lv = sasvis.vdata.zenith_radiance;
L = glue_visnir(sasvis.vdata.wl, Lv, sasnir.vdata.wl, Ln);

wl_1 = interp1(nir.wl, [1:length(nir.wl)],1000,'nearest');
L1 = nir.vdata.
wl_1000_1100 = nir.wl >=1000 & nir.wl<=1100;

P = polyfit(nir.wl(wl_1000_1100)./1000, nir.zenrad(wl_1000_1100,:),1);
