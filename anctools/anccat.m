
function [nc1] = anccat (nc1, nc2)

% [NC] = ANCCAT (NC1, NC2)
%
%   Combines the two input structs into a single struct.  This assumes that
%   the inputs are of the same data element structure, and that the time
%   dimension is the last for each record field.  The two structs are
%   combined along the unlimited (time) dimension.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCSIFT, ANCLINK, ANCSAVE, ANCGETDATA, ANCSTRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anccat.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anccat.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:28  cflynn
%   *** empty log message ***
%
%   Revision 1.3  2008/10/27 22:14:17  cflynn
%   Finally completing some of the static DOD and ancwrite stuff.
%
%   Revision 1.2  2008/02/20 00:01:37  cflynn
%   Fixed ancat ndim problem
%
%   Revision 1.1  2007/11/09 01:24:19  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.10  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.9  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

% Initialize output structure to first input.
% Horizontally concatenate time values.
nc1.time = [nc1.time nc2.time];
[nc1.time, sortinds] = unique(nc1.time);

nc1 = timesync(nc1);

varnames = fieldnames(nc1.vars);
for v = 1:length(varnames)
    % Skip time fields (have already been synchronized).
    if (~strcmp(varnames{v},'time') && ~strcmp(varnames{v},'base_time') && ~strcmp(varnames{v},'time_offset'))
        v1 = nc1.vars.(varnames{v});
        % Make sure compatible variable exists in second struct.
        if (isfield(nc2.vars, varnames{v}))
            v2 = nc2.vars.(varnames{v});
            catdim = find(strcmp(v1.dims,nc1.recdim.name));
            if catdim ==1
                [v1.data,NSHIFTS] = shiftdim(v1.data,catdim-1);
                [v2.data,NSHIFTS] = shiftdim(v2.data,catdim-1);
                v1.data = [v1.data, v2.data];
                v1.data = v1.data(:,sortinds);
                [v1.data] = shiftdim(v1.data,NSHIFTS);
                nc1.vars.(varnames{v}) = v1;
            elseif catdim > 1
                [v1.data,NSHIFTS] = shiftdim(v1.data,catdim-1);
                [v2.data,NSHIFTS] = shiftdim(v2.data,catdim-1);
                v1.data = [v1.data; v2.data];
                v1.data = v1.data(sortinds,:);
                [v1.data] = shiftdim(v1.data,NSHIFTS);
                nc1.vars.(varnames{v}) = v1;

            end
        end
    end
end

return
