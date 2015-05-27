%%
 Optronics = loadinto('C:\mlib\sws\Optronics.mat');
%%
Optronics.radiance_units = ['W/(m^2.sr.nm)']; % data file contains 'W/(m^2-sr-um)' and 'W/(cm^2-sr-nm)'
Optronics.nm = [400 410 420 430 440 450 460 470 480 490 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800 810 820 830 840 850 860 870 880 890 900 910 920 930 940 950 960 970 980 990 1000 1010 1020 1030 1040 1050 1060 1070 1080 1090 1100 1110 1120 1130 1140 1150 1160 1170 1180 1190 1200 1210 1220 1230 1240 1250 1260 1270 1280 1290 1300 1310 1320 1330 1340 1350 1360 1370 1380 1390 1400 1410 1420 1430 1440 1450 1460 1470 1480 1490 1500 1510 1520 1530 1540 1550 1560 1570 1580 1590 1600 1610 1620 1630 1640 1650 1660 1670 1680 1690 1700 1710 1720 1730 1740 1750 1760 1770 1780 1790 1800 1810 1820 1830 1840 1850 1860 1870 1880 1890 1900 1910 1920 1930 1940 1950 1960 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070 2080 2090 2100 2110 2120 2130 2140 2150 2160 2170 2180 2190 2200 2210 2220 2230 2240 2250 2260 2270 2280 2290 2300 2310 2320 2330 2340 2350 2360 2370 2380]';
Optronics.Aper_A.rad = 1e-3*[29.6 36.9 45.6 54.7 64.6 75.3 87 98.9 112 126 140 155 171 187 203 220 236 253 269 285 304 320 336 352 368 383 399 415 429 445 459 474 489 501 511 522 531 540 548 555 561 566 571 578 583 590 596 603 611 619 625 633 644 648 653 660 666 673 676 681 684 686 687 687 687 687 687 686 684 683 678 671 664 660 655 651 646 640 633 631 628 625 623 619 615 609 603 596 589 584 578 570 562 552 542 517 491 483 475 468 461 462 462 460 457 453 449 443 436 433 429 423 417 412 406 400 394 390 385 380 376 369 363 356 350 342 334 325 315 306 298 293 288 285 281 280 279 276 274 268 263 254 246 237 227 223 218 215 212 207 202 196 191 188 185 179 173 167 161 154 147 139 132 125 118 113 108 104 99.9 95.4 90.8 86.5 82.1 80.9 79.7 82.2 84.7 89.3 93.9 97.3 101 101 100 98.4 96.3 92.9 89.5 85.2 80.8 76.7 72.5 69.7 66.8 63.4 59.9 57.7 55.4 54 52.5]';
Optronics.Aper_B.rad = 1e-3*[16.5 20.3 25 30 35.9 42.1 48.4 54.8 62.2 70.1 78 86.5 95.2 104 113 122 131 140 149 158 169 177 186 195 203 212 220 229 237 246 254 262 271 278 284 291 295 301 305 310 313 316 319 322 325 329 333 337 341 346 349 354 360 362 366 370 372 376 378 382 384 386 386 385 383 381 380 382 383 382 378 373 369 368 367 366 364 359 354 352 351 350 349 346 344 341 339 335 331 328 325 321 316 310 304 290 276 271 266 263 261 260 260 259 258 255 252 249 247 244 241 239 236 233 229 226 222 219 217 214 211 207 204 200 196 192 187 182 176 172 167 165 162 160 158 157 157 155 153 150 147 142 137 132 127 124 121 120 119 116 113 110 107 105 103 101 98.4 94.4 90.4 86.7 82.9 78.6 74.3 70.5 66.7 64 61.3 58.5 55.6 53.4 51.1 48.4 45.7 45 44.2 45.5 46.8 49.5 52.2 54 55.8 55.7 55.5 54.2 52.8 50.8 48.7 46.3 43.8 41.7 39.5 37.8 36.1 34.3 32.5 30.7 28.9 28 27]';
Optronics.Aper_C.rad = 1e-3*[8.1 10.4 12.7 15.2 18 20.9 24.3 27.6 31.4 35.3 39.3 43.5 47.8 52.3 56.8 61.4 66 70.7 75.3 79.8 85.1 89.5 94 98.1 102 107 111 116 119 124 128 133 137 141 144 147 150 153 155 157 159 160 162 163 165 167 169 171 173 176 178 180 183 185 186 188 190 193 193 195 195 195 195 197 198 196 194 195 198 198 197 193 190 189 188 188 188 185 183 183 183 182 181 180 180 177 175 173 171 170 168 166 164 161 157 150 142 140 139 137 135 136 138 136 135 134 132 131 129 126 124 123 123 121 120 119 117 115 113 111 108 106 104 102 100 98.1 96 93.5 90.9 88.3 85.7 84.6 83.5 82.1 80.6 80.7 80.8 79.7 78.6 77 75.4 73.2 70.9 68.2 65.5 64.2 62.9 62 61.1 60.1 59 56.7 54.3 53.9 53.4 51.8 50.1 48.2 46.3 44.4 42.5 40.2 37.8 35.9 33.9 32.5 31.1 29.9 28.6 27 25.3 24.1 22.9 22.4 21.9 22.7 23.5 24.9 26.3 27.2 28.1 28.1 28.1 27.4 26.6 25.3 23.9 22.8 21.7 20.3 18.8 18.1 17.3 16 14.7 13.7 12.7 12.2 11.7]';
Optronics.Aper_D.rad = 1e-3*[3.6 4.7 5.7 6.9 8 9.4 10.9 12.3 14 15.9 17.8 19.6 21.7 23.7 25.7 28 30 32.1 34.3 36.4 38.8 40.8 42.8 44.9 46.8 48.8 50.7 52.7 54.5 56.6 58.4 60.3 62.3 64 65.2 66.9 68 69.2 70.3 71.2 72.1 72.8 73.4 74.4 75.1 76 76.9 77.8 78.8 79.9 80.8 81.7 82.9 83.2 83.8 85.2 86.3 87 86.8 87.2 87.6 87.9 88.4 88.9 89.3 88.9 88.3 87.8 87.6 87.6 86.7 85.3 83.9 83.4 82.8 82.7 82.6 82 81.4 81.3 81.2 80.8 80.3 80 79.7 78.8 77.8 77.6 77.4 76.5 75.6 74.9 74.2 72.5 70.7 67.1 63.5 63.2 62.8 61.4 60 61 62 61.1 60.1 59.9 59.6 58.8 57.9 57.3 56.6 56.3 55.9 55.2 54.5 53.8 53 52.3 51.5 50.1 48.7 47.8 46.9 46.2 45.4 44.5 43.6 42.5 41.3 40 38.6 37.9 37.2 37.1 36.9 36.7 36.4 35.7 35 34.5 34 32.8 31.6 30.6 29.5 29 28.4 27.7 26.9 26.4 25.8 25.4 25 24.5 23.9 23.2 22.4 21.6 20.8 19.5 18.2 17.4 16.6 15.9 15.2 14.5 13.7 13.2 12.7 11.8 10.9 10.5 10.1 9.7 9.3 9.35 9.4 10.2 11 11.4 11.8 11.7 11.6 11.3 11 10.4 9.7 9.1 8.5 7.8 7.1 6.75 6.4 5.55 4.7 4.4 4.1 3.6 3.1]';
Optronics.Si_lambda = [302.659 305.959 309.26 312.562 315.865 319.168 322.473 325.778 329.085 332.392 335.7 339.009 342.318 345.629 348.94 352.252 355.565 358.879 362.194 365.509 368.825 372.142 375.459 378.777 382.096 385.416 388.736 392.057 395.378 398.701 402.024 405.347 408.671 411.996 415.321 418.647 421.974 425.301 428.629 431.957 435.286 438.615 441.945 445.275 448.606 451.937 455.269 458.601 461.934 465.267 468.601 471.935 475.269 478.604 481.939 485.275 488.611 491.947 495.283 498.62 501.958 505.295 508.633 511.972 515.31 518.649 521.988 525.328 528.667 532.007 535.347 538.687 542.028 545.368 548.709 552.05 555.391 558.733 562.074 565.416 568.758 572.099 575.441 578.783 582.125 585.468 588.81 592.152 595.494 598.837 602.179 605.521 608.864 612.206 615.548 618.891 622.233 625.575 628.917 632.259 635.601 638.943 642.285 645.626 648.968 652.309 655.65 658.991 662.332 665.673 669.013 672.354 675.694 679.033 682.373 685.712 689.051 692.39 695.729 699.067 702.405 705.743 709.08 712.417 715.754 719.09 722.426 725.761 729.097 732.431 735.766 739.1 742.433 745.766 749.099 752.431 755.763 759.094 762.425 765.755 769.085 772.414 775.743 779.071 782.399 785.726 789.053 792.378 795.704 799.029 802.353 805.676 808.999 812.321 815.643 818.964 822.284 825.604 828.922 832.241 835.558 838.875 842.191 845.506 848.82 852.134 855.447 858.759 862.07 865.381 868.691 871.999 875.307 878.615 881.921 885.226 888.531 891.834 895.137 898.439 901.74 905.04 908.339 911.637 914.934 918.23 921.525 924.819 928.112 931.404 934.696 937.986 941.274 944.562 947.849 951.135 954.42 957.703 960.986 964.267 967.547 970.826 974.104 977.381 980.656 983.93 987.204 990.475 993.746 997.016 1000.28 1003.55 1006.82 1010.08 1013.34 1016.61 1019.87 1023.13 1026.38 1029.64 1032.9 1036.15 1039.4 1042.65 1045.9 1049.15 1052.4 1055.64 1058.89 1062.13 1065.37 1068.61 1071.85 1075.09 1078.32 1081.56 1084.79 1088.02 1091.25 1094.48 1097.7 1100.93 1104.15 1107.37 1110.59 1113.81 1117.03 1120.24 1123.45 1126.67 1129.88 1133.08 1136.29 1139.5 1142.7 1145.9]';
Optronics.In_lambda = [900.51 906.944 913.363 919.767 926.156 932.53 938.889 945.233 951.562 957.876 964.176 970.46 976.731 982.987 989.228 995.455 1001.67 1007.87 1014.05 1020.22 1026.38 1032.52 1038.65 1044.76 1050.87 1056.95 1063.03 1069.09 1075.13 1081.17 1087.19 1093.19 1099.19 1105.17 1111.14 1117.09 1123.03 1128.96 1134.88 1140.78 1146.67 1152.55 1158.41 1164.27 1170.11 1175.94 1181.75 1187.56 1193.35 1199.13 1204.9 1210.65 1216.4 1222.13 1227.85 1233.56 1239.25 1244.94 1250.61 1256.28 1261.93 1267.57 1273.2 1278.82 1284.42 1290.02 1295.6 1301.18 1306.74 1312.29 1317.83 1323.36 1328.88 1334.39 1339.89 1345.38 1350.86 1356.33 1361.79 1367.23 1372.67 1378.1 1383.52 1388.93 1394.32 1399.71 1405.09 1410.46 1415.82 1421.17 1426.51 1431.84 1437.16 1442.47 1447.78 1453.07 1458.36 1463.63 1468.9 1474.16 1479.4 1484.64 1489.88 1495.1 1500.31 1505.52 1510.71 1515.9 1521.08 1526.25 1531.42 1536.57 1541.72 1546.86 1551.99 1557.11 1562.23 1567.33 1572.43 1577.52 1582.61 1587.68 1592.75 1597.81 1602.86 1607.91 1612.95 1617.98 1623 1628.02 1633.03 1638.03 1643.03 1648.01 1653 1657.97 1662.94 1667.9 1672.85 1677.8 1682.74 1687.67 1692.6 1697.52 1702.44 1707.35 1712.25 1717.15 1722.04 1726.92 1731.8 1736.67 1741.53 1746.39 1751.25 1756.1 1760.94 1765.77 1770.61 1775.43 1780.25 1785.06 1789.87 1794.68 1799.48 1804.27 1809.06 1813.84 1818.61 1823.39 1828.15 1832.92 1837.67 1842.43 1847.17 1851.92 1856.65 1861.39 1866.12 1870.84 1875.56 1880.27 1884.98 1889.69 1894.39 1899.09 1903.78 1908.47 1913.16 1917.84 1922.52 1927.19 1931.86 1936.52 1941.18 1945.84 1950.49 1955.14 1959.79 1964.43 1969.07 1973.71 1978.34 1982.97 1987.59 1992.21 1996.83 2001.45 2006.06 2010.67 2015.27 2019.88 2024.48 2029.07 2033.67 2038.26 2042.85 2047.43 2052.01 2056.59 2061.17 2065.74 2070.32 2074.89 2079.45 2084.02 2088.58 2093.14 2097.7 2102.25 2106.8 2111.36 2115.9 2120.45 2124.99 2129.54 2134.08 2138.62 2143.15 2147.69 2152.22 2156.75 2161.28 2165.81 2170.34 2174.86 2179.38 2183.91 2188.43 2192.94 2197.46 2201.98 2206.49 2211.01 2215.52 2220.03]';
Optronics.Aper_A.Si_rad = interp1(Optronics.nm,Optronics.Aper_A.rad,Optronics.Si_lambda, 'linear');
Optronics.Aper_B.Si_rad = interp1(Optronics.nm,Optronics.Aper_B.rad,Optronics.Si_lambda, 'linear');
Optronics.Aper_C.Si_rad = interp1(Optronics.nm,Optronics.Aper_C.rad,Optronics.Si_lambda, 'linear');
Optronics.Aper_D.Si_rad = interp1(Optronics.nm,Optronics.Aper_D.rad,Optronics.Si_lambda, 'linear');
Optronics.Aper_A.In_rad = interp1(Optronics.nm,Optronics.Aper_A.rad,Optronics.In_lambda, 'linear');
Optronics.Aper_B.In_rad = interp1(Optronics.nm,Optronics.Aper_B.rad,Optronics.In_lambda, 'linear');
Optronics.Aper_C.In_rad = interp1(Optronics.nm,Optronics.Aper_C.rad,Optronics.In_lambda, 'linear');
Optronics.Aper_D.In_rad = interp1(Optronics.nm,Optronics.Aper_D.rad,Optronics.In_lambda, 'linear');
%%

