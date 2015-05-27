%%
% Nov 23, 2012 14-15 UT (single layer, liquid)
% Jan 28, 2013 14-15 UT (mixed phase, mid-altitude)
% Feb 1, 2013 21-23 UT (mixed phase, low altitude)


cldrad = read_chiu_cloudrads;
pplrad = aeronet_zenith_radiance;

figure; lines = plot(pplrad.time, ...
    [pplrad.zen_rad_440_nm, pplrad.zen_rad_500_nm, pplrad.zen_rad_670_nm, pplrad.zen_rad_870_nm, pplrad.zen_rad_1020_nm, pplrad.zen_rad_1640_nm],'.');
recolor(lines, [1:6]);
legend('440','500','675','870','1020','1640');
hold('on')
dots = plot(cldrad.time, cldrad.skyrad,'o','markersize',4);
recolor(dots,[1:6]);
hold('off')
dynamicDateTicks



%%
nfov2 = ancbundle_files;
%%
% Nov 23, 2012 14-15 UT (single layer, liquid)
saszefilt = ancbundle_files;
[ainb, bina] = nearest(nfov2.time, saszefilt.time);
good_ab = nfov2.vars.radiance_673nm.data(ainb)>-100 & nfov2.vars.radiance_870nm.data(ainb)>-100 & ...
    saszefilt.vars.zenith_radiance_673nm.data(bina)>-100 & saszefilt.vars.zenith_radiance_870nm.data(bina)>-100;
figure; plot(nfov2.time(ainb&good_ab), 1000.*[nfov2.vars.radiance_673nm.data(ainb&good_ab);nfov2.vars.radiance_870nm.data(ainb&good_ab)],'x',...
    saszefilt.time(bina&good_ab), [saszefilt.vars.zenith_radiance_673nm.data(bina&good_ab); saszefilt.vars.zenith_radiance_870nm.data(bina&good_ab)], 'o');
legend('NFOV 673','NFOV 870','SAS 673','SAS 870');

figure; plot(nfov2.time(ainb(good_ab)), 1000.*[nfov2.vars.radiance_673nm.data(ainb(good_ab))],'x',...
    saszefilt.time(bina(good_ab)), [saszefilt.vars.zenith_radiance_673nm.data(bina(good_ab))], 'o');
legend('NFOV 673','NFOV 870','SAS 673','SAS 870');

[P,S] = polyfit( 1000.*[nfov2.vars.radiance_673nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_673nm.data(bina(good_ab)),1);
stat_673n = fit_stat(1000.*[nfov2.vars.radiance_673nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_673nm.data(bina(good_ab)),P,S);
stat_673n.P = P;

figure; plot( 1000.*[nfov2.vars.radiance_673nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_673nm.data(bina(good_ab)), '.');
xl = xlim; 
ylim(xl);
xlabel('NFOV2 673 nm radiance');ylabel('SASZe 673 nm radiance')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

[P,S] = polyfit( 1000.*[nfov2.vars.radiance_870nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_870nm.data(bina(good_ab)),1);
stat_870n = fit_stat(1000.*[nfov2.vars.radiance_870nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_870nm.data(bina(good_ab)),P,S);
stat_870n.P = P;
figure; plot( 1000.*[nfov2.vars.radiance_870nm.data(ainb(good_ab))], saszefilt.vars.zenith_radiance_870nm.data(bina(good_ab)), '.');
xl = xlim; 
ylim(xl);
xlabel('NFOV2 870 nm radiance');ylabel('SASZe 870 nm radiance')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')


[cinb, binc] = nearest(cldrad.time, saszefilt.time);
good_cb = all(cldrad.sunrad(cinb,:)>0,2)'>-100 & saszefilt.vars.zenith_radiance_440nm.data(binc)>-100 & ...
    saszefilt.vars.zenith_radiance_500nm.data(binc)>-100 &saszefilt.vars.zenith_radiance_673nm.data(binc)>-100 & ...
    saszefilt.vars.zenith_radiance_870nm.data(binc)>-100 &saszefilt.vars.zenith_radiance_1020nm.data(binc)>-100 & ...
    saszefilt.vars.zenith_radiance_1637nm.data(binc)>-100;
figure; plot(cldrad.time(cinb(good_cb)), [cldrad.sunrad(cinb(good_cb),[3,4])],'x',...
    cldrad.time(cinb(good_cb)), [cldrad.skyrad(cinb(good_cb),[3,4])],'+');

[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),1)', saszefilt.vars.zenith_radiance_440nm.data(binc(good_cb)),1);
stat_440 = fit_stat(cldrad.skyrad(cinb(good_cb),1)', saszefilt.vars.zenith_radiance_440nm.data(binc(good_cb)),P,S);
stat_440.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),1), saszefilt.vars.zenith_radiance_440nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 440 nm');ylabel('SASZe 440 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),2)', saszefilt.vars.zenith_radiance_500nm.data(binc(good_cb)),1);
stat_500 = fit_stat(cldrad.skyrad(cinb(good_cb),2)', saszefilt.vars.zenith_radiance_500nm.data(binc(good_cb)),P,S);
stat_500.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),2), saszefilt.vars.zenith_radiance_500nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 500 nm');ylabel('SASZe 500 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),3)', saszefilt.vars.zenith_radiance_673nm.data(binc(good_cb)),1);
stat_673 = fit_stat(cldrad.skyrad(cinb(good_cb),3)', saszefilt.vars.zenith_radiance_673nm.data(binc(good_cb)),P,S);
stat_673.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),3), saszefilt.vars.zenith_radiance_673nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 675 nm');ylabel('SASZe 673 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),4)', saszefilt.vars.zenith_radiance_870nm.data(binc(good_cb)),1);
stat_870 = fit_stat(cldrad.skyrad(cinb(good_cb),4)', saszefilt.vars.zenith_radiance_870nm.data(binc(good_cb)),P,S);
stat_870.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),4), saszefilt.vars.zenith_radiance_870nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 870 nm');ylabel('SASZe 870 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),5)', saszefilt.vars.zenith_radiance_1020nm.data(binc(good_cb)),1);
stat_1020 = fit_stat(cldrad.skyrad(cinb(good_cb),5)', saszefilt.vars.zenith_radiance_1020nm.data(binc(good_cb)),P,S);
stat_1020.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),5), saszefilt.vars.zenith_radiance_1020nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 1020 nm');ylabel('SASZe 1020 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')


