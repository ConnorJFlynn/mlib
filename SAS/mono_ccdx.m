% ava ccd monoscans
% Okay, the idea is to manually load the darks and mono scan.
% subtract scaled darks
% Manually subset the scan
% use monoscan_27 logic to identify peaks.
% 

ccd_OSF1_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF1\2048\darks\';
ccd_osf1_dark = loadinto([ccd_OSF1_dark_path ,'CCD_OSF1_5068.trt.mat']);
ccdx_OSF1_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF1\2048X14\darks\';
ccdx_osf1_dark = loadinto([ccdx_OSF1_dark_path ,'CCD_OSF1_5069.trt.mat']);
%%
figure
lines = plot(ccdx_osf1_dark.nm, ccdx_osf1_dark.Sample,'-');
ccdx_osf1_darks = mean(ccdx_osf1_dark.Sample(2:3,:),1);
ccdx_osf1_darks = ccdx_osf1_dark.Sample(1,:);
%%
lines = plot(ccd_osf1_dark.nm, ccd_osf1_dark.Sample(2:3,:),'-');
ccd_osf1_darks = mean(ccd_osf1_dark.Sample(2:3,:),1);
%%
ccd_OSF1_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF1\2048\';
ccd_osf1 = loadinto([ccd_OSF1_path ,'CCD_OSF1_5065.trt.mat']);
ccdx_OSF1_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF1\2048X14\';
ccdx_osf1 = loadinto([ccdx_OSF1_path,'CCD_OSF1_5064.trt.mat']);

%%
start_pt = 1;
end_pt = 500;

figure; lines = semilogy(ccd_osf1.nm, ccd_osf1.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccd_osf1.tint)]); 
colorbar
title(['CCD OSF1 : start_pt',num2str(start_pt)],'interp','none');

figure; lines = semilogy(ccdx_osf1.nm, ccdx_osf1.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccdx_osf1.tint)]); 
colorbar
title(['CCDX OSF1 : start_pt',num2str(start_pt)],'interp','none');
%%