nm_max = 1040;
% cm_max = nm_max / 1e7;
% T = 0.28978./cm_max;
T = 2843 ;
p_T = planck_in_wl(Optronics.nm./1e9,T); 
cm_max = 0.28978./T;
nm_max = 1e7*cm_max;
nm_ind = round(interp1(Optronics.nm,[1:length(Optronics.nm)],nm_max));
figure;
ax(1) = subplot(2,1,1);
semilogy(Optronics.nm, Optronics.Aper_A.rad, '.r-',Optronics.nm,p_T .* Optronics.Aper_A.rad(nm_ind)./p_T(nm_ind),'g-'); 
title(['T = ',num2str(T)]);
ax(2) = subplot(2,1,2); 
rat = diff(log10(Optronics.Aper_A.rad))-diff(log10(p_T));
r = Optronics.nm> 450 & Optronics.nm < nm_max;
sum_rat = trapz(Optronics.nm(r), abs(rat(r(2:end)))./Optronics.nm(r));
plot(Optronics.nm(2:end),rat , 'k-');
title(['sum ratio = ',sprintf('%2.4e',sum_rat)]);
linkaxes(ax,'x');
xlim([450,nm_max+20]);
%Augment Optronics with matched Planck curve below 450 nm.

%%

Optronics.Aper_A.planck_T = T;
Optronics.Aper_A.Si_rad(1:45) = planck_in_wl(Optronics.Si_lambda(1:45)./1e9,Optronics.Aper_A.planck_T).* Optronics.Aper_A.rad(nm_ind)./p_T(nm_ind);
figure; plot(Optronics.Si_lambda, Optronics.Aper_A.Si_rad,'b.')
% figure; plot(Optronics.nm, Optronics.Aper_A.rad, 'k-',Optronics.Si_lambda, Optronics.Aper_A.Si_rad, 'b.',...
%    Optronics.In_lambda, Optronics.Aper_A.In_rad, 'r.')
%%

