function tap = rd_tap_raw_asap(infile)
% tap = rd_tap_raw_asap(infile)
% Reads raw TAP data from ASAP field campaign in San Antonio.
% This is a preliminary format generated by Lucy.  

if ~exist('infile','var')
    infile = getfullname('TAP*.dat','tap_asap','Select tap asap raw data file.');
end
if exist(infile,'file')
    %   Detailed explanation goes here
    fid = fopen(infile);
else
    disp('No valid file selected.')
    return
end
    done = false
    while ~done
        this = fgetl(fid);
        start = strfind(this,'Date(yymmdd)');
        if feof(fid)||~isempty(start)
            done = true;
        end
    end
%     start_time = datenum(this(start+10:end),'yyyy.mm.dd HH:MM:SS');

n = 1;
% Date(yymmdd),Time(24hr),Record Type,Status Flag,Elapsed Time,Filter ID,Active Spot,Flow Rate(SLPM),Sample Volume for Active Spot(m3),Case Temp(C),Sample Air Temp(C),CH0 Dark,CH0 RED,CH0 GRN,CH0 BLU,CH1 Dark,CH1 RED,CH1 GRN,CH1 BLU,CH2 Dark,CH2 RED,CH2 GRN,CH2 BLU,CH3 Dark,CH3 RED,CH3 GRN,CH3 BLU,CH4 Dark,CH4 RED,CH4 GRN,CH4 BLU,CH5 Dark,CH5 RED,CH5 GRN,CH5 BLU,CH6 Dark,CH6 RED,CH6 GRN,CH6 BLU,CH7 Dark,CH7 RED,CH7 GRN,CH7 BLU,CH8 Dark,CH8 RED,CH8 GRN,CH8 BLU,CH9 Dark,CH9 RED,CH9 GRN,CH9 BLU
% 17/05/20,11:58:04,03, 0000, 0000de6d, 0084, 01, 2.171, 0.005880, 35.06, 34.73, c333227a, 494e7bdd, 48da7025, 494f1073, c330c4aa, 490dd696, 4894f9f9, 4903efae, c3247efe, 49374075, 48c168f7, 4935dd49, c32b1067, 4931394a, 48c003c9, 4938115b, c2ac5373, 492c7710, 48bb53b4, 492e2212, c2acdda1, 492d541a, 48b83682, 49317d77, c34ae5d2, 492f6b36, 48c25516, 4933db54, c34c6918, 4936d377, 48bf8a57, 49331a39, c36bb4b0, 4930e80e, 48c1054d, 49393110, c37f6233, 4941399c, 48d311a0, 49415ced
%         fmt_str = '%s %s '; % Date/time, "I"
        fmt_str = ['%s %s %*s %s %s %s ']; %Date(yymmdd),Time(24hr), msg_type, flags, secs_hex, filt_id 2,
        fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_slpm, sample_vol, T_case, T_sample 5
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1 8
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3 8
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5 8
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7 8
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9 8

        this = fgetl(fid);
        [raw.pname,raw.fname, ext] = fileparts(infile);
        raw.pname = [raw.pname, filesep]; raw.fname = [raw.fname, ext];
while ~feof(fid)

    
    if length(this)>100
        %^ =~=~=~=~=~=~=~=~=~=~=~= PuTTY log 2016.08.01 19:56:40 =~=~=~=~=~=~=~=~=~=~=~=
        % datetime, ?, 3, flags, secs_hex, filt_id_str, spot, flow, sample_length, head_Temp, sample_air_temp, 
%         fmt_str = '%s %s '; % Date/time, "I"
%         fmt_str = [fmt_str, '%f %s %s %s ']; %msg_type, flags, secs_hex, filt_id 
%         fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_slpm, sample_vol, T_case, T_sample
%         fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1
%         fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3
%         fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5
%         fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7
%         fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9

        A = textscan(this,fmt_str, 'delimiter',',');
