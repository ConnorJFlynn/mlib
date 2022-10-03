function toms = get_oz_at_latlon_jh(lat,lon,toms)
% toms = get_oz(lat,lon,toms);
% This function computes a gaussian weighted average of ozone in DU around
% the indicated lat and lon postion for the supplied TOMS file.
% The existing ozone, lat, and lon variables are replaced 
% with the more restricted set and outputs the results as netcdf struct.
%
% Josh Howie Modified, Jan 5 2017
% I think toms.vars.ozone.data is now toms.vdata.ozone
% toms.vars.lat.data is toms.vdata.lat
% The toms.dims changes are less clear to me.  Lines 47 onward are guesses.

if ~exist('toms','var')
   toms = anc_bundle_files(getfullname('*.cdf','ozone'));
end
miss = toms.vdata.ozone <0;   %JH
toms.vdata.ozone(miss) = NaN;   % JH
good_lats = abs(toms.vdata.lat-lat)<10;  %JH
good_lat = toms.vdata.lat(good_lats);    % JH
dist = geodisth(good_lat*ones(size(toms.vdata.lon'))*pi/180,ones(size(good_lat))*toms.vdata.lon'*pi/180,lat*pi/180, lon*pi/180)./1000;  %JH
[dis,ind] = sort(dist(:));
[subs.I,subs.J] = ind2sub(size(dist),ind(1:500));
% dist_inds = sub2ind(size(dist),subs.I(1:100), subs.J(1:100));
for t = length(toms.time):-1:1
    oz_inds = sub2ind(size(toms.vdata.ozone(good_lats,:,:)),subs.I(1:100), subs.J(1:100), t.*ones(size(subs.J(1:100))));  %JH
    oz_du = toms.vdata.ozone(oz_inds);  %JH
    dis_ = dis(1:100);
    if any(~isnan(oz_du))
    toms.oz_weight(t) = trapz(dis_(~isnan(oz_du)),oz_du(~isnan(oz_du)) .* gaussian(dis_(~isnan(oz_du)), 0, 100))...
        ./trapz(dis_(~isnan(oz_du)),gaussian(dis_(~isnan(oz_du)), 0, 100));
    else
       toms.oz_weight(t) = NaN;
    end
end

%% Adjust this to comprise an interpolation over time for the good ozone values
      Du_daily = toms.oz_weight;
      good_times = toms.time(~isnan(Du_daily));
      Du_daily(isnan(Du_daily)) = [];
      Du = interp1(good_times, Du_daily, toms.time, 'linear','extrap');

%%

toms.vdata.ozone = Du;    % JH
toms.vdata.ozone.dims = {'time'};  % JH.  Was: toms.vars.ozone.dims
NaNs = isnan(toms.vars.ozone.data);
toms.vars.ozone.data(NaNs) = interp1(toms.time(~NaNs), toms.vars.ozone.data(~NaNs), toms.time(NaNs), 'linear','extrap');
toms.vdata.lat = single(lat);   % JH
toms.ncdef.dims.lat = {''};  % JH: Was toms.vars.lat.dims. now is toms.ncdef.dims.lat ???
toms.vdata.lon = single(lon);   % JH
toms.ncdef.dims.lon = {''};j   % JH: was toms.vars.lon.dims.  Now toms.ncdef.dims.lon???
toms.dims = rmfield(toms.dims,'lat');   %JH removed  
toms.dims = rmfield(toms.dims,'lon');   %JH removed
toms.vdata = rmfield(toms.vdata, 'ai');   % JH

if isfield(toms.vdata, 'reflectivity')
toms.vdata = rmfield(toms.vdata, 'reflectivity');
end
if isfield(toms.vdata, 'radiative_cloud_fraction');
   toms.vdata = rmfield(toms.vdata, 'radiative_cloud_fraction');
end
toms = rmfield(toms, 'oz_weight');
toms.vdata = rmfield(toms.vdata,'date');  % JH toms.dims = rmfield(toms.dims, 'string_length');
% toms.fname = [toms.fname, '.nc'];
anc_check(toms)

return





