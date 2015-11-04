%% varg_val(vargin, strname, defaultval) is an operator for varargin. It checks
%%   whether strname is present as an argument and, if so, returns the value. 
%%   If it is not present, returns defaultval.

function sval = varg_val(vargin, strname, defaultval)
   if nargin<3
       defaultval=NaN;
   end
   
   varnames = vargin(1:2:length(vargin));
   strloc = (find(strcmp(varnames, strname)));
   if length(strloc)==0
       sval = defaultval;
   else
       sval = vargin(((strloc-1)*2)+2);
       sval = cell2mat(sval(1));
   end

return
   
  