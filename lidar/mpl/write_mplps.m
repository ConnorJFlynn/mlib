function status = write_mplps(mplps, pname);
% status = write_mplps(mplps, pname);
% provided with a complete mplps structure, writes it to netcdf in pname

year = str2num(datestr(mplps.time(1), 10));
epoch = serial2epoch(mplps.time);
julian_day = floor(serial2doy0(mplps.time(1)));

base_time = min(epoch);
base_time_str = [datestr(min(mplps.time),31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy0(mplps.time) - julian_day) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(mplps.time(1)),31) ' GMT' ];

julian_day_long_name = 'Day of year'; 
julian_day_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
julian_day_comment = ['For example: Jan 1 6:00 AM = 0.25'];      
%      !!

%Create and define the outgoing netcdf file...
%construct outgoing filename
ds_name_stem = strtok(mplps.statics.datastream, '.');
begin_date = floor(mplps.time(1));
begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
ds_name = [ds_name_stem, '.c1.', begin_datestr, '.000000.cdf'];
cdfid = ncmex('create', [pname, ds_name], 'clobber');
status = ncmex('DIMDEF', cdfid, 'time', 0);
status = ncmex('DIMDEF', cdfid, 'range', length(mplps.range));


att_name = 'proc_level';
att_val = 'c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'input_source';
att_val = [mplps.statics.datastream];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'site_id';
att_val = 'nsa';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'facility_id';
att_val = 'C1 : PAARCS2:NSA-Barrow_Central_Facility';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'proc_level';
att_val = 'c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'averaging_int';
att_val = [num2str(mplps.statics.averaging_interval), ' minutes'];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'deadtime_corrected';
att_val = 'yes';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'Instrument Mentor';
att_val = ['Connor J. Flynn Connor.Flynn@arm.gov 509-375-2041'];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'time_offset_description';
att_val = 'The time is referenced to the middle of each averaging interval.';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'serial_number';
att_val = [num2str(mplps.statics.unitSN)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'zeb_platform';
att_val = 'nsamplpsC1.c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'history';
att_val = ['Created by CJF on ', datestr(now)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;


varname = 'base_time';
datatype = 4; ndims = 0; dim_ids = [];
status = ncmex('VARDEF', cdfid, 'base_time', datatype, ndims, dim_ids);   
status = ncmex('ATTPUT', cdfid, 'base_time','string', 2, length(base_time_str), base_time_str);
status = ncmex('ATTPUT', cdfid, 'base_time','long_name', 2, length(base_time_long_name), base_time_long_name);
status = ncmex('ATTPUT', cdfid, 'base_time', 'units', 2,  length(base_time_units), base_time_units);

varname = 'time_offset';
datatype = 6; ndims = 1; dim_ids = [0];
status = ncmex('VARDEF', cdfid, 'time_offset', datatype, ndims, dim_ids);   
status = ncmex('ATTPUT', cdfid, 'time_offset','long_name', 2, length(time_offset_long_name), time_offset_long_name);
status = ncmex('ATTPUT', cdfid, 'time_offset', 'units', 2 , length(time_offset_units), time_offset_units);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'time_offset', 'reference_point', 2 , length(att_val), att_val);

status = ncmex('VARDEF', cdfid, 'time', datatype, ndims, dim_ids);   
att_val = 'time in seconds since midnight';
status = ncmex('ATTPUT', cdfid, 'time','long_name', 2, length(time_long_name), time_long_name);
status = ncmex('ATTPUT', cdfid, 'time', 'units', 2 ,length(time_units), time_units);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'time', 'reference_point', 2 , length(att_val), att_val);


status = ncmex('VARDEF', cdfid, 'julian_day', 6, ndims, dim_ids);
status = ncmex('ATTPUT', cdfid, 'julian_day','long_name', 2, length(julian_day_long_name), julian_day_long_name);
status = ncmex('ATTPUT', cdfid, 'julian_day', 'units', 2 , length(julian_day_units), julian_day_units);
status = ncmex('ATTPUT', cdfid, 'julian_day', 'comment', 2 , length(julian_day_comment), julian_day_comment);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'julian_day', 'reference_point', 2 , length(att_val), att_val);

