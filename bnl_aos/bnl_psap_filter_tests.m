
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
neph = rd_tsv_neph(ins);



% 'C:\case_studies\BNL_PSAP_filter_tests\from_salwen\dryneph\bnllabCPU1.dryneph.05s.00.20180725.000000.raw.tsv'
% 'C:\case_studies\BNL_PSAP_filter_tests\from_salwen\caps\bnllabCPU1.caps.01s.00.20180725.000000.raw.tsv'
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'caps',filesep]);
ins_ = strrep(ins_, '.dryneph.05s.','.caps.01s.');
ins_ = fix_file_timestamp(ins_);
caps = rd_bnl_tsv_caps(ins_);

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
% neph.Sca_B_amb(good) = 1e6.*smooth(neph.time(good),neph.Blue_T(good),12,'lowess').*0.889;
% neph.Sca_G_amb(good) = 1e6.*smooth(neph.time(good),neph.Green_T(good),12,'lowess').*0.889;
% neph.Sca_R_amb(good) = 1e6.*smooth(neph.time(good),neph.Red_T(good),12,'lowess').*0.889;
neph.Sca_B_amb(good) = 1e6.*smooth(neph.Blue_T(good),12).*0.889;
neph.Sca_G_amb(good) = 1e6.*smooth(neph.Green_T(good),12).*0.889;
neph.Sca_R_amb(good) = 1e6.*smooth(neph.Red_T(good),12).*0.889;
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

% caps.Ext_B_amb(caps.good_blue) = smooth(caps.time(caps.good_blue), caps.Extinction_Blue(caps.good_blue),60,'lowess');
% caps.Ext_G_amb(caps.good_green) = smooth(caps.time(caps.good_green), caps.Extinction_Green(caps.good_green),60,'lowess');
% caps.Ext_R_amb(caps.good_red) = smooth(caps.time(caps.good_red), caps.Extinction_Red(caps.good_red),60,'lowess');

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
% close(gcf);
% Next set of files...
% PSAP SN 046
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-046
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM1-046',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabVM1.046psap3wI.01s.00.20180725.040000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabVM1.046psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);
psap = read_psap_ir(ins_);
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
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM1-077',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabVM1.077psap3wI.01s.00.20180711.030000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabVM1.077psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);

tic; psap = read_psap_ir(ins_);toc
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


% PSAP SN 090
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM2-090
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM2-090',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabVM2.090psap3wI.01s.00.20180711.080000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabVM2.090psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);
tic; psap = read_psap_ir(ins_); toc
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

% PSAP SN 092
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM2-092
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM2-092',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabVM2.092psap3wI.01s.00.20180711.070000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabVM2.092psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);
tic; psap = read_psap_ir(ins_); toc
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

% PSAP SN 107
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_CPU2-107
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_CPU2-107',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabCPU2.107psap3wI.01s.00.20180711.060000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabCPU2.107psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);
tic; psap = read_psap_ir(ins_); toc

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


% PSAP SN 110
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_CPU2-110
ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_CPU2-110',filesep]);
% bnllabCPU1.dryneph.05s.00.20180724.220000.raw.tsv
% bnllabCPU2.110psap3wI.01s.00.20180711.010000.raw.tsv
ins_ = strrep(ins_, 'bnllabCPU1.dryneph.05s.','bnllabCPU2.110psap3wI.01s.');
ins_ = fix_file_timestamp(ins_);
tic; psap = read_psap_ir(ins_); toc
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
 
SN =          {'046','077','090','092','107','110'};
filter_type = {'Azu','E70','EMF','SAV','Wha','E70'};
legs = {'046 Azumi', '077 E70', '090 Emfab', '092 Savil', '107 Whatman','110 E70'};
% SN = {'077'};
% SN = {'077','090','107','110'};

figure_(333);figure_(334);figure_(335);

