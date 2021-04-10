
function [cdf,status] = anc_check (cdf)

% [cdf, status] = ANC_CHECK (ancstruct)
%
%   - Checks structure for required elements (dims, atts, vars)
%   - Checks the data element of each field for size consistent with the dims
%
%   Basically this will let you know when you've either forgotten to
%   populate a field, or have made a mistake in terms of the size/shape
%   of the data element.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANC_STRUCT, ANC_LIST, ANC_DIFF.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anccheck.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anccheck.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:28  cflynn
%   *** empty log message ***
%
%   Revision 1.4  2009/02/27 16:57:25  cflynn
%   wide ranging commit from Flynn sandbox to repository.
%
%   Revision 1.3  2008/03/31 08:41:54  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/01/15 23:30:23  cflynn
%   Improved data and datatype compatibility.
%
%   Revision 1.1  2007/11/09 01:24:19  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.21  2006/08/18 22:41:19  cflynn
%   Supported logical/boolean datatype
%
%   Revision 1.20  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.19  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

status = 0;
if (nargin ~= 1)
    help anccheck
    return;
end

q = isquiet(cdf);

% Check for first-level elements.
elements = {'fname' 'ncdef' 'gatts' 'vatts' 'vdata'};
for e = 1:length(elements)
    if ~isfield(cdf, elements{e})
        if strcmp(elements{e}, 'fname')
            cdf.fname = '';
        else
            cdf.(elements{e}) = struct;
        end
        dispmsg(q, 0, 'NCSTRUCT', elements{e}, 'Added');
        status = status + 1;
    end
end

% Check for elements within ncdef.
elements = {'atts' 'dims' 'recdim' 'vars'};
for e = 1:length(elements)
    if ~isfield(cdf.ncdef, elements{e})
            cdf.ncdef.(elements{e}) = struct;
        dispmsg(q, 0, 'NCSTRUCT ncdef.', elements{e}, 'Added');
        status = status + 1;
    end
end


if isempty(fieldnames(cdf.ncdef.recdim))
   disp('Populating empty recdim struct.')
   cdf.ncdef.recdim.name = {''};
   cdf.ncdef.recdim.length = 0;
   cdf.ncdef.recdim.id = [];
end

% Check dimensions.
dims = fieldnames(cdf.ncdef.dims);
cdf.ncdef.dims = init_ids(cdf.ncdef.dims);
elements = {'isunlim' 'length'};
for d = 1:length(dims)
    dim = cdf.ncdef.dims.(dims{d});
    for e = 1:length(elements)
        if ~isfield(dim, elements{e})
            cdf.ncdef.dims.(dims{d}).(elements{e}) = 0;
            dispmsg(q, 1, 'DIMENSION', dims{d}, ['Added "', elements{e}, '" element']);
            status = status + 1;
        end
        if (isempty(fieldnames(cdf.ncdef.recdim)) && dim.isunlim)
            cdf.ncdef.recdim = dim;
            cdf.ncdef.recdim.name = dims{d};
            dispmsg(q, 0, 'NCSTRUCT', 'recdim', 'Added details (name, id, length)');
            status = status + 1;
        end
    end

    % Check corresponding coordinate field.
    if (strcmp(dims{d}, 'time'))
        % Time special case is handled by 'synctime'.
        continue;
    end
    if (isfield(cdf.ncdef.vars, dims{d}))
        if (length(cdf.ncdef.vars.(dims{d}).dims) ~= 1)
            dispwarn('COORD VAR', dims{d}, 'Is not single-dimensioned');
            status = status + 1;
        end
        if (~strcmp(cdf.ncdef.vars.(dims{d}).dims{1}, dims{d}))
            dispwarn('COORD VAR', dims{d}, 'Is not appropriately dimensioned');
            status = status + 1;
        end
        if ~isempty(cdf.vdata.(dims{d}))
            vdata = cdf.vdata.(dims{d});
            diffs = diff(vdata);
            gtzero = length(find(diffs > 0));
            ltzero = length(find(diffs < 0));
            if (gtzero < (dim.length-1) && ltzero < (dim.length-1))
                dispwarn('COORD VAR', dims{d}, 'Is not monotonic');
                status = status + 1;
            end
            if (~isempty(find(isnan(vdata))) || ~isempty(find(vdata == -9999)))
                dispwarn('COORD VAR', dims{d}, 'Contains missing(s)');
                status = status + 1;
            end
        else
            if (dim.length > 0)
                cdf.vdata.(dims{d}) = 0:(dim.length-1);
                dispmsg(q, 1, 'COORD VAR', dims{d}, 'Added default data');
                status = status + 1;
            end
        end
    else
