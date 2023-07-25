% MFRSR7nch and Aeronet AOD plots for Evgueni, ASR/ARM 2023
% Looks pretty good.
% Some differences at 1.6 might be cosine corr or might be gas subtraction
% Probably need aeronet collaboration to resolve by modeling actual gas contributions
% to their 1.6 um OD at high spectral resolution.

anet = rd_anetaod_v3;
houmfr = anc_bundle_files;
houmfr = anc_sift(houmfr, houmfr.vdata.airmass>=1 & houmfr.vdata.airmass<6);
bad_aod = houmfr.vdata.aerosol_optical_depth_filter1<0|houmfr.vdata.aerosol_optical_depth_filter2<0;
bad_aod = bad_aod | houmfr.vdata.aerosol_optical_depth_filter3<0|houmfr.vdata.aerosol_optical_depth_filter4<0;
bad_aod = bad_aod | houmfr.vdata.aerosol_optical_depth_filter5<0|houmfr.vdata.aerosol_optical_depth_filter7<0;
houmfr = anc_sift(houmfr, ~bad_aod);
bad_aod = anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter1, houmfr.vatts.qc_aerosol_optical_depth_filter1)>1;
bad_aod = bad_aod |anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter2, houmfr.vatts.qc_aerosol_optical_depth_filter2)>1;
bad_aod = bad_aod |anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter3, houmfr.vatts.qc_aerosol_optical_depth_filter3)>1;
bad_aod = bad_aod |anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter4, houmfr.vatts.qc_aerosol_optical_depth_filter4)>1;
bad_aod = bad_aod |anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter5, houmfr.vatts.qc_aerosol_optical_depth_filter5)>1;
bad_aod = bad_aod |anc_qc_impacts(houmfr.vdata.qc_aerosol_optical_depth_filter7, houmfr.vatts.qc_aerosol_optical_depth_filter7)>1;
houmfr = anc_sift(houmfr, ~bad_aod);

[hina, ainh] = nearest(houmfr.time, anet.time);
[good, P_bar] = rbifit(anet.AOD_1640nm(ainh), houmfr.vdata.aerosol_optical_depth_filter7(hina)',2.5,0, []);
xlabel('Aeronet AOD');ylabel('ARM AOD');
title('Aeronet and ARM AOD 1.6 um')

[good, P_bar] = rbifit(anet.AOD_500nm(ainh), houmfr.vdata.aerosol_optical_depth_filter2(hina)',2.5,0, []);
xlabel('Aeronet AOD');ylabel('ARM AOD');
title('Aeronet and ARM AOD 500 nm')

plots_ppt; 

bad_aod_ = houmfr.vdata.aerosol_optical_depth_filter7<0.007;
houmfr_ = anc_sift(houmfr, ~bad_aod_);
[hina_, ainh_] = nearest(houmfr_.time, anet.time);

[good, P_bar] = rbifit(anet.AOD_1640nm(ainh_), houmfr_.vdata.aerosol_optical_depth_filter7(hina_)',3,0, []);
xlabel('Aeronet AOD');ylabel('ARM AOD');
title('Aeronet and ARM AOD 1.6 um')
 xlim([0,.15]); ylim(xlim); axis('square')
[gt,txt, stats] = txt_stat(anet.AOD_1640nm(ainh_(good)), houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good))',P_bar);
hold('on'); plot(anet.AOD_1640nm(ainh_(~good)), houmfr_.vdata.aerosol_optical_depth_filter7(hina_(~good))','k.'); hold('off');

figure; plot(anet.AOD_1640nm(ainh_), houmfr_.vdata.aerosol_optical_depth_filter7(hina_)','k.')
 xlim([0,.15]); ylim(xlim); axis('square')
% Copy desired graphical element from rbifit plot to above.
legend('outliers','points in fit')
legend('outliers','fitted points')
xlabel('Aeronet AOD 1640 nm')
ylabel('MFRSR AOD 1625 nm')
title('Aeronet and MFRSR AOD 1.6 um')

[good, P_bar] = rbifit(anet.AOD_500nm(ainh_), houmfr_.vdata.aerosol_optical_depth_filter2(hina_)',2.5,0, []);
xlabel('Aeronet AOD');ylabel('ARM AOD');
title('Aeronet and ARM AOD 500 nm');
 xlim([0,.4]); ylim(xlim); axis('square')
[gt,txt, stats] = txt_stat(anet.AOD_500nm(ainh_(good)), houmfr_.vdata.aerosol_optical_depth_filter2(hina_(good))',P_bar);

figure; plot(anet.time(ainh_(good)),anet.AOD_500nm(ainh_(good)),'bx',houmfr_.time(hina_(good)), houmfr_.vdata.aerosol_optical_depth_filter2(hina_(good)),'c+');
dynamicDateTicks; xl = xlim; yl = ylim; 
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR')
title('ARM and Aeronet AOD at 500 nm')
figure; hist(anet.AOD_500nm(ainh_(good)),50); figure; hist(houmfr_.vdata.aerosol_optical_depth_filter2(hina_(good)),50)

figure; plot(anet.time(ainh_(good)),anet.AOD_1640nm(ainh_(good)),'rx',houmfr_.time(hina_(good)), houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good)),'m+');
dynamicDateTicks; xlim(xl); ylim([0,.25]);
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR');
title('ARM and Aeronet AOD at 1.6 um')
figure; hist([anet.AOD_1640nm(ainh_(good))],50); figure; hist(houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good)),50)
figure; hist([anet.AOD_1640nm(ainh_(good)),.008+houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good))'],50);
figure; plot(anet.time(ainh_(good)),anet.AOD_870nm(ainh_(good)),'x',houmfr_.time(hina_(good)), houmfr_.vdata.aerosol_optical_depth_filter5(hina_(good)),'+');
dynamicDateTicks; xlim(xl); ylim([0,.35]);
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR');
title('ARM and Aeronet AOD at 870 nm')

figure; plot(houmfr_.time(hina_(good)), houmfr_.vdata.angstrom_exponent(hina_(good)),'kx');
dynamicDateTicks; xlim(xl); 
xlabel('time'); ylabel('Angstrom'); legend('Ang Exp');
title('Angstrom Exponent from 500 nm and 870 nm')

ang_870_1p6 = ang_exp(houmfr_.vdata.aerosol_optical_depth_filter5(hina_(good)),houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good)),870,1640);

