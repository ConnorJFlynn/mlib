%%
% First load aeri and assist data
% This presupposes that you have already processed some ASSIST data that
% is at the same time as some collocated AERI data. 
assist = load(getfullname__('assist_degraded.mat','assist_aeri_compare'));

aeri_ch1 = ancload(getfullname__('tmpaeri*.cdf','assist_aeri_compare'));
aeri_ch2 = ancload(getfullname__('tmpaerich2M1.b1.*.cdf','assist_aeri_compare'));


% Next, identify a clear sky time period by plotting radiance at 900 1/cm
% vs time.  The sky is mostly transparent at this wavelength so clear sky
% will yield low values of sky radiance.
wnum_900_asst = interp1(assist.chA.mrad.x, [1:length(assist.chA.mrad.x)],900,'nearest');
wnum_900_aeri = interp1(aeri_ch1.vars.wnum.data, [1:length(aeri_ch1.vars.wnum.data)],900,'nearest');

figure; plot(serial2hs(assist.time(assist.isSky)), assist.chA.mrad.y(assist.isSky,wnum_900_asst),'-o',...
    serial2hs(aeri_ch1.time), aeri_ch1.vars.mean_rad.data(wnum_900_aeri,:),'-x');legend('assist','aeri');
zoom('on');
title('time series of AERI and ASSIST sky radiance at 900 1/cm');
xlabel('time [UT]');
ylabel('radiance [mW/(m^2 sr cm^-1)]');

OK = menu({'Zoom into time range where radiances';'are low and stable. Click OK when done'},'OK');
tl = xlim;
tl_aeri = serial2hs(aeri_ch1.time)>=tl(1) &  serial2hs(aeri_ch1.time)<=tl(2);
tl_asst = serial2hs(assist.time)>=tl(1) &  serial2hs(assist.time)<=tl(2) & assist.isSky;
tl_abb = serial2hs(assist.time)>=tl(1) &  serial2hs(assist.time)<=tl(2) & assist.isABB;

mean_aeri = mean(aeri_ch1.vars.mean_rad.data(:,tl_aeri),2);
mean_asst = mean(assist.chA.mrad.y(tl_asst,:));
mean_abb = mean(assist.chA.mrad.y(tl_abb,:));
mean_asst_T = mean(assist.chA.T_bt(tl_asst,:));
mean_aeri_T = BrightnessTemperature(aeri_ch1.vars.wnum.data, real(mean_aeri));

mean_aeri_ch2 = mean(aeri_ch2.vars.mean_rad.data(:,tl_aeri),2);
mean_asst_ch2 = mean(assist.chB.mrad.y(tl_asst,:));
mean_abb_ch2 = mean(assist.chB.mrad.y(tl_abb,:));
mean_asst_T_ch2 = mean(assist.chB.T_bt(tl_asst,:));
mean_aeri_T_ch2 = BrightnessTemperature(aeri_ch2.vars.wnum.data, real(mean_aeri_ch2));


figure; 
s(1) = subplot(2,1,1);
plot(assist.chA.mrad.x, mean_asst, '-r.',aeri_ch1.vars.wnum.data, mean_aeri,'-b.', assist.chA.mrad.x, mean_abb, 'k-');
title('mean radiances');
legend('assist','aeri', 'ABB')
ylabel('RU')
title(['ASSIST and AERI mean radiances from UT 01-02 2014_05_17'],'interp','none');

s(2) = subplot(2,1,2);
plot(assist.chA.mrad.x, mean_asst_T, '-r.',aeri_ch1.vars.wnum.data, mean_aeri_T,'-b.');
title('mean brightness temp');
legend('assist','aeri')

xlabel('wavenumber')
ylabel('K')
linkaxes(s,'x');
xlim([350,1800]);

