%
% compare AERI 01 to AERI E14

% First read AERI01 summary file and plot some brightness temperatures.
% Zoom into a clear sky region to use for the comparison.

aesum = ancload(['C:\case_studies\assist\integration\data_integration\at_SGP\aeri01\sgpaeri01summaryC1.a1.20100518.001025.cdf']);
%%
 figure; plot(serial2doy(aesum.time), [aesum.vars.elevatedLayerAirTemp700_705.data;aesum.vars.longwaveWindowAirTemp985_990.data;aesum.vars.surfaceLayerAirTemp675_680.data],'-');
 legend('elevated','window','surface');
 xlabel('time');
 ylabel('brightness temperature');
 zoom('on');
 %%
 k = menu('Zoom into a clear sky time period and select OK','OK');
 xl = xlim;
 clearsky = (serial2doy(aesum.time)>xl(1))&(serial2doy(aesum.time)<xl(2));
 
 %%
 aeri01 = ancload(['C:\case_studies\assist\integration\data_integration\at_SGP\aeri01\sgpaeri01ch1C1.a1.20100518.001025.cdf']);
 aeri01_ch2 = ancload(['C:\case_studies\assist\integration\data_integration\at_SGP\aeri01\sgpaeri01ch2C1.a1.20100518.001025.cdf']);

 %%
 figure; plot(aeri01.vars.wnum.data, aeri01.vars.mean_rad.data(:,clearsky),'-');
 
 %%
 aeriE14 = ancload(['C:\case_studies\assist\integration\data_integration\at_SGP\aeri_data\sgpaerich1E14.b1.20100518.000228.cdf']);
 aeriE14_ch2 = ancload(['C:\case_studies\assist\integration\data_integration\at_SGP\aeri_data\sgpaerich2E14.b1.20100518.000228.cdf']);
 [ainb,bina] = nearest(aeri01.time(clearsky), aeriE14.time);
 
 %%
 clearsky_ii = find(clearsky);
 %%
 figure; 
sb(1) = subplot(2,1,1); plot([aeri01.vars.wnum.data;aeri01_ch2.vars.wnum.data], [aeri01.vars.mean_rad.data(:,clearsky_ii(ainb(1)));aeri01_ch2.vars.mean_rad.data(:,clearsky_ii(ainb(1)))],'r-',...
    [aeriE14.vars.wnum.data;aeriE14_ch2.vars.wnum.data], [aeriE14.vars.mean_rad.data(:,bina(1));aeriE14_ch2.vars.mean_rad.data(:,bina(1))],'k-');
 legend('AERI 01','AERI E14');
 xlabel('wavenumber [1/cm]');
 ylabel('radiance [mw/m^2 sr cm^-1]')
 grid('on')
sb(2) = subplot(2,1,2); plot(aeri01.vars.wnum.data, aeri01.vars.mean_rad.data(:,clearsky_ii(ainb(1)))- ...
   aeriE14.vars.mean_rad.data(:,bina(1)),'r-', aeri01_ch2.vars.wnum.data([1:end-1]),aeri01_ch2.vars.mean_rad.data([1:end-1],clearsky_ii(ainb(1)))- ...
aeriE14_ch2.vars.mean_rad.data(:,bina(1)),'r-');
title('AERI 01 - AERI E14')
xlabel('wavenumber [1/cm]');
 ylabel('radiance [mw/m^2 sr cm^-1]')
 grid('on')
 %%
sb(2) = subplot(2,1,2); plot(aeri01.vars.wnum.data, 100.*(aeri01.vars.mean_rad.data(:,clearsky_ii(ainb(1)))- ...
   aeriE14.vars.mean_rad.data(:,bina(1)))./aeriE14.vars.mean_rad.data(:,bina(1)),'r-',...
   aeri01_ch2.vars.wnum.data([1:end-1]), 100.*(aeri01_ch2.vars.mean_rad.data([1:end-1],clearsky_ii(ainb(1)))- ...
   aeriE14_ch2.vars.mean_rad.data(:,bina(1)))./aeriE14_ch2.vars.mean_rad.data(:,bina(1)),'r-');
title('100*(AERI 01 - AERI E14)/(AERI E14)')
xlabel('wavenumber [1/cm]');
 ylabel('%')
 sb(2) = subplot(2,1,2); plot(aeri01.vars.wnum.data, (aeri01.vars.mean_rad.data(:,clearsky_ii(ainb(1)))- ...
   aeriE14.vars.mean_rad.data(:,bina(1))),'r-',...
   aeri01_ch2.vars.wnum.data([1:end-1]), (aeri01_ch2.vars.mean_rad.data([1:end-1],clearsky_ii(ainb(1)))- ...
   aeriE14_ch2.vars.mean_rad.data(:,bina(1))),'r-');
title('(AERI 01 - AERI E14)')
xlabel('wavenumber [1/cm]');
ylabel('radiance [mw/m^2 sr cm^-1]')
 grid('on')
zoom('on')
linkaxes(sb,'x');
%%
ch1_wnum = downsample(aeri01.vars.wnum.data,20);
ch1_diffs = (aeri01.vars.mean_rad.data(:,clearsky_ii(ainb(1)))- ...
   aeriE14.vars.mean_rad.data(:,bina(1)));
ch1_diffs = downsample(ch1_diffs,20,1);

ch2_wnum = downsample(aeri01_ch2.vars.wnum.data([1:end-1]),20);
ch2_diffs = (aeri01_ch2.vars.mean_rad.data([1:end-1],clearsky_ii(ainb(1)))- ...
   aeriE14_ch2.vars.mean_rad.data(:,bina(1)));
ch2_diffs = downsample(ch2_diffs,20,1);

figure; s(1)=subplot(2,1,1);
plot(ch1_wnum, mean(ch1_diffs,2), '-', ch2_wnum, mean(ch2_diffs,2), '-');
title('Mean radiance differences averages over 10 1/cm, AERI - ASSIST')
ylabel('mW/(sr-m^2-cm^-^1)')
legend('Ch A','Ch B')
s(2)=subplot(2,1,2); 
plot(ch1_wnum, 100.*mean(ch1_diffs,2)./mean(downsample(aeri01.vars.mean_rad.data(:,clearsky_ii(ainb)),20),2), '-', ...
   ch2_wnum, 100.*mean(ch2_diffs,2)./mean(downsample(aeri01_ch2.vars.mean_rad.data([1:end-1],clearsky_ii(ainb)),20),2), '-');
title('Percent differences: AERI - ASSIST')
ylabel('%')
legend('Ch A','Ch B')

linkaxes(s,'x')
