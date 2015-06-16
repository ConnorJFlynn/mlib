function [old,new] = abe_review(old);
%%
if ~exist('new','var')
   old = ancload(getfullname('*.cdf','abe_old','Select original (old) file.'));
end
%%

vars = fieldnames(old.vars);

%Plotting notes...
% Plot all Angstrom fields leading to be_angstrom_exponent
% On linked axis, plot all AOD fields leading to be values.
%%
figure; ang(1) = subplot(2,1,1);
plot(serial2doy(old.time), old.vars.be_angstrom_exponent.data, 'o');
title('Angstrom exponent');
legend('be angstrom exponent')
ang(2) = subplot(2,1,2);
plot(serial2doy(old.time), old.vars.source_be_angstrom_exponent.data, 'o');
legend('source flag')
linkaxes(ang,'x')
%%

figure; ax(1) = subplot(2,1,1);
plot(serial2doy(old.time), ...
   [old.vars.mean_aod_mfrsr_filter1.data;old.vars.mean_aod_nimfr_filter1.data], 'x', ...
serial2doy(old.time), ...
   [old.vars.mean_aod_mfrsr_filter2.data;old.vars.mean_aod_nimfr_filter2.data], 'o', ...
   serial2doy(old.time), ...
   [old.vars.mean_aod_mfrsr_filter5.data;old.vars.mean_aod_nimfr_filter5.data], '+');
legend('mfrsr 1','nimfr 1','mfrsr 2','nimfr 2','mfrsr 5','nimfr 5');
title('mean aod');
ylim([0,.2]);
ax(2) = subplot(2,1,2);
plot(serial2doy(old.time), old.vars.be_angstrom_exponent.data, '+', ...
   serial2doy(old.time), [old.vars.mean_angstrom_exponent_nimfr.data;...
   old.vars.mean_angstrom_exponent_mfrsr.data], 'o',...
   serial2doy(old.time), [old.vars.interpolated_angstrom_exponent_nimfr.data;...
   ;old.vars.interpolated_angstrom_exponent_mfrsr.data;...
   old.vars.angstrom_exponent_mfr.data],'-x',...
   serial2doy(old.time), old.vars.angstrom_exponent_rl_filled.data,'k.',...
   serial2doy(old.time), old.vars.angstrom_exponent_AIP.data,'g*');

lg = legend('be','nimfr','mfrsr','nimfr_interp','mfrsr_interp','xmfrx','rl_filled','aip');
set(lg,'interp','none');
ylim([0,3])
linkaxes(ax,'x');
%%
% Look at extinction profiles, what is "extinction_profile_clim"
figure; ss(1) = subplot(2,1,1);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.extinction_profile.data);axis('xy'); colorbar; 
title('best-estimate extinction profile');


ss(2) = subplot(2,1,2);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.extinction_profile_clim.data);axis('xy'); colorbar; 
title('extinction_profile_clim');
linkaxes(ss,'x')
%%
figure; ss(1) = subplot(2,1,1);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.rh.data);axis('xy'); colorbar; 
title('rh');

ss(2) = subplot(2,1,2);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.ratio_Bbs_B_1um.data./old.vars.ratio_Bs_B_1um.data);axis('xy'); colorbar; 
tl = title('ratio_Bbs_B_1um'); set(tl,'interp','none');
caxis([0,2])
linkaxes(ss,'x')


%%
figure; ss(1) = subplot(4,1,1);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.rh.data);axis('xy'); colorbar; 
title('rh');

ss(2) = subplot(4,1,2);
imagegap(serial2doy(old.time), old.vars.height.data, old.vars.ratio_Bs_B_1um.data);axis('xy'); colorbar; 
tl = title('ratio_Bs_B_1um'); set(tl,'interp','none');
caxis([0.8,3])
ss(3) = subplot(4,1,3);
imagegap(serial2doy(old.time), old.vars.height.data, real((old.vars.BluTscat_humidified.data)));axis('xy'); colorbar; 
tl = title('BluTscat_humidified'); set(tl,'interp','none');
caxis([0,.15]);
ss(4) = subplot(4,1,4);
plot(serial2doy(old.time), old.vars.total_scatter_coefficient_blue.data,'.')

linkaxes(ss,'x')


%%

% Look at vertical profiles of rh, time series of frh fits, and corresponding vertical profiles of ratios  

% 80  'angstrom_exponent_rl'
% 81  'angstrom_exponent_mfr'
% 82  'angstrom_exponent_rl_filled' 

%%
return

