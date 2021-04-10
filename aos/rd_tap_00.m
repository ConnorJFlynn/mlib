function [tap, raw] = rd_tap_00(infile);

if ~exist('infile','var')
    infile = getfullname('*tap*.00.*.csv','tap_raw','Select a raw TAP file.');
end
if exist(infile,'file')
    %   Detailed explanation goes here
    fid = fopen(infile);
else
    disp('No valid file selected.')
    return
end

% DateTime,Record type,Status,Elapsed time,Filter ID,Active spot,Flow rate,Sample vol,Case temp,Sample air temp,Ref0 DARK, Ref0 RED, Ref0 GRN, Ref0 BLU,CH1 DARK,CH1 RED,CH1 GRN,CH1 BLU,CH2 DARK,CH2 RED,CH2 GRN,CH2 BLU,CH3 DARK,CH3 RED,CH3 GRN,CH3 BLU,CH4 DARK,CH4 RED,CH4 GRN,CH4 BLU,CH5 DARK,CH5 RED,CH5 GRN,CH5 BLU,CH5 DARK,CH6 RED,CH6 GRN,CH6 BLU,CH7 DARK,CH7 RED,CH7 GRN,CH7 BLU,CH8 DARK,CH8 RED,CH8 GRN,CH8 BLU,Ref9 DARK, Ref9 RED, Ref9 GRN, Ref9 BLU
% 2015-12-06T04:00:00.48Z, 03, 0000, 004f9b2f, 001a, 07, 1.584, 0.137717, 34.89, 35.46, c2ffc983, 4901c0e3, 48a0d990, 48e0b5d6, c33fe12a, 48c3a7c2, 48694746, 4897c850, c2da3546, 48de59c3, 4877ca1d, 48a6e390, c2e9be6d, 48d85943, 4877e963, 48a977d6, c366147a, 48f16633, 488c113f, 48b4ce49, c3694505, 48ebd0ea, 4888d908, 48b4a963, c3865bbe, 48ea7770, 4894b35e, 48b35962, c38530e2, 49087568, 48ad6053, 48df6066, c268f27d, 48eae5b0, 4896e0ab, 48d33d80, c29fb28a, 490d8b02, 48b69957, 48f2391b
this = fgetl(fid);
while isempty(strfind(this,'Date(yymmdd),'))&&~feof(fid)
    this = fgetl(fid);
end

% labels = textscan(this,'%s','delimiter',',');
labels = textscan(this,'%s');


fmt_str = '%s '; % Date/time,
fmt_str = [fmt_str, '%f %s %s %s ']; %msg_type, flags, secs_hex, filt_id
fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_slpm, sample_vol, T_case, T_sample
fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1
fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3
fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5
fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7
fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9

A = textscan(fid,fmt_str, 'delimiter',','); fclose(fid);
        [raw.pname,raw.fname, ext] = fileparts(infile);
        raw.pname = [raw.pname, filesep]; raw.fname = [raw.fname, ext];
        raw.time_str = A{1};
        raw.time = datenum(strrep(strrep(raw.time_str,'T',' '),'Z',' '),'yyyy-mm-dd HH:MM:SS');
        raw.flags_hex = A{3};
        raw.secs_hex = A{4};
        raw.filter_id_hex = A{5};
        raw.spot = A{6};
        raw.flow_slpm = A{7};
        raw.spot_vol = A{8};
        raw.T_case = A{9};
        raw.T_sample = A{10};
        raw.DN_Dark_0 = A{11}; raw.DN_Red_0 = A{12}; raw.DN_Grn_0 = A{13};raw.DN_Blu_0 = A{14};
        raw.DN_Dark_1 = A{15}; raw.DN_Red_1 = A{16}; raw.DN_Grn_1 = A{17};raw.DN_Blu_1 = A{18};
        raw.DN_Dark_2 = A{19}; raw.DN_Red_2 = A{20}; raw.DN_Grn_2 = A{21};raw.DN_Blu_2 = A{22};
        raw.DN_Dark_3 = A{23}; raw.DN_Red_3 = A{24}; raw.DN_Grn_3 = A{25};raw.DN_Blu_3 = A{26};
        raw.DN_Dark_4 = A{27}; raw.DN_Red_4 = A{28}; raw.DN_Grn_4 = A{29};raw.DN_Blu_4 = A{30};
        raw.DN_Dark_5 = A{31}; raw.DN_Red_5 = A{32}; raw.DN_Grn_5 = A{33};raw.DN_Blu_5 = A{34};
        raw.DN_Dark_6 = A{35}; raw.DN_Red_6 = A{36}; raw.DN_Grn_6 = A{37};raw.DN_Blu_6 = A{38};
        raw.DN_Dark_7 = A{39}; raw.DN_Red_7 = A{40}; raw.DN_Grn_7 = A{41};raw.DN_Blu_7 = A{42};
        raw.DN_Dark_8 = A{43}; raw.DN_Red_8 = A{44}; raw.DN_Grn_8 = A{45};raw.DN_Blu_8 = A{46};
        raw.DN_Dark_9 = A{47}; raw.DN_Red_9 = A{48}; raw.DN_Grn_9 = A{49};raw.DN_Blu_9 = A{50};                

% fclose(fid)
% cpc data in  N61_20140331T180302Z
% !row;colhdr;N61a,N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
% !row;mvc;N61a,N61a;ZZZ;0;9999-99-99T99:99:99Z;FFFF;FFFF;99999.9
% N61a,AMF,1396310640,2014-04-01T00:04:00Z,0000,0000,02388.7

% myriad flows that actually come from other files but for QL quality we'll
% use these nominal values.