lights_A = read_sws_cal_pair;

%%
Optronics.Aper_A.Si_avg_cps = lights_A.avg_Si_per_ms;
Optronics.Aper_A.Si_resp = Optronics.Aper_A.Si_avg_cps ./ Optronics.Aper_A.Si_rad;
Optronics.Aper_A.In_avg_cps = lights_A.avg_In_per_ms;
Optronics.Aper_A.In_resp = Optronics.Aper_A.In_avg_cps ./ Optronics.Aper_A.In_rad;
Optronics.Aper_A.Si_avg_SNR = lights_A.avg_Si_SNR;
Optronics.Aper_A.In_avg_SNR = lights_A.avg_In_SNR;

figure; plot(Optronics.Si_lambda, Optronics.Aper_A.Si_resp, 'b.',...
   Optronics.In_lambda, Optronics.Aper_A.In_resp, 'r.')
title('Responsivity of SWS Si and InGaAs detectors')
xlabel('wavelength')
ylabel(['DN/',Optronics.radiance_units])
%%
%%
lights_B = read_sws_cal_pair;
Optronics.Aper_B.Si_avg_cps = lights_B.avg_Si_per_ms;
Optronics.Aper_B.Si_resp = Optronics.Aper_B.Si_avg_cps ./ Optronics.Aper_B.Si_rad;
Optronics.Aper_B.In_avg_cps = lights_B.avg_In_per_ms;
Optronics.Aper_B.In_resp = Optronics.Aper_B.In_avg_cps ./ Optronics.Aper_B.In_rad;
Optronics.Aper_B.Si_avg_SNR = lights_B.avg_Si_SNR;
Optronics.Aper_B.In_avg_SNR = lights_B.avg_In_SNR;

