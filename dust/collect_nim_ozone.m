toms_path = getdir('dust_ozone','Select ozone source.');

toms_list = dir([toms_path, filesep,'*.cdf']);
for t =  1:length(toms_list);
   t
   toms = ancload([toms_path, toms_list(t).name]);
   toms_lat = [max(find(toms.vars.lat.data < mfr.vars.lat.data)):min(find(toms.vars.lat.data > mfr.vars.lat.data))];
   toms_lon = [max(find(toms.vars.lon.data < mfr.vars.lon.data)):min(find(toms.vars.lon.data > mfr.vars.lon.data))];
   if ~exist('ozone','var')
      ozone.time = toms.time;
      ozone.db = zeros(size(toms.time));
      ozone.db(:) = mean(mean(toms.vars.ozone.data(toms_lat, toms_lon, :)));
   else
      ozone.time = [ozone.time, toms.time];
      tmp = zeros(size(toms.time));
      tmp(:) = mean(mean(toms.vars.ozone.data(toms_lat, toms_lon, :)));
      ozone.db = [ozone.db, tmp];
   end
   [ozone.time, i]= sort(ozone.time);
   ozone.db = ozone.db(i);
end
nans = ozone.db<100;
ozone.db(nans) = NaN;


figure; plot(ozone.time, ozone.db, '.'); datetick('keepticks')
%%
save nim_ozone.mat ozone

