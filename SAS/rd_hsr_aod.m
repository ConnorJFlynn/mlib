function hsr = rd_hsr_aod(infiles);

%read hsr aod

if ~isavar('infiles')
infiles = getfullname('hsr1*.nc','hsr_aod');
end
for f =length(infiles):-1:1

   anc = anc_load(infiles{f});
   hsr.time = unique([hsr.time ;(epoch2serial(double(anc.vdata.retrieved_aod_time)))]);
   hsr.wl(f) = sscanf(anc.gatts.wavelength_nm,'%f');
   disp(f)
end

for f =length(infiles):-1:1
   anc = anc_load(infiles{f});
  intime = (epoch2serial(double(anc.vdata.retrieved_aod_time)));
  aod = anc.vdata.retrieved_aod;
  t_i = interp1(hsr.time, [1:length(hsr.time)],intime,'nearest','extrap');
  hsr.aod(t_i,f) = aod;
end

return


figure; these = plot(hsr.wl, hsr.aod,'.'); 
recolor(these,serial2doy(hsr.time))
