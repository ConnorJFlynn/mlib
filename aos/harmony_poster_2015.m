% % load cpc and cpcf data from Aug - Oct 2014 since it is likely to be good.
% 
% cpc = ARM_nc_display;
% cpcf = ARM_nc_display;
% 
% cpcf_dn = anc_downsample_nomiss(cpcf,10); % downsample cpcf 
% 
% % screen for qc_impacts ==0, then look at 1:1
% 
% cpc_qci = anc_qc_impacts(cpc.vdata.qc_concentration, cpc.vatts.qc_concentration);
% cpcf_dn_qci = anc_qc_impacts(cpcf_dn.vdata.qc_concentration, cpcf_dn.vatts.qc_concentration);
% 
% cpc_good = anc_sift(cpc, cpc_qci==0);
% cpcf_good = anc_sift(cpcf_dn, cpcf_dn_qci==0);
% 
% [ainb, bina] = nearest(cpc_good.time, cpcf_good.time);
% 
% cpc_both = anc_sift(cpc_good, ainb);
% cpcf_both = anc_sift(cpcf_good, bina);
% 
% figure; plot(serial2doys(cpcf_both.time), cpcf_both.vdata.concentration,'b.',serial2doys(cpc_both.time), cpc_both.vdata.concentration, 'g.')
% 
% xl = xlim;
% xl_ = serial2doys(cpc_both.time)>=xl(1) & serial2doys(cpc_both.time)<=xl(2);
% 
% maxd = max([max(cpc_both.vdata.concentration(xl_)), max(cpcf_both.vdata.concentration(xl_))]);
% [P,S] = polyfit(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_),1);
% [P_,S_] = polyfit(cpcf_both.vdata.concentration(xl_),cpc_both.vdata.concentration(xl_),1);
% % P_bar = (P + 1./P_)./2;
% P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
% stats = fit_stat(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_),P_bar,S);
% 
% figure; plot(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_), '.', ...
%    [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
% 
% title(['Aerosol Number Density']);
% xlabel('M1 CN  [1/cm^3]'); ylabel('S1 CN  [1/cm^3]');
% txt = {['N pts= ', num2str(stats.N)],...
%    ['slope = ',sprintf('%1.3f',P_bar(1))]};
% 
% xlabel('CPC M1 N/cc'); ylabel('CPCf S1 N/cc');
% txt = {['N pts= ', num2str(stats.N)],...
%    ['slope = ',sprintf('%1.3f',P_bar(1))], ...
%     ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
%     ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
%     ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
%     ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
% gt = gtext(txt); set(gt,'backgroundColor','w');
% 
% 
% %%
% cpc = ARM_nc_display;
% cpcf = ARM_nc_display;
% 
% cpcf_dn = anc_downsample_nomiss(cpcf,10); % downsample cpcf 
% 
% % screen for qc_impacts ==0, then look at 1:1
% 
% cpc_qci = anc_qc_impacts(cpc.vdata.qc_concentration, cpc.vatts.qc_concentration);
% cpcf_dn_qci = anc_qc_impacts(cpcf_dn.vdata.qc_concentration, cpcf_dn.vatts.qc_concentration);
% 
% cpc_good = anc_sift(cpc, cpc_qci==0);
% cpcf_good = anc_sift(cpcf_dn, cpcf_dn_qci==0);
% 
% [ainb, bina] = nearest(cpc_good.time, cpcf_good.time);
% 
% cpc_both = anc_sift(cpc_good, ainb);
% cpcf_both = anc_sift(cpcf_good, bina);
% 
% figure; plot(serial2doys(cpcf_both.time), cpcf_both.vdata.concentration,'b.',serial2doys(cpc_both.time), cpc_both.vdata.concentration, 'g.')
% 
% xl = xlim;
% xl_ = serial2doys(cpc_both.time)>=xl(1) & serial2doys(cpc_both.time)<=xl(2);
% 
% maxd = max([max(cpc_both.vdata.concentration(xl_)), max(cpcf_both.vdata.concentration(xl_))]);
% [P,S] = polyfit(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_),1);
% [P_,S_] = polyfit(cpcf_both.vdata.concentration(xl_),cpc_both.vdata.concentration(xl_),1);
% P_bar = (P + 1./P_)./2;
% stats = fit_stat(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_),P_bar,S);
% 
% figure; plot(cpc_both.vdata.concentration(xl_), cpcf_both.vdata.concentration(xl_), '.', ...
%    [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
% 
% xlabel('CPC M1 N/cc'); ylabel('CPCf S1 N/cc');
% txt = {['N pts= ', num2str(stats.N)],...
%    ['slope = ',sprintf('%1.3f',P_bar(1))], ...
%     ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
%     ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
%     ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
%     ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
% gt = gtext(txt); set(gt,'backgroundColor','w');
% 
% % Now, get impactor M1, S1, and Neph M1, S1
nephS1 = anc_bundle_files;
nephM1 = anc_bundle_files;

M1_qci = anc_qc_impacts(nephM1.vdata.Bs_G, nephM1.vatts.qc_Bs_G);


M1_good = anc_sift(nephM1, nephM1.vdata.qc_Bs_G==0);
[M1_good_1um, M1_good_10um] = anc_sift(M1_good,M1_good.vdata.impactor_state==1);
M1_good_10um = anc_sift(M1_good_10um,M1_good_10um.vdata.impactor_state==10);

S1_good = anc_sift(nephS1, nephS1.vdata.qc_Bs_G_Dry_Neph3W==0);
[S1_good_1um, S1_good_10um] = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
S1_good_10um = anc_sift(S1_good_10um,S1_good_10um.vdata.impactor_state==10);

[ainb, bina] = nearest(M1_good_1um.time, S1_good_1um.time);
M1_both_1um = anc_sift(M1_good_1um, ainb);
S1_both_1um = anc_sift(S1_good_1um, bina);

[ainb, bina] = nearest(M1_good_10um.time, S1_good_10um.time);
M1_both_10um = anc_sift(M1_good_10um, ainb);
S1_both_10um = anc_sift(S1_good_10um, bina);


figure; 
ax(1) = subplot(2,1,1);
plot(serial2doys(M1_good.time(M1_good.vdata.impactor_state==1)), M1_good.vdata.Bs_G_Dry_Neph3W(M1_good.vdata.impactor_state==1),'b.',...
serial2doys(S1_good.time(S1_good.vdata.impactor_state==1)), S1_good.vdata.Bs_G_Dry_Neph3W(S1_good.vdata.impactor_state==1), 'g.'); 
legend('M1 1um','S1 1um');
ax(2) = subplot(2,1,2);
plot(serial2doys(M1_good.time(M1_good.vdata.impactor_state==10)), M1_good.vdata.Bs_G_Dry_Neph3W(M1_good.vdata.impactor_state==10),'b.',...
serial2doys(S1_good.time(S1_good.vdata.impactor_state==10)), S1_good.vdata.Bs_G_Dry_Neph3W(S1_good.vdata.impactor_state==10), 'g.'); 
legend('M1 10um','S1 10um');
linkaxes(ax,'xy')

xl = xlim;
% First the 10 um cut
xl_ = serial2doys(M1_both_10um.time)>=xl(1) & serial2doys(M1_both_10um.time)<=xl(2);

maxd = max([max(M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_)), max(S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_))]);
% [P,S] = polyfit(M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_),1);
% [P_,S_] = polyfit(S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_),M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_),1);
% P_bar = (P + 1./P_)./2;
% stats = fit_stat(M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_),P_bar,S);

