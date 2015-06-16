% % Calibration of PNNL integrating sphere...
% % Use comparison data collected with SWS at NASA Ames to establish
% % calibration for a given lamp voltage and current.
% % This data resides here: C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19
% clear
% Optronics.radiance_units = ['W/(m^2.sr.nm)'];
% Optronics.nm = [400 410 420 430 440 450 460 470 480 490 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800 810 820 830 840 850 860 870 880 890 900 910 920 930 940 950 960 970 980 990 1000 1010 1020 1030 1040 1050 1060 1070 1080 1090 1100 1110 1120 1130 1140 1150 1160 1170 1180 1190 1200 1210 1220 1230 1240 1250 1260 1270 1280 1290 1300 1310 1320 1330 1340 1350 1360 1370 1380 1390 1400 1410 1420 1430 1440 1450 1460 1470 1480 1490 1500 1510 1520 1530 1540 1550 1560 1570 1580 1590 1600 1610 1620 1630 1640 1650 1660 1670 1680 1690 1700 1710 1720 1730 1740 1750 1760 1770 1780 1790 1800 1810 1820 1830 1840 1850 1860 1870 1880 1890 1900 1910 1920 1930 1940 1950 1960 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070 2080 2090 2100 2110 2120 2130 2140 2150 2160 2170 2180 2190 2200 2210 2220 2230 2240 2250 2260 2270 2280 2290 2300 2310 2320 2330 2340 2350 2360 2370 2380]';
% Optronics.Aper_A.rad = 1e-3*[29.6 36.9 45.6 54.7 64.6 75.3 87 98.9 112 126 140 155 171 187 203 220 236 253 269 285 304 320 336 352 368 383 399 415 429 445 459 474 489 501 511 522 531 540 548 555 561 566 571 578 583 590 596 603 611 619 625 633 644 648 653 660 666 673 676 681 684 686 687 687 687 687 687 686 684 683 678 671 664 660 655 651 646 640 633 631 628 625 623 619 615 609 603 596 589 584 578 570 562 552 542 517 491 483 475 468 461 462 462 460 457 453 449 443 436 433 429 423 417 412 406 400 394 390 385 380 376 369 363 356 350 342 334 325 315 306 298 293 288 285 281 280 279 276 274 268 263 254 246 237 227 223 218 215 212 207 202 196 191 188 185 179 173 167 161 154 147 139 132 125 118 113 108 104 99.9 95.4 90.8 86.5 82.1 80.9 79.7 82.2 84.7 89.3 93.9 97.3 101 101 100 98.4 96.3 92.9 89.5 85.2 80.8 76.7 72.5 69.7 66.8 63.4 59.9 57.7 55.4 54 52.5]';
% Optronics.Open.rad = 1e-3*[106	131.4	161.4	195.7	229.8	267.3	308.4	351.6	396.4	448.2	498.6	553.2	608	665	723.1	779.8	 839.3	898.7	956	1014	1074	1132.6 1189	1244.9 1298.1 1351.5 1402.3 1451.3 1500.9 1548.9 1595.4 1639.4 1680.8 1720	1753.4 1787	1817.4 1846.6 1873.9 1896.7 1916.1 1936.3 1953	1972.9 1988.6 2010.5 2031.7 2053.6 2075.3 2101.9 2117.7 2142.3 2167.8 2179.3 2191	 2209.9 2229.7 2241.1 2251.1 2266.5 2279.7 2280.5 2274.9 2275.7 2279	 2280.8 2275.4 2253.3 2236.5 2239.5 2221.1 2156.5 2149.1 2113	 2054.5 2058.5 2022.5 1989.3 1952.8 1914	 1859.2 1821.6 1753.8 1604.3 1541.7 1508.3 1517.6 1473.5 1464.4 1420.9 1384	1364.8 1321.2 1280.8 1248.3 1209.4 1174.5 1123.9 1071.2 1011.3 958.8	934.7	903.9	900.5	881.7	842.5	789.6	732.8	692.9	675.5	646.5	619	617.1	581.4	539.6	485.8	431.3	383.9	347.8	327.3	296.6	270.5	255 277.4 316.1 337.1 333.3 315.9 290.9 261.1	236.3	210.3	183.4	160.8	148.8	];
% 
% % In NASA source file: [W/(sr m^2 um)]
% % Use swscal.20081120.0342 with Si_tint AperA and 125 ms and In_tint 65 ms
% % C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\
% % cal\_NASA_ARC_2008_11_20\optronics\20081120.033844
% 
% % Next, read in SWS data for this sphere.
% % Subtract darks
% % Normalize to mS by dividing by integration time.
% 
% sws_Optronics_cal = read_sws_cal_pair;
% %%
% Optronics.Aper_A.Si_rad = interp1(Optronics.nm,Optronics.Aper_A.rad,sws_Optronics_cal.Si_lambda, 'linear','extrap');
% Optronics.Aper_A.In_rad = interp1(Optronics.nm,Optronics.Aper_A.rad,sws_Optronics_cal.In_lambda, 'linear','extrap');
% %%
% sws_Optronics_cal.Si_cal = Optronics.Aper_A.Si_rad./sws_Optronics_cal.avg_Si_per_ms;
% sws_Optronics_cal.In_cal = Optronics.Aper_A.In_rad./sws_Optronics_cal.avg_In_per_ms;
% %%
% 
% % Now read a Labsphere calibration comparison:
% % using data in dir 20081120.192500 and plot swscal.20081120.1928.png
% % Compute normalized spectra and apply calibration from Optronics to yield
% % Labsphere radiances for V and I readings: V = 10.43, I = 2.78A
% sws_Labsphere_cal = read_sws_cal_pair;
% sws_Labsphere_cal.Si_rad = sws_Labsphere_cal.avg_Si_per_ms .* sws_Optronics_cal.Si_cal;
% sws_Labsphere_cal.In_rad = sws_Labsphere_cal.avg_In_per_ms .* sws_Optronics_cal.In_cal;
% %%
% figure; plot(sws_Labsphere_cal.Si_lambda, sws_Labsphere_cal.Si_rad, 'b-',...
% sws_Labsphere_cal.In_lambda, sws_Labsphere_cal.In_rad, 'b-',...
% sws_Optronics_cal.Si_lambda, Optronics.Aper_A.Si_rad,'k-',...
% sws_Optronics_cal.In_lambda, Optronics.Aper_A.In_rad,'k-')
% %%
% % Compute calibration = interpolated Optronics ./ normalized SWS spectra
% % Thereafter, calibrate SWS spectra by multiplying normalized (DN-dark)
% % spectra by this calibration vector.
% % For PNNL Labsphere integrating sphere, this yields radiance calibration
% % of sphere. 
% % There is an evident mismatch between these calibrations, possibly due to
% % temperature drift of the InGaAs.  We'll apply an adhoc adjustment by
% % pinning the InGaAs radiance to match the Si radiance between 975-1050 nm.
% In_match = sws_Labsphere_cal.In_lambda>=1050 & sws_Labsphere_cal.In_lambda<=1075;
% Si_match = sws_Labsphere_cal.Si_lambda>=1050 & sws_Labsphere_cal.Si_lambda<=1075;
% 
% labsphere_In_pin = mean(sws_Labsphere_cal.Si_rad(Si_match))./mean(sws_Labsphere_cal.In_rad(In_match));
% figure; plot(sws_Labsphere_cal.Si_lambda, sws_Labsphere_cal.Si_rad, 'b-',...
% sws_Labsphere_cal.In_lambda, labsphere_In_pin.*sws_Labsphere_cal.In_rad, 'b-',...
% sws_Optronics_cal.Si_lambda, Optronics.Aper_A.Si_rad,'k-',...
% sws_Optronics_cal.In_lambda, Optronics.Aper_A.In_rad,'k-');
% %%
% 
% labsphere.nm = [sws_Labsphere_cal.Si_lambda(sws_Labsphere_cal.Si_lambda<1060);sws_Labsphere_cal.In_lambda(sws_Labsphere_cal.In_lambda>=1060)];
% labsphere.rad = [sws_Labsphere_cal.Si_rad(sws_Labsphere_cal.Si_lambda<1060); labsphere_In_pin.*sws_Labsphere_cal.In_rad(sws_Labsphere_cal.In_lambda>=1060)];
% figure; plot(sws_Labsphere_cal.Si_lambda, sws_Labsphere_cal.Si_rad, 'b-',...
% sws_Labsphere_cal.In_lambda, labsphere_In_pin.*sws_Labsphere_cal.In_rad, 'b-',...
% labsphere.nm, labsphere.rad, 'r.');
% save('C:\mlib\ARRA_SAS\adhoc_labsphere_cal.mat', 'labsphere');
%%
labsphere = loadinto('C:\mlib\ARRA_SAS\adhoc_labsphere_cal.mat');
% Okay, this should be the calibration for our Labsphere
% So now read in the data from each spectrometer looking at this sphere to
% derive the calibration fro the spectrometers. Then apply these to the sky
% radiance data.


