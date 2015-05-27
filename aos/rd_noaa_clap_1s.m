function [clap, raw] = rd_noaa_clap_1s(infile);

if ~exist('infile','var')
    infile = getfullname_('a12_*','NOAA_AOS_raw','Select an a12 clap file.');
end
if exist(infile,'file')
    %   Detailed explanation goes here
    fid = fopen(infile);
else
    disp('No valid file selected.')
    return
end

n = 1;
        fmt_str = '%s %s '; % Date/time, "I"
        fmt_str = [fmt_str, '%f %s %s %s ']; %msg_type, flags, secs_hex, filt_id 
        fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_slpm, sample_vol, T_case, T_sample
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7
        fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9
while ~feof(fid)
    this = fgetl(fid);
    if length(this)>50
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
        time_str = A{1};
%         clap.time(n) = datenum(time_str,'yyyy-mm-ddTHH:MM:SSZ');
        raw.time_str(n) = time_str;
        raw.flags_hex(n) = A{4};
        raw.secs_hex(n) = A{5};
        raw.filter_id_hex(n) = A{6};
        raw.spot(n) = A{7};
        raw.flow_slpm(n) = A{8};
        raw.spot_vol(n) = A{9};
        raw.T_case(n) = A{10};
        raw.T_sample(n) = A{11};
        raw.DN_Dark_0(n) = A{12}; raw.DN_Red_0(n) = A{13}; raw.DN_Grn_0(n) = A{14};raw.DN_Blu_0(n) = A{15};
        raw.DN_Dark_1(n) = A{16}; raw.DN_Red_1(n) = A{17}; raw.DN_Grn_1(n) = A{18};raw.DN_Blu_1(n) = A{19};
        raw.DN_Dark_2(n) = A{20}; raw.DN_Red_2(n) = A{21}; raw.DN_Grn_2(n) = A{22};raw.DN_Blu_2(n) = A{23};
        raw.DN_Dark_3(n) = A{24}; raw.DN_Red_3(n) = A{25}; raw.DN_Grn_3(n) = A{26};raw.DN_Blu_3(n) = A{27};
        raw.DN_Dark_4(n) = A{28}; raw.DN_Red_4(n) = A{29}; raw.DN_Grn_4(n) = A{30};raw.DN_Blu_4(n) = A{31};
        raw.DN_Dark_5(n) = A{32}; raw.DN_Red_5(n) = A{33}; raw.DN_Grn_5(n) = A{34};raw.DN_Blu_5(n) = A{35};
        raw.DN_Dark_6(n) = A{36}; raw.DN_Red_6(n) = A{37}; raw.DN_Grn_6(n) = A{38};raw.DN_Blu_6(n) = A{39};
        raw.DN_Dark_7(n) = A{40}; raw.DN_Red_7(n) = A{41}; raw.DN_Grn_7(n) = A{42};raw.DN_Blu_7(n) = A{43};
        raw.DN_Dark_8(n) = A{44}; raw.DN_Red_8(n) = A{45}; raw.DN_Grn_8(n) = A{46};raw.DN_Blu_8(n) = A{47};
        raw.DN_Dark_9(n) = A{48}; raw.DN_Red_9(n) = A{49}; raw.DN_Grn_9(n) = A{50};raw.DN_Blu_9(n) = A{51};                
         n = n+1;
    end
end
fclose(fid)
% cpc data in  N61_20140331T180302Z
% !row;colhdr;N61a,N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
% !row;mvc;N61a,N61a;ZZZ;0;9999-99-99T99:99:99Z;FFFF;FFFF;99999.9
% N61a,AMF,1396310640,2014-04-01T00:04:00Z,0000,0000,02388.7

% myriad flows that actually come from other files but for QL quality we'll
% use these nominal values.

