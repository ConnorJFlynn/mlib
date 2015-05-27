% Ok, so idea is to first determine T_offset and eta_prime from a
% calibration data set of dT vs ss along with the calibration flow,
% pressure, and T_bar.

% Then we apply this calibration to the CCN calibration data itself to
% confirm that it yields ss in keeping with the cal.  Then we can apply it
% to the CCNc under different conditions. 

% These numbers from Anne's salt cal 2015/02/05 at NOAA
% CCN T1=23.5 C
% dT, Dc(nm), ss%
salt_cal_ = [4	94	0.164
5	77	0.222
7	59	0.337
9	50	0.436
11	43	0.553
3	125	0.106
3.5	110	0.128
3.75	102	0.145];
salt_cal.dT_outer = salt_cal_(:,1);
salt_cal.Dc_nm = salt_cal_(:,2);
salt_cal.ss = salt_cal_(:,3);

[P_salt, S_salt] = polyfit(salt_cal.dT_outer, salt_cal.ss,1);
ss = P_salt(1).*salt_cal.dT_outer + P_salt(2);
dT_offset = -P_salt(2)./P_salt(1);
[P_salt0, S_salt0] = polyfit(salt_cal.dT_outer-dT_offset, salt_cal.ss,1);

ss_cal = salt_cal.ss./100;
dT = [salt_cal.dT_outer-dT_offset] ; % assume dT = dTouter minus offset

Q1 = (0.5.*1000)./60; % flow in cc/sec I'm assuming flow is 0.5 lpm
Q = Q1 * (1e-02).^3; % flow in m3/sec

P = 840 %pressure in mbarr
P = P * 1e2;; % pressure in Pa (N/m2)

B1 = 877;
B2 = 1.3;
B3 = 3.75e-4;
B4 = 1.27e-5;
B5 = 2.24e-5;

T1 = 23.5 + 273;
Tc = T1;
Th = T1 + dT;
T_prime = (Th + Tc)./2;

dTQP = dT.*Q.*P;
TBBT = (T_prime.*(B3+B4.*T_prime));
C1 = B1.*dTQP;
C2 = (T_prime - B2.*dTQP./TBBT).^2; C1./C2;

C3a = 1./TBBT;
C3b = 1./(B5.*T_prime.^1.94);
C3 = (C3a - C3b);
S_lance = (C1./C2).*(C3);

eta_prime = ss_cal./S_lance;
eta_prime = mean(eta_prime); % Looks like no systematic dependence, so take the mean.
s_calc = eta_prime .* S_lance;
% When used operationally, Th above would be replaced by the T_reading,
% adjusted for TG and then with offset subtracted.


ccn_1col = ARM_nc_display;

T1_set = ccn_1col.vdata.T_set_TEC1;
T2_set = ccn_1col.vdata.T_set_TEC2;
T3_set = ccn_1col.vdata.T_set_TEC3;

delta_T = 2.*(T2_set - T1_set);
delta_T_set = delta_T *(1-TG);
T3_set = T1_set + delta_T_set;



delta_T_set = (T3_set - T1_set);
TG = 1 - (delta_T_set/delta_T);



T1_read = ccn_1col.vdata.T_read_TEC1;
T2_read = ccn_1col.vdata.T_read_TEC2;
T3_read = ccn_1col.vdata.T_read_TEC3;

dT13_set_rep = ccn_1col.vdata.T_set_gradient;
dT = dT13_set_rep./(1-.07);
dT13_set_read = T3_set - T1_set;
dT13_reported = ccn_1col.vdata.T_read_gradient;
dT13_read = T3_read - T1_read;

dT_int = 2.*(T2_set-T1_set);
dT12_read = T2_read - T1_read;

doys = serial2doys(ccn_1col.time);

figure; 
ax(1) = subplot(2,1,1);
plot(doys, (0.5.*dT13_set_rep), 'bo',doys, (T2_set-T1_set), 'rx'); 
ax(2) = subplot(2,1,2);
plot(doys, ccn_1col.vdata.T_OPC,'go');
linkaxes(ax,'x');

figure; 
plot(doys, (0.5.*dT13_set_rep)./(T2_set-T1_set), 'g+',doys, (dT13_set_rep)./(T3_set-T1_set), 'bo'); legend('ratio dT/d(T2set-T1set)', 'ratio dT/d(T3set-T1set)')


% Sorting out the issue with %TG in CCN 
% To account for closer distance between T2 and T3 measurements compared to
% distance between T1 and T2, the TEC3 is actually adjusted a little bit shy of the full desired dT.

%in the CCN manual, the value dT is a hypothetical value for the full
%column length. According to the manual:
% T3_set = T1_set + dT * (1-%TG/100)
% T3_set = T1_set = dT * (1-%TG/100)

figure; plot(serial2doys(ccn_1col.time), ccn_1col.vdata.reported_temperature_gradient, 'o');
title('dT_set by DMT')

figure; plot(serial2doys(ccn_1col.time), ccn_1col.vdata.T_set_TEC3-ccn_1col.vdata.T_set_TEC1, 'o')
tl = title('T3_set - T1_set');set(tl,'interp','none')

figure; plot(serial2doys(ccn_1col.time), 2.*(ccn_1col.vdata.T_set_TEC2-ccn_1col.vdata.T_set_TEC1), 'ro',...
   serial2doys(ccn_1col.time), 2.*(ccn_1col.vdata.T_read_TEC2-ccn_1col.vdata.T_read_TEC1), 'k.',...
   serial2doys(ccn_1col.time), ccn_1col.vdata.T_set_gradient, 'bo',...
   serial2doys(ccn_1col.time), ccn_1col.vdata.T_read_gradient, 'g+',...
   serial2doys(ccn_1col.time), ccn_1col.vdata.T_set_TEC3-ccn_1col.vdata.T_set_TEC1, 'm+')
legend('2x(T2set-T1set)','2x(T2read-T1read)','dTset', 'T3read-T1red','T3set-T1set')
tl = title('2 x (T2_set - T1_set)');set(tl,'interp','none')% 
% I had thought that we wouldn't see 
