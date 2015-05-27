function val = ancfixdatatype(val);
% val = anc_datacast(val);
% idea is to fix val.datatype to match class of val.data
datatype_to_class = {'uint8','char','int16','int32','single','double'};
if ~isfield(val, 'datatype')|~strcmp(datatype_to_class{val.datatype},class(val.data))
   dtype = find(strcmp(class(val.data),datatype_to_class));
   if ~isempty(dtype)
      val.datatype = dtype;
   else
      disp([class(val.data), ' is not a valid data type for netcdf.']);
   end
end



