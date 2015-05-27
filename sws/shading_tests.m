% Load sws file, determine darks, subtract them from entire time series.
% Plot spectra vs time to observe shading. 
% Create "shaded" logical
% Plot unshaded vs shaded. 

% Shading times GMT, 2008-12-11
% 1530-1532
% 1628-1630
% 1730-1732
% 1830-1832

% File #1: shading
%% load an rss file so we have lat and lon.
rss = ancload;
%%
sws_1 = read_sws_raw;% 1530-1532
%%

sws_1 = cat_sws_raw(read_sws_raw,sws_1);

%%
[sws_1.zen, az, soldst, ha_next, dec, el, am] = sunae(rss.vars.lat.data, rss.vars.lon.data, (sws_1.time));
sws_1.Si_dark = mean(sws_1.Si_DN(:,sws_1.shutter==1),2);
sws_1.In_dark = mean(sws_1.In_DN(:,sws_1.shutter==1),2);

sws_1.Si_cps = (sws_1.Si_DN - (sws_1.Si_dark*ones(size(sws_1.time))))./(ones(size(sws_1.Si_lambda))*sws_1.Si_ms);
sws_1.In_cps = (sws_1.In_DN - (sws_1.In_dark*ones(size(sws_1.time))))./(ones(size(sws_1.In_lambda))*sws_1.In_ms);
figure; subplot(2,1,1); plot(serial2Hh(sws_1.time(sws_1.shutter==0)),sws_1.Si_cps(150,sws_1.shutter==0),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_1.zen))]);
legend('800 nm');
xlabel('time (UTC)')
yl = ylim;
subplot(2,1,2); plot([1:length(sws_1.time)],sws_1.Si_cps(150,:),'.-');
ylim(yl);
xlabel('record number');
%%
figure; 
%
clear ax
ax(1) = subplot(2,1,1); plot((sws_1.time(sws_1.shutter==0)),sws_1.Si_cps([60,95,147],(sws_1.shutter==0)),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_1.zen))]);
legend(sprintf('%1.f nm',sws_1.Si_lambda(60)),sprintf('%1.f nm',sws_1.Si_lambda(95)),sprintf('%1.f nm',sws_1.Si_lambda(147)));
xlabel('time (UTC)')
ylabel('counts/ms')
datetick('keeplimits')
yl = ylim;
ax(2) = subplot(2,1,2); plot((sws_1.time(sws_1.shutter==0)),sws_1.In_cps([17,60,125,230],(sws_1.shutter==0)),'.-');
legend(sprintf('%1.f nm',sws_1.In_lambda(17)),sprintf('%1.f nm',sws_1.In_lambda(60)),...
   sprintf('%1.f nm',sws_1.In_lambda(125)),sprintf('%1.f nm',sws_1.In_lambda(230)));
xlabel('time (UTC)')
ylabel('counts/ms')
datetick('keeplimits')
linkaxes(ax,'x')
%%
datetick(ax(1),'keeplimits');
datetick(ax(2),'keeplimits');
%%
figure; 
%
clear ax
ax(1) = subplot(2,1,1); plot([1:length(sws_1.time(sws_1.shutter==0))],sws_1.Si_cps([60,95,147],(sws_1.shutter==0)),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_1.zen))]);
legend(sprintf('%1.f nm',sws_1.Si_lambda(60)),sprintf('%1.f nm',sws_1.Si_lambda(95)),sprintf('%1.f nm',sws_1.Si_lambda(147)));
xlabel('record number')
ylabel('counts/ms')
yl = ylim;
ax(2) = subplot(2,1,2); plot([1:length(sws_1.time(sws_1.shutter==0))],sws_1.In_cps([17,60,125,230],(sws_1.shutter==0)),'.-');
legend(sprintf('%1.f nm',sws_1.In_lambda(17)),sprintf('%1.f nm',sws_1.In_lambda(60)),...
   sprintf('%1.f nm',sws_1.In_lambda(125)),sprintf('%1.f nm',sws_1.In_lambda(230)));