%%
% SN 0911146U1: NIR
% SN 0911137U1: CCDx14
% SN 0911134U1: CCD
% SN 0911129U1: CMOS
CCD34 = SAS_read_ava(getfullname('*.csv','ava','Select Zenith collimator spectra for CCD34'));
CCD34.dark = sum(CCD34.spec,2)<mean(sum(CCD34.spec,2));
CCD34.darks = mean(CCD34.spec(CCD34.dark,:),1);
CCD34.lights = mean(CCD34.spec(~CCD34.dark,:),1)-CCD34.darks;
CCD34.lights_per_ms = CCD34.lights./mean(CCD34.Intgration);
CCD34.rad = interp1(labsphere.nm, labsphere.rad, CCD34.nm, 'linear','extrap');
CCD34.cal = CCD34.rad./CCD34.lights_per_ms;

figure; subplot(2,1,1); plot(CCD34.nm, CCD34.darks, 'k-');
title('Zenith darks');
subplot(2,1,2); semilogy(CCD34.nm, CCD34.lights,'b-');
title('Zenith DN-darks');
%%
CCDx37 = SAS_read_ava(getfullname('*.csv','ava','Select Zenith collimator spectra for CCDx37'));
CCDx37.dark = sum(CCDx37.spec,2)<mean(sum(CCDx37.spec,2));
CCDx37.darks = mean(CCDx37.spec(CCDx37.dark,:),1);
CCDx37.lights = mean(CCDx37.spec(~CCDx37.dark,:),1)-CCDx37.darks;
CCDx37.lights_per_ms = CCDx37.lights./mean(CCDx37.Intgration);
CCDx37.rad = interp1(labsphere.nm, labsphere.rad, CCDx37.nm, 'linear','extrap');
CCDx37.cal = CCDx37.rad./CCDx37.lights_per_ms;