%         raw.s_elapsed = A{2};
        YY = A{1}; HH = A{2}; DT = [YY{:}, ' ', HH{:}];A(1) = [];A(1) = [];
        raw.time(n) = datenum(DT,'yy/mm/dd HH:MM:SS');
        tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.flags_hex(n) = sscanf(tmp,'%x'); 
        tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.secs_hex(n) = sscanf(tmp,'%x');
        tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.filter_id_hex(n) = sscanf(tmp,'%x');
        raw.spot(n) = A{1};
        raw.flow_slpm(n) = A{2};
        raw.spot_vol(n) = A{3};
        raw.T_case(n) = A{4};
        raw.T_sample(n) = A{5}; A(1:5) = [];
        raw.DN_Dark_0(n) = A{1}; raw.DN_Red_0(n) = A{2}; raw.DN_Grn_0(n) = A{3};raw.DN_Blu_0(n) = A{4};
        raw.DN_Dark_1(n) = A{5}; raw.DN_Red_1(n) = A{6}; raw.DN_Grn_1(n) = A{7};raw.DN_Blu_1(n) = A{8};
        raw.DN_Dark_2(n) = A{9}; raw.DN_Red_2(n) = A{10}; raw.DN_Grn_2(n) = A{11};raw.DN_Blu_2(n) = A{12};
        raw.DN_Dark_3(n) = A{13}; raw.DN_Red_3(n) = A{14}; raw.DN_Grn_3(n) = A{15};raw.DN_Blu_3(n) = A{16};
        raw.DN_Dark_4(n) = A{17}; raw.DN_Red_4(n) = A{18}; raw.DN_Grn_4(n) = A{19};raw.DN_Blu_4(n) = A{20};
        raw.DN_Dark_5(n) = A{21}; raw.DN_Red_5(n) = A{22}; raw.DN_Grn_5(n) = A{23};raw.DN_Blu_5(n) = A{24};
        raw.DN_Dark_6(n) = A{25}; raw.DN_Red_6(n) = A{26}; raw.DN_Grn_6(n) = A{27};raw.DN_Blu_6(n) = A{28};
        raw.DN_Dark_7(n) = A{29}; raw.DN_Red_7(n) = A{30}; raw.DN_Grn_7(n) = A{31};raw.DN_Blu_7(n) = A{32};
        raw.DN_Dark_8(n) = A{33}; raw.DN_Red_8(n) = A{34}; raw.DN_Grn_8(n) = A{35};raw.DN_Blu_8(n) = A{36};
        raw.DN_Dark_9(n) = A{37}; raw.DN_Red_9(n) = A{38}; raw.DN_Grn_9(n) = A{39};raw.DN_Blu_9(n) = A{40};                
        n = n+1
    end
    this = fgetl(fid);
end
fclose(fid)
% cpc data in  N61_20140331T180302Z
% !row;colhdr;N61a,N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
% !row;mvc;N61a,N61a;ZZZ;0;9999-99-99T99:99:99Z;FFFF;FFFF;99999.9
% N61a,AMF,1396310640,2014-04-01T00:04:00Z,0000,0000,02388.7

% myriad flows that actually come from other files but for QL quality we'll
% use these nominal values.
clap.pname = raw.pname, clap.fname = raw.fname;
% clap.time = (start_time + (raw.secs_hex-raw.secs_hex(1))./(24*60*60))';
clap.time = raw.time;
clap.flags = uint16(raw.flags_hex)';
clap.spot_active = raw.spot';
clap.spot_vol = raw.spot_vol';
clap.filter_id = uint16(raw.filter_id_hex)';
clap.flow_slpm = raw.flow_slpm';
clap.T_case = raw.T_case';
clap.T_sample = raw.T_sample';

% me.time = tap_a0.time;
% me.filter_id = tap_a0.vdata.filter_id;
% me.active_spot = tap_a0.vdata.active_spot_number;


for ch = 10:-1:1
    clap.signal_dark_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Dark_',num2str(mod(ch,10))]))),'single');
    clap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Blu_',num2str(mod(ch,10))]))),'single');
    clap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Grn_',num2str(mod(ch,10))]))),'single');
    clap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Red_',num2str(mod(ch,10))]))),'single');
end
clap.signal_blue = clap.signal_blue_raw - clap.signal_dark_raw;
clap.signal_green = clap.signal_green_raw - clap.signal_dark_raw;
clap.signal_red = clap.signal_red_raw - clap.signal_dark_raw;



% c343ef6c
% typecast(uint32(hex2dec('c343ef6c')),'single');
% N = 20;
% figure; plot(serial2hs(clap.time(spot_4)), real(log(-diffN((clap.DN_Red_4(spot_4)-clap.DN_Dark_4(spot_4))./((clap.DN_Red_0(spot_4)-clap.DN_Dark_0(spot_4))),N))),'.',...
%    serial2hs(clap.time(~spot_4)), real(log(-diffN((clap.DN_Red_5(~spot_4)-clap.DN_Dark_5(~spot_4))./((clap.DN_Red_1(~spot_4)-clap.DN_Dark_1(~spot_4))),N))),'.')
% legend('spot 4: sig/ref','spot 5: sig/ref' );
% figure; plot(serial2hs(clap.time), clap.DN_Red_2,'x')

% figure; plot(clap.time, [clap.DN_Grn_0,clap.DN_Grn_1],'.'); dynamicDateTicks;

return
