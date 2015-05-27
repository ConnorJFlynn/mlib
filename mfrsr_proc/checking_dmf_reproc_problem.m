dev = ancload;
dmf = ancload;
%%
E13 = ancload;
nimfr = ancload;
%%
good = dev.vars.aerosol_optical_depth_filter1.data>0 & dmf.vars.aerosol_optical_depth_filter1.data>0;
goodnim = nimfr.vars.aerosol_optical_depth_filter1.data > 0;
goodE13 = E13.vars.aerosol_optical_depth_filter1.data > 0;
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.direct_normal_narrowband_filter1.data(good) .* dev.vars.Io_filter1.data - dmf.vars.direct_normal_narrowband_filter1.data(good) .* dmf.vars.Io_filter1.data, '.')
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.aerosol_optical_depth_filter1.data(good), 'go',...
   serial2doy(dmf.time(good)), dmf.vars.aerosol_optical_depth_filter1.data(good), 'bx',...
   serial2doy(E13.time(goodE13)), E13.vars.aerosol_optical_depth_filter1.data(goodE13), 'co',...
   serial2doy(nimfr.time(goodnim)), nimfr.vars.aerosol_optical_depth_filter1.data(goodnim), 'kx');
legend('dev','dmf','E13','nimfr')
title('Aerosol optical depths filter 1')

%.*(dev.vars.Io_filter1.data
%
%./(dmf.vars.Io_filter1.data./sscanf(dmf.atts.filter1_TOA_direct_normal.dat
%a,'%f'))
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.aerosol_optical_depth_filter2.data(good), 'go',...
   serial2doy(dmf.time(good)), dmf.vars.aerosol_optical_depth_filter2.data(good), 'bx',...
   serial2doy(E13.time(goodE13)), E13.vars.aerosol_optical_depth_filter2.data(goodE13), 'co',...
   serial2doy(nimfr.time(goodnim)), nimfr.vars.aerosol_optical_depth_filter2.data(goodnim), 'kx');
legend('dev','dmf','E13','nimfr')
title('Aerosol optical depths filter 2')
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.aerosol_optical_depth_filter3.data(good), 'go',...
   serial2doy(dmf.time(good)), dmf.vars.aerosol_optical_depth_filter3.data(good), 'bx',...
   serial2doy(E13.time(goodE13)), E13.vars.aerosol_optical_depth_filter3.data(goodE13), 'co',...
   serial2doy(nimfr.time(goodnim)), nimfr.vars.aerosol_optical_depth_filter3.data(goodnim), 'kx');
legend('dev','dmf','E13','nimfr')
title('Aerosol optical depths filter 3')
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.aerosol_optical_depth_filter4.data(good), 'go',...
   serial2doy(dmf.time(good)), dmf.vars.aerosol_optical_depth_filter4.data(good), 'bx',...
   serial2doy(E13.time(goodE13)), E13.vars.aerosol_optical_depth_filter4.data(goodE13), 'co',...
   serial2doy(nimfr.time(goodnim)), nimfr.vars.aerosol_optical_depth_filter4.data(goodnim), 'kx');
legend('dev','dmf','E13','nimfr')
title('Aerosol optical depths filter 4')
%%
figure; plot(serial2doy(dev.time(good)), dev.vars.aerosol_optical_depth_filter5.data(good), 'go',...
   serial2doy(dmf.time(good)), dmf.vars.aerosol_optical_depth_filter5.data(good), 'bx',...
   serial2doy(E13.time(goodE13)), E13.vars.aerosol_optical_depth_filter5.data(goodE13), 'co',...
   serial2doy(nimfr.time(goodnim)), nimfr.vars.aerosol_optical_depth_filter5.data(goodnim), 'kx');
legend('dev','dmf','E13','nimfr')
title('Aerosol optical depths filter 5')
