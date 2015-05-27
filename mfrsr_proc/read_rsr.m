function [mfr,anc_rsr] = read_rsr(filename);
% [anc_rsr,mfr] = read_rsr_v5(filename);
% Returns "anc_rsr" and "mfr", same data in different formats
% "anc_rsr" is ancstruct, "mfr" is more terse
%
%     $Revision: 1.1 $      
%     $Date: 2013/12/11 04:25:45 $          

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: read_rsr.m,v $         
%   $Revision: 1.1 $        
%   $Date: 2013/12/11 04:25:45 $            
%
%   $Log: read_rsr.m,v $
%   Revision 1.1  2013/12/11 04:25:45  cflynn
%   Commit mfrsr processing code
%
%   Revision 1.1  2011/04/08 13:50:07  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:49  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:09:07  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.1  2006/08/10 19:41:20  cflynn
%   Committing a whole slew of mfrsr processing scripts so I can use them from my other PC.
%             
%

%-------------------------------------------------------------------
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
   [this,that] = system(['C:\cygwin\usr\local\bin\tu -R -v quiet -H -d joe -x aezhdmst ', filename]);
   %First line is header
   anc_rsr.fname = filename;

   nlines = find(that==10);
   header = that(1:nlines(1)-1);
   anc_rsr.header.string = header;
   that2 = that(nlines(1)+1:end);
   [anc_rsr.header.firmware_version, header] = strtok(header);
   if sscanf(anc_rsr.header.firmware_version,'%g')==13
      [anc_rsr.header.logger_ID, header] = strtok(header);
      [anc_rsr.header.head_ID, header] = strtok(header);
      [anc_rsr.header.lat, header] = strtok(header);
      [anc_rsr.header.lon, header] = strtok(header);
      [anc_rsr.header.flags, header] = strtok(header);
      flags = sscanf(anc_rsr.header.flags,'%x');
      [anc_rsr.header.sample_rate, header] = strtok(header);
      [anc_rsr.header.avg_interval, header] = strtok(header);
      [anc_rsr.header.date_joe, header] = strtok(header);
      [anc_rsr.header.daysec, header] = strtok(header);
      [anc_rsr.header.nchannels, header] = strtok(header);
      nchannels = sscanf(anc_rsr.header.nchannels,'%x');
      [anc_rsr.header.daytime_channels, header] = strtok(header);
      daytime_channels = sscanf(anc_rsr.header.daytime_channels,'%x');
      [anc_rsr.header.alltime_channels, header] = strtok(header);
      alltime_channels = sscanf(anc_rsr.header.alltime_channels,'%x');
      [anc_rsr.header.counters, header] = strtok(header);
      counters = sscanf(anc_rsr.header.counters, '%x');
      [anc_rsr.header.datasize, header] = strtok(header);
      [anc_rsr.header.errors, header] = strtok(header);
      
      nlines(1) = [];
      thatnum = sscanf(that2, '%g');
      data = zeros([length(thatnum)/length(nlines), length(nlines)]);
      data(:) = thatnum;
      data = data';
      place = 1;
      anc_rsr.time = data(:,place)-1 + datenum('1900-01-01', 'yyyy-mm-dd');
      place = place + 1;
      if bitget(alltime_channels,1)
         SRT = data(:,place);
         place = place + 1;
         SRT = 6810 * (5000 ./ SRT - 1);
         SRT  = 1.030852e-3 + 2.389179e-4 .* log(SRT) + 1.574641e-07 .* log(SRT).^3;
         SRT  = 1.0 ./ SRT - 273.12;
         anc_rsr.vars.logger_T.data = SRT;
      end
      for ch = 1:7
         if bitget(alltime_channels,ch+1)
            anc_rsr.vars.(['alltime_ch',num2str(ch)]).data = data(:,place);
            place = place + 1;
         end
      end
      if bitget(alltime_channels,9)
         anc_rsr.vars.logger_V.data = data(:,place)*6/1000;
         place = place + 1;
      end
      if bitget(flags,6) % We have shadowband data
         for ch = 1:7
            anc_rsr.vars.(['th_ch',num2str(ch)]).data = data(:,place);
            place = place + 1;
            NaNs = find(anc_rsr.vars.(['th_ch',num2str(ch)]).data<-9000);
            anc_rsr.vars.(['th_ch',num2str(ch)]).data(NaNs) = NaN;
         end
         for ch=1:7
            anc_rsr.vars.(['dif_ch',num2str(ch)]).data = data(:,place);
            place = place + 1;
            NaNs = find(anc_rsr.vars.(['dif_ch',num2str(ch)]).data<-9000);
            anc_rsr.vars.(['dif_ch',num2str(ch)]).data(NaNs) = NaN;
         end
         for ch=1:7
            anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data = data(:,place);
            place = place + 1;
            NaNs = find(anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data<-9000);
            anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data(NaNs) = NaN;
         end
      end
      anc_rsr.vars.solar_azimuth.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_elevation.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_zenith.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.hour_angle.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.declination.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.airmass.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_dist_au.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_time.data = data(:,place);
      place = place + 1;
   else %we have old logger firmware < 13
      [anc_rsr.header.logger_ID, header] = strtok(header);
      [anc_rsr.header.head_ID] = '';
      [anc_rsr.header.lat, header] = strtok(header);
      [anc_rsr.header.lon, header] = strtok(header);
      [anc_rsr.header.flags, header] = strtok(header);
      flags = sscanf(anc_rsr.header.flags,'%x');
      [anc_rsr.header.aux_channels, header] = strtok(header);
      aux_channels = sscanf(anc_rsr.header.aux_channels, '%x');
      [anc_rsr.header.bipol_channels, header] = strtok(header);
      bipol_channels = sscanf(anc_rsr.header.bipol_channels, '%x');
      [anc_rsr.header.sample_rate, header] = strtok(header);
      [anc_rsr.header.avg_interval, header] = strtok(header);
      [anc_rsr.header.date_joe, header] = strtok(header);
      [anc_rsr.header.daysec, header] = strtok(header);
      [anc_rsr.header.active_channels, header] = strtok(header);
      active_channels = sscanf(anc_rsr.header.active_channels, '%x');
      [anc_rsr.header.datasize, header] = strtok(header);
      nlines(1) = [];
      thatnum = sscanf(that2, '%g');
      data = zeros([length(thatnum)/length(nlines), length(nlines)]);
      data(:) = thatnum;
      data = data';
      place = 1;
      anc_rsr.time = data(:,place)-1 + datenum('1900-01-01', 'yyyy-mm-dd');
      anc_rsr.time = anc_rsr.time';
      place = place + 1;

      for ch = 1:7
         anc_rsr.vars.(['th_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(anc_rsr.vars.(['th_ch',num2str(ch)]).data<-9000);
         anc_rsr.vars.(['th_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      for ch = 1:7
         anc_rsr.vars.(['dif_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(anc_rsr.vars.(['dif_ch',num2str(ch)]).data<-9000);
         anc_rsr.vars.(['dif_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      for ch = 1:7
         anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data = data(:,place);
         NaNs = find(anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data<-9000);
         anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data(NaNs) = NaN;
         place = place + 1;
      end
      anc_rsr.vars.logger_V.data = data(:,place)*6/1000;
      place = place + 1;
      SRT = data(:,place);
      place = place + 1;
      SRT = 6810 * (5000 ./ SRT - 1);
      SRT  = 1.030852e-3 + 2.389179e-4 .* log(SRT) + 1.574641e-07 .* log(SRT).^3;
      SRT  = 1.0 ./ SRT - 273.12;
      anc_rsr.vars.logger_T.data = SRT;
      
      anc_rsr.vars.solar_azimuth.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_elevation.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_zenith.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.hour_angle.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.declination.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.airmass.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_dist_au.data = data(:,place);
      place = place + 1;
      anc_rsr.vars.solar_time.data = data(:,place);
      place = place + 1;
   end
   anc_rsr.vars.lat.data = sscanf(anc_rsr.header.lat, '%g');
   anc_rsr.vars.lon.data = -sscanf(anc_rsr.header.lon, '%g');
   anc_rsr.vars.lat.dims ={''};
   anc_rsr.vars.lon.dims = {''};
   
end
anc_rsr = fix_rsr_orientation(anc_rsr);
mfr.statics.fname = anc_rsr.fname;
mfr.statics.header = anc_rsr.header;
mfr.statics.lat = anc_rsr.vars.lat.data;
mfr.statics.lon = anc_rsr.vars.lon.data;
mfr.time = anc_rsr.time;
mfr.hk.V = anc_rsr.vars.logger_V.data;
mfr.hk.T = anc_rsr.vars.logger_T.data;

mfr.hk.saa = anc_rsr.vars.solar_azimuth.data;
mfr.hk.sea = anc_rsr.vars.solar_elevation.data;
mfr.hk.sza = anc_rsr.vars.solar_zenith.data;
mfr.hk.ha = anc_rsr.vars.hour_angle.data;
mfr.hk.da = anc_rsr.vars.declination.data;
mfr.hk.airmass = anc_rsr.vars.airmass.data;
mfr.hk.r_au = anc_rsr.vars.solar_dist_au.data;
mfr.hk.solar_time = anc_rsr.vars.solar_time.data;
for ch = 1:7
   mfr.(['th_ch',num2str(ch)]) = anc_rsr.vars.(['th_ch',num2str(ch)]).data;
   mfr.(['dif_ch',num2str(ch)]) = anc_rsr.vars.(['dif_ch',num2str(ch)]).data;
   mfr.(['dirhor_ch',num2str(ch)]) = anc_rsr.vars.(['dirhor_ch',num2str(ch)]).data;
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
function anc_rsr = fix_rsr_orientation(anc_rsr)
anc_rsr.time = anc_rsr.time';
varname = fieldnames(anc_rsr.vars);
for v = 1:length(varname);
    if length(anc_rsr.vars.(char(varname(v))).data)==length(anc_rsr.time)
       anc_rsr.vars.(char(varname(v))).data = anc_rsr.vars.(char(varname(v))).data';
       anc_rsr.vars.(char(varname(v))).dims = {'time'};
    end
end