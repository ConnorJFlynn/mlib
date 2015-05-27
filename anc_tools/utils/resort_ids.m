
function elems = resort_ids(elems,inds)
% elems = resort_ids(elems,inds)
% Re-sorts IDs occording to id field or in terms of indices in optional 'inds'
% and renumbers from 0:(length(ids)-1)
% Initialize ID values if not already existing.
% 2006-03-13 CJF: modified to use id_list
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: resort_ids.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: resort_ids.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/03/19 21:57:28  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:20  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.6  2006/06/19 18:43:01  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------
ids = id_list(elems);
fields = fieldnames(elems);

if ~exist('inds','var')||(length(inds)~=length(fields))
   elems = init_ids(elems);
   ids = id_list(elems);
   [ids, inds] = sort(ids);
end

elems = orderfields(elems,inds); % 1-based indexing for matlab
fields = fieldnames(elems);
for n = 1:length(fields)
   elems.(fields{n}).id = n-1; % 0-based indexing for netcdf
end

return
