% Examine MFRSR_CIP and  surfspecalb files to make sense of status fields
mfr = ancload(getfullname('sgp*.cdf','cip','Select aod file'));
plot_qcs(mfr)

cip = ancload(getfullname('sgp*.cdf','cip','Select cip file'));
surf = ancload(getfullname('sgp*.cdf','cip','Select surfspec file'));
figure; plot(serial2hs(surf.time), surf.vars.cosine_solar_zenith_angle_mfr25mC1.data - surf.vars.cosine_solar_zenith_angle_mfr10mC1.data,'o')

good = qc_impacts(cip.vars.qc_aerosol_optical_depth_filter2_observed)==0;


 figure; plot(serial2hs(cip.time),good,'o')

[cip] = ancsift(cip,cip.dims.time,good);
[ainb, bina] = nearest(cip.time, surf.time);

surf_bina = ancsift(surf, surf.dims.time, bina);

plot_qcs(surf_bina);


figure(104);plot(serial2hs(cip.time), cip.vars.volume_median_radius_fine.data,'o-',...
    serial2hs(cip.time), cip.vars.volume_median_radius_coarse.data,'-x');legend('mean radius, fine','mean radius, coarse');

figure(105);plot(serial2hs(cip.time), cip.vars.volume_median_radius_fine.data,'o-',...
    serial2hs(cip.time), cip.vars.volume_median_radius_coarse.data,'-x');legend('mean radius, fine','mean radius, coarse');


N = [25:29];figure(101); lines = loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N);...
    cip.vars.aerosol_optical_depth_filter2_modeled.data(N);cip.vars.aerosol_optical_depth_filter3_modeled.data(N);...
    cip.vars.aerosol_optical_depth_filter4_modeled.data(N);cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar

