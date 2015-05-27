%% sws osf tests
% dark: sgpswscf.00.20090701.012746.raw.dat, 15 ms, 18 ms
% dark: sgpswscf.00.20090701.010834.raw.dat, 18 records, as above

% osf1: 300-650 nm, sgpswscf.00.20090701.011333.raw.dat, Si_osf1.fig
% dark: sgpswscf.00.20090701.011908.raw.dat
% osf2: 450-900 nm, sgpswscf.00.20090701.012047.raw.dat, Si_osf2.fig
% dark: sgpswscf.00.20090701.012746.raw.dat
% osf3: 650-1200: sgpswscf.00.20090701.012832.raw.dat, Si_osf3.fig, InGaAs_osf3.fig
% dark: sgpswscf.00.20090701.013426.raw.dat
% dark: sgpswscf.00.20090701.013703.raw.dat new tints 100, 120 ms
% confused: sgpswscf.00.20090701.013745.raw.dat, as above
% darks: sgpswscf.00.20090701.014627.raw.dat, 100, 35 ms
% osf4: 800-1300: sgpswscf.00.20090701.014747.raw.dat, as above, Si_osf4.fig InGaAs_osf4.fig
% osf5: 1300-2200: sgpswscf.00.20090701.015301.raw.dat, InGaAs_osf5.fig
% darks: sgpswscf.00.20090701.015724.raw.dat