%%
lights_C = read_sws_cal_pair;
Optronics.Aper_C.Si_avg_cps = lights_C.avg_Si_per_ms;
Optronics.Aper_C.Si_resp = Optronics.Aper_C.Si_avg_cps ./ Optronics.Aper_C.Si_rad;
Optronics.Aper_C.In_avg_cps = lights_C.avg_In_per_ms;
Optronics.Aper_C.In_resp = Optronics.Aper_C.In_avg_cps ./ Optronics.Aper_C.In_rad;
Optronics.Aper_C.Si_avg_SNR = lights_C.avg_Si_SNR;
Optronics.Aper_C.In_avg_SNR = lights_C.avg_In_SNR;

%%
lights_D = read_sws_cal_pair;
Optronics.Aper_D.Si_avg_cps = lights_D.avg_Si_per_ms;
Optronics.Aper_D.Si_resp = Optronics.Aper_D.Si_avg_cps ./ Optronics.Aper_D.Si_rad;
Optronics.Aper_D.In_avg_cps = lights_D.avg_In_per_ms;
Optronics.Aper_D.In_resp = Optronics.Aper_D.In_avg_cps ./ Optronics.Aper_D.In_rad;
Optronics.Aper_D.Si_avg_SNR = lights_D.avg_Si_SNR;
Optronics.Aper_D.In_avg_SNR = lights_D.avg_In_SNR;