for sn = 1:length(SN)
   psap = eval(['psap_',SN{sn}]);
   figure_(333);
 plot(psap.time, psap.transmittance_blue, '-'); hold('on');
   figure_(334);
plot(psap.time,psap.transmittance_green,'-'); hold('on');
   figure_(335);
plot(psap.time,psap.transmittance_green,'-'); hold('on');
end
figure_(333); ax3(1) = gca; legend(legs);
xlabel('time'); ylabel('Tr');; title('Transmittance blue');
dynamicDateTicks;
figure_(334);ax3(2) = gca;legend(SN);legend(legs);
xlabel('time'); ylabel('Tr');; title('Transmittance green');
dynamicDateTicks;
figure_(335);ax3(3) = gca;legend(SN);legend(legs);
xlabel('time'); ylabel('Tr');; title('Transmittance red');
dynamicDateTicks;
linkaxes(ax3,'xy');
   
   

rs = 1;
plt = 1;

% linkaxes(rst,'xy')
% other colors...
for sn = 1:length(SN)
   NNN = SN{sn};
   eval(['psap = psap_',NNN,';']);
   title_str = ['PSAP SN ',NNN]
   
   [psap.flow_std,~, avg, mid] = stdwin(psap.flow_AD,30);
   psap.flow_rstd = mid./avg;
   
   [psap.B_ratio_std,~, avg, mid] = stdwin(psap.blu_rel,30);
   psap.B_ratio_rstd = mid./avg;
   [psap.B_sig_std,~, avg, mid] = stdwin(psap.blu_sig,30);
   psap.B_sig_rstd = mid./avg;
   [psap.B_ref_std,~, avg, mid] = stdwin(psap.blu_ref,30);
   psap.B_ref_rstd = mid./avg;
   
   [psap.G_ratio_std,~, avg, mid] = stdwin(psap.grn_rel,30);
   psap.G_ratio_rstd = mid./avg;
   [psap.G_sig_std,~, avg, mid] = stdwin(psap.grn_sig,30);
   psap.G_sig_rstd = mid./avg;
   [psap.G_ref_std,~, avg, mid] = stdwin(psap.grn_ref,30);
   psap.G_ref_rstd = mid./avg;
   
   psap.G_ref_avg = avg;
   
   [psap.R_ratio_std,~, avg, mid] = stdwin(psap.red_rel,30);
   psap.R_ratio_rstd = mid./avg;
   [psap.R_sig_std,~, avg, mid] = stdwin(psap.red_sig,30);
   psap.R_sig_rstd = mid./avg;
   [psap.R_ref_std,~, avg, mid] = stdwin(psap.red_ref,30);
   psap.R_ref_rstd = mid./avg;
   
   % for sn = 1:length(SN)
   %    NNN = SN{sn};
   %    eval(['psap = psap_',NNN,';']);
   %    title_str = ['PSAP SN ',NNN]
   figure_(sscanf(NNN,'%d'));
   ta(plt) = subplot(3,1,1); plt = plt+1;
   plot(psap.time, [psap.flow_SLPM ],'k-'); legend(['flow SLPM ',NNN]); dynamicDateTicks
   ylabel('unitless');
   title(title_str);
   ta(plt) = subplot(3,1,2); plt = plt+1;
   plot(psap.time, [psap.blu_ref ],'b-'); legend(['blue ref ',NNN]); dynamicDateTicks
   ylabel('unitless');logy;
   ta(plt) = subplot(3,1,3); plt = plt+1;
   plot(psap.time, [psap.B_ref_rstd ],'b-',psap.time, [psap.B_ratio_rstd ],'r-');
   legend(['B ref rstd',NNN],['B ratio rstd',NNN]); dynamicDateTicks
   ylabel('unitless');logy;
   xlabel('time');
   
   plot_name = [title_str, ' flow_ref_rstds'];
   saveas(gcf,[imgdir,plot_name,'.png']);
   saveas(gcf,[imgdir,plot_name,'.fig']);
   ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
   %    close(gcf);
   %    figure_;
   %    rst(rs) = subplot(3,1,1);rs = rs +1;
   %    plot(psap.time, psap.B_sig_rstd, 'c',psap.time, psap.B_ref_rstd, 'r-'); dynamicDateTicks
   %    logy;legend('std(sig)','std(ref)')
   %    title([title_str,': relative STD']);
   %    rst(rs) = subplot(3,1,2);rs = rs +1;
   %    plot(psap.time, psap.B_ratio_rstd, 'k'); dynamicDateTicks
   %    logy;legend('std(ratio)')
   %    rst(rs) = subplot(3,1,3);rs = rs +1;
   %    plot(psap.time, psap.flow_rstd, 'g'); dynamicDateTicks;
   %    legend('std(flow)')
   %
   %    plot_name = [title_str, ' standard deviations'];
   %    saveas(gcf,[imgdir,plot_name,'.png']);
   % saveas(gcf,[imgdir,plot_name,'.fig']);
   %    ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
   %    close(gcf);
   
   save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
   eval(['psap_',NNN,' = psap;']);