%  1  'base_time'
%  2  'time_offset'
%  3  'time'
%  4  'be_aod_500'
%  5  'source_be_aod_500'
%  6  'be_aod_355'
%  7  'source_be_aod_355'
%  8  'be_angstrom_exponent'
%  9  'source_be_angstrom_exponent'
% 10  'height'
% 11   'extinction_profile'
% 12   'single_scattering_albedo_red'
% 13   'single_scattering_albedo_green'
% 14   'single_scattering_albedo_blue'
% 15   'asymmetry_parameter_red'
% 16   'asymmetry_parameter_green'
% 17   'asymmetry_parameter_blue'
% 18   'bsf_R_Dry_1um'
% 19   'bsf_G_Dry_1um'
% 20   'bsf_B_Dry_1um'
% 21  'total_scatter_coefficient_red'
% 22  'source_total_scatter_coefficient_red'
% 23  'total_scatter_coefficient_green'
% 24  'source_total_scatter_coefficient_green'
% 25  'total_scatter_coefficient_blue'
% 26  'source_total_scatter_coefficient_blue'
% 27  'backscatter_coefficient_red'
% 28  'source_backscatter_coefficient_red'
% 29  'backscatter_coefficient_green'
% 30  'source_backscatter_coefficient_green'
% 31  'backscatter_coefficient_blue'
% 32  'source_backscatter_coefficient_blue'
% 33  'absorption_coefficient_mean_red'
% 34  'source_absorption_coefficient_mean_red'
% 35  'absorption_coefficient_mean_green'
% 36  'source_absorption_coefficient_mean_green'
% 37  'absorption_coefficient_mean_blue'
% 38  'source_absorption_coefficient_mean_blue'
% 39  'rh'
% 40  'source_rh'
% 41  'mean_aod_nimfr_filter1'
% 42  'qc_mean_aod_nimfr_filter1'
% 43  'sdev_aod_nimfr_filter1'
% 44  'mean_aod_nimfr_filter2'
% 45  'qc_mean_aod_nimfr_filter2'
% 46  'sdev_aod_nimfr_filter2'
% 47  'mean_aod_nimfr_filter3'
% 48  'qc_mean_aod_nimfr_filter3'
% 49  'sdev_aod_nimfr_filter3'
% 50  'mean_aod_nimfr_filter4'
% 51  'qc_mean_aod_nimfr_filter4'
% 52  'sdev_aod_nimfr_filter4'
% 53  'mean_aod_nimfr_filter5'
% 54  'qc_mean_aod_nimfr_filter5'
% 55  'sdev_aod_nimfr_filter5'
% 56  'mean_angstrom_exponent_nimfr'
% 57  'qc_mean_angstrom_exponent_nimfr'
% 58  'interpolated_angstrom_exponent_nimfr'
% 59  'mean_aod_mfrsr_filter1'
% 60  'qc_mean_aod_mfrsr_filter1'
% 61  'sdev_aod_mfrsr_filter1'
% 62  'mean_aod_mfrsr_filter2'
% 63  'qc_mean_aod_mfrsr_filter2'
% 64  'sdev_aod_mfrsr_filter2'
% 65  'mean_aod_mfrsr_filter3'
% 66  'qc_mean_aod_mfrsr_filter3'
% 67  'sdev_aod_mfrsr_filter3'
% 68  'mean_aod_mfrsr_filter4'
% 69  'qc_mean_aod_mfrsr_filter4'
% 70  'sdev_aod_mfrsr_filter4'
% 71  'mean_aod_mfrsr_filter5'
% 72  'qc_mean_aod_mfrsr_filter5'
% 73  'sdev_aod_mfrsr_filter5'
% 74  'mean_angstrom_exponent_mfrsr'
% 75  'qc_mean_angstrom_exponent_mfrsr'
% 76  'interpolated_angstrom_exponent_mfrsr'
% 77  'mean_aod_rl'
% 78  'height_rl'
% 79  'rh_rl'
% 80  'angstrom_exponent_rl'
% 81  'angstrom_exponent_mfr'
% 82  'angstrom_exponent_rl_filled'
% 83  'angstrom_exponent_AIP'
% 84  'GrnTscat_humidified'
% 85  'GrnBscat_humidified'
% 86  'BluTscat_humidified'
% 87  'BluBscat_humidified'
% 88  'RedTscat_humidified'
% 89  'RedBscat_humidified'
% 90  'rh_mean_surf_boundary'
% 91  'predicted_aod'
% 92  'boundary_layer'
% 93  'rh_mwrp'
% 94  'mean_aod_aos'
% 95  'extinction_profile_scaled'
% 96  'extinction_profile_aos'
% 97  'extinction_profile_clim'
% 98  'solar_zenith_angle'
% 99  'fRH_Bs_G_1um_2p'
%100  'source_fRH_Bs_G_1um_2p'
%101  'fRH_Bs_B_1um_2p'
%102  'source_fRH_Bs_B_1um_2p'
%103  'fRH_Bs_R_1um_2p'
%104  'source_fRH_Bs_R_1um_2p'
%105  'fRH_Bbs_G_1um_2p'
%106  'source_fRH_Bbs_G_1um_2p'
%107  'fRH_Bbs_B_1um_2p'
%108  'source_fRH_Bbs_B_1um_2p'
%109  'fRH_Bbs_R_1um_2p'
%110  'source_fRH_Bbs_R_1um_2p'
%111  'RH_NephVol_Dry'
%112  'ratio_Bs_R_1um'
%113  'ratio_Bs_G_1um'
%114  'ratio_Bs_B_1um'
%115  'ratio_Bbs_R_1um'
%116  'ratio_Bbs_G_1um'
%117  'ratio_Bbs_B_1um'
%118  'lat'
%119  'lon'
% 120  'alt'
