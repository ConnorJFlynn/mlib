function pin_sas_to_mfr

% load vis0, nir0, vis, nir, mfrsr
% identify some clear sky using mfrsr direct_normal
% generate the corresponding time index matching vis0/nir0 to clear total hemisp time
% load vis_calib and nir_calib files,
% resp = calib(:,3)
% multipy each resp by integration time
% compute mean vis_dark and nir_dark
% compute irad = (spectra - dark)./resp
% plot (vis.wl, vis_irad, 'b-',nir.wl, nir_irad,'r-', [415,500,615,676,870,1645],

mfr = anc_load(getfullname('*mfrsr*.nc','mfr'));
figure; plot(mfr.time, mfr.vdata.direct_normal_narrowband_filter5,'.', mfr.time, mfr.vdata.hemisp_narrowband_filter5,'.'); dynamicDateTicks
menu('Zoom into a time with stable irradiances','OK');
t_mfr = mean(xlim); ti_mfr = interp1(mfr.time, [1:length(mfr.time)],t_mfr,'nearest');
dstr = datestr(mfr.time(ti_mfr),'yyyymmdd');
vis0 = anc_load(getfullname(['*sashevis*.a0.*',dstr,'*']));
nir0 = anc_load(getfullname(['*sashenir*.a0.*',dstr,'*']));
vis_dark = mean(vis0.vdata.spectra(:,vis0.vdata.shutter_state==0),2);
nir_dark = mean(nir0.vdata.spectra(:,nir0.vdata.shutter_state==0),2);
vis = anc_load(getfullname(['*sashevis*.b1.*',dstr,'*']));
nir = anc_load(getfullname(['*sashenir*.b1.*',dstr,'*']));

vcal_fname = getfullname('*sashevis*.Io_calib');
ncal_fname = getfullname('*sashenir*.Io_calib');
vis_calib = load(vcal_fname);
nir_calib = load(ncal_fname);
vis_resp = vis_calib(:,3);
nir_resp = nir_calib(:,3);
vis_resp = vis.vdata.responsivity_vis;%.*unique(vis.vdata.integration_time_vis);
nir_resp = nir.vdata.responsivity_nir;%.*unique(nir.vdata.integration_time_nir);
vis_resp = vis_resp .*unique(vis.vdata.integration_time_vis);
nir_resp = nir_resp.*unique(nir.vdata.integration_time_nir);

t_v0 = interp1(vis0.time(vis0.vdata.tag==5),find(vis0.vdata.tag==5), t_mfr,'nearest');
t_v = interp1(vis.time,[1:length(vis.time)], t_mfr,'nearest');
t_n0 = interp1(nir0.time(nir0.vdata.tag==5),find(nir0.vdata.tag==5), t_mfr,'nearest');
t_n = interp1(nir.time,[1:length(nir.time)], t_mfr,'nearest');

mfr_wl = [415, 500, 615, 676, 870];
mfr_irad = [mfr.vdata.hemisp_narrowband_filter1(ti_mfr), mfr.vdata.hemisp_narrowband_filter2(ti_mfr), ...
   mfr.vdata.hemisp_narrowband_filter3(ti_mfr), mfr.vdata.hemisp_narrowband_filter4(ti_mfr), mfr.vdata.hemisp_narrowband_filter5(ti_mfr)];


vis_cts = vis.vdata.total_hemisp_vis(:,t_v).*vis_resp;
vis0_cts = (vis0.vdata.spectra(:,t_v0)-vis_dark);
nir_cts = nir.vdata.total_hemisp_nir(:,t_n).*nir_resp;
nir0_cts = (nir0.vdata.spectra(:,t_n0)-nir_dark);

figure; plot(vis.vdata.wavelength_vis, vis_cts, '.',vis.vdata.wavelength_vis, vis0_cts,'o');
figure; plot(nir.vdata.wavelength_nir, nir_cts, '.',nir.vdata.wavelength_nir, nir0_cts,'o');

figure; plot(vis.vdata.wavelength_vis, vis_irad,'b.', vis.vdata.wavelength_vis, vis.vdata.total_hemisp_vis(:,t_v),'o',...
   nir.vdata.wavelength_nir, nir_irad,'r.', nir.vdata.wavelength_nir, nir.vdata.total_hemisp_nir(:,t_n),'o',...
   mfr_wl, mfr_irad,'mo'); logy; zoom('on');

vismfr_irad = interp1(vis.vdata.wavelength_vis, vis_irad, mfr_wl,'nearest');
vm_factor = mean(mfr_irad./vismfr_irad);
vis_resp = vis_calib(:,3).*unique(vis.vdata.integration_time_vis)./vm_factor;
nir_resp = nir_calib(:,3).*unique(nir.vdata.integration_time_nir)./vm_factor;
vis_irad = (vis0.vdata.spectra(:,t_v0)-vis_dark)./vis_resp;
nir_irad = (nir0.vdata.spectra(:,t_n0)-nir_dark)./nir_resp;

figure; plot(vis.vdata.wavelength_vis, vis_irad,'b.', vis.vdata.wavelength_vis, vis.vdata.total_hemisp_vis(:,t_v),'o',...
   nir.vdata.wavelength_nir, nir_irad,'r.', nir.vdata.wavelength_nir, nir.vdata.total_hemisp_nir(:,t_n),'o',...
   mfr_wl, mfr_irad,'mo'); logy; zoom('on');

kk = menu('Write out new resp values?','OK','No')

if kk == 1
   vis_calib(:,3) = vis_resp ./ unique(vis.vdata.integration_time_vis);
   nir_calib(:,3) = nir_resp ./ unique(nir.vdata.integration_time_nir);

   [pname, vname, ext] = fileparts(vcal_fname);
   [~,nname] = fileparts(ncal_fname); nname = [nname, ext];
   pname = [pname, filesep]; vname = [vname, ext];
   add = [];j = 1;
   while isafile([pname, vname, add])
      j  = j +1;
      add = ['.' num2str(j)];
   end
   vname = [vname, add]; nname = [nname, add];

   vid = fopen([pname,vname],'w');
   fprintf(vid, '%d %4.3f %5.6f %1.6f \n',vis_calib');
   fclose(vid);

   nid = fopen([pname,nname],'w');
   fprintf(nid, '%d %4.3f %5.6f %1.6f \n',nir_calib');
   fclose(nid);

end

end