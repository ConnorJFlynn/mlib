function [aos,fid] = read_aos_aH(filename);
%This should read NOAA a_ files.  Not fully tested...
if ~exist('filename', 'var')||~exist(filename,'file')
   filename = getfullname_('*.*','noaa_aos','Select a NOAA AOS a_ file.');
end

fid = fopen(filename);
[pname, fname,ext] = fileparts(filename);
if fid>0
   aos.fname = [fname ext];
   format_str = ['%3s %f %f %4s %f %f %f %f '];
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];
   format_str = [format_str, '%f %f %f %f %f %f %f %f %f %f '];
   label_str = {'Station';'Year';'StartTime_UTC';'Flags';...
      'CN_contr';'CN_amb_10um';'Bap_G_10um';'Bsp_B_10um';'Bsp_G_10um';'Bsp_R_10um';'Bbsp_B_10um';'Bbsp_G_10um';' Bbsp_R_10um';' Neph_RH';...
      'CN_Ambient_1um';'Bap_G_1um';'Bsp_B_1um';' Bsp_G_1um';' Bsp_R_1um';' Bbsp_B_1um';' Bbsp_G_1um';' Bbsp_R_1um';...
      'SD_CN_contr';'SD_CN_amb_10um';'SD_Bap_G_10um';'SD_Bsp_B_10um';' SD_Bsp_G_10um';' SD_Bsp_R_10um';' SD_Bbsp_B_10um';' SD_Bbsp_G_10um';' SD_Bbsp_R_10um';' SD_Neph_RH';...
      'SD_CN_amb_1um';'SD_Bap_G_1um';'SD_Bsp_B_1um';' SD_Bsp_G_1um';' SD_Bsp_R_1um';' SD_Bbsp_B_1um';' SD_Bbsp_G_1um';' SD_Bbsp_R_1um'; ...
      'N_CN_contr';'N_CN_amb_10um';'N_Bap_G_10um';'N_Bsp_B_10um';' N_Bsp_G_10um';' N_Bsp_R_10um';' N_Bbsp_B_10um';' N_Bbsp_G_10um';' N_Bbsp_R_10um';' N_Neph_RH';...
      'N_CN_amb_1um';'N_Bap_G_1um';'N_Bsp_B_1um';' N_Bsp_G_1um';' N_Bsp_R_1um';' N_Bbsp_B_1um';' N_Bbsp_G_1um';' N_Bbsp_R_1um'};

   txt = textscan(fid,format_str,'headerlines',0,'delimiter',',');
   aos.station = char(txt{1}(1));
   aos.time = (datenum(txt{2}(:),1,1)+txt{3}(:)-1);
   aod.hex_flags = txt{4};
   aos.flags = uint32(hex2dec(txt{4}(:)));
   for ff = 5:58
      label_str{ff} = fliplr(deblank(fliplr(deblank(label_str{ff}))));

      aos.(label_str{ff}) = txt{ff};
   end
   fclose(fid);
else
   aos = [];
end