%%
save('C:\mlib\sws\Optronics.mat', 'Optronics')

%%
    
     figure; plot(lights.Si_lambda, lights.avg_Si_per_ms, '-');
     title('Si spectra, normalized by integration time')
     xlabel('wavelength (nm)')
     ylabel('(DN - dark)/ms')
     figure; plot(lights.In_lambda, lights.avg_In_per_ms, '-');
          title('InGaAs spectra, normalized by integration time')
     xlabel('wavelength (nm)')
     ylabel('(DN - dark)/ms')
     figure; plot(lights.Si_lambda, lights.avg_Si_SNR, '.b-',...
        lights.In_lambda, lights.avg_In_SNR, '.r-')
     title('signal to noise for Si and InGaAs')
     xlabel('wavelength')
     ylabel('(DN-dark)/sqrt(DN)')

% Read in cal for A on first day;

sws_cal_B1a = read_sws_cal;
%%
sws_cal_B1b = read_sws_cal;
%%
sws_cal_B2 = read_sws_cal;
%%

figure; plot(sws_cal_B2.Si_lambda, (mean(sws_cal_B1a.Si_spec,2)-mean(sws_cal_B2.Si_spec,2))./mean(sws_cal_B2.Si_spec,2), 'g-')

%%
figure; plot(sws_cal_B2.In_lambda, (mean(sws_cal_B1b.In_spec,2)-mean(sws_cal_B2.In_spec,2))./mean(sws_cal_B2.In_spec,2), 'g-')

%%

sws_cal_D1 = read_sws_cal;
%%
sws_cal_D2 = read_sws_cal;
%%

figure; plot(sws_cal_D2.Si_lambda, (mean(sws_cal_D1.Si_spec,2)-mean(sws_cal_D2.Si_spec,2))./mean(sws_cal_D2.Si_spec,2), 'g-')

%%
figure; plot(sws_cal_D2.In_lambda, (mean(sws_cal_D1.In_spec,2)-mean(sws_cal_D2.In_spec,2))./mean(sws_cal_D2.In_spec,2), 'g-')
%%
figure; plot(sws_cal_D2.In_lambda, ((sws_cal_D1.In_dark)-(sws_cal_D2.In_dark))./(sws_cal_D2.In_dark), 'g-')

%%
figure; ax(1) = subplot(2,1,1); semilogy(sws_cal_D2.In_lambda, [mean(sws_cal_D1.In_spec,2),mean(sws_cal_D2.In_spec,2)],'-')
ax(2) = subplot(2,1,2); semilogy(sws_cal_D2.In_lambda, [(sws_cal_D1.In_dark),(sws_cal_D2.In_dark)], '-')
linkaxes(ax,'x');
%%
figure; plot(sws_cal_D2.In_lambda,100*mean(sws_cal_D2.In_spec,2)-sws_cal_D2.In_dark, '.-')
%%

figure; 

