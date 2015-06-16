% figures for Kassianov SASHe paper
% D:\SASHe_Ze\Kassianov data paper\Fig3_HyperAOD
pvc_vis_Io = anc_load(getfullname('*.cdf','pvcsashe'));
pvc_nir_Io = anc_load(getfullname('*.cdf','pvcsashe'));
pvc_vis_lang = anc_load(getfullname('*.cdf','pvcsashe'));
pvc_nir_lang = anc_load(getfullname('*.cdf','pvcsashe'));
figure; plot(pvc_vis_Io.vdata.wavelength, pvc_vis_Io.vdata.smoothed_Io_values,'.')
%figure; semilogy(pvc_vis_lang.vdata.airmass, pvc_vis_lang.vdata.direct_normal_irradiance

imagesc(serial2hs(pvc_vis_Io.time), pvc_vis_Io.vdata.wavelength, pvc_vis_Io.vdata.qc_aerosol_optical_depth>0);
axis('xy');

qc_imp = anc_qc_impacts(pvc_vis_Io.vdata.qc_aerosol_optical_depth, pvc_vis_Io.vatts.qc_aerosol_optical_depth);
qc_time = serial2hs(pvc_vis_Io.time)>18 &serial2hs(pvc_vis_Io.time)<19;
qc_nm = pvc_vis_Io.vdata.wavelength>400 & pvc_vis_Io.vdata.wavelength<1020;
% qc_good = qc_good & (ones(size(qc_good,1),1)*double(qc_time))==1;
[aod_1, aod_2] = mean_mask_2dim(pvc_vis_Io.vdata.aerosol_optical_depth,qc_time, qc_imp==0, qc_nm);

size(pvc_vis_Io.vdata.qc_aerosol_optical_depth>0)
good = pvc_vis_Io.vdata.qc_aerosol_optical_depth>0 .* ...
(ones([1315,1])*(serial2hs(pvc_vis_Io_time)>18)&(serial2hs(pvc_vis_Io_time)<19));
good = pvc_vis_Io.vdata.qc_aerosol_optical_depth>0 .* ...
(ones([1315,1])*(serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19));
size((serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19)))
size((serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19))
size((ones([1315,1])*(serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19)))
size((ones([1315,1])*((serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19))))
good = pvc_vis_Io.vdata.qc_aerosol_optical_depth>0 .* ...
(ones([1315,1])*((serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19)));
clear_sky_aod = pvc_vis_Io.vdata.aerosol_optical_depth(:,(serial2hs(pvc_vis_Io.time)>18)&serial2hs(pvc_vis_Io.time)<19));
clear_sky_aod = pvc_vis_Io.vdata.aerosol_optical_depth(:,(serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19));
size(mean(clear_sky_aod))
size(mean(clear_sky_aod,2))
figure; plot(pvc_vis_Io.vdata.wavelength, mean(clear_sky_aod,2)),'.')
figure; plot(pvc_vis_Io.vdata.wavelength, mean(clear_sky_aod,2),'.')
logy
pvc_vis_Io = anc_load(getfullname('*.cdf','pvcsashe'));
clear_sky_aod = pvc_vis_Io.vdata.aerosol_optical_depth(:,(serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19));
figure; plot(pvc_vis_Io.vdata.wavelength, mean(clear_sky_aod,2),'.'); logy
liny
logy
NaN * 0
good = pvc_vis_Io.vdata.qc_aerosol_optical_depth==0.* ...
(ones(size(pvc_vis_Io.vdata.wavelength))*((serial2hs(pvc_vis_Io.time)>18)&(serial2hs(pvc_vis_Io.time)<19)));
good(~good) = NaN;