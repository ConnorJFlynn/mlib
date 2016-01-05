
function [cdf,status] = anclink (ncfile)

% [cdf, status] = ancLINK (ncfile)
%
%   Retrieves all information for a specified netcdf file (except
%   variable data) and populates and returns a netCDF structure.
%   If 'status' is non-zero, an error has occurred.
%
%   For example,
%
%   mfr = ancLINK('mfrsr.nc') populates acstruct, 'mfr'
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ancLOAD, ancGETDATA, ancSAVE, ancSTRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: anclink.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: anclink.m,v $
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
%   Revision 1.12  2006/08/18 22:55:11  sbeus
%   Open files in "nc_nowrite_mode" instead of "nc_write_mode" because anclink/load only need read access.
%
%   Revision 1.11  2006/08/18 22:42:36  cflynn
%   Legalized "+" in dimname
%
%   Revision 1.10  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%   Revision 1.9  2006/05/24 23:18:26  sbeus
%   Modified help structure to accommodate new version function.
%
%   Revision 2.0  2006/05/24 23:18:26  cflynn
%   Renaming with _, implementing internal Matlab netcdf support.
%-------------------------------------------------------------------


status = 0;
if ~exist('ncfile','var')||~exist(ncfile,'file')
   ncfile = getfullname_('*.cdf;*.nc','nc_file');
end

% Open netcdf file.
ncid = netcdf.open(ncfile,'nowrite');
c = onCleanup(@()netcdf.close(ncid));
if (ncid == 0)
    disp(['ANCLINK: Cannot open: ',ncfile]);
%     netcdf.close(ncid);
    return;
end

cdf.fname = ncfile;

% Inquire about netcdf file.

try
   [ndims,nvars,natts,recdim] = netcdf.inq(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end
   
if (status ~= 0)
    disp(['ANCLINK: Cannot inquire about: ',ncfile]);
%     netcdf.close(ncid);
    return;
end

% Get global attributes.
for g = 0:(natts-1)
   try
    attname = netcdf.inqAttName(ncid,-1,g);
catch ME
   status = status -1;
   disp(ME.message);
   end
try
    [atttype,attlen] = netcdf.inqAtt(ncid,-1,attname);
catch ME
   status = status -1;
   disp(ME.message);
end
try
    [attval] = netcdf.getAtt(ncid,-1,attname);
catch ME
   status = status -1;
   disp(ME.message);
end

    attname = legalizename(attname);
    cdf.atts.(attname).id = g;
    cdf.atts.(attname).datatype = atttype;
    cdf.atts.(attname).data = attval;
end

% Get dimension information.
for d = 0:(ndims-1)
   try
    [dimname,dimlength] = netcdf.inqDim(ncid,d);
catch ME
   status = status -1;
   disp(ME.message);
   end

    isunlim = false;
    if (d == recdim)
        isunlim = true;
        recdim = 'recdim';
        cdf.(recdim).name = dimname;
        cdf.(recdim).id = d;
        cdf.(recdim).length = dimlength;
    end

    dimname = legalizename(dimname);
    cdf.dims.(dimname).id = d;
    cdf.dims.(dimname).length = dimlength;
    cdf.dims.(dimname).isunlim = isunlim;
    if isunlim==true
        cdf.recdim.id = d;
        cdf.recdim.name = dimname;
        cdf.recdim.length = dimlength;
    end
end

% Get variables.
for v = 0:(nvars-1)
   try
      [vname,vtype,vdims,vnatts] = netcdf.inqVar(ncid,v);
      vndims = length(vdims);
   catch ME
      status = status -1;
      disp(ME.message);
%       netcdf.close(ncid);
      return
   end
   vname = legalizename(vname);
   cdf.vars.(vname).id = v;
    cdf.vars.(vname).datatype = vtype;
    clear vdimnames;
    vdimnames{1} = '';
    for d = 1:vndims
       try
          [dname,dlen] = netcdf.inqDim(ncid,vdims(d));
          vdimnames{d} = dname;          
       catch ME
          status = status -1;
          disp(ME.message);
%           netcdf.close(ncid);
          return
       end
       
    end
%     vdimnames = fliplr(vdimnames);
    cdf.vars.(vname).dims = vdimnames;
    for a = 0:(vnatts-1)
try
   [attname] = netcdf.inqAttName(ncid,v,a);
       catch ME
          status = status -1;
          disp(ME.message);
%           netcdf.close(ncid);
          return
       end
try
   [atttype,attlen] = netcdf.inqAtt(ncid,v,attname);
       catch ME
          status = status -1;
          disp(ME.message);
%           netcdf.close(ncid);
          return
end
try
[attval] = netcdf.getAtt(ncid,v,attname);
       catch ME
          status = status -1;
          disp(ME.message);
%           netcdf.close(ncid);
          return
       end
        attname = legalizename(attname);

        cdf.vars.(vname).atts.(attname).id = a;
        cdf.vars.(vname).atts.(attname).datatype = atttype;
        cdf.vars.(vname).atts.(attname).data = attval;
    end
end

status = 0;
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

