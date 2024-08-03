
function bnl_psap_filter_tests_3(ss)
% Reorganizing. Read PSAPs first, then TAPs (manually?) ,then Neph & CAPS
% Then compute various propeperties for PSAPs and TAPs
% Then save mat file and csv files for each PSAP & TAP (which includes Bs,
% Bx converted to those wavelengths)
% Then produce 3 plots, one for each color, for PSAP + TAP, for Tr, Ba,
% And another plot, one per system (so 6 PSAP + 2 TAP) with RGB of same
% props above.
% Then as above for the various AAE pairs.
% v1: did not handle bad CAPS G period
% v2: compute extinction only from good caps WL, depending on date/time
% v3: catch case where there are not good CAPS valu
% v4: interpolate from CAPS R if G is not good instead of from B.  
% v4: apply fixed time grid to output ASCII file.
if ~isavar('ss')
   ss = 60;
end
ss = 60;
dt = ss./(24*60*60);
ver = 4;
% PSAP SN 046
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-046
% ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM1-046',filesep]);
%bnllabVM1.046psap3wI.01s.00.20180711.030000.raw
ins = getfullname('bnllabVM1.046psap3wI.01s.00.*.raw.tsv','psap046','select raw PSAP file');
ins_ = ins;
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 046 files...',num2str(length(ins))])
psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.755; spot_area = pi.*(spot_diam./2).^2;
Kn = [921,744,24];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
psap.wavelength_B = 462;
psap.wavelength_G = 529;
psap.wavelength_R = 648;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
psap_046 = psap;

% PSAP SN 077
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-077
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabVM1.077psap3wI.01s.00.20180711.030000.raw.tsv
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'psap3wI_VM1-077',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046','bnllabVM1.077');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 077 files...',num2str(length(ins))])
psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.724; spot_area = pi.*(spot_diam./2).^2;
Kn = [1035,767,22];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
psap.wavelength_B = 463;
psap.wavelength_G = 525;
psap.wavelength_R = 647;
psap_077 = psap;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
%
%
% % PSAP SN 090
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM2-090
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-077
% % bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% % bnllabVM2.090psap3w.01s.00.20180711.060000.raw.tsv
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'psap3wI_VM2-090',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046','bnllabVM2.090');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 090 files...',num2str(length(ins))])
psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.724; spot_area = pi.*(spot_diam./2).^2;
Kn = [771,794,12];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
psap.wavelength_B = 463;
psap.wavelength_G = 530;
psap.wavelength_R = 645;
psap_090 = psap;
%
% % PSAP SN 092
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM2-092
% % bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% % bnllabVM2.092psap3wI.01s.00.20180711.060000.raw
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'psap3wI_VM2-092',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046','bnllabVM2.092');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 092 files...',num2str(length(ins))])
psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.724; spot_area = pi.*(spot_diam./2).^2;
Kn = [1064,738,31];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
psap.wavelength_B = 462;
psap.wavelength_G = 529;
psap.wavelength_R = 646;
psap_092 = psap;
%
% % PSAP SN 107
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_CPU2-107
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-077
% % bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabCPU2.107psap3wI.01s.00.20180711.000000.raw.tsv
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'psap3wI_CPU2-107',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046','bnllabCPU2.107');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 107 files...',num2str(length(ins))])
psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.76; spot_area = pi.*(spot_diam./2).^2;
Kn = [989,736,23];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
psap.wavelength_B = 466;
psap.wavelength_G = 529;
psap.wavelength_R = 647;
psap_107 = psap;

%
% % PSAP SN 110
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_CPU2-110
% % C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-077
% % bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% % bnllabCPU2.110psap3wI.01s.00.20180711.040000.raw.tsv
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'psap3wI_CPU2-110',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046','bnllabCPU2.110');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading PSAP SN 110 files...',num2str(length(ins))])

psap = read_psap_ir(ins_);
toc
flow_AD = psap.flow_AD;
spot_diam = 4.801; spot_area = pi.*(spot_diam./2).^2;
Kn = [984,751,27];
ko = Kn(1); k1 = Kn(2); k2 = Kn(3);
flow_SLPM = (-k1 + sqrt(k1.^2 -4.*(ko-flow_AD).*k2))./(2.*k2);
psap.spot_diam = spot_diam; psap.spot_area = spot_area;
psap.Kn = Kn; psap.flow_SLPM = flow_SLPM;
save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
psap.wavelength_B = 462;
psap.wavelength_G = 528;
psap.wavelength_R = 647;
psap_110 = psap;
%

