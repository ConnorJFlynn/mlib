function status = define_ipasmpl_a1(cdfid, in_time, range, statics);
% status = define_ipasmpl_a1(cdfid, in_time, range, statics);
% Defines a ipasmpl.a1 file
% Principle difference between a0 and a1 is deadtime correction

if cdfid>0
   %% Define new file:

   status = ncmex('DIMDEF', cdfid, 'time', 0);
   status = ncmex('DIMDEF', cdfid, 'range', length(range));
   status = define_globals(cdfid, statics);
   status = define_fields(cdfid, in_time, length(range), statics);
   status = ncmex('ENDEF', cdfid);
   status = put_mpl_statics(cdfid, in_time, range, statics);

else
   disp('Bad netcdf file id provided!');
   pause
end
end

function status = define_globals(cdfid, statics);
% status = define_globals(cdfid);
% An internal function to define global attributes in ipa_ps.a0 netcdf file
att_name = 'proc_level';
att_val = statics.datalevel;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'input_source';
att_val = ['raw mpl data file in prototype SESI PS mode'];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'datastream';
att_val = statics.datastream;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'datalevel';
att_val = statics.datalevel;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'polarized';
att_val = statics.polarized;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'ocr';
att_val = statics.ocr;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'scanning';
att_val = statics.scanning;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'site_id';
att_val = 'ipa';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'facility_id';
att_val = 'C1 : Indiana University, Indiana, Pennsylvania';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'averaging_int';
att_val = statics.averaging_int;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'range_bin_time';
att_val = statics.range_bin_time;
att_datatype = 4; %long=4
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'pulse_rep';
att_val = statics.pulse_rep;
att_datatype = 4; %long=4
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

% att_name = 'shots_summed';
% att_val = statics.shots_summed;
% att_datatype = 4; %long=4
% status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'deadtime_corrected';
att_val = 'yes';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'apd';
att_val = 'SN_XXXX';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'dtc_function';
att_val = 'Matlab dtc function name';
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
att_val = [num2str(statics.unitSN)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'zeb_platform';
att_val = statics.datastream;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'history';
att_val = ['Created by CJF on ', datestr(now)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;
end

function status = define_fields(cdfid, in_time, range, statics);
year = str2num(datestr(in_time, 10));
epoch = serial2epoch(in_time);
day_of_year = floor(serial2doy0(in_time));

base_time = min(epoch);
base_time_str = [datestr(min(in_time),31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy0(in_time) - day_of_year) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(in_time),31) ' GMT' ];

day_of_year_long_name = 'Day Of Year';
day_of_year_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
day_of_year_comment = ['For example: Jan 1 6:00 AM = 0.25'];

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


status = ncmex('VARDEF', cdfid, 'doy', 6, ndims, dim_ids);
status = ncmex('ATTPUT', cdfid, 'doy','long_name', 2, length(day_of_year_long_name), day_of_year_long_name);
status = ncmex('ATTPUT', cdfid, 'doy', 'units', 2 , length(day_of_year_units), day_of_year_units);
status = ncmex('ATTPUT', cdfid, 'doy', 'comment', 2 , length(day_of_year_comment), day_of_year_comment);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'doy', 'reference_point', 2 , length(att_val), att_val);

datatype = 5;
varname = 'range';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 1);
att_val = 'distance from lidar to the center of the bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'km';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
att_val = .03;
status = ncmex('ATTPUT', cdfid, varname, 'range_resolution', datatype, length(att_val), att_val);

varname = 'range_bin_time';
status = ncmex('VARDEF', cdfid, varname, datatype, 0, [0]);
att_val = 'range bin time resolution';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'ns';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'shots_summed';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'laser shots summed over measurement interval';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'zenith_angle';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'mirror angle with respect to zenith';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees N';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'energy_monitor';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'average laser pulse energy';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'mW';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'filter_temp';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'filter temperature discontinued';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'C';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'detector_temp';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'detector temperature';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'C';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'laser_temp';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'laserhead temperature';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'C';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'instrument_temp';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'telescope temperature';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'C';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'background_signal';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'ambient background count rate';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'pol_test_1';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'odd_even pol_mode test';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'boolean';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'copol=1, crosspol=0';
status = ncmex('ATTPUT', cdfid, varname, 'values', 2, length(att_val), att_val) ;
att_val = 'copol is given as the greater sum of odd and even profiles over the whole file';
status = ncmex('ATTPUT', cdfid, varname, 'test_summary', 2, length(att_val), att_val) ;

