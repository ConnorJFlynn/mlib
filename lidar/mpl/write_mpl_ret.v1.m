function status = write_mpl_ret(mpl, filename);
%status = write_mpl_ret(mpl, mpl_id, fullfilename);

[mplret_id] = mexnc('CREATE', filename, 'clobber');
mpl.r.lte_15 = find((mpl.range>=0)&(mpl.range<=15));
%Define 'time' related fields
year = str2num(datestr(mpl.time(1), 10));
epoch = serial2epoch(mpl.time);
julian_day = floor(serial2doy(mpl.time(1)));

base_time = min(epoch);
base_time_str = [datestr(min(mpl.time),31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy(mpl.time) - julian_day) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(mpl.time(1)),31) ' GMT' ];

julian_day_long_name = 'Day of year'; 
julian_day_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
julian_day_comment = ['For example: Jan 1 6:00 AM = 0.25'];

if mplret_id  >0  
% %   xvar{1} = '-x';
%    varlist = nclist(mpl_id);
%    [row, col] = size(varlist);
% 
%    keepers = [1:5 15 19:21];
%    for c = 1:length(keepers)
%       xvar{c} = varlist(:,keepers(c));
%    end
   status = mexnc('DIMDEF', mplret_id, 'time', 0);
   status = mexnc('DIMDEF', mplret_id, 'range', length(mpl.r.lte_15));
   
   varname = 'base_time';
   datatype = 4; ndims = 0; dim_ids = [];
   status = mexnc('VARDEF', mplret_id, 'base_time', datatype, ndims, dim_ids);   
   status = mexnc('ATTPUT', mplret_id, 'base_time','string', 2, length(base_time_str), base_time_str);
   status = mexnc('ATTPUT', mplret_id, 'base_time','long_name', 2, length(base_time_long_name), base_time_long_name);
   status = mexnc('ATTPUT', mplret_id, 'base_time', 'units', 2,  length(base_time_units), base_time_units);
   
   varname = 'time_offset';
   datatype = 6; ndims = 1; dim_ids = [0];
   status = mexnc('VARDEF', mplret_id, 'time_offset', datatype, ndims, dim_ids);   
   status = mexnc('ATTPUT', mplret_id, 'time_offset','long_name', 2, length(time_offset_long_name), time_offset_long_name);
   status = mexnc('ATTPUT', mplret_id, 'time_offset', 'units', 2 , length(time_offset_units), time_offset_units);
   
   status = mexnc('VARDEF', mplret_id, 'time', datatype, ndims, dim_ids);   
   att_val = 'time in seconds since midnight';
   status = mexnc('ATTPUT', mplret_id, 'time','long_name', 2, length(time_long_name), time_long_name);
   status = mexnc('ATTPUT', mplret_id, 'time', 'units', 2 ,length(time_units), time_units);
   
   status = mexnc('VARDEF', mplret_id, 'julian_day', 6, ndims, dim_ids);
   status = mexnc('ATTPUT', mplret_id, 'julian_day','long_name', 2, length(julian_day_long_name), julian_day_long_name);
   status = mexnc('ATTPUT', mplret_id, 'julian_day', 'units', 2 , length(julian_day_units), julian_day_units);
   status = mexnc('ATTPUT', mplret_id, 'julian_day', 'comment', 2 , length(julian_day_comment), julian_day_comment);

   datatype = 5;
   varname = 'range';