figure; subplot(2,1,1); plot(CCDx37.nm, CCDx37.darks, 'k-');
title('Zenith darks');
subplot(2,1,2); semilogy(CCDx37.nm, CCDx37.lights,'b-');
title('Zenith DN-darks');
%%
NIR_46 = SAS_read_ava(getfullname('*.csv','ava','Select Zenith collimator spectra for NIR_46'));
NIR_46.dark = sum(NIR_46.spec,2)<mean(sum(NIR_46.spec,2));
NIR_46.darks = mean(NIR_46.spec(NIR_46.dark,:),1);
NIR_46.lights = mean(NIR_46.spec(~NIR_46.dark,:),1)-NIR_46.darks;
NIR_46.lights_per_ms = NIR_46.lights./mean(NIR_46.Intgration);
NIR_46.rad = interp1(labsphere.nm, labsphere.rad, NIR_46.nm, 'linear','extrap');
NIR_46.cal = NIR_46.rad./NIR_46.lights_per_ms;

figure; subplot(2,1,1); plot(NIR_46.nm, NIR_46.darks, 'k-');
title('Zenith darks');
subplot(2,1,2); semilogy(NIR_46.nm, NIR_46.lights,'b-');
title('Zenith DN-darks');
%%
% Next, read in each of the zenith sky measurements, apply calibration and
% plot
NIR = SAS_read_ava(getfullname('*.csv','ava','Select NIR 0911146U1 spectrometer'));
NIR.time(NIR.Intgration==100) = [];
NIR.Averages(NIR.Intgration==100) = [];
NIR.Temp(NIR.Intgration==100) = [];
NIR.spec(NIR.Intgration==100,:) = [];
NIR.Intgration(NIR.Intgration==100) = [];
NIR = rmfield(NIR,'Shuttered_0');
NIR.sums = sum(NIR.spec,2);
NIR.dark = NIR.sums<mean(NIR.sums);
figure; 
subplot(2,1,1); plot(NIR.nm, NIR.spec, '-');
subplot(2,1,2); plot(NIR.nm, NIR.spec(NIR.dark,:),'-')
figure; semilogy(NIR.nm, NIR.spec(~NIR.dark,:)-ones([sum(~NIR.dark),1])*mean(NIR.spec(NIR.dark,:)),'-');
title('NIR dark-subtracted zenith signal');
NIR.lights_per_ms = (NIR.spec(~NIR.dark,:)-ones([sum(~NIR.dark),1])*mean(NIR.spec(NIR.dark,:)))./unique(NIR.Intgration(~NIR.dark));
NIR.rad = NIR.lights_per_ms .* (ones([size(NIR.lights_per_ms,1),1])*NIR_46.cal);
figure; semilogy(NIR.nm, NIR.rad,'-');
title('NIR dark-subtracted zenith signal');
%%
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
subplot(2,1,2); plot(CCD.nm, CCD.spec(CCD.dark,:),'-');
CCD.lights_per_ms = (CCD.spec(~CCD.dark,:)-ones([sum(~CCD.dark),1])*mean(CCD.spec(CCD.dark,:)))./unique(CCD.Intgration(~CCD.dark));