% bnllabCPU1.dryneph.05s.00.20180801.170000.raw.tsv
% bnllabVM1.046psap3wI.01s.00.20180711.010000.raw.tsv
ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'dryneph',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046psap3wI.01s.','bnllabCPU1.dryneph.05s.');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading neph files...',num2str(length(ins))])
neph = rd_tsv_neph(ins_);
neph.wavelength_B = 450;
neph.wavelength_G = 550;
neph.wavelength_R = 700;
toc


ins_ = strrep(ins,[filesep,'psap3wI_VM1-046',filesep],[filesep,'caps',filesep]);
ins_ = strrep(ins_, 'bnllabVM1.046psap3wI.01s.','bnllabCPU1.caps.01s.');
ins_ = fix_file_timestamp(ins_);
tic; disp(['Reading CAPS files...',num2str(length(ins))])
caps = rd_bnl_tsv_caps(ins_);
caps.wavelength_R = 632;
caps.wavelength_G = 532;
caps.wavelength_B = 450;
toc
% ins = getfullname('*neph.*.00.*.raw.*','neph','select raw NEPH file');
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
   
   [~,undir] = strtok(fliplr(indir),filesep);
   [~,undir] = strtok(undir,filesep);
   undir = fliplr(undir);
   pptdir = [undir, 'results',filesep];
   ppt_name = ['PSAP_tests.',first,'to',last];
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
% tap_spot_area = 30.721; %default for PALL E70 from Brechtel TAP data file
% % Spot Area = 3.0721E-5 sq. m
% % Use rd_tap_bmi_raw_nolf for data collected 2018-07-10 and before
% % Use rd_tap_bmi_raw for data collected on or after 2018-07-11 10:37
% % From Jake 2018-7-17: TAP 14 with Azumi: 7.0mm ==> 38.5 mm^2.
% % TAP 15 with Pall: 6.9mm ==> 37.4 mm^0
% % Now get list of TAPs files spanning First and Last
tap_ = rd_tap_bmi_raw(getfullname('RAW_TAP_SN14*.dat','tap_14',['Select files spanning: ',first_str,' to ',last_str]));
tap_.time = tap_.time + 4/24;
tap = proc_tap_me(tap_);tap.fname = tap_.fname; tap.pname = tap_.pname;close('all')
tap.wavelength_B = 375;
tap.wavelength_G = 520.6;
tap.wavelength_R = 629.7;
TAP14_flowcal = load('C:\case_studies\BNL_PSAP_filter_tests\TAP\TAP14_flowcal.mat');
tap.flow_SLPM = polyval(TAP14_flowcal.P1_top,tap.flow_lpm);
% From Jake 2018-7-17: TAP 14 with Azumi: 7.0mm ==> 38.5 mm^2.
tap.spot_area = 38.5;
tap14 = tap_; tap_14 = tap;

tap_ = rd_tap_bmi_raw(getfullname('RAW_TAP_SN15*.dat','tap_15',['Select files spanning: ',first_str,' to ',last_str]));
tap_.time = tap_.time + 4/24;
tap = proc_tap_me(tap_);tap.fname = tap_.fname; tap.pname = tap_.pname;close('all')
TAP15_flowcal = load('C:\case_studies\BNL_PSAP_filter_tests\TAP\TAP15_flowcal.mat');
tap.flow_SLPM = polyval(TAP15_flowcal.P1_top,tap.flow_lpm);
tap.wavelength_B = 379.3;
tap.wavelength_G = 518.5;
tap.wavelength_R = 629.6;
% TAP 15 with Pall: 6.9mm ==> 37.4 mm^0
tap.spot_area = 37.4;
tap15 = tap_; tap_15 = tap;

SN =          {'psap_046','psap_077','psap_090','psap_092','psap_107','psap_110', 'tap_14','tap_15'};
% SN =          {'psap_046','psap_077'};
filter_type = {'Azu','E70','EMF','SAV','Wha','E70'};
legs = {'046 Azumi', '077 E70', '090 Emfab', '092 Savil', '107 Whatman','110 E70'};
legs = SN;