%         cdf.ncdef.vars.(dims{d}).dims = { dims{d} };
%         cdf.vdata.(dims{d}) = [];
%         if (dim.length > 0)
%             cdf.vdata.(dims{d}) = 0:(dim.length-1);
%         end
%         dispmsg(q, 1, 'COORD VAR', dims{d}, 'Added');
%         status = status + 1;
    end
end

% Check global attributes.
[cdf.ncdef.atts, cdf.gatts, status] = checkatts(q, 'global', cdf.ncdef.atts, cdf.gatts, status);

% Check variables.
if isfield(cdf, 'vars')
    vars = fieldnames(cdf.ncdef.vars);
    cdf.ncdef.vars = init_ids(cdf.ncdef.vars);
    for v = 1:length(vars)
%         vars(v)
        if ~isfield(cdf.vdata, vars{v})
            cdf.vdata.(vars{v}) = 0;
            dispmsg(q, 1, 'VARIABLE', vars{v}, 'Added default data');
            status = status + 1;
        end

        if ~isfield(cdf.ncdef.vars.(vars{v}), 'dims')
            if any(size(cdf.vdata.(vars{v})) == 1)
                % Assume uni-dimensional fields are against the unlimited dim.
                cdf.ncdef.vars.(vars{v}).dims = { cdf.ncdef.recdim.name };
                dispmsg(q, 1, 'VARIABLE', vars{v}, ['Set default dim to unlimited ', cdf.ncdef.recdim.name]);
                status = status + 1;
            end
        end

        if ~isfield(cdf.ncdef.vars.(vars{v}), 'datatype')
           cdf.ncdef.vars.(vars{v}) = anc_fixdatatype(cdf.ncdef.vars.(vars{v}),cdf.vdata.(vars{v}));
%             datatype = mexnc('PARAMETER', 'NC_FLOAT');
%             if all(islogical(cdf.ncdef.vars.(vars{v})))
%                datatype = mexnc('PARAMETER', 'NC_INT');
%             elseif all(cdf.vdata.(vars{v})== floor(cdf.vdata.(vars{v})))
%                 datatype = mexnc('PARAMETER', 'NC_INT');
%             end
%             cdf.ncdef.vars.(vars{v}).datatype = datatype;
            dispmsg(q, 1, 'VARIABLE', vars{v}, ['Set default datatype to ', anctype(cdf.ncdef.vars.(vars{v}).datatype)]);
            status = status + 1;
        end

        cdf.ncdef.vars.(vars{v}) = anccast2datatype(cdf.ncdef.vars.(vars{v}));
        
        if ~isfield(cdf.ncdef.vars.(vars{v}), 'atts')
            cdf.ncdef.vars.(vars{v}).atts = struct;
            dispmsg(q, 1, 'VARIABLE', vars{v}, 'Added "atts" element');
            status = status + 1;
        end

        if ~isfield(cdf.ncdef.vars.(vars{v}).atts, 'long_name')
            cdf.adata.(vars{v}).atts.long_name = vars{v};
            dispmsg(q, 2, 'ATTRIBUTE', [vars{v},':long_name'], 'Defined');
            status = status + 1;
        end

        if ~isfield(cdf.ncdef.vars.(vars{v}).atts, 'units')
            cdf.adata.(vars{v}).atts.units = 'unitless';
            dispmsg(q, 2, 'ATTRIBUTE', [vars{v},':units'], 'Defined');
            status = status + 1;
        end
[cdf.ncdef.atts, cdf.gatts, status] = checkatts(q, 'global', cdf.ncdef.atts, cdf.gatts, status);
        [cdf.ncdef.vars.(vars{v}).atts, status] = checkatts(q, vars{v}, cdf.ncdef.vars.(vars{v}).atts, status);
    end
