%%
%Load new MFRSR files
C1 = ancload;
E13 = ancload;
%%
%Compute sun-distance correction
r_sun = C1.vars.sun_to_earth_distance.data;
r2_sun = r_sun.^2;
am = C1.vars.airmass.data;
%Get TOA from metadata (same for both C1 and E13)
TOA = sscanf(C1.vars.direct_normal_narrowband_filter2.atts.Gueymard_TOA_filter2.data,'%f');
%Get Io values (different for each instrument)
Io_C1 = C1.vars.Io_filter2.data;
Io_E13 = E13.vars.Io_filter2.data;

%%
figure(1); plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter1.data, 'r.', ...
serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter1.data, 'go')
title('Direct normal, filter 1, as in file');
xlim(xl);ylim('auto');
figure(2); plot(serial2doy(C1.time), C1.vars.aerosol_optical_depth_filter1.data, 'r.', ...
serial2doy(E13.time), E13.vars.aerosol_optical_depth_filter1.data, 'go')
title('AOD, filter 1, as in file')   
xlim(xl);ylim('auto');
%%

figure(1); plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter2.data, 'r.', ...
serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter2.data, 'go')
title('Direct normal, filter 2, as in file');
xlim(xl);ylim('auto');
figure(2); plot(serial2doy(C1.time), C1.vars.aerosol_optical_depth_filter2.data, 'r.', ...
serial2doy(E13.time), E13.vars.aerosol_optical_depth_filter2.data, 'go')
title('AOD, filter 2, as in file')   
xlim(xl);ylim('auto');
%%

figure(1); plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter3.data, 'r.', ...
serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter3.data, 'go')
title('Direct normal, filter 3, as in file')   
xlim(xl);ylim('auto');
figure(2); plot(serial2doy(C1.time), C1.vars.aerosol_optical_depth_filter3.data, 'r.', ...
serial2doy(E13.time), E13.vars.aerosol_optical_depth_filter3.data, 'go')
title('AOD, filter 3, as in file')   
xlim(xl);ylim('auto');
%%

figure(1); plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter4.data, 'r.', ...
serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter4.data, 'go')
title('Direct normal, filter 4, as in file')   
xlim(xl);ylim('auto');
figure(2); plot(serial2doy(C1.time), C1.vars.aerosol_optical_depth_filter4.data, 'r.', ...
serial2doy(E13.time), E13.vars.aerosol_optical_depth_filter4.data, 'go')
title('AOD, filter 4, as in file')  
xlim(xl);ylim('auto');
%%

figure(1); plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter5.data, 'r.', ...
serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter5.data, 'go')
title('Direct normal, filter 5, as in file')   
xlim(xl);ylim('auto');
figure(2); plot(serial2doy(C1.time), C1.vars.aerosol_optical_depth_filter5.data, 'r.', ...
serial2doy(E13.time), E13.vars.aerosol_optical_depth_filter5.data, 'go')
title('AOD, filter 5, as in file')   
xlim(xl);ylim('auto');

 
%%
C1_prior = ancload;
E13_prior = ancload;
%%
TOA_filter1 = sscanf(C1.vars.direct_normal_narrowband_filter1.atts.Gueymard_TOA_filter1.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter1.data./C1_prior.vars.direct_normal_narrowband_filter1.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter1.data./E13_prior.vars.direct_normal_narrowband_filter1.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter1 / Io_filter1 =',num2str(TOA_filter1/C1.vars.Io_filter1.data)],['E13: TOA_filter1 / Io_filter1 =',num2str(TOA_filter1/E13.vars.Io_filter1.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter1');
%%
TOA_filter2 = sscanf(C1.vars.direct_normal_narrowband_filter2.atts.Gueymard_TOA_filter2.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter2.data./C1_prior.vars.direct_normal_narrowband_filter2.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter2.data./E13_prior.vars.direct_normal_narrowband_filter2.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter2 / Io_filter2 =',num2str(TOA_filter2/C1.vars.Io_filter2.data)],['E13: TOA_filter2 / Io_filter2 =',num2str(TOA_filter2/E13.vars.Io_filter2.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter2');

%%
TOA_filter3 = sscanf(C1.vars.direct_normal_narrowband_filter3.atts.Gueymard_TOA_filter3.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter3.data./C1_prior.vars.direct_normal_narrowband_filter3.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter3.data./E13_prior.vars.direct_normal_narrowband_filter3.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter3 / Io_filter3 =',num2str(TOA_filter3/C1.vars.Io_filter3.data)],['E13: TOA_filter3 / Io_filter3 =',num2str(TOA_filter3/E13.vars.Io_filter3.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter3');

