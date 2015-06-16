hsrl = ancload(getfullname('*.cdf','Select HSRL file','hsrl_nsa'));
%%
ahsrl = ancload(getfullname('*.nc','Select a UW HSRL file','ahsrl'));
%%
figure; 
axx(1) = subplot(2,1,1); 
imagesc(serial2Hh(ahsrl.time), ahsrl.vars.altitude.data, real(log10(ahsrl.vars.beta_a.data))); axis('xy'); colorbar; caxis([-5,-2]);
axx(2) = subplot(2,1,2); 
imagesc(serial2Hh(hsrl.time), hsrl.vars.range.data, real(log10(hsrl.vars.beta_a.data))); axis('xy');colorbar; caxis([-5,-2])
linkaxes(axx,'xy')

%%
figure(5)
ax(1) = subplot(4,1,1); 
imagesc(serial2Hh(ahsrl.time), ahsrl.vars.altitude.data, real(log10(ahsrl.vars.beta_a_backscat.data))); axis('xy');colorbar; caxis([-8,-3])
ax(2) = subplot(4,1,2); 
imagesc(serial2Hh(ahsrl.time), ahsrl.vars.altitude.data, real(log10(ahsrl.vars.depol.data))); axis('xy');colorbar;caxis([log10(.01),log10(2)]);
ax(3) = subplot(4,1,3); 
imagesc(serial2Hh(ahsrl.time), ahsrl.vars.altitude.data, real(log10(ahsrl.vars.beta_a.data))); axis('xy');colorbar;caxis([-5,-2])
ax(4) = subplot(4,1,4);
linkaxes(ax,'xy')
imagesc(serial2Hh(ahsrl.time), ahsrl.vars.altitude.data, ahsrl.vars.beta_a.data./ahsrl.vars.beta_a_backscat.data); axis('xy');colorbar;caxis([8*pi/3,50])
xlim([0,12]);
if exist('yl','var')
    ylim(yl);
else
  ylim([0,15e3])
end
%%

figure;
plot(hsrl.vars.range.data, hsrl.vars.
%%
hsrl.vars.piezovoltage.data(1:5)

%%

    'time_average'
    'range_resolution'
    'cal_times'
    'cal_trigger'
    'top_alt_sounding'
    'temperature_profile'
    'pressure_profile'
    'dewpoint_profile'
    'raob_station'
    'raob_time_offset'
    'raob_time_vector'
    'raob_beta_m'
    'lidar_calibration_Cmc'
    'lidar_calibration_Cmm'
    'lidar_calibration_Cam'
    'combined_gain'
    'combined_merge_threshhold'
    'geo_cor'
    'transmitted_energy'
    'piezovoltage'
    'num_seeded_shots'
    'seed_quality'
    'frequency_quality'
    'lock_quality'
    'mol_cal_pulse'
    'c_pol_dark_count'
    'mol_dark_count'
    'combined_dark_count_lo'
    'combined_dark_count_hi'
    'od'
    'beta_a'
    'atten_beta_r_backscat'
    'depol'
    'molecular_counts'
    'combined_counts_lo'
    'combined_counts_hi'
    'cross_counts'
    'beta_a_backscat'
    'qc_mask'
    'std_beta_a_backscat'
    'lat'
    'lon'
    'alt'
