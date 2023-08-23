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

figure; plot(nfov.time, nfov.vdata.radiance_673nm, 'o', sas.time, sas.vdata.zenith_radiance_673nm./1000,'x'); dynamicDateTicks; logy

[nins, sinn] = nearest(nfov.time, sas.time);

ns_good = rbifit(nfov.vdata.radiance_673nm(nins), sas.vdata.zenith_radiance_673nm(sinn)./1000); axis('square')
ns_good = rbifit(nfov.vdata.radiance_870nm(nins), sas.vdata.zenith_radiance_870nm(sinn)./1000); axis('square')

azen = anc_bundle_files(getfullname('epccsphotzen*.nc','azen'));
good_a = azen.vdata.zenith_sky_radiance_A(3,:)>0&azen.vdata.zenith_sky_radiance_A(4,:)>0;
azen = anc_sift(azen, good_a);

figure; plot(nfov.time, nfov.vdata.radiance_673nm, 'o', azen.time, azen.vdata.zenith_sky_radiance_A(4,:)./100,'x')

[anin, nina] = nearest(azen.time,nfov.time);
[anis, sina] = nearest(azen.time,sas.time);

figure; plot(azen.vdata.zenith_sky_radiance_A(4,anin)./100,  nfov.vdata.radiance_673nm(nina),'.',...
   azen.vdata.zenith_sky_radiance_A(4,anis)./100,sas.vdata.zenith_radiance_673nm(sina)./1000,'r.' )

figure; plot(azen.vdata.zenith_sky_radiance_A(3,anin)./100,  nfov.vdata.radiance_870nm(nina),'.',...
   azen.vdata.zenith_sky_radiance_A(4,anis)./100,sas.vdata.zenith_radiance_870nm(sina)./1000,'r.' )

figure; sb(6) = subplot(3,2,1); plot(azen.vdata.zenith_sky_radiance_A(1,anis)./100,sas.vdata.zenith_radiance_1637nm(sina)./1000,'r.'); 
legend('1640'); axis('square');v = axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);
sb(5) = subplot(3,2,2); plot(azen.vdata.zenith_sky_radiance_A(2,anis)./100,sas.vdata.zenith_radiance_1020nm(sina)./1000,'r.'); 
legend('1020'); axis('square');  v= axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);
sb(4) = subplot(3,2,3); plot(azen.vdata.zenith_sky_radiance_A(3,anis)./100,sas.vdata.zenith_radiance_870nm(sina)./1000,'r.',...
   azen.vdata.zenith_sky_radiance_A(3,anin)./100,nfov.vdata.radiance_870nm(nina),'.'); 
legend('870'); axis('square');  v= axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);
sb(3) = subplot(3,2,4); plot(azen.vdata.zenith_sky_radiance_A(4,anis)./100,sas.vdata.zenith_radiance_673nm(sina)./1000,'r.',...
   azen.vdata.zenith_sky_radiance_A(4,anin)./100, nfov.vdata.radiance_673nm(nina),'.'); 
legend('675'); axis('square'); v= axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);
sb(2) = subplot(3,2,5); plot(azen.vdata.zenith_sky_radiance_A(5,anis)./100,sas.vdata.zenith_radiance_500nm(sina)./1000,'r.'); 
legend('500'); axis('square'); v= axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);
sb(1) = subplot(3,2,6); plot(azen.vdata.zenith_sky_radiance_A(6,anis)./100,sas.vdata.zenith_radiance_440nm(sina)./1000,'r.'); 
legend('440'); axis('square'); v= axis; mv = max([v(2), v(4)]); xlim([0,mv]); ylim(xlim);






figure; scatter(nfov.vdata.radiance_673nm(nina), azen.vdata.zenith_sky_radiance_A(4,anin)./100)
rbifit(nfov.vdata.radiance_673nm(nina), azen.vdata.zenith_sky_radiance_A(4,anin)./100,6);
rbifit(nfov.vdata.radiance_870nm(nina), azen.vdata.zenith_sky_radiance_A(3,anin)./100,6);
figure; scatter(nfov.vdata.radiance_673nm,sas.vdata.zenith_radiance_673nm./1000 )
good = rbifit(nfov.vdata.radiance_673nm,sas.vdata.zenith_radiance_673nm./1000,8);
good = rbifit(nfov.vdata.radiance_870nm,sas.vdata.zenith_radiance_870nm./1000,4);
end