%%
TOA_filter4 = sscanf(C1.vars.direct_normal_narrowband_filter4.atts.Gueymard_TOA_filter4.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter4.data./C1_prior.vars.direct_normal_narrowband_filter4.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter4.data./E13_prior.vars.direct_normal_narrowband_filter4.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter4 / Io_filter4 =',num2str(TOA_filter4/C1.vars.Io_filter4.data)],['E13: TOA_filter4 / Io_filter4 =',num2str(TOA_filter4/E13.vars.Io_filter4.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter4');
%%
TOA_filter5 = sscanf(C1.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.direct_normal_narrowband_filter5.data./C1_prior.vars.direct_normal_narrowband_filter5.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.direct_normal_narrowband_filter5.data./E13_prior.vars.direct_normal_narrowband_filter5.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter5 / Io_filter5 =',num2str(TOA_filter5/C1.vars.Io_filter5.data)],['E13: TOA_filter5 / Io_filter5 =',num2str(TOA_filter5/E13.vars.Io_filter5.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter5');
%%
%%
TOA_filter1 = sscanf(C1.vars.diffuse_hemisp_narrowband_filter1.atts.Gueymard_TOA_filter1.data,'%f');
%C1.vars.Io_filter2.data;
figure(4); 
plot(serial2doy(C1.time), C1.vars.diffuse_hemisp_narrowband_filter1.data./C1_prior.vars.diffuse_hemisp_narrowband_filter1.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.diffuse_hemisp_narrowband_filter1.data./E13_prior.vars.diffuse_hemisp_narrowband_filter1.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter1 / Io_filter1 =',num2str(TOA_filter1/C1.vars.Io_filter1.data)],['E13: TOA_filter1 / Io_filter1 =',num2str(TOA_filter1/E13.vars.Io_filter1.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter1');
%%
TOA_filter2 = sscanf(C1.vars.diffuse_hemisp_narrowband_filter2.atts.Gueymard_TOA_filter2.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.diffuse_hemisp_narrowband_filter2.data./C1_prior.vars.diffuse_hemisp_narrowband_filter2.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.diffuse_hemisp_narrowband_filter2.data./E13_prior.vars.diffuse_hemisp_narrowband_filter2.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter2 / Io_filter2 =',num2str(TOA_filter2/C1.vars.Io_filter2.data)],['E13: TOA_filter2 / Io_filter2 =',num2str(TOA_filter2/E13.vars.Io_filter2.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter2');

%%
TOA_filter3 = sscanf(C1.vars.diffuse_hemisp_narrowband_filter3.atts.Gueymard_TOA_filter3.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.diffuse_hemisp_narrowband_filter3.data./C1_prior.vars.diffuse_hemisp_narrowband_filter3.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.diffuse_hemisp_narrowband_filter3.data./E13_prior.vars.diffuse_hemisp_narrowband_filter3.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter3 / Io_filter3 =',num2str(TOA_filter3/C1.vars.Io_filter3.data)],['E13: TOA_filter3 / Io_filter3 =',num2str(TOA_filter3/E13.vars.Io_filter3.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter3');

%%
TOA_filter4 = sscanf(C1.vars.diffuse_hemisp_narrowband_filter4.atts.Gueymard_TOA_filter4.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.diffuse_hemisp_narrowband_filter4.data./C1_prior.vars.diffuse_hemisp_narrowband_filter4.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.diffuse_hemisp_narrowband_filter4.data./E13_prior.vars.diffuse_hemisp_narrowband_filter4.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter4 / Io_filter4 =',num2str(TOA_filter4/C1.vars.Io_filter4.data)],['E13: TOA_filter4 / Io_filter4 =',num2str(TOA_filter4/E13.vars.Io_filter4.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter4');
%%
TOA_filter5 = sscanf(C1.vars.diffuse_hemisp_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
%C1.vars.Io_filter2.data;
figure(3); 
plot(serial2doy(C1.time), C1.vars.diffuse_hemisp_narrowband_filter5.data./C1_prior.vars.diffuse_hemisp_narrowband_filter5.data,'r.')
hold('on');
plot(serial2doy(E13.time), E13.vars.diffuse_hemisp_narrowband_filter5.data./E13_prior.vars.diffuse_hemisp_narrowband_filter5.data,'b.')
hold('off');
leg = legend(['C1: TOA_filter5 / Io_filter5 =',num2str(TOA_filter5/C1.vars.Io_filter5.data)],['E13: TOA_filter5 / Io_filter5 =',num2str(TOA_filter5/E13.vars.Io_filter5.data)]);
set(leg,'Interpreter','none','location','northwest')
title('TOA to Io scaling, filter5');
