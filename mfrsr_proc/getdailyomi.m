function Du = getdailyomi(time, lat, lon);
% Du = getdailyomi(time, lat, lon);
% Modify this to call get_oz which finds a gaussian weighted value for
% robustness.
%
% JH modified, Jan 5 2017
% I think get_oz ref'd above is now get_oz_at_latlon.m  Also, time input is
% in Matlab's datenum format?

lat = round(lat);
lon = round(lon);
% Convert lat and lon into complex angle
point = (pi./180).*(lat+sqrt(-1).*lon);
[points, ii,jj] = unique(point);
lats = real(points).*(180./pi);
lons = imag(points).*(180./pi);
Du = 300.*ones(size(time)); % pre-fill with default of 300

% JH: this is looping over lat/lon values if there are multiple?
for p = length(points):-1:1
    in_time = time(ii(p));
    oz_file = get_oz_file_jh(in_time);   %JH change.  hard -coded 1 line in this.
    if isempty(oz_file)
        disp('No ozone file for this month?')
        break
    end
    % Returns just that portion of the supplied file over the desired lat
    % and lon, with gaussian smoother applied spatially and linear
    % interpolation applied over time to fill NaN gaps.
    oz_latlon = get_oz_at_latlon_jh(lats(p),lons(p),oz_file);   % call JH function
    
    % JH: make standard change to vars data structure (same as in
    % get....latlon_jh.m file)
    %Du_p = interp1(oz_latlon.time, oz_latlon.vars.ozone.data,in_time,'nearest');
    Du_p = interp1(oz_latlon.time, oz_latlon.vdata.ozone,in_time,'nearest');
    if p>1
        Du((ii(p-1)+1):ii(p)) = Du_p;
    else
        Du(1:ii(p)) = Du_p;
    end
end
      
 return