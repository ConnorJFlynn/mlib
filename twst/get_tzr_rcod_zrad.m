function tz = get_tzr_rcod_zrad

date_dir = getnamedpath('tzr_datedir')
tz = [];
for d = 20240501:20240531
   dstr = num2str(d); disp(dstr)
   day = datenum(dstr,'yyyymmdd');
   tz_file = [date_dir, dstr,filesep,'Ze2.',dstr,'.nc'];
   if isafile(tz_file)
      vdata = anc_load(tz_file);
      vdata = vdata.vdata;
      vdata.time = epoch2serial(vdata.time);
      vwl = [380,440,500,675,870]; vwl_i = interp1(vdata.wavelength_vis, [1:length(vdata.wavelength_vis)],vwl,'nearest');
      nwl = 1640; nwl_i = interp1(vdata.wavelength_nir, [1:length(vdata.wavelength_nir)],nwl,'nearest');
      vdata.zrad_380 = vdata.vis(vwl_i(1),:);vdata.zrad_440 = vdata.vis(vwl_i(2),:);
      vdata.zrad_500 = vdata.vis(vwl_i(3),:);vdata.zrad_675 = vdata.vis(vwl_i(4),:);
      vdata.zrad_870 = vdata.vis(vwl_i(5),:);vdata.zrad_1640 = vdata.nir(nwl_i(1),:);
      vdata = rmfield(vdata,{'vis','nir','wavelength_nir','wavelength_vis','lat','lon'});
      good = vdata.state==0|vdata.state==1|vdata.state==3|vdata.state==4;
      good = good & vdata.cod>0 & vdata.cod<199.9 & vdata.sza<75;
      good = good & vdata.time>day & vdata.time<(day+1);
      vdata = sift_tstruct(vdata,good);
      tz = cat_timeseries(tz,vdata);
   end
end
save([date_dir,'Ze2_rcods_zrads.mat'],'-struct','tz')