
function [nc1, nc2] = ancsift (nc, dim, dim_indices)

% [NC1, NC2] = ANCSIFT (NC, DIM, DIM_INDICES)
%
%   Separates the input struct NC into two netcdf structs NC1 & NC2, one
%   containing all input dimension indices and the other containing the
%   complement.
%
%   NC: netcdf struct to split.
%   DIM: dimension struct used for splitting NC.
%   DIM_INDICES: array of dimension indices to keep in NC1 and the complement
%     of which to keep in NC2.
%
%   For example,
%
%   [nc1, nc2] = ancsift(nc, nc.dims.time, [1:30,35,40:82]);
%
%   TODO: consider what will happen if only one index is chosen (dimension
%   will disappear altogether).
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCSPLIT, ANCLINK, ANCSAVE, ANCGETDATA, ANCSTRUCT.
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
A = 1:dim.length;
if islogical(dim_indices)
   inds1 = find(dim_indices);
else
   inds1 = dim_indices;
end
% inds1 = find(dim_indices);
inds2 = setdiff(A, inds1);

dimnames = fieldnames(nc.dims);
dimname = '';
for d = 1:length(dimnames)
    dimension = nc.dims.(dimnames{d});
    if (dimension.id == dim.id)
        dimname = dimnames{d};
    end
end

nc1 = ancsubset(nc, dimname, inds1);
nc2 = ancsubset(nc, dimname, inds2);

return

function ncout = ancsubset (ncin, dimname, indices)
% Performs subset function on set of indices.

ncout = ncin;

% Update internal dimension info.
ncout.dims.(dimname).length = length(indices);
if (strcmp(dimname, ncout.recdim.name))
    ncout.recdim.length = length(indices);
end

% Handle time special case.
if (strcmp(dimname, 'time') & isfield(ncout, 'time'))
    ncout.time = ncout.time(indices);
end

% Slice variables.
varnames = fieldnames(ncout.vars);
for v = 1:length(varnames)
    variable = ncout.vars.(varnames{v});

    % Determine subset reference struct.
    S.type = '()';
    S.subs = cell(0);
    dosubset = false;
    dd = 1;
    for d = 1:ndims(variable.data)
        if (size(variable.data,d) == 1)
            S.subs{d} = ':';
            continue;
        end
        if (strcmp(variable.dims{dd},dimname))
            S.subs{d} = indices;
            dosubset = true;
        else
            S.subs{d} = ':';
        end
        dd = dd + 1; % increment counter for dim names array.
    end

    % Do subset calculation.
    if (dosubset == true)
        ncout.vars.(varnames{v}).data = subsref(variable.data, S);
    end
end

return
