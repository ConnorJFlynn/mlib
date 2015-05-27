function toms = get_oz(lat,lon,toms)
% toms = get_oz(lat,lon,toms);
% This function computes a gaussian weighted average of ozone in DU around
% the indicated lat and lon postion for the supplied TOMS file.
% The existing ozone, lat, and lon variables are replaced 
% with the more restricted set and outputs the results as netcdf struct.

if ~exist('toms','var')
   toms.fname = getfullname_('*.cdf','ozone');
   toms = ancload(toms.fname);
end
miss = toms.vars.ozone.data <0;
toms.vars.ozone.data(miss) = NaN;
dist = geodist(toms.vars.lat.data*ones(size(toms.vars.lon.data'))*pi/180,ones(size(toms.vars.lat.data))*toms.vars.lon.data'*pi/180,lat*pi/180, lon*pi/180)./1000;
max_dist = max(max(dist));
neg_dist = dist<0;
dist(neg_dist) = 2*max_dist + dist(neg_dist);
[dis,ind] = sort(dist(:));
[subs.I,subs.J] = ind2sub(size(dist),ind(1:500));
dist_inds = sub2ind(size(dist),subs.I(1:10), subs.J(1:10));
for t = length(toms.time):-1:1
    oz_inds = sub2ind(size(toms.vars.ozone.data),subs.I(1:10), subs.J(1:10), t.*ones(size(subs.J(1:10))));
    oz = toms.vars.ozone.data(oz_inds);
    toms.oz_weight(t) = trapz(dis(1:10),oz .* gaussian(dis(1:10), 0, 100))./trapz(dis(1:10),gaussian(dis(1:10), 0, 100));
end
toms.vars.ozone.data = toms.oz_weight;
toms.vars.ozone.dims = {'time'};
% NaNs = isNaN(toms.vars.ozone.data);
% toms.vars.ozone.data(NaNs) = interp1(toms.time(~NaNs), toms.vars.ozone.data(~NaNs), toms.time(NaNs), 'linear','extrap');
toms.vars.lat.data = single(lat);
toms.vars.lat.dims = {''};
toms.vars.lon.data = single(lon);
toms.vars.lon.dims = {''};
toms.dims = rmfield(toms.dims,'lat');
toms.dims = rmfield(toms.dims,'lon');
toms.vars = rmfield(toms.vars, 'ai');
if isfield(toms.vars, 'reflectivity')
toms.vars = rmfield(toms.vars, 'reflectivity');
end
if isfield(toms.vars, 'radiative_cloud_fraction');
   toms.vars = rmfield(toms.vars, 'radiative_cloud_fraction');
end
toms = rmfield(toms, 'oz_weight');
toms.vars = rmfield(toms.vars,'date');
toms.dims = rmfield(toms.dims, 'string_length');
toms.fname = [toms.fname, '.nc'];





