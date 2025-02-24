function tsi = tsi_cal(tsi)
%Apply gas cals to TSI nephelometer and output corrected values with air subtracted.

% Neph total scattering field... tsi_neph.Blue_T*1e6

B_nm = [450, 550, 700];
B_air = [27.61, 12.125, 4.549]; %Anderson et al 1996
P_air = polyfit(log(B_nm), log(B_air), 1); 
Bs_air = exp(polyval(P_air, log(B_nm)));
cal_path = getnamedpath('gas_cal');
cal = load([cal_path, 'TSI_cal.mat']);
tsi.Bs_B = polyval(cal.P(1,:), 1e6.*tsi.Blue_T)-Bs_air(1);
tsi.Bs_G = polyval(cal.P(2,:), 1e6.*tsi.Green_T)-Bs_air(2);
tsi.Bs_R = polyval(cal.P(3,:), 1e6.*tsi.Red_T)-Bs_air(3);
tsi.Bbs_B = polyval(cal.P(1,:), 1e6.*tsi.Blue_B)-Bs_air(1);
tsi.Bbs_G = polyval(cal.P(2,:), 1e6.*tsi.Green_B)-Bs_air(2);
tsi.Bbs_R = polyval(cal.P(3,:), 1e6.*tsi.Red_B)-Bs_air(3);
% figure; plot(ap.time, [ap.TOTAL_SCATT_BLUE, ap.TOTAL_SCATT_GREEN, ap.TOTAL_SCATT_RED],'x',...
%    ap.time, [ap.Bs_B, ap.Bs_G, ap.Bs_R],'o');

return

% Blue_T: [1880×1 double]
% Green_T: [1880×1 double]
% Red_T: [1880×1 double]
% Blue_B: [1880×1 double]
% Green_B: [1880×1 double]
% Red_B: [1880×1 double]