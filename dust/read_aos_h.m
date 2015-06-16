function [aos,fid] = read_aos_h(filename);
%This should read NOAA h_ files.  Not fully tested...
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
   fclose(fid);
   aos.station = char(txt{1}(1));
   aos.time = (datenum(txt{2}(:),1,1)+txt{3}(:)-1);
   aos.hex_flags = txt{4};
   aos.flags = uint32(hex2dec(txt{4}(:)));
   %These flags are broken.  Fix them using the raw flags...
   % Assuming that all the corrections have been applied, the only flag we
   % care about is the impactor / size cut.
   aos_flags = loadinto('aos_flags.mat');
   [AinB,BinA] = nearest(aos.time, aos_flags.time');
   aos.flags(AinB) = bitset(aos.flags(AinB),5,aos_flags.flags(BinA));
   for ff = 5:length(label_str)
      label_str{ff} = fliplr(deblank(fliplr(deblank(label_str{ff}))));
      aos.(label_str{ff}) = txt{ff};
   end
   aux = ancload(['C:\case_studies\dust\nimaosauxM1.a1\nimaux.cdf']);
   fc= find(diff(aux.vars.TrB.data)>0.01);
   aux.vars.TrB.data(fc) = NaN;
   aos.TrB = interp1(aux.time, aux.vars.TrB.data, aos.time,'nearest','extrap');
   fc= find(diff(aux.vars.TrG.data)>0.01);
   aux.vars.TrG.data(fc) = NaN;
   aos.TrG = interp1(aux.time, aux.vars.TrG.data, aos.time,'nearest','extrap');
   fc= find(diff(aux.vars.TrR.data)>0.01);
   aux.vars.TrR.data(fc) = NaN;
   aos.TrR = interp1(aux.time, aux.vars.TrR.data, aos.time,'nearest','extrap');
   
   ccn = loadinto('nim_ccn.mat');
   aos.SS_pct = interp1(ccn.time, ccn.SS_pct,aos.time, 'nearest','extrap');

   save(['C:\case_studies\dust\nimaosM1.noaa\nim_aos_all.mat'],'aos')
%    inds = interp1(ccn.time, [1:length(ccn.time)],aos_mon.time, 'nearest');
%    aos_mon.ccn_corr = ccn.ccn_corr(inds);
%    aos_mon.cpc_corr = ccn.cpc_corr(inds);
%    aos_mon.SS_pct = ccn.SS_pct(inds);
else
   aos = [];
end

