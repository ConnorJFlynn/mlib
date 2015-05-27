% With the 'Win' format, the size of the profile is variable, so it
% must be determined before reading in the data.
clear temp;
fseek(fid,0,-1);
temp = fread(fid,44);
same = [1,9:14,37:44]; %These positions should be the same for all packets.
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
else
      disp('This file is too short for even a single profile');
end