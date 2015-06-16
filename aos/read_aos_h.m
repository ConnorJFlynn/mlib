function [aos] = read_aos_h(filename);
%This reads h_eX.amf, the year-long collection of corrected AOS data from
%Anne Jefferson
if ~exist('filename', 'var')||~exist(filename,'file')
   filename = getfullname('*.*','noaa_aos','Select a NOAA AOS a_ file.');
end

fid = fopen(filename);
[pname, fname,ext] = fileparts(filename);
if fid>0
   aos.fname = [fname ext];
   format_str = ['%3s %f %f %4s '];                                        %4
   format_str = [format_str, '%f %f %f '];                                 %3
   format_str = [format_str, '%f %f %f %f %f %f '];                        %6
   format_str = [format_str, '%f %f %f %f %f %f '];                        %6
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];            %8
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];            %8
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];            %8
   label_str = {'Station';'Year';'StartTime_UTC';'flags';...
      'CN_contr';'CN_amb';'Bap_G';...
      'Bsp_B_Dry';'Bsp_G_Dry';'Bsp_R_Dry';'Bbsp_B_Dry';'Bbsp_G_Dry';'Bbsp_R_Dry'; ...
      'Bsp_B_Wet';'Bsp_G_Wet';'Bsp_R_Wet';'Bbsp_B_Wet';'Bbsp_G_Wet';'Bbsp_R_Wet'; ...
      'RH_Inlet';'T_Inlet';'RH_Inlet_Dry';'T_Inlet_Dry';'RH_Neph_Dry';'T_Neph_Dry';'RH_S1';'T_S1';...
      'RH_S2';'T_S2';'RH_Inlet_Wet';'T_Inlet_Wet';'RH_Neph_Wet';'T_Neph_Wet';'RH_Ambient';'T_Ambient';...
      'P_Ambient';'P_Neph_Dry';'P_Neph_Wet';'wind_spd';'wind_dir';'Bap_B_3W';'Bap_G_3W';'Bap_R_3W'};
   txt = textscan(fid,format_str,'headerlines',0,'delimiter',',');
   aos.station = char(txt{1}(1));
   aos.time = (datenum(txt{2}(:),1,1)+txt{3}(:)-1);
   aos.flags = uint32(hex2dec(txt{4}(:)));
   for ff = 5:length(label_str)
      label_str{ff} = fliplr(deblank(fliplr(deblank(label_str{ff}))));
      aos.(label_str{ff}) = txt{ff};
   end
   fclose(fid);
else
   aos = [];
end
% Now clean up the input, flag missings
fields = fieldnames(aos);
for f = 5:length(fields);
   tmp = fields{f};
   if strcmp(fields{f},'CN_amb')
      miss = (aos.(fields{f}) <= 0) |(aos.(fields{f}) >= 9e4);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'CN_contr')
      miss = (aos.(fields{f}) <= 0) |(aos.(fields{f}) >= 9e4);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:3),'Bap')
      miss = (aos.(fields{f}) >= 9e3)|(aos.(fields{f}) < 1);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:3),'Bsp')
      miss = (aos.(fields{f}) >= 9e3)|(aos.(fields{f}) < 0);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:4),'Bbsp')
      miss = (aos.(fields{f}) >= 9e3)|(aos.(fields{f}) < 0);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'RH_S1')
      miss = (aos.(fields{f}) <=2)|(aos.(fields{f}) >= 200);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:2),'RH')
      miss = (aos.(fields{f}) <=0)|(aos.(fields{f}) >= 200);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:2),'T_')
      miss = (aos.(fields{f}) <=12)|(aos.(fields{f}) >= 200);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f}(1:2),'P_')
      miss = (aos.(fields{f}) <=940)|(aos.(fields{f}) >= 9000);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'wind_spd')
      miss = (aos.(fields{f}) <=0)|(aos.(fields{f}) >= 90);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'wind_dir')
      miss = (aos.(fields{f}) <=0)|(aos.(fields{f}) >= 900);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'ccn_corr')
      miss = (aos.(fields{f}) <= 0) |(aos.(fields{f}) >= 9e4);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'cpc_corr')
      miss = (aos.(fields{f}) <= 0) |(aos.(fields{f}) >= 9e4);
      aos.(fields{f})(miss) = NaN;
   elseif strcmp(fields{f},'SS_pct')
      miss = (aos.(fields{f}) <=0.2);
      aos.(fields{f})(miss) = NaN;
   end
   sub = [2:(length(aos.time)-1)];
   NaNs = isNaN(aos.(fields{f}));
   NaNs(sub) =  NaNs(sub) | ( NaNs(sub-1)& NaNs(sub+1));
   aos.(fields{f})(NaNs) = NaN;
end
%    aos.RH_Inlet = aos.RH_Inlet_Dry;
%    aos.T_Inlet = aos.T_Inlet_Dry;
%    aos = rmfield(aos,'RH_Inlet_Dry');
%    aos = rmfield(aos,'T_Inlet_Dry');
% windowSize = 2;
%    submicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)))==1;
%    supmicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)==0))==1;
%    aos.cut_1um = submicron;
%    aos.cut_10um = supmicron;