figure(109); lines = plot(serial2hs(cip.time), [cip.vars.refractive_index_real_part_filter1.data;...
 cip.vars.refractive_index_real_part_filter2.data;cip.vars.refractive_index_real_part_filter3.data;...
 cip.vars.refractive_index_real_part_filter4.data;cip.vars.refractive_index_real_part_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar

figure(110); lines = plot(serial2hs(cip.time), [cip.vars.asymmetry_parameter_filter1.data;...
 cip.vars.asymmetry_parameter_filter2.data;cip.vars.asymmetry_parameter_filter3.data;...
 cip.vars.asymmetry_parameter_filter4.data;cip.vars.asymmetry_parameter_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar; title('asymmetry parameter')

figure(111); lines = plot(serial2hs(cip.time), [cip.vars.ssa_filter1.data;...
 cip.vars.ssa_filter2.data;cip.vars.ssa_filter3.data;...
 cip.vars.ssa_filter4.data;cip.vars.ssa_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar; title('ssa')

% cip fieldnames...
    'qc_aerosol_optical_depth_filter1_observed'
    'aerosol_optical_depth_filter2_observed'
    'qc_aerosol_optical_depth_filter2_observed'
    'aerosol_optical_depth_filter3_observed'
    'qc_aerosol_optical_depth_filter3_observed'
    'aerosol_optical_depth_filter4_observed'
    'qc_aerosol_optical_depth_filter4_observed'
    'aerosol_optical_depth_filter5_observed'
    'qc_aerosol_optical_depth_filter5_observed'
    'diffuse_hemisp_narrowband_filter1_observed'
    'diffuse_hemisp_narrowband_filter2_observed'
    'diffuse_hemisp_narrowband_filter3_observed'
    'diffuse_hemisp_narrowband_filter4_observed'
    'diffuse_hemisp_narrowband_filter5_observed'
    'direct_normal_narrowband_filter1_observed'
    'direct_normal_narrowband_filter2_observed'
    'direct_normal_narrowband_filter3_observed'
    'direct_normal_narrowband_filter4_observed'
    'direct_normal_narrowband_filter5_observed'
    'direct_to_diffuse_ratio_filter1_observed'
    'direct_to_diffuse_ratio_filter2_observed'
    'direct_to_diffuse_ratio_filter3_observed'
    'direct_to_diffuse_ratio_filter4_observed'
    'direct_to_diffuse_ratio_filter5_observed'
    'surface_albedo_filter1'
    'surface_albedo_filter2'
    'surface_albedo_filter3'
    'surface_albedo_filter4'
    'surface_albedo_filter5'
    'aerosol_particle_volume_concentration_fine'
    'aerosol_particle_volume_concentration_coarse'
    'volume_median_radius_fine'
    'volume_median_radius_std_fine'
    'volume_median_radius_coarse'
    'volume_median_radius_std_coarse'
    'refractive_index_imaginary_part_filter1'
    'refractive_index_real_part_filter1'
    'refractive_index_imaginary_part_filter2'
    'refractive_index_real_part_filter2'
    'refractive_index_imaginary_part_filter3'
    'refractive_index_real_part_filter3'
    'refractive_index_imaginary_part_filter4'
    'refractive_index_real_part_filter4'
    'refractive_index_imaginary_part_filter5'
    'refractive_index_real_part_filter5'
    'aerosol_optical_depth_filter1_modeled'
    'qc_aerosol_optical_depth_filter1_modeled'
    'aerosol_optical_depth_filter1_modeled_error'
    'aerosol_optical_depth_filter2_modeled'
    'qc_aerosol_optical_depth_filter2_modeled'
    'aerosol_optical_depth_filter2_modeled_error'
    'aerosol_optical_depth_filter3_modeled'
    'qc_aerosol_optical_depth_filter3_modeled'
    'aerosol_optical_depth_filter3_modeled_error'
    'aerosol_optical_depth_filter4_modeled'
    'qc_aerosol_optical_depth_filter4_modeled'
    'aerosol_optical_depth_filter4_modeled_error'
    'aerosol_optical_depth_filter5_modeled'
    'qc_aerosol_optical_depth_filter5_modeled'
    'aerosol_optical_depth_filter5_modeled_error'
    'direct_to_diffuse_ratio_filter1_modeled'
    'qc_direct_to_diffuse_ratio_filter1_modeled'
    'direct_to_diffuse_ratio_filter1_modeled_error'
    'direct_to_diffuse_ratio_filter2_modeled'
    'qc_direct_to_diffuse_ratio_filter2_modeled'
    'direct_to_diffuse_ratio_filter2_modeled_error'
    'direct_to_diffuse_ratio_filter3_modeled'
    'qc_direct_to_diffuse_ratio_filter3_modeled'
    'direct_to_diffuse_ratio_filter3_modeled_error'
    'direct_to_diffuse_ratio_filter4_modeled'
    'qc_direct_to_diffuse_ratio_filter4_modeled'
    'direct_to_diffuse_ratio_filter4_modeled_error'
    'direct_to_diffuse_ratio_filter5_modeled'
    'qc_direct_to_diffuse_ratio_filter5_modeled'
    'direct_to_diffuse_ratio_filter5_modeled_error'
    'ssa_filter1'
    'qc_ssa_filter1'
    'ssa_filter2'
    'qc_ssa_filter2'
    'ssa_filter3'
    'qc_ssa_filter3'
    'ssa_filter4'
    'qc_ssa_filter4'
    'ssa_filter5'
    'qc_ssa_filter5'
    'asymmetry_parameter_filter1'
    'qc_asymmetry_parameter_filter1'
    'asymmetry_parameter_filter2'
    'qc_asymmetry_parameter_filter2'
    'asymmetry_parameter_filter3'
    'qc_asymmetry_parameter_filter3'
    'asymmetry_parameter_filter4'
    'qc_asymmetry_parameter_filter4'
    'asymmetry_parameter_filter5'
    'qc_asymmetry_parameter_filter5'
    'be_surface_albedo_mfr_narrowband_25m'
    'qc_be_surface_albedo_mfr_narrowband_25m'
    'be_surface_albedo_mfr_narrowband_25m_status'

    %command history
    load_editor_proj('assist_sri.ed')
list_editor_proj
cip = ancload(getfullname('sgp*.cdf','cip','Select cip file'));
good = qc_impacts(cip.vars.qc_aerosol_optical_depth_filter2_observed)==0;
figure; plot([1:length(good)],good,'o')
mfr = ancload(getfullname('sgp*.cdf','cip','Select aod file'));
plot_qcs(mfr)
figure; plot(serial2hs(cip.time),good,'o')
surf = ancload(getfullname('sgp*.cdf','cip','Select surfspec file'));
fieldnames(surf.vars)
figure; plot(serial2hs(surf.time), surf.vars.cosine_solar_zenith_angle_mfr25mC1.data - surf.vars.cosine_solar_zenith_angle_mfr10mC1.data,'o')
[cip_good] = ancsift(cip,cip.dims.time,good);
[cip] = ancsift(cip,cip.dims.time,good);
[ainb, bina] = nearest(cip.time, surf.time);
surf_bina = ancsift(surf, surf.dims.time, bina);
fieldnames(surf.vars)
length(fieldnames(surf.vars))
length(fieldnames(surf_bina.vars))
plot_qcs(surf_bina);
size(surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data)
size(surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.data)
size(surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.data)
surf_bina.vars.qc_surface_albedo_mfr_broadband_10m.atts.bit_4_description.data
surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.data
surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.atts
surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.atts.comment1.data
1./0.15
surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.data
fieldnames(cip.vars)
cip.vars.be_surface_albedo_mfr_narrowband_25_filter1 = be_surface_albedo_mfr_narrowband_25.data(1,:);
cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1 = be_surface_albedo_mfr_narrowband_25m;
cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1 = cip.vars.be_surface_albedo_mfr_narrowband_25m;
cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1.data = cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1.data(1,:);
size( cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1.dat)
size( cip.vars.be_surface_albedo_mfr_narrowband_25m_filter1.data)
figure; plot(serial2hs(cip.time), cip.vars.qc_be_surface_albedo_mfr_narrowband_25m.data(1,:),'o')
cip.vars.qc_be_surface_albedo_mfr_narrowband_25m.atts
cip.vars.qc_be_surface_albedo_mfr_narrowband_25m.atts.description.data
figure; plot(serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m_status.data(1,:),'o')
figure; plot(serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m_status.data(2,:),'o')
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m_status.data(2,:),'o')
figure; plto(serial2hs(cip.time), cip.vars.ssa_filter2.data, 'o-')
figure; plot(serial2hs(cip.time), cip.vars.ssa_filter2.data, 'o-')
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'bx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'ro-')
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(2,:), 'kx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'ro-')
legend('25m from surfspec','10m from surfspec', 'average in cip'); title(['surface spectral albedo filter 2:',datestr(cip.time(1),'yyyy-mm-dd'))
legend('25m from surfspec','10m from surfspec', 'average in cip'); title(['surface spectral albedo filter 2:',datestr(cip.time(1),'yyyy-mm-dd')])
fieldnames(cip.vars)
figure; plot(serial2hs(cip.time), cip.vars.surface_albedo_filter2.data, 'xk-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'ro-')
figure; plot(serial2hs(cip.time), cip.vars.surface_albedo_filter1.data, 'xk-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(1,:), 'ro-')
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(1,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(1,:), 'kx-'); title('surfspecalbedo 415 nm'); legend('25m','10m')
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(2,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'ro-'); title('filter 2'); legend('surf 25m','surf 10m','cip (avg)')
v = axis;
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(2,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(2,:), 'ro-'); title('filter 2'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(1,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(1,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(1,:), 'ro-'); title('filter 1'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(3,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(3,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(3,:), 'ro-'); title('filter 3'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
unique(cip.vars.surface_albedo_filter3.data)
unique(cip.vars.surface_albedo_filter1.data)
unique(cip.vars.surface_albedo_filter2.data)
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(4,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(4,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(4,:), 'ro-'); title('filter 4'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(5,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(5,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(5,:), 'ro-'); title('filter 5'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
%surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.data
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(5,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(5,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(5,:), 'ro-'); title('filter 5'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
figure; plot(serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_25m.data(4,:), 'bx-',serial2hs(surf_bina.time), surf_bina.vars.be_surface_albedo_mfr_narrowband_10m.data(4,:), 'gx-',serial2hs(cip.time), cip.vars.be_surface_albedo_mfr_narrowband_25m.data(4,:), 'ro-'); title('filter 4'); legend('surf 25m','surf 10m','cip (avg)'); axis(v)
surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.data
surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.atts
surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.atts.comment1.data
surf_bina.vars.be_surface_albedo_mfr_narrowband_10m_status.atts.comment2.data
figure; plot(serial2hs(cip.time), cip.vars.cosine_solar_zenith_angle.data, 'o-')
figure; plot(serial2hs(cip.time), 1./cip.vars.cosine_solar_zenith_angle.data, 'o-'); legend('airmass')
figure; plot(serial2hs(cip.time), 0.2./cip.vars.cosine_solar_zenith_angle.data, 'ko-'); legend('airmass')
legend('ssa','airmass/5')
fieldnames(cip.vars)
figure(100); plot(cip.time, cip.vars.azimuth_angle.data,'o-')
figure(100); plot(serial2hs(cip.time), cip.vars.azimuth_angle.data,'o-')
figure(100); plot(cip.time, cip.vars.azimuth_angle.data,'o-'); dynamicDateTicks
figure(100); plot(serial2hs(cip.time), cip.vars.azimuth_angle.data,'o-')
figure(101); plot(cip.time, cip.vars.azimuth_angle.data,'o-'); dynamicDateTicks
figure(101); plot(cip.time, cip.vars.solar_zenith_angle.data,'o-'); dynamicDateTicks
figure(101); plot(cip.time, cip.vars.cosine_solar_zenith_angle.data,'o-'); dynamicDateTicks
figure(100); plot(serial2hs(cip.time), 1./cip.vars.cosine_solar_zenith_angle.data,'o-',serial2hs(cip.time), cip.vars.airmass.data,'x-')
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter1_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter1_modeled.data,'-x');
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filte21_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter2_modeled.data,'-x');
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter2_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter2_modeled.data,'-x');
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter3_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter3_modeled.data,'-x');
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter4_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter4_modeled.data,'-x');legend('obs','fit')
figure(100);plot(serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter5_observed.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_optical_depth_filter5_modeled.data,'-x');legend('obs','fit')
N = 28;figure(101); loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter2_modeled.data(N),cip.vars.aerosol_optical_depth_filter3_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter4_modeled.data(N),cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-')
N = 27;figure(101); loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter2_modeled.data(N),cip.vars.aerosol_optical_depth_filter3_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter4_modeled.data(N),cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-')
N = [25:29];figure(101); loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter2_modeled.data(N),cip.vars.aerosol_optical_depth_filter3_modeled.data(N),...
cip.vars.aerosol_optical_depth_filter4_modeled.data(N),cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-')
N = [25:29];figure(101); loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N);...
cip.vars.aerosol_optical_depth_filter2_modeled.data(N);cip.vars.aerosol_optical_depth_filter3_modeled.data(N);...
cip.vars.aerosol_optical_depth_filter4_modeled.data(N);cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-')
N = [25:29];figure(101); lines = loglog([415, 500, 615,676,870], [cip.vars.aerosol_optical_depth_filter1_modeled.data(N);...
cip.vars.aerosol_optical_depth_filter2_modeled.data(N);cip.vars.aerosol_optical_depth_filter3_modeled.data(N);...
cip.vars.aerosol_optical_depth_filter4_modeled.data(N);cip.vars.aerosol_optical_depth_filter5_modeled.data(N)],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar
figure(103);plot(serial2hs(cip.time), cip.vars.aerosol_particle_volume_concentration_fine.data,'o-',...
serial2hs(cip.time), cip.vars.aerosol_particle_volume_concentration_coarse.data,'-x');legend('fine','coarse');
figure(104);plot(serial2hs(cip.time), cip.vars.volume_median_radius_fine.data,'o-',...
serial2hs(cip.time), cip.vars.volume_median_radius_coarse.data,'-x');legend('mean radius, fine','mean radius, coarse');
figure(109); lines = plot(serial2hs(cip.time), [cip.vars.refractive_index_real_part_filter1.data;...
cip.vars.refractive_index_real_part_filter2.data;cip.vars.refractive_index_real_part_filter3.data;...
cip.vars.refractive_index_real_part_filter4.data;cip.vars.refractive_index_real_part_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar
figure(110); lines = plot(serial2hs(cip.time), [cip.vars.asymmetry_parameter_filter1.data;...
cip.vars.asymmetry_parameter_filter2.data;cip.vars.asymmetry_parameter_filter3.data;...
cip.vars.asymmetry_parameter_filter4.data;cip.vars.asymmetry_parameter_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar; title('asymmetry parameter')
figure(111); lines = plot(serial2hs(cip.time), [cip.vars.ssa_filter1.data;...
cip.vars.ssa_filter2.data;cip.vars.ssa_filter3.data;...
cip.vars.ssa_filter4.data;cip.vars.ssa_filter5.data],'o-');
recolor(lines,[415, 500, 615,676,870]);colorbar; title('ssa')