function [mplps,ncid] = read_mplps(ncid);
%mplps = read_mplps(ncid);
%This function is probably no longer useful.  It reads netcfd MPL-PS files
%of my own design formed from the prototype MPL-PS data.

if nargin==0
   ncid = get_ncid;
end

mplps.time = nc_time(ncid);
mplps.range = nc_getvar(ncid, 'range');
mplps.r.lte_5 = find((mplps.range>=0)&(mplps.range<=5));
mplps.r.lte_10 = find(mplps.range>=0&mplps.range<=10);
mplps.r.lte_15 = find(mplps.range>=0&mplps.range<=15);
mplps.r.lte_20 = find(mplps.range>=0&mplps.range<=20);
mplps.copol.prof = nc_getvar(ncid, 'copol_prof');
mplps.copol.cts = nc_getvar(ncid, 'copol_cts');
mplps.copol.sample_noise = nc_getvar(ncid, 'copol_noise');
mplps.crosspol.prof = nc_getvar(ncid, 'crosspol_prof');
mplps.crosspol.cts = nc_getvar(ncid, 'crosspol_cts');
mplps.crosspol.sample_noise = nc_getvar(ncid, 'crosspol_noise');

mplps.dpr = nc_getvar(ncid, 'depolarization');
mplps.cts = nc_getvar(ncid, 'total_cts');
mplps.prof = nc_getvar(ncid, 'total_prof');
mplps.sample_stability =nc_getvar(ncid, 'sample_stability');
mplps.statics.datastream = ncmex('ATTGET', ncid, 'nc_global', 'zeb_platform');

gtz = find((mplps.copol.cts>0)&(mplps.copol.sample_noise>0));
mplps.copol.snr = zeros(size(mplps.copol.prof));
mplps.copol.snr(gtz) = mplps.copol.cts(gtz)./mplps.copol.sample_noise(gtz);
mplps.good = mplps.copol.snr>.25;

% gtz = find((mplps.copol.cts>0)&(mplps.crosspol.cts>0)&(mplps.copol.noise>0));
% mplps.ldpr = zeros(size(mplps.copol.cts));
% mplps.ldpr = mplps.crosspol.cts./(mplps.copol.cts-0.5*mplps.crosspol.cts);


if nargin==0
   ncmex('close', ncid);
end

return

