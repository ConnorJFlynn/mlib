function [status] = mplnet2arm(ncid);
% function [mplnet, status] = mplnet2arm(ncid);
% Converts input netcdf file to ARM-style (with addition of base_time and time_offset) if necessary
% -1 returned for failure
% 0  returned if unnecessary (base_time already exists)
% 1 returned if successful

in_name = 'base_time';
[out_name] = ncmex('VARINQ', ncid, in_name);
if strcmp(in_name, out_name)
   status = 0;
else
   [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
   for i = 1:natts
      temp = ncmex('ATTNAME', ncid, 'nc_global', i-1);
      attname{i} = temp;
      if any(findstr(upper(temp),upper('MPL-net_WWW_Homepage')))|any(findstr(upper(temp),upper('MPLNET_'))); %Then it is an MPLnet file 
         MPLnet = 1;
      end
   end;
   if MPLnet == 1
      jd0 = nc_getvar(ncid, 'time'); 
      value = ncmex('ATTGET', ncid, 'nc_global', 'File_Name');
      dot = findstr(value,'.cdf');
      year = str2num(value(dot-8:dot-5));
      time = datenum(year,1,0)+jd0;
      epoch = serial2epoch(time);
      
      julian_day_long_name = 'Day of year'; 
      julian_day_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
      julian_day_comment = ['For example: Jan 1 6:00 AM = 0.25'];
      
      base_time = min(epoch);
      base_time_str = [datestr(min(time),31) ' GMT'];
      base_time_long_name = 'Base time in Epoch';
      base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';
      
      time_offset = epoch - base_time;
      time_offset_long_name = ['Time offset from base_time'];
      time_offset_units = ['seconds since ' base_time_str] ;
      
      %time is seconds since midnight of the day of the first record
      julian_day = floor(jd0(1));
      time = (jd0 - julian_day) * (24*60*60);
      time_long_name  = 'Time offset from midnight';
      time_units = ['seconds since ' datestr(floor(time(1)),31) ' GMT' ];
      
      [name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', ncid, 'time');
      [status] = ncmex('REDEF',ncid);
      status = ncmex('ATTDEL', ncid, 'time', 'long_name');
      status = ncmex('ATTDEL', ncid, 'time', 'units');
      status = ncmex('ATTPUT', ncid, 'time','long_name', 2, length(time_long_name), time_long_name);
      status = ncmex('ATTPUT', ncid, 'time', 'units', 2 ,length(time_units), time_units);
      
      status = ncmex('VARDEF', ncid, 'time_offset', 6, ndims, dims);
      status = ncmex('ATTPUT', ncid, 'time_offset','long_name', 2, length(time_offset_long_name), time_offset_long_name);
      status = ncmex('ATTPUT', ncid, 'time_offset', 'units', 2 , length(time_offset_units), time_offset_units);
      
      status = ncmex('VARDEF', ncid, 'base_time', 4, 0, []);
      status = ncmex('ATTPUT', ncid, 'base_time','string', 2, length(base_time_str), base_time_str);
      status = ncmex('ATTPUT', ncid, 'base_time','long_name', 2, length(base_time_long_name), base_time_long_name);
      status = ncmex('ATTPUT', ncid, 'base_time', 'units', 2,  length(base_time_units), base_time_units);

      status = ncmex('VARDEF', ncid, 'julian_day', 6, ndims, dims);
      status = ncmex('ATTPUT', ncid, 'julian_day','long_name', 2, length(julian_day_long_name), julian_day_long_name);
      status = ncmex('ATTPUT', ncid, 'julian_day', 'units', 2 , length(julian_day_units), julian_day_units);
      status = ncmex('ATTPUT', ncid, 'julian_day', 'comment', 2 , length(julian_day_comment), julian_day_comment);

      [status] = ncmex('ENDEF',ncid);
      status = nc_putvar(ncid, 'time', time);
      status = nc_putvar(ncid, 'base_time', base_time);
      status = nc_putvar(ncid, 'time_offset', time_offset);
      status = nc_putvar(ncid, 'julian_day', jd0);
      status = 1;
   else
      disp('Not an MPL-net data file.');
      status = -1;
   end;
end;