xlabel('record number')
ylabel('counts/ms')
linkaxes(ax,'x')
%%
% identify shading start and stop
mark1 = 198; % start of shading
mark2 = 316; % done shading
sws_1.shaded = (sws_1.time>=sws_1.time(mark1))&(sws_1.time<=sws_1.time(mark1));
% figure; plot(sws_1.Si_lambda, mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2),'b',sws_1.Si_lambda, mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2),'r')
% figure; ax(1) = subplot(2,1,1); plot(sws_1.Si_lambda, mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2),'b',sws_1.Si_lambda, mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2),'r');
% ax(2) = subplot(2,1,2); plot(sws_1.Si_lambda, (mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2))./(mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)),'k');
Si_fig = figure; ax(1) = subplot(3,1,1); plot(sws_1.Si_lambda, mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2),'b',sws_1.Si_lambda, mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS Si shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_1.zen)), datestr(mean(sws_1.time(sws_1.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_1.Si_lambda, (mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_1.Si_lambda, 100*(mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2))./(mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)');
ylim([0,100]);

In_fig = figure; ax(1) = subplot(3,1,1); plot(sws_1.In_lambda, mean(sws_1.In_cps(:,sws_1.shaded&sws_1.shutter==0),2),'b',sws_1.In_lambda, mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS InGaAs shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_1.zen)), datestr(mean(sws_1.time(sws_1.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_1.In_lambda, (mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.In_cps(:,sws_1.shaded&sws_1.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_1.In_lambda, 100*(mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.In_cps(:,sws_1.shaded&sws_1.shutter==0),2))./(mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)')
ylim([0,100]);

[pname, fstem,ext] = fileparts(sws_1.filename);
SZA = sprintf('%2.1fdeg., ',mean(sws_1.zen));
dstr = datestr(mean(sws_1.time(sws_1.shaded)),'yyyymmdd_HHMM.');
fstem = ['SWS_shading_test.']; 
ext = '.png';
saveas(Si_fig,[pname,fstem,'Si.',SZA,dstr,ext],'png');
saveas(In_fig,[pname,fstem,'InGaAs.',SZA,dstr,ext],'png');
save([pname,fstem,SZA,dstr,'mat'],'-mat')
%%


% 1730-1732
% 1830-1832

% File #2: shading: % 1628-1630
sws_2 = read_sws_raw;%File #2: shading: % 1628-1630
%%
sws_2 = cat_sws_raw(read_sws_raw,sws_2);

%%
[sws_2.zen, az, soldst, ha_next, dec, el, am] = sunae(rss.vars.lat.data, rss.vars.lon.data, (sws_2.time));
sws_2.Si_dark = mean(sws_2.Si_DN(:,sws_2.shutter==1),2);
sws_2.In_dark = mean(sws_2.In_DN(:,sws_2.shutter==1),2);

sws_2.Si_cps = (sws_2.Si_DN - (sws_2.Si_dark*ones(size(sws_2.time))))./(ones(size(sws_2.Si_lambda))*sws_2.Si_ms);
sws_2.In_cps = (sws_2.In_DN - (sws_2.In_dark*ones(size(sws_2.time))))./(ones(size(sws_2.In_lambda))*sws_2.In_ms);
figure; subplot(2,1,1); plot(serial2Hh(sws_2.time(sws_2.shutter==0)),sws_2.Si_cps(150,sws_2.shutter==0),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_2.zen))]);
legend('800 nm');
xlabel('time (UTC)')
yl = ylim;
subplot(2,1,2); plot([1:length(sws_2.time)],sws_2.Si_cps(150,:),'.-');
ylim(yl);
xlabel('record number');
%%
% identify shading start and stop
mark1 = 73; % start of shading
mark2 = 197; % done shading
sws_2.shaded = (sws_2.time>=sws_2.time(mark1))&(sws_2.time<=sws_2.time(mark1));
% figure; plot(sws_2.Si_lambda, mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2),'b',sws_2.Si_lambda, mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2),'r')
% figure; ax(1) = subplot(2,1,1); plot(sws_2.Si_lambda, mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2),'b',sws_2.Si_lambda, mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2),'r');
% ax(2) = subplot(2,1,2); plot(sws_2.Si_lambda, (mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2))./(mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)),'k');
Si_fig = figure; ax(1) = subplot(3,1,1); plot(sws_2.Si_lambda, mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2),'b',sws_2.Si_lambda, mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS Si shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_2.zen)), datestr(mean(sws_2.time(sws_2.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_2.Si_lambda, (mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_2.Si_lambda, 100*(mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2))./(mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)');
ylim([0,100]);

In_fig = figure; ax(1) = subplot(3,1,1); plot(sws_2.In_lambda, mean(sws_2.In_cps(:,sws_2.shaded&sws_2.shutter==0),2),'b',sws_2.In_lambda, mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS InGaAs shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_2.zen)), datestr(mean(sws_2.time(sws_2.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_2.In_lambda, (mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.In_cps(:,sws_2.shaded&sws_2.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_2.In_lambda, 100*(mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.In_cps(:,sws_2.shaded&sws_2.shutter==0),2))./(mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)')
ylim([0,100]);

[pname, fstem,ext] = fileparts(sws_2.filename);
SZA = sprintf('%2.1fdeg., ',mean(sws_2.zen));
dstr = datestr(mean(sws_2.time(sws_2.shaded)),'yyyymmdd_HHMM.');
fstem = ['SWS_shading_test.']; 
ext = '.png';
saveas(Si_fig,[pname,fstem,'Si.',SZA,dstr,ext],'png');
saveas(In_fig,[pname,fstem,'InGaAs.',SZA,dstr,ext],'png');
save([pname,fstem,SZA,dstr,'mat'],'-mat')
%%
% 1830-1832

% File #3: shading: %  1730-1732

sws_3 = read_sws_raw; %  1730-1732
%%
sws_3 = cat_sws_raw(read_sws_raw,sws_3);

%%
[sws_3.zen, az, soldst, ha_next, dec, el, am] = sunae(rss.vars.lat.data, rss.vars.lon.data, (sws_3.time));
sws_3.Si_dark = mean(sws_3.Si_DN(:,sws_3.shutter==1),2);
sws_3.In_dark = mean(sws_3.In_DN(:,sws_3.shutter==1),2);

sws_3.Si_cps = (sws_3.Si_DN - (sws_3.Si_dark*ones(size(sws_3.time))))./(ones(size(sws_3.Si_lambda))*sws_3.Si_ms);
sws_3.In_cps = (sws_3.In_DN - (sws_3.In_dark*ones(size(sws_3.time))))./(ones(size(sws_3.In_lambda))*sws_3.In_ms);
figure; subplot(2,1,1); plot(serial2Hh(sws_3.time(sws_3.shutter==0)),sws_3.Si_cps(150,sws_3.shutter==0),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_3.zen))]);
legend('800 nm');
xlabel('time (UTC)')
yl = ylim;
subplot(2,1,2); plot([1:length(sws_3.time)],sws_3.Si_cps(150,:),'.-');
ylim(yl);
xlabel('record number');
%%
% identify shading start and stop
mark1 = 198; % start of shading
mark2 = 317; % done shading
sws_3.shaded = (sws_3.time>=sws_3.time(mark1))&(sws_3.time<=sws_3.time(mark1));
% figure; plot(sws_3.Si_lambda, mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2),'b',sws_3.Si_lambda, mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2),'r')
% figure; ax(1) = subplot(2,1,1); plot(sws_3.Si_lambda, mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2),'b',sws_3.Si_lambda, mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2),'r');
% ax(2) = subplot(2,1,2); plot(sws_3.Si_lambda, (mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2))./(mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)),'k');
Si_fig = figure; ax(1) = subplot(3,1,1); plot(sws_3.Si_lambda, mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2),'b',sws_3.Si_lambda, mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS Si shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_3.zen)), datestr(mean(sws_3.time(sws_3.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_3.Si_lambda, (mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_3.Si_lambda, 100*(mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2))./(mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)');
ylim([0,100]);

In_fig = figure; ax(1) = subplot(3,1,1); plot(sws_3.In_lambda, mean(sws_3.In_cps(:,sws_3.shaded&sws_3.shutter==0),2),'b',sws_3.In_lambda, mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS InGaAs shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_3.zen)), datestr(mean(sws_3.time(sws_3.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_3.In_lambda, (mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.In_cps(:,sws_3.shaded&sws_3.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_3.In_lambda, 100*(mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.In_cps(:,sws_3.shaded&sws_3.shutter==0),2))./(mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)')
ylim([0,100]);

[pname, fstem,ext] = fileparts(sws_3.filename);
SZA = sprintf('%2.1fdeg., ',mean(sws_3.zen));
dstr = datestr(mean(sws_3.time(sws_3.shaded)),'yyyymmdd_HHMM.');
fstem = ['SWS_shading_test.']; 
ext = '.png';
saveas(Si_fig,[pname,fstem,'Si.',SZA,dstr,ext],'png');
saveas(In_fig,[pname,fstem,'InGaAs.',SZA,dstr,ext],'png');
save([pname,fstem,SZA,dstr,'mat'],'-mat')
%%
sws_4 = read_sws_raw; % 1830-1832
%%
sws_4 = cat_sws_raw(read_sws_raw,sws_4);

%%
[sws_4.zen, az, soldst, ha_next, dec, el, am] = sunae(rss.vars.lat.data, rss.vars.lon.data, (sws_4.time));
sws_4.Si_dark = mean(sws_4.Si_DN(:,sws_4.shutter==1),2);
sws_4.In_dark = mean(sws_4.In_DN(:,sws_4.shutter==1),2);

sws_4.Si_cps = (sws_4.Si_DN - (sws_4.Si_dark*ones(size(sws_4.time))))./(ones(size(sws_4.Si_lambda))*sws_4.Si_ms);
sws_4.In_cps = (sws_4.In_DN - (sws_4.In_dark*ones(size(sws_4.time))))./(ones(size(sws_4.In_lambda))*sws_4.In_ms);
figure; subplot(2,1,1); plot(serial2Hh(sws_4.time(sws_4.shutter==0)),sws_4.Si_cps(150,sws_4.shutter==0),'.-')
title(['Non-dark cps for selected Si pixels for ',sprintf('%2.1f degrees',mean(sws_4.zen))]);
legend('800 nm');
xlabel('time (UTC)')
yl = ylim;
subplot(2,1,2); plot([1:length(sws_4.time)],sws_4.Si_cps(150,:),'.-');
ylim(yl);
xlabel('record number');
%%
% identify shading start and stop
mark1 = 198; % start of shading
mark2 = 317; % done shading
sws_4.shaded = (sws_4.time>=sws_4.time(mark1))&(sws_4.time<=sws_4.time(mark1));
% figure; plot(sws_4.Si_lambda, mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2),'b',sws_4.Si_lambda, mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2),'r')
% figure; ax(1) = subplot(2,1,1); plot(sws_4.Si_lambda, mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2),'b',sws_4.Si_lambda, mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2),'r');
% ax(2) = subplot(2,1,2); plot(sws_4.Si_lambda, (mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2))./(mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)),'k');
Si_fig = figure; ax(1) = subplot(3,1,1); plot(sws_4.Si_lambda, mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2),'b',sws_4.Si_lambda, mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS Si shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_4.zen)), datestr(mean(sws_4.time(sws_4.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_4.Si_lambda, (mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_4.Si_lambda, 100*(mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2))./(mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)');
ylim([0,100]);

In_fig = figure; ax(1) = subplot(3,1,1); plot(sws_4.In_lambda, mean(sws_4.In_cps(:,sws_4.shaded&sws_4.shutter==0),2),'b',sws_4.In_lambda, mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2),'r');
legend('shaded','unshaded');
title(['SWS InGaAs shading test, SZA=',sprintf('%2.1f deg, ',mean(sws_4.zen)), datestr(mean(sws_4.time(sws_4.shaded)),' yyyy-mm-dd HH:MM UTC')]);
ylabel('cps, dark subtracted');
yl = ylim; ylim([0,yl(2)]);
ax(2) = subplot(3,1,2); plot(sws_4.In_lambda, (mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.In_cps(:,sws_4.shaded&sws_4.shutter==0),2)),'k');
ylabel('diff (cps)');
yl = ylim; ylim([0,yl(2)]);
ax(3) = subplot(3,1,3); plot(sws_4.In_lambda, 100*(mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.In_cps(:,sws_4.shaded&sws_4.shutter==0),2))./(mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)),'g');
ylabel('diff (%)');
xlabel('wavelength (nm)')
ylim([0,100]);

