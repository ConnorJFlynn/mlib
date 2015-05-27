function status = output_ocr_hour_mavg(ocr_hour_mavg, statics);

%Determine filename and open it.
dir_out = statics.pname;
fstem = statics.fstem;
[d_str,t_str] = strtok(datestr(ocr_hour_mavg.time(1),30),'T');
hh_str = t_str(2:3);
full_name = [dir_out,fstem,'.',d_str,'.',hh_str,'0000.nc'];
[ncid, rcode] = ncmex('create', full_name, 'clobber');
dims.time = ocr_hour_mavg.time;
dims.range = ocr_hour_mavg.range;
dims.height = ocr_hour_mavg.height;
%dims.ol_range = ocr_hour_mavg.range;
dims.fixed_angles = ocr_hour_mavg.fixed_angles;
ocr.statics = ocr_hour_mavg.statics;
ocr.statics.datalevel = statics.datalevel;
ocr.statics.proc_level = statics.datalevel;
ocr.statics.datastream = statics.datastream;
ocr.statics.zeb_platform = statics.datastream;
ocr.statics.ocr = statics.ocr;
ocr.statics.averaging_int = statics.averaging_int;
ocr.statics.pname = statics.pname;

status = define_ocr_mavg_rprof_c1(ncid, dims, ocr.statics);
status = write_ocr_mavg_rprof_c1(ncid, ocr_hour_mavg);
ncmex('close', ncid);

end %end output_hour_mavg


function status = define_ocr_mavg_rprof_c1(cdfid, dims, statics);
% status = define_ocr_mavg_rprof_c1(ncid, dims, statics);;
% Defines ipa mirror-averaged range-profile data file
% Not interpolated to vertical heights yet

if cdfid>0
    %% Define new file:

    status = ncmex('DIMDEF', cdfid, 'time', 0);
    status = ncmex('DIMDEF', cdfid, 'range', length(dims.range));
    status = ncmex('DIMDEF', cdfid, 'height', length(dims.height));
%     status = ncmex('DIMDEF', cdfid, 'ol_range', length(dims.ol_range));
    status = ncmex('DIMDEF', cdfid, 'fixed_angles', length(dims.fixed_angles));
    status = define_globals(cdfid, statics);
    status = define_fields(cdfid, dims, statics);
    status = ncmex('ENDEF', cdfid);
    status = put_mpl_statics(cdfid, dims, statics);

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
att_val = statics.apd;
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'dtc_function';
att_val = statics.dtc_function;
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

function status = define_fields(cdfid, dims, statics);
in_time = dims.time(1);
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

% status = ncmex('VARDEF', cdfid, 'time', datatype, ndims, dim_ids);
% att_val = 'time in seconds since midnight';
% status = ncmex('ATTPUT', cdfid, 'time','long_name', 2, length(time_long_name), time_long_name);
% status = ncmex('ATTPUT', cdfid, 'time', 'units', 2 ,length(time_units), time_units);
% att_val = 'times are referenced to the center of the averaging interval';
% status = ncmex('ATTPUT', cdfid, 'time', 'reference_point', 2 , length(att_val), att_val);

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


datatype = 5;
varname = 'height';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 2);
att_val = 'projected vertical height AGL';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'km';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
att_val = .0075;
status = ncmex('ATTPUT', cdfid, varname, 'range_resolution', datatype, length(att_val), att_val);

% 
% datatype = 5;
% varname = 'ol_range';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 2);
% att_val = 'distance from lidar to the center of the bin';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'km';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
% att_val = .03;
% status = ncmex('ATTPUT', cdfid, varname, 'range_resolution', datatype, length(att_val), att_val);

datatype = 5;
varname = 'fixed_angles';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 3);
att_val = 'mirror position measured from zenith';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
att_val = 1;
status = ncmex('ATTPUT', cdfid, varname, 'resolution', datatype, length(att_val), att_val);
att_val = 'positive zenith angles are toward the north';
status = ncmex('ATTPUT', cdfid, varname, 'orientation', 2, length(att_val), att_val);

varname = 'range_bin_time';
status = ncmex('VARDEF', cdfid, varname, datatype, 0, [0]);
att_val = 'range bin time resolution';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'ns';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'scene_duration';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'duration of mirror position';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'seconds';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'nsamples';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'number of accumulates collected during mirror position';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'shots_summed';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'laser shots summed over measurement interval';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

% varname = 'copol_shots_summed';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'laser shots summed for copol over measurement interval';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'counts';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_shots_summed';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'laser shots summed for crosspol over measurement interval';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'counts';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

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

varname = 'energy_monitor_std';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'stddev of average laser pulse energy nsamples';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'mW';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

% varname = 'filter_temp';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'filter temperature discontinued';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'C';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

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