datatype = 5;
varname = 'range';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 1);
att_val = 'height above ground level to the center of the bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'km';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
att_val = mplps.statics.bin_width;
status = ncmex('ATTPUT', cdfid, varname, 'range_resolution', datatype, length(att_val), att_val);

varname = 'overlap_corr';
status = ncmex('VARDEF', cdfid, 'overlap_corr', datatype, 1, 1);
att_val = 'near-range overlap correction factor';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'applied to remove near-field instrument artifact';
status = ncmex('ATTPUT', cdfid, varname, 'utility', 2, length(att_val), att_val) ;
att_val = 'derived from vertical data on 2003-11-19 by CJF';
status = ncmex('ATTPUT', cdfid, varname, 'source', 2, length(att_val), att_val) ;

varname = 'deadtime_corrected';
status = ncmex('VARDEF', cdfid, 'deadtime_corrected', 3, 0, 0);
att_val = 'detector deadtime correction applied';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'y=(a+cx+ex^2)/(1+bx+dx^2+fx^3)';
status = ncmex('ATTPUT', cdfid, varname, 'equation', 2, length(att_val), att_val) ;
att_val = 'a= 0.02300185641971347 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_a', 2, length(att_val), att_val) ;
att_val = 'b= -0.3760112491643825 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_b', 2, length(att_val), att_val) ;
att_val = 'c= 1.050386710451692 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_c', 2, length(att_val), att_val) ;
att_val = 'd= 0.004038376442503992 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_d', 2, length(att_val), att_val) ;
att_val = 'e= -0.3625570586137006 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_e', 2, length(att_val), att_val) ;
att_val = 'f= 0.00128412385484703 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_f', 2, length(att_val), att_val) ;

varname = 'energyMonitor';
status = ncmex('VARDEF', cdfid, 'energyMonitor', datatype, 1, 0);
att_val = 'average laser pulse energy';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'microjoules';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_afterpulse';
status = ncmex('VARDEF', cdfid, 'copol_afterpulse', datatype, 1, 1);
att_val = 'afterpulse subtracted from copol channel';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/usec';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_samples';
status = ncmex('VARDEF', cdfid, 'copol_samples', datatype, 1, 0);
att_val = 'number of copol samples per average';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'count';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_zerobin';
status = ncmex('VARDEF', cdfid, 'copol_zerobin', datatype, 1, 0);
att_val = 'original location of copol zero bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_bg';
status = ncmex('VARDEF', cdfid, 'copol_bg', datatype, 1, 0);
att_val = 'co-polarized background';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_cts';
status = ncmex('VARDEF', cdfid, 'copol_cts', datatype, 2, [0 1]);
att_val = 'co-polarized counts';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'background subtracted, deadtime corrected, afterpulse subtracted';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'copol_std';
status = ncmex('VARDEF', cdfid, 'copol_std', datatype, 2, [0 1]);
att_val = 'copol sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_noise';
status = ncmex('VARDEF', cdfid, 'copol_noise', datatype, 2, [0 1]);
att_val = 'copol sample statistical noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_prof';
status = ncmex('VARDEF', cdfid, 'copol_prof', datatype, 2, [0 1]);
att_val = 'co-polarized range-corrected backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;


