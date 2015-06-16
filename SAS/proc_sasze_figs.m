%%
ze_vis = rd_raw_SAS(getfullname('SASZe_*_vis*.csv','sasze'));
ze_nir = rd_raw_SAS(getfullname('SASZe_*_nir*.csv','sasze'));
%%
plots_default
vis_nm = ze_vis.lambda>340 & ze_vis.lambda<1020;
nir_nm = ze_nir.lambda>920 & ze_nir.lambda<1700;

vis_dark = mean(ze_vis.spec(ze_vis.Shutter_open_TF==0,:));
nir_dark = mean(ze_nir.spec(ze_nir.Shutter_open_TF==0,:));
not_shut = ze_vis.Shutter_open_TF==1;
figure; lines = plot(ze_vis.lambda(vis_nm),ze_vis.spec(not_shut,vis_nm)-ones([sum(not_shut),1])*vis_dark(vis_nm),'-',...
   ze_nir.lambda(nir_nm),ze_nir.spec(not_shut,nir_nm)-ones([sum(not_shut),1])*nir_dark(nir_nm),'-');
lines = recolor(lines, [[1:sum(not_shut)],[1:sum(not_shut)]]);
xlabel('wavelength [nm]')
ylabel('dark-subtracted raw cts')
title('SGP SAS-Ze raw zenith cts')