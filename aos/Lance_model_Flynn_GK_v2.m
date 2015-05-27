%This program uses ARM data file to calculate Lance_SS

close all
clear all
clc % clears command window screen


ccn_1col = ARM_nc_display;
% For tmp (Finland, BNL/DOE AOS system)

T1_read = ccn_1col.vdata.CCN_t_read_TEC1;
T2_read = ccn_1col.vdata.CCN_t_read_TEC2;
T3_read = ccn_1col.vdata.CCN_t_read_TEC3;

T1_set = ccn_1col.vdata.CCN_t_set_TEC1;
T2_set = ccn_1col.vdata.CCN_t_set_TEC2;
T3_set = ccn_1col.vdata.CCN_t_set_TEC3;

figure; s(1) = subplot(2,1,1);
plot(ccn_1col.time, T1_read, 'r.',ccn_1col.time, T1_set, 'ko'); dynamicDateTicks;
title('T1')
s(2) = subplot(2,1,2); 
plot(ccn_1col.time, T1_read - T1_set, 'bx'); dynamicDateTicks;
title('read - set');
linkaxes(s,'x');

figure; s(1) = subplot(2,1,1);
plot(ccn_1col.time, T2_read, 'r.',ccn_1col.time, T2_set, 'ko'); dynamicDateTicks;
title('T2')
s(2) = subplot(2,1,2); 
plot(ccn_1col.time, T2_read - T2_set, 'bx'); dynamicDateTicks;
title('read - set');
linkaxes(s,'x');

figure; s(1) = subplot(2,1,1);
plot(ccn_1col.time, T3_read, 'r.',ccn_1col.time, T3_set, 'ko'); dynamicDateTicks;
title('T3')
s(2) = subplot(2,1,2); 
plot(ccn_1col.time, T3_read - T3_set, 'bx'); dynamicDateTicks;
title('read - set');
linkaxes(s,'x');

figure; plot(ccn_1col.time, ccn_1col.vdata.CCN_T_sample, '*',ccn_1col.time, T1_read, 'o')
figure; s(1) = subplot(2,1,1);
plot(ccn_1col.time, T3_read - T1_read, 'r.',ccn_1col.time, T3_set - T1_set, 'ko'); dynamicDateTicks;
title('T3 - T1')
s(2) = subplot(2,1,2); 
plot(ccn_1col.time, T3_read - T1_read - (T3_set - T1_set), 'bx'); dynamicDateTicks;
title('T3_read - T1_read - (T3_set - T1_set)');
linkaxes(s,'x');

figure; s(1) = subplot(2,1,1);
plot(ccn_1col.time, T1_read, 'r.',ccn_1col.time, T1_set, 'ko'); dynamicDateTicks;
title('T1')
s(2) = subplot(2,1,2); 
plot(ccn_1col.time, T1_read - T1_set, 'bx'); dynamicDateTicks;
title('read - set');
linkaxes(s,'x');



T_inlet = ccn_1col.vdata.CCN_T_inlet;

dT_file = ccn_1col.vdata.CCN_temperature_gradient;

ss = ccn_1col.vdata.CCN_ss_set;
ss_file = ss;
%======Building calibration equation from data
[P1, P2] = polyfit(dT_file, ss,1)
ss_cal = P1(1).*dT_file + P1(2);
dT_offset_cal = -P1(2)./P1(1);
dT_cal = ss_cal./P1(1) + abs(P1(2))/P1(1) ;
%======

dT_read = T3_read - T1_read;
TG_read = 100.*(1-(dT_read./dT_file));
T3_prime_actual_read = T1_read + dT_read .*(1 + TG_read./100);% temp adjustment

dT_prime_actual_read = T3_prime_actual_read - T1_read;
%dT_prime_actual_read = (T3_prime_actual_read-dT_offset_cal) - T_inlet;
dT_inner = dT_prime_actual_read -((ss_cal./P1(1)).*0.0 + abs(P1(2))/P1(1)); % or use dT_offset_cal %=dTactual - dTo

%==========

Q1 = (0.5.*1000)./60; % flow in cc/sec I'm assuming flow is 0.5 lpm
Q = Q1 * (1e-02).^3; % flow in m3/sec

P = 840 %pressure in mbarr
P = P * 1e2; % pressure in Pa (N/m2)

B1 = 877;
B2 = 1.3;
B3 = 3.75e-4;
B4 = 1.27e-5;
B5 = 2.24e-5;

T_prime = ((dT_prime_actual_read./2)+ T_inlet)+273;

dTQP = dT_inner.*Q.*P;
TBBT = (T_prime.*(B3+B4.*T_prime));
C1 = B1.*dTQP;
C2 = (T_prime - B2.*dTQP./TBBT).^2; C1./C2;

C3a = 1./TBBT;
C3b = 1./(B5.*T_prime.^1.94);
C3 = (C3a - C3b);
S_lance = (C1./C2).*(C3);
S_lance_prct = S_lance.*100;
%==========
eta_prime = ss./(S_lance_prct);
eta_prime_mean = mean(eta_prime); 
SS_Lance_calc = eta_prime_mean .* (S_lance_prct);

figure; plot([1:length(SS_Lance_calc)], S_lance_prct, 'o', [1:length(ss)], ss,'k.');