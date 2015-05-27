% Easier SWS cal
% 1. Produce calibration #1, Optronics (disp temperatures too)
% 2. Produce calibration #2, 30" (disp temperatures too)
% 3. Produce calibration #3, 30" (disp temperatures too)

% 3. Load previous responsivities.
% 4. Scale most recent previous to match Optronics (at 450?)
% 5. Scale most recent previous to match 30" (at 450?)
% 6. Identify test cases from Christine's email 
% 7. Reprocess with new responsivities, provide back to Christine.

% SWS calibration visits:
% 2008_11_19 - Optronics - use 2008_02_04 calibration
% 2009_07_01 - SPEX, 30" sphere - use 2009_03_14 calibration
% 2009_09_08 - 30" sphere - use 2009_03_14 calibration


% Adopt the following spectral radiance calibration framework:
% One or more light-source files with calibration date, radiance units,
% wavelength, and radiance columns.  Preferably one growing file with time
% and several digested values as time-series and sub-structures providing
% spectral detail for each time.  
% For example:
% Archi_30in.12lamp.time(N)
% Archi_30in.12lamp.radiance_units
% Archi_30in.12lamp.flux(N)
% 
% Archi_30in.12lamp.cal{N}.nm
% Archi_30in.12lamp.cal{N}.radiance
% Archi_30in.12lamp.cal{N}.radiance_orig
% Archi_30in.12lamp.cal{N}.planck
% Archi_30in.12lamp.cal{N}.planck_T
% Archi_30in.12lamp.cal{N}.radiance_note

