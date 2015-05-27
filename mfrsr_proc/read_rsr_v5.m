function rsr = read_rsr_v5(filename);
% pname = 'D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\236\';
% fname = 'BCEE.040828.mtm';
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.*');
   filename = fullfile(pname, fname);
end
if ~exist(filename, 'file')|(exist(filename, 'dir'))
   if exist(filename, 'dir')
      [fname, pname] = uigetfile([filename,'/','*.*']);
   else
      [fname, pname] = uigetfile(['*.*']);
   end;
   filename = [pname, fname];
end

if exist(filename, 'file')&~exist(filename, 'dir')
   [this,that] = system(['tu -R -v quiet -H -d joe -x aezhdmst ', filename]);
   %First line is header
   rsr.fname = filename;
   nlines = find(that==10);
   header = that(1:nlines(1)-1);
   rsr.header.string = header;
   that2 = that(nlines(1)+1:end);
   [rsr.header.firmware_version, header] = strtok(header);
   if sscanf(rsr.header.firmware_version,'%g')==13
      [rsr.header.logger_ID, header] = strtok(header);
      [rsr.header.head_ID, header] = strtok(header);
      [rsr.header.lat, header] = strtok(header);
      [rsr.header.lon, header] = strtok(header);
      [rsr.header.flags, header] = strtok(header);
      flags = sscanf(rsr.header.flags,'%x');
      [rsr.header.sample_rate, header] = strtok(header);
      [rsr.header.avg_interval, header] = strtok(header);
      [rsr.header.date_joe, header] = strtok(header);
      [rsr.header.daysec, header] = strtok(header);
      [rsr.header.nchannels, header] = strtok(header);
      nchannels = sscanf(rsr.header.nchannels,'%x');
      [rsr.header.daytime_channels, header] = strtok(header);
      daytime_channels = sscanf(rsr.header.daytime_channels,'%x');
      [rsr.header.alltime_channels, header] = strtok(header);
      alltime_channels = sscanf(rsr.header.alltime_channels,'%x');
      [rsr.header.counters, header] = strtok(header);
      counters = sscanf(rsr.header.counters, '%x');
      [rsr.header.datasize, header] = strtok(header);
      [rsr.header.errors, header] = strtok(header);
      nlines(1) = [];
      thatnum = sscanf(that2, '%g');
      data = zeros([length(thatnum)/length(nlines), length(nlines)]);
      data(:) = thatnum;
      data = data';
      place = 1;
      rsr.time = data(:,place)-1 + datenum('1900-01-01', 'yyyy-mm-dd');
      place = place + 1;
      if bitget(alltime_channels,1)
         SRT = data(:,place);
         place = place + 1;
         SRT = 6810 * (5000 ./ SRT - 1);
         SRT  = 1.030852e-3 + 2.389179e-4 .* log(SRT) + 1.574641e-07 .* log(SRT).^3;
         SRT  = 1.0 ./ SRT - 273.12;
         rsr.vars.logger_T.data = SRT;
      end
      for ch = 1:7
         if bitget(alltime_channels,ch+1)
            rsr.vars.(['alltime_ch',num2str(ch)]).data = data(:,place);
            place = place + 1;
         end
      end
      if bitget(alltime_channels,9)
         rsr.vars.logger_V.data = data(:,place)*6/1000;
         place = place + 1;
      end
      if bitget(flags,6) % We have shadowband data
         for ch = 1:7
            rsr.vars.(['th_ch',num2str(ch+1)]).data = data(:,place);
            place = place + 1;
            NaNs = find(rsr.vars.(['th_ch',num2str(ch+1)]).data<-9000);
            rsr.vars.(['th_ch',num2str(ch+1)]).data(NaNs) = NaN;
         end
         for ch=1:7
            rsr.vars.(['dif_ch',num2str(ch+1)]).data = data(:,place);
            place = place + 1;
            NaNs = find(rsr.vars.(['dif_ch',num2str(ch+1)]).data<-9000);
            rsr.vars.(['dif_ch',num2str(ch+1)]).data(NaNs) = NaN;
         end
         for ch=1:7
            rsr.vars.(['dirhor_ch',num2str(ch+1)]).data = data(:,place);
            place = place + 1;
            NaNs = find(rsr.vars.(['dirhor_ch',num2str(ch+1)]).data<-9000);
            rsr.vars.(['dirhor_ch',num2str(ch+1)]).data(NaNs) = NaN;
         end
      end
      rsr.vars.solar_azimuth.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_elevation.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_zenith.data = data(:,place);
      place = place + 1;
      rsr.vars.hour_angle.data = data(:,place);
      place = place + 1;
      rsr.vars.declination.data = data(:,place);
      place = place + 1;
      rsr.vars.airmass.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_dist_au.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_time.data = data(:,place);
      place = place + 1;
   else %we have old logger firmware < 13
      [rsr.header.logger_ID, header] = strtok(header);
      [rsr.header.head_ID] = '';
      [rsr.header.lat, header] = strtok(header);
      [rsr.header.lon, header] = strtok(header);
      [rsr.header.flags, header] = strtok(header);
      flags = sscanf(rsr.header.flags,'%x');
      [rsr.header.aux_channels, header] = strtok(header);
      aux_channels = sscanf(rsr.header.aux_channels, '%x');
      [rsr.header.bipol_channels, header] = strtok(header);
      bipol_channels = sscanf(rsr.header.bipol_channels, '%x');
      [rsr.header.sample_rate, header] = strtok(header);
      [rsr.header.avg_interval, header] = strtok(header);
      [rsr.header.date_joe, header] = strtok(header);
      [rsr.header.daysec, header] = strtok(header);
      [rsr.header.active_channels, header] = strtok(header);
      active_channels = sscanf(rsr.header.active_channels, '%x');
      [rsr.header.datasize, header] = strtok(header);
      nlines(1) = [];
      thatnum = sscanf(that2, '%g');
      data = zeros([length(thatnum)/length(nlines), length(nlines)]);
      data(:) = thatnum;
      data = data';
      place = 1;
      rsr.time = data(:,place)-1 + datenum('1900-01-01', 'yyyy-mm-dd');
      rsr.time = rsr.time';
      place = place + 1;

      for ch = 1:7
         rsr.vars.(['th_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(rsr.vars.(['th_ch',num2str(ch)]).data<-9000);
         rsr.vars.(['th_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      for ch = 1:7
         rsr.vars.(['dif_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(rsr.vars.(['dif_ch',num2str(ch)]).data<-9000);
         rsr.vars.(['dif_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      for ch = 1:7
         rsr.vars.(['dirhor_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(rsr.vars.(['dirhor_ch',num2str(ch)]).data<-9000);
         rsr.vars.(['dirhor_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      rsr.vars.logger_V.data = data(:,place)*6/1000;
      place = place + 1;
      SRT = data(:,place);
      place = place + 1;
      SRT = 6810 * (5000 ./ SRT - 1);
      SRT  = 1.030852e-3 + 2.389179e-4 .* log(SRT) + 1.574641e-07 .* log(SRT).^3;
      SRT  = 1.0 ./ SRT - 273.12;
      rsr.vars.logger_T.data = SRT;
      
      rsr.vars.solar_azimuth.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_elevation.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_zenith.data = data(:,place);
      place = place + 1;
      rsr.vars.hour_angle.data = data(:,place);
      place = place + 1;
      rsr.vars.declination.data = data(:,place);
      place = place + 1;
      rsr.vars.airmass.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_dist_au.data = data(:,place);
      place = place + 1;
      rsr.vars.solar_time.data = data(:,place);
      place = place + 1;
   end
   rsr.vars.lat.data = sscanf(rsr.header.lat, '%g');
   rsr.vars.lon.data = -sscanf(rsr.header.lon, '%g');
   rsr.vars.lat.dims ={''};
   rsr.vars.lon.dims = {''};
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
