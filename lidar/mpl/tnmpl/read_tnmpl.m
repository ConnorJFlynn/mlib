function [lidar] = read_tnmpl(filename);
% [lidar, status] = read_tnmpl(filename);
% reads an entire raw tnmpl file and populates the lidar structure
if nargin==0
   disp(['Select a TNMPL data file from Houston'])
   [fid, fname, pname] = getfile('*.*', 'mpl_data');
   filename = [pname fname];
else
   fid = fopen(filename);
end
if fid>1
   [pname, fname, ext] = fileparts(filename);
   c =  2.99792458e8;   % speed of light in meters / second

   fidstart = ftell(fid);
   fseek(fid,0,1);
   fidend = ftell(fid);
   fseek(fid,0,-1);
   %Make sure file is at least 44 bytes long, then read first two bytes
   if((fidend-fidstart)>43);
      [A] = fread(fid,2);
      %if first byte is between 80 and 99, then it is YEAR and format is MPL00
      %else then it is UnitSN folded with FileFormat
      fseek(fid,0,-1);
      %disp(['Unit Serial Number: ', num2str(UnitSN)])
      % In this first version, assume that the files are not corrupt.
      % That is, assume FileLength = NumPackets * PacketSize
      FileLength = fidend - fidstart;

      FileFormat = 'tnmpl';
      % With the 'Win' format, the size of the profile is variable, so it
      % must be determined before reading in the data.
      clear temp;
      fseek(fid,0,-1);
      temp = fread(fid,44);
      same = [1,9:14,37:42]; %These positions should be the same for all packets.
      fseek(fid,0,-1);
      range_bin_time= temp(37)*256^3 + temp(38)*256^2 + temp(39)*256 + temp(40);
      max_altitude = temp(41)*256 + temp(42);
      num_bins = round( 2* (max_altitude/range_bin_time) / (c*1e-12) );
      if num_bins > 4000
         num_bins = 4000;
      end
      PacketSize = 44 + 4*num_bins; %This is only approximate due to possible round error
      if (FileLength > PacketSize) % then there is room for at least one packets so cont.
         if (FileLength < 2*PacketSize) % then there is only one profile
            %read the only profile...
         else %There is room for more profiles so verify PacketSize and read all complete profiles...
            done = 0;
            i = -2;
            while ~done
               fseek(fid, PacketSize+i,-1);
               test = fread(fid,44);
               if all(temp(same)==test(same))
                  PacketSize = PacketSize + i;
                  done = 1;
               else
                  i = i + 1;
               end
               if i > 2
                  done = -1;
               end
            end
            if done==-1
               disp('Unable to determine PacketSize from the first two records...')
               disp('Halting execution...')
               pause
            end
            num_bins = (PacketSize - 44)./4; %This should also be an integer
            if (num_bins ~= fix(num_bins))
               disp('Bogus non-integer number of bins?!');
               pause
            end
            % At this point we have determined the PacketSize based on the first
            % two packets...
            NumPackets = (FileLength/PacketSize);
            %PacketSize = FileLength/NumPackets; %This should be an integer if
            %the file is good.
            if (NumPackets==fix(NumPackets))
               %disp('File appears to be valid.  Reading packets...')
               bigarray = zeros(PacketSize,NumPackets);
               fseek(fid,0,-1);
               bigarray(:) = fread(fid,PacketSize*NumPackets);
               save_array = bigarray;
               unit_sn = max(bigarray(1,:));
               bigarray(1,:) = [];
               Day = bigarray(3,:);
               Month = bigarray(2,:);
               Year = 1900 + bigarray(1,:);
               bigarray(1:3,:) = [];
               time = bigarray(4,:)/100 + bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
               Seconds = bigarray(4,:)/100 + bigarray(3,:);
               Minutes = bigarray(2,:);
               Hours = bigarray(1,:);
               bigarray(1:4,:) = [];
               four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               shots_summed = (four_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               pulse_rep = (two_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               energy_monitor = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               detector_temp= two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               filter_temp= two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               instrument_temp = two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               laser_temp = two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_10 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_05 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_15 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               preliminary_cbh = two_byte;
               four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               background_signal = four_byte/1e8;
               %      four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               %      range_bin_time = max(four_byte);
               %      two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               %      max_altitude = max(two_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               azimuth = bigarray(1,:);
               zenith = bigarray(2,:);
               azimuth(azimuth==255) = NaN;
               zenith(zenith==255) = NaN;
               azimuth = azimuth*(360/254);
               zenith = zenith*(90/254);
               bigarray(1:2,:) = [];
               dead_time_corrected = max(two_byte);
               num_bins = fix( 2* (max_altitude/range_bin_time) / (c*1e-12) );
               if num_bins>4000
                  num_bins = 4000;
               end
               temp = zeros(4,num_bins*NumPackets);
               temp(:) = bigarray;
               bigarray = [];
               temp(1,:) = temp(4,:) + 256*temp(3,:) + 256^2*temp(2,:) + 256^3*temp(1,:);
               profile_bins = zeros(num_bins,NumPackets);
               profile_bins(:) = temp(1,:)/1e8;
               temp = [];
            else
               disp(['This file appears to be corrupt: ' filename]);
               disp(['Attempting to read all but the last packet...']);
               NumPackets = floor(FileLength/PacketSize);
               bigarray = zeros(PacketSize,NumPackets);
               fseek(fid,0,-1);
               bigarray(:) = fread(fid,PacketSize*NumPackets);
               save_array = bigarray;
               unit_sn = max(bigarray(1,:));
               bigarray(1,:) = [];
               Day = bigarray(3,:);
               Month = bigarray(2,:);
               Year = 1900 + bigarray(1,:);
               bigarray(1:3,:) = [];
               time = bigarray(4,:)/100 + bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
               Seconds = bigarray(4,:)/100 + bigarray(3,:);
               Minutes = bigarray(2,:);
               Hours = bigarray(1,:);
               bigarray(1:4,:) = [];
               four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               shots_summed = (four_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               pulse_rep = (two_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               energy_monitor = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               detector_temp= two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               filter_temp= two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               instrument_temp = two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               laser_temp = two_byte/100;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_10 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_05 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               voltage_15 = two_byte;
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               preliminary_cbh = two_byte;
               four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               background_signal = four_byte/1e8;
               %      four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
               bigarray(1:4,:) = [];
               %      range_bin_time = max(four_byte);
               %      two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               %      max_altitude = max(two_byte);
               two_byte = bigarray(2,:) + 256*bigarray(1,:);
               bigarray(1:2,:) = [];
               dead_time_corrected = max(two_byte);
               num_bins = fix( 2* (max_altitude/range_bin_time) / (c*1e-12) );
               temp = zeros(4,num_bins*NumPackets);
               temp(:) = bigarray;
               bigarray = [];
               temp(1,:) = temp(4,:) + 256*temp(3,:) + 256^2*temp(2,:) + 256^3*temp(1,:);
               profile_bins = zeros(num_bins,NumPackets);
               profile_bins(:) = temp(1,:)/1e8;
               temp = [];
            end;
         end;
         statics.unitSN = unit_sn;
         statics.datastream = FileFormat;
         rawcts = profile_bins;
         clear profile_bins;
         hk.cbh = preliminary_cbh;
         time = datenum(Year, Month, Day, Hours, Minutes, Seconds);
         hk.energy_monitor = energy_monitor/1000;
         hk.instrument_temp = instrument_temp ;
         hk.laser_temp = laser_temp;
         hk.detector_temp = detector_temp;
         hk.filter_temp = filter_temp;
         hk.pulse_rep = pulse_rep;
         hk.shots_summed = shots_summed;
         hk.zenith = zenith;
         hk.azimuth = azimuth;
         if exist('voltage_05','var')
            hk.voltage_05 = voltage_05;
            hk.voltage_10 = voltage_10;
            hk.voltage_15 = voltage_15;
         end
         statics.datalevel = 0;
         statics.deadtime_corrected = 0;
         statics.mplps = 0;
         if exist('numchannels','var')
            statics.channels = numchannels;
         else
            statics.channels = 1;
         end
         statics.maxAltitude = max_altitude;
         statics.range_bin_time = range_bin_time;
         statics.pulse_rep = round(mean(hk.pulse_rep));
         %    statics.shots_summed = round(mean(hk.shots_summed));

         %Determine a preliminary background, subtract the background
         %Then determine range offset and subtract it.
         %Cull negative ranges.
         [bins,profs] = size(rawcts);
         r.bg = [fix(bins*.77):ceil(bins*.97)];
         bg = mean(rawcts(r.bg,:));
         for i = profs:-1:1
            signal(:,i) = rawcts(:,i) - bg(i);
         end;
         earlybins = mean(signal(1:10,:)');
         if any(find(earlybins > 1))
            first_bin = min(find(earlybins > 1));
         else
            first_bin = 1;
         end;
         % Now with first_bin determined, calculate range_offset.
         r.range_offset = (first_bin - 1) * range_bin_time * c/2 * 1e-12; % The "0.5" centers the first bin
         %cull bins up to and including first_bin
         range = [1:bins]' -first_bin;
         %     r.squared = range.^2; % moved this to read_mpl.m
         %      rawcts(1:first_bin,:) = [];
         %      signal(1:first_bin,:) = [];
         range = range*range_bin_time*c/2*1e-12;
         signal = (((range>0).*(range.^2))*ones(1,profs)).* signal;
         %     range = range*range_bin_time*c/2*1e-12 - r.range_offset ;
         %     range(first_bin) = ((first_bin)* range_bin_time*c/2*1e-12 - r.range_offset)/2;

         r.bg = [fix(bins*.6):ceil(bins*.95)];
         bg = mean(rawcts(r.bg,:));

         hk.bg = bg;
         lidar.rawcts =rawcts;
         lidar.time = time;
         lidar.statics = statics;
         lidar.hk = hk;
         lidar.range = range;
         lidar.r = r;
         lidar.prof = signal;
         status = 1;

         %Done reading in data...
         % By this time, data has been read in.
         % Now generate some useful range selections...
         if isfield(lidar,'r')
            r = lidar.r;
         end
         if isfield(lidar, 'range')
            r.lte_5 = find((lidar.range>.045)&(lidar.range<=5));
            r.lte_10 = find((lidar.range>.045)&(lidar.range<=10));
            r.lte_15 = find((lidar.range>.045)&(lidar.range<=15));
            r.lte_20 = find((lidar.range>.045)&(lidar.range<=20));
            r.lte_25 = find((lidar.range>.045)&(lidar.range<=25));
            r.lte_30 = find((lidar.range>.045)&(lidar.range<=30));
            lidar.r = r;
         end

         %cts_to_MHz = (1./(lidar.hk.shots_summed*lidar.statics.range_bin_time/1000));
         MHz_to_cts = (lidar.hk.shots_summed*lidar.statics.range_bin_time/1000);
         try
            lidar.noise_MHz = sqrt(lidar.rawcts./(ones(size(lidar.range))*MHz_to_cts));
         catch
            for b = length(lidar.range):-1:1
               lidar.noise_MHz(b,:) = sqrt(lidar.rawcts(b,:)./MHz_to_cts);
            end
         end
         % lidar.noise_MHz = sqrt(lidar.rawcts./(ones(size(lidar.range))*MHz_to_cts));
         bg_bin_noise = sqrt(lidar.hk.bg ./ MHz_to_cts);
         for t = 1:length(lidar.time)
            low_cts = find(lidar.rawcts(:,t)<lidar.hk.bg(t));
            lidar.noise_MHz(low_cts,t) = bg_bin_noise(t);
         end
         bg_bins = length(lidar.r.bg);
         lidar.hk.bg_noise = sqrt(lidar.hk.bg ./(MHz_to_cts*bg_bins));
         lidar.statics.filename = filename;
      else
         disp(['This file is too short for even a single profile: ',filename]);
         lidar = [];
      end
   else
      disp(['This files does not contain a complete header: ',filename]);
      lidar = [];
   end
   fclose(fid);
else
disp(['Could not even open file: ',filename] );
end