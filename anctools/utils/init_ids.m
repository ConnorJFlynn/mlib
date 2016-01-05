
function elems = init_ids(elems)

% Initialize ID values if not already existing.
% 2006-03-13 CJF: modified to use id_list
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: init_ids.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: init_ids.m,v $
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

% Insert default ID field.
field.names = fieldnames(elems);
for q = 1:length(field.names)
    key = field.names{q};
    val = elems.(key);
    if (~isfield(val,'id'))
        id = ceil(max(id_list(elems))) + 1;
        if isempty(id)
            id = 0;
        end
        elems.(key).id = id;
    end
    field.ids(q) = elems.(key).id;
end

% Check for duplicate IDs.
if isfield(field,'ids')
    if (length(field.ids) > length(unique(field.ids)))
        %disp(' > Fixing duplicate IDs');
        n = length(field.ids);
        [sorted, index] = sort(field.ids);
        for i = 1:n
            elem_name = field.names{index(i)};
            elems.(elem_name).id = i-1;
        end
    end
end
return
