
function status = anc_save (ncstruct, ncfile)

% status = anc_SAVE (ncstruct, ncfile)
%
%   Writes an input netcdf structure to the specified file.  By default
%   Matlab sorts all structure elements alphabetically, but ancsave writes
%   the elements according to the ID stored for each element.  So in
%   theory the elements should be written in the same order as the
%   original file (unless the IDs are altered).
%
%   If only certain elements are to be written to file, simply add or
%   change the field 'keep' to read false for those undesired elements.
%   By default, if the field does not exist, the element is kept.
%
%   Also, to force the overwrite of an existing file using ancsave, set
%   or change the field 'clobber' inside of the netcdf structure to
%   read true.
%
%   For example,
%
%   mfr = ancload('mfrsr.nc') Populates ncstruct, 'mfr' (with data)
%   mfr.vars.hemisp_broadband.keep = false;
%   mfr.clobber = true;
%   ancsave(mfr, 'newfile.nc')
%     > All data except hemisp_broadband written to 'newfile.nc'
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also anc_LINK, anc_SAVE, anc_GETDATA, anc_STRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancsave.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancsave.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.3  2008/02/04 18:55:22  cflynn
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
%   Revision 1.16  2006/08/18 22:49:03  cflynn
%   Handled case with no unlim dim defined
%
%   Revision 1.15  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.14  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

status = 1;
if (nargin < 1 || nargin > 2)
    help anc_save;
    return;
elseif nargin == 1
    ncfile = ncstruct.fname;
end

quiet = false;
if isfield(ncstruct,'quiet')
   quiet = ncstruct.quiet;
end

cmode = 'nc_noclobber';
if (isfield(ncstruct,'clobber') && ncstruct.clobber == true)
    cmode = 'nc_clobber';
end
try
   ncid = netcdf.create(ncfile, cmode);
catch ME
   status = status -1;
   disp(['ancSAVE: Cannot create file: ',ncfile]);
   return;
end

% Write global attributes.
if (isfield(ncstruct,'gatts'))
    % TODO: Set ARM globals (e.g. history, version).

    nextid = 0;
    ncstruct.ncdef.atts = init_ids(ncstruct.ncdef.atts);
    while (true)

        % Get element by next id.
        [val,key] = getnextelem(ncstruct.ncdef.atts,nextid)        
        if (strcmp(key,''))
            break;
        end
        dat = ncstruct.gatts.(key);
        nextid = val.id+1;

        if (isfield(val,'keep') == false || (isfield(val,'keep') && val.keep == true))
            key = undolegalize(key);
            if (~isfield(val,'datatype'))
               val = anc_fixdatatype(val, dat);
%                 if ischar(val.data)
%                     val.datatype = 2;
%                 else
%                     val.datatype = 5;
%                 end
            end
            if isempty(dat)
               dat = sprintf('\n');
            end
            try
            netcdf.putAtt(ncid,netcdf.getConstant('GLOBAL'),key,dat);
            catch ME
               disp(ME.message)
               status = status -1;
                handle_error(ncid);
                return;
            end
        end
    end
end

% Define dimensions.
if (isfield(ncstruct.ncdef,'dims'))
    unlimid = -1;
    nextid = 0;
    ncstruct.ncdef.dims = init_ids(ncstruct.ncdef.dims);
    while (true)

        % Get element by next id.
        [val,key] = getnextelem(ncstruct.ncdef.dims,nextid);
        if (strcmp(key,''))
            break;
        end
        nextid = val.id+1;

        dlength = val.length;
        if isfield(ncstruct.ncdef, 'recdim')
            if (val.id == ncstruct.ncdef.recdim.id)
                dlength = 0;
            end
        end
        if isfield(val, 'isunlim')
            if (val.isunlim)
                dlength = 0;
            end
        end

        if (isfield(val,'keep') == false || (isfield(val,'keep') && val.keep == true))
            key = undolegalize(key);
            try
            dimid = netcdf.defDim(ncid,key,dlength);
            catch ME
               disp(ME.message);
               status = status -1;
                disp(['ancSAVE: Cannot define dimension: ',key]);
                handle_error(ncid);
                return;
            end

            if ~isfield(val, 'isunlim')
               val.isunlim = false;
            elseif (val.isunlim == true)
                unlimid = dimid;
            end
        end
    end
end

% Define variables and write attributes.
if (isfield(ncstruct.ncdef,'vars'))
    nextid = 0;
    ncstruct.ncdef.vars = init_ids(ncstruct.ncdef.vars);
    while (true)

        % Get element by next id.
        [val,key] = getnextelem(ncstruct.ncdef.vars,nextid);
        if (strcmp(key,''))
            break;
        end
        data = ncstruct.vdata.(key);        
        nextid = val.id+1;

        if (isfield(val,'keep') == false || (isfield(val,'keep') && val.keep == true))

            % Determine new dimension ids.
            if ~quiet 
               disp(['Defining variable: ', key]); 
            end
            clear dimids start count;
            dimids = [];
            start = [0];
            count = [1];
            ndims = 0;
            if (isfield(val,'dims'))
                if ~isempty(val.dims)&&(~isempty(val.dims{1}))
                    ndims = length(val.dims);
                end
            end
