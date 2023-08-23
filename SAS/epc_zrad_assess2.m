function epc_zrad_assess

% Let's look at the last few months of hou to see how NFOV2 and SASZe look
% Data is in here: C:\case_studies\sasx
nfov = anc_bundle_files(getfullname('epcnfov*.cdf','nfov'));
good_n = nfov.vdata.qc_radiance_673nm==0 & nfov.vdata.qc_radiance_870nm==0 & nfov.vdata.radiance_673nm>1e-2 & nfov.vdata.radiance_870nm>1e-2 ;
nfov = anc_sift(nfov, good_n);

% 
sas = anc_bundle_files(getfullname('epcsas*.nc','sasze'));
good_s = sas.vdata.zenith_radiance_673nm>10 & sas.vdata.zenith_radiance_870nm>1;
sas = anc_sift(sas, good_s);

% [nina_, ainn_] = nearest(new_AOD_.time, anet.time,2./(24.*60));
% [good, P_bar] = rbifit(anet.AOD_870nm(ainn_), new_AOD_.vdata.aerosol_optical_depth_filter5(nina_)',2.5,0, []);
% xlabel('Aeronet AOD');ylabel('ARM AOD');
% title('Aeronet and good new ARM AOD 870 nm')
%  xlim([0,.15]); ylim(xlim); axis('square')
% [gt,txt, stats] = txt_stat(anet.AOD_870nm(ainn_(good)), new_AOD_.vdata.aerosol_optical_depth_filter5(nina_(good))',P_bar);
% hold('on'); plot(anet.AOD_870nm(ainn_(~good)), new_AOD_.vdata.aerosol_optical_depth_filter5(nina_(~good))','k.'); hold('off');



figure; plot(nfov.time, nfov.vdata.radiance_673nm, 'o', sas.time, sas.vdata.zenith_radiance_673nm./1000,'x'); dynamicDateTicks; logy

[nins, sinn] = nearest(nfov.time, sas.time);
% rbifit(X,Y,M,pct,good,fig);
figure; 
[ns_good, P_bar] = rbifit(nfov.vdata.radiance_673nm(nins), sas.vdata.zenith_radiance_673nm(sinn)./1000,6,0,[],gcf);
 xlim([0,.5]); ylim(xlim); axis('square')
figure; plot(nfov.vdata.radiance_673nm(nins(~ns_good)), sas.vdata.zenith_radiance_673nm(sinn(~ns_good))./1000,'.','color',[.75,.75,.75]); 
 xlim([0,.3]); ylim(xlim); axis('square')
legend('outliers','in fit')
[gt,txt, stats] = txt_stat(nfov.vdata.radiance_673nm(nins(ns_good)), sas.vdata.zenith_radiance_673nm(sinn(ns_good))./1000,P_bar);

xlabel('NFOV ch1 673 nm');ylabel('SASZe 673 nm');
title({'EPC NFOV2 and SASZe Oct 2021';'673 nm radiances'})

figure; 
[ns_good, P_bar] = rbifit(nfov.vdata.radiance_870nm(nins), sas.vdata.zenith_radiance_870nm(sinn)./1000,6,0,[],gcf);
 xlim([0,.5]); ylim(xlim); axis('square')
figure; plot(nfov.vdata.radiance_870nm(nins(~ns_good)), sas.vdata.zenith_radiance_870nm(sinn(~ns_good))./1000,'.','color',[.75,.75,.75]); 
 xlim([0,.25]); ylim(xlim); axis('square')
legend('outliers','in fit')
[gt,txt, stats] = txt_stat(nfov.vdata.radiance_870nm(nins(ns_good)), sas.vdata.zenith_radiance_870nm(sinn(ns_good))./1000,P_bar);

xlabel('NFOV ch1 870 nm');ylabel('SASZe 870 nm');
title({'EPC NFOV2 and SASZe Feb 2023';'870 nm radiances'})

% now what?  Now 
% 

azen = anc_bundle_files(getfullname('epccsphotzen*.nc','azen'));
good_a = azen.vdata.zenith_sky_radiance_A(3,:)>0&azen.vdata.zenith_sky_radiance_A(4,:)>0;
azen = anc_sift(azen, good_a);

% figure; plot(nfov.time, nfov.vdata.radiance_673nm, 'o', azen.time, azen.vdata.zenith_sky_radiance_A(4,:)./100,'x')

[anin, nina] = nearest(azen.time,nfov.time);
[anis, sina] = nearest(azen.time,sas.time);

figure; plot(azen.vdata.zenith_sky_radiance_A(4,anin)./100,  nfov.vdata.radiance_673nm(nina),'.',...
   azen.vdata.zenith_sky_radiance_A(4,anis)./100,sas.vdata.zenith_radiance_673nm(sina)./1000,'r.' );
xlabel('CSPHOT 675 nm');ylabel('NFOV and SASZe 673 nm');
title({'EPC CSPHOT NFOV2 and SASZe  F3b 2023';'673/675 nm radiances'})
 xlim([0,.3]); ylim(xlim); axis('square');legend('NFOV2','SASZe')

 [nf_good, nf_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(4,anin)./100,  nfov.vdata.radiance_673nm(nina));
 [ze_good, ze_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(4,anis)./100,  sas.vdata.zenith_radiance_673nm(sina)./1000);
 
figure; plot(azen.vdata.zenith_sky_radiance_A(3,anin)./100,  nfov.vdata.radiance_870nm(nina),'.',...
   azen.vdata.zenith_sky_radiance_A(3,anis)./100,sas.vdata.zenith_radiance_870nm(sina)./1000,'r.' );
xlabel('CSPHOT 870 nm');ylabel('NFOV and SASZe 870 nm');
title({'EPC CSPHOT NFOV2 and SASZe Feb 2023';'870 nm radiances'})
 xlim([0,.3]); ylim(xlim); axis('square'); legend('NFOV2','SASZe')

 [nf_good, nf_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(3,anin)./100,  nfov.vdata.radiance_870nm(nina));
 [ze_good, ze_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(3,anis)./100,  sas.vdata.zenith_radiance_870nm(sina)./1000);
 
 % Adjust the below for 1600 and 1020 

figure; plot(azen.vdata.zenith_sky_radiance_A(1,anis)./100,sas.vdata.zenith_radiance_1637nm(sina)./1000,'r.' );
xlabel('CSPHOT 1640 nm');ylabel('SASZe 1637 nm');
title({'EPC CSPHOT and SASZe Feb 2023';'1637/1640 nm radiances'})
 xlim([0,.04]); ylim(xlim); axis('square');legend('SASZe')

 [ze_good, ze_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(1,anis)./100,  sas.vdata.zenith_radiance_1637nm(sina)./1000);
 
figure; plot(azen.vdata.zenith_sky_radiance_A(2,anis)./100,sas.vdata.zenith_radiance_1020nm(sina)./1000,'r.' );
xlabel('CSPHOT 1020 nm');ylabel('SASZe 1020 nm');
title({'EPC CSPHOT and SASZe Feb 2023';'1020 nm radiances'})
 xlim([0,.15]); ylim(xlim); axis('square'); legend('SASZe')

 [ze_good, ze_Pfit] =rbifit(azen.vdata.zenith_sky_radiance_A(2,anis)./100,  sas.vdata.zenith_radiance_1020nm(sina)./1000);
 
