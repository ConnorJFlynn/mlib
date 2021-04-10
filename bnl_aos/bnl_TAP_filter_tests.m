
function bnl_psap_filter_tests(ss)

if ~isavar('ss')
   ss = 60;
end
ss = 60;
dt = ss./(24*60*60);

ins = getfullname('*neph.*.00.*.raw.*','neph','select raw NEPH file');
if ~isempty(ins)
   indir = fileparts(ins{1}); ni = fliplr(indir); [~,ni] = strtok(ni,filesep);
   indir = fliplr(ni);
   [~,first] = fileparts(ins{1}); dots = findstr(first,'.'); first = first(dots(end-2):dots(end));
   first_str = datestr(datenum(first(2:end-1),'yyyymmdd.HHMMSS'),'yyyy-mm-dd HH:MM:SS');
   [~,last] = fileparts(ins{end});dots = findstr(last,'.'); last = last(dots(end-2):dots(end));
   last_str = datestr(datenum(last(2:end-1),'yyyymmdd.HHMMSS'),'yyyy-mm-dd HH:MM:SS');
   if strcmp(first_str(1:11),last_str(1:11))
      last_str(1:11) = [];
   end
   first = strrep(first,'.','_'); first = first(2:end);
   last = strrep(last,'.','_');last = last(1:end-1);
      [~,undir] = strtok(fliplr(indir),filesep); undir = fliplr(undir);
   pptdir = [undir, 'results',filesep];
   ppt_name = ['TAP_tests.',first,'to',last];
   imgdir = [pptdir,ppt_name,filesep];
   if isafile([pptdir, ppt_name,'.ppt'])
      ppt_mode = menu([ppt_name,'.ppt aleady exists:'] ,'Delete and replace','Keep old and new','Keep and append')      
      if ppt_mode==1
         delete([pptdir, ppt_name,'.ppt']);
         delete([imgdir,'*.png']);delete([imgdir,'*.fig']);
         rmdir(imgdir)
      elseif ppt_mode ==2
         ppt_name_ = [ppt_name,'_'];
         N = 1;
         while isafile([pptdir,ppt_name,'.ppt'])
            N = N+1;
            ppt_name = [ppt_name_,num2str(N)];
         end
         imgdir = [pptdir,ppt_name,filesep];
      end
   end
   ppt_add_title([pptdir, ppt_name,'.ppt'], ['PSAP tests: ', first_str,' to ',last_str]);
end
if ~isdir(imgdir)
   mkdir(imgdir);
end
%    ppt_add_slide(ppt_name, [imgdir,'image name']);
neph = rd_tsv_neph(ins);

% 'C:\case_studies\BNL_PSAP_filter_tests\from_salwen\dryneph\bnllabCPU1.dryneph.05s.00.20180725.000000.raw.tsv'
% 'C:\case_studies\BNL_PSAP_filter_tests\from_salwen\caps\bnllabCPU1.caps.01s.00.20180725.000000.raw.tsv'
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'caps',filesep]);
ins_ = strrep(ins_, '.dryneph.05s.','.caps.01s.');
ins_ = fix_file_timestamp(ins_);
caps = rd_bnl_tsv_caps(ins_);

figure_(555); pts = plot(caps.time, [caps.Extinction_Blue, caps.Extinction_Green, caps.Extinction_Red],'-x',...
   neph.time, 1e6.*[neph.Blue_T.*0.889, neph.Green_T.*0.869, neph.Red_T.*0.818],'o-');
set(pts(3),'color',[.8,0,0]);set(pts(2),'color',[0,.5,0]);set(pts(1),'color',[0,0,.75]);
set(pts(6),'color',[1,.3,.3]);set(pts(5),'color',[0,.9,0]);set(pts(4),'color',[0.25,0.25,1]);
legend('CAPS B', 'CAPS G','CAPS R','Neph B','Neph G','Neph R')
xlabel('time'); dynamicDateTicks; ylabel ('Ext [1/Mm]');
title('Extinction and Scattering, native resolution, raw');
logy
plot_name = 'CAPS_Neph_native';
saveas(gcf,[imgdir,plot_name,'.fig']);
% saveas(gcf,[imgdir,plot_name,'.png']);
% ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);