end

% Check variable data-dimensionality consistency.
[cdf, status] = checkvardata(q, cdf, status);

% Check record dimension.
dims = fieldnames(cdf.ncdef.dims);
for d = 1:length(dims)
    dim = cdf.ncdef.dims.(dims{d});
    if dim.isunlim
        cdf.ncdef.recdim.name = dims{d};
        cdf.ncdef.recdim.id = dim.id;
        cdf.ncdef.recdim.length = dim.length;
        break;
    end
end

return


function [cdf, status] = checkvardata (q, cdf, status)
% Checks all variables for data-dimensionality consistency.

quiet = isquiet(cdf);

vars = fieldnames(cdf.ncdef.vars);
for v = 1:length(vars)
    if ~quiet disp(vars(v)); end
    variable = cdf.ncdef.vars.(vars{v});
    variable.data = cdf.vdata.(vars{v});
    nvardims = length(variable.dims);
    if (nvardims == 1)
        if (isempty(variable.dims{1}))
            nvardims = nvardims - 1; % scalar fields have empty string for dimension.
        end
    end
    dsize = size(variable.data);
%     vdims = length(variable.dims);
    dimels = 1;
    for vd = 1:nvardims
       dimels = dimels.*cdf.ncdef.dims.(variable.dims{vd}).length;
    end
    vels = numel(variable.data);
    

    % Check to see if data size agrees with dims cell array.
    if (dimels ~= vels)
        dispwarn('VARIABLE', vars{v}, 'Data size does not match dims array');
        status = status + 1;
        continue;
    end
    startstat = status;
    for d = 1:(nvardims-1)
        if (strcmp(variable.dims{d}, cdf.ncdef.recdim.name))
            dispwarn('VARIABLE', vars{v}, ['"',variable.dims{d},'" dimension must be last in dims array']);
            status = status + 1;
        end
    end
    if (status > startstat)
        continue;
    end
    
    if (nvardims == 1)
       if isfield(cdf.ncdef,'recdim')
        if ((strcmp(variable.dims{1},cdf.ncdef.recdim.name) && dsize(2) == 1) || (~strcmp(variable.dims{1},cdf.ncdef.recdim.name) && dsize(1) == 1))
%             cdf.vars.(vars{v}).data = cdf.vars.(vars{v}).data'; %'
            cdf.vdata.(vars{v}) = cdf.vdata.(vars{v})'; %'
            variable = cdf.ncdef.vars.(vars{v});
            variable.data = cdf.vdata.(vars{v});
            dispmsg(q, 1, 'VARIABLE', vars{v}, 'Single-dim record fields must be row vectors (non-record: column)');
            status = status + 1;
        end
       else
           !! % Will this ever run?
        if ((strcmp(variable.dims{1},cdf.ncdef.recdim.name) && dsize(2) == 1) || (~strcmp(variable.dims{1},cdf.ncdef.recdim.name) && dsize(1) == 1))
            cdf.vdata.(vars{v}) = cdf.vdata.(vars{v})'; %'
            variable = cdf.ncdef.vars.(vars{v});
            variable.data = cdf.vdata.(vars{v});
            dispmsg(q, 1, 'VARIABLE', vars{v}, 'Single-dim record fields must be row vectors (non-record: column)');
            status = status + 1;
        end          
       end
    end

    % Check field dimensionality against dims cell array.
    for d = 1:nvardims
        if (~isfield(cdf.ncdef.dims, variable.dims{d}))
            % Dimension does not exist.
            continue;
        end
        dim = cdf.ncdef.dims.(variable.dims{d});
        dindex = d;
        if (nvardims == 1 && dim.isunlim)
            % Single-dimensioned, unlimited vars are column ordered.
            dindex = dindex + 1;
        end
        datalength = size(variable.data, dindex);
        if (datalength > dim.length)
            cdf.ncdef.dims.(variable.dims{d}).length = datalength;
            dispmsg(q, 1, 'DIMENSION', variable.dims{d}, ['Changed length to ',num2str(datalength),', to match variable: ',vars{v}]);
            status = status + 1;

            % Run re-check to pad all fields affected by this dimension length increase.
            [cdf, status] = checkvardata(q, cdf, status);

            break;

        elseif (datalength < dim.length)&&(datalength > 0)
            needlength = dim.length;

            % Pad variable data with NaNs to meet dimension length.
            inds = size(variable.data);
            inds(dindex) = (needlength - datalength);
            pad = zeros(inds)*NaN;
            cdf.vdata.(vars{v}) = cat(dindex, variable.data, pad);

            % Reset variable struct so recent changes will be included.
            variable = cdf.ncdef.vars.(vars{v});
            variable.data = cdf.vdata.(vars{v});

            dispmsg(q, 1, 'VARIABLE', vars{v}, ['Padded with ',num2str(needlength - datalength),' NaNs to match dimension: ',variable.dims{d}]);
            status = status + 1;
        end
    end
