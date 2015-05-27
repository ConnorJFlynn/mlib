function rsr = read_rsr(filename);
% pname = 'D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\236\';
% fname = 'BCEE.040828.mtm';
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.*');
   filename = fullfile(pname, fname);
end
while ~exist(filename, 'file')
   [fname, pname] = uigetfile('*.*');
   filename = fullfile(pname, fname);
end

[this,that] = system(['tu -R -v quiet -H -d joe -x aezhdmst ', filename]);
%First line is header
nlines = find(that==10);
header = that(1:nlines(1)-1);
rsr.header.string = header;
that2 = that(nlines(1)+1:end);
[rsr.header.firmware_version, header] = strtok(header);
[rsr.header.logger_ID, header] = strtok(header);
[rsr.header.head_ID, header] = strtok(header);
[rsr.header.lon, header] = strtok(header);
[rsr.header.lat, header] = strtok(header);
[rsr.header.flags, header] = strtok(header);
[rsr.header.sample_rate, header] = strtok(header);
[rsr.header.avg_interval, header] = strtok(header);
[rsr.header.date_joe, header] = strtok(header);
[rsr.header.daysec, header] = strtok(header);
[rsr.header.nchannels, header] = strtok(header);
[rsr.header.daytime_channels, header] = strtok(header);
[rsr.header.alltime_channels, header] = strtok(header);
[rsr.header.counters, header] = strtok(header);
[rsr.header.datasize, header] = strtok(header);
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
rsr.vars.solar_azimuth.data = data(:,25);
rsr.vars.solar_elevation.data = data(:,26);
rsr.vars.solar_zenith.data = data(:,27);
rsr.vars.hour_angle.data = data(:,28);
rsr.vars.declination.data = data(:,29);
rsr.vars.airmass.data = data(:,30);
rsr.vars.solar_dist_au.data = data(:,31);
rsr.vars.solar_time.data = data(:,32);
for ch = 0:6;
   rsr.vars.(['th_ch',num2str(ch+1)]).data = data(:,3+ch);
   rsr.vars.(['dif_ch',num2str(ch+1)]).data = data(:,11+ch);
   rsr.vars.(['dirh_ch',num2str(ch+1)]).data = data(:,18+ch);
%   rsr.vars.(['dirh_ch',num2str(ch+1)]).data = data(:,25+ch);
end

% >> figure; plot(serial2doy0(rsr.time), 1./cos(pi*rsr.vars.solar_zenith.data/180), '.',serial2doy0(rsr.time), rsr.vars.airmass.data)
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.solar_zenith.data + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), acos(1./rsr.vars.airmass.data) + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), 180*acos(1./rsr.vars.airmass.data)/pi + rsr.vars.solar_elevation.data , '.')
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.hour_angle.data, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time), rsr.vars.hour_angle.data/15, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15, '.',serial2doy0(rsr.time), rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15 - rsr.vars.solar_time.data,'x')
% >> figure; plot(serial2doy0(rsr.time),12+ rsr.vars.hour_angle.data/15 - rsr.vars.solar_time.data,'.')
