close all
clear 

Detector = 'B';
Direction = 'R';
test_dir = getdir('assist_nlc','Select NLC test directory');
Nb_of_Runs = 2;
a_2 = zeros(Nb_of_Runs, 1);
T_ABB = zeros(Nb_of_Runs, 1);
a_2_ = zeros(Nb_of_Runs, 1);

for Run_number = 1:Nb_of_Runs
Run_number

s = xlsread([test_dir,'HBB_' num2str(Run_number) '_ANN.xls']);
T_HBB(Run_number) = 273.15 + mean(s(:, 36));
s = xlsread([test_dir,'ABB_' num2str(Run_number) '_ANN.xls']);
T_ABB(Run_number) = 273.15 + mean(s(:, 41));
T_CBB = 77;

MaxNbScansCalib = -1;
MaxNbScansScene = -1;

fileName = [test_dir,'HBB_' num2str(Run_number) '_' Detector '.igm'];
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

% clear DataHBB ForwardHBB ReverseHBB

fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
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

% clear DataABB ForwardABB ReverseABB

fileName = [test_dir,'LN2_' num2str(Run_number) '_' Detector '.igm'];
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

% clear DataCBB ForwardCBB ReverseCBB
%%

figure
plot(IGM_H.x, abs(IGM_H.y),'.-', IGM_A.x, abs(IGM_A.y),'.-', IGM_C.x, abs(IGM_C.y),'.-')
legend('Hot', 'Ambient', 'LN2');
%%
% figure; 
% sb(1) = subplot(2,1,1);
% plot(ForwardHBB.x,[mean(ForwardHBB.y);mean(ForwardCBB.y);mean(ForwardABB.y)],'-');
% title('forward scans')
% legend('HBB','CBB','ABB')
% sb(2) = subplot(2,1,2);
% plot(ForwardHBB.x,fliplr([mean(ReverseHBB.y);mean(ReverseCBB.y);mean(ReverseABB.y)]),'-');
% title('reverse scans, flipped left-to-right')
% 
% linkaxes(sb,'xy')
% %%
% shifted = circshift(mean(ForwardHBB.y),[0,sft]);
% folded((1:16385-1)) = [shifted(1:16385-1)+fliplr(shifted(16385:end))]./2;
% folded(16385) = shifted(16385);
% folded(16386:32768) = [shifted(16386:end)+fliplr(shifted(1:16383))]./2;
% plot(ForwardHBB.x,shifted,'k',ForwardHBB.x,folded,'r.'); axis(v)
% title(num2str(sft));
% %%
% figure; plot([1:length(folded)],real(fft(fftshift(shifted))),'k',[1:length(folded)],real(fft(fftshift(folded))),'r-')
% title('real');
% legend('circshifted','folded')
% %%
% figure; plot([1:length(folded)],imag(fft(fftshift(shifted))),'k',[1:length(folded)],imag(fft(fftshift(folded))),'r-')
% title('imag');
% legend('circshifted','folded')
% %%
% figure; plot([1:length(folded)],real(fft(fftshift(sheifted))),'k',[1:length(folded)],real(fft(fftshift(folded))),'r-')
% title('real');
% legend('circshifted','folded')
%%
figure; 
spc_h = RawIgm2RawSpc_(IGM_H);
spc_a = RawIgm2RawSpc_(IGM_A);
spc_c = RawIgm2RawSpc_(IGM_C);
% spc_g = RawIgm2GrfSpc(IGM_H.x,);
% sb(1) = subplot(3,1,1);
% plot(spc_h.x,abs([spc_h.y;spc_g.y5;spc_g.y6]),'-');
% title('Abs spectra')
% legend('Hot','Grf_5','Grf_6');
% 
% sb(2) = subplot(3,1,2);
% plot(spc_h.x,real([spc_h.y; spc_g.y5; spc_g.y6]),'-');
% title('real spectra')
% legend('Hot', 'Grf_5','Grf_6');
% sb(3) = subplot(3,1,3);
% plot(spc_h.x,imag([spc_h.y;spc_g.y5;spc_g.y6]),'-');
% title('IMAG spectra')
% legend('Hot', 'Grf_5','Grf_6');
% linkaxes(sb,'xy');
% Grf 6 seems to yield the lowest real residuals in the long-wave end where it
% would matter most.  
%%


%%

% figure; 
% plot([1:length(IGM_H.x)], real(fftshift(fft(fftshift(IGM_H.y, 2), [], 2), 2)),'b-',...
%    [1:length(IGM_H.x)], real(fftshift(fft(zpd2end(IGM_H.y, length(IGM_H.x)./2-1), [], 2), 2)),'r-')
% legend('fftshift','zpd2end')

%%
I_H = IGM_H.y;
[TMP, I] = max(abs(I_H - mean(I_H)));
I_H = I_H(I);
I_A = IGM_A.y;
[TMP, I] = max(abs(I_A - mean(I_A)));
I_A = I_A(I);
I_C = IGM_C.y;
[TMP, I] = max(abs(I_C - mean(I_C)));
I_C = I_C(I);

MF  =0.7;
f_back = 1;

V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);

% V_H = -(1/MF) * (3*(- I_C) + I_H); %= (3I_C - I_H)/MF
% V_A = -(1/MF) * (3*(- I_C) + I_A);%= (3I_C - I_A)/MF
% V_C = -(1/MF) * (3*(- I_C) + I_C); % = (2I_C)/MF ;


