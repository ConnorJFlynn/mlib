nir = rd_SAS_raw(getfullname('SASZe_*_nir_1s.*.csv'));

nir.darks = mean(nir.spec(nir.Tag==1,:));
nir.sig = nir.spec - ones([length(nir.time),1])*nir.darks;
nir.white = (nir.sig(nir.Tag==3,:));
nir.anodized = (nir.sig(nir.Tag==5,:));
nir.acrily = (nir.sig(nir.Tag==7,:));
nir.flocking = (nir.sig(nir.Tag==9,:));
nir.plastic = (nir.sig(nir.Tag==11,:));
nir.black3 = (nir.sig(nir.Tag==13,:));

nir.refl_anodized = nir.anodized./nir.white;
figure; plot(nir.wl, nir.refl_anodized,'-');
figure; plot(nir.wl, 100.*std(nir.refl_anodized)./mean(nir.refl_anodized),'k-');
figure; errorbar(nir.wl, mean(nir.refl_anodized,std(nir.refl_anodized))

nir.refl_acrily = mean(nir.sig(nir.Tag==7,:));
nir.refl_flocking = mean(nir.sig(nir.Tag==9,:));
nir.refl_plastic = mean(nir.sig(nir.Tag==11,:));
nir.refl_black3 = mean(nir.sig(nir.Tag==13,:));

nir.sdev_anodized = std(nir.sig(nir.Tag==5,:));
nir.sdev_acrily = std(nir.sig(nir.Tag==7,:));
nir.sdev_flocking = std(nir.sig(nir.Tag==9,:));
nir.sdev_plastic = std(nir.sig(nir.Tag==11,:));
nir.sdev_black3 = std(nir.sig(nir.Tag==13,:));

figure; plot(nir.wl, [nir.anodized./nir.white; nir.acrily./nir.white; nir.flocking./nir.white; nir.plastic./nir.white; nir.black3./nir.white],'-')
legend('anodize','acrily','flocking','plastic','black3')

figure; plot(nir.wl, [nir.sdev_anodized./nir.white; nir.sdev_acrily./nir.white; nir.sdev_flocking./nir.white; nir.sdev_plastic./nir.white; nir.sdev_black3./nir.white],'-')
legend('anodize','acrily','flocking','plastic','black3')



vis = rd_SAS_raw(getfullname('SASZe_*_vis_1s.*.csv'));


vis.darks = mean(vis.spec(vis.Tag==1,:));
vis.sig = vis.spec - ones([length(vis.time),1])*vis.darks;
vis.white = mean(vis.sig(vis.Tag==3,:));
vis.anodized = mean(vis.sig(vis.Tag==5,:));
vis.acrily = mean(vis.sig(vis.Tag==7,:));
vis.flocking = mean(vis.sig(vis.Tag==9,:));
vis.plastic = mean(vis.sig(vis.Tag==11,:));
vis.black3 = mean(vis.sig(vis.Tag==13,:));


figure; plot(vis.wl, [vis.anodized./vis.white; vis.acrily./vis.white; vis.flocking./vis.white; vis.plastic./vis.white; vis.black3./vis.white],'-')
legend('anodize','acrily','flocking','plastic','black3')
logy

xlabel('wavelength [nm]');
ylabel('Reflectance [unitless]')

title({['Reflectance of various sample disks relative to Spectralon'];['Data collected by Emily West 03-29-2023']})
