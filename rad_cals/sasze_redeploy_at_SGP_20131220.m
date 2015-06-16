function sasze_redeploy_at_SGP_20131220
% Redeployment of SASZe1 to SGP after Magic.
% Due to time constraints, I was only able to obtain a post-magic pre-clean
% calibration at NASA Ames on Nov 21, 2013.
% Now I'll transfer that calibration to the Labsphere 12" sphere at SGP.
% Then clean the SAS-Ze and calibration again to get an SGP pre-deployment
% calibration. The dirty calibration looks about 20% lower in the VIS and
% only 2% lower in the NIR compared to clean calibration on May 5, 2013.

% Now we'll look at the dirty/clean comparison with Lab12...
% Have to be careful here becuase there are really two different
% post-clean measurements: one in the outer room and another the next day
% in the darkened room - possibly at a different detector temperature.

in_dir = ['D:\case_studies\radiation_cals\2013_11_20.NASA_ARC_SASZe1_cals\Use_these_as_postMagic_preclean_responsivities\'];
vis_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.si.5ms.dat']);
nir_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.ir.200ms.dat']);
preclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.preclean_postMAG\Lamps_2\'];
postclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_predeploy\Lamps_2\'];
% For starters, we'll simply read the file with the closest integration
% times, even though these may not be  optimal given vastly different lamp
% intensities.
% [rate, signal, mean_dark_time, mean_dark_spec] = sasze_raw_to_rate(ze)
vis_preclean = bundle_sas_raw(getfullname([preclean_dir,'*.csv']));
[vis_preclean.rate, vis_preclean.signal, vis_preclean.mean_dark_time, vis_preclean.mean_dark_spec] = sasze_raw_to_rate(vis_preclean);

vis_postclean = rd_raw_SAS([postclean_dir,'']);
[vis_postclean.rate, vis_postclean.signal, vis_postclean.light, vis_postclean.dark] = sasze_raw_to_rate(vis_postclean);







return
%% 