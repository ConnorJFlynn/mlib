function data_id = datatype_to_id(dtype)
nc_datatypes = {'char','byte','short','int','float','double'};
if exist('dtype','var') & any(strcmp(nc_datatypes,dtype))
   data_id = find(strcmp(nc_datatypes,dtype));
else
   disp('datatype_to_id did not find a matching netcdf datatype, defaulting to "char"')
   data_id = 1;
end

return