CCD.rad = CCD.lights_per_ms .* (ones([size(CCD.lights_per_ms,1),1])*CCD34.cal);
figure; semilogy(CCD.nm, CCD.rad,'-');
title('CCD calibrated radiance');

%%
CCDx = SAS_read_ava(getfullname('*.csv','ava','Select CCD 0911137U1 spectrometer'));
CCDx = rmfield(CCDx,'Shuttered_0');
CCDx.sums = sum(CCDx.spec,2);
%%
CCDx.dark = CCDx.sums<mean(CCDx.sums);
figure; 
subplot(2,1,1); plot(CCDx.nm, CCDx.spec, '-');
subplot(2,1,2); plot(CCDx.nm, CCDx.spec(CCDx.dark,:),'-')
CCDx.lights_per_ms = (CCDx.spec(~CCDx.dark,:)-ones([sum(~CCDx.dark),1])*mean(CCDx.spec(CCDx.dark,:)))./unique(CCDx.Intgration(~CCDx.dark));
CCDx.rad = CCDx.lights_per_ms./(ones([size(CCDx.lights_per_ms,1),1])*CCDx37.cal);
figure; semilogy(CCDx.nm, CCDx.rad,'-')
title('CCDx14 radiance')
%%
figpos = get(gcf,'position');
axpos = get(gca,'position');
figure; semilogy(log10(CCD.nm(CCD.nm<915)), CCD.rad(:,CCD.nm<915),'-',log10(NIR.nm), NIR.rad,'-');
set(gca,'xtick',log10([300,450,600,800,1100,1400,1700]));
set(gca,'xticklabel',num2str([300;450;600;800;1100;1400;1700]))
title('SAS-Ze measured zenith radiance, Richland WA. Feb 25 2010')
ylabel({'radiance','[W/m^2-sr]'});
xlabel('wavelength [nm]')
xlim(log10([300, 1700])); 
set(gca, 'xgrid','on', 'xminorgrid','off')
set(gca,'ygrid','on','yminorgrid','off')
set(gca, 'xgrid','on', 'xminorgrid','on')
set(gca, 'xgrid','on', 'xminorgrid','off')
set(gcf,'position',figpos); set(gca,'units','normalized','position',axpos)
%%
% CCD34	CMOS
% col	bare	: starting with 181
% col	bare	: ending with 220 (after adjusting tints) weird 12-bit saturation with CCD?
% bare 	col	: starting with 220 (visible drop in CMOS)
% 	
% CCD34	CCDx	
% bare	col	: starting with 241 after adjusting CCDx tint to 10 ms
% col 	bare	: starting with 261 after swap (adjusted tint CCDx with typo to 70, then 7)
% 
% CCD34	NIR	
% col	bare	: starting with 300?
% bare	col	: starting with
% 
% darks thereafter but crashed when trying to get them.