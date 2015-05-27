function ax = plot_aip(aip);

axi = 1;
figure; plot(serial2doy(aip.time), [aip.Bsp_B_Dry_1um,aip.Bsp_G_Dry_1um,aip.Bsp_R_Dry_1um],'.');
hold('on');
plot(serial2doy(aip.time), [aip.Bsp_B_Dry_10um,aip.Bsp_G_Dry_10um,aip.Bsp_R_Dry_10um],'x');
hold('off')
legend('blue','green','red');
title('scattering coef')
ylabel('1/Mm')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.Bap_B_3W_1um,aip.Bap_G_3W_1um,aip.Bap_R_3W_1um],'.');
hold('on');
plot(serial2doy(aip.time), [aip.Bap_B_3W_10um,aip.Bap_G_3W_10um,aip.Bap_R_3W_10um],'x');
hold('off')
legend('blue','green','red');
title('absorption coef')
ylabel('1/Mm')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.Ang_Bs_B_G_10um,aip.Ang_Bs_B_R_10um,aip.Ang_Bs_G_R_10um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, scattering, 10 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.Ang_Bs_B_G_1um,aip.Ang_Bs_B_R_1um,aip.Ang_Bs_G_R_1um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, scattering, 1 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.Ang_Ba_B_G_10um,aip.Ang_Ba_B_R_10um,aip.Ang_Ba_G_R_10um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, absorption, 10 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.Ang_Ba_B_G_1um,aip.Ang_Ba_B_R_1um,aip.Ang_Ba_G_R_1um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, absorption, 1 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.subfrac_Bs_B,aip.subfrac_Bs_G,aip.subfrac_Bs_R],'.')
legend('blue','green','red');
title('Submicron scattering fraction')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.subfrac_Ba_B,aip.subfrac_Ba_G,aip.subfrac_Ba_R],'.')
legend('blue','green','red');
title('Submicron absorption fraction')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.w_B_1um,aip.w_G_1um,aip.w_R_1um],'.');
legend('blue','green','red');
title('SSA 1um')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip.time), [aip.w_B_10um,aip.w_G_10um,aip.w_R_10um],'.');
legend('blue','green','red');
title('SSA 10um')
ax(axi) =gca; axi = axi+1;
%

figure; plot(serial2doy(aip.time), [aip.CN_frac],'.',serial2doy(aip.time), [aip.SS_pct],'k');
legend('CN_frac','SS_pct');
title('CN_frac')
ax(axi) =gca; axi = axi+1;
linkaxes(ax,'x')