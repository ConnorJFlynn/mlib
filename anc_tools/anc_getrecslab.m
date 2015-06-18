
function [vdata,status] = ancgetrecslab (cdf, var,rec_start,rec_count)

% [vdata, status] = ANCGETRECSLAB (cdf, var, start,count)
%
%   Retrieves slab of record variable data for a specified variable (by ID or name).
%   The input 'cdf' must have already been populated by calling
%   ancLOADCOORDS (which grabs all static data 
%   If 'status' is non-zero, an error has occurred.
%
%   For example,
%
%   mfr = ancLINK('mfrsr.nc') populates ancstruct, 'mfr'
%   data = ancGETDATA(mfr,'hemisp_broadband') returns var data as vector
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ancSTRUCT, ancLINK, ancLOAD, ancSAVE.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancgetrecslab.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancgetrecslab.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:28  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2009/02/27 16:59:25  cflynn
%   wide ranging add/commit from Connor's sandbox to repository
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

status = 0;

if (nargin < 2)
    help ancgetrecslab;
    return;
end
if ~exist('rec_start','var')
   rec_start = 0;
end
if ~exist('rec_count','var');
   rec_count = cdf.ncdef.recdim.length;
end

varid = -1;
varname = 'unknown';
datatype = -1; 
dimids = [];
if (isnumeric(var) == 0)
    varname = var;
    if isfield(cdf.ncdef.vars,var)
        varid = cdf.ncdef.vars.(var).id;
        datatype = cdf.ncdef.vars.(var).datatype;
        dims = cdf.ncdef.vars.(var).dims;
    end
else
    varid = var;
    fields = fieldnames(cdf.vatts);
    for q = 1:length(fields)
        key = fields{q};
        val = cdf.vatts.(key);
        if (varid == val.id)
            varname = key;
            datatype = val.datatype;
            dims = val.dims;
        end
    end
end

unlimid = -1;
dimids = [];
for d = 1:length(dims)
    fields = fieldnames(cdf.ncdef.dims);
    for q = 1:length(fields)
        dkey = fields{q};
        dval = cdf.ncdef.dims.(dkey);
        if (dval.isunlim)
            unlimid = dval.id;
        end
        if (strcmp(dims{d},dkey))
            dimids(d) = dval.id;
            break;
        end
    end
end
try
   [ncid] = netcdf.open(cdf.fname,'nowrite');
catch ME
   status = status -1;
   disp(ME.message)
   return;
end
% [ncid,status] = mexnc('open',cdf.fname,'nc_nowrite_mode');
% if (status ~= 0)
%     disp(['MEXNC: ',mexnc('strerror', status)]);
%     disp(['Cannot open file: ',cdf.fname]);
%     return;
% end

start = [0];
count = [1];
nodata = false;
dimids = fliplr(dimids); % flip dimensions because matlab reads in reverse.
for d = 1:length(dimids);
    start(d) = 0;
%     [dimlength, status] = mexnc('inq_dimlen', ncid, dimids(d));
    [dimname, dimlength] = netcdf.inqDim(ncid,dimids(d));
    if (dimlength < 1)
        nodata = true;
    end
    count(d) = dimlength;
    if dimids(d)==unlimid
       start(d) = rec_start-1;
       count(d) = rec_count;
    else
       start(d) = 0;
       count(d) = dimlength;
    end
end
start = fliplr(start);
count = fliplr(count);

if (nodata)
    vdata = [];
    status = 0;
else
   try      
      if (length(dimids) == 0)
         vdata = netcdf.getVar(ncid,varid,start);
      else
         vdata = netcdf.getVar(ncid,varid,start,count);
         %         [vdata] = mexnc(['get_vara_',anctype(datatype,true)],ncid,varid,start,count);
         if (length(dimids) == 1)
            if (dimids(1) == unlimid && size(vdata,2) == 1)
               vdata = vdata'; % record vectors are column ordered.'
            elseif (dimids(1) ~= unlimid && size(vdata,1) == 1)
               vdata = vdata'; % non-record vectors are row ordered.'
            end
         end
      end
   catch ME
      status = status -1;
      disp(ME.message)
      return
   end
end
netcdf.close(ncid);

return