end

% Handle time special case...
if isfield(cdf, 'time') & isfield(cdf.ncdef.dims, 'time')
    exlength = length(cdf.time);
    inlength = cdf.ncdef.dims.time.length;
    if (exlength > inlength)
        cdf.ncdef.dims.time.length = exlength;
        dispmsg(q, 1, 'DIMENSION', 'time', ['Changed length to ',num2str(exlength),', to match time field']);
        status = status + 1;

        % Run re-check to pad all fields affected by this dimension increase.
        [cdf, status] = checkvardata(q, cdf, status);

    elseif (exlength < inlength)
        % Remove time array so timesync will update it.
        cdf = rmfield(cdf, 'time');

        % Synchronize time difference (so internal fields are updated e.g. base_time, time_offset).
        cdf = timesync(cdf);

        dispmsg(q, 0, 'NCSTRUCT', 'time', 'Synchronized with internal time variable(s)');
    end
end

return


function [attstruct, adata, status] = checkatts(q, parent, attstruct, adata, status);
%[attstruct, status] = checkatts (q, parent, attstruct, status)
% Checks attributes.

% This function is actually deprecated but still works.
% chartype = mexnc('PARAMETER', 'NC_CHAR');
% chartype = netcdf.getConstant('NC_CHAR');
atts = fieldnames(attstruct);
attstruct = init_ids(attstruct);
elements = {'data', 'datatype'};
for a = 1:length(atts)
    att = attstruct.(atts{a});
        if ~isfield(adata, atts{a})
            adata.(atts{a}) = char(0);
            dispmsg(q, 2, 'ATTRIBUTE', [parent,':',atts{a}],  ['Added data element']);
            status = status + 1;
        end
        if ~isfield(att, 'datatype')
           attstruct.(atts{a}) = anc_fixdatatype(attstruct.(atts{a}),adata.(atts{a}));
%             attstruct.(atts{a}).datatype = 0;
            dispmsg(q, 2, 'ATTRIBUTE', [parent,':',atts{a}],  ['Added datatype element']);
            status = status + 1;
        end
%     
%     
%     for e = 1:length(elements)
%         if ~isfield(att, elements{e})
%             attstruct.(atts{a}).(elements{e}) = 0;
%             dispmsg(q, 2, 'ATTRIBUTE', [parent,':',atts{a}],  ['Added ', elements{e}, ' element']);
%             status = status + 1;
%         end
%     end
    
%     
%     att = attstruct.(atts{a});
%     istexttype = (att.datatype == chartype);
%     istext = ischar(att.data);
%     if (istexttype ~= istext)
%         attstruct.(atts{a}).datatype = chartype;
%         dispmsg(q, 2, 'ATTRIBUTE', [parent,':',atts{a}], 'Changed datatype to "char"');
%         status = status + 1;
%     end
end
return

function dispmsg(quiet, indent, element, name, message)
% Displays message if quiet global is not set.

spaces = ' ';
for i=0:indent
    spaces = [spaces, ' '];
end

if (~quiet)
    disp([spaces, '> ', upper(element), ' > ', upper(name), ': ', message]);
end

return


function dispwarn(element, name, message)
% Displays warning message.

disp(['WARNING > ', upper(element), ' > ', upper(name), ': ', message]);

return


function [quiet] = isquiet(cdf)
% Returns whether or not to suppress output messages.

quiet = false;
if (isfield(cdf,'quiet'))
    quiet = cdf.quiet;
end

return

