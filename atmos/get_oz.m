function toms = get_oz(lat,lon,toms)
% toms = get_oz(lat,lon,toms);
% This function computes a gaussian weighted average of ozone in DU around
% the indicated lat and lon postion for the supplied TOMS file.
% The existing ozone, lat, and lon variables are replaced 
% with the more restricted set and outputs the results as netcdf struct.
% 2017-04-17: CJF, updating for anc_struct (with vdata) and to examine
% noise issues

if ~exist('toms','var')
   toms.fname = getfullname('*.cdf','ozone');
   toms = anc_load(toms.fname);
end
miss = toms.vdata.ozone <0;
toms.vdata.ozone(miss) = NaN;
dist = geodist(toms.vdata.lat*ones(size(toms.vdata.lon'))*pi/180,ones(size(toms.vdata.lat))*toms.vdata.lon'*pi/180,lat*pi/180, lon*pi/180)./1000;
max_dist = max(max(dist));
neg_dist = dist<0;
dist(neg_dist) = 2*max_dist + dist(neg_dist);
[dis,ind] = sort(dist(:));dis = dis(1:500);
[subs.I,subs.J] = ind2sub(size(dist),ind(1:500));
dist_inds = sub2ind(size(dist),subs.I, subs.J);
% for each time, compute a gaussian weighted average about the current lat
% and lon, excluding NaNs.  
for t = length(toms.time):-1:1
   oz_t = toms.vdata.ozone(:,:,t);
%     oz_inds = sub2ind(size(toms.vdata.ozone(:,:,t)),subs.I(1:10), subs.J(1:10), t.*ones(size(subs.J(1:10))));
%     oz_inds = sub2ind(size(oz_t),subs.I, subs.J, t.*ones(size(subs.J)));
    oz = oz_t(dist_inds); bads = isNaN(oz); 
    if sum(~bads)>1
       toms.oz_weight(t) = trapz(dis(~bads),oz(~bads) .* gaussian(dis(~bads), 0, 100))./trapz(dis(~bads),gaussian(dis(~bads), 0, 100));
    else 
       toms.oz_weight(t) = meannonan(oz(~bads));
    end
end
bads = isNaN(toms.oz_weight); 
% Replace NaNs at a given time with mean
toms.oz_weight(bads) = meannonan(toms.oz_weight);
toms.vdata.ozone = toms.oz_weight;
toms.ncdef.vars.ozone.dims = {'time'};
% NaNs = isNaN(toms.vdata.ozone);
% toms.vdata.ozone(NaNs) = interp1(toms.time(~NaNs), toms.vdata.ozone(~NaNs), toms.time(NaNs), 'linear','extrap');
toms.vdata.lat = single(lat);
toms.ncdef.vars.lat.dims = {''};
toms.vdata.lon = single(lon);
toms.ncdef.vars.lon.dims = {''};
toms.ncdef.dims = rmfield(toms.ncdef.dims,'lat');
toms.ncdef.dims = rmfield(toms.ncdef.dims,'lon');
toms.vdata = rmfield(toms.vdata, 'ai');
toms.ncdef.vars = rmfield(toms.ncdef.vars, 'ai');
if isfield(toms.vdata, 'reflectivity')
toms.vdata = rmfield(toms.vdata, 'reflectivity');
toms.ncdef.vars = rmfield(toms.ncdef.vars, 'reflectivity');
end
if isfield(toms.vdata, 'radiative_cloud_fraction');
   toms.vdata = rmfield(toms.vdata, 'radiative_cloud_fraction');
   toms.ncdef.vars = rmfield(toms.ncdef.vars, 'radiative_cloud_fraction');
end
toms = rmfield(toms, 'oz_weight');
toms.vdata = rmfield(toms.vdata,'date');
toms.ncdef.vars = rmfield(toms.ncdef.vars,'date');
toms.ncdef.dims = rmfield(toms.ncdef.dims, 'string_length');
toms.fname = strrep(toms.fname,'.cdf','.nc');

return


