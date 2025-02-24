function ap = ap_cal(ap)
%Apply gas cals to AP nephelometer and output corrected values with air subtracted.
if ~isfield(ap,'nm');
   ap.nm = [450   530   630];
end
B_nm = [450, 550, 700];
B_air = [27.61, 12.125, 4.549]; %Anderson et al 1996
P_air = polyfit(log(B_nm), log(B_air), 1); 
Bs_air = exp(polyval(P_air, log(ap.nm)));
cal_path = getnamedpath('gas_cal');
cal = load([cal_path, 'AP_cal.mat']);
ap.Bs_B = polyval(cal.P(1,:), ap.TOTAL_SCATT_BLUE)-Bs_air(1);
ap.Bs_G = polyval(cal.P(2,:), ap.TOTAL_SCATT_GREEN)-Bs_air(2);
ap.Bs_R = polyval(cal.P(3,:), ap.TOTAL_SCATT_RED)-Bs_air(3);
ap.Bbs_B = polyval(cal.P(1,:), ap.TOTAL_SCATT_BLUE)-Bs_air(1);
ap.Bbs_G = polyval(cal.P(2,:), ap.TOTAL_SCATT_GREEN)-Bs_air(2);
ap.Bbs_R = polyval(cal.P(3,:), ap.TOTAL_SCATT_RED)-Bs_air(3);

% figure; plot(ap.time, [ap.TOTAL_SCATT_BLUE, ap.TOTAL_SCATT_GREEN, ap.TOTAL_SCATT_RED],'x',...
%    ap.time, [ap.Bs_B, ap.Bs_G, ap.Bs_R],'o');

return