figure_(555); pts = plot(caps.time, [caps.Extinction_Blue, caps.Extinction_Green, caps.Extinction_Red],'-',...
   neph.time, 1e6.*[neph.Blue_T.*0.889, neph.Green_T.*0.869, neph.Red_T.*0.818],'-');
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
neph.Sca_B_amb(good) = 1e6.*smooth(neph.Blue_T(good),12).*0.889;
neph.Sca_G_amb(good) = 1e6.*smooth(neph.Green_T(good),12).*0.889;
neph.Sca_R_amb(good) = 1e6.*smooth(neph.Red_T(good),12).*0.889;
neph.dens_corr = (1013.25./neph.BaroPress) .* (neph.Inlettemp./273.15);
neph.Sca_B_stp_unc = neph.Sca_B_amb .* neph.dens_corr;
neph.Sca_G_stp_unc = neph.Sca_G_amb .* neph.dens_corr;
neph.Sca_R_stp_unc = neph.Sca_R_amb .* neph.dens_corr;
neph.SAE_BG = real(ang_exp(neph.Sca_B_amb, neph.Sca_G_amb, neph.wavelength_B, neph.wavelength_G));
neph.SAE_BR = real(ang_exp(neph.Sca_B_amb, neph.Sca_R_amb, neph.wavelength_B, neph.wavelength_R));
neph.SAE_GR = real(ang_exp(neph.Sca_G_amb, neph.Sca_R_amb, neph.wavelength_G, neph.wavelength_R));
non = NaN(size(neph.SAE_BG));neph.SAE_BG_sm = non; neph.SAE_BR_sm = non; neph.SAE_GR_sm = non;
non = ~isnan(neph.SAE_BG); neph.SAE_BG_sm(non) = smooth(neph.SAE_BG(non),12);
non = ~isnan(neph.SAE_BR); neph.SAE_BR_sm(non) = smooth(neph.SAE_BR(non),12);
non = ~isnan(neph.SAE_GR); neph.SAE_GR_sm(non) = smooth(neph.SAE_GR(non),12);
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
caps.Ext_B_amb(caps.good_blue) = smooth(caps.Extinction_Blue(caps.good_blue),60);
caps.Ext_G_amb(caps.good_green) = smooth(caps.Extinction_Green(caps.good_green),60);
caps.Ext_R_amb(caps.good_red) = smooth( caps.Extinction_Red(caps.good_red),60);

caps.dens_corr_B = (760./caps.Pressure_Blue) .* (caps.Temperature_Blue./273.15);
caps.dens_corr_G = (760./caps.Pressure_Green) .* (caps.Temperature_Green./273.15);
caps.dens_corr_R = (760./caps.Pressure_Red) .* (caps.Temperature_Red./273.15);

caps.Ext_B_stp = caps.Ext_B_amb .* caps.dens_corr_B;
caps.Ext_G_stp = caps.Ext_G_amb .* caps.dens_corr_G;
caps.Ext_R_stp = caps.Ext_R_amb .* caps.dens_corr_R;

figure_(556);
pts = plot((neph.time), neph.Sca_B_stp, '-',...
   (caps.time), caps.Ext_B_stp,'-',...
   (neph.time), neph.Sca_G_stp, '-',...
   (caps.time), caps.Ext_G_stp, '-',...
   (caps.time), caps.Ext_R_stp, '-',...
   (neph.time),  neph.Sca_R_stp,'-');
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
% % neph R set(pts(6),'color',[1,.3,.3]);
% % neph G set(pts(5),'color',[0,.9,0]);
% % neph B set(pts(4),'color',[0.25,0.25,1]);

%    ppt_add_title([imgdir, ppt_name,'.ppt'], ['PSAP tests: ', first_str,' to ',last_str]);
% %    ppt_add_slide(ppt_name, [imgdir,'image name']);

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
figure_(444); close(444);
% close(gcf);
% Next set of files...
% SN = {'077'};
% SN = {'077','090','107','110'};
% One figure for each nominal color, blue green red
blue = 333; green = blue + 1; red = green +1;
figure_(blue);figure_(green);figure_(red);
close(blue); close(green); close(335);
figure_(blue);figure_(green);figure_(red);

for sn = 1:length(SN)
   psap = eval(SN{sn});
   figure_(blue);
   plot(psap.time, psap.transmittance_blue, '-'); hold('on');
   figure_(green);
   plot(psap.time,psap.transmittance_green,'-'); hold('on');
   figure_(red);
   plot(psap.time,psap.transmittance_red,'-'); hold('on');
