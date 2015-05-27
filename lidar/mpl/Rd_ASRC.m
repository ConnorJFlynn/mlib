function [lidar, status] = rd_sigma(filename);
% [lidar,status] = rd_sigma(filename)
% Reads an entire Sigma raw MPL files in its entirety populating MPL structure

if nargin==0
   disp('Select a raw ASRC MPL file:');
   [fname, pname] = uigetfile('C:\case_studies\MPL_holder\MPL_105\*.*');
   filename = [pname fname];
end
status = 0;
fid = fopen(filename);
disp(['filename: ',filename]);
[lidar, status] = read_sigmaraw(fid,filename);
fclose(fid);

% ProfileBins is averaged over ShotSummed shots and is in units of cts/microsecond.
%To get the original shots per bin, multiply ProfileBins by ShotsSummed and by BinTime in microseconds
% ProfileBins = ProfileBins * ShotsSummmed/(BinTime/1000);
%%

function [lidar, status] = read_sigmaraw(fid, filename);
% [lidar, status] = read_sigmaraw(fid,filename);
% reads an entire raw asrc mpl file and populates the lidar structure

if nargin==0
   pname = [];
   while isempty(pname)
      [fname, pname] = uigetfile('*.*');
   end
   fid = fopen([pname, fname]);
end
c =  2.99792458e8;
if fid>0
   fidstart = ftell(fid);
   fseek(fid,0,1);
   fidend = ftell(fid);
   fseek(fid,0,-1);
   FileSize = fidend - fidstart;
   % speed of light in meters / second
   % With the 'ASRC' format, the size of the profile is variable, so it
   % must be determined before reading in the data.
   if FileSize>1000
      clear temp;
      fseek(fid,0,-1);
      temp = fread(fid,56);
      NumChannels = fread(fid, 1, 'uint16');
      NumBins = fread(fid, 1, 'uint32');
      fseek(fid,0,-1);
      PacketSize = 128 + 4*NumBins*NumChannels;
      NumPackets = FileSize/PacketSize;
      if NumPackets == fix(NumPackets)
         for t = 1:NumPackets
            %Then it divides evenly so read them all in.
            UnitSN = fread(fid, 1, 'uint16'); % Serial Number of instrument
            VerNum = fread(fid, 1, 'uint16'); % Software version number*100
            Year(t) = fread(fid, 1, 'uint16');
            Month(t) = fread(fid, 1, 'uint16');
            Day(t) = fread(fid, 1, 'uint16');
            Hours(t) = fread(fid, 1, 'uint16');
            Minutes(t) = fread(fid, 1, 'uint16');
            Seconds(t) = fread(fid, 1, 'uint16');
            ShotsSummed(t) = fread(fid, 1, 'uint32'); % Number of shots in integration period (1 sec = 2500 shots)
            PulseRep(t) = fread(fid, 1, 'uint32'); % 2500 Hz PRF
            EnergyMonitor(t) = fread(fid, 1, 'uint32')/100; % Energy monitor reading in uJ, stored as emon_uJ*100
            DetectorTemp(t) = fread(fid, 1, 'uint32')/100; % Temp 0 Detector temperature det_C*100 Celcius
            FilterTemp(t) = fread(fid, 1, 'uint32'); % Temp 1, not used
            InstrumentTemp(t) = fread(fid, 1, 'uint32')/100; % Temp 2, Telescope temperature tele_C*100 Celcius
            LaserTemp(t) = fread(fid, 1, 'uint32')/100; % Temp 3, Laser head temperature temp_C*100 Celcius
            BoxTemp(t) = fread(fid, 1, 'uint32'); % Temp 4, not used
            BackgroundSignal(t) = fread(fid, 1, 'float32'); % Background signal mean in counts/microsecond
            BkGndSTD(t) = fread(fid, 1, 'float32');% Background signal standard deviation in counts/microsecond
            NumChannels = fread(fid, 1, 'uint16'); % Number of detector channels
            NumBins = fread(fid, 1, 'uint32'); % Number of bins stored in data block
            RangeBinTime = fread(fid, 1, 'float32'); % Range bin time (100ns = 15m resolution etc)
            MaxAltitude = fread(fid, 1, 'float32'); % maximum range up to which data is stored (usually ~60,000 m)
            DeadtimeCorrected = fread(fid, 1, 'uint16'); % Dead time correction flag, 1=corrected, default=0
            ScanningFlag(t) = fread(fid, 1, 'uint16'); % scanning enabled=1, disabled=0; % Not applicable
            PolFlag(t) = fread(fid, 1, 'uint16');% Polarization control enabled=1, disabled=0;
            AzDeg(t) = fread(fid, 1, 'float32');% azimuth angle degrees % Not applicable
            ElDeg(t) = fread(fid, 1, 'float32');% elevation angle degrees % Not applicable
            CompassDeg(t) = fread(fid, 1, 'float32');% compass readout degrees % Not applicable
            PolV1(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts
            PolV2(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
            PolV3(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
            PolV4(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
            reserved = fread(fid, 24, 'char');% Future expansion
            if NumChannels == 1
               ch_1(:,t) = fread(fid,NumBins,'float32');
            else
               for ch = 1:NumChannels
                  eval(['ch_',num2str(ch),'(:,t)']) = fread(fid,NumBins,'float32');
               end
            end
         end
      else
      %Must have a partial packets.  Read in while the sentinal bytes
      %all match.
      end
   else
      disp('This file is too small to contain a lidar profile');
   end
else
   disp('Unable to open file');
end

statics.unitSN = UnitSN;
FileFormat = 'ASRC';
statics.datastream = FileFormat;
clear UnitSN FileFormat ProfileBins;
% hk.cbh = preliminary_cbh;
time = datenum(Year, Month, Day, Hours, Minutes, Seconds);
hk.energyMonitor = EnergyMonitor/1000;
hk.instrumentTemp = InstrumentTemp ;
hk.laserTemp = LaserTemp;
hk.detectorTemp = DetectorTemp;
hk.filterTemp = FilterTemp;
hk.PRF = PulseRep;
hk.shots_summed = ShotsSummed;
hk.ScanningFlag = ScanningFlag;
hk.PolFlag = PolFlag;
hk.AzDeg = AzDeg;
hk.ElDeg = ElDeg;
hk.CompassDeg = CompassDeg;
hk.PolV1 = PolV1;
hk.PolV2 = PolV2;
hk.PolV3 = PolV3;
hk.PolV4 = PolV4;
% bg = mean(ch_1(r.bg,:));
% hk.bg = bg;
lidar.rawcts =ch_1;
clear ch_1
lidar.time = time;
lidar.statics = statics;
lidar.hk = hk;

range = 1e-3*[0:NumBins-1]*c*RangeBinTime/2;
lidar.range = range;
r.squared = lidar.range.^2;
r.bg = find((lidar.range>=40)&(lidar.range<=57));
r.lte_5 = find((lidar.range>.045)&(lidar.range<=5));
r.lte_10 = find((lidar.range>.045)&(lidar.range<=10));
r.lte_15 = find((lidar.range>.045)&(lidar.range<=15));
r.lte_20 = find((lidar.range>.045)&(lidar.range<=20));
r.lte_25 = find((lidar.range>.045)&(lidar.range<=25));
r.lte_30 = find((lidar.range>.045)&(lidar.range<=30));
lidar.r = r;
bg = mean(lidar.rawcts(r.bg,:));
hk.bg = bg;
lidar.prof = lidar.rawcts - ones([NumBins,1])*hk.bg;
clear time statics hk range r MaxAltitude
% %%
% statics.unitSN = UnitSN;
% statics.datastream = FileFormat;
% hk.cbh = preliminary_cbh;
% time = datenum(Year, Month, Day, Hours, Minutes, Seconds);
% hk.energyMonitor = EnergyMonitor/1000;
% hk.instrumentTemp = InstrumentTemp ;
% hk.laserTemp = LaserTemp;
% hk.detectorTemp = DetectorTemp;
% hk.filterTemp = FilterTemp;
% hk.PRF = PulseRep;
% hk.shots_summed = ShotsSummed;
% hk.voltage_05 = Voltage_05;
% hk.voltage_10 = Voltage_10;
% hk.voltage_15 = Voltage_15;
% 
% statics.datalevel = 0;
% statics.mpl = 1;
% statics.deadtime_corrected = 0;
% statics.mplps = 0;
% statics.channels = 1;
% statics.maxAltitude = MaxAltitude;
% 
% %Determine a preliminary background, subtract the background
% %Then determine range offset and subtract it.
% %Cull negative ranges.
% [bins,profs] = size(lidar.rawcts);
% r.bg = [fix(bins*.77):ceil(bins*.97)];
% bg = mean(lidar.rawcts(r.bg,:));
% for i = profs:-1:1
%    signal(:,i) = lidar.rawcts(:,i) - bg(i);
% end;
% earlybins = mean(signal(1:10,:)');
% if any(find(earlybins > 1))
%    first_bin = min(find(earlybins > 1));
% else
%    first_bin = 1;
% end;
% % Now with first_bin determined, calculate range_offset.
% r.range_offset = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12; % The "0.5" centers the first bin


%cull bins up to and including first_bin
% range = [1:bins-first_bin]';
% %     r.squared = range.^2; % moved this to read_mpl.m
% rawcts(1:first_bin,:) = [];
% signal(1:first_bin,:) = [];
% range = range*RangeBinTime*c/2*1e-12;
% 
% %     range = range*RangeBinTime*c/2*1e-12 - r.range_offset ;
% %     range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - r.range_offset)/2;
% 
% r.bg = [fix(bins*.87):ceil(bins*.97)];
% bg = mean(rawcts(r.bg,:));
% 
% hk.bg = bg;
% lidar.time = time;
% lidar.statics = statics;
% lidar.hk = hk;
% lidar.range = range;
% lidar.r = r;
% lidar.prof = signal;

status = 1;
