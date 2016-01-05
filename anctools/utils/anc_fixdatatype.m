function att = anc_fixdatatype(att,val);
% val = anc_datacast(val,att);
% idea is to fix att.datatype to match class of val
datatype_to_class = {'uint8','char','int16','int32','single','double'};
if ~isfield(att, 'datatype')|~strcmp(datatype_to_class{att.datatype},class(val))
   dtype = find(strcmp(class(val),datatype_to_class));
   if ~isempty(dtype)
      val.datatype = dtype;
   else
      disp([class(val), ' is not a valid data type for netcdf.']);
   end
end



