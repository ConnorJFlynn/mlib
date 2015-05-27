function [lidar, status, save_array] = read_mplraw(fid, filename);
% [lidar, status] = read_mplraw(fid,filename);
% reads an entire raw mpl file and populates the lidar structure
% CJF: 2006-10-25: removed 1/2 bin centering, computing range-squared prof
[pname, fname, ext] = fileparts(filename);
c =  2.99792458e8;   % speed of light in meters / second
if findstr(upper(ext),'MPL') % Then it is SIGMA format
    FileFormat = 'Sigma';
    disp([FileFormat]);
    lidar = Rd_Sigma(filename);
    save_array = [];
else
    fidstart = ftell(fid);
    fseek(fid,0,1);
    fidend = ftell(fid);
    fseek(fid,0,-1);
    FileLength = fidend - fidstart;
    %Make sure file is at least 44 bytes long, then read first two bytes
    if((fidend-fidstart)>43);
        [A] = fread(fid,2);
        %if first byte is between 80 and 99, then it is YEAR and format is MPL00
        %else then it is UnitSN folded with FileFormat
        if (A(1)>80)&(A(1)<99);
            FileFormat = 'NASA_825';
            UnitSN = 0; %Only MPL00 produce 825-byte profiles
            disp([FileFormat]);
        elseif (A(1)>-1)&(A(1) < 50);
            FileFormat = 'NASA_836';
            disp([FileFormat]);
            UnitSN = A(1);
            Year = 1900 + A(2);
        elseif (A(1)>49)&(A(1)<150);
            FileFormat = 'NASA_Win';
            %disp([FileFormat]);
            UnitSN = A(1)-50;
            Year = 1900 + A(2);
        elseif (A(1)>149)&(A(1)<256);
            FileFormat = 'SESI_Win';
            disp([FileFormat]);
            UnitSN = A(1)-150;
            Year = 1900 + A(2);
        else
            FileFormat = 'Unknown format';
            disp([FileFormat]);
            UnitSN = -1;
            Year = 1900 + A(2);
        end;
        clear A;
        fseek(fid,0,-1);
        %disp(['Unit Serial Number: ', num2str(UnitSN)])
        % In this first version, assume that the files are not corrupt.
        % That is, assume FileLength = NumPackets * PacketSize


        if FileFormat == 'NASA_825';
            Rd_825;
        elseif FileFormat == 'NASA_836';
            Rd_836;
        elseif FileFormat == 'NASA_Win';
            Rd_Win;
        elseif FileFormat == 'SESI_Win';
            Rd_SESI;
        end;
        status = 1;
    else
        disp(['This file is too small to contain any profiles: ' pname, fname]);
    end; %of minimum file length check.

    statics.unitSN = UnitSN;
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
        r.bg = [fix(bins*.47):ceil(bins*.97)];
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
    r.range_offset = (first_bin) * range_bin_time * c/2 * 1e-12; % The "0.5" centers the first bin


    %cull bins up to and including first_bin
    range = [1:bins]' -first_bin;
    %     r.squared = range.^2; % moved this to read_mpl.m
    %      rawcts(1:first_bin,:) = [];
    %      signal(1:first_bin,:) = [];
    range = range*range_bin_time*c/2*1e-12;
    signal = (((range>0).*(range.^2))*ones(1,profs)).* signal;
    %     range = range*range_bin_time*c/2*1e-12 - r.range_offset ;
    %     range(first_bin) = ((first_bin)* range_bin_time*c/2*1e-12 - r.range_offset)/2;

    r.bg = [fix(bins*.87):ceil(bins*.97)];
    bg = mean(rawcts(r.bg,:));

    hk.bg = bg;
    lidar.rawcts =rawcts;
    lidar.time = time;
    lidar.statics = statics;
    lidar.hk = hk;
    lidar.range = range;
    lidar.r = r;
    lidar.prof = signal .* ((range.^2)*ones(size(lidar.time)));
end
status = 1;