ax(1) = subplot(3,1,1); lines = plot(sws_raw.Si_lambda, sws_raw.Si_DN(:,sws_raw.shutter==0), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==0));
ax(2) = subplot(3,1,2); lines = plot(sws_raw.Si_lambda, sws_raw.Si_DN(:,sws_raw.shutter==1), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==1));
ax(3) = subplot(3,1,3); lines = plot(sws_raw.Si_lambda, sws_raw.Si_spec(:,sws_raw.shutter==0), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==0));

%%
figure; 

ax(1) = subplot(3,1,1); lines = plot(sws_raw.In_lambda, sws_raw.In_DN(:,sws_raw.shutter==0), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==0));
ax(2) = subplot(3,1,2); lines = plot(sws_raw.In_lambda, sws_raw.In_DN(:,sws_raw.shutter==1), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==1));
ax(3) = subplot(3,1,3); lines = plot(sws_raw.In_lambda, sws_raw.In_spec(:,sws_raw.shutter==0), '-'); lines = recolor(lines,sws_raw.time(sws_raw.shutter==0));
linkaxes(ax,'x')

%%
figure; plot(...
   Optronics.Si_lambda, Optronics.Aper_A.Si_resp, '.',...
   Optronics.In_lambda, Optronics.Aper_A.In_resp, 'x', ...
   Optronics.Si_lambda, Optronics.Aper_B.Si_resp, '.',...
   Optronics.In_lambda, Optronics.Aper_B.In_resp, 'x', ...
   Optronics.Si_lambda, Optronics.Aper_C.Si_resp, '.',...
   Optronics.In_lambda, Optronics.Aper_C.In_resp, 'x', ...
   Optronics.Si_lambda, Optronics.Aper_D.Si_resp, '.',...
   Optronics.In_lambda, Optronics.Aper_D.In_resp, 'x', ...
old_Si_resp(:,1), old_Si_resp(:,2)./1000,'b-',old_In_resp(:,1), old_In_resp(:,2)./1000, 'r-'); 
title('SWS detector responsivity');
xlabel('wavelength (nm)');
ylabel('W/m^2.µm.sr');
legend('Si new','InGaAs new','Si old','InGaAs old');
%%
figure; plot(...
   lights_A.In_lambda, lights_A.In_dark, '-x', ...
   lights_B.In_lambda, lights_B.In_dark, '-x', ...
   lights_C.In_lambda, lights_C.In_dark, '-x', ...
   lights_D.In_lambda, lights_D.In_dark, '-x'); 
title('SWS InGaAs darks');
xlabel('wavelength (nm)');
ylabel('W/m^2.µm.sr');
legend('A','B','C','D');
%%
figure; plot(...
   Optronics.In_lambda, Optronics.Aper_A.In_resp, '-x', ...
   Optronics.In_lambda, Optronics.Aper_B.In_resp, '-x', ...
   Optronics.In_lambda, Optronics.Aper_C.In_resp, '-x', ...
   Optronics.In_lambda, Optronics.Aper_D.In_resp, '-x'); 
title('SWS detector responsivity');
xlabel('wavelength (nm)');
ylabel('W/m^2.µm.sr');
legend('A','B','C','D');
%%
figure; plot(Optronics.Si_lambda, old_Si_resp(:,2)./(1000*Optronics.Si_resp_B), '-b.',...
   Optronics.In_lambda, old_In_resp(:,2)./(1000*(Optronics.In_resp_B)), '-r.'); 
title('SWS detector responsivity ratio')
xlabel('wavelength (nm)')
ylabel('W/m^2.nm.sr')
legend('Si new','InGaAs new','Si old','InGaAs old')
%%
Optronics.Si_resp_C = lights.avg_Si_per_ms ./ Optronics.Aper_C.Si_rad;
Optronics.In_resp_C = lights.avg_In_per_ms ./ Optronics.Aper_C.In_rad;
%%
Optronics.Si_resp_D = lights.avg_Si_per_ms ./ Optronics.Aper_D.Si_rad;
Optronics.In_resp_D = lights.avg_In_per_ms ./ Optronics.Aper_D.In_rad;

%%
if ~exist('sws', 'var')
   sws = read_sws_raw;
