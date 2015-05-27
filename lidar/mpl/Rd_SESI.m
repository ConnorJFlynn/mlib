clear temp;
fseek(fid,44,-1);
RangeBinTime= fread(fid,1,'uint32')
fseek(fid,48,-1);
MaxAltitude = fread(fid,1,'uint32')
NumBins = fix( 2* (MaxAltitude/RangeBinTime) / (c*1e-12) )
PacketSize = 64 + 4*NumBins
NumPackets = FileLength/PacketSize;
if NumPackets == fix(NumPackets);
    disp('File appears to be valid.  Reading packets...')
    Year = zeros(NumPackets,1);
    Month = zeros(NumPackets,1);
    Day = zeros(NumPackets,1);
    Hours = zeros(NumPackets,1);
    Minutes = zeros(NumPackets,1);
    Seconds = zeros(NumPackets,1);
    EnergyMonitor = zeros(NumPackets,1);
    DetectorTemp = zeros(NumPackets,1);
    InstrumentTemp = zeros(NumPackets,1);
    LaserTemp = zeros(NumPackets,1);
    PreliminaryCBH = zeros(NumPackets,1);
    BackgroundSignal = zeros(NumPackets,1);
    ProfileBins = zeros(NumBins, NumPackets);
    
    %Now, read variables from file, one by one, with proper type and skip
    for i = 1:NumPackets
        j = i - 1;
        fseek(fid,0+j*PacketSize,-1);
        UnitSN = fread(fid,1,'uchar');
        WMPL_Version = fread(fid,1,'uchar');
        Year(i) = fread(fid,1,'uint16')+1900;
        Month(i) = fread(fid,1,'uint16');
        Day(i) = fread(fid,1,'uint16');
        Hours(i) = fread(fid,1,'uint16');
        Minutes(i) = fread(fid,1,'uint16');
        Seconds(i) = fread(fid,1,'uint16');
        PulseRep = fread(fid,1,'uint16');
        ShotsSummed = fread(fid,1,'uint32');
        EnergyMonitor(i) = fread(fid,1,'float32');
        DetectorTemp(i) = fread(fid,1,'float32')/100;
        InstrumentTemp(i) = fread(fid,1,'float32')/100;
        LaserTemp(i) = fread(fid,1,'float32')/100;
        PreliminaryCBH(i) = fread(fid,1,'uint32');
        BackgroundSignal(i) = fread(fid,1,'float32')/1e8;
        RangeBinTime = fread(fid,1,'uint32');
        MaxAltitude = fread(fid,1,'uint32');
        DeadTimeCorrected = fread(fid,1,'uint32');
        NumBins = fix( 2* (MaxAltitude/RangeBinTime) / (c*1e-12) );
        temp = fread(fid, NumBins, 'float32');
        ProfileBins(:,i) = temp;
    end; % of for loop
    date_yyyymmdd = Day + 100*Month + 100^2*(Year);
    time_hhmmss = Seconds + 100*Minutes + 100^2*Hours;
else disp(['This file appears to be corrupt: ' pname fname]);
end; %end of filelength check.