[P_bar,stats] = bifit(M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_));
figure; plot(M1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_10um.vdata.Bs_G_Dry_Neph3W(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);

xlabel('M1 B_s_p Green 10 um size cut [1/Mm]'); ylabel('S1 B_s_p Green 10 um size cut[1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
    ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt); set(gt,'backgroundColor','w');

% Now the 1 um cut
xl_ = serial2doys(M1_both_1um.time)>=xl(1) & serial2doys(M1_both_1um.time)<=xl(2);

maxd = max([max(M1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_)), max(S1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_))]);
[P_bar,stats] = bifit(M1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_));
figure; plot(M1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_), S1_both_1um.vdata.Bs_G_Dry_Neph3W(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);

xlabel('M1 B_s_p Green 1 um size cut [1/Mm]'); ylabel('S1 B_s_p Green 1 um size cut[1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
    ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt); set(gt,'backgroundColor','w');

%% Now PSAP M1 and S1
xl = xlim;
% First the 10 um cut
xl_ = serial2doys(M1_both_10um.time)>=xl(1) & serial2doys(M1_both_10um.time)<=xl(2);

maxd = max([max(M1_both_10um.vdata.Ba_G_combined(xl_)), max(S1_both_10um.vdata.Ba_G_combined(xl_))]);
[P_bar, stats] = bifit(M1_both_10um.vdata.Ba_G_combined(xl_), S1_both_10um.vdata.Ba_G_combined(xl_));

