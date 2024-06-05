function check_twst_Ze_vis_nir_match

% Idea is to obtain both Ze and TWST data from SGP
% Using Ze data, find optimal pixels from VIS and NIR that yield confident
% match to overlapping spectral region.
% Then use the corresponding spectral regions from TWST to compute matching factor

zenir = anc_bundle_files;
figure;plot((zevis.time), zevis.vdata.zenith_radiance(400:100:1000,:),'.'); dynamicDateTicks
cld = [49700, 51250];
clr_sky = interp1(zevis.time, [1:length(zevis.time)],datenum(2023,11,22,18,00,00),'nearest')
figure;plot(1:length(zenir.time), zenir.vdata.zenith_radiance(20:40:end,:),'.')

figure; plot(zenir.vdata.wavelength,zenir.vdata.zenith_radiance(:,[clr_sky 49700, 51250]),'-'); logy; logx
yl = ylim; ylim([0,yl(2)]);

zevis = anc_bundle_files;_

figure; plot(zevis.vdata.wavelength,zevis.vdata.zenith_radiance(:,clr),'-')

figure; plot(zevis.vdata.wavelength,zevis.vdata.zenith_radiance(:,[clr_sky, 49700, 51250]),'-',...
   zenir.vdata.wavelength,zenir.vdata.zenith_radiance(:,[clr, 49700, 51250]),'-'...
   ); logy; logx; title('SASZe');


[tws, twst] = cat_twst_mat;
tws_times = interp1(tws.time, [1:length(tws.time)],zenir.time([clr_sky, cld]),'nearest')

figure; plot(twst.wl_A, 1000.*twst.zenrad_A(:,tws_times),'-', twst.wl_B, 1000.*twst.zenrad_B(:,tws_times),'-')
logy; logx; title('TWST')

zt = clr_sky
tt = tws_times(1);

zt = 49700;
tt  = tws_times(2);

zt = 51250;
tt  = tws_times(3);

ze_ts = find(zevis.vdata.zenith_radiance(500,:)>5);
tts = interp1(tws.time, [1:length(tws.time)],zenir.time(ze_ts),'nearest','extrap');
logviswl = log(zevis.vdata.wavelength); lognirwl = log(zenir.vdata.wavelength);
ze_viswl_ = (zevis.vdata.wavelength>742&zevis.vdata.wavelength<752);
ze_viswl_ = ze_viswl_ | (zevis.vdata.wavelength>772&zevis.vdata.wavelength<790);
pin_ze = zenir.vdata.wavelength>985 & zenir.vdata.wavelength<1029;
logwlA = log(twst.wl_A); logwlB = log(twst.wl_B);
wlA_ = (twst.wl_A>742&twst.wl_A<752)|(twst.wl_A>772&twst.wl_A<790);
pin_tw = twst.wl_B>985 & twst.wl_B<1029;

for z = length(ze_ts):-1:1
   zt = ze_ts(z);
   tt = tts(z);
   logvis = log(zevis.vdata.zenith_radiance(:,zt));
   ze_nir_pin = mean(zenir.vdata.zenith_radiance(pin_ze,zt));
   Pze = polyfit(logviswl(ze_viswl_),logvis(ze_viswl_),1);
   ze_fit_pin = exp(polyval(Pze,mean(lognirwl(pin_ze))));
   ze_factor(z) = ze_fit_pin./ze_nir_pin;

   logA = log(twst.zenrad_A(:,tt));
   tw_B_pin = mean(twst.zenrad_B(pin_tw,tt));
   Ptw = polyfit(logwlA(wlA_),logA(wlA_),1);
   tw_fit_pin = exp(polyval(Ptw,mean(logwlB(pin_tw))));

   tws_factor(z) = tw_fit_pin./tw_B_pin;

   sprintf('%d, ze factor = %2.2f%%, tws factor = %2.2f%%', z, 100.*(1-ze_factor(z)), 100.*(1-tws_factor(z)))

end

figure; plot(zevis.time(ze_ts), [ze_factor;tws_factor]','.')












return