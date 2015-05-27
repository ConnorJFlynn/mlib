clear temp;
bad_file = false;
%             [A] = fread(fid,3,'uint16')
%             UnitSN = A(1);
%             SWVersion = A(2);
%             Year = A(3);
t = 1;
fseek(fid,0,1);
filesize = ftell(fid);
disp(['file size = ',num2str(filesize)])
fseek(fid,start_here,-1);

while ~feof(fid)
    UnitSN(t) = fread(fid, 1, 'uint16'); % Serial Number of instrument
    ver_num(t) = fread(fid, 1, 'uint16'); % Software version number*100
    Year(t) = fread(fid, 1, 'uint16');
    Month(t) = fread(fid, 1, 'uint16');
    Day(t) = fread(fid, 1, 'uint16');
    Hours(t) = fread(fid, 1, 'uint16');
    Minutes(t) = fread(fid, 1, 'uint16');
    Seconds(t) = fread(fid, 1, 'uint16');
    shots_summed(t) = fread(fid, 1, 'uint32'); % Number of shots in integration period (1 sec = 2500 shots)
    pulse_rep(t) = fread(fid, 1, 'uint32'); % 2500 Hz PRF
    energy_monitor(t) = fread(fid, 1, 'uint32')/100; % Energy monitor reading in uJ, stored as emon_uJ*100
    detector_temp(t) = fread(fid, 1, 'uint32')/100; % Temp 0 Detector temperature det_C*100 Celcius
    filter_temp(t) = fread(fid, 1, 'uint32'); % Temp 1, not used
    %Reading temp1 as filter temp, unused
    instrument_temp(t) = fread(fid, 1, 'uint32')/100; % Temp 2, Telescope temperature tele_C*100 Celcius
    %Reading telescope temp as instrument temp
    laser_temp(t) = fread(fid, 1, 'uint32')/100; % Temp 3, Laser head temperature temp_C*100 Celcius
    temp4(t) = fread(fid, 1, 'uint32'); % Temp 4, not used
    bkgnd(t) = fread(fid, 1, 'float32'); % Background signal mean in counts/microsecond
    bkgnd_std(t) = fread(fid, 1, 'float32');% Background signal standard deviation in counts/microsecond
%     if ver_num(t)>0
       numchannels(t) = fread(fid, 1, 'uint16'); % Number of detector channels
       numbins(t) = fread(fid, 1, 'uint32'); % Number of bins stored in data block
       range_bin_time(t) = 1e9*fread(fid, 1, 'float32'); % Range bin time (100ns = 15m resolution etc)
       max_altitude(t) = fread(fid, 1, 'float32'); % maximum range up to which data is stored (usually ~60,000 m)
       deadt_flag(t) = fread(fid, 1, 'uint16'); % Dead time correction flag, 1=corrected, default=0
       scan_flag(t) = fread(fid, 1, 'uint16'); % scanning enabled=1, disabled=0; % Not applicable
       pol_flag(t) = fread(fid, 1, 'uint16');% Polarization control enabled=1, disabled=0;