figure; plot(M1_both_10um.vdata.Ba_G_combined(xl_), S1_both_10um.vdata.Ba_G_combined(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);

xlabel('M1 B_a_p Green 10 um size cut [1/Mm]'); ylabel('S1 B_a_p Green 10 um size cut[1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
    ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt); set(gt,'backgroundColor','w');

% Now the 1 um cut
xl_ = serial2doys(M1_both_1um.time)>=xl(1) & serial2doys(M1_both_1um.time)<=xl(2);

maxd = max([max(M1_both_1um.vdata.Ba_G_combined(xl_)), max(S1_both_1um.vdata.Ba_G_combined(xl_))]);
[P_bar, stats] = bifit(M1_both_1um.vdata.Ba_G_combined(xl_), S1_both_1um.vdata.Ba_G_combined(xl_));

figure; plot(M1_both_1um.vdata.Ba_G_combined(xl_), S1_both_1um.vdata.Ba_G_combined(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);

xlabel('M1 B_a_p Green 1 um size cut [1/Mm]'); ylabel('S1 B_a_p Green 1 um size cut[1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1f',stats.bias)], ...
    ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt); set(gt,'backgroundColor','w');

%%
psapr = anc_bundle_files(getfullname('*.nc','psapr','Select psap r file'));
psapa1 = anc_bundle_files(getfullname('*.nc','psapa','Select psap a1 file'));
psapb1 = anc_bundle_files(getfullname('*.nc','psapb','Select psap b1 file'));
S1 = psapb1;

psapb1M = anc_bundle_files(getfullname('*.*','psapb1','Select psap b1'));

psapr_vatts = psapr.vatts;
tim = psapr.time;
psapr = psapr.vdata;
psapr.time = tim;

tim = psapa1.time;
psapa1_vatts = psapa1.vatts;
psapa1 = psapa1.vdata;
psapa1.time = tim;

tim = psapb1.time;
psapb1_vatts = psapb1.vatts;
psapb1 = psapb1.vdata;
psapb1.time = tim;
Tr_blue = double(psapr.blue_signal_sum - psapr.dark_signal_sum)./ ...
   double(psapr.blue_reference_sum - psapr.dark_reference_sum);
% figure; plot(serial2hs(psapb1.time(2:end)), psapb1.absorbance_blue(2:end)+diff(log(Tr_blue)), 'ko')
% 
Tr_green = double(psapr.green_signal_sum - psapr.dark_signal_sum)./ ...
   double(psapr.green_reference_sum - psapr.dark_reference_sum);
% figure; plot(serial2hs(psapb1.time(2:end)), psapb1.absorbance_green(2:end)+diff(log(Tr_green)), 'g.')
% 
Tr_red = double(psapr.red_signal_sum - psapr.dark_signal_sum)./ ...
   double(psapr.red_reference_sum - psapr.dark_reference_sum);
% figure; plot(serial2hs(psapb1.time(2:end)), psapb1.absorbance_red(2:end)+diff(log(Tr_red)), 'r.')