% varname = 'copol_nsamples';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'number of copol samples during mirror position';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_nsamples';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'number of crosspol samples during mirror position';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'ocr_nsamples';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'number of ocr samples during mirror position';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

% varname = 'copol_bg';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'copol ambient background count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_bg';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'copol ambient background count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'ocr_bg';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'ocr ambient background count rate';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'copol_bg_std';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'stddev of copol bg samples during mirror position';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_bg_std';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'stddev of crosspol bg samples during mirror position';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'ocr_bg_std';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'stddev of ocr bg samples during mirror position';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

% varname = 'copol_bg_noise';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'statistical noise in copol bg';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_bg_noise';
% status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
% att_val = 'statistical noise in crosspol bg';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'ocr_bg_noise';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 0);
att_val = 'statistical noise in ocr bg';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

% varname = 'bscat';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'combined (copol+crosspol) count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'bscat_noise';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'statistical noise in combined signal';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'bscat_snr';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'combined signal (copol+crosspol) snr';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

% varname = 'copol';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'copol count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'copol_noise';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'statistical noise in copol count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'copol_snr';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'copol snr';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'crosspol count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_noise';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'statistical noise in crosspol count rate';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;
% 
% varname = 'crosspol_snr';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'crosspol snr';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% att_val = 'deadtime-corrected counts to MHz';
% status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'ocr';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
att_val = 'overlap correction receiver count rate';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'deadtime-corrected counts to MHz';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'ocr_noise';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
att_val = 'statistical noise in ocr count rate';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'deadtime-corrected counts to MHz';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'ocr_snr';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
att_val = 'ocr snr';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'deadtime-corrected counts to MHz';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'height_prof';
status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 2]);
att_val = 'interpolated vertical profile';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'MHz';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;


% 
% varname = 'dpr';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'depolarization ratio (crosspol/copol)';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'unitless';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'dpr_snr';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 1]);
% att_val = 'signal to noise ratio of dpr';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'unitless';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'overlap';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [0 2]);
% att_val = 'overlap ratio (OCR/BSCAT)';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'unitless';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
% 
% varname = 'overlap_by_angle';
% status = ncmex('VARDEF', cdfid, varname, datatype, 2, [3 2]);
% att_val = 'overlap ratio (OCR/BSCAT)';
% status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
% att_val = 'unitless';
% status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

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

% status = ncmex('VARDEF', cdfid, 'time', datatype, ndims, dim_ids);
% att_val = 'time in seconds since midnight';
% status = ncmex('ATTPUT', cdfid, 'time','long_name', 2, length(time_long_name), time_long_name);
% status = ncmex('ATTPUT', cdfid, 'time', 'units', 2 ,length(time_units), time_units);
% att_val = 'times are referenced to the center of the averaging interval';
% status = ncmex('ATTPUT', cdfid, 'time', 'reference_point', 2 , length(att_val), att_val);


status = ncmex('VARDEF', cdfid, 'day_of_year', 6, ndims, dim_ids);
status = ncmex('ATTPUT', cdfid, 'day_of_year','long_name', 2, length(day_of_year_long_name), day_of_year_long_name);
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'units', 2 , length(day_of_year_units), day_of_year_units);
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'comment', 2 , length(day_of_year_comment), day_of_year_comment);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'day_of_year', 'reference_point', 2 , length(att_val), att_val);
end

function status = put_mpl_statics(cdfid, dims, statics);

if nargin<4
    statics.deadtime_corrected = 0;
end


[status] = nc_putvar(cdfid, 'range', dims.range);
if status<0
    keyboard;
end


[status] = nc_putvar(cdfid, 'height', dims.height);
if status<0
    keyboard;
end


% [status] = nc_putvar(cdfid, 'ol_range', dims.ol_range);
% if status<0
%     keyboard;
% end

[status] = nc_putvar(cdfid, 'fixed_angles', dims.fixed_angles);
if status<0
    keyboard;
end

[status] = nc_putvar(cdfid, 'base_time', serial2epoch(dims.time(1)));
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

function status = write_ocr_mavg_rprof_c1(cdfid, ocr);
% status = output_ipasmpl_a1(a1_ncid, mpl_a1_out);

epoch = serial2epoch(ocr.time);
base_time = min(epoch);
time_offset = epoch - base_time;

varname = 'time_offset';
[status] = nc_putvar(cdfid, varname, time_offset);

epoch_midnight = serial2epoch(floor(ocr.time(1)));
time = time_offset + (base_time - epoch_midnight);
varname = 'time';
% [status] = nc_putvar(cdfid, varname, time);