[pname, fstem,ext] = fileparts(sws_4.filename);
SZA = sprintf('%2.1fdeg., ',mean(sws_4.zen));
dstr = datestr(mean(sws_4.time(sws_4.shaded)),'yyyymmdd_HHMM.');
fstem = ['SWS_shading_test.']; 
ext = '.png';
saveas(Si_fig,[pname,fstem,'Si.',SZA,dstr,ext],'png');
saveas(In_fig,[pname,fstem,'InGaAs.',SZA,dstr,ext],'png');
save([pname,fstem,SZA,dstr,'mat'],'-mat')
%%
sws_1.Si_solar_cps = (mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2));
sws_2.Si_solar_cps = (mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2));
sws_3.Si_solar_cps = (mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2));
sws_4.Si_solar_cps = (mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2));

sws_1.In_solar_cps = (mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.In_cps(:,sws_1.shaded&sws_1.shutter==0),2));
sws_2.In_solar_cps = (mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.In_cps(:,sws_2.shaded&sws_2.shutter==0),2));
sws_3.In_solar_cps = (mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.In_cps(:,sws_3.shaded&sws_3.shutter==0),2));
sws_4.In_solar_cps = (mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.In_cps(:,sws_4.shaded&sws_4.shutter==0),2));

Optronics = loadinto('C:\mlib\sws\Optronics.mat');
%%

