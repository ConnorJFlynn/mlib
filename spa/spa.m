function [zen_angle, az_angle, r_au,hour_angle, inc_angle, sunrise, suntransit, sunset, cos_sza, airmass] = spa(lat, lon, alt,serial_time, tz, tz_sec,pres);
%[zen_angle, az_angle, r_au,hour_angle, inc_angle, sunrise, suntransit, sunset, cos_sza, airmass]=spa(lat, lon, alt, serial_time, tz, tz_sec,pres);
% lat(+N), lon(+E), and alt(m) are required.  If time is not provided, now is assumed
% All angles returned in degrees
%
%     float longitude;     // Observer longitude (negative west of Greenwich)
%                          // valid range: -180  to  180 degrees, error code: 9
% 
%     float latitude;      // Observer latitude (negative south of equator)
%                          // valid range: -90   to   90 degrees, error code: 10
% 
%     float elevation;     // Observer elevation [meters]
%                          // valid range: -6500000 or higher meters,    error code: 11

if nargin<7
    pres = 1013;%Probably should use atmos scale factor for this term.
else
    if pres> 1500 % Wrong units, divide by 10
        pres = pres/10;
    elseif pres < 150 % Wrong units for pressure, multiply by 10
        pres = pres * 10;
    end
end

if nargin<6
    tz_sec = 0;
end
if nargin<5
    tz = 0;
end
if nargin<4
    serial_time = now;
end
if nargin>=3
    %fill in defaults for spa
%     d_str = datestr(serial_time, 'YYYY-mm-DD HH:MM:SS');
%     year = str2num(d_str(1:4));
%     month = str2num(d_str(6:7));
%     day   = str2num(d_str(9:10));
%     hour = str2num(d_str(12:13));
%     mins = str2num(d_str(15:16));
%     sec = str2num(d_str(18:19));

    T_C = 15;%Scale with lapse rate?
    sfc_slope = 0;
    sfc_az = 0;
    atmos_refr = .5667;
    [serial_time, lon, lat, alt, pres] = adjust_sizes(serial_time, lon, lat, alt, pres);
%      serial_time = round(serial_time*24*60*60)/(24*60*60);

    if length(serial_time)>1
        if serial_time(1)==serial_time(2)
            V = ones([length(serial_time),1])*datevec(serial_time(1));
        else
            V = datevec(serial_time');
        end
    else
        V = datevec(serial_time');
    end
    for t = length(serial_time):-1:1
        year = V(t,1);
        month = V(t,2);
        day   = V(t,3);
        hour = V(t,4);
        mins = V(t,5);
        secs = V(t,6);
        
        frac_secs = 60*(24*60*60*serial_time(end)-floor(24*60*60*serial_time(end)));
% %         if frac_secs > 60
% %            disp('Whoa');
%           secs = secs + frac_secs;
% %         end
        hsecs = secs + frac_secs;       
        [jd(t), helio_lat(t), helio_lon(t), r_au(t), nut_lon(t), nut_obl(t), ecl_obl(t), ... 
           hour_angle(t), zen_angle(t), az_angle(t), inc_angle(t), ...
           sunrise(t), suntransit(t), sunset(t)] =  ... 
           mex_spa(year, month, day, hour, mins, hsecs, tz, tz_sec, ... 
           lon(t), lat(t), alt(t), pres(t), T_C, sfc_slope, sfc_az, atmos_refr);
    end
    cos_sza = cos(pi*zen_angle/180);
    el = 90-zen_angle;
    airmass = NaN(size(zen_angle));
    pos = find(el>0);
    airmass(pos) = 1./cos_sza(pos);
else
    disp('Need to at least specify lat, lon, and alt.');
end


function [serial_time, lon, lat, alt, pres] = adjust_sizes(serial_time, lon, lat, alt, pres);
    % An internal function of spa intended to adjust the sizes of supplied
    % arguments to permit vector input rather than just scalars
    % It requires all inputs to have a singleton dimension.
    % All inputs with an (additional) non-singleton dimension must be of equal length.
    % All scalar inputs are then expanded to match the non-singleton length
    % using ones
    if ~any(size(serial_time)==1)|~any(size(lon)==1)|~any(size(lat)==1)|~any(size(pres)==1)
    disp('At least one input lacked any singleton dimension.  Aborting!')
    else
        sizes = [size(serial_time), size(lon), size(lat), size(pres)];
        sizes = unique(sizes);
        if length(sizes)>2
            disp('Inputs with non-singleton dimension had different lengths.  Aborting!')
        else
            out_length = max(sizes);
            if any(sizes==1)&any(sizes>1)
                if length(serial_time)==1
                    serial_time = ones([out_length,1])*serial_time;
                end
                if length(lat)==1
                    lat = ones([out_length,1])*lat;
                end
                if length(lon)==1
                    lon = ones([out_length,1])*lon;
                end
                if length(alt)==1
                    alt = ones([out_length,1])*alt;
                end
                if length(pres)==1
                    pres = ones([out_length,1])*pres;
                end
            end
        end
    end