
function [typestr] = anctype (typenum, isvar)

% [TYPESTR] = ANCTYPE (TYPENUM)
%
%   Converts the input data type numeric value into its
%   equivalent netcdf name.
%
%   Example: str = anctype(2);
%     str => 'NC_CHAR'
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCLINK, ANCSAVE, ANCGETDATA, ANCSTRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anctype.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anctype.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/01/15 23:30:23  cflynn
%   Improved data and datatype compatibility.
%
%   Revision 1.1  2007/11/09 01:24:20  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.8  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

typestr = 'NC_NAT';

% Library constants.
nctypes = {'NC_BYTE', 'NC_CHAR', 'NC_SHORT', 'NC_INT', 'NC_FLOAT', 'NC_DOUBLE'};

types = nctypes;
if (nargin > 1) 
    % For attributes.
    types = {'uchar', 'text', 'short', 'int', 'float', 'double'};
    if (isvar == true)
        % For variables.
        % For some reason, casting doubles to floats is not working.
        % CJF: it works, but you need to cast the data values as well.
        types = {'uchar', 'text', 'short', 'int', 'float', 'double'};
    end
end
for i = 1:length(types)
    % This function is actually deprecated, but still works.
    t = netcdf.getConstant(nctypes{i});
    if (t == typenum)
        typestr = types{i};
    end
end

return
