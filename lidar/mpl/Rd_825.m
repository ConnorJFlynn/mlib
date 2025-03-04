    PacketSize = 25 + 800; %25-byte header + 200 4-byte bins
    MaxAltitude = 60;
    NumPackets = FileLength/PacketSize;
    if NumPackets == fix(NumPackets);
      disp('File appears to be valid.  Reading packets...')
      bigarray = zeros(PacketSize,NumPackets);
      bigarray(:) = fread(fid,PacketSize*NumPackets);
      dates = bigarray(3,:) + 100*bigarray(2,:) + 100^2*(1900+bigarray(1,:));
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
      ShotsSummed = max(four_byte);
      two_byte = bigarray(2,:) + 256*bigarray(1,:);
      bigarray(1:2,:) = [];    
      PulseRep = max(two_byte);
      two_byte = bigarray(2,:) + 256*bigarray(1,:);
      bigarray(1:2,:) = [];    
      EnergyMonitor = two_byte;
      two_byte = bigarray(2,:) + 256*bigarray(1,:);
      bigarray(1:2,:) = [];    
      DetectorTemp= two_byte/100;
      two_byte = bigarray(2,:) + 256*bigarray(1,:);
      bigarray(1:2,:) = [];    
      FilterTemp= two_byte/100;
      two_byte = bigarray(2,:) + 256*bigarray(1,:);
      bigarray(1:2,:) = [];    
      InstrumentTemp = two_byte/100;
      four_byte = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
      bigarray(1:4,:) = [];
      BackgroundSignal = four_byte/1e8;
      NumBins = 200;
      temp = zeros(4,NumBins*NumPackets);
      temp = bigarray(1:4*NumBins,:);
      bigarray = [];
      ProfileBins = temp(4,:) + 256*temp(3,:) + 256^2*temp(2,:) + 256^3*temp(1,:);
      ProfileBins = ProfileBins/1e8;
      temp = [];
    else disp(['This file appears to be corrupt: ' pname fname]);
    end;
  