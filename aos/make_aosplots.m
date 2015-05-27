function status = make_aosplots(pname, fname)
% status = make_aosplots()
 cdfid = ncmex('OPEN', [pname fname]);

RH_wetNeph = nc_getvar(cdfid, 'RH_wetNeph');
RH_refNeph = nc_getvar(cdfid, 'RH_refNeph');
aos_flags = nc_getvar(cdfid, 'flags');
Bsp_B_dry = nc_getvar(cdfid, 'Bsp_B_1um_RefRH');
Bsp_G_dry = nc_getvar(cdfid, 'Bsp_G_1um_RefRH');
Bsp_R_dry = nc_getvar(cdfid, 'Bsp_R_1um_RefRH');
Bbsp_B_dry = nc_getvar(cdfid, 'Bbsp_B_1um_RefRH');
Bbsp_G_dry = nc_getvar(cdfid, 'Bbsp_G_1um_RefRH');
Bbsp_R_dry = nc_getvar(cdfid, 'Bbsp_R_1um_RefRH');
time = nc_time(cdfid);
Bsp_B_wet = nc_getvar(cdfid, 'Bsp_B_1um_WetRH');
Bsp_G_wet = nc_getvar(cdfid, 'Bsp_G_1um_WetRH');
Bsp_R_wet = nc_getvar(cdfid, 'Bsp_R_1um_WetRH');
Bbsp_B_wet = nc_getvar(cdfid, 'Bbsp_B_1um_WetRH');
Bbsp_G_wet = nc_getvar(cdfid, 'Bbsp_G_1um_WetRH');
Bbsp_R_wet = nc_getvar(cdfid, 'Bbsp_R_1um_WetRH');
bfrac_B_wet = Bbsp_B_wet ./ Bsp_B_wet;
bfrac_G_wet = Bbsp_G_wet ./ Bsp_G_wet;
bfrac_R_wet = Bbsp_R_wet ./ Bsp_R_wet;
goods = find((Bbsp_B_wet>0)&(Bbsp_R_wet>0)&(Bbsp_G_wet>0)&(Bsp_R_wet>0)&(Bsp_G_wet>0)&(Bsp_B_wet>0));
ramp = ramps(RH_wetNeph(goods), 10);
for i = 1:max(ramp)
rampcell{i} = find(ramp==i);
end

% i = 1;
% figure; semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i}))], 'x')
% xlabel(['Relative humidity %']);
% ylabel(['log[Bsp_B(wet)/Bsp_B(dry)]']);
% title([datestr(time(1),1)]);
% hold
% for i = 2:max(ramp)
% semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i}))], 'x')
% end
% 
% print('-dmeta', [pname, datestr(time(1),29), '.log_fRH', '.png']);
% close 

i = 1;
figure; plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i}))], 'x')
xlabel(['Relative humidity %']);
ylabel(['Bsp_B(wet)/Bsp_B(dry)']);
title([datestr(time(1),1)]);
axis([30,90,.5,2.5]);
hold
for i = 2:max(ramp)
plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i}))], 'x')
end

print('-dmeta', [pname, datestr(time(1),29), '.fRH', '.png']);
close 

% i = 1;
% figure; plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), bfrac_B_wet(goods(rampcell{i}))], 'x')
% hold
% for i = 2:max(ramp)
% plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), bfrac_B_wet(goods(rampcell{i}))], 'x')
% end
% 
% i = 1;
% figure; semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), bfrac_B_wet(goods(rampcell{i}))], 'x')
% hold
% for i = 2:max(ramp)
% semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), bfrac_B_wet(goods(rampcell{i}))], 'x')
% end
% 
% i = 1;
% figure; plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i}))], 'x')
% hold
% for i = 2:max(ramp)
% plot(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i}))], 'x')
% end
% 
% figure; semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), 10*bfrac_B_wet(goods(rampcell{i}))], 'x')
% for i = 1:max(ramp)
% figure;semilogy(RH_wetNeph(goods(rampcell{i})), [Bsp_B_wet(goods(rampcell{i}))./Bsp_B_dry(goods(rampcell{i})), Bbsp_B_wet(goods(rampcell{i}))./Bbsp_B_dry(goods(rampcell{i})), bfrac_B_wet(goods(rampcell{i}))], 'x')
% title(['RH ramp #',num2str(i)]);
% xlabel(['Relative humidity %']);
% legend('Bsp f(RH)', 'Bbsp f(RH)', 'bfrac');
% end

ncmex('close', cdfid);