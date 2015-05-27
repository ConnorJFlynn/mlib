
function anc_list (cdf)

% ANC_LIST (ancstruct)
%
%   Provides a summarized list of variable information contained in
%   in the input ancstruct.
%
%   FORMAT:
%   var name.............(nc dims)....(matlab dims)
%   ...
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCCHECK, ANCDIFF.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anclist.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anclist.m,v $
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
%   Revision 1.8  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

% Should check be run first?
%[cdf, status] = anccheck(cdf);
%if (status ~= 0)
%    disp('One or more elements failed check.');
%    return;
%end

vars = fieldnames(cdf.ncdef.vars);

maxnamelength = 0;
for v = 1:length(vars)
    strlen = length(vars{v});
    if (strlen > maxnamelength)
        maxnamelength = strlen;
    end
end

maxdimlength = 0;
for v = 1:length(vars)
    var = cdf.ncdef.vars.(vars{v});
    vdata = cdf.vdata.(vars{v});
    dimstring{v} = '(';
    for d = 1:length(var.dims)
        dname = var.dims{d};
        if (length(dname) > 0)
            dimlen = cdf.ncdef.dims.(dname).length;
            dimstring{v} = strcat(dimstring{v}, [dname, '[', num2str(dimlen), ']']);
            if (d < length(var.dims))
                dimstring{v} = strcat(dimstring{v}, ', ');
            end
        end
    end
    dimstring{v} = strcat(dimstring{v}, ')');

    strlen = length(dimstring{v});
    if (strlen > maxdimlength)
        maxdimlength = strlen;
    end

    orientation{v} = '(';
    sizearray = size(vdata);
    orientation{v} = strcat(orientation{v}, [num2str(sizearray(1)), 'r x']);
    for d = 2:length(sizearray)
        orientation{v} = strcat(orientation{v}, [' ', num2str(sizearray(d)), 'c']);
        if (d < length(sizearray))
            orientation{v} = strcat(orientation{v}, ' x');
        end
    end
    orientation{v} = strcat(orientation{v}, ')');
end

for v = 1:length(vars)
    namelen = length(vars{v});
    dimlength = length(dimstring{v});
    disp(['   ', vars{v}, getlead((maxnamelength - namelen) + 8, '.'), dimstring{v}, getlead((maxdimlength - dimlength) + 2, '.'), orientation{v}]);
end

return

function [str] = getlead(num, leadchar)

str = '';
for c = 1:num
    str = strcat(str,leadchar);
end

return
