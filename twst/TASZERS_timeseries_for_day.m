function TASZERS_timeseries_for_day

infile = getfullname(['TASZERS_*.mat'],'TASZERS','Select a TASZERS daily mat file.');
for in = 1:length(infile)

if isafile(infile{in})
   taszers_xcal = load(getfullname('taszers_xcal_resp_20240426.mat','taszers_xcal', 'Select the taszers_xcal mat file.'));

   TASZERS = load(infile{in});
   Ze1_vis = TASZERS.Ze1_vis;
   Ze2_vis=TASZERS.Ze2_vis;
   Ze1_nir=TASZERS.Ze1_nir;
   if isfield(TASZERS,'Ze12nir')
      Ze2_nir=TASZERS.Ze12nir;
   else
      Ze2_nir=TASZERS.Ze2_nir;
   end
   TWST10 = TASZERS.TWST10;
   TWST11 = TASZERS.TWST11;
   clear TASZERS
   Ze1_1020 = find(Ze1_vis.wl>1019.6, 1, 'first'); taszers_xcal.Ze1_resp_vis(Ze1_1020) = taszers_xcal.Ze1_resp_vis(Ze1_1020-2);
   Ze1_vis_rad = (Ze1_vis.rate)./taszers_xcal.Ze1_resp_vis; Ze1_nir_rad = (Ze1_nir.rate)./taszers_xcal.Ze1_resp_nir;
   Ze2_vis_rad = (Ze2_vis.rate)./taszers_xcal.Ze2_resp_vis; Ze2_nir_rad = (Ze2_nir.rate)./taszers_xcal.Ze2_resp_nir;
   TWST10_radA =(TWST10.rate_A)./taszers_xcal.twst10_resp.A; TWST10_radB =(TWST10.rate_B)./taszers_xcal.twst10_resp.B;
   TWST11_radA =(TWST11.rate_A)./taszers_xcal.twst11_resp.A; TWST11_radB =(TWST11.rate_B)./taszers_xcal.twst11_resp.B;



   nm1_500 = interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],500,'nearest');
   nm2_500 = interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],500,'nearest');
   nm10_500 = interp1(TWST10.wl_A , [1:length(TWST10.wl_A)],500,'nearest');
   nm11_500 = interp1(TWST11.wl_A , [1:length(TWST11.wl_A)],500,'nearest');
   pos1 = Ze1_vis.Shutter_open_TF==1; pos2 = Ze2_vis.Shutter_open_TF==1;
   pos1n = Ze1_nir.Shutter_open_TF==1; pos2n = Ze2_nir.Shutter_open_TF==1;


   figure_(121011);
   plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'-',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'-',...
      TWST10.time, TWST10_radA(nm10_500,:),'-',TWST11.time, TWST11_radA(nm11_500,:),'-'); 
   legend('Ze1','Ze2','TWST10','TWST11')
   dynamicDateTicks
   title(['500 nm radiance vs time for ',datestr(mean(Ze1_vis.time),'yyyy-mm-dd')])
zoom('on'); 
outfile = [getnamedpath('TZR_fig'),'timeseries_',datestr(mean(Ze1_vis.time),'yyyymmdd'),'.fig'];
menu('Zoom to a sharp peak and click OK','OK')
saveas(121011,outfile);
outfile = [getnamedpath('TZR_fig'),'timeseries_',datestr(mean(Ze1_vis.time),'yyyymmdd'),'.png'];
saveas(121011,outfile);
end
end