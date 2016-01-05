
function [elem,elemname] = getnextelem (sarray,id)

% Returns element with ID closest (going up) to input ID.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: getnextelem.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: getnextelem.m,v $
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
%   Revision 1.5  2006/06/19 18:43:01  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

elem = [];
elemname = '';

i = 1;
nextlist = [];
fields = fieldnames(sarray);
for q = 1:length(fields)
    key = fields{q};
    val = sarray.(key);
    if (val.id >= id)
        nextlist(i) = val.id;
        i = i+1;
    end
end

if (length(nextlist) == 0)
    return;
end

nextlist = sort(nextlist);

nextid = nextlist(1);
fields = fieldnames(sarray);
for q = 1:length(fields)
    key = fields{q};
    val = sarray.(key);
    if (val.id == nextid)
        elem = val;
        elemname = key;
        status = 0;
        return;
    end
end

return
