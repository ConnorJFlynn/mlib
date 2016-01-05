
function [cdf] = anc_load (ncfile, arm_time)

% [cdf] = anc_LOAD (ncfile, arm_time)
%
%   Wrapper around anc_link and anc_getdata.  First, anc_link is called,
%   which populates a structure with the netcdf file contents, and then
%   anc_getdata is called, which grabs the data for each variable in the
%   file.
%
%   For example,
%
%   mfr = anc_load('mfrsr.nc') populates anc_struct, 'mfr' (with data)
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also anc_LINK, anc_SAVE, anc_GETDATA, anc_STRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anc_load.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anc_load.m,v $
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
%   Revision 1.14  2006/06/22 21:26:31  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.13  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%   Revision 1.12  2006/05/25 15:43:49  sbeus
%   Modified help structure to accommodate new version function.
%
%
%-------------------------------------------------------------------

status = 0;
if ~exist('ncfile','var')||~exist(ncfile,'file')
   ncfile = getfullname('*.cdf;*.nc','nc_file');
end

[pname, fname, ext] = fileparts(ncfile);
if strcmp(ext,'.mat')
   cdf = load(ncfile);
else

% Open netcdf file.
ncid = netcdf.open(ncfile,'nowrite');
c = onCleanup(@()netcdf.close(ncid));
if (ncid == 0)
    disp(['anc_LINK: Cannot open: ',ncfile]);
%     netcdf.close(ncid);
    return;
end

% Grab all but variable data.
[cdf, status] = anc_link(ncfile);
if (status ~= 0)
    disp(['anc_LOAD: Cannot open: ', ncfile]);
%     netcdf.close(ncid);
    return;
end

% Load variable data.
fields = fieldnames(cdf.ncdef.vars);
for q = 1:length(fields)
    vkey = fields{q};
    vval = cdf.ncdef.vars.(vkey);
%     if findstr(vkey,'qc_')
%         disp(vkey)
%     end
    [vdata, status] = anc_getdata(cdf, vval.id);
%     if findstr(vkey,'qc_')
%         unique(vdata)
%     end
    if (status ~= 0)
%        netcdf.close(ncid);
        return;
    end
    cdf.vdata.(vkey) = vdata;
end

% Create and populate a 'time' field at the base level of cdf
% containing serial date for Matlab use.
% [tok, rest] = strtok(cdf.ncdef.vars.time_offset.atts.units.data);
% [tok, rest] = strtok(rest);
% cdf.ncdef.vars.base_time.data  = int32(serial2epoch(datenum(rest,['yyyy-mm-dd HH:MM:SS 0:00'])));
% cdf.time = (epoch2serial(double(cdf.ncdef.vars.base_time.data) + cdf.ncdef.vars.time_offset.data));
if ~exist('arm_time','var')
   if isfield(cdf.ncdef.vars,'base_time')&&isfield(cdf.ncdef.vars,'time_offset')
      arm_time = true;
   else
      arm_time = false;
   end
end
if arm_time
   cdf = anc_timesync(cdf);
end


end
% netcdf.close(ncid);
return