[P,S] = polyfit( cldrad.skyrad(cinb(good_cb),6)', saszefilt.vars.zenith_radiance_1637nm.data(binc(good_cb)),1);
stat_1640 = fit_stat(cldrad.skyrad(cinb(good_cb),6)', saszefilt.vars.zenith_radiance_1637nm.data(binc(good_cb)),P,S);
stat_1640.P = P;
figure; plot( cldrad.skyrad(cinb(good_cb),6), saszefilt.vars.zenith_radiance_1637nm.data(binc(good_cb)), '.');
xl = xlim; 
ylim(xl);
xlabel('Cimel skyrad 1640 nm');ylabel('SASZe 1637 nm')
hold('on'); plot(xl, xl,'k--',xl, polyval(P,xl,S),'r-');
hold('off')

xl = [0,200];
figure; these =  plot(xl, [polyval(stat_440.P,xl);polyval(stat_500.P,xl);polyval(stat_673.P,xl);polyval(stat_870.P,xl);polyval(stat_1020.P,xl);polyval(stat_1640.P,xl)],'-',...
 xl,polyval(stat_673n.P,xl), '--',xl,polyval(stat_870n.P,xl),'--');
recolor(these,[1:6,3,4]);
legend('440 nm','500 nm', '673 nm','870 nm','1020 nm', '1640 nm','673 nm NFOV','870 nm NFOV', 'location','northwest');
xlabel('Cimel cloudrad or NFOV radiance');
ylabel('SASZe radiance')
hold('on'); plot(xl,xl,'k--','linewidth',5);hold('off'); axis('square'); 
xlim(ylim);
title('Cloud radiances at Cape Cod, PVC over Jan 2013')


saszenir = ancload(['D:\data\dmf\pvc\pvcsaszenirM1.a1\pvcsaszenirM1.a1.20121123.114108.cdf']);
saszevis = ancload(['D:\data\dmf\pvc\pvcsaszevisM1.a1\pvcsaszevisM1.a1.20121123.114108.cdf']);

hold('on');
exes = plot(saszefilt.time, [saszefilt.vars.zenith_radiance_440nm.data;saszefilt.vars.zenith_radiance_500nm.data;saszefilt.vars.zenith_radiance_673nm.data;...
    saszefilt.vars.zenith_radiance_870nm.data; saszefilt.vars.zenith_radiance_1020nm.data; saszefilt.vars.zenith_radiance_1637nm.data],'x','markersize',3)
recolor(exes,[1:6]);
% Had trouble finding the Cimel data because we were right on top of it!
xl = xlim;
xl_ze= saszevis.time>=xl(1)&saszevis.time<xl(2);
wl_ = saszevis.vars.wavelength.data>=350 & saszevis.vars.wavelength.data<=1000;
wlnir_ = saszenir.vars.wavelength.data>=920 & saszenir.vars.wavelength.data<=1700;
wl_end = saszevis.vars.wavelength.data>=990 & saszevis.vars.wavelength.data<=1000;
wl_beg = saszenir.vars.wavelength.data>=990 & saszenir.vars.wavelength.data<=1000;
nir2vis = mean(mean(saszevis.vars.zenith_radiance.data(wl_end,xl_ze),2))./mean(mean(saszenir.vars.zenith_radiance.data(wl_beg,xl_ze),2));
figure; plot(saszevis.vars.wavelength.data(wl_), mean(saszevis.vars.zenith_radiance.data(wl_,xl_ze),2),'-',saszenir.vars.wavelength.data(wlnir_), ...
    nir2vis .* mean(saszenir.vars.zenith_radiance.data(wlnir_,xl_ze),2),'r-');
title(['SASZe zenith radiance, PVC ',datestr(saszevis.time(1),'yyyy-mm-dd HH:MM')]);
legend('CCD','InGaAs'); xlabel('wavelength [nm]');ylabel('radiance [W/(m^2 um sr)]');

logi.t_ = xl_ze;
logi.w_ = wl_;
print_sasnc_column_ordered(saszevis, logi);
logi2 = logi;
logi2.w_ = wlnir_;
print_sasnc_column_ordered(saszenir, logi2);

%%
% Jan 28, 2013 14-15 UT (mixed phase, mid-altitude)
saszefilt = ancbundle_files;
saszenir = ancload(['D:\data\dmf\pvc\pvcsaszenirM1.a1\pvcsaszenirM1.a1.20130128.115732.cdf']);
saszevis = ancload(['D:\data\dmf\pvc\pvcsaszevisM1.a1\pvcsaszevisM1.a1.20130128.115732.cdf']);

hold('on');
exes = plot(saszefilt.time, [saszefilt.vars.zenith_radiance_440nm.data;saszefilt.vars.zenith_radiance_500nm.data;saszefilt.vars.zenith_radiance_673nm.data;...
    saszefilt.vars.zenith_radiance_870nm.data; saszefilt.vars.zenith_radiance_1020nm.data; saszefilt.vars.zenith_radiance_1637nm.data],'x','markersize',3)
recolor(exes,[1:6]);
% Had trouble finding the Cimel data because we were right on top of it!
xl = xlim;
xl_ze= saszevis.time>=xl(1)&saszevis.time<xl(2);
wl_ = saszevis.vars.wavelength.data>=350 & saszevis.vars.wavelength.data<=1000;
wlnir_ = saszenir.vars.wavelength.data>=920 & saszenir.vars.wavelength.data<=1700;
wl_end = saszevis.vars.wavelength.data>=990 & saszevis.vars.wavelength.data<=1000;
wl_beg = saszenir.vars.wavelength.data>=990 & saszenir.vars.wavelength.data<=1000;
nir2vis = mean(mean(saszevis.vars.zenith_radiance.data(wl_end,xl_ze),2))./mean(mean(saszenir.vars.zenith_radiance.data(wl_beg,xl_ze),2));
figure; plot(saszevis.vars.wavelength.data(wl_), mean(saszevis.vars.zenith_radiance.data(wl_,xl_ze),2),'-',saszenir.vars.wavelength.data(wlnir_), ...
    nir2vis .* mean(saszenir.vars.zenith_radiance.data(wlnir_,xl_ze),2),'r-');
title(['SASZe zenith radiance, PVC ',datestr(saszevis.time(1),'yyyy-mm-dd HH:MM')]);
legend('CCD','InGaAs'); xlabel('wavelength [nm]');ylabel('radiance [W/(m^2 um sr)]');

logi.t_ = xl_ze;
logi.w_ = wl_;
print_sasnc_column_ordered(saszevis, logi);
logi2 = logi;
logi2.w_ = wlnir_;
print_sasnc_column_ordered(saszenir, logi2);

%%




%%



vceil = ancload(['D:\data\dmf\pvc\pvcvceil25kM1.b1\pvcvceil25kM1.b1.20121123.000014.cdf']);
figure; imagesc(serial2Hh(vceil.time), vceil.vars.range.data, real(log10(vceil.vars.backscatter.data))); axis('xy');colorbar; zoom('on')

sasze_filt = ancload(['D:\data\dmf\pvc\pvcsaszefilterbandsM1.a1\pvcsaszefilterbandsM1.a1.20121123.114108.cdf']);
saszevis = ancload(['D:\data\dmf\pvc\pvcsaszevisM1.a1\pvcsaszevisM1.a1.20121123.114108.cdf']);





%%
saszefilt = ancbundle_files;
saszenir = ancload(['D:\data\dmf\pvc\pvcsaszenirM1.a1\pvcsaszenirM1.a1.20130128.115732.cdf']);
saszevis = ancload(['D:\data\dmf\pvc\pvcsaszevisM1.a1\pvcsaszevisM1.a1.20130128.115732.cdf']);
figure; plot(nfov2.time, [nfov2.vars.radiance_673nm.data; nfov2.vars.radiance_870nm.data],'.',saszefilt.time, [saszefilt.vars.zenith_radiance_673nm.data; saszefilt.vars.zenith_radiance_870nm.data]./1000,'o')

figure; plot(cldrad.time, cldrad.skyrad(:,3:4)./1000,'-o');
legend('cloud-mode 673','cloud-mode 870')

xl = xlim;
xl_cldrad = cldrad.time>xl(1)&cldrad.time<xl(2);
xl_zef = saszefilt.time>xl(1)&saszefilt.time<xl(2)&saszefilt.vars.zenith_radiance_673nm.data>0;
xl_ze= saszevis.time>xl(1)&saszevis.time<xl(2);
figure; plot(saszevis.vars.wavelength.data, mean(saszevis.vars.zenith_radiance.data(:,xl_ze),2),'-',...
    673, mean(saszefilt.vars.zenith_radiance_673nm.data(xl_zef)), 'ko',870, mean(saszefilt.vars.zenith_radiance_870nm.data(xl_zef)),'kx',...
    673, mean(cldrad.skyrad(xl_cldrad,3)), 'ro',870, mean(cldrad.skyrad(xl_cldrad,4)),'rx');

filt_zoom = ancsift(saszefilt,saszefilt.dims.time, xl_zef);
vis_zoom = ancsift(saszevis,saszevis.dims.time, xl_ze);
nir_zoom = ancsift(saszenir, saszenir.dims.time, xl_ze);
[ainb, bina] = nearest(vis_zoom.time, filt_zoom.time);
wl = xlim;
wl_ = vis_zoom.vars.wavelength.data>wl(1) & vis_zoom.vars.wavelength.data<wl(2);
logi.w_ = wl_;
print_sasnc_column_ordered(vis_zoom, logi);
figure; plot(vis_zoom.vars.wavelength.data, vis_zoom.vars.zenith_radiance.data,'-')
wl2_ = nir_zoom.vars.wavelength.data>xl2(1) & nir_zoom.vars.wavelength.data<xl2(2);
logi2.w_ = wl2_;
print_sasnc_column_ordered(nir_zoom, logi2);

%%
% Feb 1, 2013 21-23 UT (mixed phase, low altitude)
saszefilt = ancbundle_files;
saszenir = ancload(['D:\data\dmf\pvc\pvcsaszenirM1.a1\pvcsaszenirM1.a1.20130201.115337.cdf']);
saszevis = ancload(['D:\data\dmf\pvc\pvcsaszevisM1.a1\pvcsaszevisM1.a1.20130201.115337.cdf']);
hold('on');
exes = plot(saszefilt.time, [saszefilt.vars.zenith_radiance_440nm.data;saszefilt.vars.zenith_radiance_500nm.data;saszefilt.vars.zenith_radiance_673nm.data;...
    saszefilt.vars.zenith_radiance_870nm.data; saszefilt.vars.zenith_radiance_1020nm.data; saszefilt.vars.zenith_radiance_1637nm.data],'x','markersize',3)
recolor(exes,[1:6]);
xl = xlim;

xl_ze= saszevis.time>xl(1)&saszevis.time<xl(2);
figure; plot(saszevis.vars.wavelength.data, mean(saszevis.vars.zenith_radiance.data(:,xl_ze),2),'-',...
    673, mean(saszefilt.vars.zenith_radiance_673nm.data(xl_zef)), 'ko',870, mean(saszefilt.vars.zenith_radiance_870nm.data(xl_zef)),'kx',...
    673, mean(cldrad.skyrad(xl_cldrad,3)), 'ro',870, mean(cldrad.skyrad(xl_cldrad,4)),'rx');

filt_zoom = ancsift(saszefilt,saszefilt.dims.time, xl_ze);
vis_zoom = ancsift(saszevis,saszevis.dims.time, xl_ze);
nir_zoom = ancsift(saszenir, saszenir.dims.time, xl_ze);
[ainb, bina] = nearest(vis_zoom.time, filt_zoom.time);
wl = xlim;
wl_ = vis_zoom.vars.wavelength.data>wl(1) & vis_zoom.vars.wavelength.data<wl(2);
logi.w_ = wl_;
print_sasnc_column_ordered(vis_zoom, logi);
figure; plot(vis_zoom.vars.wavelength.data, vis_zoom.vars.zenith_radiance.data,'-')
wl2_ = nir_zoom.vars.wavelength.data>xl2(1) & nir_zoom.vars.wavelength.data<xl2(2);
logi2.w_ = wl2_;
print_sasnc_column_ordered(nir_zoom, logi2);