end
%%
shut = sws.shutter==1;
% figure; plot(serial2Hh(sws.time(shut)),sws.Si_DN(100:104,shut),'.-');
figure; 
ax(1) = subplot(2,1,1);
plot(serial2Hh(sws.time(shut)),sws.In_DN(100,shut),'.-');
ax(2) = subplot(2,1,2);
plot(serial2Hh(sws.time), smooth(sws.internal_temp,1),'.')
linkaxes(ax,'x');
%%
In_norm = zeros(size(sws.In_DN));Si_norm = In_norm;
In_norm(:,~shut) = sws.In_DN(:,~shut)./(max(sws.In_DN(:,~shut),[],2)*ones(size(sws.In_DN(1,~shut))));
Si_norm(:,~shut) = sws.Si_DN(:,~shut)./(max(sws.Si_DN(:,~shut),[],2)*ones(size(sws.Si_DN(1,~shut))));
In_norm(:,shut) = sws.In_DN(:,shut)./(max(sws.In_DN(:,shut),[],2)*ones(size(sws.In_DN(1,shut))));
Si_norm(:,shut) = sws.Si_DN(:,shut)./(max(sws.Si_DN(:,shut),[],2)*ones(size(sws.Si_DN(1,shut))));
%%
figure;
ax(1) = subplot(2,1,1);
plot(sws.internal_temp(~shut), Si_norm(50:5:200,~shut),'.');
title('Si detector')
ax(2) = subplot(2,1,2);
plot(sws.internal_temp(~shut), In_norm(50:5:200,~shut),'.');
title('InGaAs detector')
%%
figure; 
ax(1) = subplot(2,1,1);
plot(sws.internal_temp(shut),Si_norm(51:58,shut), '.')
ax(2) = subplot(2,1,2);
plot(sws.internal_temp(shut),In_norm(51:58,shut), '.')
linkaxes(ax,'x')
%%
pp = 0;
%%
pix = pp+[1:7];
ax(1) = subplot(2,1,1);
plot(sws.internal_temp(~shut),In_norm(pix,~shut), '.')
ax(2) = subplot(2,1,2);
plot(sws.internal_temp(shut),In_norm(pix,shut), '.');
leg_str = {};
for p = 1:length(pix)
leg_str = {leg_str{:}, num2str(pix(p))};
end
legend(leg_str)
linkaxes(ax,'x')
pp = pp + 7;

%%
bad_pixels = [35 56 65 65 70 70 75 90 96 99 109 129 129 133 133 137 145 147 147 162 171 187 192 195 207 212 217 228 237 240 247 252 254];
%%
% Now check how to convert the measured SWS spectra (of the integrating
% sphere) from wavelength to wavenumber scales.

% We only need Optroncis and the planck function, I think.

Optronics.wn = 1./(Optronics.nm*1e-7);
%%

figure; plot(Optronics.nm, Optronics.Aper_A.rad,'r',Optronics.nm,1e-12*planck_in_um(Optronics.nm*1e-9,2800),'g')

%%
figure; plot(Optronics.wn, 500*Optronics.Aper_A.rad.*(3e10./Optronics.wn.^2),'r',Optronics.wn,planck_in_wn(Optronics.wn,2800),'g')

%%

wl = [100:100:50000]*1e-9;
wl_cm = wl*100;
wn = [10:50:10000];
subplot(2,1,1); loglog(wl*1e9,1e-7.*planck_in_wl(wl,1000),'g');
ylim([1,1e8]);
title(['B(wl,1000 K)'])
ylabel('W/(m2.sr.um)')
xlabel('wavelength (nm)')
subplot(2,1,2); loglog(wn,(planck_in_wn(wn,1000)),'b');
title(['B(wn,1000 K)'])
ylabel('mW/(m2.sr.cm-1)')
xlabel('wavenumber (1/cm)')

