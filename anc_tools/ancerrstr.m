function err_str = ancerrstr(ancerr);
% err_str = ancerrstr(ancerr);

const_names = netcdf.GetConstantNames;
err_str = [];
pos = length(const_names);
while pos>0 && netcdf.GetConstant(char(const_names(pos)))~=ancerr 
   pos = pos -1;
end
if pos > 0
   err_str = const_names(pos);
else
   disp(['Unknown error: ',num2str(ancerr)]);
end
   
   
   