neph.Sca_B_amb = NaN(size(neph.time)); neph.Sca_G_amb = neph.Sca_B_amb; neph.Sca_R_amb = neph.Sca_B_amb;
good = neph.Modes==31; neph.good = good;
neph.Sca_B_amb(good) = 1e6.*smooth(neph.time(good),neph.Blue_T(good),12,'lowess').*0.889;
neph.Sca_G_amb(good) = 1e6.*smooth(neph.time(good),neph.Green_T(good),12,'lowess').*0.889;
neph.Sca_R_amb(good) = 1e6.*smooth(neph.time(good),neph.Red_T(good),12,'lowess').*0.889;
neph.dens_corr = (1013.25./neph.BaroPress) .* (neph.Inlettemp./273.15);
neph.Sca_B_stp_unc = neph.Sca_B_amb .* neph.dens_corr;
neph.Sca_G_stp_unc = neph.Sca_G_amb .* neph.dens_corr;
neph.Sca_R_stp_unc = neph.Sca_R_amb .* neph.dens_corr;
neph.wavelength_B = 450;
neph.wavelength_G = 550;
neph.wavelength_R = 700;
neph.SAE_BG = real(ang_exp(neph.Sca_B_amb, neph.Sca_G_amb, neph.wavelength_B, neph.wavelength_G));
neph.SAE_BR = real(ang_exp(neph.Sca_B_amb, neph.Sca_R_amb, neph.wavelength_B, neph.wavelength_R));
neph.SAE_GR = real(ang_exp(neph.Sca_G_amb, neph.Sca_R_amb, neph.wavelength_G, neph.wavelength_R));
neph.SAE_BG_sm = smooth(neph.SAE_BG,12);
neph.SAE_BR_sm = smooth(neph.SAE_BR,12);
neph.SAE_GR_sm = smooth(neph.SAE_GR,12);
neph.trunc_corr_B = 1.165 - 0.046 .* neph.SAE_BG_sm;
neph.trunc_corr_G = 1.152 - 0.044 .* neph.SAE_BR_sm;
neph.trunc_corr_R = 1.120 - 0.035 .* neph.SAE_GR_sm;
neph.Sca_B_stp = neph.Sca_B_stp_unc .* neph.trunc_corr_B;
neph.Sca_G_stp = neph.Sca_G_stp_unc .* neph.trunc_corr_G;
neph.Sca_R_stp = neph.Sca_R_stp_unc .* neph.trunc_corr_R;

caps.good_blue = floor(caps.Status_Blue./10000) == 1 & ...
   floor(rem(caps.Status_Blue,10000)./1000)==0 & ...
   floor(rem(caps.Status_Blue,10))==4;
caps.good_green = floor(caps.Status_Green./10000) == 1 & ...
   floor(rem(caps.Status_Green,10000)./1000)==0 & ...
   floor(rem(caps.Status_Green,10))==5;
caps.good_red = floor(caps.Status_Red./10000) == 1 & ...
   floor(rem(caps.Status_Red,10000)./1000)==0 & ...
   floor(rem(caps.Status_Red,10))==6;

caps.Ext_B_amb = NaN(size(caps.Extinction_Blue));
caps.Ext_G_amb = caps.Ext_B_amb; caps.Ext_R_amb = caps.Ext_B_amb;

caps.Ext_B_amb(caps.good_blue) = smooth(caps.time(caps.good_blue), caps.Extinction_Blue(caps.good_blue),60,'lowess');
caps.Ext_G_amb(caps.good_green) = smooth(caps.time(caps.good_green), caps.Extinction_Green(caps.good_green),60,'lowess');
caps.Ext_R_amb(caps.good_red) = smooth(caps.time(caps.good_red), caps.Extinction_Red(caps.good_red),60,'lowess');

caps.dens_corr_B = (760./caps.Pressure_Blue) .* (caps.Temperature_Blue./273.15);
caps.dens_corr_G = (760./caps.Pressure_Green) .* (caps.Temperature_Green./273.15);
caps.dens_corr_R = (760./caps.Pressure_Red) .* (caps.Temperature_Red./273.15);

caps.Ext_B_stp = caps.Ext_B_amb .* caps.dens_corr_B;
caps.Ext_G_stp = caps.Ext_G_amb .* caps.dens_corr_G;
caps.Ext_R_stp = caps.Ext_R_amb .* caps.dens_corr_R;