% Okay, so these are in (mW/(m2.ster.cm) and (mW/(m2.ster.cm-1) 
% For comparison with ppt, convert to W/(m2.sr.um) 
% so divide by 1e7 for mW to W. 
% Confirmed, these now match the ppt results.

%%
figure
wl = [300:100:2000]*1e-9;
wl_cm = wl*100;
% wn = [10:50:10000];
wn = 1./wl_cm;
subplot(2,1,1);
loglog(wl*1e9,planck_in_wl(wl,5800),'g',wl*1e9,(wn.^2).*planck_in_wn(wn,5800),'b.');
title(['B(wl,5800 K)'])
ylabel('mW/(m2.sr.cm)')
xlabel('wavelength (nm)')
subplot(2,1,2);
loglog(wn,(planck_in_wn(wn,5800)),'bo',wn,(wl_cm.^2).*planck_in_wl(wl,5800),'g');
title(['B(wn,5800 K)'])
ylabel('mW/(m2.sr.cm-1)')
xlabel('wavenumber (1/cm)')

%%

figure; plot(Optronics.wn, Optronics.Aper_A.rad,'r',Optronics.wn,1e-12*planck_in_um(Optronics.nm*1e-9,2800),'g')
%%
dir_name = 'C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\';
fmask = 'sgpswsC1.resp*.dat';

files = dir([dir_name, fmask]);

%%
clear Si_cal In_cal tmp_time tmp dmp stem
for f = 1:length(files);
   stem = files(f).name;
   [dmp,stem] = strtok(stem,'.');
   [dmp,stem] = strtok(stem,'.');
   [dmp,stem] = strtok(stem,'.');
   tmp_time = datenum(dmp,'yyyymmddHHMM');
   tmp = load([dir_name,files(f).name]);
   if findstr(files(f).name,'.si.')
      if ~exist('Si_cal','var')
         Si_cal.nm = tmp(:,1);
         Si_cal.resp(:,1) = tmp(:,2);
         Si_cal.time(1) = tmp_time;
      else
         [r,c] = size(Si_cal.resp);
         Si_cal.resp(:,c+1) = tmp(:,2);
         Si_cal.time(c+1) = tmp_time;
      end
   else
      if ~exist('In_cal','var')
         In_cal.nm = tmp(:,1);
         In_cal.resp(:,1) = tmp(:,2);
         In_cal.time(1) = tmp_time;
      else
         [r,c] = size(In_cal.resp);
         In_cal.resp(:,c+1) = tmp(:,2);
         In_cal.time(c+1) = tmp_time;
      end
   end
end
Si_cal.norm_time = Si_cal.time(2:end);
Si_cal.normed = Si_cal.resp(:,2:end);
Si_cal.normed = Si_cal.normed ./ (Si_cal.resp(:,1)*ones([1,size(Si_cal.normed,2)]));
In_cal.norm_time = In_cal.time(2:end);
In_cal.normed = In_cal.resp(:,2:end);
In_cal.normed = In_cal.normed ./ (In_cal.resp(:,1)*ones([1,size(In_cal.normed,2)]));

figure; lines = plot(Si_cal.nm, Si_cal.normed,'-',In_cal.nm, In_cal.normed,'-'); lines = recolor(lines, [Si_cal.norm_time, In_cal.norm_time]);
colorbar;title('responsivities');
% figure; lines = plot(In_cal.nm, In_cal.normed,'-'); lines = recolor(lines, [1:length(In_cal.norm_time)]);
% colorbar;title('InGaAs responsivities');

%%
ir_files = dir(['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\sgpswsC1.resp_func.*.ir.*.dat']);

leg = [];
for n_ir = length(ir_files):-1:1
   A = textscan(ir_files(n_ir).name,'%s','delimiter','.');
   ir_resp{n_ir}.tag = [A{1}{5},'_',A{1}{3}];
   tmp = load(['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\',ir_files(n_ir).name]);
   ir_resp{n_ir}.nm = tmp(:,1);
   ir_resp{n_ir}.resp = tmp(:,2);
   leg = [leg;ir_resp{n_ir}.tag];
   ir_time(n_ir) = datenum(A{1}{3},'yyyymmdd');
   ir_time(n_ir) = str2double(A{1}{3});
end
si_files = dir(['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\sgpswsC1.resp_func.*.si.*.dat']);
for n_si = length(si_files):-1:1
   A = textscan(si_files(n_si).name,'%s','delimiter','.');
   si_resp{n_si}.tag = [A{1}{5},'_',A{1}{3}];
   tmp = load(['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\',si_files(n_si).name]);
   si_resp{n_si}.nm = tmp(:,1);
   si_resp{n_si}.resp = tmp(:,2);
   si_time(n_si) = datenum(A{1}{3},'yyyymmdd');
   si_time(n_si) = str2double(A{1}{3});
end
%%
figure; lines = plot(ir_resp{1}.nm, [ir_resp{1}.resp,ir_resp{2}.resp,ir_resp{3}.resp,ir_resp{4}.resp,...
   ir_resp{5}.resp,ir_resp{6}.resp,ir_resp{7}.resp,ir_resp{8}.resp,ir_resp{9}.resp], '-',...
   si_resp{1}.nm,[si_resp{1}.resp, si_resp{2}.resp, si_resp{3}.resp,...
   si_resp{4}.resp,si_resp{5}.resp,si_resp{6}.resp,si_resp{7}.resp],'-');
recolor(lines,[ir_time, si_time]);
colorbar
xlabel('nm');
hold('on');
plot(Optronics.Si_lambda, Optronics.Aper_A.Si_resp, 'b.',...
   Optronics.In_lambda, Optronics.Aper_A.In_resp, 'r.');
hold('off'); zoom('on')