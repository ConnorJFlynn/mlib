function [tap, raw] = rd_tap_bmi(infile);

if ~exist('infile','var')
   infile = getfullname('TAP_*.csv','tap_bmi','Select tap BMI data file.');
end
if exist(infile,'file')
   %   Detailed explanation goes here
   fid = fopen(infile);
else
   disp('No valid file selected.')
   return
end
done = false;
while ~done
   this = fgetl(fid);
   
   if feof(fid)||(~isempty(strfind(this,'Date'))&&~isempty(strfind(this,'LPF')))
      done = true;
   end
end
[raw.pname,raw.fname, ext] = fileparts(infile);
raw.pname = [raw.pname, filesep]; raw.fname = [raw.fname, ext];

% Date(yymmdd)	Time(24hr)	Active Spot	Ref Spot	LPF	AvgTime	Red Abs Coef	Green Abs Coef	Blue Abs Coef	Sample Flow(L/min)	Heater Set Point	Sample Air Temp(C)	Case Temp(C)	Red Ratio	Green Ratio	Blue Ratio	Dark	Red	Green	Blue	Dark Ref	Red Ref	Green Ref	Blue Ref
%180221	10:47:18	1	1	0	1	12.968828	21.268709	22.783773	2.037000	35.100000	34.820000	34.920000	0.962117	1.001941	1.000484	-153.249756	758250.562256	539300.312256	555738.874756	-142.361053	788106.361053	538255.486053	555470.173553

% Date ,time,Active Spot,Ref Spot,LPF,AvgTime,Red Abs Coef,Green Abs Coef,Blue Abs Coef,Sample Flow(L/min),Heater Set Point,Sample Air Temp (C),Case Temp (C),Red Ratio,Green Ratio,Blue Ratio,Dark,Red,Green,Blue,Dark Ref,Red Ref,Green Ref,Blue Ref
% 8/2/2022,6:35:17,1,1,1,60,2.307285,2.878729,4.041642,1.76,40,40,40,0.809463,0.805173,0.749166,-45.044975,639901.517,637587.2422,99115.09144,-108.774038,790656.3706,792023.2023,132335.8297


fmt_str = '%s %s '; % Date(yymmdd)	Time(24hr)
% 	180221	10:47:18
fmt_str = [fmt_str, '%d %d %d %d ']; %Active Spot	Ref Spot	LPF	AvgTime
% 1	1	0	1
fmt_str = [fmt_str, '%f %f %f ']; % Red Abs Coef	Green Abs Coef	Blue Abs Coef
% 12.968828	21.268709	22.783773
fmt_str = [fmt_str, '%f %f %f %f ']; %Sample Flow(L/min)	Heater Set Point	Sample Air Temp(C)	Case Temp(C)
% 2.037000	35.100000	34.820000	34.920000
fmt_str = [fmt_str, '%f %f %f ']; %Red Ratio	Green Ratio	Blue Ratio
% 0.962117	1.001941	1.000484
fmt_str = [fmt_str, '%f %f %f %f ']; %Dark	Red	Green	Blue
% -153.249756	758250.562256	539300.312256	555738.874756
fmt_str = [fmt_str, '%f %f %f %f ']; %Dark Ref	Red Ref	Green Ref	Blue Ref
% -142.361053	788106.361053	538255.486053	555470.173553

this = fgetl(fid);
n = 0;
while ~feof(fid)
   A = textscan(this,fmt_str);
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
   dstr(N) =  {['20',raw.YYMMDD{N},' ',raw.HHMMSS{N}]} ;
end
raw.time = datenum(dstr,'yyyymmdd HH:MM:SS');
secs = raw.time.*24.*60.*60;secs = secs - secs(1);
time_ii = [1:length(raw.time)];
diff_secs = diff(secs);
bad_times = [false; (diff_secs<.5) | ((diff_secs>1.5)&(diff_secs<3))]|isNaN(raw.time);
raw.time(bad_times) = interp1(time_ii(~bad_times), raw.time(~bad_times), time_ii(bad_times),'linear','extrap');

tap = proc_tap_bmi(raw,[],30);
save(strrep(infile,'.dat','.mat'),'-struct','tap');
[~,title_str] = fileparts(infile);
title(title_str,'interp','none')
saveas(gcf,strrep(infile,'.dat','.fig'))
return