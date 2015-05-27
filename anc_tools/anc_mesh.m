
function [nc] = anc_mesh (nc1, nc2, dimname)

% [NC] = ANCMESH (NC1, NC2, DIMNAME)
%
%   Combines the two input structs along the specified dimension
%   into a single struct.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
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
    nc = anc_cat(nc1, nc2);
    return
end

% Initialize output structure to first input.
nc = nc1;

if (~isfield(nc1.ncdef.dims,dimname) || ~isfield(nc2.ncdef.dims,dimname))
    error('Dimension "%s" does not exist in one or both input structures', dimname);
end

if (~isfield(nc1.ncdef.vars,dimname) || ~isfield(nc2.ncdef.dims,dimname))
    error('Coordinate field "%s" does not exist in one or both input structures (try using anc_check to fix this)', dimname);
end

% Vertically concatenate coordinate values.
coords = [nc1.vdata.(dimname);nc2.vdata.(dimname)];
[coords, sortinds] = sort(coords);

% Check for monotonic decreasing coordinate field (do reverse sort).
if (nc1.vdata.(dimname)(1) > nc1.vdata.(dimname)(2))
    coords = flipud(coords);
    sortinds = flipud(sortinds);
end

nc.vdata.(dimname) = coords;
nc.ncdef.dims.(dimname).length = length(coords);

varnames = fieldnames(nc1.ncdef.vars);
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
    v1 = nc1.ncdef.vars.(varnames{v});
    vdata1 = nc1.vdata.(varnames{v});
    if (isfield(nc2.ncdef.vars, varnames{v}))
        v2 = nc2.ncdef.vars.(varnames{v});
        vdata2 = nc2.vdata.(varnames{v});
        if (length(v1.ncdef.dims) == length(v2.ncdef.dims))
            domesh = false;
            for d = 1:length(v1.ncdef.dims)
                if (~strcmp(v1.ncdef.dims{d},v2.ncdef.dims{d}))
                    domesh = false;
                    break;
                end
                if (strcmp(v1.ncdef.dims{d},dimname))
                    dimindex = d;
                    domesh = true;
                end
            end
            if (domesh == true)
                !! in progress
                nd = ndims(vdata1);
                dimdiff = (size(vdata1) == size(vdata2));
                dimdiff(dimindex) = 1;
                dimcomp = ones(1,nd);
                domesh = (dimdiff == dimcomp);
                if (domesh == true)
                    % Rotate dimensions so mesh dim is first (necessary for vertcat).
                    dimrotate = (dimindex-1);
                    vdata1 = shiftdim(vdata1, dimrotate);
                    vdata2 = shiftdim(vdata2, dimrotate);
                    % Determine subset reference struct (for sorting along input dim in first position).
                    S.type = '()';
                    S.subs = cell(0);
                    S.subs{1} = sortinds;
                    for d = 2:length(v1.dims)
                        S.subs{d} = ':';
                    end
                    % Vertically concatenate data arrays.
                    %disp(['Combining field: ', varnames{v}]);
                    nc.vdata.(varnames{v}) = subsref([vdata1;vdata2], S);
                    % Undo dim rotation.
                    nc.vdata.(varnames{v}) = shiftdim(nc.vdata.(varnames{v}), (nd-dimrotate));
                end
            end
        end
    end
end

return
