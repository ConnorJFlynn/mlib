%AMICE 1b, second cal set with He and CO2

% We expect to see a double or triple hump in scattering 

ap_neph = rd_in102_raw; % air_neph.time = air_neph.time + 1;
tsi_neph = rd_bnl_tsv4;
figure; plot(tsi_neph.time, [tsi_neph.Blue_T, tsi_neph.Green_T, tsi_neph.Red_T],'o'); legend('TSI B','TST G','TSI R')
dynamicDateTicks
figure; plot(ap_neph.time, [ap_neph.TOTAL_SCATT_BLUE, ap_neph.TOTAL_SCATT_GREEN, ap_neph.TOTAL_SCATT_RED],'o'); legend('AP B','AP G','AP R')
dynamicDateTicks;
linkexes

xl = xlim;
xlim(xl)
xl_He = xl;
ap_He_ = ap_neph.time>xl_He(1) & ap_neph.time<xl_He(2);
tsi_He_ = tsi_neph.time>xl_He(1) & tsi_neph.time<xl_He(2);
ap_He_B = mean(ap_neph.TOTAL_SCATT_BLUE(ap_He_));ap_He_G = mean(ap_neph.TOTAL_SCATT_GREEN(ap_He_));ap_He_R = mean(ap_neph.TOTAL_SCATT_RED(ap_He_));
tsi_He_B = mean(tsi_neph.Blue_T(tsi_He_));tsi_He_G = mean(tsi_neph.Green_T(tsi_He_));tsi_He_R = mean(tsi_neph.Red_T(tsi_He_));

xl_air = xlim;
ap_air_ = ap_neph.time>xl_air(1) & ap_neph.time<xl_air(2);
tsi_air_ = tsi_neph.time>xl_air(1) & tsi_neph.time<xl_air(2);
ap_air_B = mean(ap_neph.TOTAL_SCATT_BLUE(ap_air_));ap_air_G = mean(ap_neph.TOTAL_SCATT_GREEN(ap_air_));ap_air_R = mean(ap_neph.TOTAL_SCATT_RED(ap_air_));
tsi_air_B = mean(tsi_neph.Blue_T(tsi_air_));tsi_air_G = mean(tsi_neph.Green_T(tsi_air_));tsi_air_R = mean(tsi_neph.Red_T(tsi_air_));

xl_CO2 = xlim;
ap_CO2_ = ap_neph.time>xl_CO2(1) & ap_neph.time<xl_CO2(2);
tsi_CO2_ = tsi_neph.time>xl_CO2(1) & tsi_neph.time<xl_CO2(2);
ap_CO2_B = mean(ap_neph.TOTAL_SCATT_BLUE(ap_CO2_));ap_CO2_G = mean(ap_neph.TOTAL_SCATT_GREEN(ap_CO2_));ap_CO2_R = mean(ap_neph.TOTAL_SCATT_RED(ap_CO2_));
tsi_CO2_B = mean(tsi_neph.Blue_T(tsi_CO2_));tsi_CO2_G = mean(tsi_neph.Green_T(tsi_CO2_));tsi_CO2_R = mean(tsi_neph.Red_T(tsi_CO2_));




B_nm = [450, 550, 700];
B_He = [.34, .15, .06]; % Thalman 2014
B_CO2 = [65.54, 28.64, 10.71]; %Sneep & Ubachs 2025
P_He = polyfit(log(B_nm), log(B_He), 1);
P_CO2 = polyfit(log(B_nm), log(B_CO2), 1);

B_air = [27.61, 12.125, 4.549]; %Anderson et al 1996
P_air = polyfit(log(B_nm), log(B_air), 1);
B_co2 = [72.3, 31.7, 11.86];    % Anderson et al 1996

% figure; plot(B_nm, B_co2,'-o', B_nm,B_CO2,'-x'); logy; logx
TSI_He_ref = exp(polyval(P_He, log(B_nm))); TSI_He = 1e6.*[tsi_He_B,tsi_He_G, tsi_He_R];
TSI_air_ref = exp(polyval(P_air, log(B_nm)));TSI_air = 1e6.*[tsi_air_B,tsi_air_G, tsi_air_R];
TSI_CO2_ref = exp(polyval(P_CO2, log(B_nm))); TSI_CO2 = 1e6.*[tsi_CO2_B,tsi_CO2_G, tsi_CO2_R];

AP_He_ref = exp(polyval(P_He, log(ap_neph.nm))); AP_He = [ap_He_B, ap_He_G, ap_He_R];
AP_air_ref = exp(polyval(P_air, log(ap_neph.nm))); AP_air = [ap_air_B, ap_air_G, ap_air_R];
AP_CO2_ref = exp(polyval(P_CO2, log(ap_neph.nm))); AP_CO2 = [ap_CO2_B, ap_CO2_G, ap_CO2_R];

for ii = 3:-1:1
   P_AP(ii,:) = polyfit([AP_He(ii), AP_air(ii), AP_CO2(ii)],[AP_He_ref(ii), AP_air_ref(ii), AP_CO2_ref(ii)],1);
   P_TSI(ii,:)= polyfit([TSI_He(ii), TSI_air(ii), TSI_CO2(ii)],[TSI_He_ref(ii), TSI_air_ref(ii), TSI_CO2_ref(ii)],1);
end

AP_cal.nm = ap_neph.nm';
AP_cal.P = P_AP;

TSI_cal.nm = B_nm';
TSI_cal.P = P_TSI;

save(['C:\case_studies\AMICE\AMICE1b_data\daily_by_start_date\gas_cals\AP_cal.mat'],'-struct','AP_cal');
save(['C:\case_studies\AMICE\AMICE1b_data\daily_by_start_date\gas_cals\TSI_cal.mat'],'-struct','TSI_cal')