varname = 'crosspol_afterpulse';
status = ncmex('VARDEF', cdfid, 'crosspol_afterpulse', datatype, 1, 1);
att_val = 'afterpulse subtracted from crosspol channel';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/usec';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_samples';
status = ncmex('VARDEF', cdfid, 'crosspol_samples', datatype, 1, [0]);
att_val = 'number of crosspol samples per average';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'count';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_zerobin';
status = ncmex('VARDEF', cdfid, 'crosspol_zerobin', datatype, 1, 0);
att_val = 'original location of crosspol zero bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_bg';
status = ncmex('VARDEF', cdfid, 'crosspol_bg', datatype, 1, [0]);
att_val = 'cross-polarized background';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_cts';
status = ncmex('VARDEF', cdfid, 'crosspol_cts', datatype, 2, [0 1]);
att_val = 'cross-polarized backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'background subtracted, deadtime corrected, afterpulse subtracted';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'crosspol_std';
status = ncmex('VARDEF', cdfid, 'crosspol_std', datatype, 2, [0 1]);
att_val = 'crosspol sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_noise';
status = ncmex('VARDEF', cdfid, 'crosspol_noise', datatype, 2, [0 1]);
att_val = 'crosspol sample statistical noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_prof';
status = ncmex('VARDEF', cdfid, 'crosspol_prof', datatype, 2, [0 1]);
att_val = 'cross-polarized range-corrected backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_cts';
status = ncmex('VARDEF', cdfid, 'total_cts', datatype, 2, [0 1]);
att_val = 'combined backscatter components';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_prof';
status = ncmex('VARDEF', cdfid, 'total_prof', datatype, 2, [0 1]);
att_val = 'combined range-corrected backscatter components';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_noise';
status = ncmex('VARDEF', cdfid, 'total_noise', datatype, 2, [0 1]);
att_val = 'quadrature combined sample noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_std';
status = ncmex('VARDEF', cdfid, 'total_std', datatype, 2, [0 1]);
att_val = 'quadrature combined sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'sample_stability';
status = ncmex('VARDEF', cdfid, 'sample_stability', datatype, 2, [0 1]);
att_val = 'sample relative stability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'low values indicate stable conditions';
status = ncmex('ATTPUT', cdfid, varname, 'Comment', 2, length(att_val), att_val) ;

varname = 'depolarization';
status = ncmex('VARDEF', cdfid, 'depolarization', datatype, 2, [0 1]);
att_val = 'linear depolarization ratio';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'dpr = crosspol_cts/copol_cts';
status = ncmex('ATTPUT', cdfid, varname, 'equation', 2, length(att_val), att_val) ;
att_val = 'No depolarization = 0';
status = ncmex('ATTPUT', cdfid, varname, 'comment_1', 2, length(att_val), att_val) ;
att_val = 'Full depolarization = 1';
status = ncmex('ATTPUT', cdfid, varname, 'comment_2', 2, length(att_val), att_val) ;

varname = 'lat';
status = ncmex('VARDEF', cdfid, 'lat', datatype, 0, [0]);
att_val = 'north latitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'lon';
status = ncmex('VARDEF', cdfid, 'lon', datatype, 0, [0]);
att_val = 'east longitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'alt';
status = ncmex('VARDEF', cdfid, 'alt', datatype, 0, [0]);
att_val = 'altitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'meters above Mean Sea Level';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

ncmex('endef', cdfid);

%[status] = nc_putvar(mplret_id, 'lidar_C', mpl.cal.C);
[status] = nc_putvar(cdfid, 'depolarization', mplps.dpr);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_cts', mplps.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'overlap_corr', mplps.overlap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_prof', mplps.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_afterpulse', mplps.crosspol.ap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_cts', mplps.crosspol.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_prof', mplps.crosspol.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_noise', mplps.crosspol.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_std', mplps.crosspol.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_samples', mplps.crosspol.samples);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_bg', mplps.crosspol.bg);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_zerobin', mplps.crosspol.zerobin);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'copol_afterpulse', mplps.copol.ap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_cts', mplps.copol.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_prof', mplps.copol.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_noise', mplps.copol.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_std', mplps.copol.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_noise', mplps.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_std', mplps.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'sample_stability', mplps.sample_stability);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_samples', mplps.copol.samples);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_bg', mplps.copol.bg);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_zerobin', mplps.copol.zerobin);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'energyMonitor', mplps.energy_monitor);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'range', mplps.range);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'base_time', base_time);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'time_offset',time_offset );
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'time', time);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'julian_day',serial2doy0(mplps.time));
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'deadtime_corrected', 1);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'alt', mplps.statics.alt);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'lon', mplps.statics.lon);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'lat', mplps.statics.lat);
if status<0
   keyboard;
end

ncmex('close', cdfid);
return