% = (-K1 + (K1^2 - 4*(K0-mV)*K2)^0.5)/(2*K2) 
K0 = 923.6; K1 = 752.9; K2 = 38.2;
sample_flow = (-K1 + (K1.^2 - 4.*(K0-double(psapr.mass_flow_output)).*K2).^0.5)./(2.*K2) ;
figure; plot(serial2hs(psapb1.time), psapb1.sample_flow_rate,'o',serial2hs(psapb1.time), sample_flow,'r.')
%%            = (-K1 + (part1 - part2).^0.5)./(2.*K2) ;
T = 2;
dt = diffN(psapb1.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flow)./(60.*17.81); % mm per second
dL = dL ./ (1000); %m / sec;
dL = dL.*dt;
Bap_G = diffN(-log(Tr_green),60)./dL; %smoothed over 1 minute
k1=1.317; ko=0.866; 
Bap_G__ = zeros(size(Bap_G));
N = 3;
for ii = 2:(length(Bap_G)-N)
   Bap_G__(1+ii) = (Tr_green(ii)-Tr_green(ii+N))./(dL(ii).*N);
end
figure; plot(serial2hs(psapb1.time), Bap_G__, 'k.', serial2hs(psapb1.time), Bap_G_, 'r.');axis(v);
%now for M1 PSAP
kfM = 1./(k1.*psapb1M.vdata.transmittance_green + ko);
sample_flowM = psapb1M.vdata.sample_flow_rate ; %liter/min
T = 2;
dt = diffN(psapb1M.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flowM)./(60.*17.81); % mm/sec
dL = dL ./ (1000); %m per 60-sec average
dL = dL.*dt;
boM = psapb1M.vdata.absorbance_green./dL;


figure; plot(serial2hs(psapb1.time), kf.*Bap_G*1e6,'r.', serial2hs(psapb1M.time), 1e6.*boM.*kfM,'kx' );
legend('S1 derived','M1 derived');

V = datevec(psapb1.time)';V(7,:) = kf.*Bap_G*1e6;
fid = fopen([srs.pname,'maoaospsap.flynn.csv'],'w');
fprintf(fid,'year, month, day, hour, minute, seconds, Abs_Green \n');
fprintf(fid,'%d, %d, %d, %d, %d, %3.3f, %3.3e \n', V);
fclose(fid);

%% 
S1.vdata.Bap_G = kf.*Bap_G*1e6;
S1.vatts.Bap_G = S1.vatts.absorbance_green;
S1.ncdef.vars.Bap_G = S1.ncdef.vars.absorbance_green;
S1 = anc_check(S1);

psapb1M.vdata.Bap_G = 1e6.*boM.*kfM;
psapb1M.vatts.Bap_G = psapb1M.vatts.absorbance_green;
psapb1M.ncdef.vars.Bap_G = psapb1M.ncdef.vars.absorbance_green;
psapb1M = anc_check(psapb1M);

% Now separate them by size cut and look at fits.
M1_good = anc_sift(psapb1M, psapb1M.vdata.Bap_G>0&psapb1M.vdata.Bap_G<15);
[M1_good_1um, M1_good_10um] = anc_sift(M1_good,M1_good.vdata.impactor_state==1);
M1_good_10um = anc_sift(M1_good_10um,M1_good_10um.vdata.impactor_state==10);

S1_good = anc_sift(S1, S1.vdata.Bap_G>0&S1.vdata.Bap_G<15);
[S1_good_1um, S1_good_10um] = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
S1_good_10um = anc_sift(S1_good_10um,S1_good_10um.vdata.impactor_state==10);

[ainb, bina] = nearest(M1_good_1um.time, S1_good_1um.time);
M1_both_1um = anc_sift(M1_good_1um, ainb);
S1_both_1um = anc_sift(S1_good_1um, bina);

[ainb, bina] = nearest(M1_good_10um.time, S1_good_10um.time);
M1_both_10um = anc_sift(M1_good_10um, ainb);
S1_both_10um = anc_sift(S1_good_10um, bina);

