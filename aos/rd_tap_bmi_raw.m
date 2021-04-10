function [clap, raw] = rd_tap_bmi_raw(infile);

if ~isavar('infile')
   infile = getfullname('RAW_TAP_*.dat','tap_tty','Select tap puTTY log file.');
end

if iscell(infile)&&length(infile)>1
   [clap, raw] = rd_tap_bmi_raw(infile{1});
   raw.time = clap.time; clap.fname = raw.fname; 
   [clap2, raw2] = rd_tap_bmi_raw(infile(2:end));
   raw2.time = clap2.time;clap2.fname = raw2.fname;
%    clap_.fname = unique([clap.fname,clap2.fname]);
   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   clap = cat_timeseries(clap, clap2); clap.fname = raw.fname; clap.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      %   Detailed explanation goes here
      fid = fopen(infile);
   else
      disp('No valid file selected.')
      return
   end
   done = false;
   while ~done
      this = fgetl(fid);
      commas = length(strfind(this,','));
      if feof(fid)||(commas == 48)||(commas == 50)
         done = true;
      end
   end
   [raw.pname,raw.fname, ext] = fileparts(infile);
   raw.pname = {[raw.pname, filesep]}; raw.fname = {[raw.fname, ext]};
   clap.fname = raw.fname; clap.pname = raw.pname;
   try 
      start_time = datenum(this,'yymmdd HH:MM:SS');
   catch
      start_time = datenum(this,'yymmdd,HH:MM:SS');
   end
   
   n = 1;
   % 160901	21:50:06
   fmt_str = '%*s %*s '; % Date/time, "I"
   % 	03, 0000, 000187da, 00cb,
   fmt_str = [fmt_str, '%*s %s %s %s ']; %msg_type, flags, secs_hex, filt_id 2
   % 05, 1.019, 0.377724, 29.96, 29.99,
   fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_lpm, sample_vol, T_case, T_sample 5
   %         c3336424, 4958008e, 48df56a0, 495a6466, c33127ee, 49415515, 48cfc476, 49457381,
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB0, DRGB1 8
   %         c3260eba, 495562a5, 48dc8b52, 49566e7a, c32d1de3, 493fa8cb, 48ca1d3e, 4947cc52,
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB2, DRGB3 8
   %         c2b03467, 491e0e32, 48a3e271, 4919b9f8, c2afb4d9, 493901ca, 48bfb287, 493f2b4e,
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB4, DRGB5 8
   %         c34dacb3, 494167ec, 48d1f17d, 4949d6c1, c34e1e25, 49511b8d, 48d69d6a, 49508f75,
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB6, DRGB7 8
   %         c36c1a80, 4944378e, 48d0b032, 494fdd63, c380221a, 494180e2, 48ce59e6, 4942d85f
   fmt_str = [fmt_str, '%s %s %s %s %s %s %s %s ']; %DRGB8, DRGB9 8
   
   this = fgetl(fid);
   
   while ~feof(fid)
      if commas==48||commas==50
         A = textscan(strrep(this,',',' '),fmt_str );
         if length(A)==48 && ~isempty(A{end})
            tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.flags_hex(n) = sscanf(tmp,'%x');
            tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.secs_hex(n) = sscanf(tmp,'%x');
            tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.filter_id_hex(n) = sscanf(tmp,'%x');
            raw.spot(n) = A{1};
            raw.flow_lpm(n) = A{2};
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
            n = n+1;
         end
      else
         disp(['Skipping mal-formed row :',this])
      end
      this = fgetl(fid);
      commas = length(strfind(this,','));
   end
   fclose(fid);
   % cpc data in  N61_20140331T180302Z
   % !row;colhdr;N61a,N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
   % !row;mvc;N61a,N61a;ZZZ;0;9999-99-99T99:99:99Z;FFFF;FFFF;99999.9
   % N61a,AMF,1396310640,2014-04-01T00:04:00Z,0000,0000,02388.7
   
   % myriad flows that actually come from other files but for QL quality we'll
   % use these nominal values.
   
   clap.time = (start_time + (raw.secs_hex-raw.secs_hex(1))./(24*60*60))';
   clap.flags = uint16(raw.flags_hex)';
   clap.spot_active = raw.spot';
   clap.spot_vol = raw.spot_vol';
   clap.filter_id = uint16(raw.filter_id_hex)';
   clap.flow_lpm = raw.flow_lpm';
   clap.T_case = raw.T_case';
   clap.T_sample = raw.T_sample';
   
   % me.time = tap_a0.time;
   % me.filter_id = tap_a0.vdata.filter_id;
   % me.active_spot = tap_a0.vdata.active_spot_number;
   clap = tap_cast(raw, clap);
   
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
end
return

function clap = tap_cast(raw,clap);
% This function applies "typecast" to generate single-precision floating
% point number from the TAP and CLAP raw streams.  It first attempts the
% computationally efficient block-conversion but on error will step through
% each line of raw input
clap.signal_dark_raw = NaN(10,length(clap.time));
clap.signal_blue_raw = NaN(10,length(clap.time));
clap.signal_green_raw = NaN(10,length(clap.time));
clap.signal_red_raw =  NaN(10,length(clap.time));

% try processing entire string blocks
try
   for ch = 10:-1:1
      tmp_str = ['DN_Dark_',num2str(mod(ch,10))];
      clap.signal_dark_raw(ch,:) = typecast(uint32(hex2dec(raw.(tmp_str))),'single');
      tmp_str = ['DN_Red_',num2str(mod(ch,10))];
      clap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(raw.(tmp_str))),'single');
      tmp_str = ['DN_Grn_',num2str(mod(ch,10))];
      clap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(raw.(tmp_str))),'single');
      tmp_str = ['DN_Blu_',num2str(mod(ch,10))];
      clap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(raw.(tmp_str))),'single');
   end
catch
   
   for t = length(raw.secs_hex):-1:1
      % Test one record at a time, evaluating records in the order they
      % appeear in the original string.  As soon as any fails, skip the
      % rest of the time record.
      try
         for ch = 10:-1:1
            tmp_str = ['DN_Dark_',num2str(mod(ch,10))];
            tmp_hex = raw.(tmp_str){t};
            clap.signal_dark_raw(ch,t) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Red_',num2str(mod(ch,10))];
            tmp_hex = raw.(tmp_str){t};
            clap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Grn_',num2str(mod(ch,10))];
            tmp_hex = raw.(tmp_str){t};
            clap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Blu_',num2str(mod(ch,10))];
            tmp_hex = raw.(tmp_str){t};
            clap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
         end
      catch
         disp(['Skipping record: ',num2str(t)])
      end
      
   end
end

return