figure_(556);
pts = plot((neph.time), neph.Sca_B_stp, '-bo',...
   (caps.time), caps.Ext_B_stp,'bx',...
   (neph.time), neph.Sca_G_stp, '-go',...
   (caps.time), caps.Ext_G_stp, 'gx',...
   (caps.time), caps.Ext_R_stp, 'rx',...
   (neph.time),  neph.Sca_R_stp,'-ro');
set(pts(1),'color', [0.25,0.25,1]); set(pts(2),'color',[0,0,.75]); set(pts(3),'color', [0,.9,0]);
set(pts(4),'color', [0,.5,0]); set(pts(5),'color', [.8,0,0]); set(pts(6),'color', [1,.3,.3]);
% xlabel('time [UT]'); ylabel ('Ext [1/Mm]');
xlabel('time'); dynamicDateTicks; ylabel ('Ext [1/Mm]');
legend('Sca B 450', 'Ext B 450', 'Sca G 550', 'Ext G 532', 'Ext R 632', 'Sca R 700')
title('Scattering and Extinction, STP, 60 sec sliding window');zoom('on')
logy;
plot_name = 'CAPS_Neph_vs_time';
saveas(gcf,[imgdir,plot_name,'.fig']);
% saveas(gcf,[imgdir,plot_name,'.png']);
% ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);

figure_(555); raw_ax = gca;
figure_(556); avg_ax = gca;
linkaxes([raw_ax avg_ax],'xy');

done = false;
while ~done
   v = axis;
   don = menu({['Zoom and click OK to save']; ['Or click DONE']},'OK','DONE');
   if ~isavar('vv')||any(v~=axis)
      vv = axis;
      figure_(555);
      plot_name = 'CAPS_Neph_native';
      plot_name_ = [plot_name,'_'];
      N = 1;
      while isafile([imgdir,plot_name,'.png'])
         N = N+1;
         plot_name = [plot_name_,num2str(N)];
      end
      saveas(gcf,[imgdir,plot_name,'.png']);
      ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
      figure_(556);
      plot_name = 'CAPS_Neph_vs_time';
      plot_name_ = [plot_name,'_'];
      N = 1;
      while isafile([imgdir,plot_name,'.png'])
         N = N+1;
         plot_name = [plot_name_,num2str(N)];
      end
      saveas(gcf,[imgdir,plot_name,'.png']);
      ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
   end
   done = don>1;
end

% % caps B set(pts(1),'color',[0,0,.75]);
% % caps G set(pts(2),'color',[0,.5,0]);
% % caps R set(pts(3),'color',[.8,0,0]);
% neph R set(pts(6),'color',[1,.3,.3]);
% % neph G set(pts(5),'color',[0,.9,0]);
%% neph B set(pts(4),'color',[0.25,0.25,1]);

%    ppt_add_title([imgdir, ppt_name,'.ppt'], ['PSAP tests: ', first_str,' to ',last_str]);
% %    ppt_add_slide(ppt_name, [imgdir,'image name']);



caps.wavelength_R = 632;
caps.wavelength_G = 532;
caps.wavelength_B = 450;
caps.EAE_BG = caps.Ext_B_amb; caps.EAE_BR = caps.Ext_B_amb; caps.EAE_GR = caps.Ext_B_amb;
caps.EAE_BG_sm = caps.Ext_B_amb; caps.EAE_BR_sm = caps.Ext_B_amb; caps.EAE_GR_sm = caps.Ext_B_amb;


% figure_; plot(neph.time, [neph.SAE_BG, neph.SAE_BR, neph.SAE_GR], 'o',...
%    neph.time, [neph.SAE_BG_sm, neph.SAE_BR_sm, neph.SAE_GR_sm], '.'); dynamicDateTicks
caps.EAE_BG(caps.good_blue&caps.good_green) = real(ang_exp(...
   caps.Ext_B_amb(caps.good_blue&caps.good_green), caps.Ext_G_amb(caps.good_blue&caps.good_green),...
   caps.wavelength_B, caps.wavelength_G));
