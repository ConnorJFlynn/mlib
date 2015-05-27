function mfrsr = mfrsr_ql(mfrsr);
%%

qc_aod1 = qc_impacts(mfrsr.vars.qc_aerosol_optical_depth_filter1);
qc_aod2 = qc_impacts(mfrsr.vars.qc_aerosol_optical_depth_filter2);
qc_aod3 = qc_impacts(mfrsr.vars.qc_aerosol_optical_depth_filter3);
qc_aod4 = qc_impacts(mfrsr.vars.qc_aerosol_optical_depth_filter4);
qc_aod5 = qc_impacts(mfrsr.vars.qc_aerosol_optical_depth_filter5);
qc_ang = qc_impacts(mfrsr.vars.qc_angstrom_exponent);

qc_dirnor1 = qc_impacts(mfrsr.vars.qc_direct_normal_narrowband_filter1);
qc_dirnor2 = qc_impacts(mfrsr.vars.qc_direct_normal_narrowband_filter2);
qc_dirnor3 = qc_impacts(mfrsr.vars.qc_direct_normal_narrowband_filter3);
qc_dirnor4 = qc_impacts(mfrsr.vars.qc_direct_normal_narrowband_filter4);
qc_dirnor5 = qc_impacts(mfrsr.vars.qc_direct_normal_narrowband_filter5);

qc_ddr1 = qc_impacts(mfrsr.vars.qc_direct_diffuse_ratio_filter1);
qc_ddr2 = qc_impacts(mfrsr.vars.qc_direct_diffuse_ratio_filter2);
qc_ddr3 = qc_impacts(mfrsr.vars.qc_direct_diffuse_ratio_filter3);
qc_ddr4 = qc_impacts(mfrsr.vars.qc_direct_diffuse_ratio_filter4);
qc_ddr5 = qc_impacts(mfrsr.vars.qc_direct_diffuse_ratio_filter5);
%%

figure(1); 
ax(1) = subplot(2,1,1); 
plot(serial2doy(mfrsr.time(qc_aod2<2)),mfrsr.vars.aerosol_optical_depth_filter2.data(qc_aod2<2),'y.',...
   serial2doy(mfrsr.time(qc_aod2<1)),mfrsr.vars.aerosol_optical_depth_filter2.data(qc_aod2<1),'g.');
title('Aerosol optical depth filter 2, nominal CWL 500 nm');
ylabel('AOD');
legend('caution','good','location','NorthEast');
ylim([0,.5])
ax(2) = subplot(2,1,2);
plot(serial2doy(mfrsr.time(qc_aod2<2)),mfrsr.vars.angstrom_exponent.data(qc_aod2<2),'y.',...
   serial2doy(mfrsr.time(qc_aod2<1)),mfrsr.vars.angstrom_exponent.data(qc_aod2<1),'g.');
title('Angstrom exponent from 500 nm and 870 nm');
xlabel('time (day of year)')
ylabel('unitless');
legend('caution','good','Location','SouthEast');
ylim([-.5, 1.5])
linkaxes(ax,'x');
%%
%%

figure(2); 
plot(serial2doy(mfrsr.time(qc_aod1<2)),mfrsr.vars.aerosol_optical_depth_filter1.data(qc_aod2<2),'b.',...
   serial2doy(mfrsr.time(qc_aod2<2)),mfrsr.vars.aerosol_optical_depth_filter2.data(qc_aod2<2),'c.', ...
   serial2doy(mfrsr.time(qc_aod3<2)),mfrsr.vars.aerosol_optical_depth_filter3.data(qc_aod3<2),'g.', ...
   serial2doy(mfrsr.time(qc_aod4<2)),mfrsr.vars.aerosol_optical_depth_filter4.data(qc_aod4<2),'m.', ...
   serial2doy(mfrsr.time(qc_aod5<2)),mfrsr.vars.aerosol_optical_depth_filter5.data(qc_aod5<2),'r.');

hold('on')
plot(serial2doy(mfrsr.time(qc_aod1==1)),mfrsr.vars.aerosol_optical_depth_filter1.data(qc_aod2==1),'yo',...
   serial2doy(mfrsr.time(qc_aod2==1)),mfrsr.vars.aerosol_optical_depth_filter2.data(qc_aod2==1),'yo', ...
   serial2doy(mfrsr.time(qc_aod3==1)),mfrsr.vars.aerosol_optical_depth_filter3.data(qc_aod3==1),'yo', ...
   serial2doy(mfrsr.time(qc_aod4==1)),mfrsr.vars.aerosol_optical_depth_filter4.data(qc_aod4==1),'yo', ...
   serial2doy(mfrsr.time(qc_aod5==1)),mfrsr.vars.aerosol_optical_depth_filter5.data(qc_aod5==1),'yo');
legend('415 nm', '500 nm', '615 nm', '673 nm', '870 nm','questionable','location','NorthEast');
title('Aerosol optical depth, all filters');
ylabel('AOD');
% legend('415 nm', '500 nm', '615 nm', '673 nm', '870 nm','location','NorthEast');
ylim([0,.5]);
hold('off');

%

ylim([0,.5]);
%%