sws_1.Si_solar = sws_1.Si_solar_cps./Optronics.Aper_A.Si_resp;
sws_2.Si_solar = sws_2.Si_solar_cps./Optronics.Aper_A.Si_resp;
sws_3.Si_solar = sws_3.Si_solar_cps./Optronics.Aper_A.Si_resp;
sws_4.Si_solar = sws_4.Si_solar_cps./Optronics.Aper_A.Si_resp;

sws_1.In_solar = sws_1.In_solar_cps./Optronics.Aper_A.In_resp;
sws_2.In_solar = sws_2.In_solar_cps./Optronics.Aper_A.In_resp;
sws_3.In_solar = sws_3.In_solar_cps./Optronics.Aper_A.In_resp;
sws_4.In_solar = sws_4.In_solar_cps./Optronics.Aper_A.In_resp;
%%
sws_1.Si_pct_solar = 100*(mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.Si_cps(:,sws_1.shaded&sws_1.shutter==0),2))./(mean(sws_1.Si_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2));
sws_2.Si_pct_solar = 100*(mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.Si_cps(:,sws_2.shaded&sws_2.shutter==0),2))./(mean(sws_2.Si_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2));
sws_3.Si_pct_solar = 100*(mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.Si_cps(:,sws_3.shaded&sws_3.shutter==0),2))./(mean(sws_3.Si_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2));
sws_4.Si_pct_solar = 100*(mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.Si_cps(:,sws_4.shaded&sws_4.shutter==0),2))./(mean(sws_4.Si_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2));