figure; 
ax(1) = subplot(2,1,1);
plot(serial2doys(M1_both_1um.time), M1_both_1um.vdata.Bap_G,'b.',...
serial2doys(S1_both_1um.time), S1_both_1um.vdata.Bap_G, 'g.'); 
legend('M1 1um','S1 1um');
ax(2) = subplot(2,1,2);
plot(serial2doys(M1_both_10um.time), M1_both_10um.vdata.Bap_G,'b.',...
serial2doys(S1_both_10um.time), S1_both_10um.vdata.Bap_G, 'g.'); 
legend('M1 10um','S1 10um');
linkaxes(ax,'xy')

xl = xlim;
% First the 10 um cut
xl_ = serial2doys(M1_both_10um.time)>=xl(1) & serial2doys(M1_both_10um.time)<=xl(2);
S1_dcf = mean(S1_both_10um.vdata.dilution_correction_factor(xl_));
M1_dcf = mean(M1_both_10um.vdata.dilution_correction_factor(xl_));

maxd = max([M1_dcf.*max(M1_both_10um.vdata.Bap_G(xl_)), S1_dcf.*max(S1_both_10um.vdata.Bap_G(xl_))]);
[P,S] = polyfit(M1_dcf.*M1_both_10um.vdata.Bap_G(xl_), S1_dcf.*S1_both_10um.vdata.Bap_G(xl_),1);
[P_,S_] = polyfit(S1_dcf.*S1_both_10um.vdata.Bap_G(xl_),M1_dcf.*M1_both_10um.vdata.Bap_G(xl_),1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
stats = fit_stat(M1_dcf.*M1_both_10um.vdata.Bap_G(xl_), S1_dcf.*S1_both_10um.vdata.Bap_G(xl_),P_bar,S);

figure; plot(M1_dcf.*M1_both_10um.vdata.Bap_G(xl_), S1_dcf.*S1_both_10um.vdata.Bap_G(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);

xlabel('M1 B_a_p Green 10 um size cut [1/Mm]'); ylabel('S1 B_a_p Green 10 um size cut[1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.2f',stats.bias)], ...
    ['Y\_int = ', sprintf('%0.02g',P_bar(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt); set(gt,'backgroundColor','w');

%% Now get SRS data:
% save([srs.pname,srs.fname,'.mat'],'-struct','srs');
srs = load(['D:\case_studies\aos\harmony_summary\data\Springston 14-02 PSAP MAOS A\maomaosas1.psap.01s.00.20140201.000000.m02.tsv.mat']);
% srs = rd_bnl_tsv3;
srs_xl =srs.time>datenum(2014,2,7) & srs.time<datenum(2014,2,8);
figure; srs_h = plot(serial2hs(srs.time(srs_xl))-1/60, srs.GreenAbs(srs_xl),'.');
set(srs_h,'markerEdgeColor',[0,.5,0]);
% Now the 1 um cut
xl_ = serial2doys(M1_both_1um.time)>=xl(1) & serial2doys(M1_both_1um.time)<=xl(2);

maxd = max([M1_dcf.*max(M1_both_1um.vdata.Bap_G(xl_)), max(S1_dcf.*S1_both_1um.vdata.Bap_G(xl_))]);
[P,S] = polyfit(M1_dcf.*M1_both_1um.vdata.Bap_G(xl_), S1_dcf.*S1_both_1um.vdata.Bap_G(xl_),1);
[P_,S_] = polyfit(S1_dcf.*S1_both_1um.vdata.Bap_G(xl_),M1_dcf.*M1_both_1um.vdata.Bap_G(xl_),1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
stats = fit_stat(M1_dcf.*M1_both_1um.vdata.Bap_G(xl_), S1_dcf.*S1_both_1um.vdata.Bap_G(xl_),P_bar,S);

figure; plot(M1_dcf.*M1_both_1um.vdata.Bap_G(xl_), S1_dcf.*S1_both_1um.vdata.Bap_G(xl_), '.', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
title(['Absorption coefficient, Green 1 um size cut']);
xlabel('M1 B_a_p  [1/Mm]'); ylabel('S1 B_a_p  [1/Mm]');
txt = {['N pts= ', num2str(stats.N)],...
   ['slope = ',sprintf('%1.3f',P_bar(1))]};
gt = gtext(txt); set(gt,'backgroundColor','w');
