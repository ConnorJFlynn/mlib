
Ze1_vresp = rd_sasze_resp_file(getfullname('*saszevis*.cal.*.dat','Ze1_resp','Select a Ze1 vis resp file'));
Ze2_vresp = rd_sasze_resp_file(getfullname('*saszevis*.cal.*.dat','Ze2_resp','Select a Ze2 vis resp file'));

Ze1 = rd_SAS_dualtint_raw(getfullname(['sgpsaszeC1.*_vis_1s.*.csv'],'taszers_Ze1','Select Ze1 vis files'));
% oriel_cal_vis.resp(oriel_cal_vis.lambda_nm>1020) = NaN;

Ze2 = rd_SAS_dualtint_raw(getfullname(['sgpsaszeE13.*_vis_1s.*.csv'],'taszers_Ze2','Select Ze2 vis files'));

Ze1.zrad = Ze1.rate./(ones(size(Ze1.time))*Ze1_vresp.resp');
Ze2.zrad = Ze2.rate./(ones(size(Ze2.time))*Ze2_vresp.resp');

nm1_500 = interp1(Ze1.wl, [1:length(Ze1.wl)],500,'nearest');
nm2_500 = interp1(Ze2.wl, [1:length(Ze2.wl)],500,'nearest');

figure; plot(Ze1.time(Ze1.Shutter_open_TF==1), Ze1.zrad(Ze1.Shutter_open_TF==1,nm1_500),'.',...
   Ze2.time(Ze2.Shutter_open_TF==1), Ze2.zrad(Ze2.Shutter_open_TF==1,nm2_500),'.'); dynamicDateTicks

twst_10 =twst4_to_struct(getfullname(['sgptwstC1.*.TWST-EN*0010_2024*.nc'],'twst_10','Select TWST10 files...'));
nm10_500 = interp1(twst_10.wl_A , [1:length(twst_10.wl_A)],500,'nearest')
twst_11 =twst4_to_struct(getfullname(['sgptwstE13.*.TWST-EN*0011_2024*.nc'],'twst_11','Select TWST11 files...'));
nm11_500 = interp1(twst_11.wl_A , [1:length(twst_11.wl_A)],500,'nearest')

anet_zrad = anet_ppl_zenrad(datenum(2024,4,28));

% Read anet cloudmode file
cim_cld = rd_cimel_cloudrad_v3;

figure; plot(Ze1.time(Ze1.Shutter_open_TF==1), Ze1.zrad(Ze1.Shutter_open_TF==1,nm1_500),'.',...
   Ze2.time(Ze2.Shutter_open_TF==1), Ze2.zrad(Ze2.Shutter_open_TF==1,nm2_500),'.',...
   twst_10.time, 1e3.*twst_10.zenrad_A(nm10_500,:),'.',...
   twst_11.time, 1e3.*twst_11.zenrad_A(nm11_500,:),'.',...
   anet_zrad.time, anet_zrad.zenrad_500_nm,'o',cim_cld.time, cim_cld.A500nm,'+',cim_cld.time, cim_cld.K500nm,'x'); dynamicDateTicks;
legend('Ze1','Ze2','TWST-10','TWST-11', 'PPL 500nm', 'Cld A500nm', 'Cld K500nm')
ylabel(cim_cld.zenrad_units)