end

linkaxes(ta,'x');
% linkaxes(rst,'xy');

for sn = 1:length(SN)
   NNN = SN{sn};
   eval(['psap = psap_',NNN,';']);
   title_str = ['PSAP SN ',NNN]
   psap.flow_smooth = psap.flow_SLPM;
   tic; psap.flow_smooth = smooth(psap.flow_SLPM, ss);toc
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
   psap.Bs_B = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');;
   Bx = ang_coef(caps.Ext_B_stp, caps.EAE_BG_sm, caps.wavelength_B, psap.wavelength_B);
   psap.Bx_B = interp1(caps.time(caps.good_blue), Bx(caps.good_blue), psap.time, 'pchip');   
   psap.Ba_B_Virk_Sca = compute_Virkkula(psap.Tr_B_ss, psap.Bs_B, psap.Ba_B_raw, 4);
   psap.Ba_B_Virk_Ext = compute_Virkkula_ext(psap.Tr_B_ss, psap.Bx_B, psap.Ba_B_raw, 4);

   psap.Weiss_f_G = WeissBondOgren(psap.Tr_G_ss);
   psap.Ba_G_Weiss = psap.Ba_G_raw .* psap.Weiss_f_G;
   Bs = ang_coef(neph.Sca_B_stp_unc, neph.SAE_BR_sm, neph.wavelength_G, psap.wavelength_G);
   psap.Bs_G_unc = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   psap.Ba_G_Bond = psap.Ba_G_Weiss - (0.02./1.22).*psap.Bs_G_unc;
   Bs = ang_coef(neph.Sca_G_stp, neph.SAE_BR_sm, neph.wavelength_G, psap.wavelength_G);
   psap.Bs_G = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   Bx = ang_coef(caps.Ext_G_stp, caps.EAE_BR_sm, caps.wavelength_G, psap.wavelength_G);
   psap.Bx_G = interp1(caps.time(caps.good_green), Bx(caps.good_green), psap.time, 'pchip');
   psap.Ba_G_Virk_Sca = compute_Virkkula(psap.Tr_G_ss, psap.Bs_G, psap.Ba_G_raw, 4);
   psap.Ba_G_Virk_Ext = compute_Virkkula_ext(psap.Tr_G_ss, psap.Bx_G, psap.Ba_G_raw, 4);
   
   psap.Weiss_f_R = WeissBondOgren(psap.Tr_R_ss);
   psap.Ba_R_Weiss = psap.Ba_R_raw .* psap.Weiss_f_R;
   Bs = ang_coef(neph.Sca_R_stp_unc, neph.SAE_GR_sm, neph.wavelength_R, psap.wavelength_R);
   psap.Bs_R_unc = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   psap.Ba_R_Bond = psap.Ba_R_Weiss - (0.02./1.22).*psap.Bs_R_unc;
   Bs = ang_coef(neph.Sca_R_stp, neph.SAE_GR_sm, neph.wavelength_R, psap.wavelength_R);
   psap.Bs_R = interp1(neph.time(neph.good), Bs(neph.good), psap.time, 'pchip');
   Bx = ang_coef(caps.Ext_R_stp, caps.EAE_GR_sm, caps.wavelength_R, psap.wavelength_R);
   psap.Bx_R = interp1(caps.time(caps.good_red), Bx(caps.good_red), psap.time, 'pchip');
   psap.Ba_R_Virk_Sca = compute_Virkkula(psap.Tr_R_ss, psap.Bs_R, psap.Ba_R_raw, 4);
   psap.Ba_R_Virk_Ext = compute_Virkkula_ext(psap.Tr_R_ss, psap.Bx_R, psap.Ba_R_raw, 4);
   
   psap.AAE_BG_Weiss = ang_exp(psap.Ba_B_Weiss,psap.Ba_G_Weiss,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Bond = ang_exp(psap.Ba_B_Bond,psap.Ba_G_Bond,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Virk_Sca = ang_exp(psap.Ba_B_Virk_Sca,psap.Ba_G_Virk_Sca,psap.wavelength_B, psap.wavelength_G);
   psap.AAE_BG_Virk_Ext = ang_exp(psap.Ba_B_Virk_Ext,psap.Ba_G_Virk_Ext,psap.wavelength_B, psap.wavelength_G);

   psap.AAE_BR_Weiss    = ang_exp(psap.Ba_B_Weiss,psap.Ba_R_Weiss,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Bond     = ang_exp(psap.Ba_B_Bond,psap.Ba_R_Bond,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Virk_Sca = ang_exp(psap.Ba_B_Virk_Sca,psap.Ba_R_Virk_Sca,psap.wavelength_B, psap.wavelength_R);
   psap.AAE_BR_Virk_Ext = ang_exp(psap.Ba_B_Virk_Ext,psap.Ba_R_Virk_Ext,psap.wavelength_B, psap.wavelength_R);

   psap.AAE_GR_Weiss    = ang_exp(psap.Ba_G_Weiss,psap.Ba_R_Weiss,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Bond     = ang_exp(psap.Ba_G_Bond,psap.Ba_R_Bond,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Virk_Sca = ang_exp(psap.Ba_G_Virk_Sca,psap.Ba_R_Virk_Sca,psap.wavelength_G, psap.wavelength_R);
   psap.AAE_GR_Virk_Ext = ang_exp(psap.Ba_G_Virk_Ext,psap.Ba_R_Virk_Ext,psap.wavelength_G, psap.wavelength_R);

   eval(['psap_',NNN,' = psap;']);
   save([psap.pname{1},filesep,psap.fname{1},'.mat'],'-struct','psap')
end

% psap
% Extend to 3x2 for all six PSAPs.
figure_(999);
six(1) = subplot(2,3,1);
plot(psap_046.time, psap_046.flow_rstd,'-'); legend('046');dynamicDateTicks; logy;
six(2) = subplot(2,3,2);
plot(psap_077.time, psap_077.flow_rstd,'-'); legend('077');dynamicDateTicks ; logy;
title('Flow relative deviation')
six(3) = subplot(2,3,3);
plot(psap_090.time, psap_090.flow_rstd,'-'); legend('090');dynamicDateTicks ; logy;
six(4) = subplot(2,3,4);
plot(psap_092.time, psap_092.flow_rstd,'-'); legend('092');dynamicDateTicks ; logy;
six(5) = subplot(2,3,5);
plot(psap_107.time, psap_107.flow_rstd,'-'); legend('107');dynamicDateTicks ; logy;
six(6) = subplot(2,3,6);
plot(psap_110.time, psap_110.flow_rstd,'-'); legend('110');dynamicDateTicks ; logy;
linkaxes(six,'xy');
OK = menu('Touch each plot to set the labels and limits, then click OK','OK');
plot_name = ['flow_std_ALL_PSAPs'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);close(gcf)

figure_(999);
sixb(1) = subplot(2,3,1);
plot(psap_046.time, psap_046.B_ratio_rstd,'-'); legend('046');dynamicDateTicks ; logy;
sixb(2) = subplot(2,3,2);
plot(psap_077.time, psap_077.B_ratio_rstd,'-'); legend('077');dynamicDateTicks ; logy;
title('Blue ratio relative deviation')
sixb(3) = subplot(2,3,3);
plot(psap_090.time, psap_090.B_ratio_rstd,'-'); legend('090');dynamicDateTicks ; logy;
sixb(4) = subplot(2,3,4);
plot(psap_092.time, psap_092.B_ratio_rstd,'-'); legend('092');dynamicDateTicks ; logy;
sixb(5) = subplot(2,3,5);
plot(psap_107.time, psap_107.B_ratio_rstd,'-'); legend('107');dynamicDateTicks ; logy;
sixb(6) = subplot(2,3,6);
plot(psap_110.time, psap_110.B_ratio_rstd,'-'); legend('110');dynamicDateTicks ; logy;

figure_(1000);
sixb(7) = subplot(2,3,1);
plot(psap_046.time, psap_046.G_ratio_rstd,'g-'); legend('046');dynamicDateTicks ; logy;
sixb(8) = subplot(2,3,2);
plot(psap_077.time, psap_077.G_ratio_rstd,'g-'); legend('077');dynamicDateTicks ; logy;
title('Green ratio relative deviation')
sixb(9) = subplot(2,3,3);
plot(psap_090.time, psap_090.G_ratio_rstd,'g-'); legend('090');dynamicDateTicks ; logy;
sixb(10) = subplot(2,3,4);
plot(psap_092.time, psap_092.G_ratio_rstd,'g-'); legend('092');dynamicDateTicks ; logy;
sixb(11) = subplot(2,3,5);
plot(psap_107.time, psap_107.G_ratio_rstd,'g-'); legend('107');dynamicDateTicks ; logy;
sixb(12) = subplot(2,3,6);
plot(psap_110.time, psap_110.G_ratio_rstd,'g-'); legend('110');dynamicDateTicks ; logy;


figure_(1001);
sixb(13) = subplot(2,3,1);
plot(psap_046.time, psap_046.R_ratio_rstd,'r-'); legend('046');dynamicDateTicks ; logy;
sixb(14) = subplot(2,3,2);
plot(psap_077.time, psap_077.R_ratio_rstd,'r-'); legend('077');dynamicDateTicks ; logy;
title('Red ratio relative deviation')
sixb(15) = subplot(2,3,3);
plot(psap_090.time, psap_090.R_ratio_rstd,'r-'); legend('090');dynamicDateTicks ; logy;
sixb(16) = subplot(2,3,4);
plot(psap_092.time, psap_092.R_ratio_rstd,'r-'); legend('092');dynamicDateTicks ; logy;
sixb(17) = subplot(2,3,5);
plot(psap_107.time, psap_107.R_ratio_rstd,'r-'); legend('107');dynamicDateTicks ; logy;
sixb(18) = subplot(2,3,6);
plot(psap_110.time, psap_110.R_ratio_rstd,'r-'); legend('110');dynamicDateTicks ; logy;


linkaxes(sixb,'xy');
OK = menu('Touch each plot to set the labels and limits, then click OK','OK');

plot_name = ['B_ratio_rstd ALL_PSAPs'];
figure(999); pause(.1);
saveas(999,[imgdir,plot_name,'.png']);
saveas(999,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
close(999);
plot_name = ['G_ratio_rstd ALL_PSAPs'];
figure(1000); pause(.1);
saveas(1000,[imgdir,plot_name,'.png']);
saveas(1000,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
close(1000);
plot_name = ['R_ratio_rstd ALL_PSAPs'];
figure(1001); pause(.1);
saveas(1001,[imgdir,plot_name,'.png']);
saveas(1001,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
% close(fig_R_ratio_rstd);
figure_(1001); % G_ref_avg
cla;
% title('Green reference sliding window avg')
sixc(1) = subplot(2,3,1);
plot(psap_046.time, psap_046.G_ref_avg,'-'); legend('046');dynamicDateTicks
yl = ylim;
sixc(2) = subplot(2,3,2);
plot(psap_077.time, psap_077.G_ref_avg,'-'); legend('077');dynamicDateTicks
title('Green reference counts');
yl_ = ylim; yl = [0,max(yl(2),yl_(2))];
sixc(3) = subplot(2,3,3);
plot(psap_090.time, psap_090.G_ref_avg,'-'); legend('090');dynamicDateTicks
yl_ = ylim; yl = [0,max(yl(2),yl_(2))];
sixc(4) = subplot(2,3,4);
plot(psap_092.time, psap_092.G_ref_avg,'-'); legend('092');dynamicDateTicks
yl_ = ylim; yl = [0,max(yl(2),yl_(2))];
sixc(5) = subplot(2,3,5);
plot(psap_107.time, psap_107.G_ref_avg,'-'); legend('107');dynamicDateTicks
yl_ = ylim; yl = [0,max(yl(2),yl_(2))];
sixc(6) = subplot(2,3,6);
plot(psap_110.time, psap_110.G_ref_avg,'-'); legend('110');dynamicDateTicks
yl_ = ylim; yl = [0,max(yl(2),yl_(2))];

linkaxes(sixc,'xy'); ylim([0,1.1.*yl(2)]);
OK = menu('Touch each plot to set the labels and limits, then click OK','OK');
plot_name = ['G_ref_avg_ALL_PSAPs'];
saveas(1001,[imgdir,plot_name,'.png']);
saveas(1001,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
close(1001);
% plot hourly averages of ref_signal vs std_ratio
% OK = menu('Zoom into a time period to compute averages from and hit OK','OK');
% ut = xlim;
% figure;
% for sn = 1:length(SN)
%    NNN = SN{sn};
%    eval(['psap = psap_',NNN,';']);
%    xl_ = psap.time>ut(1)&psap.time<ut(2);
% plot(meannonan(psap.blu_ref(xl_)),meannonan(psap.B_ratio_rstd(xl_)),'o');
% hold('on');
% end
% title('Reference counts vs ratio rel std, blue');
% legend('046','077','090','092','107','110')

% figure;
% for sn = 1:length(SN)
%    NNN = SN{sn};
%    eval(['psap = psap_',NNN,';']);
%    xl_ = psap.time>ut(1)&psap.time<ut(2);
% plot(meannonan(psap.grn_ref(xl_)),meannonan(psap.G_ratio_rstd(xl_)),'o');
% hold('on');
% end
% title('Reference counts vs ratio rel std, green');
% legend('046','077','090','092','107','110')

% figure;
% for sn = 1:length(SN)
%    NNN = SN{sn};
%    eval(['psap = psap_',NNN,';']);
%    xl_ = psap.time>ut(1)&psap.time<ut(2);
% plot(meannonan(psap.red_ref(xl_)),meannonan(psap.R_ratio_rstd(xl_)),'o');
% hold('on');
% end
% title('Reference counts vs ratio rel std, red');
% legend('046','077','090','092','107','110')

% psap = psap_046; title_str = 'PSAP SN 046';
% psap = psap_077; title_str = 'PSAP SN 077';
% psap = psap_090; title_str = 'PSAP SN 090';
% psap = psap_092; title_str = 'PSAP SN 092';
% psap = psap_107; title_str = 'PSAP SN 107';
% psap = psap_110; title_str = 'PSAP SN 110';

plt = 1;
for sn = 1:length(SN)
   NNN = SN{sn};
   eval(['psap = psap_',NNN,';']);
   title_str = ['PSAP SN ',NNN]
   close(sscanf(NNN,'%d'));
   figure_(sscanf(NNN,'%d'));
   plot(psap.time, [psap.Ba_B_Bond ],'b-',psap.time, [psap.Ba_G_Bond ],'g-',...
      psap.time, [psap.Ba_R_Bond ],'r-');
   legend(['Bab B ',NNN],['Bab G ',NNN],['Bab R ',NNN]); dynamicDateTicks
   sb(plt) = gca; plt = plt+1;
   %    plot(psap.time, [psap.Ba_B ],'b-'); legend(['Bab B ',NNN]); dynamicDateTicks
   %    ylabel('Bap [1/Mm]');
   %    title(title_str);
   %    sb(plt) = subplot(3,1,2); plt = plt+1;
   %    plot(psap.time, [psap.Ba_G ],'g-'); legend(['Bab G ',NNN]); dynamicDateTicks
   %    ylabel('Bap [1/Mm]');
   %    sb(plt) = subplot(3,1,3); plt = plt+1;
   %    plot(psap.time, [psap.Ba_R ],'r-'); legend(['Bab R ',NNN]); dynamicDateTicks
   ylabel('Bap [1/Mm]');
   xlabel('time');
   %    plot_name = [title_str, '_Bab'];
   %    saveas(gcf,[imgdir,plot_name,'.png']);
   %    saveas(gcf,[imgdir,plot_name,'.fig']);
   %    ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
end
linkaxes(sb,'xy');
yl = ylim; ylim([-0.05.*yl(2),yl(2)]);
done = false;
while ~done
   don = menu('Zoom in adjust axes, hit "SAVE" to save current view. Hit "DONE" when all finished','SAVE', 'DONE');
   for sn = 1:length(SN)
      NNN = SN{sn};
      title_str = ['PSAP SN ',NNN]
      figure_(sscanf(NNN,'%d'));
      plot_name = [title_str, '_Bab'];
      if ~isafile([imgdir,plot_name,'.fig'])
         saveas(gcf,[imgdir,plot_name,'.fig']);
      end
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
plt = 1;
for sn = 1:length(SN)
   NNN = SN{sn};
   eval(['psap = psap_',NNN,';']);
   title_str = ['PSAP SN ',NNN]
   close(sscanf(NNN,'%d'));figure_(sscanf(NNN,'%d'));
   tb(plt) = subplot(3,1,1); plt = plt+1;
   plot(psap.time, [psap.Tr_B_ss ],'b-'); legend(['Tr B ',NNN]); dynamicDateTicks
   ylabel('unitless');ylim([-.1,1.3]);
   title(title_str);
   tb(plt) = subplot(3,1,2); plt = plt+1;
   plot(psap.time, [psap.Tr_G_ss ],'g-'); legend(['Tr G ',NNN]); dynamicDateTicks
   ylabel('unitless');ylim([-.1,1.3]);
   tb(plt) = subplot(3,1,3); plt = plt+1;
   plot(psap.time, [psap.Tr_R_ss ],'r-'); legend(['Tr R ',NNN]); dynamicDateTicks
   ylabel('unitless');ylim([-.1,1.3]);
   xlabel('time');
      plot_name = [title_str, '_Tr'];
      saveas(gcf,[imgdir,plot_name,'.png']);
      saveas(gcf,[imgdir,plot_name,'.fig']);
      ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
% end

end
linkaxes(tb,'xy');
for sn = 1:length(SN)
   NNN = SN{sn};
   figure_(sscanf(NNN,'%d'));
   plot_name = [title_str, '_Tr'];
   saveas(gcf,[imgdir,plot_name,'.png']);
   saveas(gcf,[imgdir,plot_name,'.fig']);
   ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);
end
%Is the following better than one or more of the above?
% Can/should we discontinue one of the above for this instead?

% plt = 1;
% for sn = 1:length(SN)
%    NNN = SN{sn};
%    eval(['psap = psap_',NNN,';']);
%    title_str = ['PSAP SN ',NNN]
%    figure_;
%    ta(plt) = subplot(3,1,1); plt = plt+1;
%    plot(psap.time, [psap.flow_SLPM ],'k-'); legend(['flow SLPM ',NNN]); dynamicDateTicks
%    ylabel('unitless');
%    title(title_str);
%    ta(plt) = subplot(3,1,2); plt = plt+1;
%    plot(psap.time, [psap.blu_ref ],'b-'); legend(['blue ref ',NNN]); dynamicDateTicks
%    ylabel('unitless');logy;
%    ta(plt) = subplot(3,1,3); plt = plt+1;
%    plot(psap.time, [psap.B_ref_rstd ],'b-',psap.time, [psap.B_ratio_rstd ],'r-');
%    legend(['B ref rstd',NNN],['B ratio rstd',NNN]); dynamicDateTicks
%    ylabel('unitless');logy;
%    xlabel('time');
% end
% linkaxes(ta,'x');

plt = 1;
figure_(999);
leg1 = {}; leg2 = {};leg3 = {};
for sn = 1:length(SN)
   NNN = SN{sn};
   eval(['psap = psap_',NNN,';']);
   title('Sample flow')
   tf(1) = subplot(3,1,1);
   plot(psap.time, [psap.flow_SLPM ],'-'); dynamicDateTicks; hold('on');
   leg1 = [leg1;{['flow ',NNN]}];
   ylabel('SLPM');
   tf(2) = subplot(3,1,2);
   plot(psap.time, [psap.blu_ref ],'-'); dynamicDateTicks; hold('on');
   leg2 = [leg2;{['blu ref ',NNN]}];
   ylabel('AD cnts');
   ylabel('unitless');logy;
   tf(3) = subplot(3,1,3);
   plot(psap.time, [psap.blu_sig ],'-'); dynamicDateTicks; hold('on');
   leg3 = [leg3;{['blu sig ',NNN]}];
   ylabel('AD cnts');
   ylabel('unitless');logy;
   xlabel('time');
end
legend(tf(1),leg1);
legend(tf(2),leg2);
legend(tf(3),leg3);
linkaxes(tf,'x');

plot_name = ['flow_sig_ref_ALL'];
saveas(gcf,[imgdir,plot_name,'.png']);
saveas(gcf,[imgdir,plot_name,'.fig']);
ppt_add_slide([pptdir, ppt_name,'.ppt'], [imgdir,plot_name]);

tap_spot_area = 30.721; %default for PALL E70 from Brechtel TAP data file
% Spot Area = 3.0721E-5 sq. m
% Use rd_tap_bmi_raw_nolf for data collected 2018-07-10 and before
% Use rd_tap_bmi_raw for data collected on or after 2018-07-11 10:37
% From Jake 2018-7-17: TAP 14 with Azumi: 7.0mm ==> 38.5 mm^2.
% TAP 15 with Pall: 6.9mm ==> 37.4 mm^2.

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
close('all');
tap_14 = rd_tap_bmi_raw(getfullname('RAW_TAP_SN14*.dat','tap_14','Select tap puTTY log file.'));
tap14 = proc_tap_me(tap_14);
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


TAP14_flowcal = load('C:\case_studies\BNL_PSAP_filter_tests\TAP\TAP14_flowcal.mat');
tap14.flow_slpm = polyval(TAP14_flowcal.P1_top,tap14.flow_lpm);

close('all')
tap_15 = rd_tap_bmi_raw(getfullname('RAW_TAP_SN15*.dat','tap_15','Select tap puTTY log file.'));
tap15 = proc_tap_me(tap_15);
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
   time_str03 = time_str; time_str01(6:7) = '03';
   time_str04 = time_str; time_str02(6:7) = '04';
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