varname = 'doy';
[status] = nc_putvar(cdfid, varname, serial2doy0(ocr.time));
% varname = 'range';
% [status] = nc_putvar(cdfid, varname, dims.range);
% varname = 'ol_range';
% [status] = nc_putvar(cdfid, varname, dims.ol_range);
% 
% varname = 'fixed_angles';
% [status] = nc_putvar(cdfid, varname, dims.fixed_angles);

%varname = 'range_bin_time';

varname = 'nsamples';
[status] = nc_putvar(cdfid, varname, ocr.hk.nsamples);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'scene_duration';
[status] = nc_putvar(cdfid, varname, ocr.hk.span);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'shots_summed';
[status] = nc_putvar(cdfid, varname, ocr.hk.shots_summed);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'copol_shots_summed';
% [status] = nc_putvar(cdfid, varname, ocr.hk.cop_shots_summed);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_shots_summed';
% [status] = nc_putvar(cdfid, varname, ocr.hk.crs_shots_summed);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'zenith_angle';
[status] = nc_putvar(cdfid, varname, ocr.hk.zenith_angle);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'energy_monitor';
[status] = nc_putvar(cdfid, varname, ocr.hk.energy_monitor);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'energy_monitor_std';
[status] = nc_putvar(cdfid, varname, ocr.hk.energy_monitor_std);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'detector_temp';
[status] = nc_putvar(cdfid, varname, ocr.hk.detector_temp);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'laser_temp';
[status] = nc_putvar(cdfid, varname, ocr.hk.laser_temp);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'instrument_temp';
[status] = nc_putvar(cdfid, varname, ocr.hk.instrument_temp);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'copol_nsamples';
% [status] = nc_putvar(cdfid, varname, ps.hk.cop_nsamples);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_nsamples';
% [status] = nc_putvar(cdfid, varname, ps.hk.crs_nsamples);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'ocr_nsamples';
[status] = nc_putvar(cdfid, varname, ocr.hk.nsamples);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'copol_bg';
% [status] = nc_putvar(cdfid, varname, ps.hk.cop_bg);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_bg';
% [status] = nc_putvar(cdfid, varname, ps.hk.crs_bg);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'ocr_bg';
[status] = nc_putvar(cdfid, varname, ocr.hk.bg);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'copol_bg_std';
% [status] = nc_putvar(cdfid, varname, ps.hk.cop_bg_std);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_bg_std';
% [status] = nc_putvar(cdfid, varname, ps.hk.crs_bg_std);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'ocr_bg_std';
[status] = nc_putvar(cdfid, varname, ocr.hk.bg_std);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'copol_bg_noise';
% [status] = nc_putvar(cdfid, varname, ps.hk.cop_bg_noise);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_bg_noise';
% [status] = nc_putvar(cdfid, varname, ps.hk.crs_bg_noise);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'ocr_bg_noise';
[status] = nc_putvar(cdfid, varname, ocr.hk.bg_noise);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'bscat';
% [status] = nc_putvar(cdfid, varname, ps.range_prof);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'bscat_noise';
% [status] = nc_putvar(cdfid, varname, ps.range_prof_noise);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'bscat_snr';
% [status] = nc_putvar(cdfid, varname, ps.range_prof_snr);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'copol';
% [status] = nc_putvar(cdfid, varname, ps.copol);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'copol_noise';
% [status] = nc_putvar(cdfid, varname, ps.cop_noise);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'copol_snr';
% [status] = nc_putvar(cdfid, varname, ps.cop_snr);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol';
% [status] = nc_putvar(cdfid, varname, ps.crosspol);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_noise';
% [status] = nc_putvar(cdfid, varname, ps.crs_noise);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'crosspol_snr';
% [status] = nc_putvar(cdfid, varname, ps.crs_snr);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
varname = 'ocr';
[status] = nc_putvar(cdfid, varname, ocr.range_prof);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'ocr_noise';
[status] = nc_putvar(cdfid, varname, ocr.noise_MHz);
if status<0
    disp(['Problem writing ' varname,'!']);
end
varname = 'ocr_snr';
[status] = nc_putvar(cdfid, varname, ocr.range_prof_snr);
if status<0
    disp(['Problem writing ' varname,'!']);
end

varname = 'height_prof';
[status] = nc_putvar(cdfid, varname, ocr.height_prof);
if status<0
    disp(['Problem writing ' varname,'!']);
end
% varname = 'dpr';
% [status] = nc_putvar(cdfid, varname, ps.dpr);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'dpr_snr';
% [status] = nc_putvar(cdfid, varname, ps.dpr_snr);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'overlap';
% [status] = nc_putvar(cdfid, varname, ps.overlap);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
% varname = 'overlap_by_angle';
% [status] = nc_putvar(cdfid, varname, ps.overlap_by_angle);
% if status<0
%     disp(['Problem writing ' varname,'!']);
% end
end