tap.time = datenum(strrep(strrep(raw.time_str,'T',' '),'Z',' '),'yyyy-mm-dd HH:MM:SS');
tap.flags = hex2dec(raw.flags_hex);
tap.spot_active = raw.spot';
tap.spot_vol = raw.spot_vol';
tap.filter_id = hex2dec(raw.filter_id_hex);
tap.flow_slpm = raw.flow_slpm;
tap.T_case = raw.T_case;
tap.T_sample = raw.T_sample;

tap.DN_Dark_0= typecast(uint32(hex2dec(raw.DN_Dark_0)),'single');
tap.DN_Red_0= typecast(uint32(hex2dec(raw.DN_Red_0)),'single');
tap.DN_Grn_0= typecast(uint32(hex2dec(raw.DN_Grn_0)),'single');
tap.DN_Blu_0= typecast(uint32(hex2dec(raw.DN_Blu_0)),'single');

tap.DN_Dark_1= typecast(uint32(hex2dec(raw.DN_Dark_1)),'single');
tap.DN_Red_1= typecast(uint32(hex2dec(raw.DN_Red_1)),'single');
tap.DN_Grn_1= typecast(uint32(hex2dec(raw.DN_Grn_1)),'single');
tap.DN_Blu_1= typecast(uint32(hex2dec(raw.DN_Blu_1)),'single');

tap.DN_Dark_2= typecast(uint32(hex2dec(raw.DN_Dark_2)),'single');
tap.DN_Red_2= typecast(uint32(hex2dec(raw.DN_Red_2)),'single');
tap.DN_Grn_2= typecast(uint32(hex2dec(raw.DN_Grn_2)),'single');
tap.DN_Blu_2= typecast(uint32(hex2dec(raw.DN_Blu_2)),'single');

tap.DN_Dark_3= typecast(uint32(hex2dec(raw.DN_Dark_3)),'single');
tap.DN_Red_3= typecast(uint32(hex2dec(raw.DN_Red_3)),'single');
tap.DN_Grn_3= typecast(uint32(hex2dec(raw.DN_Grn_3)),'single');
tap.DN_Blu_3= typecast(uint32(hex2dec(raw.DN_Blu_3)),'single');

tap.DN_Dark_4= typecast(uint32(hex2dec(raw.DN_Dark_4)),'single');
tap.DN_Red_4= typecast(uint32(hex2dec(raw.DN_Red_4)),'single');
tap.DN_Grn_4= typecast(uint32(hex2dec(raw.DN_Grn_4)),'single');
tap.DN_Blu_4= typecast(uint32(hex2dec(raw.DN_Blu_4)),'single');

tap.DN_Dark_5= typecast(uint32(hex2dec(raw.DN_Dark_5)),'single');
tap.DN_Red_5= typecast(uint32(hex2dec(raw.DN_Red_5)),'single');
tap.DN_Grn_5= typecast(uint32(hex2dec(raw.DN_Grn_5)),'single');
tap.DN_Blu_5= typecast(uint32(hex2dec(raw.DN_Blu_5)),'single');

tap.DN_Dark_6= typecast(uint32(hex2dec(raw.DN_Dark_6)),'single');
tap.DN_Red_6= typecast(uint32(hex2dec(raw.DN_Red_6)),'single');
tap.DN_Grn_6= typecast(uint32(hex2dec(raw.DN_Grn_6)),'single');
tap.DN_Blu_6= typecast(uint32(hex2dec(raw.DN_Blu_6)),'single');

tap.DN_Dark_7= typecast(uint32(hex2dec(raw.DN_Dark_7)),'single');
tap.DN_Red_7= typecast(uint32(hex2dec(raw.DN_Red_7)),'single');
tap.DN_Grn_7= typecast(uint32(hex2dec(raw.DN_Grn_7)),'single');
tap.DN_Blu_7= typecast(uint32(hex2dec(raw.DN_Blu_7)),'single');

tap.DN_Dark_8= typecast(uint32(hex2dec(raw.DN_Dark_8)),'single');
tap.DN_Red_8= typecast(uint32(hex2dec(raw.DN_Red_8)),'single');
tap.DN_Grn_8= typecast(uint32(hex2dec(raw.DN_Grn_8)),'single');
tap.DN_Blu_8= typecast(uint32(hex2dec(raw.DN_Blu_8)),'single');

tap.DN_Dark_9= typecast(uint32(hex2dec(raw.DN_Dark_9)),'single');
tap.DN_Red_9= typecast(uint32(hex2dec(raw.DN_Red_9)),'single');
tap.DN_Grn_9= typecast(uint32(hex2dec(raw.DN_Grn_9)),'single');
tap.DN_Blu_9= typecast(uint32(hex2dec(raw.DN_Blu_9)),'single');


N = 20;
% figure; plot(serial2hs(tap.time(spot_4)), real(log(-diffN((tap.DN_Red_4(spot_4)-tap.DN_Dark_4(spot_4))./((tap.DN_Red_0(spot_4)-tap.DN_Dark_0(spot_4))),N))),'.',...
%    serial2hs(tap.time(~spot_4)), real(log(-diffN((tap.DN_Red_5(~spot_4)-tap.DN_Dark_5(~spot_4))./((tap.DN_Red_1(~spot_4)-tap.DN_Dark_1(~spot_4))),N))),'.')
% legend('spot 4: sig/ref','spot 5: sig/ref' );
figure; plot(serial2hs(tap.time), tap.DN_Red_2,'x')

figure; plot(tap.time, [tap.DN_Grn_0,tap.DN_Grn_1],'.'); dynamicDateTicks;

return
