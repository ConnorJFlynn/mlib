function SASHe_SGP_blocking_filter_tests
% Examine filter tests at SGP SAS-He with schott glass and Semrock filters.
% 2013 March 26 in conjunction with ASSIST / AERI comparison
% filters: 
% RG830 (long long pass)
% OG570 (long pass)
% KG5 (short pass, not sharp)
% Semrock 364 short pass, sharp
% Semrock 514 notch filter
% 
% Getting ready to start tests 22:33 UTC, airmass 2.3
% Opening chiller door to insert semrock filter at 22:37.
% But neglected to confirm filter orientation (arrow should face in direction of light propagation)
% So abandon this Semrock run and start with Schott glass
% 1. RG830, 22:43
% 2. OG570, 22:47 (airmass 2.5)
% 3. KG5, 22:51 first one plate (airmass 2.6) 
%         then sky
%         22:55, then second plate
% 4. Then Semrock notch filter, AMF 2.8, 23:00
% 5. Then Semrock 364 AM 2.9
% 
% Repeat but with filters place on diffuser.  This should probably be OK for schott glass
% but not for Semrock
% 1. Semrock 364
% 2. Semrock notch, not even discernable
% 3. RG830
% 4 OG570
% 5. KG5
% 6 Blocked
%%
pname = ['D:\case_studies\SAS\testing_and_characterization\2013_03_26.SASHe_SGP_filter_tests\'];
nirfile = [pname, 'SASHe_HiSun_nir_1s.20130326_224254.csv'];
% nirfile = getfullname_([pname, 'SASHe_HiSun_nir_1s.*.csv'],'SASHe_filtertests');
% SASHe_HiSun_nir_1s.20130326_224254.csv for RG830 test
nir = rd_raw_SAS(nirfile);
visfile = strrep(nirfile,'_nir_','_vis_');
vis = rd_raw_SAS(visfile);
%%
recs = [1:length(nir.time)]';
% figure; plot(recs(nir.Shutter_open_TF==0),nir.Tag(nir.Shutter_open_TF==0),'ro',...
% recs((nir.Shutter_open_TF~=0)),nir.Tag(nir.Shutter_open_TF~=0),'go')

%%
% figure; lines = plot(nir.lambda, nir.spec(vis.Shutter_open_TF==0,:),'-'); 
% recolor(lines,recs(nir.Shutter_open_TF==0)); colorbar
%%
above = vis.lambda>620 & vis.lambda < 630;
nir_dark = mean(nir.spec(nir.Shutter_open_TF==0,:));
vis_dark = mean(vis.spec(vis.Shutter_open_TF==0,:));
vis.light = vis.spec - ones(size(vis.Tag))*vis_dark;
nir.light = nir.spec - ones(size(nir.Tag))*nir_dark;
vis.light = vis.light - 0.0018.*mean(vis.light(above));

%% 
% TH_RG_in = (vis.Tag==5&recs>20&recs<35);
% TH_RG_out = vis.Tag==5&(recs<20|recs>35);

TH_ = vis.Tag==5|vis.Tag==16; 
SB_  = vis.Tag==7|vis.Tag==11|vis.Tag==18|vis.Tag==22; 
BK_ =  vis.Tag==9|vis.Tag==20;
% figure;
% lines = plot(vis.lambda, vis.light(TH_&vis.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs(TH_&vis.Shutter_open_TF==1)); colorbar
% title('TH');

SB_(SB_) = SB_(SB_) & ((vis.light(SB_&vis.Shutter_open_TF==1,446)> 9000)|(vis.light(SB_&vis.Shutter_open_TF==1,446)< 500));
% figure;
% lines = plot(vis.lambda, vis.light(SB_&vis.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs(SB_&vis.Shutter_open_TF==1)); colorbar
% title('SB');


% figure;
% lines = plot(vis.lambda, vis.light(BK_&vis.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs(BK_&vis.Shutter_open_TF==1)); colorbar
% title('BK');

%%
% filt_in = (recs>20&recs<35);
% filt_out = (recs<20|recs>35);
pix = interp1(vis.lambda, [1:length(vis.lambda)],775,'nearest');
filt_in = (vis.light(:,pix)<100)&(vis.Shutter_open_TF==1);
filt_out = vis.light(:,pix)>100;

%%
TH_out = meannonan(vis.light(TH_&filt_out,:));
SB_out = meannonan(vis.light(SB_&filt_out,:));
BK_out = meannonan(vis.light(BK_&filt_out,:));
DH_out = SB_out - BK_out;
Dif_out = TH_out-DH_out;

TH_in = meannonan(vis.light(TH_&filt_in,:));
SB_in = meannonan(vis.light(SB_&filt_in,:));
BK_in = meannonan(vis.light(BK_&filt_in,:));
DH_in = SB_in - BK_in;
Dif_in = TH_in-DH_in;

wl_555 = interp1(vis.lambda,[1:length(vis.lambda)],555,'nearest');
TH_peak = TH_out(wl_555);
DH_peak = mean(DH_out(wl_555));
Dif_peak = mean(Dif_out(wl_555));

figure; 
 semilogy(vis.lambda,  DH_in/DH_peak,'-',...
     vis.lambda, Dif_in/Dif_peak,'-' );
lg = legend('DirHoriz_stray','DifHemisp_stray'); set(lg,'interp','none');
title('Stray light with RG830 long pass filter in place');

figure;
ax(1) = subplot(3,1,1);
lines = semilogy(vis.lambda, TH_in./TH_peak,'r',...
   vis.lambda, TH_out/TH_peak,'b-' );
lg = legend('TH_in','TH_out'); set(lg,'interp','none')

title('Stray light with RG830 long pass filter in place');
ax(2) = subplot(3,1,2);
lines = semilogy(vis.lambda, DH_in/DH_peak,'r',...
   vis.lambda, DH_out/DH_peak,'b-' );
lg = legend('DH_in','DH_out'); set(lg,'interp','none')
ax(3) = subplot(3,1,3);
lines = semilogy(vis.lambda, Dif_in/Dif_peak,'r',...
   vis.lambda, Dif_out/Dif_peak,'b-' );
lg = legend('Dif_in','Dif_out'); set(lg,'interp','none');
linkaxes(ax,'xy');
%%
figure; 
lines = semilogy(vis.lambda, TH_in./TH_out,'-',...
vis.lambda, DH_in./DH_out,'-',...
vis.lambda, Dif_in./Dif_out,'-' );
lg = legend('TH', 'DH','Dif'); set(lg,'interp','none');
title('Percent of unfiltered signal with RG830 long pass filter in place');

%% Now OG570

pname = ['D:\case_studies\SAS\testing_and_characterization\2013_03_26.SASHe_SGP_filter_tests\'];
% nirfile = getfullname_([pname, 'SASHe_HiSun_nir_1s.*.csv'],'SASHe_filtertests');
nirfile = [pname, 'SASHe_HiSun_nir_1s.20130326_224754.csv'];
nir2 = rd_raw_SAS(nirfile);
visfile = strrep(nirfile,'_nir_','_vis_');
vis2 = rd_raw_SAS(visfile);


recs2 = [1:length(nir2.time)]';
% figure; plot(recs2(nir2.Shutter_open_TF==0),nir2.Tag(nir2.Shutter_open_TF==0),'ro',...
% recs2((nir2.Shutter_open_TF~=0)),nir2.Tag(nir2.Shutter_open_TF~=0),'go')

%%
% figure; lines = plot(nir.lambda, nir.spec(vis.Shutter_open_TF==0,:),'-'); 
% recolor(lines,recs(nir.Shutter_open_TF==0)); colorbar
%%
nir_dark2 = mean(nir2.spec(nir2.Shutter_open_TF==0,:));
vis_dark2 = mean(vis2.spec(vis2.Shutter_open_TF==0,:));
vis2.light = vis2.spec - ones(size(vis2.Tag))*vis_dark2;
nir2.light = nir2.spec - ones(size(nir2.Tag))*nir_dark2;


TH_2 = vis2.Tag==5|vis2.Tag==16; 
SB_2 = vis2.Tag==7|vis2.Tag==11|vis2.Tag==18|vis2.Tag==22; 
BK_2 = vis2.Tag==9|vis2.Tag==20;
% figure;
% lines = plot(vis2.lambda, vis2.light(TH_2&vis2.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs2(TH_2&vis2.Shutter_open_TF==1)); colorbar
% title('TH2');

SB_(SB_2) = SB_(SB_2) & ((vis2.light(SB_2&vis2.Shutter_open_TF==1,446)> 9000)|(vis2.light(SB_2&vis2.Shutter_open_TF==1,446)< 500));
% figure;
% lines = plot(vis2.lambda, vis2.light(SB_2&vis2.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs2(SB_2&vis2.Shutter_open_TF==1)); colorbar
% title('SB');

% figure;
% lines = plot(vis2.lambda, vis2.light(BK_2&vis2.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs2(BK_2&vis2.Shutter_open_TF==1)); colorbar
% title('BK');

%%
% filt_in2 = (recs2>15&recs2<25);
% filt_out2 = (recs2<15|recs2>25);
pix2 = interp1(vis2.lambda, [1:length(vis2.lambda)],514,'nearest');
filt_in2 = vis2.light(:,pix2)<100;
filt_out2 = vis2.light(:,pix2)>100;

% filt_in = (recs>20&recs<35);
% filt_out = (recs<20|recs>35);
% pix2 = interp1(vis2.lambda, [1:length(vis2.lambda)],775,'nearest');
% filt_in2 = (vis2.light(:,pix2)<100)&(vis2.Shutter_open_TF==1);
% filt_out2 = vis2.light(:,pix2)>100;

%%
TH_out2 = meannonan(vis2.light(TH_2&filt_out2,:));
SB_out2 = meannonan(vis2.light(SB_2&filt_out2,:));
BK_out2 = meannonan(vis2.light(BK_2&filt_out2,:));
DH_out2 = SB_out2 - BK_out2;
Dif_out2 = TH_out2-DH_out2;

TH_in2 = meannonan(vis2.light(TH_2&filt_in2,:));
SB_in2 = meannonan(vis2.light(SB_2&filt_in2,:));
BK_in2 = meannonan(vis2.light(BK_2&filt_in2,:));
DH_in2 = SB_in2 - BK_in2;
Dif_in2 = TH_in2-DH_in2;

wl_555 = interp1(vis.lambda,[1:length(vis.lambda)],555,'nearest');
TH_peak2 = TH_out2(wl_555);
DH_peak2 = mean(DH_out2(wl_555));
Dif_peak2 = mean(Dif_out2(wl_555));



figure; 
semilogy(vis2.lambda, DH_in2./DH_peak2,'r',vis2.lambda, Dif_in2./Dif_peak2,'b' );

figure;


ax(1) = subplot(3,1,1);
lines = semilogy(vis2.lambda, TH_in2./TH_peak2,'r',...
   vis2.lambda, TH_out2./TH_peak2,'b-' );
lg = legend('TH_in2','TH_out2'); set(lg,'interp','none')

title('Stray light with OG570 long pass filter in place');
ax(2) = subplot(3,1,2);
lines = semilogy(vis2.lambda, DH_in2./DH_peak2,'r',...
   vis2.lambda, DH_out2./DH_peak2,'b-' );
lg = legend('DH_in2','DH_out2'); set(lg,'interp','none')
ax(3) = subplot(3,1,3);
lines = semilogy(vis2.lambda, Dif_in2./Dif_peak2,'r',...
   vis2.lambda, Dif_out2./Dif_peak2,'b-' );
lg=legend('Dif_in2','Dif_out2'); set(lg,'interp','none');
linkaxes(ax,'xy');
%%
figure; 
lines = semilogy(vis2.lambda, TH_in2./TH_out2,'-',...
vis2.lambda, DH_in2./DH_out2,'-',...
vis2.lambda, Dif_in2./Dif_out2,'-' );
lg = legend('TH2', 'DH2','Dif2'); set(lg,'interp','none');
title('Percent of unfiltered signal with OG570 long pass filter in place');

%% Done OG570
% figure; lines = semilogy(vis.lambda, mean(vis.light(TH_&filt_in,:))./mean(TH),'b');
% % figure; lines = semilogy(vis.lambda, vis.light(TH_&filt_in,:)./TH,'b');
% title('Stray light with RG830 long pass filter in place');
% ylabel('Fraction of unfiltered signal');
% xlabel('wavelength [nm]')
%%

%% Now, KG5
% SASHe_HiSun_nir_1s.20130326_225137.csv for KG5 test
pname = ['D:\case_studies\SAS\testing_and_characterization\2013_03_26.SASHe_SGP_filter_tests\'];
nirfile = [pname, 'SASHe_HiSun_nir_1s.20130326_225137.csv'];
% nirfile = getfullname_([pname, 'SASHe_HiSun_nir_1s.*.csv'],'SASHe_filtertests');
nir3 = rd_raw_SAS(nirfile);
visfile = strrep(nirfile,'_nir_','_vis_');
vis3 = rd_raw_SAS(visfile);
%%
recs3 = [1:length(nir3.time)]';
% figure; plot(recs3(nir3.Shutter_open_TF==0),nir3.Tag(nir3.Shutter_open_TF==0),'ro',...
% recs3((nir3.Shutter_open_TF~=0)),nir3.Tag(nir3.Shutter_open_TF~=0),'go')

%%
% figure; lines = plot(nir.lambda, nir.spec(vis.Shutter_open_TF==0,:),'-'); 
% recolor(lines,recs(nir.Shutter_open_TF==0)); colorbar
%%
nir_dark3 = mean(nir3.spec(nir3.Shutter_open_TF==0,:));
vis_dark3 = mean(vis3.spec(vis3.Shutter_open_TF==0,:));
vis3.light = vis3.spec - ones(size(vis3.Tag))*vis_dark3;
nir3.light = nir3.spec - ones(size(nir3.Tag))*nir_dark3;


TH_3 = vis3.Tag==5|vis3.Tag==16; 
SB_3 = vis3.Tag==7|vis3.Tag==11|vis3.Tag==18|vis3.Tag==22 ;
BK_3 = vis3.Tag==9|vis3.Tag==20;

% figure;
% lines = plot(vis3.lambda, vis3.light(TH_3&vis3.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs3(TH_3&vis3.Shutter_open_TF==1)); colorbar
% title('TH3');

% SB_3(SB_3) = SB_3(SB_3) & ((vis3.light(SB_3&vis3.Shutter_open_TF==1,446)> 9000)|(vis3.light(SB_3&vis3.Shutter_open_TF==1,446)< 500));
% figure;
% lines = plot(vis3.lambda, vis3.light(SB_3&vis3.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs3(SB_3&vis3.Shutter_open_TF==1)); colorbar
% title('SB');

% figure;
% lines = plot(vis3.lambda, vis3.light(BK_3&vis3.Shutter_open_TF==1,:),'-'); 
% recolor(lines,recs3(BK_3&vis3.Shutter_open_TF==1)); colorbar
% title('BK');
% 
%%
% filt_in3 = (recs3>15&recs3<35);
% filt_out3 = (recs3<15|recs3>35);
pix3 = interp1(vis3.lambda, [1:length(vis3.lambda)],780,'nearest');
filt_in3 = vis3.light(:,pix3)<100;
filt_out3 = vis3.light(:,pix3)>100;

% filt_in = (recs>30&recs<35);
% filt_out = (recs<30|recs>35);
% pix3 = interp1(vis3.lambda, [1:length(vis3.lambda)],775,'nearest');
% filt_in3 = (vis3.light(:,pix3)<100)&(vis3.Shutter_open_TF==1);
% filt_out3 = vis3.light(:,pix3)>100;

%%
TH_out3 = meannonan(vis3.light(TH_3&filt_out3,:));
SB_out3 = meannonan(vis3.light(SB_3&filt_out3,:));
BK_out3 = meannonan(vis3.light(BK_3&filt_out3,:));
DH_out3 = SB_out3 - BK_out3;
Dif_out3 = TH_out3-DH_out3;

TH_in3 = meannonan(vis3.light(TH_3&filt_in3,:));
SB_in3 = meannonan(vis3.light(SB_3&filt_in3,:));
BK_in3 = meannonan(vis3.light(BK_3&filt_in3,:));
DH_in3 = SB_in3 - BK_in3;
Dif_in3 = TH_in3-DH_in3;

wl_555 = interp1(vis.lambda,[1:length(vis.lambda)],555,'nearest');
TH_peak3 = TH_out3(wl_555);
DH_peak3 = mean(DH_out3(wl_555));
Dif_peak3 = mean(Dif_out3(wl_555));

%%
figure;
title('Stray light with OG570 long pass filter in place');
lines = semilogy(vis3.lambda, DH_in3./DH_peak3,'-',...
   vis3.lambda, DH_out3./DH_peak3,'-',vis3.lambda, Dif_in3./Dif_peak3,'-',...
   vis3.lambda, Dif_out3./Dif_peak3,'-' );
lg = legend('DH_in3, DH_out3,Dif_in3','Dif_out3'); set(lg,'interp','none');
linkaxes(ax,'xy');
%%
figure; 
lines = semilogy(vis3.lambda, DH_in3./DH_peak3,'b',...
   vis3.lambda, Dif_in3./Dif_peak3,'r');

%%
figure
ax(1) = subplot(3,1,1);
lines = semilogy(vis3.lambda, TH_in3,'r',...
   vis3.lambda, TH_out3,'b-' );
lg = legend('TH_in3','TH_out3'); set(lg,'interp','none')

title('Stray light with OG570 long pass filter in place');
ax(2) = subplot(3,1,2);
lines = semilogy(vis3.lambda, DH_in3,'r',...
   vis3.lambda, DH_out3,'b-' );
lg = legend('DH_in3','DH_out3'); set(lg,'interp','none')
ax(3) = subplot(3,1,3);
lines = semilogy(vis3.lambda, Dif_in3,'r',...
   vis3.lambda, Dif_out3,'b-' );
lg = legend('Dif_in3','Dif_out3'); set(lg,'interp','none');
linkaxes(ax,'xy');
%%


figure; 
lines = semilogy(vis3.lambda, TH_in3./TH_out3,'-',...
vis3.lambda, DH_in3./DH_out3,'-',...
vis3.lambda, Dif_in3./Dif_out3,'-' );
lg = legend('TH3', 'DH3','Dif3'); set(lg,'interp','none');

figure; plot(vis.lambda, TH_out, '-',vis3.lambda, TH_out3,'-');

mean(DH_in3(wl_900)./DH_peak3)

% ans =
% 
%    5.6613e-04

wl_400 = vis.lambda>300&vis.lambda<500;
mean(DH_in(wl_400)./DH_peak)

% ans =
% 
%    7.4874e-05

mean(DH_in2(wl_400)./DH_peak2)

% ans =
% 
%    9.5625e-04

(1./0.55).*mean(DH_in2(wl_400)./DH_peak2)

% ans =
% 
%     0.0017

mean(DH_in3(wl_900)./DH_peak3)

% ans =
% 
%    5.6613e-04

(1./.6).*mean(DH_in3(wl_900)./DH_peak3)

% ans =
% 
%    9.4355e-04

mean(DH_in2(wl_400)./DH_peak2)

% ans =
% 
%    9.5625e-04

mean(DH_in3(wl_900)./DH_peak3)

% ans =
% 
%    5.6613e-04

mean(DH_in2(wl_400)./DH_peak2)

% ans =
% 
%    9.5625e-04

mean(DH_in3(wl_900)./DH_peak3)

% ans =
% 
%    5.6613e-04

trapz(vis.lambda,DH_in3)./trapz(vis.lambda,DH_out3)

% ans =
% 
%     0.6028

trapz(vis.lambda,DH_in)./trapz(vis.lambda,DH_out)

% ans =
% 
%     0.0334

trapz(vis.lambda,DH_in2)./trapz(vis.lambda,DH_out2)

% ans =
% 
%     0.5548

9.6e-4 ./ .55

% ans =
% 
%     0.0017

5.7e-4./.6

% ans =
% 
%    9.5000e-04