end
figure_(blue); ax3(1) = gca; lg = legend(legs);set(lg,'interp','none')
xlabel('time'); ylabel('Tr');; title('Transmittance blue');
dynamicDateTicks;
figure_(green);ax3(2) = gca;lg = legend(legs);set(lg,'interp','none')
xlabel('time'); ylabel('Tr');; title('Transmittance green');
dynamicDateTicks;
figure_(red);ax3(3) = gca; lg = legend(legs);set(lg,'interp','none')
xlabel('time'); ylabel('Tr');; title('Transmittance red');
dynamicDateTicks;
linkaxes(ax3,'xy');

%one figure for each PSAP and TAP
figure_(441);figure_(442);figure_(443);
figure_(444);figure_(445);figure_(446);
figure_(447);figure_(448); % TAP
close(441);close(442);close(443);
close(444);close(445);close(446);
close(447);close(448); % TAP
figure_(441);figure_(442);figure_(443);
figure_(444);figure_(445);figure_(446);
figure_(447);figure_(448); % TAP

for sn = 1:length(SN)
   psap = eval(SN{sn});
   figure_(440+sn);
   plot(psap.time, psap.transmittance_blue, 'b-',...
      psap.time, psap.transmittance_green, 'g-',...
      psap.time, psap.transmittance_red, 'r-');
   xlabel('time'); ylabel('Tr'); title(legs{sn});
   legend('Tr blue','Tr green','Tr red');
   tl = title([SN{sn}, ' transmittance']);set(tl,'interp','none');
   dynamicDateTicks;
   ax6(sn) = gca;
