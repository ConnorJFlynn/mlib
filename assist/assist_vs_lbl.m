function assist = assist_vs_lbl(pname)% ASSIST annew
% Applies ASSIST calibrations step by step. The main point of this function
% is to look at the wavenumber registration of the ASSIST vs LBL-generated spectra.

%%

assist = load(getfullname('*.mat','assist_compare'));
chA = assist.chA.mrad.x>550 & assist.chA.mrad.x<1830;
chB = assist.chB.mrad.x>1800&assist.chB.mrad.x<3200;
sky = assist.isSky;

% aeri = ancload(getfullname('*sgpaerisummaryC1*.cdf','aeri'));
% xl = aeri.time>assist.time(1)&aeri.time<assist.time(end);
% aericha = ancload(getfullname('*sgpaeri*.cdf','aeri'));
% aericha = ancsift(aericha, aericha.dims.time, xl);
%%
% figure; plot(aericha.vars.wnum.data, mean(aericha.vars.mean_rad.data,2),'k-',(1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-'); 
% title(['AERI and ASSIST sky radiances: ',datestr(aericha.time(1),'mmm dd yyyy')]);
% legend('AERI','ASSIST')
%%
% .  The were run with the 326.2329 scaled sonde using the AERI instrument function
chA_lbl_fname = getfullname('*lbl*.csv','eli_lbl');
fid1 = fopen(chA_lbl_fname);
chA_lbl = textscan(fid1,'%f %f %*[^\n]','delimiter',',','headerlines',1);
fclose(fid1);
fid2 = fopen(strrep(chA_lbl_fname, 'rad_aer','rad_sw_aer'));
chB_lbl = textscan(fid2,'%f %f %*[^\n]','delimiter',',','headerlines',1);
fclose(fid2);

lbl.chA.x = chA_lbl{1};
lbl.chA.rad = chA_lbl{2};
lbl.chB.x = chB_lbl{1};
lbl.chB.rad = chB_lbl{2};

% units: (W/(cm^2-sr-cm^-1)
% ASSIST units: mW/(m^2 sr cm^-1)
%%
% As a test I pre-stretched the ASSIST wn scale by 1.001.  This yielded a
% commensurate "stretch" < 1. 
%assist.chA.mrad.x = 1.001.*assist.chA.mrad.x;

figure; plot(lbl.chA.x, 1e7.*lbl.chA.rad,'b-', assist.chA.mrad.x(chA), assist.chA.mrad.y(sky,chA),'r-'); legend('lbl','assist');zoom('on');
!! We're right here, getting ready to compute lag to maximize correlation between ASSIST and LBL
%%
m = menu('zoom in to select a region to fit over for ch A then select OK','OK')
xl = xlim;
%%
lbl_x = lbl.chA.x>= xl(1) & lbl.chA.x<xl(2);
assist_x =assist.chA.mrad.x>xl(1) & assist.chA.mrad.x< xl(2);
%
xrange = [min([min(lbl.chA.x(lbl_x)),min(assist.chA.mrad.x(assist_x))]),...
   max([max(lbl.chA.x(lbl_x)),max(assist.chA.mrad.x(assist_x))])];
%
xrange = [xrange(1):0.005*(diff(lbl.chA.x(1:2))):xrange(2)];
lbl_in_ = 1e7.*interp1(lbl.chA.x,lbl.chA.rad,xrange,'linear');
lbl_in = (lbl_in_-mean(lbl_in_));
assist_in_ = interp1(assist.chA.mrad.x,mean(real(assist.chA.mrad.y(assist.Sky_ii,:))),xrange,'linear');
assist_in = (assist_in_-mean(assist_in_));
% figure; plot(xrange, lbl_in,'.r-',xrange,assist_in,'.k-');legend('LBL','ASSIST')
%
corrLength=length(lbl_in)+length(assist_in)-1;
c=fftshift(ifft(fft(lbl_in,corrLength).*conj(fft(assist_in,corrLength))));
lags = [-(corrLength-1)./2:(corrLength-1)./2];
figure; plot(lags, c,'-r');
[~, lag] = max(c);
wn_offset = lags(lag).*diff(xrange(1:2));
title(['xcorr max for lag=',num2str(lags(lag))]);

%%
stretch = (mean(xl)+wn_offset)./mean(xl);
assist_in2_ = interp1(stretch.*assist.chA.mrad.x,mean(real(assist.chA.mrad.y(assist.Sky_ii,:))),xrange,'linear');
assist_in2 = (assist_in2_-mean(assist_in2_));
corrLength=length(lbl_in)+length(assist_in2)-1;
c=fftshift(ifft(fft(lbl_in,corrLength).*conj(fft(assist_in2,corrLength))));
lags2 = [-(corrLength-1)./2:(corrLength-1)./2];
[~, lag2] = max(c);
wn_offset2 = lags2(lag2).*diff(xrange(1:2));
sprintf('%g',wn_offset2)
%%
laser_wn_nom = (assist.chA.mrad.x(2)-assist.chA.mrad.x(1)) .* 2^15;
laser_wn_new = stretch.*(assist.chA.mrad.x(2)-assist.chA.mrad.x(1)) .* 2^15;

figure; plot(lbl.chA.x, 1e7.*lbl.chA.rad,'b-', assist.chA.mrad.x(chA), assist.chA.mrad.y(sky,chA),'r-'); legend('lbl','assist');
xlim(xl)
title({sprintf('Original laser freq=%5.5f ',15798.02); sprintf('Effective laser freq=%5.5f ',laser_wn_new)}) 
%%
figure; plot(lbl.chB.x, 1e7.*lbl.chB.rad,'b-', assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'r-'); legend('lbl SW','assist chB');zoom('on');

%%
m = menu('zoom in to select a region to fit over for ch B then select OK','OK')
xlB = xlim;
%%
lbl_xB = lbl.chB.x>= xlB(1) & lbl.chB.x<xlB(2);
assist_xB =assist.chB.mrad.x>xlB(1) & assist.chB.mrad.x< xlB(2);
%
xrangeB = [min([min(lbl.chB.x(lbl_xB)),min(assist.chB.mrad.x(assist_xB))]),...
   max([max(lbl.chB.x(lbl_xB)),max(assist.chB.mrad.x(assist_xB))])];
%
xrangeB = [xrangeB(1):0.005*(diff(lbl.chB.x(1:2))):xrangeB(2)];
lbl_inB_ = 1e7.*interp1(lbl.chB.x,lbl.chB.rad,xrangeB,'linear');
lbl_inB= (lbl_inB_-mean(lbl_inB_));
assist_inB_ = interp1(assist.chB.mrad.x,mean(real(assist.chB.mrad.y(assist.Sky_ii,:))),xrangeB,'linear');
assist_inB = (assist_inB_-mean(assist_inB_));
% figure; plot(xrange, lbl_in,'.r-',xrange,assist_in,'.k-');legend('LBL','ASSIST')
%
corrLength=length(lbl_inB)+length(assist_inB)-1;
c=fftshift(ifft(fft(lbl_inB,corrLength).*conj(fft(assist_inB,corrLength))));
lags = [-(corrLength-1)./2:(corrLength-1)./2];
figure; plot(lags, c,'-k');
[~, lag] = max(c);
wn_offsetB = lags(lag).*diff(xrangeB(1:2));
title(['xcorr max for lag=',num2str(lags(lag))]);

%%
stretchB = (mean(xlB)+wn_offsetB)./mean(xlB);
assist_in2B_ = interp1(stretchB.*assist.chB.mrad.x,mean(real(assist.chB.mrad.y(assist.Sky_ii,:))),xrangeB,'linear');
assist_in2B = (assist_in2B_-mean(assist_in2B_));
corrLength=length(lbl_inB)+length(assist_in2B)-1;
c=fftshift(ifft(fft(lbl_inB,corrLength).*conj(fft(assist_in2B,corrLength))));
lags2 = [-(corrLength-1)./2:(corrLength-1)./2];
[~, lag2] = max(c);
wn_offset2B = lags2(lag2).*diff(xrangeB(1:2));
%
laser_wn_nomB = (assist.chB.mrad.x(2)-assist.chB.mrad.x(1)) .* 2^15;
laser_wn_newB = stretchB.*(assist.chB.mrad.x(2)-assist.chB.mrad.x(1)) .* 2^15;

figure; plot(lbl.chB.x, 1e7.*lbl.chB.rad,'b-', stretchB.*assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'r-'); legend('lbl SW','assist chB');
title({sprintf('Original laser freq=%5.5f ',15798.02); sprintf('Effective laser freq=%5.5f ',laser_wn_newB)})
xlim(xlB)
%%

return