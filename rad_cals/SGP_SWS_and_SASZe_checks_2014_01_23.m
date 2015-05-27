%%

%Load existing responsivity files
% Apply to some raw SWS data
% Check against netcdf file for consistency

in_dir = ['D:\case_studies\radiation_cals\2013_11_20.NASA_ARC_SASZe1_cals\Use_these_as_postMagic_preclean_responsivities\'];
vis_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.si.5ms.dat']);
nir_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.ir.200ms.dat']);
preclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.preclean_postMAG\Lamps_2\'];
postclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_predeploy\Lamps_2\'];
postclean2_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_second_day\Lamps_2\'];
%
pname = ['D:\case_studies\radiation_cals\2013_12_21.SWS_SGP_Lab12.cals_and_filter_tests\sws_before_and_after\'];
sws_vis_resp = load([pname, 'sgpswsC1.resp_func.201303130000.si.40ms.dat']);
sws_nir_resp = load([pname, 'sgpswsC1.resp_func.201303130000.ir.40ms.dat']);
sws_rate = bundle_sws_raw_2;
sws_rate.Si_rad = sws_rate.Si_rate ./ (sws_vis_resp(:,2)*ones([1,size(sws_rate.Si_rate,2)]));
sws_rate.In_rad = sws_rate.In_rate ./ (sws_nir_resp(:,2)*ones([1,size(sws_rate.Si_rate,2)]));
figure; plot(sws_rate.Si_lambda, sws_rate.Si_rad(:,1111),'-',sws_rate.In_lambda, sws_rate.In_rad(:,1111),'-');
%These match up OK
sws_nc = ancload(getfullname_([pname, 'sgpsws*.cdf']));
sws_ii = interp1(sws_nc.time, [1:length(sws_nc.time)], sws_rate.time(1111),'nearest');
plot(sws_rate.Si_lambda, sws_rate.Si_rad(:,1111),'-',sws_rate.In_lambda, sws_rate.In_rad(:,1111),'-', ...
    sws_nc.vars.wavelength.data, sws_nc.vars.zen_spec_calib.data(:,sws_ii),'k-');
% These match as well.  So the SWS radiances are beign computed properly
% and the Si and InGaAs responses match up well.

sas_vis = bundle_sas_raw; 
[sas_vis.rate, sas_vis.signal, sas_vis.mean_dark_time, sas_vis.mean_dark_spec] = sasze_raw_to_rate(sas_vis);
sas_vis_resp = rd_SAS_resp;
sas_vis.rad = sas_vis.rate ./ (ones([length(sas_vis.time),1])*sas_vis_resp.resp');

sas_nir = bundle_sas_raw; 
[sas_nir.rate, sas_nir.signal, sas_nir.mean_dark_time, sas_nir.mean_dark_spec] = sasze_raw_to_rate(sas_nir);
sas_nir_resp = rd_SAS_resp;
sas_nir.rad = sas_nir.rate ./ (ones([length(sas_nir.time),1])*sas_nir_resp.resp');

sas_vis_ii  = interp1(sas_vis.time, [1:length(sas_vis.time)], sws_rate.time(1111),'nearest');
sas_nir_ii  = interp1(sas_nir.time, [1:length(sas_nir.time)], sws_rate.time(1111),'nearest');

   lambdair = [  2206.58 -4.48404 -3.19203e-4 -9.1953e-6 0 ];% new sws NIR spec
   inds = [0:255];sdni = fliplr(inds);
   sws_raw.In_lambda = lambdair(1) + lambdair(2).*sdni + lambdair(3).*sdni.^2 + lambdair(4).*sdni.^3 + lambdair(5).*sdni.^4;
   sws_rate.In_lambda = sws_raw.In_lambda;
   
figure;
plot(sws_rate.Si_lambda, sws_rate.Si_rad(:,1111),'b-',sws_rate.In_lambda, sws_rate.In_rad(:,1111),'b-', ...
    sas_vis.lambda, 1e-3.*sas_vis.rad(sas_vis_ii,:),'r-',sas_nir.lambda, 1e-3.*sas_nir.rad(sas_nir_ii,:),'r-');

% Okay, so we've got rough agreement between SWS Vis and NIR, and rough
% agreement between SASZe Vis and NIR, but about a 20% disagreement between
% the two based on the "dirty" pre-clean responsivities at NASA Ames.

% Now, look at the differences between pre-clean and post-clean at SGP with
% LAB12

in_dir = ['D:\case_studies\radiation_cals\2013_11_20.NASA_ARC_SASZe1_cals\Use_these_as_postMagic_preclean_responsivities\'];
vis_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.si.5ms.dat']);
nir_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.ir.200ms.dat']);
preclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.preclean_postMAG\Lamps_2\'];
postclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_predeploy\Lamps_2\'];
postclean2_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_second_day\Lamps_2\'];
% For starters, we'll simply read the file with the closest integration
% times, even though these may not be  optimal given vastly different lamp
% intensities.
% [rate, signal, mean_dark_time, mean_dark_spec] = sasze_raw_to_rate(ze)
vis_preclean = bundle_sas_raw(getfullname_([preclean_dir,'*_vis_1s*.csv'],'preclean','Select preclean files.'));
vis_postclean = bundle_sas_raw(getfullname_([postclean_dir,'*_vis_1s*.csv'],'postclean','Select postclean files.'));
vis_postclean2 = bundle_sas_raw(getfullname_([postclean2_dir,'*_vis_1s*.csv'],'postclean2','Select postclean files.'));

nir_preclean = bundle_sas_raw(getfullname_([preclean_dir,'*_nir_1s*.csv'],'preclean','Select preclean files.'));
nir_postclean = bundle_sas_raw(getfullname_([postclean_dir,'*_nir_1s*.csv'],'postclean','Select postclean files.'));
nir_postclean2 = bundle_sas_raw(getfullname_([postclean2_dir,'*_nir_1s*.csv'],'postclean2','Select postclean files.'));

[vis_preclean.rate, vis_preclean.signal, vis_preclean.mean_dark_time, vis_preclean.mean_dark_spec] = sasze_raw_to_rate(vis_preclean);
[vis_postclean.rate, vis_postclean.signal, vis_postclean.mean_dark_time, vis_postclean.mean_dark_spec] = sasze_raw_to_rate(vis_postclean);
[vis_postclean2.rate, vis_postclean2.signal, vis_postclean2.mean_dark_time, vis_postclean2.mean_dark_spec] = sasze_raw_to_rate(vis_postclean2);
[nir_preclean.rate, nir_preclean.signal, nir_preclean.mean_dark_time, nir_preclean.mean_dark_spec] = sasze_raw_to_rate(nir_preclean);
[nir_postclean.rate, nir_postclean.signal, nir_postclean.mean_dark_time, nir_postclean.mean_dark_spec] = sasze_raw_to_rate(nir_postclean);
[nir_postclean2.rate, nir_postclean2.signal, nir_postclean2.mean_dark_time, nir_postclean2.mean_dark_spec] = sasze_raw_to_rate(nir_postclean2);

pre_good_vis = vis_preclean.Shutter_open_TF==1&vis_preclean.t_int_ms<20&vis_preclean.t_int_ms>4;
post1_good_vis = vis_postclean.Shutter_open_TF==1&vis_postclean.t_int_ms<20&vis_postclean.t_int_ms>4;
post2_good_vis = vis_postclean2.Shutter_open_TF==1&vis_postclean2.t_int_ms<20&vis_postclean2.t_int_ms>4;

pre_good_nir = nir_preclean.Shutter_open_TF==1&nir_preclean.t_int_ms<250&nir_preclean.t_int_ms>60;
post1_good_nir = nir_postclean.Shutter_open_TF==1&nir_postclean.t_int_ms<250&nir_postclean.t_int_ms>60;
post2_good_nir = nir_postclean2.Shutter_open_TF==1&nir_postclean2.t_int_ms<350&nir_postclean2.t_int_ms>60;


vis_cleaner1 =mean(vis_postclean.rate(post1_good_vis,:))./ mean(vis_preclean.rate(pre_good_vis,:));
vis_cleaner2 =mean(vis_postclean2.rate(post2_good_vis,:))./ mean(vis_preclean.rate(pre_good_vis,:));
nir_cleaner1 =mean(nir_postclean.rate(post1_good_nir,:))./ mean(nir_preclean.rate(pre_good_nir,:));
nir_cleaner2 =mean(nir_postclean2.rate(post2_good_nir,:))./ mean(nir_preclean.rate(pre_good_nir,:));

vis_later = mean(vis_postclean2.rate(post2_good_vis,:))./mean(vis_postclean.rate(post1_good_vis,:));
nir_later = mean(nir_postclean2.rate(post2_good_nir,:))./mean(nir_postclean.rate(post1_good_nir,:));

figure; plot(nir_preclean.lambda, nir_cleaner1, 'r-',nir_preclean.lambda, nir_cleaner2, 'g-',...
    nir_preclean.lambda, nir_later,'b-'); 
legend('cleaner 1','cleaner 2', 'clean2 / clean1')

 
 figure; plot(vis_preclean.lambda, vis_cleaner1, 'r-',vis_preclean.lambda, vis_cleaner2, 'g-',...
    vis_preclean.lambda, vis_later,'b-'); 
legend('cleaner 1','cleaner 2', 'clean2 / clean1')
 xlim([400,900]);
 

figure; plot(serial2doy(vis_preclean.time), vis_preclean.T_avantes_AD_C,'bx',...
    serial2doy(vis_postclean.time), vis_postclean.T_avantes_AD_C,'b+',...
    serial2doy(vis_postclean2.time), vis_postclean2.T_avantes_AD_C,'bo',...
    serial2doy(nir_preclean.time), nir_preclean.T_avantes_AD_C,'rx',...
    serial2doy(nir_postclean.time), nir_postclean.T_avantes_AD_C,'r+',...
    serial2doy(nir_postclean2.time), nir_postclean2.T_avantes_AD_C,'ro')

figure; plot(serial2doy(vis_preclean.time), vis_preclean.T_avantes_bench_C,'bx',...
    serial2doy(vis_postclean.time), vis_postclean.T_avantes_bench_C,'b+',...
    serial2doy(vis_postclean2.time), vis_postclean2.T_avantes_bench_C,'bo',...
    serial2doy(nir_preclean.time), nir_preclean.T_avantes_bench_C,'rx',...
    serial2doy(nir_postclean.time), nir_postclean.T_avantes_bench_C,'r+',...
    serial2doy(nir_postclean2.time), nir_postclean2.T_avantes_bench_C,'ro',...
    serial2doy(sas_vis.time), sas_vis.T_avantes_bench_C, 'k.')
%%
% cloudy
sws_nc_cloud = ancload(getfullname_([pname, 'sgpsws*.cdf']));
