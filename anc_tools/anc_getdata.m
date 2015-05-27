
function [vdata,status] = anc_getdata (cdf, var)

% [vdata, status] = anc_GETDATA (cdf, var)
%
%   Retrieves variable data for a specified variable (by ID or name).
%   The input 'cdf' must have already been populated by calling
%   either ancLOAD (which grabs all variable data automatically anyway)
%   or ancLINK.  If 'status' is non-zero, an error has occurred.
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
%   $RCSfile: ancgetdata.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancgetdata.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:28  cflynn
%   *** empty log message ***
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

if (nargin ~= 2)
   help ancgetdata;
   return;
end

varid = -1;
varname = 'unknown';
datatype = -1;
dimids = [];
if (isnumeric(var) == 0)
   varname = var;
   if (isfield(cdf.ncdef.vars,var))
      varid = cdf.ncdef.vars.(var).id;
      datatype = cdf.ncdef.vars.(var).datatype;
      dims = cdf.ncdef.vars.(var).dims;
   end
else
   varid = var;
   fields = fieldnames(cdf.ncdef.vars);
   for q = 1:length(fields)
      key = fields{q};
      val = cdf.ncdef.vars.(key);
      if (varid == val.id)
         varname = key;
         datatype = val.datatype;
         dims = val.dims;
         break
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
      %       if (strcmp(legalizename(dims{d}),dkey))
      % The above line was an attempt to solve a problem reading the NSA
      % HSRL raw netcdf file that appeared to work but seems to have
      % introduced problems reading the SAS file!?
      
      if (strcmp(dims{d},dkey))
         dimids(d) = dval.id;
         break;
      end
   end
end
status = 0;
try
   [ncid] = netcdf.open(cdf.fname,'nowrite');
   c = onCleanup(@()netcdf.close(ncid));
catch ME
   status = status -1;
   disp(ME.message)
%    netcdf.close(ncid);
   return;
end

start = [0];
count = [1];
nodata = false;
% dimids = fliplr(dimids); % flip dimensions because matlab reads in reverse.
for d = 1:length(dimids);
   start(d) = 0;
   [dimname, dimlength] = netcdf.inqDim(ncid,dimids(d));
   %     [dimlength, status] = mexnc('inq_dimlen', ncid, dimids(d));
   if (dimlength < 1)
      nodata = true;
   end
   count(d) = dimlength;
end

if (nodata)
   vdata = [];
   status = 0;
else
   try      
      if (length(dimids) == 0)
         vdata = netcdf.getVar(ncid,varid);
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
%       netcdf.close(ncid);
      return
   end
end

% mexnc('close',ncid);
% status = 0;
% netcdf.close(ncid);
return


function newname = legalizename(oldname)
% Replaces illegal characters in names of structure elements.
if ((oldname(1)>47)&(oldname(1)<58))
oldname = ['n_',oldname];
end
newname = strrep(oldname,' ','__space__');
newname = strrep(newname,'-','__dash__');
newname = strrep(newname,'+','__plus__');
newname = strrep(newname,'(','__leftpar__');
newname = strrep(newname,')','__rightpar__');

if newname(1) == '_'
    newname = ['underbar__',newname(2:end)];
end

return