% For each specific detector, maintain a growing calibration history with
% calibration date, responsivity units, and time-ordered structures including 
% wavelength, light source tag, interpolated radiances, DN, detector responsivity.
% For example:
% SWS_Si.time(N)
% SWS_Si.responsivity_units
% SWS_Si.cal{N}.source = 'Archi_30in.12lamp';
% SWS_Si.cal{N}.wavelength
% SWS_Si.cal{N}.radiance_interp
% SWS_Si.cal{N}.tint
% SWS_Si.cal{N}.mean_det_temp
% SWS_Si.cal{N}.std_det_temp
% SWS_Si.cal{N}.DN
% SWS_Si.cal{N}.light
% SWS_Si.cal{N}.dark
% SWS_Si.cal{N}.sig_kHz
% SWS_Si.cal{N}.resp
% 
% Archi_30.nm = archi_temp(:,1) .* 1000;
% Archi_30.lamps_12.rad = archi_temp(:,2);
% Archi_30.lamps_9.rad = archi_temp(:,3);
% Archi_30.lamps_6.rad = archi_temp(:,4);
% Archi_30.lamps_3.rad = archi_temp(:,5);
% Archi_30.Si_lambda = [302.659 305.959 309.26 312.562 315.865 319.168 322.473 325.778 329.085 332.392 335.7 339.009 342.318 345.629 348.94 352.252 355.565 358.879 362.194 365.509 368.825 372.142 375.459 378.777 382.096 385.416 388.736 392.057 395.378 398.701 402.024 405.347 408.671 411.996 415.321 418.647 421.974 425.301 428.629 431.957 435.286 438.615 441.945 445.275 448.606 451.937 455.269 458.601 461.934 465.267 468.601 471.935 475.269 478.604 481.939 485.275 488.611 491.947 495.283 498.62 501.958 505.295 508.633 511.972 515.31 518.649 521.988 525.328 528.667 532.007 535.347 538.687 542.028 545.368 548.709 552.05 555.391 558.733 562.074 565.416 568.758 572.099 575.441 578.783 582.125 585.468 588.81 592.152 595.494 598.837 602.179 605.521 608.864 612.206 615.548 618.891 622.233 625.575 628.917 632.259 635.601 638.943 642.285 645.626 648.968 652.309 655.65 658.991 662.332 665.673 669.013 672.354 675.694 679.033 682.373 685.712 689.051 692.39 695.729 699.067 702.405 705.743 709.08 712.417 715.754 719.09 722.426 725.761 729.097 732.431 735.766 739.1 742.433 745.766 749.099 752.431 755.763 759.094 762.425 765.755 769.085 772.414 775.743 779.071 782.399 785.726 789.053 792.378 795.704 799.029 802.353 805.676 808.999 812.321 815.643 818.964 822.284 825.604 828.922 832.241 835.558 838.875 842.191 845.506 848.82 852.134 855.447 858.759 862.07 865.381 868.691 871.999 875.307 878.615 881.921 885.226 888.531 891.834 895.137 898.439 901.74 905.04 908.339 911.637 914.934 918.23 921.525 924.819 928.112 931.404 934.696 937.986 941.274 944.562 947.849 951.135 954.42 957.703 960.986 964.267 967.547 970.826 974.104 977.381 980.656 983.93 987.204 990.475 993.746 997.016 1000.28 1003.55 1006.82 1010.08 1013.34 1016.61 1019.87 1023.13 1026.38 1029.64 1032.9 1036.15 1039.4 1042.65 1045.9 1049.15 1052.4 1055.64 1058.89 1062.13 1065.37 1068.61 1071.85 1075.09 1078.32 1081.56 1084.79 1088.02 1091.25 1094.48 1097.7 1100.93 1104.15 1107.37 1110.59 1113.81 1117.03 1120.24 1123.45 1126.67 1129.88 1133.08 1136.29 1139.5 1142.7 1145.9]';
% Archi_30.In_lambda = [900.51 906.944 913.363 919.767 926.156 932.53 938.889 945.233 951.562 957.876 964.176 970.46 976.731 982.987 989.228 995.455 1001.67 1007.87 1014.05 1020.22 1026.38 1032.52 1038.65 1044.76 1050.87 1056.95 1063.03 1069.09 1075.13 1081.17 1087.19 1093.19 1099.19 1105.17 1111.14 1117.09 1123.03 1128.96 1134.88 1140.78 1146.67 1152.55 1158.41 1164.27 1170.11 1175.94 1181.75 1187.56 1193.35 1199.13 1204.9 1210.65 1216.4 1222.13 1227.85 1233.56 1239.25 1244.94 1250.61 1256.28 1261.93 1267.57 1273.2 1278.82 1284.42 1290.02 1295.6 1301.18 1306.74 1312.29 1317.83 1323.36 1328.88 1334.39 1339.89 1345.38 1350.86 1356.33 1361.79 1367.23 1372.67 1378.1 1383.52 1388.93 1394.32 1399.71 1405.09 1410.46 1415.82 1421.17 1426.51 1431.84 1437.16 1442.47 1447.78 1453.07 1458.36 1463.63 1468.9 1474.16 1479.4 1484.64 1489.88 1495.1 1500.31 1505.52 1510.71 1515.9 1521.08 1526.25 1531.42 1536.57 1541.72 1546.86 1551.99 1557.11 1562.23 1567.33 1572.43 1577.52 1582.61 1587.68 1592.75 1597.81 1602.86 1607.91 1612.95 1617.98 1623 1628.02 1633.03 1638.03 1643.03 1648.01 1653 1657.97 1662.94 1667.9 1672.85 1677.8 1682.74 1687.67 1692.6 1697.52 1702.44 1707.35 1712.25 1717.15 1722.04 1726.92 1731.8 1736.67 1741.53 1746.39 1751.25 1756.1 1760.94 1765.77 1770.61 1775.43 1780.25 1785.06 1789.87 1794.68 1799.48 1804.27 1809.06 1813.84 1818.61 1823.39 1828.15 1832.92 1837.67 1842.43 1847.17 1851.92 1856.65 1861.39 1866.12 1870.84 1875.56 1880.27 1884.98 1889.69 1894.39 1899.09 1903.78 1908.47 1913.16 1917.84 1922.52 1927.19 1931.86 1936.52 1941.18 1945.84 1950.49 1955.14 1959.79 1964.43 1969.07 1973.71 1978.34 1982.97 1987.59 1992.21 1996.83 2001.45 2006.06 2010.67 2015.27 2019.88 2024.48 2029.07 2033.67 2038.26 2042.85 2047.43 2052.01 2056.59 2061.17 2065.74 2070.32 2074.89 2079.45 2084.02 2088.58 2093.14 2097.7 2102.25 2106.8 2111.36 2115.9 2120.45 2124.99 2129.54 2134.08 2138.62 2143.15 2147.69 2152.22 2156.75 2161.28 2165.81 2170.34 2174.86 2179.38 2183.91 2188.43 2192.94 2197.46 2201.98 2206.49 2211.01 2215.52 2220.03]';
% save('C:\mlib\sws\ARCHI_30_20080314.mat','Archi_30')
%%
resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
tmp = load([resp_dir, 'sgpswsC1.resp_func.200707200000.si.100ms.dat']);
sws_resp.Si_lambda = tmp(:,1);
sws_resp.Si_base = tmp(:,2);
tmp = load([resp_dir, 'sgpswsC1.resp_func.200707200000.ir.250ms.dat']);
sws_resp.In_lambda = tmp(:,1);
sws_resp.In_base = tmp(:,2);

%%
Archi_30 = loadinto('C:\mlib\sws\ARCHI_30_20080314.mat');
%%
Archi_30.radiance_units = ['W/(m^2.sr.nm)'];
sws_resp.radiance_units = ['W/(m^2.sr.nm)'];
% Archi_30.lamps_12.rad = Archi_30.lamps_12.rad./1000;
% Archi_30.lamps_9.rad = Archi_30.lamps_9.rad./1000;
% Archi_30.lamps_6.rad = Archi_30.lamps_6.rad./1000;
% Archi_30.lamps_3.rad = Archi_30.lamps_3.rad./1000;