sws_1.In_pct_solar = 100*(mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2)-mean(sws_1.In_cps(:,sws_1.shaded&sws_1.shutter==0),2))./(mean(sws_1.In_cps(:,(~sws_1.shaded)&(sws_1.shutter==0)),2));
sws_2.In_pct_solar = 100*(mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2)-mean(sws_2.In_cps(:,sws_2.shaded&sws_2.shutter==0),2))./(mean(sws_2.In_cps(:,(~sws_2.shaded)&(sws_2.shutter==0)),2));
sws_3.In_pct_solar = 100*(mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2)-mean(sws_3.In_cps(:,sws_3.shaded&sws_3.shutter==0),2))./(mean(sws_3.In_cps(:,(~sws_3.shaded)&(sws_3.shutter==0)),2));
sws_4.In_pct_solar = 100*(mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2)-mean(sws_4.In_cps(:,sws_4.shaded&sws_4.shutter==0),2))./(mean(sws_4.In_cps(:,(~sws_4.shaded)&(sws_4.shutter==0)),2));

%%
figure; subplot(2,1,1); plot(sws_1.Si_lambda, [sws_1.Si_solar_cps,sws_2.Si_solar_cps,sws_3.Si_solar_cps,sws_4.Si_solar_cps], '-');
subplot(2,1,2); plot(sws_1.Si_lambda, [sws_1.Si_solar,sws_2.Si_solar,sws_3.Si_solar,sws_4.Si_solar], '-');
legend(datestr(mean(sws_1.time(sws_1.shaded)),'HHMM'),datestr(mean(sws_2.time(sws_2.shaded)),'HHMM'),...
   datestr(mean(sws_3.time(sws_3.shaded)),'HHMM'),datestr(mean(sws_4.time(sws_4.shaded)),'HHMM'))