end
linkaxes(ax6,'xy');
% close('all');
mint = []; maxt = [];
for sn = 1:length(SN)
   NNN = SN{sn};
   psap = eval(NNN);
   title_str = [NNN];
   psap.flow_smooth = psap.flow_SLPM;
   non = NaN(size(psap.time)); psap.flow_smooth = non;
   non = isnan(psap.flow_SLPM);
   tic;
   psap.flow_smooth(~non) = smooth(psap.flow_SLPM(~non), ss);toc
   tic
   [psap.Ba_B_raw, psap.Tr_B_ss, psap.dV_ss, psap.dL_ss] = ...
      smooth_Tr_i_Bab(psap.time, psap.flow_smooth, psap.transmittance_blue,ss,psap.spot_area);
   [psap.Ba_B_std,~, avg, mid] = stdwin(psap.Ba_B_raw,30);
   psap.Ba_B_rstd = mid./avg;
   [psap.Ba_G_raw, psap.Tr_G_ss] = smooth_Tr_i_Bab(psap.time, psap.flow_smooth, psap.transmittance_green,ss);
   [psap.Ba_R_raw, psap.Tr_R_ss] = smooth_Tr_i_Bab(psap.time, psap.flow_smooth, psap.transmittance_red,ss);
   
   psap.Weiss_f_B = WeissBondOgren(psap.Tr_B_ss);
   psap.Ba_B_Weiss = psap.Ba_B_raw .* psap.Weiss_f_B;
   Bs = ang_coef(neph.Sca_B_stp_unc, neph.SAE_BG_sm, neph.wavelength_B, psap.wavelength_B);
   psap.Bs_B_unc = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   psap.Ba_B_Bond = psap.Ba_B_Weiss - (0.02./1.22).*psap.Bs_B_unc;
   Bs = ang_coef(neph.Sca_B_stp, neph.SAE_BG_sm, neph.wavelength_B, psap.wavelength_B);
   psap.Bs_B = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   pump_fail = datenum(2018,07,26,18,0,0);
   caps_G_good = caps.time<pump_fail;Bx = NaN(size(caps.time));
   Bx(caps_G_good) = ang_coef(caps.Ext_B_stp(caps_G_good), caps.EAE_BG_sm(caps_G_good),...
      caps.wavelength_B, psap.wavelength_B);
   % When G is bad, then extrapolating from R is just as good as from B since two points define a line
   % But extrapolate from R since it has less noise than B.  
   Bx(~caps_G_good) = ang_coef(caps.Ext_R_stp(~caps_G_good), caps.EAE_BR_sm(~caps_G_good),...
      caps.wavelength_R, psap.wavelength_B);
   if any(caps.good_blue)
      psap.Bx_B = interp1(caps.time(caps.good_blue), Bx(caps.good_blue), psap.time, 'pchip');
   else
      psap.Bx_B = NaN.*psap.time;
   end
   psap.Ba_B_Virk_Sca = compute_Virkkula(psap.Tr_B_ss, psap.Bs_B, psap.Ba_B_raw, 4);
   psap.Ba_B_Virk_Ext = compute_Virkkula_ext(psap.Tr_B_ss, psap.Bx_B, psap.Ba_B_raw, 4);
   
   psap.Weiss_f_G = WeissBondOgren(psap.Tr_G_ss);
   psap.Ba_G_Weiss = psap.Ba_G_raw .* psap.Weiss_f_G;
   Bs = ang_coef(neph.Sca_B_stp_unc, neph.SAE_BR_sm, neph.wavelength_G, psap.wavelength_G);
   psap.Bs_G_unc = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   psap.Ba_G_Bond = psap.Ba_G_Weiss - (0.02./1.22).*psap.Bs_G_unc;
   Bs = ang_coef(neph.Sca_G_stp, neph.SAE_BR_sm, neph.wavelength_G, psap.wavelength_G);
   psap.Bs_G = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   Bx = NaN(size(caps.time));
   Bx(caps_G_good) = ang_coef(caps.Ext_G_stp(caps_G_good), caps.EAE_BG_sm(caps_G_good),...
      caps.wavelength_G, psap.wavelength_G);
   % When G is bad, then extrapolating from R is just as good as from B since two points define a line
   % But extrapolate from R since it has less noise than B.  
   Bx(~caps_G_good) = ang_coef(caps.Ext_R_stp(~caps_G_good), caps.EAE_BR_sm(~caps_G_good),...
      caps.wavelength_R, psap.wavelength_G);
   if any(caps.good_green)
      psap.Bx_G = interp1(caps.time(caps.good_green), Bx(caps.good_green), psap.time, 'pchip');
   else
      psap.Bx_G = NaN.*psap.time;
   end
   psap.Ba_G_Virk_Sca = compute_Virkkula(psap.Tr_G_ss, psap.Bs_G, psap.Ba_G_raw, 4);
   psap.Ba_G_Virk_Ext = compute_Virkkula_ext(psap.Tr_G_ss, psap.Bx_G, psap.Ba_G_raw, 4);
   
   psap.Weiss_f_R = WeissBondOgren(psap.Tr_R_ss);
   psap.Ba_R_Weiss = psap.Ba_R_raw .* psap.Weiss_f_R;
   Bs = ang_coef(neph.Sca_R_stp_unc, neph.SAE_GR_sm, neph.wavelength_R, psap.wavelength_R);
   psap.Bs_R_unc = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   psap.Ba_R_Bond = psap.Ba_R_Weiss - (0.02./1.22).*psap.Bs_R_unc;
   Bs = ang_coef(neph.Sca_R_stp, neph.SAE_GR_sm, neph.wavelength_R, psap.wavelength_R);
   psap.Bs_R = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   Bx = NaN(size(caps.time));
   Bx(caps_G_good) = ang_coef(caps.Ext_R_stp(caps_G_good), caps.EAE_GR_sm(caps_G_good),...
      caps.wavelength_R, psap.wavelength_R);
   % When G is bad, then extrapolating from R is just as good as from B since two points define a line
   % But extrapolate from R since it has less noise than B.
   Bx(~caps_G_good) = ang_coef(caps.Ext_R_stp(~caps_G_good), caps.EAE_BR_sm(~caps_G_good),...
      caps.wavelength_R, psap.wavelength_R);
   if any(caps.good_red)
      psap.Bx_R = interp1(caps.time(caps.good_red), Bx(caps.good_red), psap.time, 'pchip');
   else
      psap.Bx_R = NaN.*psap.time;
   end
   psap.Ba_R_Virk_Sca = compute_Virkkula(psap.Tr_R_ss, psap.Bs_R, psap.Ba_R_raw, 4);
   psap.Ba_R_Virk_Ext = compute_Virkkula_ext(psap.Tr_R_ss, psap.Bx_R, psap.Ba_R_raw, 4);
   
   psap.AAE_BG_raw = ang_exp(psap.Ba_B_raw,psap.Ba_G_raw,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Weiss = ang_exp(psap.Ba_B_Weiss,psap.Ba_G_Weiss,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Bond = ang_exp(psap.Ba_B_Bond,psap.Ba_G_Bond,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Virk_Sca = ang_exp(psap.Ba_B_Virk_Sca,psap.Ba_G_Virk_Sca,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Virk_Ext = ang_exp(psap.Ba_B_Virk_Ext,psap.Ba_G_Virk_Ext,psap.wavelength_B, psap.wavelength_G);
   
   psap.AAE_BR_raw = ang_exp(psap.Ba_B_raw,psap.Ba_R_raw,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Weiss    = ang_exp(psap.Ba_B_Weiss,psap.Ba_R_Weiss,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Bond     = ang_exp(psap.Ba_B_Bond,psap.Ba_R_Bond,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Virk_Sca = ang_exp(psap.Ba_B_Virk_Sca,psap.Ba_R_Virk_Sca,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Virk_Ext = ang_exp(psap.Ba_B_Virk_Ext,psap.Ba_R_Virk_Ext,psap.wavelength_B, psap.wavelength_R);
   
   psap.AAE_GR_raw = ang_exp(psap.Ba_G_raw,psap.Ba_R_raw,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Weiss    = ang_exp(psap.Ba_G_Weiss,psap.Ba_R_Weiss,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Bond     = ang_exp(psap.Ba_G_Bond,psap.Ba_R_Bond,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Virk_Sca = ang_exp(psap.Ba_G_Virk_Sca,psap.Ba_R_Virk_Sca,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Virk_Ext = ang_exp(psap.Ba_G_Virk_Ext,psap.Ba_R_Virk_Ext,psap.wavelength_G, psap.wavelength_R);
   
   eval([NNN,' = psap;']);
   outdir = getnamedpath('filter_study_out');
   tic
   disp(['Saving ',psap.fname{1},'.mat']);
   save([outdir,psap.fname{1},'.mat'],'-struct','psap');
   toc
end

SN =          {'psap_046','psap_077','psap_090','psap_092','psap_107','psap_110', 'tap_14','tap_15'};
mint = []; maxt = [];
for sn = 1:length(SN)
   NNN = SN{sn};
   psap = eval(NNN);
   mint = min([mint, psap.time(1)]);
   maxt = max([maxt, psap.time(end)]);
end
mint = max([mint,datenum('2018-07-23 16:31','yyyy-mm-dd HH:MM')]);datestr(mint)
maxt = min([maxt, datenum('2018-08-06 13:51','yyyy-mm-dd HH:MM')]); datestr(maxt)
 out_time = [mint:(1/(24*60*60)) : maxt]';
 outdir = getnamedpath('filter_study_out');
for sn = 2:length(SN)
   NNN = SN{sn};
   psap = eval(NNN);
   title_str = [NNN];
   clear out;   
   pino = interp1(out_time, [1:length(out_time)],psap.time, 'nearest','extrap');
   [pin, ij] = unique(pino);
   fields = fieldnames(psap);
   ts = size(psap.time);
   for fld = 1:length(fields)
      field = fields{fld};
      if all(size(psap.(field))==ts)
         bloop = NaN.*out_time;
         out.(field) = bloop;
         bloop(pino) = psap.(field);
         out.(field)(pin) = bloop(ij);
      else
         out.(field) = psap.(field);
      end
   end
   out.time = out_time;
   disp(['Writing ',NNN])
      file_out = ['filter_test.',NNN,'.from_',datestr(out.time(1),'yyyymmdd_HHMM')...
      ,'-',datestr(out.time(end),'yyyymmdd_HHMM'),'.v',num2str(ver),'.csv'];
   tic
   write_out_csv(out, file_out);
   toc
end


return

function ins_ = fix_file_timestamp(ins_)
for L = length(ins_):-1:1;
   [pname, fstem,x] = fileparts(ins_{L});
   G = textscan(fstem,'%s','delimiter','.'); G = G{1};
   time_str = ['.',G{6},'.'];
   time_str00 = time_str; time_str00(6:7) = '00';
   time_str01 = time_str; time_str01(6:7) = '01';
   time_str02 = time_str; time_str02(6:7) = '02';
   time_str03 = time_str; time_str03(6:7) = '03';
   time_str04 = time_str; time_str04(6:7) = '04';
   if ~isafile(ins_{L})
      if isafile(strrep(ins_{L},time_str,time_str00))
         ins_(L) = {strrep(ins_{L},time_str,time_str00)};
      elseif isafile(strrep(ins_{L},time_str,time_str01))
         ins_(L) = {strrep(ins_{L},time_str,time_str01)};
      elseif isafile(strrep(ins_{L},time_str,time_str02))
         ins_(L) = {strrep(ins_{L},time_str,time_str02)};
      elseif isafile(strrep(ins_{L},time_str,time_str03))
         ins_(L) = {strrep(ins_{L},time_str,time_str03)};
      elseif isafile(strrep(ins_{L},time_str,time_str04))
         ins_(L) = {strrep(ins_{L},time_str,time_str04)};
      else
         ins_(L) = [];
      end
   end
end

return
function write_out_csv(psap, file_out)
outdir = getnamedpath('filter_study_out');
fields = fieldnames(psap);
yyyy = datestr(psap.time,'yyyy-mm-dd'); HHMM = datestr(psap.time,'HH:MM:SS');
fid = fopen([outdir,file_out],'w');
for f = 1:length(fields)
   fld = fields{f};
   if all(size(psap.(fld))==1)&&~iscell(psap.(fld))
      fprintf(fid,'%% %s: %d \n',fld,psap.(fld));
   end
end

% outfield = fields;
% for f = length(fields):-1:1
%    fld = outfield{f};
%    if ~all(size(psap.(fld))==size(psap.time)) || strcmp(fld,'time') || ~isfloat(psap.(fld))
%       outfield(f) = [];
%    end
% end
outfield = [   {'flow_SLPM'          }
   {'flow_smooth'        }
   {'dV_ss'              }
   {'dL_ss'              }
   {'transmittance_blue' }
   {'transmittance_green'}
   {'transmittance_red'  }
   {'Tr_B_ss'            }
   {'Tr_G_ss'            }
   {'Tr_R_ss'            }
   {'Ba_B_raw'           }
   {'Ba_G_raw'           }
   {'Ba_R_raw'           }
   {'Weiss_f_B'          }
   {'Weiss_f_G'          }
   {'Weiss_f_R'          }
   {'Ba_B_Weiss'         }
   {'Ba_G_Weiss'         }
   {'Ba_R_Weiss'         }
   {'Bs_B_unc'           }
   {'Bs_G_unc'           }
   {'Bs_R_unc'           }
   {'Ba_B_Bond'          }
   {'Ba_G_Bond'          }
   {'Ba_R_Bond'          }
   {'Bs_B'               }
   {'Bs_G'               }
   {'Bs_R'               }
   {'Ba_B_Virk_Sca'      }
   {'Ba_G_Virk_Sca'      }
   {'Ba_R_Virk_Sca'      }
   {'AAE_BG_raw'         }
   {'AAE_BG_Weiss'       }
   {'AAE_BG_Bond'        }
   {'AAE_BG_Virk_Sca'    }
   {'AAE_BR_raw'         }
   {'AAE_BR_Weiss'       }
   {'AAE_BR_Bond'        }
   {'AAE_BR_Virk_Sca'    }
   {'AAE_GR_raw'         }
   {'AAE_GR_Weiss'       }
   {'AAE_GR_Bond'        }
   {'AAE_GR_Virk_Sca'    }
   {'Bx_B'               }
   {'Bx_G'               }
   {'Bx_R'               }
   {'Ba_B_Virk_Ext'      }
   {'Ba_G_Virk_Ext'      }
   {'Ba_R_Virk_Ext'      }
   {'AAE_BG_Virk_Ext'    }
   {'AAE_BR_Virk_Ext'    }
   {'AAE_GR_Virk_Ext'    }];
fprintf(fid,['yyyy-mm-dd, HH:MM:SS',repmat(', %s',[1,length(outfield)]), '\n'], outfield{:});
all_t = length(psap.time);
for t = 1:all_t;
   fprintf(fid,['%s, %s'],yyyy(t,:), HHMM(t,:));
   for f = 1:length(outfield)
      fld = outfield{f};
      fprintf(fid,', %1.7f',psap.(fld)(t));
   end
   fprintf(fid,'\n');
   if mod(t,1000)==0
      disp(num2str(all_t - t));
   end
end
fclose(fid)
return

