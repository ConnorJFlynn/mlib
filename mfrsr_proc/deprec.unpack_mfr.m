function [rsr,fail] = unpack_mfr(filename);
% pname = 'D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\236\';
% fname = 'BCEE.040828.mtm';
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.*');
   filename = fullfile(pname, fname);
end
while ~exist(filename, 'file')
   if exist(filename, 'dir')
      [fname, pname] = uigetfile([filename,'*.*']);
   else
   [fname, pname] = uigetfile('*.*');
   end
   filename = fullfile(pname, fname);
end

[fail,that] = system(['tu -R -v quiet -H -d joe -x aezhdmst ', filename]);
fail = (fail~=0);
%First line is header
nlines = find(that==10);
header = that(1:nlines(1)-1);
rsr.header.string = header;
that2 = that(nlines(1)+1:end);
[rsr.header.firmware_version, header] = strtok(header);
rsr.header.firmware_version = sscanf(rsr.header.firmware_version ,'%g');
[rsr.header.logger_ID, header] = strtok(header);
[rsr.header.head_ID, header] = strtok(header);
[rsr.header.lat, header] = strtok(header);
rsr.header.lat = sscanf(rsr.header.lat,'%g');
[rsr.header.lon, header] = strtok(header);
rsr.header.lon = -sscanf(rsr.header.lon,'%g');
[rsr.header.flags, header] = strtok(header);
[rsr.header.sample_rate, header] = strtok(header);
rsr.header.sample_rate = sscanf(rsr.header.sample_rate,'%g');
[rsr.header.avg_interval, header] = strtok(header);
rsr.header.avg_interval = sscanf(rsr.header.avg_interval,'%g');
[rsr.header.date_joe, header] = strtok(header);
rsr.header.date_joe = sscanf(rsr.header.date_joe,'%g');
[rsr.header.daysec, header] = strtok(header);
rsr.header.daysec = sscanf(rsr.header.daysec,'%g');
[rsr.header.nchannels, header] = strtok(header);
rsr.header.nchannels = sscanf(rsr.header.nchannels,'%g');
[rsr.header.daytime_channels, header] = strtok(header);
rsr.header.daytime_channels = sscanf(rsr.header.daytime_channels,'%g');
[rsr.header.alltime_channels, header] = strtok(header);
rsr.header.alltime_channels = sscanf(rsr.header.alltime_channels,'%g');
[rsr.header.counters, header] = strtok(header);
rsr.header.counters = sscanf(rsr.header.counters,'%g');
[rsr.header.datasize, header] = strtok(header);
rsr.header.datasize = sscanf(rsr.header.datasize,'%g');
[rsr.header.errors, header] = strtok(header);

nlines(1) = [];
thatnum = sscanf(that2, '%g');
data = zeros([length(thatnum)/length(nlines), length(nlines)]);
data(:) = thatnum;
data = data';
rsr.time = data(:,1)-1 + datenum('1900-01-01', 'yyyy-mm-dd');
SRT = data(:,2);
SRT = 6810 * (5000 ./ SRT - 1);
SRT  = 1.030852e-3 + 2.389179e-4 .* log(SRT) + 1.574641e-07 .* log(SRT).^3;
SRT  = 1.0 ./ SRT - 273.12;
rsr.vars.logger_T.data = SRT;
rsr.vars.logger_V.data = data(:,10)*6/1000;
rsr.vars.solar_azimuth.data = data(:,32);
rsr.vars.solar_elevation.data = data(:,33);
rsr.vars.solar_zenith.data = data(:,34);
rsr.vars.hour_angle.data = data(:,35);
rsr.vars.declination.data = data(:,36);
rsr.vars.airmass.data = data(:,37);
rsr.vars.solar_dist_au.data = data(:,38);
rsr.vars.solar_time.data = data(:,39);
for ch = 0:6;
   rsr.vars.(['alltime_ch',num2str(ch+1)]).data = data(:,3+ch);
   missed = find(rsr.vars.(['alltime_ch',num2str(ch+1)]).data < -99);
   rsr.vars.(['alltime_ch',num2str(ch+1)]).data(missed) = NaN;

   rsr.vars.(['th_ch',num2str(ch+1)]).data = data(:,11+ch);
   missed = find(rsr.vars.(['th_ch',num2str(ch+1)]).data < -99);
   rsr.vars.(['th_ch',num2str(ch+1)]).data(missed) = NaN;
   
   rsr.vars.(['dif_ch',num2str(ch+1)]).data = data(:,18+ch);
   missed = find(rsr.vars.(['dif_ch',num2str(ch+1)]).data < -99);
   rsr.vars.(['dif_ch',num2str(ch+1)]).data(missed) = NaN;

   rsr.vars.(['dirh_ch',num2str(ch+1)]).data = data(:,25+ch);
   missed = find(rsr.vars.(['dirh_ch',num2str(ch+1)]).data < -99);
   rsr.vars.(['dirh_ch',num2str(ch+1)]).data(missed) = NaN;

end


rsr.dims.time.id = 0;
rsr.dims.time.isunlim = 1;
rsr.recdim.name = 'time';
rsr.recdim.id = 0;
rsr.vars.lat.data = rsr.header.lat;
rsr.vars.lon.data = rsr.header.lon; 
rsr.vars.alt.data = NaN;
rsr.atts.head_id.data = rsr.header.head_ID;
rsr.atts.head_id.datatype = 2;
rsr.atts.logger_id.data = rsr.header.logger_ID;
rsr.atts.logger_id.datatype = 2;
rsr.atts.serial_number.data = rsr.header.logger_ID;
rsr.atts.serial_number.datatype = 2;

rsr = timesync(rsr);
rsr = anccheck(rsr);

% >> figure; plot(serial2doy0(rsr.time), 1./cos(pi*rsr.vars.solar_zenith.data/180), '.',serial2doy0(rsr.time), rsr.vars.airmass.data)
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.solar_zenith.data + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), acos(1./rsr.vars.airmass.data) + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), 180*acos(1./rsr.vars.airmass.data)/pi + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.hour_angle.data, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.hour_angle.data/15, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15 - rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15 - rsr.vars.solar_time.data,'.')
