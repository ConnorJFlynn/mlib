function twst = rd_twst_nc4(in_file)

while ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
end
if ~iscell(in_file) && isafile(in_file)
   in_file = {in_file};
end
twst = twst4_to_struct(in_file{1});
if length(in_file)>1
   twst2 = rd_twst_nc4(in_file(2:end));
   [twst.time, ind] = unique([twst.time, twst2.time]);
   tmp = [twst.epoch, twst2.epoch];
   twst.epoch = tmp(ind);
   tmp = [twst.zenrad_A, twst2.zenrad_A];
   twst.zenrad_A = tmp(:,ind);
   tmp = [twst.zenrad_B, twst2.zenrad_B];
   twst.zenrad_B = tmp(:,ind);
   clear twst2
end


end