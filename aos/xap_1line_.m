function xap = xap_1line_(xap_line)
% xap = xap_1line(xap_line)
% Parses a single line of data read from xap, clap, tap to compute raw transmittances
fmt_str = '';
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

if isempty(xap_line)
   A = {};
else
   A = textscan(strrep(xap_line,',',' '),fmt_str );
end
if length(A)==48 && ~isempty(A{end})
   raw.time = now;
   tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.flags_hex = sscanf(tmp,'%x');
   tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.secs_hex = sscanf(tmp,'%x');
   tmp = A{1}; tmp = tmp{:}; A(1) = []; raw.filter_ID_hex = sscanf(tmp,'%x');
   raw.spot = A{1};
   raw.flow_lpm = A{2};
   raw.spot_vol = A{3};
   raw.T_case = A{4};
   raw.T_sample = A{5}; A(1:5) = [];
   raw.DN_Dark_0 = A{1}; raw.DN_Red_0 = A{2}; raw.DN_Grn_0 = A{3};raw.DN_Blu_0 = A{4};
   raw.DN_Dark_1 = A{5}; raw.DN_Red_1 = A{6}; raw.DN_Grn_1 = A{7};raw.DN_Blu_1 = A{8};
   raw.DN_Dark_2 = A{9}; raw.DN_Red_2 = A{10}; raw.DN_Grn_2 = A{11};raw.DN_Blu_2 = A{12};
   raw.DN_Dark_3 = A{13}; raw.DN_Red_3 = A{14}; raw.DN_Grn_3 = A{15};raw.DN_Blu_3 = A{16};
   raw.DN_Dark_4 = A{17}; raw.DN_Red_4 = A{18}; raw.DN_Grn_4 = A{19};raw.DN_Blu_4 = A{20};
   raw.DN_Dark_5 = A{21}; raw.DN_Red_5 = A{22}; raw.DN_Grn_5 = A{23};raw.DN_Blu_5 = A{24};
   raw.DN_Dark_6 = A{25}; raw.DN_Red_6 = A{26}; raw.DN_Grn_6 = A{27};raw.DN_Blu_6 = A{28};
   raw.DN_Dark_7 = A{29}; raw.DN_Red_7 = A{30}; raw.DN_Grn_7 = A{31};raw.DN_Blu_7 = A{32};
   raw.DN_Dark_8 = A{33}; raw.DN_Red_8 = A{34}; raw.DN_Grn_8 = A{35};raw.DN_Blu_8 = A{36};
   raw.DN_Dark_9 = A{37}; raw.DN_Red_9 = A{38}; raw.DN_Grn_9 = A{39};raw.DN_Blu_9 = A{40};

   clap.time = raw.time;
   clap.secs = raw.secs_hex';
   clap.flags = uint16(raw.flags_hex)';
   clap.spot = raw.spot';
   clap.spot_vol = raw.spot_vol';
   clap.filter_ID = uint16(raw.filter_ID_hex)';
   clap.flow_lpm = raw.flow_lpm';
   clap.T_case = raw.T_case';
   clap.T_sample = raw.T_sample';

   clap = tap_cast(raw, clap);

   clap.signal_blue = clap.signal_blue_raw - clap.signal_dark_raw;
   clap.signal_green = clap.signal_green_raw - clap.signal_dark_raw;
   clap.signal_red = clap.signal_red_raw - clap.signal_dark_raw;

   % % I don't think these "mean"s are doing anything because we're parsing a single line
   % clean.blue(10) = mean(clap.signal_blue(10,rem(clap.spot,2)==0),2);
   % clean.green(10) = mean(clap.signal_green(10,rem(clap.spot,2)==0),2);
   % clean.red(10) = mean(clap.signal_red(10,rem(clap.spot,2)==0),2);
   % clean.blue(9) = mean(clap.signal_blue(9,rem(clap.spot,2)==1),2);
   % clean.green(9) = mean(clap.signal_green(9,rem(clap.spot,2)==1),2);
   % clean.red(9) = mean(clap.signal_red(9,rem(clap.spot,2)==1),2);
   %
   % for spot = 8:-1:1
   %    clean.blue(spot) = mean(clap.signal_blue(spot,clap.spot==spot),2);
   %    clean.green(spot) = mean(clap.signal_green(spot,clap.spot==spot),2);
   %    clean.red(spot) = mean(clap.signal_red(spot,clap.spot==spot),2);
   % end
   %
   % clean.Tr_blu_init([2,4,6,8]) = clean.blue([2,4,6,8])./clean.blue(10);
   % clean.Tr_blu_init([1,3,5,7]) = clean.blue([1,3,5,7])./clean.blue(9);
   % clean.Tr_grn_init([2,4,6,8]) = clean.green([2,4,6,8])./clean.green(10);
   % clean.Tr_grn_init([1,3,5,7]) = clean.green([1,3,5,7])./clean.green(9);
   % clean.Tr_red_init([2,4,6,8]) = clean.red([2,4,6,8])./clean.red(10);
   % clean.Tr_red_init([1,3,5,7]) = clean.red([1,3,5,7])./clean.red(9);
   % Tr_raw = NaN+[0,0,0];
   % if raw.spot>0
   %    Tr_raw = [clean.Tr_blu_init(raw.spot), ...
   %       clean.Tr_grn_init(raw.spot), ...
   %       clean.Tr_red_init(raw.spot)];
   % end
   xap = clap;
   % xap.spot = raw.spot;
   % xap.Tr_raw = Tr_raw';
   else
      xap = [];
   end
   return

function clap = tap_cast(raw,clap)
% This function applies "typecast" to generate single-precision floating
% point number from the TAP and CLAP raw streams.  It first attempts the
% computationally efficient block-conversion but on error will step through
% each line of raw input
clap.signal_dark_raw = NaN(10,length(clap.secs));
clap.signal_blue_raw = NaN(10,length(clap.secs));
clap.signal_green_raw = NaN(10,length(clap.secs));
clap.signal_red_raw =  NaN(10,length(clap.secs));

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