figure; plot(houmfr_.time(hina_(good)), houmfr_.vdata.angstrom_exponent(hina_(good)),'kx',houmfr_.time(hina_(good)), ang_870_1p6,'r.');
dynamicDateTicks; xlim(xl); 
xlabel('time'); ylabel('Angstrom'); legend('500 & 870', '870 & 1640');
title('Angstrom Exponent from  870 nm and 1640 nm');

[good, P_bar] = rbifit(anet.AOD_870nm(ainh_), houmfr_.vdata.aerosol_optical_depth_filter5(hina_)',2.5,0, []);
xlabel('Aeronet AOD');ylabel('ARM AOD');
title('Aeronet and ARM AOD 870 nm');
 xlim([0,.4]); ylim(xlim); axis('square')
[gt,txt, stats] = txt_stat(anet.AOD_870nm(ainh_(good)), houmfr_.vdata.aerosol_optical_depth_filter5(hina_(good))',P_bar);




figure; plot(houmfr_.vdata.airmass(hina_(good)), houmfr_.vdata.aerosol_optical_depth_filter7(hina_(good))-anet.AOD_1640nm(ainh_(good))','k.');

xlabel('airmass'); ylabel('dAOD'); legend('ARM-Aeronet');
title('ARM and Aeronet AOD at 1.6 um')

agod = houmfr_.vdata.co2_optical_depth_filter7(hina_(good))+houmfr_.vdata.ch4_optical_depth_filter7(hina_(good));

figure; plot(houmfr_.vdata.airmass(hina_(good)), agod,'k.'); legend('agod')


% Redo the time series plots but include all "good" values, not just coincident
figure; plot(anet.time,anet.AOD_500nm,'cx',houmfr_.time, houmfr_.vdata.aerosol_optical_depth_filter2,'m.');
dynamicDateTicks; % xl = xlim; yl = ylim; 
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR')
title('ARM and Aeronet AOD at 500 nm'); axis(v)

figure; plot(anet.time,anet.AOD_1640nm,'rx',houmfr_.time, houmfr_.vdata.aerosol_optical_depth_filter7,'m.');
dynamicDateTicks; xlim(xl); ylim([0,.25]);
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR');
title('ARM and Aeronet AOD at 1.6 um')

figure; plot(anet.time,anet.AOD_870nm,'x',houmfr_.time, houmfr_.vdata.aerosol_optical_depth_filter5,'m.');
dynamicDateTicks; xlim(xl); ylim([0,.35]);
xlabel('time'); ylabel('AOD'); legend('Aeronet','ARM MFRSR');
title('ARM and Aeronet AOD at 870 nm')

figure; plot(houmfr_.time, houmfr_.vdata.angstrom_exponent,'k.');
dynamicDateTicks; xlim(xl); 
xlabel('time'); ylabel('Angstrom'); legend('Ang Exp');
title('Angstrom Exponent from 500 nm and 870 nm')


