% assess sws.b0 QC

rad_b0 = anc_load(getfullname('*swsrad*.b0.*.nc','sws'));
rad = anc_load(getfullname('*swsrad*.b1.*.nc','sws'));
[~,fname,ex] = fileparts(rad.fname)
vis = anc_load(getfullname(['*swsvisC1.a0.*.nc'],'swsvis'));

nir = anc_load(getfullname(['*swsnirC1.a0.*.nc'],'swsnir'));

[rinv, vinr] = nearest(rad.time, vis.time);
% bit_1_description: 'Value is equal to missing_value.'
% bit_2_description: 'Value is less than fail_min.'
% bit_3_description: 'Value is greater than fail_max.'
% bit_4_description: 'pwr_pos12v is Bad'
nir.vdata.pwr_pos12v(1000:2000) = -1.*nir.vdata.pwr_pos12v(1000:2000);
vis.vdata.pwr_pos12v(1000:2000) = -1.*vis.vdata.pwr_pos12v(1000:2000);
 bitget(rad.vdata.qc_zenith_radiance_LW(128,rinv(vinr>5997&vinr<6010)),9)
% bit_5_description: 'pwr_neg12v is Bad'
nir.vdata.pwr_neg12v(2000:3000) = -1.*nir.vdata.pwr_neg12v(2000:3000);
vis.vdata.pwr_neg12v(2000:3000) = -1.*vis.vdata.pwr_neg12v(2000:3000);
% bit_6_description: 'pwr_5v is Bad'
nir.vdata.pwr_5v(3000:4000) = -1.*nir.vdata.pwr_5v(3000:4000);
vis.vdata.pwr_5v(3000:4000) = -1.*vis.vdata.pwr_5v(3000:4000);
% bit_7_description: 'temp_rack is Bad'
nir.vdata.temp_rack(4000:5000) = 50;
vis.vdata.temp_rack(4000:5000) = 50;
% bit_8_description: 'rh_rack is Bad'
nir.vdata.rh_rack(5000:6000) = 110;
vis.vdata.rh_rack(5000:6000) = 110;
% bit_9_description: 'temp_spec_SW is Bad'
nir.vdata.temp_nir_spec(6000:7000) = 110;
vis.vdata.temp_vis_spec(6000:7000) = 110;
% bit_10_description: 'responsivity_SW is Bad'

% bit_11_description: 'Not used'
% bit_12_description: 'Not used'
% bit_13_description: 'Any pixel was saturated (applies to all SW pixels)'
% bit_14_description: 'pixel was saturated (applies only to saturated pixels)'
% bit_15_description: 'Dark spectra suspect (too old or too variable)'
% bit_16_description: '(90-solar_zenith) > solar_elevation_max_warning'
% bit_17_description: '(90-solar_zenith) > solar_elevation_max_alarm'

bitget(rad.vdata.qc_zenith_radiance_LW([110 125 155] ,rinv(vinr>9997&vinr<10010)),14)

nir.vdata.solar_zenith_angle(7000:9000) = 4;
vis.vdata.solar_zenith_angle(7000:9000) = 4;
nir.vdata.solar_zenith_angle(7500:8500) = 0;
vis.vdata.solar_zenith_angle(7500:8500) = 0;
nir.vdata.spectra(120:140,9000:10000) = 32500;
nir.vdata.spectra(120:140,10000:11000) = 32766;
nir.vdata.spectra(120:140,11000:12000) = 32767;
nir.vdata.spectra(120:140,12000:13000) = 33333;

vis.vdata.spectra(120:140,15000:16000) = 32500;
vis.vdata.spectra(120:140,16000:17000) = 32766;
vis.vdata.spectra(120:140,17000:18000) = 32767;
vis.vdata.spectra(120:140,18000:19000) = 33333;
vis.clobber = true;
nir.clobber = true;
vis.fname = strrep(vis.fname,'.nc','.mod2.nc');
nir.fname = strrep(nir.fname,'.nc','.mod2.nc');
anc_save(vis); 
anc_save(nir);
% pix = 2; tt= 1;
% bit_1 = bitget(rad.vdata.qc_zenith_radiance_SW(:,pix),1); bits_1 = find(bit_1); length(bits_1)
% unique(rad.vdata.zenith_radiance_SW(bits_1,pix))
% 
% pix = 2; tt= 1;
% bit_2 = bitget(rad.vdata.qc_zenith_radiance_SW,2); bits_2 = find(bit_2); length(bits_2)
% unique(rad.vdata.zenith_radiance_SW(bits_2,pix))
% 
% pix = 2; tt= 1;
% bit_3 = bitget(rad.vdata.qc_zenith_radiance_SW,3); bits_3 = find(bit_3); numel(bits_3)
% unique(rad.vdata.zenith_radiance_SW(bits_3,pix))
% 
% pix = 2; tt= 1;
% bit_4 = bitget(rad.vdata.qc_zenith_radiance_SW,4); bits_4 = find(bit_4); numel(bits_4)
% unique(rad.vdata.zenith_radiance_SW(bits_4,pix))
% 
% bit_5 = bitget(rad.vdata.qc_zenith_radiance_SW,5); bits_5 = find(bit_5); numel(bits_5)
% imp = anc_qc_impacts(rad.vdata.qc_pwr_neg12v, rad.vatts.qc_pwr_neg12v); numel(imp(imp>0))
% 
% bit_6 = bitget(rad.vdata.qc_zenith_radiance_SW,6); bits_6 = find(bit_6); numel(bits_6)
% imp = anc_qc_impacts(rad.vdata.qc_pwr_5v, rad.vatts.qc_pwr_5v); numel(imp(imp>0))
% 
% bit_7 = bitget(rad.vdata.qc_zenith_radiance_SW,7); bits_7 = find(bit_7); numel(bits_7)
% imp = anc_qc_impacts(rad.vdata.qc_temp_rack, rad.vatts.qc_temp_rack); numel(imp(imp>0))
% rad.vatts.qc_temp_rack
% plot(rad.time, rad.vdata.temp_rack,'o'); dynamicDateTicks
% 
% bit_8 = bitget(rad.vdata.qc_zenith_radiance_SW,8); bits_8 = find(bit_8); numel(bits_8)
% imp = anc_qc_impacts(rad.vdata.qc_temp_spec_LW, rad.vatts.qc_temp_spec_LW); numel(imp(imp>0))
% 
% bit_9 = bitget(rad.vdata.qc_zenith_radiance_SW,9); bits_9 = find(bit_9); numel(bits_9)
% imp = anc_qc_impacts(rad.vdata.qc_temp_spec_SW, rad.vatts.qc_temp_spec_SW); numel(imp(imp>0))
% 
% bit_10 = bitget(rad.vdata.qc_zenith_radiance_SW,10); bits_10 = find(bit_10); numel(bits_10)
% imp = anc_qc_impacts(rad.vdata.qc_responsivity_SW, rad.vatts.qc_responsivity_SW); numel(imp(imp==2))
% 
% 
% bit_16 = bitget(rad.vdata.qc_zenith_radiance_SW,16); bits_16 = find(bit_16); numel(bits_16)
% imp = anc_qc_impacts(rad.vdata.qc_responsivity_SW, rad.vatts.qc_responsivity_SW)
% 
% 
% sat_ij = vis.vdata.spectra>32000; numel(sat_ij(sat_ij))