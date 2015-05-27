
function ids = id_list(elems)

% Returns list of unique IDs
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: id_list.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: id_list.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
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

ids = [];
fields = fieldnames(elems);
for q = 1:length(fields)
    key = fields{q};
    val = elems.(key);
    if isfield(val,'id')
        ids = [ids, val.id];
%         ids = unique([ids, val.id]);
    end
end

return
