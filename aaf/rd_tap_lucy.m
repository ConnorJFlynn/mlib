function [tap, raw] = rd_tap_lucy(infile);
% [tap, raw] = rd_tap_lucy(infile);

% This reads TAP serial data created by Lucy's Labview SW version 1.
% Because Lucy was careful outputting the data records we can read the
% entire file at once in contrast to rd_tap_tty which reads a row at a time

if ~exist('infile','var')
   infile = getfullname('TAP_RAW_*.dat','tap_raw','Select a raw TAP file.');
end
if iscell(infile)
   [tap, raw] = rd_tap_lucy(infile{1});
   for in = 2:length(infile)
      [tap_, raw_] = rd_tap_lucy(infile{in});
      tap = cat_timeseries(tap, tap_);
      raw = cat_timeseries(raw, raw_);
   end
   clear tap_ raw_
   return
end

if ~iscell(infile)&&exist(infile,'file')
   %   Detailed explanation goes here
   fid = fopen(infile);
      
   % Lots of other preliminary metadata but header row looks like this:
   % Date(yymmdd),Time(24hr),Record Type,Status Flag,Elapsed Time,Filter ID,Active Spot,Flow Rate(SLPM),Sample Volume for Active Spot(m3),Case Temp(C),Sample Air Temp(C),CH0 Dark,CH0 RED,CH0 GRN,CH0 BLU,CH1 Dark,CH1 RED,CH1 GRN,CH1 BLU,CH2 Dark,CH2 RED,CH2 GRN,CH2 BLU,CH3 Dark,CH3 RED,CH3 GRN,CH3 BLU,CH4 Dark,CH4 RED,CH4 GRN,CH4 BLU,CH5 Dark,CH5 RED,CH5 GRN,CH5 BLU,CH6 Dark,CH6 RED,CH6 GRN,CH6 BLU,CH7 Dark,CH7 RED,CH7 GRN,CH7 BLU,CH8 Dark,CH8 RED,CH8 GRN,CH8 BLU,CH9 Dark,CH9 RED,CH9 GRN,CH9 BLU
   
   this = fgetl(fid);
   while ~feof(fid) && (isempty(strfind(this,'Date'))||isempty(strfind(this,'Time'))||isempty(strfind(this,'CH9 BLU')))
      this = fgetl(fid);
   end
   fmt_str = '%s %s '; % Date(yymmdd),Time(24hr),
   fmt_str = [fmt_str, '%*s %s %s %s ']; %Record Type,Status Flag,Elapsed Time,Filter ID,
   fmt_str = [fmt_str, '%f %f %f %f %f ']; % Active Spot,Flow Rate(SLPM),Sample Volume for Active Spot(m3),Case Temp(C),Sample Air Temp(C),
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1 8
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3 8
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5 8
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7 8
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9 8
   
   [raw.pname,raw.fname, ext] = fileparts(infile);
   raw.pname = [raw.pname, filesep]; raw.fname = [raw.fname, ext];
   A = textscan(fid,fmt_str, 'delimiter',','); 
   fclose(fid);
   D = A{1}; T = A{2};
   for X = length(D):-1:1
      DT(X) = {[D{X},' ',T{X}]};
   end
   
   raw.time_str = DT;
   raw.time = datenum(DT,'yy/mm/dd HH:MM:SS');
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
   
   tap.pname = raw.pname; tap.fname = raw.fname;
   % tap.time = (start_time + (raw.secs_hex-raw.secs_hex(1))./(24*60*60))';
   tap.time = raw.time;
   tap.secs_hex = hex2dec(raw.secs_hex);
   % Reference the times against the seconds elapsed reported by the TAP
   tap.time = tap.time(1) + (tap.secs_hex - tap.secs_hex(1))./(24.*60.*60);
   tap.flags = hex2dec(raw.flags_hex);
   tap.active_spot = raw.spot;
   tap.spot_vol = raw.spot_vol;
   tap.filter_id = hex2dec(raw.filter_id_hex);
   tap.flow_slpm = raw.flow_slpm;
   tap.T_case = raw.T_case;
   tap.T_sample = raw.T_sample;
   
   % me.time = tap_a0.time;
   % me.filter_id = tap_a0.vdata.filter_id;
   % me.active_spot = tap_a0.vdata.active_spot_number;
   
   
   for ch = 10:-1:1
      tap.signal_dark_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Dark_',num2str(mod(ch,10))]))),'single');
      tap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Blu_',num2str(mod(ch,10))]))),'single');
      tap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Grn_',num2str(mod(ch,10))]))),'single');
      tap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(raw.(['DN_Red_',num2str(mod(ch,10))]))),'single');
   end
   tap.signal_blue = tap.signal_blue_raw - tap.signal_dark_raw;
   tap.signal_green = tap.signal_green_raw - tap.signal_dark_raw;
   tap.signal_red = tap.signal_red_raw - tap.signal_dark_raw;
   
else
   disp('No valid file selected.')
   return
end

return
