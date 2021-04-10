function dtype = class_to_dtype(val);
% dtype = class_to_dtype(val);
% match class to closest nc datatype
datatype_to_class = {'uint8','char','int16','int32','single','double','','uint16','uint32','int64','uint64'};
val_class = class(val);
   dtype = find(strcmp(val_class,datatype_to_class)); 
   if isempty(dtype)
      warning([val_class, ' is not a valid data type for netcdf.']);
   end
end

