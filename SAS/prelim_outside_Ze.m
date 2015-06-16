function prelim_outside_Ze
% Zenith radiance data taken on Feb 25 2010 with 4 spectrometers in freezer
% via 600 um core fiber and the Thorlabs RC08FC off-axis parabolic collimator

% Quasi-blue sky with some high thin diffuse cirrus beginning to drift in
% with time.

% Each spectrometer collected with darks (should be obvious from data)
% SN 0911146U1: NIR
% SN 0911137U1: CCDx14
% SN 0911134U1: CCD
% SN 0911129U1: CMOS
%%
NIR = SAS_read_ava(getfullname('*.csv','ava','Select NIR 0911146U1 spectrometer'));
NIR.time(NIR.Intgration==100) = [];
NIR.Averages(NIR.Intgration==100) = [];
NIR.Temp(NIR.Intgration==100) = [];
NIR.spec(NIR.Intgration==100,:) = [];
NIR.Intgration(NIR.Intgration==100) = [];
NIR = rmfield(NIR,'Shuttered_0');
NIR.sums = sum(NIR.spec,2);
%%
NIR.dark = NIR.sums<mean(NIR.sums);
figure; 
subplot(2,1,1); plot(NIR.nm, NIR.spec, '-');
subplot(2,1,2); plot(NIR.nm, NIR.spec(NIR.dark,:),'-')
figure; semilogy(NIR.nm, NIR.spec(~NIR.dark,:)-ones([sum(~NIR.dark),1])*mean(NIR.spec(NIR.dark,:)),'-');
title('NIR dark-subtracted zenith signal')
%%
%
CCD = SAS_read_ava(getfullname('*.csv','ava','Select CCD 0911134U1spectrometer'));
CCD.time(CCD.Intgration>=100) = [];
CCD.Averages(CCD.Intgration>=100) = [];
CCD.Temp(CCD.Intgration>=100) = [];
CCD.spec(CCD.Intgration>=100,:) = [];
CCD.Intgration(CCD.Intgration>=100) = [];
CCD = rmfield(CCD,'Shuttered_0');
CCD.sums = sum(CCD.spec,2);
%%
CCD.dark = CCD.sums<mean(CCD.sums);
figure; 
subplot(2,1,1); plot(CCD.nm, CCD.spec, '-');
subplot(2,1,2); plot(CCD.nm, CCD.spec(CCD.dark,:),'-')
figure; semilogy(CCD.nm, CCD.spec(~CCD.dark,:)-ones([sum(~CCD.dark),1])*mean(CCD.spec(CCD.dark,:)),'-')
title('CCD dark-subtracted zenith signal')

%%
CCDx = SAS_read_ava(getfullname('*.csv','ava','Select CCD 0911137U1 spectrometer'));
%
% CCDx.time(CCDx.Intgration>=100) = [];
% CCDx.Averages(CCDx.Intgration>=100) = [];
% CCDx.Temp(CCDx.Intgration>=100) = [];
% CCDx.spec(CCDx.Intgration>=100,:) = [];
% CCDx.Intgration(CCDx.Intgration>=100) = [];
CCDx = rmfield(CCDx,'Shuttered_0');
CCDx.sums = sum(CCDx.spec,2);
%%
CCDx.dark = CCDx.sums<mean(CCDx.sums);
figure; 
subplot(2,1,1); plot(CCDx.nm, CCDx.spec, '-');
subplot(2,1,2); plot(CCDx.nm, CCDx.spec(CCDx.dark,:),'-')
figure; semilogy(CCDx.nm, CCDx.spec(~CCDx.dark,:)-ones([sum(~CCDx.dark),1])*mean(CCDx.spec(CCDx.dark,:)),'-')
title('CCDx14 dark-subtracted zenith signal')
%%
CMOS = SAS_read_ava(getfullname('*.csv','ava','Select CCD 0911129U1 spectrometer'));
%%
CMOS.time(CMOS.Intgration==100) = [];
CMOS.Averages(CMOS.Intgration==100) = [];
CMOS.Temp(CMOS.Intgration==100) = [];
CMOS.spec(CMOS.Intgration==100,:) = [];
CMOS.Intgration(CMOS.Intgration==100) = [];
CMOS = rmfield(CMOS,'Shuttered_0');
CMOS.sums = sum(CMOS.spec,2);
%
CMOS.dark = CMOS.sums<mean(CMOS.sums);
figure; 
subplot(2,1,1); plot(CMOS.nm, CMOS.spec, '-');
subplot(2,1,2); plot(CMOS.nm, CMOS.spec(CMOS.dark,:),'-');
%%
figure; semilogy(CMOS.nm, CMOS.spec(~CMOS.dark,:)-ones([sum(~CMOS.dark),1])*mean(CMOS.spec(CMOS.dark,:)),'-');
title('CMOS dark-subtracted zenith signal')