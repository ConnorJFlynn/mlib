close all
clear all

Detector = 'A';
Direction = 'F';

Nb_of_Runs = 1;
a_2 = zeros(Nb_of_Runs, 1);
T_ABB = zeros(Nb_of_Runs, 1);
a_2 = zeros(Nb_of_Runs, 1);

for Run_number = 1:Nb_of_Runs
Run_number

s = xlsread(['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\HBB_60_' num2str(Run_number) '_ANN.xls']);
T_HBB(Run_number) = 273.15 + mean(s(:, 20));
s = xlsread(['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\ABB_30_' num2str(Run_number) '_ANN.xls']);
T_ABB(Run_number) = 273.15 + mean(s(:, 25));
T_CBB = 77;

MaxNbScansCalib = -1;
MaxNbScansScene = -1;

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\HBB_60_' num2str(Run_number) '_' Detector '.igm'];
DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);
IGM_H.Header = ForwardHBB.Header;
if Direction == 'F'
    IGM_H.x = ForwardHBB.x;
    IGM_H.y = mean(ForwardHBB.y, 1);
else
    IGM_H.x = ReverseHBB.x;
    IGM_H.y = mean(ReverseHBB.y, 1);
end

clear DataHBB ForwardHBB ReverseHBB

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\ABB_30_' num2str(Run_number) '_' Detector '.igm'];
DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardABB, ReverseABB] = SplitDirections(DataABB);
IGM_A.Header = ForwardABB.Header;
if Direction == 'F'
    IGM_A.x = ForwardABB.x;
    IGM_A.y = mean(ForwardABB.y, 1);
else
    IGM_A.x = ReverseABB.x;
    IGM_A.y = mean(ReverseABB.y, 1);
end

clear DataABB ForwardABB ReverseABB

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\LN2_77_' num2str(Run_number) '_' Detector '.igm'];
DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);
IGM_C.Header = ForwardCBB.Header;
if Direction == 'F'
    IGM_C.x = ForwardCBB.x;
    IGM_C.y = mean(ForwardCBB.y, 1);
else
    IGM_C.x = ReverseCBB.x;
    IGM_C.y = mean(ReverseCBB.y, 1);
end

clear DataCBB ForwardCBB ReverseCBB

figure
plot(IGM_H.x, IGM_H.y, IGM_A.x, IGM_A.y, IGM_C.x, IGM_C.y)
legend('Hot', 'Ambient', 'LN2')

I_H = IGM_H.y;
[TMP, I] = max(abs(I_H - mean(I_H)));
I_H = I_H(I);
I_A = IGM_A.y;
[TMP, I] = max(abs(I_A - mean(I_A)));
I_A = I_A(I);
I_C = IGM_C.y;
[TMP, I] = max(abs(I_C - mean(I_C)));
I_C = I_C(I);

I_H
I_C

MF  =0.7;
f_back = 1;

V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);

IGM_H_O.Header = IGM_H.Header;
IGM_H_O.x = IGM_H.x;
IGM_H_O.y = (IGM_H.y + V_H).^2;
IGM_A_O.Header = IGM_A.Header;
IGM_A_O.x = IGM_A.x;
IGM_A_O.y = (IGM_A.y + V_A).^2;
IGM_C_O.Header = IGM_C.Header;
IGM_C_O.x = IGM_C.x;
IGM_C_O.y = (IGM_C.y + V_C).^2;

SPC_H_O = RawIgm2RawSpc(IGM_H_O);
SPC_A_O = RawIgm2RawSpc(IGM_A_O);
SPC_C_O = RawIgm2RawSpc(IGM_C_O);
SPC_H_O.y = SPC_H_O.y/length(SPC_H_O.x);
SPC_A_O.y = SPC_A_O.y/length(SPC_A_O.x);
SPC_C_O.y = SPC_C_O.y/length(SPC_C_O.x);

Diff_R_fit.x = SPC_H_O.x;
Diff_R_fit.y = (SPC_H_O.y - SPC_A_O.y)./(Blackbody(SPC_H_O.x, T_HBB(Run_number)) - Blackbody(SPC_H_O.x, T_ABB(Run_number)))...
              -(SPC_A_O.y - SPC_C_O.y)./(Blackbody(SPC_H_O.x, T_ABB(Run_number)) - Blackbody(SPC_H_O.x, T_CBB));

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\HBB_60_' num2str(Run_number) '_' Detector '.igm'];
DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);

clear DataHBB

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\ABB_30_' num2str(Run_number) '_' Detector '.igm'];
DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardABB, ReverseABB] = SplitDirections(DataABB);

