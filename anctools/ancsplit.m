
function [nc1, nc2] = ancsplit (nc, dim, dim_index)

% [NC1, NC2] = ANCSPLIT (NC, DIM, DIM_INDEX)
%
%   Returns two nc_structs formed by splitting the input struct NC at the
%   specified dimension index.  The first struct nc1 contains all values with
%   dim index <= the specified index value.  If either struct contains zero
%   records, it is still returned as a fully-qualified nc_struct but with the
%   dimension length set to zero for recdim or [] for non-recdim.
%
%   NC: netcdf struct to split.
%   DIM: dimension struct used for splitting NC.
%   DIM_INDEX: dimension index along which to split the struct.
%
%   For example,
%
%   [nc1, nc2] = ancsplit(nc, 'time', 84);
%
%   TODO: consider what will happen if only one index is chosen (dimension
%   will disappear altogether).
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCSIFT, ANCLINK, ANCSAVE, ANCGETDATA, ANCSTRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancsplit.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancsplit.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:19  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.2  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

[nc1, nc2] = ancsift(nc, dim, [1:dim_index]);

return