varname = 'pol_test_2';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'odd_even_span pol_mode test';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'boolean';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'copol=1, crosspol=0';
status = ncmex('ATTPUT', cdfid, varname, 'values', 2, length(att_val), att_val) ;
att_val = 'copol is given as the greater sum of odd and even profiles within a span of records';
status = ncmex('ATTPUT', cdfid, varname, 'test_summary', 2, length(att_val), att_val) ;

varname = 'pol_test_3';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'gt_mean_span pol_mode test';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'boolean';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'copol=1, crosspol=0';
status = ncmex('ATTPUT', cdfid, varname, 'values', 2, length(att_val), att_val) ;
att_val = 'copol is given as those records exceeding the mean signal level over a span of records ';
status = ncmex('ATTPUT', cdfid, varname, 'test_summary', 2, length(att_val), att_val) ;

varname = 'detector_counts';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
att_val = 'raw count rate';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'deadtime-corrected counts to MHz';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'statistical_noise';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
att_val = 'statistical noise in signal';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

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

end
      
%       fstem = ['ipamplpsC1.a0.'];
%       tmp_file = [ps_out_dir,fstem,'tmp'];
%       [d_str,t_str] = strtok(datestr(in_time,30),'T');
%       t_str = t_str(2:end);
%       hh_str = t_str(1:2);
%       hour_file = [fstem,d_str,'.',hh_str];
%       % If the temp file exists then copy
%       % the temp file into the desired target hourly file.
%       if exist(tmp_file,'file')
%          fid = fopen(tmp_file,'r');
%          tmp_data = fread(fid);
%          fclose(fid);
%          if ~exist([ps_out_dir,hour_file,'0000.nc'],'file')
%             out_file = [hour_file,'0000.nc'];
%          elseif (~exist([ps_out_dir,hour_file,t_str(3:end),'.nc'],'file'))
%             out_file = [hour_file,t_str(3:end),'.nc'];
%          else 
%             out_file = [hour_file,t_str(3:end),'.nc'];
%             n = 1;
%             while exist([ps_out_dir,out_file],'file')
%                n=n+1;
%                out_file = [hour_file,t_str(3:end),'.',num2str(n),'.nc'];
%             end
%          end
%          
%          fid = fopen([ps_out_dir,out_file],'w');
%          cnt = fwrite(fid,tmp_data);
%          fclose(fid);
%          cdfid = ncmex('open', [ps_out_dir, out_file]);

function  status = update_time_fields(cdfid, in_time);
year = str2num(datestr(in_time, 10));
epoch = serial2epoch(in_time);
day_of_year = floor(serial2doy0(in_time));

base_time = min(epoch);
base_time_str = [datestr(in_time,31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy0(in_time) - day_of_year) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(in_time),31) ' GMT' ];

day_of_year_long_name = 'Day of year';
day_of_year_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
day_of_year_comment = ['For example: Jan 1 6:00 AM = 0.25'];

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


status = ncmex('VARDEF', cdfid, 'day_of_year', 6, ndims, dim_ids);
status = ncmex('ATTPUT', cdfid, 'day_of_year','long_name', 2, length(day_of_year_long_name), day_of_year_long_name);
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'units', 2 , length(day_of_year_units), day_of_year_units);
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'comment', 2 , length(day_of_year_comment), day_of_year_comment);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'reference_point', 2 , length(att_val), att_val);
end

function status = put_mpl_statics(cdfid, time_in, range, statics);

if nargin<4
   statics.deadtime_corrected = 0;
end


[status] = nc_putvar(cdfid, 'range', range);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'base_time', serial2epoch(time_in));
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'range_bin_time', statics.range_bin_time);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'lat', statics.lat);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'lon', statics.lon);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'alt', statics.alt);
if status<0
   keyboard;
end

end