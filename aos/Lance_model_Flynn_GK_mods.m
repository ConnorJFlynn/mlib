%This program uses calibration and data file from Anne to calculate Lance_SS
close all
clear all
clc % clears command window screen


%data = load ('CCN_data_test_ascii.dat');

%data = load ('CCN_data_test_ascii_SAAS_13Nov_2013.dat');

%data = load ('CCN_data_test_ascii_Anne_2009.dat');

data= load('CCN_data_test_ascii_Anne_April2015.dat');

T1_read = data(:,6);
T2_read = data(:,8);
T3_read = data (:,10);
T_inlet = data (:,14);

dT_file = data (:,4);

ss = data (:,2);

dT = 18.153.*ss + 0.9844;

dT_read = T3_read - T1_read;
TG_read = 100.*(1-(dT_read./dT_file));
T3_prime_actual_read = T1_read + dT_read .*(1 + TG_read./100);

dT_prime_actual_read = T3_prime_actual_read - T1_read;

dT_inner = dT_prime_actual_read -(18.153.*0.0 + 0.9844);  %=dTactual - dTo

%==========

Q1 = (0.5.*1000)./60; % flow in cc/sec I'm assuming flow is 0.5 lpm
Q = Q1 * (1e-02).^3; % flow in m3/sec

P = 840 %pressure in mbarr
P = P * 1e2;; % pressure in Pa (N/m2)

B1 = 877;
B2 = 1.3;
B3 = 3.75e-4;
B4 = 1.27e-5;
B5 = 2.24e-5;

% T1 = 23.5 + 273;
% Tc = T1;
% Th = T1 + dT;
% T_prime = (Th + Tc)./2;
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
eta_prime_mean = mean(eta_prime); % Looks like no systematic dependence, so take the mean.
SS_Lance_calc = eta_prime_mean .* (S_lance_prct);