caps.EAE_BR(caps.good_blue&caps.good_red) = real(ang_exp(...
   caps.Ext_B_amb(caps.good_blue&caps.good_red), caps.Ext_R_amb(caps.good_blue&caps.good_red),...
   caps.wavelength_B, caps.wavelength_R));
caps.EAE_GR(caps.good_green&caps.good_red) = real(ang_exp(...
   caps.Ext_G_amb(caps.good_green&caps.good_red), caps.Ext_R_amb(caps.good_green&caps.good_red),...
   caps.wavelength_G, caps.wavelength_R));
caps.EAE_BG_sm(caps.good_blue&caps.good_green) = smooth(caps.EAE_BG(caps.good_blue&caps.good_green),60);
caps.EAE_BR_sm(caps.good_blue&caps.good_red) = smooth(caps.EAE_BR(caps.good_blue&caps.good_red),60);
caps.EAE_GR_sm(caps.good_green&caps.good_red) = smooth(caps.EAE_GR(caps.good_green&caps.good_red),60);
% figure_; plot(caps.time, [caps.EAE_BG, caps.EAE_BR, caps.EAE_GR], 'o',...
%    caps.time, [caps.EAE_BG_sm, caps.EAE_BR_sm, caps.EAE_GR_sm], '.'); dynamicDateTicks

done = false;
while ~done
   OK = menu('zoom into a time to average neph and caps. Hit OK to save, or DONE to skip.', 'OK', 'DONE');
   
   if OK==1
      xl = xlim;
      caps_xl_ = caps.time>xl(1) & caps.time<xl(2);
      neph_xl_ = neph.time>xl(1) & neph.time<xl(2);
      plot_name = 'CAPS_Neph_vs_time_zoom';
      plot_name_ = [plot_name,'_'];
      N = 1;
      while isafile([imgdir,plot_name,'.png'])
         N = N+1;
         plot_name = [plot_name_,num2str(N)];
      end
      saveas(gcf,[imgdir,plot_name,'.png']);
      ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
%       close(gcf);
      figure_(444); ll(1) = subplot(2,1,1); loglog([neph.wavelength_B, neph.wavelength_G,neph.wavelength_R],...
         [meannonan(neph.Sca_B_stp(neph_xl_)),meannonan(neph.Sca_G_stp(neph_xl_)), meannonan(neph.Sca_R_stp(neph_xl_))], '-o',...
         [caps.wavelength_B, caps.wavelength_G, caps.wavelength_R], ...
         [meannonan(caps.Ext_B_stp(caps_xl_)), NaN.*meannonan(caps.Ext_G_stp(caps_xl_)), meannonan(caps.Ext_R_stp(caps_xl_))],'x');
      
      ylabel('1/Mm')
      title('Wavelength vs Sigma (Sca or Ext)');
      legend('neph','caps');
      ll(2) = subplot(2,1,2); semilogx([gmean([neph.wavelength_B,neph.wavelength_G]),...
         gmean([neph.wavelength_B,neph.wavelength_R]), gmean([neph.wavelength_G,neph.wavelength_R])],...
         [meannonan(neph.SAE_BG_sm(neph_xl_)),meannonan(neph.SAE_BR_sm(neph_xl_)), meannonan(neph.SAE_GR_sm(neph_xl_))], '-o', ...
         [gmean([caps.wavelength_B,caps.wavelength_G]),...
         gmean([caps.wavelength_B,caps.wavelength_R]), gmean([caps.wavelength_G,caps.wavelength_R])],...
         [NaN.*meannonan(caps.EAE_BG_sm(caps_xl_)),meannonan(caps.EAE_BR_sm(caps_xl_)), NaN.*meannonan(caps.EAE_GR_sm(caps_xl_))], 'x');
      title([datestr(xl(1),'yyyy-mm-dd HH:MM'),datestr(xl(2),'-HH:MM')]);
      legend('neph SAE','caps EAE');
      ylabel('Angstrom Exponent')
      xlabel('wavelength [nm]');
      
      linkaxes(ll,'x');
      
      plot_name = 'CAPS_Neph_vs_WL';
      plot_name_ = [plot_name,'_'];
      N = 1;
      while isafile([imgdir,plot_name,'.png'])
         N = N+1;
         plot_name = [plot_name_,num2str(N)];
      end
      saveas(444,[imgdir,plot_name,'.fig']);
      saveas(444,[imgdir,plot_name,'.png']); 
      ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
   else
      done = true;
   end
