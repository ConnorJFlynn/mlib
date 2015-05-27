
in_dir = ['D:\case_studies\radiation_cals\2013_11_20.NASA_ARC_SASZe1_cals\Use_these_as_postMagic_preclean_responsivities\'];
vis_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.si.5ms.dat']);
nir_resp_dirty = rd_SAS_resp([in_dir, 'sasze1.resp_func.201311210000.ir.200ms.dat']);
preclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.preclean_postMAG\Lamps_2\'];
postclean_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_predeploy\Lamps_2\'];
postclean2_dir = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_second_day\Lamps_2\'];

pname = ['D:\case_studies\radiation_cals\2013_12_21.SWS_SGP_Lab12.cals_and_filter_tests\sws_before_and_after\'];
sws_vis_resp = load([pname, 'sgpswsC1.resp_func.201303130000.si.40ms.dat']);
sws_nir_resp = load([pname, 'sgpswsC1.resp_func.201303130000.ir.40ms.dat']);

%%
cimel_cldrad = read_cimel_cloudrad;
%%
cimel_ppl_skyrad = aeronet_zenith_radiance;
%%
%Days to compare:
% Jan 23, ovc 18-19
% Feb 10, ovc 19-20
% Feb 16,  ovc 19-20

% Jan 24, clear 18-19
sws_rate = bundle_sws_raw_2;
sws_rate.Si_rad = sws_rate.Si_rate ./ (sws_vis_resp(:,2)*ones([1,size(sws_rate.Si_rate,2)]));
sws_rate.In_rad = sws_rate.In_rate ./ (sws_nir_resp(:,2)*ones([1,size(sws_rate.Si_rate,2)]));
save([sws_rate.pname,'sws_rate.mat'],'-struct','sws_rate');
% Compare SWS and SAS-ZE for several days after redeployment to see if the
% ratios stay more or less constant.
% Then either assume SWS is good and correct SAS-Ze against it,
% or assume Lab12 calibrated against dirty SAS-Ze was good, and calibrate
% both against that. Check each against Cimel and decide by consensus?
%
sas_vis = bundle_sas_raw; 
[sas_vis.rate, sas_vis.signal, sas_vis.mean_dark_time, sas_vis.mean_dark_spec] = sasze_raw_to_rate(sas_vis);
sas_vis_resp = vis_resp_dirty;
sas_vis.rad = sas_vis.rate ./ (ones([length(sas_vis.time),1])*sas_vis_resp.resp');
save([sas_vis.pname,'sas_vis.mat'],'-struct','sas_vis');
sas_nir = bundle_sas_raw; 
[sas_nir.rate, sas_nir.signal, sas_nir.mean_dark_time, sas_nir.mean_dark_spec] = sasze_raw_to_rate(sas_nir);
sas_nir_resp = nir_resp_dirty;
sas_nir.rad = sas_nir.rate ./ (ones([length(sas_nir.time),1])*sas_nir_resp.resp');
save([sas_nir.pname,'sas_nir.mat'],'-struct','sas_nir');
good_sws = find(sws_rate.shutter==0);
good_sas = find(sas_vis.Shutter_open_TF==1);
[ainb, bina] = nearest(sws_rate.time(good_sws),sas_vis.time(good_sas));
mean_time = mean(sws_rate.time(good_sws(ainb)));
mean_sws = mean(sws_rate.Si_rad(:,good_sws(ainb)),2);
mean_sws_ir = mean(sws_rate.In_rad(:,good_sws(ainb)),2);
mean_sas_vis = mean(sas_vis.rad(good_sas(bina),:)); 
mean_sas_vis_at_sws = interp1(sas_vis.lambda, mean_sas_vis,    sws_rate.Si_lambda,'linear'); 
mean_sas_nir = mean(sas_nir.rad(good_sas(bina),:)); 
mean_sas_nir_at_sws = interp1(sas_nir.lambda, mean_sas_nir,    sws_rate.In_lambda,'linear'); 

%%
%cimel_cldrad = read_cimel_cloudrad;
%cimel_ppl_skyrad = aeronet_zenith_radiance;

ppl_t = cimel_ppl_skyrad.time>sws_rate.time(1)&cimel_ppl_skyrad.time<sws_rate.time(end);
cld_t = cimel_cldrad.time>sws_rate.time(1) & cimel_cldrad.time<sws_rate.time(end);

if sum(ppl_t>0)
    figure; 
    plot(sws_rate.Si_lambda, mean_sws, 'b-',sws_rate.Si_lambda, 1e-3.*mean_sas_vis_at_sws, 'r-',...
    [440,500,670,870,1020,1640], 1e-3.*[cimel_ppl_skyrad.zen_rad_440_nm(ppl_t),...
    cimel_ppl_skyrad.zen_rad_500_nm(ppl_t),cimel_ppl_skyrad.zen_rad_670_nm(ppl_t),...
    cimel_ppl_skyrad.zen_rad_870_nm(ppl_t), cimel_ppl_skyrad.zen_rad_1020_nm(ppl_t),...
    cimel_ppl_skyrad.zen_rad_1640_nm(ppl_t)]','co',...
    sws_rate.In_lambda, mean_sws_ir, 'b-',sws_rate.In_lambda, 1e-3.*mean_sas_nir_at_sws, 'r-')
title(datestr(sws_rate.time(1),'mmm dd')); legend('SWS','SAS on SWS grid','Cimel PPL');
end
if sum(cld_t)>0
    plot(sws_rate.Si_lambda, mean_sws, 'b-',sws_rate.Si_lambda, 1e-3.*mean_sas_vis_at_sws, 'r-',...
    [440], 1e-3.*[cimel_cldrad.A440nm(cld_t)'],'co',...
    [440], 1e-3.*[cimel_cldrad.K440nm(cld_t)],'g.',...
    [870], 1e-3.*[cimel_cldrad.A870nm(cld_t)],'co',...
    [870], 1e-3.*[cimel_cldrad.K870nm(cld_t)],'g.',...
    sws_rate.In_lambda, mean_sws_ir, 'b-',sws_rate.In_lambda, 1e-3.*mean_sas_nir_at_sws, 'r-')
title(datestr(sws_rate.time(1),'mmm dd')); legend('SWS','SAS on SWS grid','Cimel Cld');
end
figure; ax(1) = subplot(2,1,1); plot(sws_rate.Si_lambda, mean_sws, '-',sws_rate.Si_lambda, 1e-3.*mean_sas_vis_at_sws, 'r-',...
    sws_rate.In_lambda, mean_sws_ir, '-',sws_rate.In_lambda, 1e-3.*mean_sas_nir_at_sws, 'r-');
title(datestr(sws_rate.time(1),'mmm dd')); legend('SWS','SAS on SWS grid');
ax(2) = subplot(2,1,2);
plot(sws_rate.Si_lambda, mean_sws./(1e-3.*mean_sas_vis_at_sws), 'k-',...
   sws_rate.In_lambda, mean_sws_ir./(1e-3.*mean_sas_nir_at_sws), 'r-' );
legend('SWS / SAS');
linkaxes(ax,'x');
zoom('on')

%%
% Jan 29, clear 18-19
% Feb 23, clear 16-17?
% Feb 26, clear 18-19