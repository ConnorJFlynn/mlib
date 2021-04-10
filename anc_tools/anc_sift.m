
function [nc1, nc2] = anc_sift (nc, dim_indices,  dim)

% [NC1, NC2] = ANC_SIFT (NC, DIM_INDICES, DIM)
%
%   Separates the input struct NC into two netcdf structs NC1 & NC2, one
%   containing all input dimension indices and the other containing the
%   complement.
%
%   NC: netcdf struct to split.
%   DIM_INDICES: array of dimension indices to keep in NC1 and the complement
%     of which to keep in NC2.
%   DIM: dimension struct used for splitting NC. DEFAULT is RECDIM, 0th DIM
%
%   For example,
%
%   [nc1, nc2] = ancsift(nc, [1:30,35,40:82], nc.dims.time);
%
%   TODO: consider what will happen if only one index is chosen (dimension
%   will disappear altogether).
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANC_SPLIT, ANC_LINK, ANC_SAVE, ANC_GETDATA, ANC_STRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancsift.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancsift.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/02/04 18:55:22  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:19  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.8  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.7  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

% Determine complement of input dimension indices.
if isempty(who('dim'))
    if isfield(nc.ncdef,'recdim')&&~isempty(nc.ncdef.recdim.name)
        dim = nc.ncdef.dims.(nc.ncdef.recdim.name);
    else
        dims = fieldnames(nc.ncdef.dims);
        dim = nc.ncdef.dims.(dims{1});
    end
end
    
A = 1:dim.length;
if islogical(dim_indices)
   inds1 = find(dim_indices);
else
   inds1 = dim_indices;
end
% inds1 = find(dim_indices);
inds2 = setdiff(A, inds1);

dimnames = fieldnames(nc.ncdef.dims);
dimname = '';
for d = 1:length(dimnames)
    dimension = nc.ncdef.dims.(dimnames{d});
    if (dimension.id == dim.id)
        dimname = dimnames{d};
    end
end

nc1 = anc_subset(nc, dimname, inds1);
nc2 = anc_subset(nc, dimname, inds2);

return

function ncout = anc_subset (ncin, dimname, indices)
% Performs subset function on set of indices.

ncout = ncin;

% Update internal dimension info.
ncout.ncdef.dims.(dimname).length = length(indices);
if isfield(ncout.ncdef,'recdim')&&(strcmp(dimname, ncout.ncdef.recdim.name))
    ncout.ncdef.recdim.length = length(indices);
end

% Handle time special case.
if (strcmp(dimname, 'time') && isfield(ncout, 'time'))
    ncout.time = ncout.time(indices);
end

% Slice variables.
varnames = fieldnames(ncout.vdata);
for v = 1:length(varnames)
    var = ncout.vdata.(varnames{v});
    vdef = ncout.ncdef.vars.(varnames{v});

    % Determine subset reference struct.
    S.type = '()';
    S.subs = cell(0);
    dosubset = false;
    dd = 1;
    for d = 1:ndims(var)
        if (size(var,d) == 1)
            S.subs{d} = ':';
            continue;
        end
        if (strcmp(vdef.dims{dd},dimname))
            S.subs{d} = indices;
            dosubset = true;
        else
            S.subs{d} = ':';
        end
        dd = dd + 1; % increment counter for dim names array.
    end

    % Do subset calculation.
    if (dosubset == true)
        ncout.vdata.(varnames{v}) = subsref(var, S);
    end
end

return