end 




% DON'T USE THESE VALUES.  JAKE REPLACED THE LED BOARD IN TAP 14. NOW BOTH
% HAVE A DEEP BLUE CHANNEL.  USE THE MEASURED CENTERS.
% TAP015 Blue = 380 nm
% TAP014 Blue = 465 nm%
% tap.wavelength_B = 365;
% tap.wavelength_B = 467;
% tap.wavelength_G = 528;
% tap.wavelength_R = 652;

%TAP 14
tap.wavelength_B = 375;
tap.wavelength_G = 520.6;
tap.wavelength_R = 629.7;

%TAP 15
tap.wavelength_B = 379.3;
tap.wavelength_G = 518.5;
tap.wavelength_R = 629.6;

tap_spot_area = 30.721; %default for PALL E70 from Brechtel TAP data file
% Spot Area = 3.0721E-5 sq. m
% Use rd_tap_bmi_raw_nolf for data collected 2018-07-10 and before
% Use rd_tap_bmi_raw for data collected on or after 2018-07-11 10:37
% From Jake 2018-7-17: 
% TAP 14 with Azumi: 7.0mm ==> 38.5 mm^2.
% TAP 15 with Pall: 6.9mm ==> 37.4 mm^2.


tap_14 = rd_tap_bmi_raw(getfullname('RAW_TAP_SN14*.dat','tap_14','Select tap raw file.'));
close('all');
tap14 = proc_tap_me(tap_14);
tap14.wavelength_B = 375;
tap14.wavelength_G = 520.6;
tap14.wavelength_R = 629.7;
TAP14_flowcal = load('C:\case_studies\BNL_PSAP_filter_tests\TAP\TAP14_flowcal.mat');
tap14.flow_slpm = polyval(TAP14_flowcal.P1_top,tap14.flow_lpm);

