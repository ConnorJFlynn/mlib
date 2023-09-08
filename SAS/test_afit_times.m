outp = ['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\hou\'];

% Try running afit* with only Cimel and MFR7 for both ttau and dirbeams.
% Then check times of same instrument ttau and ttau2


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