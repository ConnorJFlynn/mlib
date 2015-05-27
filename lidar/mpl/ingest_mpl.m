function mpl_nc = ingest_mpl(mpl, mpl_nc, pname);
%mpl_nc = ingest_mpl(mpl, mpl_nc, pname);
%Convert data in mpl struct to populate mpl netcdf structure and save to
%output directory pname
if nargin==0
    mpl = read_mpl;
end
if nargin<2
    mpl_nc = nclink;
end
if nargin < 3
    [pname, mpl_in, mpl_ext] = fileparts(mpl_nc.fname);
    pname = uigetdir(pname, 'Select the outgoing directory:');
    pname = [pname, '\'];
end
% So we now have an MPL struct and an empty netcdf struct for an MPL file.
% First we might as well determine the time fields.
mpl_nc = set_time_fields(mpl_nc, mpl.time);
mpl_nc = populate_metadata(mpl_nc, mpl);
mpl_nc = populate_data_fields(mpl_nc, mpl);
mpl_nc.fname = armify_filename(pname, 'sgpmplS1.aliveIOP.', mpl.time(1));
status = ncsave(mpl_nc);


function mpl_nc = set_time_fields(mpl_nc, in_time);
mpl_nc.dims.time.length = length(in_time);
mpl_nc.vars.base_time.data = serial2epoch(in_time(1));
mpl_nc.vars.base_time.atts.string.data = [datestr(in_time(1), 'dd-mmm-yyyy,HH:MM:SS'), ' GMT'];

mpl_nc.vars.time_offset.data = serial2epoch(in_time)-serial2epoch(in_time(1));
mpl_nc.vars.time_offset.atts.units.data = ['seconds since ',datestr(in_time(1), 'yyyy-mm-dd HH:MM:SS'), ' 0:00' ];

mpl_nc.vars.time.data = serial2epoch((in_time))-serial2epoch(floor(in_time(1)));
mpl_nc.vars.time.atts.units.data = ['seconds since ',datestr(floor(in_time(1)), 'yyyy-mm-dd HH:MM:SS'), ' 0:00' ];

function mpl_nc = populate_metadata(mpl_nc, mpl);
mpl_nc.atts.ingest_software.data = 'Matlab ingest';
mpl_nc.atts.input_source.data = ['mpl.00.raw: ', mpl.statics.filename];
mpl_nc.atts.facility_id.data = 'S1: GIF trailer';
mpl_nc.atts.sample_int.data = [num2str(serial2epoch(mpl.time(2))-serial2epoch(mpl.time(1))), ' seconds'];
mpl_nc.atts.location_description.data = 'SGP Central Facility, GIF trailer';
mpl_nc.atts.input_file_format.data = 'ASRC / new NASA format';
mpl_nc.atts.averaging_int.data = [num2str(serial2epoch(mpl.time(2))-serial2epoch(mpl.time(1))), ' seconds'];
mpl_nc.atts.serial_number.data = mpl.statics.unitSN;
mpl_nc.zeb_platform.data = 'sgpmplS1.aliveIOP.';

function mpl_nc = populate_data_fields(mpl_nc, mpl);
mpl_nc.vars.range_bins.data = [1:length(mpl.range)];
mpl_nc.vars.shots_summed.data = mpl.hk.shots_summed;
mpl_nc.vars.pulse_rep.data = ones(size(mpl.time))*mpl.statics.pulse_rep;
mpl_nc.vars.energy_monitor.data = mpl.hk.energy_monitor;
mpl_nc.vars.detector_temp.data = mpl.hk.detector_temp;
mpl_nc.vars.filter_temp.data = mpl.hk.filter_temp;
mpl_nc.vars.instrument_temp.data = mpl.hk.instrument_temp;
mpl_nc.vars.laser_temp.data = mpl.hk.laser_temp;
mpl_nc.vars.voltage_05.data = mpl.hk.voltage_05;
mpl_nc.vars.voltage_10.data = mpl.hk.voltage_10;
mpl_nc.vars.voltage_15.data = mpl.hk.voltage_15;
mpl_nc.vars.preliminary_cbh.data = mpl.hk.cbh;
mpl_nc.vars.background_signal.data = mpl.hk.bg;
mpl_nc.vars.range_bin_time.data = ones(size(mpl.time))*mpl.statics.range_bin_time;
mpl_nc.vars.range_bin_width.data = ones(size(mpl.time))*(mpl.range(2) - mpl.range(1));
mpl_nc.vars.max_altitude.data = ones(size(mpl.time))*(mpl.statics.maxAltitude);
mpl_nc.vars.detector_counts.data = mpl.rawcts;
mpl_nc.vars.range_offset.data = ones(size(mpl.time))*(find(mpl.range==0));
mpl_nc.vars.range.data = mpl.range;
mpl_nc.vars.height.data = mpl.range;
mpl_nc.vars.assumed_zero_range_bin.data = ones(size(mpl.time))*(0);
mpl_nc.vars.lat.data = 36.6059999;
mpl_nc.vars.lon.data = -97.485001;
mpl_nc.vars.alt.data = 316;

function nc_fname = armify_filename(pname, stem, start_time);
datestamp = datestr(start_time, 'yyyymmdd.');
if ~exist([pname, stem, datestamp, '000000.nc', 'file'])
    nc_fname = [pname, stem, datestamp, '000000.nc'];
else
    timestamp = datestr(start_time, 'HHMMSS.');
    nc_fname = [pname, stem, datestamp, timestamp, '.nc'];
end
    