figure; 
ss(1) = subplot(2,1,1);
plot(assist.chB.mrad.x, mean_asst_ch2, '-r.',aeri_ch2.vars.wnum.data, mean_aeri_ch2,'-b.', assist.chB.mrad.x, mean_abb_ch2, 'k-');
title('mean radiances');
legend('assist','aeri', 'ABB')
ylabel('RU')
title(['ASSIST and AERI mean radiances from UT 01-02 2014_05_17'],'interp','none');

ss(2) = subplot(2,1,2);
plot(assist.chB.mrad.x, mean_asst_T_ch2, '-r.',aeri_ch2.vars.wnum.data, mean_aeri_T_ch2,'-b.');
title('mean brightness temp');
legend('assist','aeri')

xlabel('wavenumber')
ylabel('K')
linkaxes(ss,'x');
xlim([350,1800]);


%Next, find a spectral region with some significant structure.  
OK = menu({'Zoom into spectral range over which to assess ';'the spectral registration. Click OK when done'},'OK');

xl = xlim;
aeri_x = aeri_ch1.vars.wnum.data> xl(1) & aeri_ch1.vars.wnum.data<xl(2);
assist_x =assist.chA.mrad.x>xl(1) & assist.chA.mrad.x< xl(2);

xrange = [min([min(aeri_ch1.vars.wnum.data(aeri_x)),min(assist.chA.mrad.x(assist_x))]),...
   max([max(aeri_ch1.vars.wnum.data(aeri_x)),max(assist.chA.mrad.x(assist_x))])];
xrange = [xrange(1):0.001*(diff(aeri_ch1.vars.wnum.data(1:2))):xrange(2)];


aeri_in = interp1(aeri_ch1.vars.wnum.data,mean_aeri,xrange,'linear');
assist_in = interp1(assist.chA.mrad.x,mean_asst',xrange,'linear');
aeri_in_T = interp1(aeri_ch1.vars.wnum.data,mean_aeri_T,xrange,'linear');
assist_in_T = interp1(assist.chA.mrad.x,mean_asst_T',xrange,'linear');

% Subtract the mean value over this limited spectral range.
aeri_in = aeri_in - mean(aeri_in);
assist_in = assist_in - mean(assist_in);
aeri_in_T = aeri_in_T - mean(aeri_in_T);
assist_in_T = assist_in_T - mean(assist_in_T);

% We could also consider normalizing the max amplitude to 1, but I think it
% is unnecessary.  

figure; plot(xrange, aeri_in,'.r',xrange,assist_in,'.k');
%% Next, compute lags and find position of maximum correlation
[R,lags] = xcorr(aeri_in',assist_in',400);
[R_T] = xcorr(aeri_in_T',assist_in_T',400);

lag_max = find(R==max(R),1,'first');
lag_max_T = find(R_T==max(R_T),1,'first');

wn_offset = lags(lag_max).*diff(xrange(1:2));
wn_offset_T = lags(lag_max_T).*diff(xrange(1:2));

figure; ss(1) = subplot(2,1,1);plot(lags, R,'.r-',lags(lag_max), R(lag_max),'or');

title(['xcorr max for lag=',num2str(lags(lag_max)),' gives offset of',num2str(wn_offset),'1/cm']);

ss(2) =subplot(2,1,2); plot(lags, R_T,'-b.',lags(lag_max_T), R_T(lag_max_T),'bo');
title(['xcorr max for lag=',num2str(lags(lag_max_T)),' gives offset of',num2str(wn_offset_T),'1/cm']);

linkaxes(ss,'x');zoom('on');
% Although the lag is expressed as an "offset", we really want this as a
% scale factor or a "stretch".  So convert the offset to a scale factor by
% appplying to the center of our selected spectral range
new_cl = mean(xl) - wn_offset; 
new_cl_T = mean(xl) - wn_offset_T; 
wn_stretch = new_cl / mean(xl);
wn_stretch_T = new_cl_T / mean(xl);
assist.chA.mrad.new_x = assist.chA.mrad.x.*wn_stretch;
log([wn_stretch, wn_stretch_T])