figure; subplot(2,1,1); plot(sws_1.In_lambda, [sws_1.In_solar_cps,sws_2.In_solar_cps,sws_3.In_solar_cps,sws_4.In_solar_cps], '-');
subplot(2,1,2); plot(sws_1.In_lambda, [sws_1.In_solar,sws_2.In_solar,sws_3.In_solar,sws_4.In_solar], '-');
legend(datestr(mean(sws_1.time(sws_1.shaded)),'HHMM'),datestr(mean(sws_2.time(sws_2.shaded)),'HHMM'),...
   datestr(mean(sws_3.time(sws_3.shaded)),'HHMM'),datestr(mean(sws_4.time(sws_4.shaded)),'HHMM'))
%%
%%
figure; subplot(2,1,1); plot(sws_1.Si_lambda, [sws_1.Si_solar,sws_2.Si_solar,sws_3.Si_solar,sws_4.Si_solar], '-');
subplot(2,1,2); plot(sws_1.In_lambda, [sws_1.In_solar,sws_2.In_solar,sws_3.In_solar,sws_4.In_solar], '-');
legend(datestr(mean(sws_1.time(sws_1.shaded)),'HHMM'),datestr(mean(sws_2.time(sws_2.shaded)),'HHMM'),...
   datestr(mean(sws_3.time(sws_3.shaded)),'HHMM'),datestr(mean(sws_4.time(sws_4.shaded)),'HHMM'))

%%
figure; 
ax(1) = subplot(2,1,1); plot(sws_1.Si_lambda, [sws_1.Si_solar,sws_2.Si_solar,sws_3.Si_solar,sws_4.Si_solar], '-');
title('Solar contribution to SWS zenith radiances')
ylabel({Optronics.radiance_units})
hold('on');
plot(sws_1.In_lambda, [sws_1.In_solar,sws_2.In_solar,sws_3.In_solar,sws_4.In_solar], '-');
hold('off');
yl = ylim; ylim([0,yl(2)/5]);
 legend(['SZA=',sprintf('%2.1f deg, ',mean(sws_1.zen))],['SZA=',sprintf('%2.1f deg, ',mean(sws_2.zen))],...
    ['SZA=',sprintf('%2.1f deg, ',mean(sws_3.zen))],['SZA=',sprintf('%2.1f deg, ',mean(sws_4.zen))])

ax(2) = subplot(2,1,2); plot(sws_1.Si_lambda, [sws_1.Si_pct_solar,sws_2.Si_pct_solar,sws_3.Si_pct_solar,sws_4.Si_pct_solar], '-');
title('Percent of SWS signal due to direct beam contamination');
ylabel('% of total')
hold('on');
plot(sws_1.In_lambda, [sws_1.In_pct_solar,sws_2.In_pct_solar,sws_3.In_pct_solar,sws_4.In_pct_solar], '-');
hold('off');
ylim([0,200]);
 xlabel('wavelength (nm)');
 legend(datestr(mean(sws_1.time(sws_1.shaded)),'HH:MM UTC'),datestr(mean(sws_2.time(sws_2.shaded)),'HH:MM UTC'),...
   datestr(mean(sws_3.time(sws_3.shaded)),'HH:MM UTC'),datestr(mean(sws_4.time(sws_4.shaded)),'HH:MM UTC'))

linkaxes(ax,'x');
xlim([sws_1.Si_lambda(1),sws_1.In_lambda(end)])