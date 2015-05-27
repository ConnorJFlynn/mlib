function [lidar] = read_mpace_lidar_file(ncid)
% [lidar] = read_mpace_lidar(ncid);
% Read a PARSL lidar file raw or c1.
if nargin>1
   disp('usage: [lidar] = read_mpace_lidar(fname);');
   return;
elseif nargin == 0
  [fid, fname, pname] = getfile('*.nc','mpace');
  fname = [pname fname];
  fclose(fid);
  ncid = ncmex('open', [fname]);
end

[datatype, len, status] = ncmex('ATTINQ', ncid, 'nc_global', 'zeb_platform');
if status>0 %then the file is c1
   lidar = read_mpace_lidar_c1(ncid);
else
   lidar = read_mpace_lidar_raw(ncid);
end;

if nargin == 0
   ncmex('close', ncid);
end
return