%             val.dims = fliplr(val.dims); % undo flip when variable data was read.
            for d = 1:ndims
                start(d) = 0;
                count(d) = -1;
                dimids(d) = netcdf.inqDimID(ncid,val.dims{d});
                if (dimids(d) == unlimid)
                    count(d) = ncstruct.ncdef.dims.(val.dims{d}).length;
                end
            end

            key = undolegalize(key);

            % Define variable.
            % for debugging... disp([key, num2str(val.datatype), num2str(ndims), num2str(dimids)]);

            try
               vid = netcdf.defVar(ncid,key,val.datatype,dimids);
            catch ME
               disp(ME.message);
               status = status-1;
               disp(['ancSAVE: Cannot define variable: ',key]);
               handle_error(ncid);
               return;
            end

            ncstruct.ncdef.vars.(key).id = vid;

            % Write attributes.
            if (isfield(val,'atts'))
                nextattid = 0;
                val.atts = init_ids(val.atts);
                while (true)
                    % Get element by next id.
                    [aval,akey] = getnextelem(val.atts,nextattid);
                    if (strcmp(akey,''))
                        break;
                    end
                    adata = ncstruct.vatts.(key).(akey);                    
                    nextattid = aval.id+1;

                    if (isfield(aval,'keep') == false || (isfield(aval,'keep') && aval.keep == true))
                        akey = undolegalize(akey);
                        if ~isfield(aval,'datatype')
                            if ischar(adata)
                                aval.datatype = 2;
                            else
                                aval.datatype = 5;
                            end
                        end
                        try
                           netcdf.putAtt(ncid,vid,akey,adata)
                        catch ME
                           disp(ME.message);
                           status = status -1;
                        
                            disp(['ancSAVE: Cannot write attribute: ',key,':',akey]);
                            handle_error(ncid);
                            return;
                        end
                    end
                end
            end
        end
    end
end

% Enter data mode.
netcdf.endDef(ncid);

% Write variable data.
if (isfield(ncstruct.ncdef,'vars'))
    nextid = 0;
    ncstruct.ncdef.vars = init_ids(ncstruct.ncdef.vars);
    while (true)

        % Get element by next id.
        [val,key] = getnextelem(ncstruct.ncdef.vars,nextid);
        if (strcmp(key,''))
            break;
        end
        nextid = val.id+1;
        data = ncstruct.vdata.(key);        
        if (isfield(val,'keep') == false || (isfield(val,'keep') && val.keep == true))

            % Determine new dimension ids.
            if ~quiet 
               disp(['Writing data: ', key]); 
            end
            clear dimids start count;
%             dimids = [];
            start = [0];
            count = [1];
            ndims = 0;
            if (isfield(val,'dims'))
                if ~isempty(val.dims)&&~isempty(val.dims{1})
                    ndims = length(val.dims);
                end
            end
%             val.dims = fliplr(val.dims); % flip dimensions because matlab read in reverse.
            for d = 1:ndims
                start(d) = 0;
                count(d) = ncstruct.ncdef.dims.(val.dims{d}).length;
            end

            key = undolegalize(key);
            td = [];
            s = 0;
            if ~any(size(data)==0)
               if (ndims == 0)
                  try
                     netcdf.putVar(ncid,val.id,data)
                  catch ME
                     disp(ME.message);
                     status = status -1;
                     s = s -1;
                     return;
                  end
                  td = netcdf.getVar(ncid,val.id);
               else
                  try
                     netcdf.putVar(ncid,val.id,start,count,data);
                  catch ME
                     disp(ME.message);
                     status = status -1;
                     s = s -1;
                     return
                  end
                  td = netcdf.getVar(ncid,val.id,start,count);
               end
            else
               s = 0;
            end

            % Make sure data was successfully saved to file.
            if (s ~= 0)
                disp(['ancSAVE: Error re-reading variable data for verification: ',key]);
            else
                if (ndims == 1)
                    if (ncstruct.ncdef.dims.(val.dims{1}).isunlim == true)
                        % Re-orient single-dim, record fields as in ancgetdata.
                        td = td'; %'
                    end
                end
                if numel(data)>0 && numel(td)>0
                if (any((data ~= td)&((~isnan(data))|(~isnan(td)))))
                    disp(['ancSAVE: WARNING: Possible data truncation for variable: ',key]);
                end
                end
            end
        end
    end
end
netcdf.close(ncid);

return


function handle_error(ncid)
% Procedure for handling errors.

netcdf.close(ncid);

return


function oldname = undolegalize(newname)
% Undo name legalization from anclink.

oldname = strrep(newname,'__dash__','-');
oldname = strrep(oldname,'__space__',' ');
oldname = strrep(oldname,'underbar__','_');

return