figure(1);
plot_name = ['TAP 14 active spot'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(2);
plot_name = ['TAP 14 flow rate'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(4);
plot_name = ['TAP 14 red sigs'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(5);
plot_name = ['TAP 14 green_normed'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(6);
plot_name = ['TAP 14 green Tr spots'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(7);
plot_name = ['TAP 14 RGB Tr'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);

tap_15 = rd_tap_bmi_raw(getfullname('RAW_TAP_SN15*.dat','tap_15','Select tap raw file.'));
close('all')
tap15 = proc_tap_me(tap_15);
tap15.wavelength_B = 379.3;
tap15.wavelength_G = 518.5;
tap15.wavelength_R = 629.6;
TAP15_flowcal = load('C:\case_studies\BNL_PSAP_filter_tests\TAP\TAP15_flowcal.mat');
tap15.flow_slpm = polyval(TAP15_flowcal.P1_top,tap15.flow_lpm);
figure(1);
plot_name = ['TAP 15 active spot'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(2);
plot_name = ['TAP 15 flow rate'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(4);
plot_name = ['TAP 15 red sigs'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(5);
plot_name = ['TAP 15 green_normed'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(6);
plot_name = ['TAP 15 green Tr spots'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
figure(7);
plot_name = ['TAP 15 RGB Tr'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);

tap = tap14;

if length(tap.time)==length(tap14.time)
   tap_SN = 14; sn_str = 'TAP 14';
elseif length(tap.time)==length(tap15.time)
   tap_SN = 15; sn_str = 'TAP 15';
end


tic
tap.flow_smooth = sliding_polyfit(tap.time, tap.flow_slpm, dt);
toc
[tap.Ba_B_raw, tap.Tr_B_ss, tap.dV_ss, tap.dL_ss] = ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_blue,ss,tap_spot_area );
toc

[tap.Ba_G_raw, tap.Tr_G_ss] = ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_green,ss,tap_spot_area );
toc
[tap.Ba_R_raw, tap.Tr_R_ss] =   ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_red,ss,tap_spot_area );
toc

if length(tap.time)==length(tap14.time)
   tap14=tap;
elseif length(tap.time)==length(tap15.time)
   tap15 = tap;
end

figure; plot(tap.time, [tap.Ba_B_raw, tap.Ba_G_raw, tap.Ba_R_raw],'-'); dynamicDateTicks
legend('Ba_B','Ba_G','Ba_R')
title(sn_str);
plot_name = ['TAP 14 RGB Bab'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);


% figure; plot(tap.time, [tap.Tr_blue_ss, tap.Tr_green_ss],'.')
% legend('Tr blue ss','Tr green ss')
% title(sn_str);
% % [tap.Ba_B, tap.dV_ss, tap.dL_ss] = ...
% %    smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_blue,ss);
% % [tap.Ba_G] = smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_green,ss);
% % [tap.Ba_R] = smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_red,ss);
% menu({'Zoom into desired time range for Tr vs Tr plot.';'Select OK when done...'},'OK');
% tr_xl = xlim;
% tr_ = tap.time>tr_xl(1)&tap.time<tr_xl(2);
% figure; plot(tap.transmittance_blue(tr_), tap.transmittance_green(tr_), '.');
% legend('transmittance blue', 'transmittance green');
% title(sn_str);

tap = tap15;
if length(tap.time)==length(tap14.time)
   tap_SN = 14; sn_str = 'TAP 14';
elseif length(tap.time)==length(tap15.time)
   tap_SN = 15; sn_str = 'TAP 15';
end


tic
tap.flow_smooth = sliding_polyfit(tap.time, tap.flow_slpm, dt);
toc
[tap.Ba_B_raw, tap.Tr_B_ss, tap.dV_ss, tap.dL_ss] = ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_blue,ss,tap_spot_area );
toc

[tap.Ba_G_raw, tap.Tr_G_ss] = ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_green,ss,tap_spot_area );
toc
[tap.Ba_R_raw, tap.Tr_R_ss] =   ...
   smooth_Tr_i_Bab(tap.time, tap.flow_smooth, tap.transmittance_red,ss,tap_spot_area );
toc

if length(tap.time)==length(tap14.time)
   tap14=tap;
elseif length(tap.time)==length(tap15.time)
   tap15 = tap;
end

figure; plot(tap.time, [tap.Ba_B_raw, tap.Ba_G_raw, tap.Ba_R_raw],'-'); dynamicDateTicks
legend('Ba_B','Ba_G','Ba_R')
title(sn_str);
plot_name = ['TAP 15 RGB Bab'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);



% figure; plot(tap.time, [tap.Tr_blue_ss, tap.Tr_green_ss],'.')
% legend('Tr blue ss','Tr green ss')
% title(sn_str);
% [tap.Ba_B, tap.dV_ss, tap.dL_ss] = ...
%    smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_blue,ss);
% [tap.Ba_G] = smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_green,ss);
% [tap.Ba_R] = smooth_Bab(tap.time, tap.flow_smooth, tap.transmittance_red,ss);
% menu({'Zoom into desired time range for Tr vs Tr plot.';'Select OK when done...'},'OK');
% tr_xl = xlim;
% tr_ = tap.time>tr_xl(1)&tap.time<tr_xl(2);
% figure; plot(tap.transmittance_blue(tr_), tap.transmittance_green(tr_), '.');
% legend('transmittance blue', 'transmittance green');
% title(sn_str);
%At this point, we have CAPS, Neph, all PSAPs, all TAP

return

function ins_ = fix_file_timestamp(ins_)
for L = length(ins_):-1:1;
   [pname, fstem,x] = fileparts(ins_{L});
   G = textscan(fstem,'%s','delimiter','.'); G = G{1};
   time_str = ['.',G{6},'.'];
   time_str00 = time_str; time_str00(6:7) = '00';
   time_str01 = time_str; time_str01(6:7) = '01';
   time_str02 = time_str; time_str02(6:7) = '02';
   if ~isafile(ins_{L})
      if isafile(strrep(ins_{L},time_str,time_str00))
         ins_(L) = {strrep(ins_{L},time_str,time_str00)};
      elseif isafile(strrep(ins_{L},time_str,time_str01))
         ins_(L) = {strrep(ins_{L},time_str,time_str01)};
      elseif isafile(strrep(ins_{L},time_str,time_str02))
         ins_(L) = {strrep(ins_{L},time_str,time_str02)};
      else
         ins_(L) = [];
      end
   end
end

return