IGM_H_O.Header = IGM_H.Header;
IGM_H_O.x = IGM_H.x;
IGM_H_O.y = (IGM_H.y + V_H).^2;
IGM_A_O.Header = IGM_A.Header;
IGM_A_O.x = IGM_A.x;
IGM_A_O.y = (IGM_A.y + V_A).^2;
IGM_C_O.Header = IGM_C.Header;
IGM_C_O.x = IGM_C.x;
IGM_C_O.y = (IGM_C.y + V_C).^2;

SPC_H_O = RawIgm2RawSpc_(IGM_H_O);
SPC_A_O = RawIgm2RawSpc_(IGM_A_O);
SPC_C_O = RawIgm2RawSpc_(IGM_C_O);

% SPC_H_O.y = SPC_H_O.y/length(SPC_H_O.x);
% SPC_A_O.y = SPC_A_O.y/length(SPC_A_O.x);
% SPC_C_O.y = SPC_C_O.y/length(SPC_C_O.x);

Diff_R_fit.x = SPC_H_O.x;
Diff_R_fit.y = (SPC_H_O.y - SPC_A_O.y)./(Blackbody(SPC_H_O.x, T_HBB(Run_number)) - Blackbody(SPC_H_O.x, T_ABB(Run_number)))...
              -(SPC_A_O.y - SPC_C_O.y)./(Blackbody(SPC_H_O.x, T_ABB(Run_number)) - Blackbody(SPC_H_O.x, T_CBB));

% fileName = [test_dir,'HBB_' num2str(Run_number) '_' Detector '.igm'];
% DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
% [ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);
% 
% clear DataHBB
% 
% fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
% DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
% [ForwardABB, ReverseABB] = SplitDirections(DataABB);
% 
 clear DataABB

if Direction == 'F'
    CalSet_HA = CreateCalibrationData(ForwardHBB, T_HBB(Run_number), ForwardABB, T_ABB(Run_number));
else
    CalSet_HA = CreateCalibrationData(ReverseHBB, T_HBB(Run_number), ReverseABB, T_ABB(Run_number));
end
% This is actually responsivity, not gain. CJF
% CalSet_HA.Gain = CalSet_HA.Gain/length(ForwardHBB.x);

% clear ForwardHBB ForwardABB ReverseHBB ReverseABB

% fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
% DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
% [ForwardABB, ReverseABB] = SplitDirections(DataABB);
% 
% % clear DataABB
% 
% fileName = [test_dir,'LN2_' num2str(Run_number) '_' Detector '.igm'];
% DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
% [ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);

% clear DataCBB

if Direction == 'F'
    CalSet_AC = CreateCalibrationData(ForwardCBB, T_CBB, ForwardABB, T_ABB(Run_number));
else
    CalSet_AC = CreateCalibrationData(ReverseCBB, T_CBB, ReverseABB, T_ABB(Run_number));
end
% This is actually responsivity, not gain. CJF
% CalSet_AC.Gain = CalSet_AC.Gain/length(ForwardABB.x);

% clear ForwardCBB ForwardABB ReverseCBB ReverseABB

% In the paper, it is mentioned that the a_2 parameter is chosen such that
% the real part of the gain evaluated using the LN2 and ABB equals the real
% part of the gain evaluated using the HBB and ABB. Therefore, Option 1
% below should be the right way to evaluate a_2. However, we obtain a
% better fit between the model and the evaluation of the difference between
% the gains when we use Option 2.

% Option 1 - Ratio or real parts
a_2_tmp = real(CalSet_HA.Gain - CalSet_AC.Gain) ./ real(Diff_R_fit.y);
% Option 2 - Real part of ratio
a_2_tmp_ = real((CalSet_HA.Gain - CalSet_AC.Gain) ./ Diff_R_fit.y);

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
a_2_(Run_number) = mean(a_2_tmp_(kk));

% V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
% V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
% V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);
nlc_h = (1+2.*a_2(Run_number).*V_H)
nlc_a = (1+2.*a_2(Run_number).*V_A)
nlc_c = (1+2.*a_2(Run_number).*V_C)

diff_gains = CalSet_HA.Gain - CalSet_AC.Gain;

figure
plot(CalSet_AC.x, real(diff_gains), 'b-')
hold on
%plot(CalSet_AC.x, imag(diff_gains), 'g-')
plot(Diff_R_fit.x, real(a_2(Run_number) * Diff_R_fit.y), 'r-', Diff_R_fit.x, real(a_2_(Run_number) * Diff_R_fit.y), 'k-')
%plot(Diff_R_fit.x, imag(a_2(Run_number) * Diff_R_fit.y), 'c-')
xlabel('Wavenumber [cm^{-1}]')
ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
kk = find(Diff_R_fit.x >= range(1) & Diff_R_fit.x <= range(2));
axis([range(1) range(2) 1.2*min([real(diff_gains(kk)) imag(diff_gains(kk)) real(a_2(Run_number) * Diff_R_fit.y(kk)) imag(a_2(Run_number) * Diff_R_fit.y(kk))]) 1.2*max([real(diff_gains(kk)) imag(diff_gains(kk)) real(a_2(Run_number) * Diff_R_fit.y(kk)) imag(a_2(Run_number) * Diff_R_fit.y(kk))])])
title(['Difference between real part of Hot/Ambient and Ambient/LN2 Gains']);
%legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)), sprintf('(2nd) %2.3e',a_2_(Run_number)));

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