%    [varid, rcode] = mexnc('VARID', mpl_id, varname);
%    [att_datatype, len, status] = mexnc('ATTINQ', mpl_id, varname, 'long_name');
%    [temp, datatype, ndims, dim_ids, natts, varid] = mexnc('VARINQ', mpl_id, varid);
   status = mexnc('VARDEF', mplret_id, 'range', datatype, 1, 1);
   att_val = 'height above ground level to the center of the bin';
   status = mexnc('ATTPUT', mplret_id, varname, 'long_name', 2, length(att_val), att_val) ;
   att_val = 'km';
   status = mexnc('ATTPUT', mplret_id, varname, 'units', 2, length(att_val), att_val) ;
   
   varname = 'alpha_m';
   status = mexnc('VARDEF', mplret_id, varname, datatype, 1, 1);
   att_val = 'molecular extinction coefficient';
   status = mexnc('ATTPUT', mplret_id, varname, 'long_name', 2, length(att_val), att_val) ;
   att_val = '1/km';
   status = mexnc('ATTPUT', mplret_id, varname, 'units', 2, length(att_val), att_val) ;
   att_val = 'Derived from sonde profile on same day.';
   status = mexnc('ATTPUT', mplret_id, varname, 'source', 2, length(att_val), att_val) ;

   att_datatype = 2;
   varname = 'beta_m';
   status = mexnc('VARDEF', mplret_id, varname, datatype, 1, 1);
   att_val = 'molecular backscatter coefficient';
   status = mexnc('ATTPUT', mplret_id, 'beta_m', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '1/km-sr';
   status = mexnc('ATTPUT', mplret_id, 'beta_m', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'Derived from sonde profile on same day.';
   status = mexnc('ATTPUT', mplret_id, 'beta_m', 'source', att_datatype, length(att_val), att_val) ;
   
   varname = 'energy_monitor';
   ndims = 1; dim_ids = 0;
 
   status = mexnc('VARDEF', mplret_id, varname, datatype, ndims, dim_ids);
   att_val = 'laser energy monitor';
   status = mexnc('ATTPUT', mplret_id, varname, 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'uJ/pulse';
   status = mexnc('ATTPUT', mplret_id, varname, 'units', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, varname, 'missing_value', datatype, length(att_val), att_val) ;

   varname = 'background_signal';
   status = mexnc('VARDEF', mplret_id, varname, datatype, ndims, dim_ids);
   att_val = 'ambient detector background';
   status = mexnc('ATTPUT', mplret_id, varname, 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'cts/uS';
   status = mexnc('ATTPUT', mplret_id, varname, 'units', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, varname, 'missing_value', datatype, length(att_val), att_val) ;
   
   status = mexnc('VARDEF', mplret_id, 'aod_523nm', datatype, ndims, dim_ids);
   att_val = 'aerosol optical depth 523 nm';
   status = mexnc('ATTPUT', mplret_id, 'aod_523nm', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'unitless';
   status = mexnc('ATTPUT', mplret_id, 'aod_523nm', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'Derived from nimfr aod 500 nm using angstrom from 500nm and 870nm.';
   status = mexnc('ATTPUT', mplret_id, 'aod_523nm', 'source', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, 'aod_523nm', 'missing_value', datatype, length(att_val), att_val) ;
   
   status = mexnc('VARDEF', mplret_id, 'lidar_C', datatype, ndims, dim_ids);
   att_val = 'lidar calibration constant';
   status = mexnc('ATTPUT', mplret_id, 'lidar_C', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '(uS-uJ)/(km^3-sr)';
   status = mexnc('ATTPUT', mplret_id, 'lidar_C', 'units', att_datatype, length(att_val), att_val) ;
   att_val = [min(mpl.range(mpl.r.cal)), max(mpl.range(mpl.r.cal))];
   status = mexnc('ATTPUT', mplret_id, 'lidar_C', 'cal_range', datatype, length(att_val), att_val) ;

   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, 'lidar_C', 'missing_value', datatype, length(att_val), att_val) ;
   
   status = mexnc('VARDEF', mplret_id, 'Sa_Klett', datatype, ndims, dim_ids);
   att_val = 'extinction to backscatter ratio';
   status = mexnc('ATTPUT', mplret_id, 'Sa_Klett', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '1/sr';
   status = mexnc('ATTPUT', mplret_id, 'Sa_Klett', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'Retrieved value consistent with integrated extinction and input aot_523.';
   status = mexnc('ATTPUT', mplret_id, 'Sa_Klett', 'source', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, 'Sa_Klett', 'missing_value', datatype, length(att_val), att_val) ;
   
   varname = 'atten_bscat';
   ndims = 2; dim_ids=[0 1];
   att_val = 'normalized attenuated backscatter';
   status = mexnc('VARDEF', mplret_id, varname, datatype, ndims, dim_ids);
   status = mexnc('ATTPUT', mplret_id, varname, 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '(counts/usec-uJ';
   status = mexnc('ATTPUT', mplret_id, varname, 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'from detector_counts in a1-level file';
   status = mexnc('ATTPUT', mplret_id, varname, 'source', att_datatype, length(att_val), att_val) ;
   att_val = 'deadtime corrected, afterpulse-subtracted, background-subtracted, range-corrected, overlap-corrected, bin-3 normalized, temporal averaged.';
   status = mexnc('ATTPUT', mplret_id, varname, 'corrections', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, varname, 'missing_value', datatype, length(att_val), att_val) ;
   
   status = mexnc('VARDEF', mplret_id, 'alpha_a_Klett', datatype, ndims, dim_ids);
   att_val = 'aerosol extinction coefficient';
   status = mexnc('ATTPUT', mplret_id, 'alpha_a_Klett', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '1/km';
   status = mexnc('ATTPUT', mplret_id, 'alpha_a_Klett', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'From backwards (top-down) Klett retrieval.';
   status = mexnc('ATTPUT', mplret_id, 'alpha_a_Klett', 'source', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, 'alpha_a_Klett', 'missing_value', datatype, length(att_val), att_val) ;

   
   status = mexnc('VARDEF', mplret_id, 'beta_a_Klett', datatype, ndims, dim_ids);
   att_val = 'aerosol backscatter coefficient';
   status = mexnc('ATTPUT', mplret_id, 'beta_a_Klett', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = '1/km-sr';
   status = mexnc('ATTPUT', mplret_id, 'beta_a_Klett', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'From backwards (top-down) Klett retrieval.';
   status = mexnc('ATTPUT', mplret_id, 'beta_a_Klett', 'source', att_datatype, length(att_val), att_val) ;
   att_val = -9999; 
   status = mexnc('ATTPUT', mplret_id, 'beta_a_Klett', 'missing_value', datatype, length(att_val), att_val) ;   
end; %
status = mexnc('ENDEF', mplret_id);

[status] = nc_putvar(mplret_id, 'Sa_Klett', mpl.klett.Sa);
[status] = nc_putvar(mplret_id, 'lidar_C', mpl.cal.C);

[status] = nc_putvar(mplret_id, 'beta_a_Klett', mpl.klett.beta_a(mpl.r.lte_15,:));
[status] = nc_putvar(mplret_id, 'alpha_a_Klett', mpl.klett.alpha_a(mpl.r.lte_15,:));
[status] = nc_putvar(mplret_id, 'atten_bscat', mpl.prof(mpl.r.lte_15,:));

[status] = nc_putvar(mplret_id, 'aod_523nm', mpl.cal.aod_523);
[status] = nc_putvar(mplret_id, 'background_signal', mpl.hk.bg);
[status] = nc_putvar(mplret_id, 'energy_monitor', mpl.hk.energy_monitor);

[status] = nc_putvar(mplret_id, 'range', mpl.range(mpl.r.lte_15));
[status] = nc_putvar(mplret_id, 'beta_m', mpl.sonde.beta_R(mpl.r.lte_15));
[status] = nc_putvar(mplret_id, 'alpha_m', mpl.sonde.alpha_R(mpl.r.lte_15));

[status] = nc_putvar(mplret_id, 'base_time', base_time);
[status] = nc_putvar(mplret_id, 'time_offset',time_offset );
[status] = nc_putvar(mplret_id, 'time', time);
[status] = nc_putvar(mplret_id, 'julian_day',serial2doy(mpl.time));

mexnc('close', mplret_id);