clear DataABB

if Direction == 'F'
    CalSet_HA = CreateCalibrationData(ForwardHBB, T_HBB(Run_number), ForwardABB, T_ABB(Run_number));
else
    CalSet_HA = CreateCalibrationData(ReverseHBB, T_HBB(Run_number), ReverseABB, T_ABB(Run_number));
end
CalSet_HA.Gain = CalSet_HA.Gain/length(ForwardHBB.x);

clear ForwardHBB ForwardABB ReverseHBB ReverseABB

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\ABB_30_' num2str(Run_number) '_' Detector '.igm'];
DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardABB, ReverseABB] = SplitDirections(DataABB);

clear DataABB

fileName = ['Y:\Documents\LR TECH\PNNL\M-ASSIST\Project\T17 (Detector Prod.)\NLC\Run_1\LN2_77_' num2str(Run_number) '_' Detector '.igm'];
DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
[ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);

clear DataCBB

if Direction == 'F'
    CalSet_AC = CreateCalibrationData(ForwardCBB, T_CBB, ForwardABB, T_ABB(Run_number));
else
    CalSet_AC = CreateCalibrationData(ReverseCBB, T_CBB, ReverseABB, T_ABB(Run_number));
end
CalSet_AC.Gain = CalSet_AC.Gain/length(ForwardABB.x);

clear ForwardCBB ForwardABB ReverseCBB ReverseABB

% In the paper, it is mentioned that the a_2 parameter is chosen such that
% the real part of the gain evaluated using the LN2 and ABB equals the real
% part of the gain evaluated using the HBB and ABB. Therefore, Option 1
% below should be the right way to evaluate a_2. However, we obtain a
% better fit between the model and the evaluation of the difference between
% the gains when we use Option 2.

% Option 1 - Ratio or real parts
a_2_tmp = real(CalSet_HA.Gain - CalSet_AC.Gain) ./ real(Diff_R_fit.y);
% Option 2 - Real part of ratio
%a_2_tmp = real((CalSet_HA.Gain - CalSet_AC.Gain) ./ Diff_R_fit.y);



switch upper(Detector)
    case('A')
        range = [200 2000];
        kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
    case('B')
        range = [200 3500];
        kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
    case('C')
        range = [200 5000];
        kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
    otherwise
        range = [200 3000];
        kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
end

a_2(Run_number) = mean(a_2_tmp(kk));

diff_gains = CalSet_HA.Gain - CalSet_AC.Gain;

figure
plot(CalSet_AC.x, real(diff_gains), 'b-')
hold on
%plot(CalSet_AC.x, imag(diff_gains), 'g-')
plot(Diff_R_fit.x, real(a_2(Run_number) * Diff_R_fit.y), 'r-')
%plot(Diff_R_fit.x, imag(a_2(Run_number) * Diff_R_fit.y), 'c-')
xlabel('Wavenumber [cm^{-1}]')
ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
kk = find(Diff_R_fit.x >= range(1) & Diff_R_fit.x <= range(2));
axis([range(1) range(2) 1.2*min([real(diff_gains(kk)) imag(diff_gains(kk)) real(a_2(Run_number) * Diff_R_fit.y(kk)) imag(a_2(Run_number) * Diff_R_fit.y(kk))]) 1.2*max([real(diff_gains(kk)) imag(diff_gains(kk)) real(a_2(Run_number) * Diff_R_fit.y(kk)) imag(a_2(Run_number) * Diff_R_fit.y(kk))])])
title(['Difference between real part of Hot/Ambient and Ambient/LN2 Gains. a_2 = ' num2str(a_2(Run_number))])
%legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
legend('Measured', 'Non-linearity model fit')

%figure
%plot(CalSet_HA.x, 1e-3*abs(CalSet_HA.Gain), 'b-')
%xlabel('Wavenumber [cm^{-1}]')
%ylabel('|R^{HA}| [Counts/(mW/(m^2 sr cm^{-1}))]')
%kk = find(Diff_R_fit.x >= range(1) & Diff_R_fit.x <= range(2));
%axis([range(1) range(2) 0 1.2e-3*max(abs(CalSet_HA.Gain(kk)))])

end

figure
plot(1:Nb_of_Runs, a_2, '*')
xlabel('Run number')
ylabel('Non-linearity correction parameter a_2')

figure
plot(1:Nb_of_Runs, T_ABB, 'r^')
hold on
plot(1:Nb_of_Runs, T_HBB, 'go')
xlabel('Run number')
ylabel('Blackbody temperature [K]')
legend('Ambient', 'Hot')
