function aod_be_plots_kassianov

% Need to load the afit output mat files, generate time-series and X-Y
% plots

% Mat files saved to: C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\hou\
% for structs produced from afit_lang_tau_series: ttau, lang_legs, dirbeams, rVos, ttau2, llegs2, rVos2, dbeams
% ttau: ttau.cim_mfr7.mat
% lang_legs: lang_legs.cim_mfr7.mat
% dirbeams: dirbeams.cim_mfr7_sas.mat (most direct SAS AOD data)
% 
outp = ['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\hou\'];
ttau = load(getfullname([outp,'ttau.*.mat']));
lang_legs = load(getfullname([outp,'lang_legs.*.mat']));
dirbeams = load(getfullname([outp,'dirbeams.*.mat']));
ttau2 = load(getfullname([outp,'ttau2.*.mat'])); % Confused by mismatch between ttau2 and dbeams
dbeams = load(getfullname([outp,'dbeams.*.mat']));

src = 1;
anet.wls = unique(ttau.nm(ttau.srctag==src));
anet.wl = ttau.nm(ttau.srctag==src);
anet.time = ttau.time(ttau.srctag==src);
anet.time_LST = ttau.time_LST(ttau.srctag==src);
anet.oam = ttau.airmass(ttau.srctag==src);
anet.aod = ttau.aod(ttau.srctag==src);
anet.aod_1p6 = ttau.aod_1p6(ttau.srctag==src);

src = 2;
mfr.wls = unique(ttau.nm(ttau.srctag==src));
mfr.wl = ttau.nm(ttau.srctag==src);
mfr.time_LST = ttau.time_LST(ttau.srctag==src);
mfr.time = ttau.time(ttau.srctag==src);
mfr.oam = ttau.airmass(ttau.srctag==src);
mfr.aod = ttau.aod(ttau.srctag==src);
mfr.aod_1p6 = ttau.aod_1p6(ttau.srctag==src);

figure; plot(anet.time_LST(anet.wl==1640), anet.aod(anet.wl==1640),'o',...
   anet.time_LST(anet.wl==1640), anet.aod_1p6(anet.wl==1640),'x', ...
   mfr.time_LST(mfr.wl>1000), mfr.aod(mfr.wl>1000), 'o',...
  mfr.time_LST(mfr.wl>1000), mfr.aod_1p6(mfr.wl>1000), '+');
dynamicDateTicks; legend('anet','a 1p6','mfr', 'm 1p6')

wl_a_500 = find(anet.wl==500);wl_m_500 = find(mfr.wl>500&mfr.wl<600);
[ainm, mina] = nearest(anet.time(wl_a_500), mfr.time(wl_m_500));
wl_a_500 = wl_a_500(ainm); wl_m_500 = wl_m_500(mina);

figure; plot(anet.time(wl_a_500), anet.aod(wl_a_500),'o',mfr.time(wl_m_500), mfr.aod(wl_m_500),'x');
dynamicDateTicks

D = den2plot(anet.aod(wl_a_500), mfr.aod(wl_m_500));
figure; scatter(anet.aod(wl_a_500), mfr.aod(wl_m_500),4,D,'filled'); colormap(comp_map_w_jet)
xl = xlim; xlim([0,xl(2)]); ylim(xlim); axis('square');
figure; scatter(anet.aod(wl_a_500), mfr.aod(wl_m_500),4,log10(D),'filled'); colormap(comp_map_w_jet)
xl = xlim; xlim([0,xl(2)]); ylim(xlim); axis('square')


[good, P_bar] = rbifit(anet.aod(wl_a_500), mfr.aod(wl_m_500),3,0, []);
xlabel('Aeronet AOD');ylabel('MFRSR AOD');
title('Aeronet and ARM AOD 500 um')
 xlim([0,.45]); ylim(xlim); axis('square')
[gt,txt, stats] = txt_stat(anet.aod(wl_a_500(good)), mfr.aod(wl_m_500(good)),P_bar);
hold('on'); plot(anet.aod(wl_a_500(~good)), mfr.aod(wl_m_500(~good)),'k.'); hold('off');

figure; scatter(X,Y,4,D);colormap(comp_map_w_jet)

figure; densityplot([0;anet.aod(wl_a_500)], [0;mfr.aod(wl_m_500)],'nbins',[100,100]);
cmap = wrgbk; cmap(1,:) = 1; colormap(cmap)
colormap(comp_map_w_jet)
xlabel('Aeronet AOD');ylabel('MFRSR AOD');
title('Aeronet and MFRSR AOD 500 um')
 ylim(xlim); axis('square')
  xlim([0,.4])

[gt,txt, stats] = txt_stat(anet.aod(wl_a_500(good)), mfr.aod(wl_m_500(good)),P_bar);
Select figure to add stats
xlabel('Aeronet AOD');ylabel('MFRSR AOD');
title('Aeronet and ARM MFRSR 500 um')
 xlim([0,.45]); ylim(xlim); axis('square')

 [db_ainm, db_mina] = nearest(dbeams.anet.time_LST, dbeams.mfrM1.time_LST);
 figure; plot(dbeams.anet.aod(4,db_ainm), dbeams.mfrM1.aod(2,db_mina),'.')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
[good, P_bar] = rbifit(dbeams.anet.aod(4,db_ainm), dbeams.mfrM1.aod(2,db_mina),3,0, []);
[gt,txt, stats] = txt_stat(dbeams.anet.aod(4,db_ainm(good)), dbeams.mfrM1.aod(2,db_mina(good)),P_bar);
hold('on'); plot(dbeams.anet.aod(4,db_ainm(~good)), dbeams.mfrM1.aod(2,db_mina(~good)),'k.'); hold('off');
xlabel('Aeronet AOD');ylabel('MFRSR AOD');
title('Aeronet and ARM AOD 500 um')

figure; densityplot(dbeams.anet.aod(4,db_ainm), dbeams.mfrM1.aod(2,db_mina),'nbins',[250,250]);
cmap = wrgbk; cmap(1,:) = 1; colormap(cmap)
colormap(comp_map_w_jet)
xlabel('Aeronet AOD');ylabel('MFRSR AOD');
title('Aeronet and ARM AOD 500 um')
 ylim(xlim); axis('square')
  xlim([0,.4])

[db_ains, db_sina] = nearest(dbeams.anet.time_LST, dbeams.sashemfr.time_LST);
 figure; plot(dbeams.anet.aod(4,db_ains), dbeams.sashemfr.aod(2,db_sina),'.')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
[good, P_bar] = rbifit(dbeams.anet.aod(4,db_ains), dbeams.sashemfr.aod(2,db_sina),4,0, []);
[gt,txt, stats] = txt_stat(dbeams.anet.aod(4,db_ains(good)), dbeams.sashemfr.aod(2,db_sina(good)),P_bar);
hold('on'); plot(dbeams.anet.aod(4,db_ains(~good)), dbeams.sashemfr.aod(2,db_sina(~good)),'.','color',[.5,.5,.5]); hold('off');
xlabel('Aeronet AOD');ylabel('SASHe AOD');
title('Aeronet and SASHe AOD 500 um')

%Compare MFR and SASHe for matching anet times.
[db_mins, db_sinm] = nearest(dbeams.mfrM1.time_LST(db_mina), dbeams.sashemfr.time_LST(db_sina));
 figure; plot(dbeams.mfrM1.aod(2,db_mina(db_mins)), dbeams.sashemfr.aod(2,db_sina(db_sinm)),'.')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
[good, P_bar] = rbifit(dbeams.mfrM1.aod(2,db_mina(db_mins)), dbeams.sashemfr.aod(2,db_sina(db_sinm)),4,0, []);
[gt,txt, stats] = txt_stat(dbeams.mfrM1.aod(2,db_mina(db_mins(good))), dbeams.sashemfr.aod(2,db_sina(db_sinm(good))),P_bar);
hold('on'); plot(dbeams.mfrM1.aod(2,db_mina(db_mins(~good))), dbeams.sashemfr.aod(2,db_sina(db_sinm(~good))),'.','color',[.5,.5,.5]); hold('off');
xlabel('MFRSR AOD');ylabel('SASHe AOD');
title('MFRSR and SASHe AOD 500 um')










end