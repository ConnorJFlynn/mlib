function tzr = tzrcod_to_anc(in_file)
if ~isavar('in_file')||~isafile(in_file)
   in_file = getfullname('*TWST*.nc','tzrcod_nc4','Select instrument-level TWST file(s)');
   if isstruct(in_file)&&~empty(in_file)&&length(in_file)>1
      tzr = catme(tzrcod_to_anc(infile(2:end)), tzrcod_to_anc(infile{1}));
   else
      tzr = anc_load(in_file); 
      tzr = tzr.vdata;
      tzr.time = epoch2seria(tzr.time);
   end

end

   function tzr = catme(tzr, tzr_);


end