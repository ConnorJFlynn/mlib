function [tap, raw] = rd_xap_nohdr(infile);
% Reads "xap" (TAP or CLAP) datafiles that don't have a leading header.
if ~isavar('infile')
   infile = getfullname('*AP*.dat','xap_amice','Select XAP no-header file collected during AMICE 1.');
end
if isafile(infile)
   %   2024-07-24, 16:38:07, 03, 0402, 000000f5, 0043, 01, 0.000, 0.000000, 33.82, 37.15, c303403e, 49581a85, 488fd70f, 491d5c86, c343a6c6, 4913142e, 483f56f2, 48bcc99f, c2dfc3f6, 492f51c6, 48589f93, 48e215b3, c2ef47aa, 491dd2cc, 4847c64b, 48de5118, c367dde6, 491545fe, 483a3ba6, 48c1ea0d, c365ee80, 49159cc6, 4838dafb, 48c3d5a3, c38218e8, 4916ad07, 4849f8dd, 48c05c9f, c38311ee, 49125a56, 483c996e, 48b4efb5, c262cf2e, 48f286cb, 4815cf3e, 4894569d, c29dc28e, 4948bc71, 4888536b, 490b384c 

   fid = fopen(infile);
else
   disp('No valid file selected.')
   return
end
done = false;
while ~done
   this = fgetl(fid);
   first3 = textscan(this,'%s %s %d %*[^/n]','delimiter',',');
   yy = first3{1}; yy = yy{:}; HH = first3{2}; HH = HH{:};
   intime = datenum([yy,' ',HH], 'yyyy-mm-dd HH:MM:SS');
   in3 = first3{3};
   if feof(fid)||((in3==3)&&(intime<now&&intime>datenum(2024,07,01)))
      done = true;
   end
end
[raw.pname,raw.fname, ext] = fileparts(infile);
raw.pname = [raw.pname, filesep]; raw.fname = [raw.fname, ext];
%   2024-07-24, 16:38:07, 03, 0402, 000000f5, 0043, 01, 0.000, 0.000000, 33.82, 37.15, c303403e, 49581a85, 488fd70f, 491d5c86, c343a6c6, 4913142e, 483f56f2, 48bcc99f, c2dfc3f6, 492f51c6, 48589f93, 48e215b3, c2ef47aa, 491dd2cc, 4847c64b, 48de5118, c367dde6, 491545fe, 483a3ba6, 48c1ea0d, c365ee80, 49159cc6, 4838dafb, 48c3d5a3, c38218e8, 4916ad07, 4849f8dd, 48c05c9f, c38311ee, 49125a56, 483c996e, 48b4efb5, c262cf2e, 48f286cb, 4815cf3e, 4894569d, c29dc28e, 4948bc71, 4888536b, 490b384c 

%   2024-07-24, 16:38:07,
   fmt_str = '%s %s '; % Date, Time, 
   % 	03, 0402, 000000f5, 0043,
   fmt_str = [fmt_str, '%*s %x %x %f ']; %msg_type, flags, secs_hex, filt_id 2
   % 05, 1.019, 0.377724, 29.96, 29.99,
   fmt_str = [fmt_str, '%f %f %f %f %f ']; % spot_N, flow_lpm, sample_vol, T_case, T_sample 5
   %         c3336424, 4958008e, 48df56a0, 495a6466, c33127ee, 49415515, 48cfc476, 49457381,
   fmt_str = [fmt_str, '%x %x %x %x %x %x %x %x ']; %DRGB0, DRGB1 8
   %         c3260eba, 495562a5, 48dc8b52, 49566e7a, c32d1de3, 493fa8cb, 48ca1d3e, 4947cc52,
   fmt_str = [fmt_str, '%x %x %x %x %x %x %x %x ']; %DRGB2, DRGB3 8
   %         c2b03467, 491e0e32, 48a3e271, 4919b9f8, c2afb4d9, 493901ca, 48bfb287, 493f2b4e,
   fmt_str = [fmt_str, '%x %x %x %x %x %x %x %x ']; %DRGB4, DRGB5 8
   %         c34dacb3, 494167ec, 48d1f17d, 4949d6c1, c34e1e25, 49511b8d, 48d69d6a, 49508f75,
   fmt_str = [fmt_str, '%x %x %x %x %x %x %x %x ']; %DRGB6, DRGB7 8
   %         c36c1a80, 4944378e, 48d0b032, 494fdd63, c380221a, 494180e2, 48ce59e6, 4942d85f
   fmt_str = [fmt_str, '%x %x %x %x %x %x %x %x ']; %DRGB8, DRGB9 8

n = 0;
while ~feof(fid)
   A = textscan(this,fmt_str,'delimiter',',');
   if  ~isempty(A{end})
      n = n+1;
      raw.YYMMDD(n) = A{1};
      raw.HHMMSS(n) = A{2};
      raw.active_spot(n) = A{3};
      raw.reference_spot(n) = A{4};
      raw.LPF(n) = A{5}; raw.AvgTime(n) = A{6}; A(1:6) = [];
      raw.Ba_R_bmi(n) = A{1}; raw.Ba_G_bmi(n) = A{2};raw.Ba_B_bmi(n) = A{3};
      A(1:3) = [];
      raw.sample_flow(n) = A{1}; raw.heater_sp(n) = A{2};raw.T_sample(n) = A{3};
      A(1:3) = [];
      raw.T_case(n) = A{1}; raw.Ratio_R(n) = A{2}; raw.Ratio_G(n) = A{3}; raw.Ratio_B(n) = A{4};
      A(1:4) = [];
      raw.Sig_Dark(n) = A{1}; raw.Sig_R(n) = A{2}; raw.Sig_G(n) = A{3}; raw.Sig_B(n) = A{4};
      A(1:4) = [];
      raw.Ref_Dark(n) = A{1}; raw.Ref_R(n) = A{2}; raw.Ref_G(n) = A{3}; raw.Ref_B(n) = A{4};
      A(1:4) = [];
   else
      disp(['Skipping mal-formed row :',this])
   end
   this = fgetl(fid);
end
fclose(fid);
for N = n:-1:1
   dstr(N) =  {[raw.YYMMDD{N},' ',raw.HHMMSS{N}]} ;
end
raw.time = datenum(dstr);
secs = raw.time.*24.*60.*60; secs = secs - secs(1);
time_ii = [1:length(raw.time)];
diff_secs = diff(secs);
bad_times = [false; (diff_secs<.5) | (diff_secs>4) ]| isNaN(raw.time);
raw.time(bad_times) = interp1(time_ii(~bad_times), raw.time(~bad_times), time_ii(bad_times),'linear','extrap');

tap = proc_tap_bmi(raw,[],30);
save(strrep(infile,'.dat','.mat'),'-struct','tap');
[~,title_str] = fileparts(infile);
title(title_str,'interp','none')
saveas(gcf,strrep(infile,'.dat','.fig'))
return