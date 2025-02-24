function tzr = tzrcod_to_catmat(in_file)
if ~isavar('in_file')
   in_file = getfullname('*TWST*.nc','tzrcod_nc4','Select instrument-level TWST file(s)');
end

if iscell(in_file)&&~isempty(in_file)&&length(in_file)>1
   tzr = tzrcod_to_catmat(in_file{1});
   tzr = catme(tzrcod_to_catmat(in_file(2:end)), tzr);
else
   if iscell(in_file) 
      in_file = in_file{1};
   end
   tzr = anc_load(in_file);
   tzr = tzr.vdata;
   tzr.time = epoch2serial(tzr.time);
   
end


return

function tzr = catme(tzr, tzr_)
[time, ind] = unique([tzr.time; tzr_.time]);
flds = fieldnames(tzr);
for f = 1:length(flds)
   fld = flds{f};
   tmp = [tzr.(fld); tzr_.(fld)];
   tzr.(fld) = tmp(ind);
end

return


