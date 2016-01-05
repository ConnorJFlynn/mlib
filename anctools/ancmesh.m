
function [nc] = ancmesh (nc1, nc2, dimname)

% [NC] = ANCMESH (NC1, NC2, DIMNAME)
%
%   Combines the two input structs along the specified dimension
%   into a single struct.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCSIFT, ANCLINK, ANCSAVE, ANCGETDATA, ANCSTRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancmesh.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancmesh.m,v $
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
%   Revision 1.4  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.3  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

if (strcmp(dimname, 'time'))
    % ANCCAT handles combining along time dimension.
    nc = anccat(nc1, nc2);
    return
end

% Initialize output structure to first input.
nc = nc1;

if (~isfield(nc1.dims,dimname) || ~isfield(nc2.dims,dimname))
    error('Dimension "%s" does not exist in one or both input structures', dimname);
end

if (~isfield(nc1.vars,dimname) || ~isfield(nc2.dims,dimname))
    error('Coordinate field "%s" does not exist in one or both input structures (try using anccheck to fix this)', dimname);
end

% Vertically concatenate coordinate values.
coords = [nc1.vars.(dimname).data;nc2.vars.(dimname).data];
[coords, sortinds] = sort(coords);

% Check for monotonic decreasing coordinate field (do reverse sort).
if (nc1.vars.(dimname).data(1) > nc1.vars.(dimname).data(2))
    coords = flipud(coords);
    sortinds = flipud(sortinds);
end

nc.vars.(dimname).data = coords;
nc.dims.(dimname).length = length(coords);

varnames = fieldnames(nc1.vars);
for v = 1:length(varnames)
    % Skip time fields (only applicable to ANCCAT).
    if (strcmp(varnames{v},'time') | strcmp(varnames{v},'base_time') | strcmp(varnames{v},'time_offset'))
        continue;
    end
    
    % Skip coordinate field (already combined).
    if (strcmp(varnames{v},dimname))
        continue;
    end

    % Make sure compatible variable exists in second struct.
    v1 = nc1.vars.(varnames{v});
    if (isfield(nc2.vars, varnames{v}))
        v2 = nc2.vars.(varnames{v});
        if (length(v1.dims) == length(v2.dims))
            domesh = false;
            for d = 1:length(v1.dims)
                if (~strcmp(v1.dims{d},v2.dims{d}))
                    domesh = false;
                    break;
                end
                if (strcmp(v1.dims{d},dimname))
                    dimindex = d;
                    domesh = true;
                end
            end
            if (domesh == true)
                nd = ndims(v1.data);
                dimdiff = (size(v1.data) == size(v2.data));
                dimdiff(dimindex) = 1;
                dimcomp = ones(1,nd);
                domesh = (dimdiff == dimcomp);
                if (domesh == true)
                    % Rotate dimensions so mesh dim is first (necessary for vertcat).
                    dimrotate = (dimindex-1);
                    v1.data = shiftdim(v1.data, dimrotate);
                    v2.data = shiftdim(v2.data, dimrotate);
                    % Determine subset reference struct (for sorting along input dim in first position).
                    S.type = '()';
                    S.subs = cell(0);
                    S.subs{1} = sortinds;
                    for d = 2:length(v1.dims)
                        S.subs{d} = ':';
                    end
                    % Vertically concatenate data arrays.
                    %disp(['Combining field: ', varnames{v}]);
                    nc.vars.(varnames{v}).data = subsref([v1.data;v2.data], S);
                    % Undo dim rotation.
                    nc.vars.(varnames{v}).data = shiftdim(nc.vars.(varnames{v}).data, (nd-dimrotate));
                end
            end
        end
    end
end

return
