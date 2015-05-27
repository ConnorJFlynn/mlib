function [status, radar] = ingest_parslradar_file(infile);

if ~exist('infile','var')
    [fname, pname] = uigetfile('parsl*.dat');
    infile = [pname, fname];
end
if ~exist(infile, 'file')
    display(['Selected file ',infile, ' does not exist.  Select another please.']);
    [fname, pname] = uigetfile('parsl*.dat');
    if length(pname)>0
      infile = [pname, fname];
    else
        status = -1;
        radar = [];
        return
    end
end

magic_constant = 10^-13.0687;

disp(['loading moments data ...' file_name]);
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name);

disp('estimating noise floor ...');
good_times=find(mean_mean_I2(10,:)>0);
[power(:,good_times),noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_mean_I(:,good_times),mean_mean_Q(:,good_times),mean_mean_I2(:,good_times),mean_mean_Q2(:,good_times));

% /* put range factor in dBZ */
disp('applying range correction ...')  
power2 = power .* (range'.^2 * ones([1,size(power,2)]));
% Convert time to ARM style 

date_array = sscanf(desired_date,'%4d%2d%2d');
year = date_array(1);
month = date_array(2);
day = date_array(3);
hour = floor(times(1));
fminute = (times(1) - hour)*60;
minute = floor(fminute);
second = floor(fminute-minute)*60;
base_time = date2epoch(year,month,day,hour,minute,second);
tseconds = times*3600;
time_offset = tseconds - tseconds(1);

% Write data to NetCDF file
radar = ancload('E:twpice\proc_data\radar\twpice_parsl.radarmoments.template.nc');
radar.fname = ['E:\twpice\proc_data\radar\twpice_parsl.radarmoments.nc'];
radar.vars.range.data = mean_range(1:nrange);
radar.vars.base_time.data = base_time;
radar.vars.time_offset.data = time_offset;
mean_power2 = mean_power2(1:nrange,:);
mean_mean_velocity = mean_mean_velocity(1:nrange,:);
mean_mean_width = mean_mean_width(1:nrange,:);
radar.vars.Doppler_Velocity.data = mean_mean_velocity;
radar.vars.Doppler_Width.data = mean_mean_width;
clear mean_mean_velocity mean_mean_width
radar.vars.Reflectivity.data = 10*log10(mean_power2*magic_constant)';
clear mean_power2
%Get real lat, lon, alt values...
radar.vars.lat.data = 0;
radar.vars.lon.data = 0;
radar.vars.alt.data = 0;
radar.clobber = 1>0;

radar = anccheck(radar);
ancsave(radar);