clap.time = datenum(strrep(strrep(raw.time_str,'T',' '),'Z',' '),'yyyy-mm-dd HH:MM:SS');
clap.flags = hex2dec(raw.flags_hex);
clap.spot_active = raw.spot';
clap.spot_vol = raw.spot_vol';
clap.filter_id = hex2dec(raw.filter_id_hex);
clap.flow_slpm = raw.flow_slpm;
clap.T_case = raw.T_case;
clap.T_sample = raw.T_sample;
clap.DN_Dark_0= typecast(uint32(hex2dec(raw.DN_Dark_0)),'single');clap.DN_Red_0= typecast(uint32(hex2dec(raw.DN_Red_0)),'single');clap.DN_Grn_0= typecast(uint32(hex2dec(raw.DN_Grn_0)),'single');clap.DN_Blu_0= typecast(uint32(hex2dec(raw.DN_Blu_0)),'single');
clap.DN_Dark_1= typecast(uint32(hex2dec(raw.DN_Dark_1)),'single');clap.DN_Red_1= typecast(uint32(hex2dec(raw.DN_Red_1)),'single');clap.DN_Grn_1= typecast(uint32(hex2dec(raw.DN_Grn_1)),'single');clap.DN_Blu_1= typecast(uint32(hex2dec(raw.DN_Blu_1)),'single');
clap.DN_Dark_2= typecast(uint32(hex2dec(raw.DN_Dark_2)),'single');clap.DN_Red_2= typecast(uint32(hex2dec(raw.DN_Red_2)),'single');clap.DN_Grn_2= typecast(uint32(hex2dec(raw.DN_Grn_2)),'single');clap.DN_Blu_2= typecast(uint32(hex2dec(raw.DN_Blu_2)),'single');
clap.DN_Dark_3= typecast(uint32(hex2dec(raw.DN_Dark_3)),'single');clap.DN_Red_3= typecast(uint32(hex2dec(raw.DN_Red_3)),'single');clap.DN_Grn_3= typecast(uint32(hex2dec(raw.DN_Grn_3)),'single');clap.DN_Blu_3= typecast(uint32(hex2dec(raw.DN_Blu_3)),'single');
clap.DN_Dark_4= typecast(uint32(hex2dec(raw.DN_Dark_4)),'single');clap.DN_Red_4= typecast(uint32(hex2dec(raw.DN_Red_4)),'single');clap.DN_Grn_4= typecast(uint32(hex2dec(raw.DN_Grn_4)),'single');clap.DN_Blu_4= typecast(uint32(hex2dec(raw.DN_Blu_4)),'single');
clap.DN_Dark_5= typecast(uint32(hex2dec(raw.DN_Dark_5)),'single');clap.DN_Red_5= typecast(uint32(hex2dec(raw.DN_Red_5)),'single');clap.DN_Grn_5= typecast(uint32(hex2dec(raw.DN_Grn_5)),'single');clap.DN_Blu_5= typecast(uint32(hex2dec(raw.DN_Blu_5)),'single');
clap.DN_Dark_6= typecast(uint32(hex2dec(raw.DN_Dark_6)),'single');clap.DN_Red_6= typecast(uint32(hex2dec(raw.DN_Red_6)),'single');clap.DN_Grn_6= typecast(uint32(hex2dec(raw.DN_Grn_6)),'single');clap.DN_Blu_6= typecast(uint32(hex2dec(raw.DN_Blu_6)),'single');
clap.DN_Dark_7= typecast(uint32(hex2dec(raw.DN_Dark_7)),'single');clap.DN_Red_7= typecast(uint32(hex2dec(raw.DN_Red_7)),'single');clap.DN_Grn_7= typecast(uint32(hex2dec(raw.DN_Grn_7)),'single');clap.DN_Blu_7= typecast(uint32(hex2dec(raw.DN_Blu_7)),'single');
clap.DN_Dark_8= typecast(uint32(hex2dec(raw.DN_Dark_8)),'single');clap.DN_Red_8= typecast(uint32(hex2dec(raw.DN_Red_8)),'single');clap.DN_Grn_8= typecast(uint32(hex2dec(raw.DN_Grn_8)),'single');clap.DN_Blu_8= typecast(uint32(hex2dec(raw.DN_Blu_8)),'single');
clap.DN_Dark_9= typecast(uint32(hex2dec(raw.DN_Dark_9)),'single');clap.DN_Red_9= typecast(uint32(hex2dec(raw.DN_Red_9)),'single');clap.DN_Grn_9= typecast(uint32(hex2dec(raw.DN_Grn_9)),'single');clap.DN_Blu_9= typecast(uint32(hex2dec(raw.DN_Blu_9)),'single');

% N = 20;
% figure; plot(serial2hs(clap.time(spot_4)), real(log(-diffN((clap.DN_Red_4(spot_4)-clap.DN_Dark_4(spot_4))./((clap.DN_Red_0(spot_4)-clap.DN_Dark_0(spot_4))),N))),'.',...
%    serial2hs(clap.time(~spot_4)), real(log(-diffN((clap.DN_Red_5(~spot_4)-clap.DN_Dark_5(~spot_4))./((clap.DN_Red_1(~spot_4)-clap.DN_Dark_1(~spot_4))),N))),'.')
% legend('spot 4: sig/ref','spot 5: sig/ref' );

return
