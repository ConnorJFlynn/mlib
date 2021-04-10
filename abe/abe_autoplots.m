function [old,new] = abe_autoplots(old);
%%
if ~exist('new','var')
   old = ancload(getfullname_('*.cdf','abe_old','Select original (old) file.'));
end
%%

vars = fieldnames(old.vars);
[t_ainb,t_bina] = nearest(old.time, old.time); % Useful to match times for difference plots;
[h_ainb,h_bina] = nearest(old.vars.height.data, old.vars.height.data); % Match height dims
%%
for v = length(vars):-1:1
   vardims(v) = length(old.vars.(vars{v}).dims)*~isempty(old.vars.(vars{v}).dims{1});
end

vdims_1 = find(vardims==1);
vdims_1((vdims_1==7)|(vdims_1==41)) = []; %remove height and rl_height field
vdims_2 = find(vardims==2);
%%
% vdims_1 = []; % uncommment this line to skip the 1-D plots
for v = fliplr(vdims_1)
   figure(1);
   
miss1 = old.vars.(vars{v}).data<-9998 & old.vars.(vars{v}).data>-10000;
olds = old.vars.(vars{v}).data;
if length(olds)==length(old.time)
olds(miss1) = NaN;
plot(serial2doy(old.time), olds, 'g.');
title(vars{v},'interp','none');
xlabel('time (day of year)');
end
% K = menu('Select to continue','OK');

end
%%
% close('all')
%%
n = 2;
for v = fliplr(vdims_2)
   figure(n);
miss1 = old.vars.(vars{v}).data<-9998 & old.vars.(vars{v}).data>-10000;
olds = old.vars.(vars{v}).data;
olds(miss1) = NaN;
imagegap(serial2doy(old.time(t_ainb)), old.vars.height.data(h_ainb),olds(h_ainb,t_ainb));
colorbar;cv = caxis;
title(vars{v},'interp','none');
ylabel('height');
xlabel('time (day of year)');
K = menu('New figure window?','Y','N');
if K==1
   n = n+1;
end
end
%%
% 
% imagegap(serial2doy(abe.time), abe.vars.height.data, real(log10(abe.vars.extinction_profile_clim.data))); colorbar
% imagegap(serial2doy(abe.time), abe.vars.height.data, real(log10(abe.vars.extinction_profile_scaled.data))); colorbar
% imagegap(serial2doy(abe.time), abe.vars.height.data, real(log10(abe.vars.extinction_profile_aos.data))); colorbar
% figure; plot(serial2doy(abe.time), abe.vars.be_aod_500.data,'g.')
% niner = (serial2doy(abe.time)>=159) & (serial2doy(abe.time)<160);
% figure; semilogy(abe.vars.height.data, abe.vars.extinction_profile_clim.data(:,niner),'-')
% figure; semilogy(abe.vars.height.data, abe.vars.extinction_profile_aos.data(:,niner),'-')
% figure; semilogy(abe.vars.height.data, abe.vars.extinction_profile_scaled.data(:,niner),'-')
% figure; semilogy(abe.vars.height.data, abe.vars.extinction_profile.data(:,niner),'-')

%%

% 1   'base_time'
% 2   'time_offset'
% 3   'time'
% 4   'be_aod_500'
% 5   'be_aod_355'
% 6   'be_angst_exp'
% 7   'height'
% 8   'extinction_profile'
% 9   'single_scattering_albedo'
%10   'asymmetry_parameter'
%11   'scat_coeff_green'
%12   'effective_height'
%13   'backscatter_green'
%14   'absorp_coef_mean'
%15   'rh'
%16   'mean_aod_mfrsr_filter1'
%17   'sdev_aod_mfrsr_filter1'
%18   'mean_aod_mfrsr_filter2'
%19   'sdev_aod_mfrsr_filter2'
%20   'mean_aod_mfrsr_filter3'
%21   'sdev_aod_mfrsr_filter3'
%22   'mean_aod_mfrsr_filter4'
%23   'sdev_aod_mfrsr_filter4'
%24   'mean_aod_mfrsr_filter5'
%25   'sdev_aod_mfrsr_filter5'
%26   'mean_angst_exponent_mfrsr'
%27   'interpolated_angst_exponent_mfrsr'
%28   'mean_aod_nimfr_filter1'
%29   'sdev_aod_nimfr_filter1'
%30   'mean_aod_nimfr_filter2'
%31   'sdev_aod_nimfr_filter2'
%32   'mean_aod_nimfr_filter3'
%33   'sdev_aod_nimfr_filter3'
%34   'mean_aod_nimfr_filter4'
%35   'sdev_aod_nimfr_filter4'
%36   'mean_aod_nimfr_filter5'
%37   'sdev_aod_nimfr_filter5'
%38   'mean_angst_exponent_nimfr'
%39   'interpolated_angst_exponent_nimfr'
%40   'mean_aod_rl'
%41   'height_rl'
%42   'rh_rl'
%43   'angst_exponent_rl'
%44   'angst_exponent_mfrsr_filter2'
%45   'angst_exponent_rl_filled'
%46   'angstrom_exponent_AOS'
%47   'scat_coeff_blue'
%48   'backscatter_blue'
%49   'scat_coeff_red'
%50   'backscatter_red'
%51   'GrnTscat_humidified'
%52   'GrnBscat_humidified'
%53   'BluTscat_humidified'
%54   'BluBscat_humidified'
%55   'RedTscat_humidified'
%56   'RedBscat_humidified'
%57   'aod_effect_ht'
%58   'effect_ht_interpolated'
%59   'rh_mean_surf_boundary'
%60   'aod_source_flag'
%61   'effect_ht_flag'
%62   'predicted_aod'
%63   'boundary_layer'
%64   'rh_mwrp'
%65   'mean_aod_aos'
%66   'extinction_profile_scaled'
%67   'extinction_profile_aos'
%68   'extinction_profile_clim'
%69   'rh_sonde'
%70   'lat'
%71   'lon'
%72   'alt'
