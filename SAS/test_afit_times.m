outp = ['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\hou\'];
outp = ['D:\aodfit_be\hou\'];
% Try running afit* with only Cimel and MFR7 for both ttau and dirbeams.
% Then check times of same instrument ttau and ttau2
% [ttau, lang_legs, dirbeams, rVos, ttau2, llegs2, rVos2, dbeams] = afit_lang_tau_series;

ttau = load(getfullname([outp,'ttau.*.mat']));
lang_legs = load(getfullname([outp,'lang_legs.*.mat']));
% Try #1: cim_mfr7 as references for ttau and lang_legs
% Then try only loading cim as dirbeam
[ttau, lang_legs, dirbeams, rVos, ttau2, llegs2, rVos2, dbeams] = afit_lang_tau_series(ttau, lang_legs);
lang_legs.AM_20220310.airmass
legs = fieldnames(lang_legs);
fits = lang_legs.(legs{1});
for lg = 2:length(legs)
   leg = lang_legs.(legs{lg});
   fits.time_LST = [fits.time_LST; leg.time_LST];
   fits.time_UT = [fits.time_UT; leg.time_UT];
   fits.airmass = [fits.airmass;leg.airmass];
   fits.pres_atm = [fits.pres_atm;leg.pres_atm];
   fits.aod_fit = [fits.aod_fit;leg.aod_fit];
end
disp('Done')

wl_i = interp1(fits.wl, [1:length(fits.wl)], [dbeams.anet.wls(4)],'nearest');
figure; plot(dbeams.anet.time_LST, dbeams.anet.aod(4,:),'o',fits.time_LST, fits.aod_fit(:,wl_i),'x'); dynamicDateTicks
% identify nearest match points for dbeams.anet and fits.

[findl, dinfl] = nearest(fits.time_LST,dbeams.anet.time_LST);
[findu, dinfu] = nearest(fits.time_UT,dbeams.anet.time);

Dl = den2plot(fits.aod_fit(findl,wl_i),dbeams.anet.aod(4,dinfl)');
figure; scatter(fits.aod_fit(findl,wl_i),dbeams.anet.aod(4,dinfl)',4,log10(Dl),'filled');colormap(comp_map_w_jet)
title('nearest LST')

Du = den2plot(fits.aod_fit(findu,wl_i),dbeams.anet.aod(4,dinfu)');
figure; scatter(fits.aod_fit(findu,wl_i),dbeams.anet.aod(4,dinfu)',4,log10(Du),'filled'); colormap(comp_map_w_jet);
title('nearest UT')

anet = dbeams.anet; mfr = dbeams.mfrM1;
sas = dbeams.sashemfr;

[ainm, mina] = nearest(anet.time, mfr.time);
D = den2plot(anet.aod(4,ainm), mfr.aod(2,mina));
[good,P_bar] = rbifit(anet.aod(4,ainm), mfr.aod(2,mina),3,0);
figure; scatter(anet.aod(4,ainm), mfr.aod(2,mina),4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(anet.aod(4,ainm(good)), mfr.aod(2,mina(good)),P_bar); set(gt,'color','b');
title('Aeronet vs ARM MFRSR7nch AOD at 500 nm');
xlabel('Aeronet AOD'); ylabel('MFRSR AOD');

% Now to be more general:
title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 675 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(5,xiny); Y = mfr.aod(4,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);

title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 870 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(6,xiny); Y = mfr.aod(5,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 1.6 micron'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(8,xiny); Y = mfr.aod(6,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

% Now try SAS vs Aeronet
title_str_top = 'ARM MFR vs ARM SASHe'; title_str_bot = 'AOD at 415 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
[xiny, yinx] = nearest(mfr.time, sas.time);
X = mfr.aod(1,xiny); Y = sas.aod(1,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

% Now try SAS vs Aeronet
title_str_top = 'ARM MFR vs ARM SASHe'; title_str_bot = 'AOD at 500 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
[xiny, yinx] = nearest(mfr.time, sas.time);
X = mfr.aod(2,xiny); Y = sas.aod(2,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')





%% we're just about here!!

wl_a_500 = find(anet.wl==500);wl_m_500 = find(mfr.wl>500&mfr.wl<600);
[ainm, mina] = nearest(anet.time(wl_a_500), mfr.time(wl_m_500));
wl_a_500 = wl_a_500(ainm); wl_m_500 = wl_m_500(mina)



% dirbeams = load(getfullname([outp,'dirbeams.*.mat']));

figure; plot(ttau.time_LST(ttau.nm==500),ttau.aod(ttau.nm==500),'ro',ttau2.time_LST(ttau2.nm==500)+.5/24,ttau2.aod(ttau2.nm==500),'b.'); dynamicDateTicks
legend('ttau','ttau2')

figure; plot(ttau.time(ttau.nm==500),ttau.aod(ttau.nm==500),'ro',ttau2.time(ttau2.nm==500),ttau2.aod(ttau2.nm==500),'b.'); dynamicDateTicks
legend('ttau','ttau2'); axis(v)

dbeams.anet.wls

% Fix axes limits, and square
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

% Nice technique for keeping the indices simple

wl_a_500 = find(anet.wl==500);wl_m_500 = find(mfr.wl>500&mfr.wl<600);
[ainm, mina] = nearest(anet.time(wl_a_500), mfr.time(wl_m_500));
wl_a_500 = wl_a_500(ainm); wl_m_500 = wl_m_500(mina)