%     else
%        dmp = fread(fid, 1, 'uint16'); % Number of detector channels
%        dmp = fread(fid, 1, 'uint32'); % Number of bins stored in data block
%        dmp = 1e9*fread(fid, 1, 'float32'); % Range bin time (100ns = 15m resolution etc)
%        dmp = fread(fid, 1, 'float32'); % maximum range up to which data is stored (usually ~60,000 m)
%        dmp = fread(fid, 1, 'uint16'); % Dead time correction flag, 1=corrected, default=0
%        dmp = fread(fid, 1, 'uint16'); % scanning enabled=1, disabled=0; % Not applicable
%        dmp = fread(fid, 1, 'uint16');% Polarization control enabled=1, disabled=0;
%     end
    az_deg(t) = fread(fid, 1, 'float32');% azimuth angle degrees % Not applicable
    el_deg(t) = fread(fid, 1, 'float32');% elevation angle degrees % Not applicable
    comp_deg(t) = fread(fid, 1, 'float32');% compass readout degrees % Not applicable
    pol_v1(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts
    pol_v2(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
    pol_v3(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
    pol_v4(t) = fread(fid, 1, 'float32');% Polarization control voltage setting volts not used
    preliminary_cbh(t) = fread(fid,1,'float32');% preliminary cbh
    dump = fread(fid, 20, 'char');% Future expansion
    if t == 1
        packetsize = 128 + 4*numbins(t)*numchannels(t);
        records = filesize/packetsize;
        profs = floor(records);
        if numchannels(t)==1
            profile_bins = zeros([numbins(t),profs]);
        else
            for ch = 1:numchannels(t)
                profile_bins.(['ch_',num2str(ch)])=zeros([numbins(t),profs]);
            end
        end
    end

    profile_start = ftell(fid);
    if numchannels(t)==1
        profile_bins(:,t) =  fread(fid,numbins(t),'float32');
    else
        for ch = 1:numchannels(t)
            profile_bins.(['ch_',num2str(ch)])(:,t)=fread(fid,numbins(t),'float32');
        end
    end
    if t == 1
%         packetsize = ftell(fid);
        disp(['Profile size = ',num2str(packetsize - profile_start)]);
        disp(['Packetsize = ',num2str(packetsize)]);
        disp([num2str(floor(filesize/packetsize)), ' complete profiles'])
    end
    if ver_num(t)>0
       t = t+1;
    end
    if (ftell(fid)+packetsize)>filesize
        end_here = ftell(fid);
        break
    end
    if (t == 1)&&((packetsize - profile_start)<0)
       bad_file = true;
       fseek(fid,0,1);
       tmp = fread(fid, 1);
    end
end

nulls = (numchannels==0)|(numbins==0)|(range_bin_time==0)|(max_altitude==0);
good = sum(~nulls);
numchannels(nulls) = [];
numbins(nulls) = []; 
range_bin_time(nulls) = []; 
max_altitude(nulls) = [];
deadt_flag(nulls) = [];
scan_flag(nulls) = [];
pol_flag(nulls) = [];

Day(nulls) = [];
Hours(nulls) = [];
Minutes(nulls) = [];
Month(nulls) = [];
Seconds(nulls) = [];
UnitSN(nulls) = [];
Year(nulls) = [];
az_deg(nulls) = [];
bkgnd(nulls) = [];
bkgnd_std(nulls) = [];
comp_deg(nulls) = [];
detector_temp(nulls) = [];
el_deg(nulls) = [];
energy_monitor(nulls) = [];
filter_temp(nulls) = [];
instrument_temp(nulls) = [];
laser_temp(nulls) = [];
pol_v1(nulls) = [];
pol_v2(nulls) = [];
pol_v3(nulls) = [];
pol_v4(nulls) = [];
preliminary_cbh(nulls) = [];
pulse_rep(nulls) = [];
shots_summed(nulls) = [];
temp4(nulls) = [];
ver_num(nulls) = [];

numchannels = unique(numchannels); % Number of detector channels
numbins = unique(numbins); % Number of bins stored in data block
range_bin_time = unique(range_bin_time); % Range bin time (100ns = 15m resolution etc)
max_altitude = unique(max_altitude); % maximum range up to which data is stored (usually ~60,000 m)
deadt_flag = unique(deadt_flag); % Dead time correction flag, 1=corrected, default=0
scan_flag = unique(scan_flag); % scanning enabled=1, dsisabled=0; % Not applicable
pol_flag = unique(pol_flag);% Polarization control enabled=1, disabled=0;

    if numchannels==1
        profile_bins(:,(t+1):end) =  [];
        profile_bins(:,nulls) = [];
    elseif ~isempty(numchannels)
        for ch = 1:numchannels(1)
            profile_bins.(['ch_',num2str(ch)])(:,(t+1):end)=[];
            profile_bins.(['ch_',num2str(ch)])(:,nulls)=[];
        end
    end

% fseek(fid,44,-1);
% RangeBinTime= fread(fid,1,'uint32')
% fseek(fid,48,-1);
% MaxAltitude = fread(fid,1,'uint32')
% NumBins = fix( 2* (MaxAltitude/RangeBinTime) / (c*1e-12) )
% PacketSize = 64 + 4*NumBins
% NumPackets = FileLength/PacketSize;

%Now, read variables from file, one by one, with proper type and skip
date_yyyymmdd = Day + 100*Month + 100^2*(Year);
time_hhmmss = Seconds + 100*Minutes + 100^2*Hours;
save_array = [];