sws_osf_path = ['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\'];
dark1_name = 'sgpswscf.00.20090701.010834.raw.dat';
dark2_name = 'sgpswscf.00.20090701.011908.raw.dat';
osf1_name = 'sgpswscf.00.20090701.011333.raw.dat';

sws_dark = read_sws_raw([sws_osf_path,dark1_name]);
Si_sd = std(sws_dark.Si_DN(sws_dark.Si_lambda>350&sws_dark.Si_lambda<500 ,:));
In_sd = std(sws_dark.In_DN(sws_dark.In_lambda>1400&sws_dark.In_lambda<1600,:));
%
figure; subplot(2,1,1)
plot(sws_dark.Si_lambda,[sws_dark.Si_DN],'-')
title(['Si darks'],'interp','none')
subplot(2,1,2); plot(sws_dark.In_lambda, sws_dark.In_DN, '-')
title(['InGaAS darks'],'interp','none')
figure; subplot(2,1,1);plot([1:length(sws_dark.time)],[Si_sd],'b-o');
lg = legend('std_dev(Si)');
set(lg,'interp','none')
title(['Si darks, stddev'],'interp','none')
subplot(2,1,2);plot([1:length(sws_dark.time)],[In_sd],'r-o');
title(['InGaAs darks, stddev'],'interp','none')
lg = legend('std_dev(InGaAs)');
set(lg,'interp','none')
%%
bad_Si = Si_sd > 3;
bad_In = In_sd > 250;
Si_dark = mean(sws_dark.Si_DN(:,~bad_Si),2);
In_dark = mean(sws_dark.In_DN(:,~bad_In),2);
%%
osf1_name = 'sgpswscf.00.20090701.011333.raw.dat';
sws_osf1 = read_sws_raw([sws_osf_path,osf1_name]);
figure; subplot(2,1,1)
plot(sws_osf1.Si_lambda,[sws_osf1.Si_DN],'-')
title(['Si DN'],'interp','none')
subplot(2,1,2); plot(sws_osf1.In_lambda, sws_osf1.In_DN, '-')
title(['InGaAS DN'],'interp','none')
%%
%use region from 800-1000 nm as dark scaling region for CMOS
%use region from 1800-1860 nm as dark scaling region for CMOS
InGaAs_dark_pin = mean(In_dark(sws_dark.In_lambda>1800 & sws_dark.In_lambda<1860));
InGaAs_dark_pins =mean(sws_osf1.In_DN((sws_osf1.In_lambda>1800 & sws_osf1.In_lambda<1860),:),1);
Si_dark_pin = mean(Si_dark(sws_dark.Si_lambda>800 & sws_dark.Si_lambda<1000));
Si_dark_pins =mean(sws_osf1.Si_DN((sws_osf1.Si_lambda>800 & sws_osf1.Si_lambda<1000),:),1);

%%
start_pt = 1;
[tmp,InGaAs_peak] = max(sws_osf1.In_DN,[],1);
[tmp,Si_peak] = max(sws_osf1.Si_DN,[],1);
figure; plot([start_pt:length(sws_osf1.In_ms)],InGaAs_peak+start_pt-1,'-bx',[start_pt:length(sws_osf1.Si_ms)],Si_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%%
figure; plot([start_pt:length(sws_osf1.In_ms)],sws_osf1.In_lambda(InGaAs_peak),'-bx',[start_pt:length(sws_osf1.Si_ms)],sws_osf1.Si_lambda(Si_peak),'-ro');

title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
%%
InGaAs_sub = [15:200];
Si_sub = [15:200];
sws_osf1.InGaAs_sub = InGaAs_sub;
sws_osf1.Si_sub = Si_sub;

%%
sws_osf1.Si_sig = sws_osf1.Si_DN - (Si_dark*Si_dark_pins)./Si_dark_pin; 
sws_osf1.In_sig = sws_osf1.In_DN - (In_dark*InGaAs_dark_pins)./InGaAs_dark_pin; 
figure; lines = semilogy(sws_osf1.In_lambda, sws_osf1.In_sig(:,InGaAs_sub),'-'); recolor(lines,[1:length(InGaAs_sub)]);
title('SWS InGaAs dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(sws_osf1.Si_lambda, sws_osf1.Si_sig(:,Si_sub),'-'); recolor(lines,[1:length(Si_sub)]);
title('SWS Si dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
% linkaxes(axx,'x');
%%
% wl is wavelength array of length 1xN
% cts is array of detector cts of length [MxN]
[sws_osf1.scan_nm, sws_osf1.norm_peaks, sws_osf1.peaks] = mono_peaks([sws_osf1.Si_lambda',sws_osf1.In_lambda'],...
   [sws_osf1.Si_sig(:,Si_sub)', sws_osf1.In_sig(:,InGaAs_sub)']);

%%
monopeak.scan_nm = sws_osf1.scan_nm;
monopeak.norm_peaks = sws_osf1.norm_peaks;
monopeak.peaks = sws_osf1.peaks;
monopeak.Si_norm_peaks =sws_osf1.norm_peaks(:,1:256);
monopeak.InGaAs_norm_peaks =sws_osf1.norm_peaks(:,257:end);
monopeak.Si_nm = sws_osf1.Si_lambda;
monopeak.InGaAs_nm = sws_osf1.In_lambda;
%
Si_goodpix = ~isNaN(monopeak.Si_nm);
InGaAs_goodpix = ~isNaN(monopeak.InGaAs_nm);
figure; 
subplot(1,2,1);
imagesc(monopeak.Si_nm(Si_goodpix), monopeak.scan_nm, real(log10(monopeak.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CMOS normalized pixel response')
subplot(1,2,2);
imagesc(monopeak.InGaAs_nm(InGaAs_goodpix), monopeak.scan_nm, real(log10(monopeak.InGaAs_norm_peaks(:,InGaAs_goodpix))));;
axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
title('InGaAs normalized pixel response')
%%
save([sws_osf_path,filesep,'osf1_monopeak.mat'],'monopeak');

%% Now for osf2
% dark: sgpswscf.00.20090701.011908.raw.dat
% osf2: 450-900 nm, sgpswscf.00.20090701.012047.raw.dat, Si_osf2.fig
% dark: sgpswscf.00.20090701.012746.raw.dat

dark1_name = 'sgpswscf.00.20090701.011908.raw.dat';
dark2_name = 'sgpswscf.00.20090701.012746.raw.dat';
osf2_name = 'sgpswscf.00.20090701.012047.raw.dat';

sws_dark = read_sws_raw([sws_osf_path,dark1_name]);
Si_sd = std(sws_dark.Si_DN(sws_dark.Si_lambda>800&sws_dark.Si_lambda<1000 ,:));
In_sd = std(sws_dark.In_DN(sws_dark.In_lambda>1400&sws_dark.In_lambda<1600,:));
%
figure; subplot(2,1,1)
plot(sws_dark.Si_lambda,[sws_dark.Si_DN],'-')
title(['Si darks'],'interp','none')
subplot(2,1,2); plot(sws_dark.In_lambda, sws_dark.In_DN, '-')
title(['InGaAS darks'],'interp','none')
figure; subplot(2,1,1);plot([1:length(sws_dark.time)],[Si_sd],'b-o');
lg = legend('std_dev(Si)');
set(lg,'interp','none')
title(['Si darks, stddev'],'interp','none')
subplot(2,1,2);plot([1:length(sws_dark.time)],[In_sd],'r-o');
title(['InGaAs darks, stddev'],'interp','none')
lg = legend('std_dev(InGaAs)');
set(lg,'interp','none')
%%
bad_Si = Si_sd > 3;
bad_In = In_sd > 250;
Si_dark = mean(sws_dark.Si_DN(:,~bad_Si),2);
In_dark = mean(sws_dark.In_DN(:,~bad_In),2);
%%

sws_osf2 = read_sws_raw([sws_osf_path,osf2_name]);
figure; subplot(2,1,1)
plot(sws_osf2.Si_lambda,[sws_osf2.Si_DN],'-')
title(['Si DN'],'interp','none')
subplot(2,1,2); plot(sws_osf2.In_lambda, sws_osf2.In_DN, '-')
title(['InGaAS DN'],'interp','none')
%%
%use region from 300-400 nm as dark scaling region for CMOS
Si_bot = 300; Si_top = 400;
%use region from 1800-1860 nm as dark scaling region for CMOS
In_bot = 1800; In_top = 1860;
InGaAs_dark_pin = mean(In_dark(sws_dark.In_lambda>In_bot & sws_dark.In_lambda<In_top));
InGaAs_dark_pins =mean(sws_osf2.In_DN((sws_osf2.In_lambda>In_bot & sws_osf2.In_lambda<In_top),:),1);
Si_dark_pin = mean(Si_dark(sws_dark.Si_lambda>Si_bot & sws_dark.Si_lambda<Si_top));
Si_dark_pins =mean(sws_osf2.Si_DN((sws_osf2.Si_lambda>Si_bot & sws_osf2.Si_lambda<Si_top),:),1);

%%
start_pt = 1;
[tmp,InGaAs_peak] = max(sws_osf2.In_DN,[],1);
[tmp,Si_peak] = max(sws_osf2.Si_DN,[],1);
figure; plot([start_pt:length(sws_osf2.In_ms)],InGaAs_peak+start_pt-1,'-bx',[start_pt:length(sws_osf2.Si_ms)],Si_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%
figure; plot([start_pt:length(sws_osf2.In_ms)],sws_osf2.In_lambda(InGaAs_peak),'-bx',[start_pt:length(sws_osf2.Si_ms)],sws_osf2.Si_lambda(Si_peak),'-ro');

title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
%%
InGaAs_sub = [5:200];
Si_sub = [5:200];
sws_osf2.InGaAs_sub = InGaAs_sub;
sws_osf2.Si_sub = Si_sub;

%%
sws_osf2.Si_sig = sws_osf2.Si_DN - (Si_dark*Si_dark_pins)./Si_dark_pin; 
sws_osf2.In_sig = sws_osf2.In_DN - (In_dark*InGaAs_dark_pins)./InGaAs_dark_pin; 
figure; lines = semilogy(sws_osf2.In_lambda, sws_osf2.In_sig(:,InGaAs_sub),'-'); recolor(lines,[1:length(InGaAs_sub)]);
title('SWS InGaAs dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(sws_osf2.Si_lambda, sws_osf2.Si_sig(:,Si_sub),'-'); recolor(lines,[1:length(Si_sub)]);
title('SWS Si dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
% linkaxes(axx,'x');
%%
% wl is wavelength array of length 1xN
% cts is array of detector cts of length [MxN]
[sws_osf2.scan_nm, sws_osf2.norm_peaks, sws_osf2.peaks] = mono_peaks([sws_osf2.Si_lambda',sws_osf2.In_lambda'],...
   [sws_osf2.Si_sig(:,Si_sub)', sws_osf2.In_sig(:,InGaAs_sub)']);

%%
monopeak.scan_nm = sws_osf2.scan_nm;
monopeak.norm_peaks = sws_osf2.norm_peaks;
monopeak.peaks = sws_osf2.peaks;
monopeak.Si_norm_peaks =sws_osf2.norm_peaks(:,1:256);
monopeak.InGaAs_norm_peaks =sws_osf2.norm_peaks(:,257:end);
monopeak.Si_nm = sws_osf2.Si_lambda;
monopeak.InGaAs_nm = sws_osf2.In_lambda;
%
Si_goodpix = ~isNaN(monopeak.Si_nm);
InGaAs_goodpix = ~isNaN(monopeak.InGaAs_nm);
figure; 
subplot(1,2,1);
imagesc(monopeak.Si_nm(Si_goodpix), monopeak.scan_nm, real(log10(monopeak.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CMOS normalized pixel response')
subplot(1,2,2);
imagesc(monopeak.InGaAs_nm(InGaAs_goodpix), monopeak.scan_nm, real(log10(monopeak.InGaAs_norm_peaks(:,InGaAs_goodpix))));;
axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
title('InGaAs normalized pixel response')
%%
save([sws_osf_path,filesep,'osf2_monopeak.mat'],'monopeak');

%%
%% Now for osf3
% dark: sgpswscf.00.20090701.012746.raw.dat
% osf3: 650-1200: sgpswscf.00.20090701.012832.raw.dat, Si_osf3.fig, InGaAs_osf3.fig
% dark: sgpswscf.00.20090701.013426.raw.dat

dark1_name = 'sgpswscf.00.20090701.012746.raw.dat';
dark2_name = 'sgpswscf.00.20090701.013426.raw.dat';
osf3_name = 'sgpswscf.00.20090701.012832.raw.dat';

sws_dark = read_sws_raw([sws_osf_path,dark2_name]);
Si_sd = std(sws_dark.Si_DN(sws_dark.Si_lambda>800&sws_dark.Si_lambda<1000 ,:));
In_sd = std(sws_dark.In_DN(sws_dark.In_lambda>1400&sws_dark.In_lambda<1600,:));
%
figure; subplot(2,1,1)
plot(sws_dark.Si_lambda,[sws_dark.Si_DN],'-')
title(['Si darks'],'interp','none')
subplot(2,1,2); plot(sws_dark.In_lambda, sws_dark.In_DN, '-')
title(['InGaAS darks'],'interp','none')
figure; subplot(2,1,1);plot([1:length(sws_dark.time)],[Si_sd],'b-o');
lg = legend('std_dev(Si)');
set(lg,'interp','none')
title(['Si darks, stddev'],'interp','none')
subplot(2,1,2);plot([1:length(sws_dark.time)],[In_sd],'r-o');
title(['InGaAs darks, stddev'],'interp','none')
lg = legend('std_dev(InGaAs)');
set(lg,'interp','none')
%%
bad_Si = Si_sd > 3;
bad_In = In_sd > 250;
Si_dark = mean(sws_dark.Si_DN(:,~bad_Si),2);
In_dark = mean(sws_dark.In_DN(:,~bad_In),2);
%%

sws_osf3 = read_sws_raw([sws_osf_path,osf3_name]);
figure; subplot(2,1,1)
plot(sws_osf3.Si_lambda,[sws_osf3.Si_DN],'-')
title(['Si DN'],'interp','none')
subplot(2,1,2); plot(sws_osf3.In_lambda, sws_osf3.In_DN, '-')
title(['InGaAS DN'],'interp','none')
%%
%use region from 300-400 nm as dark scaling region for CMOS
Si_bot = 400; Si_top = 500;
%use region from 1800-1860 nm as dark scaling region for CMOS
In_bot = 1800; In_top = 20000;
InGaAs_dark_pin = mean(In_dark(sws_dark.In_lambda>In_bot & sws_dark.In_lambda<In_top));
InGaAs_dark_pins =mean(sws_osf3.In_DN((sws_osf3.In_lambda>In_bot & sws_osf3.In_lambda<In_top),:),1);
Si_dark_pin = mean(Si_dark(sws_dark.Si_lambda>Si_bot & sws_dark.Si_lambda<Si_top));
Si_dark_pins =mean(sws_osf3.Si_DN((sws_osf3.Si_lambda>Si_bot & sws_osf3.Si_lambda<Si_top),:),1);

%%
start_pt = 1;
[tmp,InGaAs_peak] = max(sws_osf3.In_DN,[],1);
[tmp,Si_peak] = max(sws_osf3.Si_DN,[],1);
figure; plot([start_pt:length(sws_osf3.In_ms)],InGaAs_peak+start_pt-1,'-bx',[start_pt:length(sws_osf3.Si_ms)],Si_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%
figure; plot([start_pt:length(sws_osf3.In_ms)],sws_osf3.In_lambda(InGaAs_peak),'-bx',[start_pt:length(sws_osf3.Si_ms)],sws_osf3.Si_lambda(Si_peak),'-ro');

title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
%%
InGaAs_sub = [2:337];
Si_sub = [2:337];
sws_osf3.InGaAs_sub = InGaAs_sub;
sws_osf3.Si_sub = Si_sub;

%%
sws_osf3.Si_sig = sws_osf3.Si_DN - (Si_dark*Si_dark_pins)./Si_dark_pin; 
sws_osf3.In_sig = sws_osf3.In_DN - (In_dark*InGaAs_dark_pins)./InGaAs_dark_pin; 
figure; lines = semilogy(sws_osf3.In_lambda, sws_osf3.In_sig(:,InGaAs_sub),'-'); recolor(lines,[1:length(InGaAs_sub)]);
title('SWS InGaAs dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(sws_osf3.Si_lambda, sws_osf3.Si_sig(:,Si_sub),'-'); recolor(lines,[1:length(Si_sub)]);
title('SWS Si dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
% linkaxes(axx,'x');
%%
% wl is wavelength array of length 1xN
% cts is array of detector cts of length [MxN]
[sws_osf3.scan_nm, sws_osf3.norm_peaks, sws_osf3.peaks] = mono_peaks([sws_osf3.Si_lambda',sws_osf3.In_lambda'],...
   [sws_osf3.Si_sig(:,Si_sub)', sws_osf3.In_sig(:,InGaAs_sub)']);

%%
monopeak.scan_nm = sws_osf3.scan_nm;
monopeak.norm_peaks = sws_osf3.norm_peaks;
monopeak.peaks = sws_osf3.peaks;
monopeak.Si_norm_peaks =sws_osf3.norm_peaks(:,1:256);
monopeak.InGaAs_norm_peaks =sws_osf3.norm_peaks(:,257:end);
monopeak.Si_nm = sws_osf3.Si_lambda;
monopeak.InGaAs_nm = sws_osf3.In_lambda;
%
Si_goodpix = ~isNaN(monopeak.Si_nm);
InGaAs_goodpix = ~isNaN(monopeak.InGaAs_nm);
figure; 
subplot(1,2,1);
imagesc(monopeak.Si_nm(Si_goodpix), monopeak.scan_nm, real(log10(monopeak.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CMOS normalized pixel response')
subplot(1,2,2);
imagesc(monopeak.InGaAs_nm(InGaAs_goodpix), monopeak.scan_nm, real(log10(monopeak.InGaAs_norm_peaks(:,InGaAs_goodpix))));;
axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
title('InGaAs normalized pixel response')
%%
save([sws_osf_path,filesep,'osf3_monopeak.mat'],'monopeak');

%% Now for osf4
% darks: sgpswscf.00.20090701.014627.raw.dat, 100, 35 ms
% osf4: 800-1300: sgpswscf.00.20090701.014747.raw.dat, as above, Si_osf4.fig InGaAs_osf4.fig
% osf5: 1300-2200: sgpswscf.00.20090701.015301.raw.dat, InGaAs_osf5.fig
% darks: sgpswscf.00.20090701.015724.raw.dat

dark1_name = 'sgpswscf.00.20090701.014627.raw.dat';
dark2_name = 'sgpswscf.00.20090701.015724.raw.dat';
osf4_name = 'sgpswscf.00.20090701.014747.raw.dat';

sws_dark = read_sws_raw([sws_osf_path,dark2_name]);
Si_sd = std(sws_dark.Si_DN(sws_dark.Si_lambda>800&sws_dark.Si_lambda<1000 ,:));
In_sd = std(sws_dark.In_DN(sws_dark.In_lambda>1400&sws_dark.In_lambda<1600,:));
%
figure; subplot(2,1,1)
plot(sws_dark.Si_lambda,[sws_dark.Si_DN],'-')
title(['Si darks'],'interp','none')
subplot(2,1,2); plot(sws_dark.In_lambda, sws_dark.In_DN, '-')
title(['InGaAS darks'],'interp','none')
figure; subplot(2,1,1);plot([1:length(sws_dark.time)],[Si_sd],'b-o');
lg = legend('std_dev(Si)');
set(lg,'interp','none')
title(['Si darks, stddev'],'interp','none')
subplot(2,1,2);plot([1:length(sws_dark.time)],[In_sd],'r-o');
title(['InGaAs darks, stddev'],'interp','none')
lg = legend('std_dev(InGaAs)');
set(lg,'interp','none')
%%
bad_Si = Si_sd > 3;
bad_In = In_sd > 250;
Si_dark = mean(sws_dark.Si_DN(:,~bad_Si),2);
In_dark = mean(sws_dark.In_DN(:,~bad_In),2);
%%

sws_osf4 = read_sws_raw([sws_osf_path,osf4_name]);
figure; subplot(2,1,1)
plot(sws_osf4.Si_lambda,[sws_osf4.Si_DN],'-')
title(['Si DN'],'interp','none')
subplot(2,1,2); plot(sws_osf4.In_lambda, sws_osf4.In_DN, '-')
title(['InGaAS DN'],'interp','none')
%%
%use region from 300-400 nm as dark scaling region for CMOS
Si_bot = 400; Si_top = 500;
%use region from 1800-1860 nm as dark scaling region for CMOS
In_bot = 1800; In_top = 20000;
InGaAs_dark_pin = mean(In_dark(sws_dark.In_lambda>In_bot & sws_dark.In_lambda<In_top));
InGaAs_dark_pins =mean(sws_osf4.In_DN((sws_osf4.In_lambda>In_bot & sws_osf4.In_lambda<In_top),:),1);
Si_dark_pin = mean(Si_dark(sws_dark.Si_lambda>Si_bot & sws_dark.Si_lambda<Si_top));
Si_dark_pins =mean(sws_osf4.Si_DN((sws_osf4.Si_lambda>Si_bot & sws_osf4.Si_lambda<Si_top),:),1);

%%
start_pt = 1;
[tmp,InGaAs_peak] = max(sws_osf4.In_DN,[],1);
[tmp,Si_peak] = max(sws_osf4.Si_DN,[],1);
figure; plot([start_pt:length(sws_osf4.In_ms)],InGaAs_peak+start_pt-1,'-bx',[start_pt:length(sws_osf4.Si_ms)],Si_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%
figure; plot([start_pt:length(sws_osf4.In_ms)],sws_osf4.In_lambda(InGaAs_peak),'-bx',[start_pt:length(sws_osf4.Si_ms)],sws_osf4.Si_lambda(Si_peak),'-ro');

title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
%%
InGaAs_sub = [11:129];
Si_sub = [11:129];
sws_osf4.InGaAs_sub = InGaAs_sub;
sws_osf4.Si_sub = Si_sub;

%%
sws_osf4.Si_sig = sws_osf4.Si_DN - (Si_dark*Si_dark_pins)./Si_dark_pin; 
sws_osf4.In_sig = sws_osf4.In_DN - (In_dark*InGaAs_dark_pins)./InGaAs_dark_pin; 
figure; lines = semilogy(sws_osf4.In_lambda, sws_osf4.In_sig(:,InGaAs_sub),'-'); recolor(lines,[1:length(InGaAs_sub)]);
title('SWS InGaAs dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(sws_osf4.Si_lambda, sws_osf4.Si_sig(:,Si_sub),'-'); recolor(lines,[1:length(Si_sub)]);
title('SWS Si dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
% linkaxes(axx,'x');
%%
% wl is wavelength array of length 1xN
% cts is array of detector cts of length [MxN]
[sws_osf4.scan_nm, sws_osf4.norm_peaks, sws_osf4.peaks] = mono_peaks([sws_osf4.Si_lambda',sws_osf4.In_lambda'],...
   [sws_osf4.Si_sig(:,Si_sub)', sws_osf4.In_sig(:,InGaAs_sub)']);

%%
monopeak.scan_nm = sws_osf4.scan_nm;
monopeak.norm_peaks = sws_osf4.norm_peaks;
monopeak.peaks = sws_osf4.peaks;
monopeak.Si_norm_peaks =sws_osf4.norm_peaks(:,1:256);
monopeak.InGaAs_norm_peaks =sws_osf4.norm_peaks(:,257:end);
monopeak.Si_nm = sws_osf4.Si_lambda;
monopeak.InGaAs_nm = sws_osf4.In_lambda;
%
Si_goodpix = ~isNaN(monopeak.Si_nm);
InGaAs_goodpix = ~isNaN(monopeak.InGaAs_nm);
figure; 
subplot(1,2,1);
imagesc(monopeak.Si_nm(Si_goodpix), monopeak.scan_nm, real(log10(monopeak.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CMOS normalized pixel response')
subplot(1,2,2);
imagesc(monopeak.InGaAs_nm(InGaAs_goodpix), monopeak.scan_nm, real(log10(monopeak.InGaAs_norm_peaks(:,InGaAs_goodpix))));;
axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
title('InGaAs normalized pixel response')
%%
save([sws_osf_path,filesep,'osf4_monopeak.mat'],'monopeak');
%% Now for osf5
% darks: sgpswscf.00.20090701.014627.raw.dat, 100, 35 ms
% osf4: 800-1300: sgpswscf.00.20090701.014747.raw.dat, as above, Si_osf4.fig InGaAs_osf4.fig
% osf5: 1300-2200: sgpswscf.00.20090701.015301.raw.dat, InGaAs_osf5.fig
% darks: sgpswscf.00.20090701.015724.raw.dat

dark1_name = 'sgpswscf.00.20090701.014627.raw.dat';
dark2_name = 'sgpswscf.00.20090701.015724.raw.dat';
osf5_name = 'sgpswscf.00.20090701.015301.raw.dat';

sws_dark = read_sws_raw([sws_osf_path,dark2_name]);
Si_sd = std(sws_dark.Si_DN(sws_dark.Si_lambda>800&sws_dark.Si_lambda<1000 ,:));
In_sd = std(sws_dark.In_DN(sws_dark.In_lambda>1400&sws_dark.In_lambda<1600,:));
%
figure; subplot(2,1,1)
plot(sws_dark.Si_lambda,[sws_dark.Si_DN],'-')
title(['Si darks'],'interp','none')
subplot(2,1,2); plot(sws_dark.In_lambda, sws_dark.In_DN, '-')
title(['InGaAS darks'],'interp','none')
figure; subplot(2,1,1);plot([1:length(sws_dark.time)],[Si_sd],'b-o');
lg = legend('std_dev(Si)');
set(lg,'interp','none')
title(['Si darks, stddev'],'interp','none')
subplot(2,1,2);plot([1:length(sws_dark.time)],[In_sd],'r-o');
title(['InGaAs darks, stddev'],'interp','none')
lg = legend('std_dev(InGaAs)');
set(lg,'interp','none')
%%
bad_Si = Si_sd > 3;
bad_In = In_sd > 250;
Si_dark = mean(sws_dark.Si_DN(:,~bad_Si),2);
In_dark = mean(sws_dark.In_DN(:,~bad_In),2);
%%

sws_osf5 = read_sws_raw([sws_osf_path,osf5_name]);
figure; subplot(2,1,1)
plot(sws_osf5.Si_lambda,[sws_osf5.Si_DN],'-')
title(['Si DN'],'interp','none')
subplot(2,1,2); plot(sws_osf5.In_lambda, sws_osf5.In_DN, '-')
title(['InGaAS DN'],'interp','none')
%%
%use region from 300-400 nm as dark scaling region for CMOS
Si_bot = 400; Si_top = 500;
%use region from 1800-1860 nm as dark scaling region for CMOS
In_bot = 1000; In_top = 1200;
InGaAs_dark_pin = mean(In_dark(sws_dark.In_lambda>In_bot & sws_dark.In_lambda<In_top));
InGaAs_dark_pins =mean(sws_osf5.In_DN((sws_osf5.In_lambda>In_bot & sws_osf5.In_lambda<In_top),:),1);
Si_dark_pin = mean(Si_dark(sws_dark.Si_lambda>Si_bot & sws_dark.Si_lambda<Si_top));
Si_dark_pins =mean(sws_osf5.Si_DN((sws_osf5.Si_lambda>Si_bot & sws_osf5.Si_lambda<Si_top),:),1);

%%
start_pt = 1;
[tmp,InGaAs_peak] = max(sws_osf5.In_DN,[],1);
[tmp,Si_peak] = max(sws_osf5.Si_DN,[],1);
figure; plot([start_pt:length(sws_osf5.In_ms)],InGaAs_peak+start_pt-1,'-bx',[start_pt:length(sws_osf5.Si_ms)],Si_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%
figure; plot([start_pt:length(sws_osf5.In_ms)],sws_osf5.In_lambda(InGaAs_peak),'-bx',[start_pt:length(sws_osf5.Si_ms)],sws_osf5.Si_lambda(Si_peak),'-ro');

title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
%%
InGaAs_sub = [11:210];
Si_sub = [11:210];
sws_osf5.InGaAs_sub = InGaAs_sub;
sws_osf5.Si_sub = Si_sub;

%%
sws_osf5.Si_sig = sws_osf5.Si_DN - (Si_dark*Si_dark_pins)./Si_dark_pin; 
sws_osf5.In_sig = sws_osf5.In_DN - (In_dark*InGaAs_dark_pins)./InGaAs_dark_pin; 
figure; lines = semilogy(sws_osf5.In_lambda, sws_osf5.In_sig(:,InGaAs_sub),'-'); recolor(lines,[1:length(InGaAs_sub)]);
title('SWS InGaAs dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(sws_osf5.Si_lambda, sws_osf5.Si_sig(:,Si_sub),'-'); recolor(lines,[1:length(Si_sub)]);
title('SWS Si dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
% linkaxes(axx,'x');
%%
% wl is wavelength array of length 1xN
% cts is array of detector cts of length [MxN]
[sws_osf5.scan_nm, sws_osf5.norm_peaks, sws_osf5.peaks] = mono_peaks([sws_osf5.Si_lambda',sws_osf5.In_lambda'],...
   [sws_osf5.Si_sig(:,Si_sub)', sws_osf5.In_sig(:,InGaAs_sub)']);

%%
monopeak.scan_nm = sws_osf5.scan_nm;
monopeak.norm_peaks = sws_osf5.norm_peaks;
monopeak.peaks = sws_osf5.peaks;
monopeak.Si_norm_peaks =sws_osf5.norm_peaks(:,1:256);
monopeak.InGaAs_norm_peaks =sws_osf5.norm_peaks(:,257:end);
monopeak.Si_nm = sws_osf5.Si_lambda;
monopeak.InGaAs_nm = sws_osf5.In_lambda;
%
Si_goodpix = ~isNaN(monopeak.Si_nm);
InGaAs_goodpix = ~isNaN(monopeak.InGaAs_nm);
figure; 
subplot(1,2,1);
imagesc(monopeak.Si_nm(Si_goodpix), monopeak.scan_nm, real(log10(monopeak.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CMOS normalized pixel response')
subplot(1,2,2);
imagesc(monopeak.InGaAs_nm(InGaAs_goodpix), monopeak.scan_nm, real(log10(monopeak.InGaAs_norm_peaks(:,InGaAs_goodpix))));;
axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
title('InGaAs normalized pixel response')
%%
save([sws_osf_path,filesep,'osf5_monopeak.mat'],'monopeak');
%%
clear; close('all')

osf1 = loadinto(['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\osf1_monopeak.mat']);
osf2 = loadinto(['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\osf2_monopeak.mat']);
osf3 = loadinto(['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\osf3_monopeak.mat']);
osf4 = loadinto(['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\osf4_monopeak.mat']);
osf5 = loadinto(['C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\sws\osf5_monopeak.mat']);
%%
% For Si
Si_goodpix = ~isNaN(osf1.Si_nm);
figure; 
imagesc(osf1.Si_nm(Si_goodpix), osf1.scan_nm, real(log10(osf1.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS Si OSF1 normalized pixel response');

Si_goodpix = ~isNaN(osf2.Si_nm);
figure; 
imagesc(osf2.Si_nm(Si_goodpix), osf2.scan_nm, real(log10(osf2.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS Si osf2 normalized pixel response');

Si_goodpix = ~isNaN(osf3.Si_nm);
figure; 
imagesc(osf3.Si_nm(Si_goodpix), osf3.scan_nm, real(log10(osf3.Si_norm_peaks(:,Si_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS Si osf3 normalized pixel response');

%%
% osf1,osf2,osf3 each contain Si data to be concatenated
% stitch 1 and 2 at 645 nm
osf1_top = find(osf1.scan_nm>645,1,'first')-1;
osf2_bot = find(osf2.scan_nm>=645,1,'first');
% stitch 2 and 3 at 800 nm
osf2_top = find(osf2.scan_nm>800,1,'first')-1;
osf3_bot = find(osf3.scan_nm>=800,1,'first');

Si_goodpix = ~isNaN(osf1.Si_nm);
figure; 
imagesc(osf1.Si_nm(Si_goodpix), [osf1.scan_nm(1:osf1_top),osf2.scan_nm(osf2_bot:osf2_top),osf3.scan_nm(osf3_bot:end)], ...
   real(log10([osf1.Si_norm_peaks(1:osf1_top,Si_goodpix);osf2.Si_norm_peaks(osf2_bot:osf2_top,Si_goodpix);...
   ;osf3.Si_norm_peaks(osf3_bot:end,Si_goodpix)])));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]', 'fontname','Tahoma','fontweight','bold');
ylabel('scan wavelength [nm]', 'fontname','Tahoma','fontweight','bold');
title('SWS Si normalized pixel response', 'fontname','Tahoma','fontweight','bold');
%%
% For InGaAs
In_goodpix = ~isNaN(osf3.InGaAs_nm);
figure; 
imagesc(osf3.InGaAs_nm(In_goodpix), osf3.scan_nm, real(log10(osf3.InGaAs_norm_peaks(:,In_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS InGaAs OSF3 normalized pixel response');

In_goodpix = ~isNaN(osf4.InGaAs_nm);
figure; 
imagesc(osf4.InGaAs_nm(In_goodpix), osf4.scan_nm, real(log10(osf4.InGaAs_norm_peaks(:,In_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS InGaAs OSF4 normalized pixel response');

In_goodpix = ~isNaN(osf5.InGaAs_nm);
figure; 
imagesc(osf5.InGaAs_nm(In_goodpix), osf5.scan_nm, real(log10(osf5.InGaAs_norm_peaks(:,In_goodpix))));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS InGaAs OSF5 normalized pixel response');

%%
% osf3,osf4,osf5 each contain InGaAs data to be concatenated
% stitch 3 and 4 at 850 nm
osf3_bot = find(osf3.scan_nm>800,1,'first')-1;
osf3_top = find(osf3.scan_nm>850,1,'first')-1;
osf4_bot = find(osf4.scan_nm>=850,1,'first');
% stitch 2 and 3 at 800 nm
osf4_top = find(osf4.scan_nm>1300,1,'first')-1;
osf5_bot = find(osf5.scan_nm>=1300,1,'first');

In_goodpix = ~isNaN(osf3.InGaAs_nm);
figure; 
imagesc(osf3.InGaAs_nm(In_goodpix), [osf3.scan_nm(osf3_bot:3:osf3_top),osf4.scan_nm(osf4_bot:osf4_top),osf5.scan_nm(osf5_bot:end)], ...
   real(log10([osf3.InGaAs_norm_peaks(osf3_bot:3:osf3_top,In_goodpix);osf4.InGaAs_norm_peaks(osf4_bot:osf4_top,In_goodpix);...
   ;osf5.InGaAs_norm_peaks(osf5_bot:end,In_goodpix)])));
axis('xy') ; 
caxis([-5,.1]);
xlabel('pixel wavelength [nm]');
ylabel('scan wavelength [nm]');
title('SWS InGaAs osf3-3 normalized pixel response');