sws_resp.Archi_30.lamps_12.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_12.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_9.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_9.rad, sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_6.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_6.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_3.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_3.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_12.In_rad = interp1(Archi_30.nm,Archi_30.lamps_12.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_9.In_rad = interp1(Archi_30.nm,Archi_30.lamps_9.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_6.In_rad = interp1(Archi_30.nm,Archi_30.lamps_6.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_3.In_rad = interp1(Archi_30.nm,Archi_30.lamps_3.rad,sws_resp.In_lambda, 'linear');
save('C:\mlib\sws\ARCHI_30_20080314.mat','Archi_30')

%%
% sgpswscf.00.20090909.010740.raw.dat 12-lamps, Si_ms = 80, In_ms = 220
% sws_raw = read_sws_raw('C:\case_studies\SWS\calibration\NASA_ARC_2009_09_08\ARCI_30in_sphere_radiance_cal\12_lamps\sgpswscf.00.20090909.010740.raw.dat');

%Archi Radiance is in units W(m^2.sr.um)

% ARM netcdf radiance is in W/(m^2 nm sr)
%%

nm_max = 1040;
% cm_max = nm_max / 1e7;
% T = 0.28978./cm_max;
T = 2850 ;
p_T = planck_in_wl(Archi_30.nm./1e9,T); 
cm_max = 0.28978./T;
nm_max = 1e7*cm_max;
nm_ind = round(interp1(Archi_30.nm,[1:length(Archi_30.nm)],nm_max));
figure;
ax(1) = subplot(2,1,1);
semilogy(Archi_30.nm, Archi_30.lamps_12.rad  , '.r-',Archi_30.nm,p_T .* Archi_30.lamps_12.rad(nm_ind)./p_T(nm_ind),'g-'); 
title(['T = ',num2str(T)]);
ax(2) = subplot(2,1,2); 
rat = diff(log10(Archi_30.lamps_12.rad))-diff(log10(p_T));
r = Archi_30.nm> 450 & Archi_30.nm < nm_max;
sum_rat = trapz(Archi_30.nm(r), abs(rat(r(2:end)))./Archi_30.nm(r));
plot(Archi_30.nm(2:end),rat , 'k-');
title(['sum ratio = ',sprintf('%2.4e',sum_rat)]);
linkaxes(ax,'x');
xlim([450,nm_max+20]);
%Augment Optronics with matched Planck curve below 450 nm.

%%
% 
% Optronics.Aper_A.planck_T = T;
% Optronics.Aper_A.Si_rad(1:45) = planck_in_wl(Optronics.Si_lambda(1:45)./1e9,Optronics.Aper_A.planck_T).* Optronics.Aper_A.rad(nm_ind)./p_T(nm_ind);
% figure; plot(Optronics.Si_lambda, Optronics.Aper_A.Si_rad,'b.')
% % figure; plot(Optronics.nm, Optronics.Aper_A.rad, 'k-',Optronics.Si_lambda, Optronics.Aper_A.Si_rad, 'b.',...
% %    Optronics.In_lambda, Optronics.Aper_A.In_rad, 'r.')
%%
%%

lights_A = make_sws_cal_pair(['C:\case_studies\SWS\calibration\NASA_ARC_2009_09_08\ARCI_30in_sphere_radiance_cal\12_lamps\sgpswscf.00.20090909.010740.raw.dat']);

%%
sws_resp.Archi_30.lamps_12.Si_avg_cps = lights_A.avg_Si_per_ms;
sws_resp.Archi_30.lamps_12.Si_resp = sws_resp.Archi_30.lamps_12.Si_avg_cps ./ sws_resp.Archi_30.lamps_12.Si_rad;
sws_resp.Archi_30.lamps_12.In_avg_cps = lights_A.avg_In_per_ms;
sws_resp.Archi_30.lamps_12.In_resp = sws_resp.Archi_30.lamps_12.In_avg_cps ./ sws_resp.Archi_30.lamps_12.In_rad;
sws_resp.Archi_30.lamps_12.Si_avg_SNR = lights_A.avg_Si_SNR;
sws_resp.Archi_30.lamps_12.In_avg_SNR = lights_A.avg_In_SNR;

figure; 
hold('on');
plot(sws_resp.Si_lambda, sws_resp.Archi_30.lamps_12.Si_resp, 'bx',...
   sws_resp.In_lambda, sws_resp.Archi_30.lamps_12.In_resp, 'rx')
title('Responsivity of SWS Si and InGaAs detectors')
xlabel('wavelength')
ylabel(['DN/',sws_resp.radiance_units]);
hold('off');
%%
resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
si_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.si.',num2str(lights_A.Si_ms(1)),'ms.dat'];
ir_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.ir.',num2str(lights_A.In_ms(1)),'ms.dat'];
si_out = [sws_resp.Si_lambda, sws_resp.Archi_30.lamps_12.Si_resp]';
In_out = [sws_resp.In_lambda, sws_resp.Archi_30.lamps_12.In_resp]';
si_fid = fopen([resp_dir,si_stem],'w');
fprintf(si_fid,'   %5.3f    %5.3f \n',si_out);
fclose(si_fid);
In_fid = fopen([resp_dir,ir_stem],'w');
fprintf(In_fid,'   %5.3f    %5.3f \n',In_out);
fclose(In_fid);