[tmp,ccd_peak] = max(ccd_osf1.Sample(start_pt:end,:),[],2);
[tmp,ccdx_peak] = max(ccdx_osf1.Sample(start_pt:end,:),[],2);
figure; plot([start_pt:length(ccd_osf1.tint)],ccd_peak+start_pt,'-bx',[start_pt:length(ccdx_osf1.tint)],ccdx_peak+start_pt,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%%
figure; plot([start_pt:length(ccd_osf1.tint)],ccd_osf1.nm(ccd_peak),'-bx',[start_pt:length(ccdx_osf1.tint)],ccdx_osf1.nm(ccdx_peak),'-ro');
title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% four sections.
% ccd [1:212, 230:1050, 1064:1920 1932:2490]


% ccdx [1:227, 228:1050, 1080:1920 1948:2550]
%%

ccd_a = [1:212];ccd_b = [230:1050];ccd_c = [1064:1920]; ccd_d = [1932:2490];
ccdx_a = [1:227];ccdx_b = [228:1050];ccdx_c = [1080:1920];ccdx_d = [1948:2550];
%
%%
% restrict long wavelength ends to 680 nm to prevent 2nd order effects
ccd_a = [1:212];ccd_b = [230:979];ccd_c = [1064:1854]; ccd_d = [1932:2490];
ccdx_a = [1:227];ccdx_b = [228:965];ccdx_c = [1080:1839];ccdx_d = [1948:2550];
%

% Let's look at 2nd section

figure; lines = semilogy(ccd_osf1.nm, ccd_osf1.Sample(ccd_b,:),'-'); recolor(lines,[ccd_b]); 
colorbar
title(['CCD OSF1 b: [',num2str(ccd_b(1)),':',num2str(ccd_b(end)),']'],'interp','none');
ax(1) = gca;

figure; lines = semilogy(ccdx_osf1.nm, ccdx_osf1.Sample(ccdx_b,:),'-'); recolor(lines,[ccdx_b]); 
colorbar
title(['CCDX OSF1 b: [',num2str(ccdx_b(1)),':',num2str(ccdx_b(end)),']'],'interp','none');
ax(2) = gca;
linkaxes(ax,'x')
%%
figure;
plot(ccd_b,mean(ccd_osf1.Sample(ccd_b,ccd_osf1.nm>275&ccd_osf1.nm<325),2),'o')
%%
%use region from 280-340 nm as dark scaling region
ccd_dark_pin = mean(ccd_osf1_darks(ccd_osf1.nm>280 & ccd_osf1.nm<340));
ccd_dark_pins =(mean(ccd_osf1.Sample(ccd_b,ccd_osf1.nm>280 & ccd_osf1.nm<340),2));
ccdx_dark_pin = mean(ccdx_osf1_darks(ccdx_osf1.nm>280 & ccdx_osf1.nm<340));
ccdx_dark_pins =(mean(ccdx_osf1.Sample(ccdx_b,ccdx_osf1.nm>280 & ccdx_osf1.nm<340),2));

ccd_osf1.darks = ccd_osf1_darks;
ccd_osf1.dark_pin = ccd_dark_pin;
ccd_osf1.dark_pins_b = ccd_dark_pins;


ccdx_osf1.darks = ccdx_osf1_darks;
ccdx_osf1.dark_pin = ccdx_dark_pin;
ccdx_osf1.dark_pins_b = ccdx_dark_pins;
%%

ccd_osf1.less_dark_b = ccd_osf1.Sample(ccd_b,:) - ((ccd_osf1.dark_pin./ccd_osf1.dark_pins_b)*ccd_osf1.darks);
ccdx_osf1.less_dark_b = ccdx_osf1.Sample(ccdx_b,:) - ((ccdx_osf1.dark_pin./ccdx_osf1.dark_pins_b)*ccdx_osf1.darks);
figure; lines = semilogy(ccd_osf1.nm, ccd_osf1.less_dark_b,'-'); recolor(lines,[1:length(ccd_b)]);
title('CCD b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(ccdx_osf1.nm, ccdx_osf1.less_dark_b,'-'); recolor(lines,[1:length(ccdx_b)]);
title('CCDX b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
linkaxes(axx,'x');
%%

[ccd_osf1.scan_nm, ccd_osf1.norm_peaks, ccd_osf1.peaks] = mono_peaks(ccd_osf1.nm, ccd_osf1.less_dark_b);
good_pix = ~isNaN(ccd_osf1.nm);
figure; imagesc(ccd_osf1.nm(good_pix), ccd_osf1.scan_nm, real(log10(ccd_osf1.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCD normalized pixel response')

%%

[ccdx_osf1.scan_nm, ccdx_osf1.norm_peaks, ccdx_osf1.peaks] = mono_peaks(ccdx_osf1.nm, ccdx_osf1.less_dark_b);
%%
good_pix = ~isNaN(ccd_osf1.nm);
figure; imagesc(ccdx_osf1.nm(good_pix), ccdx_osf1.scan_nm, real(log10(ccdx_osf1.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCDX normalized pixel response')
%%
%% Now for OSF2 CCD and CCDX

ccd_OSF2_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF2\2048\darks\';
ccd_osf2_dark = loadinto([ccd_OSF2_dark_path ,'CCD_OSF22005.trt.mat']);
ccdx_OSF2_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF2\2048X14\darks\';
ccdx_osf2_dark = loadinto([ccdx_OSF2_dark_path ,'CCD_OSF22006.trt.mat']);
%%
figure
lines = semilogy(ccdx_osf2_dark.nm, ccdx_osf2_dark.Sample(:,:),'-');
ccdx_osf2_darks = mean(ccdx_osf2_dark.Sample(1:2,:),1);
ccdx_osf2_darks = ccdx_osf2_dark.Sample(2,:);

%%
lines = plot(ccd_osf2_dark.nm, ccd_osf2_dark.Sample(1:2,:),'-');
ccd_osf2_darks = mean(ccd_osf2_dark.Sample(1:2,:),1);
%%
ccd_OSF2_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF2\2048\';
ccd_osf2 = loadinto([ccd_OSF2_path ,'CCD_OSF22004.trt.mat']);
ccdx_OSF2_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF2\2048X14\';
ccdx_osf2 = loadinto([ccdx_OSF2_path,'CCD_OSF22003.trt.mat']);

%%
start_pt = 5;

figure; lines = semilogy(ccd_osf2.nm, ccd_osf2.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccd_osf2.tint)]); 
colorbar
title(['CCD OSF2 : start_pt',num2str(start_pt)],'interp','none');
%%

figure; lines = semilogy(ccdx_osf2.nm, ccdx_osf2.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccdx_osf2.tint)]); 
colorbar
% hold('on')
% semilogy(ccdx_osf2.nm, ccdx_osf2_dark.Sample(1:2,:),'k-')
% hold('off')
title(['CCDX OSF2 : start_pt',num2str(start_pt)],'interp','none');
%%

[tmp,ccd_peak] = max(ccd_osf2.Sample(start_pt:end,:),[],2);
[tmp,ccdx_peak] = max(ccdx_osf2.Sample(start_pt:end,:),[],2);
figure; plot([start_pt:length(ccd_osf2.tint)],ccd_peak+start_pt-1,'-bx',[start_pt:length(ccdx_osf2.tint)],ccdx_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
%%
figure; plot([start_pt:length(ccd_osf2.tint)],ccd_osf2.nm(ccd_peak),'-bx',[start_pt:length(ccdx_osf2.tint)],ccdx_osf2.nm(ccdx_peak),'-ro');
title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
%%
% one sections.

ccd_b = [5:1000];
ccdx_b = [5:1000];
%

% Let's look at 2nd section

figure; lines = semilogy(ccd_osf2.nm, ccd_osf2.Sample(ccd_b,:),'-'); recolor(lines,[ccd_b]); 
colorbar
title(['CCD OSF2 b: [',num2str(ccd_b(1)),':',num2str(ccd_b(end)),']'],'interp','none');
ax(1) = gca;
%%
figure; lines = semilogy(ccdx_osf2.nm, ccdx_osf2.Sample(ccdx_b,:),'-'); recolor(lines,[ccdx_b]); 
colorbar
title(['CCDX OSF2 b: [',num2str(ccdx_b(1)),':',num2str(ccdx_b(end)),']'],'interp','none');
ax(2) = gca;
%%
linkaxes(ax,'x')
%%
figure;
plot(ccd_b,mean(ccd_osf2.Sample(ccd_b,ccd_osf2.nm>275&ccd_osf2.nm<325),2),'o')
%%
%use region from 280-340 nm as dark scaling region
ccd_dark_pin = mean(ccd_osf2_darks(ccd_osf2.nm>280 & ccd_osf2.nm<340));
ccd_dark_pins =(mean(ccd_osf2.Sample(ccd_b,ccd_osf2.nm>280 & ccd_osf2.nm<340),2));
ccdx_dark_pin = mean(ccdx_osf2_darks(ccdx_osf2.nm>280 & ccdx_osf2.nm<340));
ccdx_dark_pins =(mean(ccdx_osf2.Sample(ccdx_b,ccdx_osf2.nm>280 & ccdx_osf2.nm<340),2));

ccd_osf2.darks = ccd_osf2_darks;
ccd_osf2.dark_pin = ccd_dark_pin;
ccd_osf2.dark_pins_b = ccd_dark_pins;


ccdx_osf2.darks = ccdx_osf2_darks;
ccdx_osf2.dark_pin = ccdx_dark_pin;
ccdx_osf2.dark_pins_b = ccdx_dark_pins;
%%
ccd_osf2.less_dark_b = ccd_osf2.Sample(ccd_b,:) - ((ccd_osf2.dark_pin./ccd_osf2.dark_pins_b)*ccd_osf2.darks);
ccdx_osf2.less_dark_b = ccdx_osf2.Sample(ccdx_b,:) - ((ccdx_osf2.dark_pin./ccdx_osf2.dark_pins_b)*ccdx_osf2.darks);
figure; lines = semilogy(ccd_osf2.nm, ccd_osf2.less_dark_b,'-'); recolor(lines,[1:length(ccd_b)]);
title('CCD b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(ccdx_osf2.nm, ccdx_osf2.less_dark_b,'-'); recolor(lines,[1:length(ccdx_b)]);
title('CCDX b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
linkaxes(axx,'x');
%%

[ccd_osf2.scan_nm, ccd_osf2.norm_peaks, ccd_osf2.peaks] = mono_peaks(ccd_osf2.nm, ccd_osf2.less_dark_b);
good_pix = ~isNaN(ccd_osf2.nm);
figure; imagesc(ccd_osf2.nm(good_pix), ccd_osf2.scan_nm, real(log10(ccd_osf2.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCD normalized pixel response')

%%

[ccdx_osf2.scan_nm, ccdx_osf2.norm_peaks, ccdx_osf2.peaks] = mono_peaks(ccdx_osf2.nm, [ccdx_osf2.less_dark_b]);
good_pix = ~isNaN(ccdx_osf2.nm);
figure; imagesc(ccdx_osf2.nm(good_pix), ccdx_osf2.scan_nm, real(log10(ccdx_osf2.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCDX normalized pixel response')
%%

%% Now for OSF3 CCD and CCDX

ccd_OSF3_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF3\2048\darks\';
ccd_osf3_dark = loadinto([ccd_OSF3_dark_path ,'CCD_OSF3_2436.trt.mat']);
ccdx_OSF3_dark_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_OSF3\2048X14\darks\';
ccdx_osf3_dark = loadinto([ccdx_OSF3_dark_path ,'CCD_OSF3_2437.trt.mat']);
%%
figure
lines = semilogy(ccdx_osf3_dark.nm, ccdx_osf3_dark.Sample(2:end,:),'-');
ccdx_osf3_darks = mean(ccdx_osf3_dark.Sample(1:2,:),1);
% ccdx_osf3_darks = ccdx_osf3_dark.Sample(2,:);

%%
lines = plot(ccd_osf3_dark.nm, ccd_osf3_dark.Sample(2:end,:),'-');
ccd_osf3_darks = mean(ccd_osf3_dark.Sample(2:end,:),1);
%%
ccd_osf3_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_osf3\2048\';
ccd_osf3 = loadinto([ccd_osf3_path ,'CCD_OSF3_2434.trt.mat']);
ccdx_osf3_path = 'C:\case_studies\ARRA\SAS\Spex\Ames\2009_06_30_Tue\monoscans\CCD_CCDx\CCD_osf3\2048X14\';
ccdx_osf3 = loadinto([ccdx_osf3_path,'CCD_OSF3_2435.trt.mat']);

%%
start_pt = 2;

figure; lines = semilogy(ccd_osf3.nm, ccd_osf3.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccd_osf3.tint)]); 
colorbar
title(['CCD osf3 : start_pt',num2str(start_pt)],'interp','none');
%%

figure; lines = semilogy(ccdx_osf3.nm, ccdx_osf3.Sample(start_pt:end,:),'-'); recolor(lines,[start_pt:length(ccdx_osf3.tint)]); 
colorbar
% hold('on')
% semilogy(ccdx_osf3.nm, ccdx_osf3_dark.Sample(1:2,:),'k-')
% hold('off')
title(['CCDX osf3 : start_pt',num2str(start_pt)],'interp','none');
%%

[tmp,ccd_peak] = max(ccd_osf3.Sample(start_pt:end,:),[],2);
[tmp,ccdx_peak] = max(ccdx_osf3.Sample(start_pt:end,:),[],2);
figure; plot([start_pt:length(ccd_osf3.tint)],ccd_peak+start_pt-1,'-bx',[start_pt:length(ccdx_osf3.tint)],ccdx_peak+start_pt-1,'-ro');
title('record number versus peak pixel location')
ylabel('peak location [pixel]');
xlabel('record number');
% CCD last good record, 1080
% CCDX last good record, 1194 or 1202 (up, down, and up again)
%%
figure; plot([start_pt:length(ccd_osf3.tint)],ccd_osf3.nm(ccd_peak),'-bx',[start_pt:length(ccdx_osf3.tint)],ccdx_osf3.nm(ccdx_peak),'-ro');
title('record number versus peak wavelength')
ylabel('wavelength [nm]');
xlabel('record number');
% CCD last good record, 1100.5 nm
% CCDX last good record, 1150 or 1155 (up, down, and up again)
%%
% one sections.

ccd_b = [2:1080];
ccdx_b = [2:1202];
%

% Let's look at 2nd section

figure; lines = semilogy(ccd_osf3.nm, ccd_osf3.Sample(ccd_b,:),'-'); recolor(lines,[ccd_b]); 
colorbar
title(['CCD osf3 b: [',num2str(ccd_b(1)),':',num2str(ccd_b(end)),']'],'interp','none');
ax(1) = gca;
%%
figure; lines = semilogy(ccdx_osf3.nm, ccdx_osf3.Sample(ccdx_b,:),'-'); recolor(lines,[ccdx_b]); 
colorbar
title(['CCDX osf3 b: [',num2str(ccdx_b(1)),':',num2str(ccdx_b(end)),']'],'interp','none');
ax(2) = gca;
%%
linkaxes(ax,'x')
%%
figure;
plot(ccd_b,mean(ccd_osf3.Sample(ccd_b,ccd_osf3.nm>275&ccd_osf3.nm<325),2),'o')
%%
%use region from 280-340 nm as dark scaling region
ccd_dark_pin = mean(ccd_osf3_darks(ccd_osf3.nm>280 & ccd_osf3.nm<340));
ccd_dark_pins =(mean(ccd_osf3.Sample(ccd_b,ccd_osf3.nm>280 & ccd_osf3.nm<340),2));
ccdx_dark_pin = mean(ccdx_osf3_darks(ccdx_osf3.nm>280 & ccdx_osf3.nm<340));
ccdx_dark_pins =(mean(ccdx_osf3.Sample(ccdx_b,ccdx_osf3.nm>280 & ccdx_osf3.nm<340),2));

ccd_osf3.darks = ccd_osf3_darks;
ccd_osf3.dark_pin = ccd_dark_pin;
ccd_osf3.dark_pins_b = ccd_dark_pins;


ccdx_osf3.darks = ccdx_osf3_darks;
ccdx_osf3.dark_pin = ccdx_dark_pin;
ccdx_osf3.dark_pins_b = ccdx_dark_pins;
%%
ccd_osf3.less_dark_b = ccd_osf3.Sample(ccd_b,:) - ((ccd_osf3.dark_pin./ccd_osf3.dark_pins_b)*ccd_osf3.darks);
ccdx_osf3.less_dark_b = ccdx_osf3.Sample(ccdx_b,:) - ((ccdx_osf3.dark_pin./ccdx_osf3.dark_pins_b)*ccdx_osf3.darks);
figure; lines = semilogy(ccd_osf3.nm, ccd_osf3.less_dark_b,'-'); recolor(lines,[1:length(ccd_b)]);
title('CCD b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');
axx(1) = gca;
figure; lines = semilogy(ccdx_osf3.nm, ccdx_osf3.less_dark_b,'-'); recolor(lines,[1:length(ccdx_b)]);
title('CCDX b dark-subtracted');
xlabel('wavelength [nm]');
ylabel('cts - dark');

axx(2) = gca;
linkaxes(axx,'x');
%%

[ccd_osf3.scan_nm, ccd_osf3.norm_peaks, ccd_osf3.peaks] = mono_peaks(ccd_osf3.nm, ccd_osf3.less_dark_b);
good_pix = ~isNaN(ccd_osf3.nm);
figure; imagesc(ccd_osf3.nm(good_pix), ccd_osf3.scan_nm, real(log10(ccd_osf3.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCD normalized pixel response')

%%

[ccdx_osf3.scan_nm, ccdx_osf3.norm_peaks, ccdx_osf3.peaks] = mono_peaks(ccdx_osf3.nm, [ccdx_osf3.less_dark_b]);
good_pix = ~isNaN(ccdx_osf3.nm);
figure; imagesc(ccdx_osf3.nm(good_pix), ccdx_osf3.scan_nm, real(log10(ccdx_osf3.norm_peaks(:,good_pix)))); axis('xy') ; colorbar
caxis([-5,.1]);
xlabel('pixel wavelength [nm]')
ylabel('scan wavelength [nm]')
title('CCDX normalized pixel response')
%%

%%

% combine post mono_peak images
top = interp1(ccdx_osf3.scan_nm, [1:length(ccdx_osf3.scan_nm)],ccdx_osf1.scan_nm(end),'nearest')+1;
figure; imagesc(ccdx_osf3.nm(good_pix), [ccdx_osf1.scan_nm, ccdx_osf3.scan_nm(top:end)], real(log10([ccdx_osf1.norm_peaks(:,good_pix); ccdx_osf3.norm_peaks(top:end,good_pix)]))); axis('xy') ; colorbar;

