function compute_smoothed_Baps_from_BNL_b1

psapb1 = anc_bundle_files(getfullname('*.nc','psapb','Select psap b1 file'));
% bnl_raw_pname = 'D:\case_studies\aos\harmony_summary\PSAP\Ab\maoaospsap3wS1.00\maoaospsap3wS1.00.20140207\';
% psapr_00 = read_psap3w_bnlr([bnl_raw_pname, 'maoaospsap3wS1.00.20140207.151101.raw.maomaosas1.psap3wR.01s.00.20140207.140000.raw.tsv']);
% springston_path = ['D:\case_studies\aos\harmony_summary\PSAP\Springston 14-02 PSAP MAOS A\'];
% erm = anc_load;
% k1=1.317; ko=0.866;  % Weiss f(tau) = 1/(1.0796 Tr + 0.71),  % Bond1999 includes new factor of 1/1.22
%                      % which yields f(tau) = 1/(1.317 Tr + 0.866)
% kf = 1./(k1.*erm.vdata.transmittance_green + ko);
% figure; plot(serial2hs(erm.time), kf.*erm.vdata.Ba_G, 'rx');
% erm_17 = anc_sift(erm, serial2hs(erm.time)>=17&serial2hs(erm.time)<=18);
% Ba_G_17 = kf(serial2hs(erm.time)>=17&serial2hs(erm.time)<=18).*erm_17.vdata.Ba_G;
% erm_time_s = (erm_17.time-erm_17.time(1)).*24*60.*60;
% [P,sigma] = gaussian_fwhm(erm_time_s, 1800, 30); 
% P_ = fftshift(P);
% P_area = P_ ./ (sigma .* sqrt(2.*pi));
% fft_p_area = fft(P_area);
% fft_Ba = fft(Ba_G_17);
% fft_by_fft = fft_Ba.*fft_p_area;
% Ba_G_ifft = ifft(fft_by_fft);
% figure; plot(serial2hs(erm_17.time), Ba_G_17, 'o',serial2hs(erm_17.time), Ba_G_ifft,'.')
% 
% 
[spring] = rd_bnl_tsv3; 
% % save([springston_path, 'maomaosas1.psap.01s.00.20140201.000000.m02.tsv.mat'],'-struct','spring');
% spring = load([springston_path, 'maomaosas1.psap.01s.00.20140201.000000.m02.tsv.mat']);
% % ss = spring.time>=psapr_00.time(1691)&spring.time<=psapr_00.time(end);
% ss = spring.time>=psapb1.time(1)&spring.time<=psapb1.time(end);
% ss_ii = find(ss);
% [ainb,bina] = nearest(psapb1.time, spring.time(ss));
% psapb1 = anc_sift(psapb1,ainb);
sample_flow = psapb1.vdata.sample_flow_rate./psapb1.vdata.dilution_correction_factor;
% K0 = psapb1.vatts.sample_flow_rate.K0;
% K1 = psapb1.vatts.sample_flow_rate.K1;
% K2 = psapb1.vatts.sample_flow_rate.K2;
% % K0 = 923.6; K1 = 752.8; K2 = 38.2;
% sample_flow = (-K1 + (K1.^2 - 4.*(K0-double(psapr_00.flow_AD)).*K2).^0.5)./(2.*K2) ;
% % figure;  plot(psapb1.time, psapb1.vdata.sample_flow_rate,'o', psapr_00.time, sample_flow, '.');
% % sample_flow = psapb1.vdata.sample_flow_rate;
%  
% Tr_grn = psapr_00.grn_rel./psapr_00.grn_rel(1691);
% Tr_blu = psapr_00.blu_rel./psapr_00.blu_rel(1691);
% Tr_red = psapr_00.red_rel./psapr_00.red_rel(1691);
% figure; plot(psapb1.time, psapb1.vdata.transmittance_red, 'k.', psapr_00.time, Tr_red,'ro');

Tr_grn = psapb1.vdata.transmittance_green;
Tr_blu = psapb1.vdata.transmittance_blue;
Tr_red = psapb1.vdata.transmittance_red;

SS = [1,5,10,15,20,30,45,60];

Bab_1s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(1));
Bab_5s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(2));
Bab_10s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(3));
Bab_15s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(4));
Bab_20s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,20);
Bab_30s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(6));
Bab_45s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(7));
Bab_60s = smooth_Tr_Bab(psapb1.time, sample_flow , Tr_grn,SS(8));

k1=1.317; ko=0.866; 
kf = 1./(k1.*Tr_grn + ko)';

Bab_1s = Bab_1s .*kf;
Bab_5s =Bab_5s .*kf;
Bab_10s =Bab_10s .*kf;
Bab_15s =Bab_15s .*kf;
Bab_20s =Bab_20s .*kf;
Bab_30s =Bab_30s .*kf;
Bab_45s =Bab_45s .*kf;
Bab_60s =Bab_60s .*kf;

figure; plot(psapb1.time, Bab_10s,'.',psapb1.time, Bab_15s,'.',psapb1.time,Bab_20s,'.', ...
   psapb1.time, Bab_30s,'.',psapb1.time, Bab_45s,'.',psapb1.time, Bab_60s,'.'); legend('10s','15s','20s','30s','45s','60s')



t_s = [1, 5, 10, 15, 30, 45, 60];
Bab_s = [Bab_1s, Bab_5s, Bab_10s, Bab_15s, Bab_30s, Bab_45s, Bab_60s];

for ii = 1:length(psapb1.time)
[P, S] = polyfit(t_s(4:end), Bab_s(ii,4:end),2);
Ps(ii).P = P;
Bab_1s_(ii) = polyval(Ps(ii).P,1);
end




% figure; plot((psapb1.time+t_offset), Bab_5s,'b.',(psapb1.time+t_offset), Bab_10s,'r.',...
%    (psapb1.time+t_offset), Bab_15s,'b.',(psapb1.time+t_offset), Bab_60s,'r.',...
%    (spring.time(ss_ii)), spring.GreenAbs(ss_ii),'ko', psapb1.time, Bab_1s_,'y-'); legend('30s','60s','spring');
t_offset = +1./(24*60);
figure; plot(psapb1.time, Bab_1s_, '-y.',psapb1.time, Bab_5s,'.',psapb1.time, Bab_10s,'.',psapb1.time, Bab_15s,'.',...
   psapb1.time, Bab_30s,'.',psapb1.time, Bab_45s,'.',psapb1.time, Bab_60s,'.',...
   spring.time(ss_ii)-t_offset, spring.GreenAbs(ss_ii),'ko'); legend('0s','5s','10s','15s','30s','45s','60s', 'SRS')
dynamicDateTicks; if exist('v','var') axis(v); end
ax(1) = gca;

cpcf = anc_load(['D:\case_studies\aos\harmony_summary\post_asr\maoaoscpcfS1.b1\maoaoscpcfS1.b1.20140207.000000.nc']);
figure; plot(cpcf.time, smooth(cpcf.vdata.concentration,15),'.');dynamicDateTicks
ax(2) = gca;
linkaxes(ax,'x');

maxd = max([max(spring.GreenAbs(ss_ii(ainb))), max(kf_60s(bina).*Bab_grn_60s(bina))]);
bnl_Bab_grn = spring.GreenAbs(ss_ii(ainb));
bnl_Bab_blu = spring.BlueAbs(ss_ii(ainb));
bnl_Bab_red = spring.RedAbs(ss_ii(ainb));
my_Bab_grn = kf_60s(bina).*Bab_grn_60s(bina);
my.time = psapr_00.time(bina)+t_offset;
my.Tr_grn_60s = psapr_00.Tr_grn_60s(bina);
my.Tr_blu_60s = psapr_00.Tr_blu_60s(bina);
my.Tr_red_60s = psapr_00.Tr_red_60s(bina);
my.Tr_grn_15s = psapr_00.Tr_grn_15s(bina);
my.Tr_blu_15s = psapr_00.Tr_blu_15s(bina);
my.Tr_red_15s = psapr_00.Tr_red_15s(bina);
my.sample_flow = sample_flow(bina);
my.dV = dV(bina);
my.dL = dL(bina);
kf_60s = 1./(k1.*psapr_00.Tr_grn_60s + ko);
Bab_corr = kf_60s.*Bab_grn_60s; % Is this right?!
my.Bab_grn_60s = Bab_corr(bina);

kf_60s = 1./(k1.*psapr_00.Tr_blu_60s + ko);
Bab_corr = kf_60s.*Bab_blu_60s; % Is this right?!
my.Bab_blu_60s = Bab_corr(bina);

kf_60s = 1./(k1.*psapr_00.Tr_red_60s + ko);
Bab_corr = kf_60s.*Bab_red_60s; % Is this right?!
my.Bab_red_60s = Bab_corr(bina);

kf_15s = 1./(k1.*psapr_00.Tr_grn_15s + ko);
Bab_corr = kf_15s.*Bab_grn_15s; % Is this right?!
my.Bab_grn_15s = Bab_corr(bina);

kf_15s = 1./(k1.*psapr_00.Tr_blu_15s + ko);
Bab_corr = kf_15s.*Bab_blu_15s; % Is this right?!
my.Bab_blu_15s = Bab_corr(bina);

kf_15s = 1./(k1.*psapr_00.Tr_red_15s + ko);
Bab_corr = kf_15s.*Bab_red_15s; % Is this right?!
my.Bab_red_15s = Bab_corr(bina);



good = ~isNaN(bnl_Bab_grn);
bnl_Bab_grn = bnl_Bab_grn(good);
bnl_Bab_blu = bnl_Bab_blu(good);
bnl_Bab_red = bnl_Bab_red(good);

my.time = my.time(good); 
my.sample_flow = my.sample_flow(good);
my.dV = my.dV(good);
my.dL = my.dL(good);
my.Tr_blu_60s = my.Tr_blu_60s(good);
my.Tr_grn_60s = my.Tr_grn_60s(good);
my.Tr_red_60s = my.Tr_red_60s(good);
my.Bab_blu_60s = my.Bab_blu_60s(good);
my.Bab_grn_60s = my.Bab_grn_60s(good);
my.Bab_red_60s = my.Bab_red_60s(good);
my.Tr_blu_15s = my.Tr_blu_15s(good);
my.Tr_grn_15s = my.Tr_grn_15s(good);
my.Tr_red_15s = my.Tr_red_15s(good);
my.Bab_blu_15s = my.Bab_blu_15s(good);
my.Bab_grn_15s = my.Bab_grn_15s(good);
my.Bab_red_15s = my.Bab_red_15s(good);

sid = fopen([springston_path, 'psap_Babs_60s_smoothing_from_R00.txt'],'w');
fprintf(sid,'%s \t %s \t %s \t %s \t %s \t %s \t %s  \t %s \t %s \t %s \n','yyyy-mm-dd HH:MM:SS',...
   'Tr_blu_15s','Tr_grn_15s','Tr_red_15s','flow_rate','sample_volume','sample length','Babs_blue_15s','Babs_green_15s','Babs_red_15s');
for i = 1:length(my.time)
   row = {datestr(my.time(i),'yyyy-mm-dd HH:MM:SS.fff'), my.Tr_blu_60s(i), my.Tr_grn_60s(i), my.Tr_red_60s(i)};
   row = {row{:},my.sample_flow(i), my.dV(i), my.dL(i)}; 
   row = {row{:},my.Bab_blu_60s(i), my.Bab_grn_60s(i), my.Bab_red_60s(i)}; 
   fprintf(sid,'%s \t %2.9e \t %2.9e \t %2.9e \t %2.4e \t %2.4e \t %2.4e  \t %2.4e \t %2.4e \t %2.4e \n',row{:});
end
fclose(sid);

sid = fopen([springston_path, 'psap_Babs_15s_smoothing_from_R00.txt'],'w');
fprintf(sid,'%s \t %s \t %s \t %s \t %s \t %s \t %s  \t %s \t %s \t %s \n','yyyy-mm-dd HH:MM:SS',...
   'Tr_blu_15s','Tr_grn_15s','Tr_red_15s','flow_rate','sample_volume','sample length','Babs_blue_15s','Babs_green_15s','Babs_red_15s');
for i = 1:length(my.time)
   row = {datestr(my.time(i),'yyyy-mm-dd HH:MM:SS.fff'), my.Tr_blu_15s(i), my.Tr_grn_15s(i), my.Tr_red_15s(i)};
   row = {row{:},my.sample_flow(i), my.dV(i), my.dL(i)}; 
   row = {row{:},my.Bab_blu_15s(i), my.Bab_grn_15s(i), my.Bab_red_15s(i)}; 
   fprintf(sid,'%s \t %2.9e \t %2.9e \t %2.9e \t %2.4e \t %2.4e \t %2.4e  \t %2.4e \t %2.4e \t %2.4e \n',row{:});
end
fclose(sid);

% my.A{1} = 
%     doy1 = serial2doy1(nc.time)';)
%     HHhh = (doy1 - floor(doy1)) *24;
%     txt_out = [yyyy, doy1, HHhh, mm, dd, HH, MM, SS, alive.aod_1(aod_times)', alive.aod_bscat(aod_times)',alive.aod_1(aod_times)'- alive.aod_bscat(aod_times)' ]; 
%         fid = fopen([pname, 'named_output_file.txt'],'wt');
%         fprintf(fid, '%s \n','yyyy, doy1, HHhh, mm, dd, HH, MM, SS, aod_1, aod_bscat, aod_diff');
%         fprintf(fid,'%d, %d, %d, %d, %d, %d, %d, %d, %3.6f, %3.6f, %3.6f \n',txt_out');
%         fclose(fid);
%     close('all'); 


[Pg,Sg] = polyfit(bnl_Bab_grn, my.Bab_grn_60s,1);
[Pg_,Sg_] = polyfit(my.Bab_grn_60s, bnl_Bab_grn,1);
Pg_bar(1) = (Pg(1) + 1./Pg_(1))./2;Pg_bar(2) = (Pg(2) - Pg_(2))./2;
statsg = fit_stat(bnl_Bab_grn, my.Bab_grn_60s,Pg_bar,Sg);

figure; plot(bnl_Bab_grn, my.Bab_grn_60s, 'go', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(Pg_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
title(['Absorption coefficient, Green']);
xlabel('BNL  [1/Mm]'); ylabel('PNL  [1/Mm]');
txt = {['N pts= ', num2str(statsg.N)],...
   ['slope = ',sprintf('%1.4f',Pg_bar(1))]};
gt = gtext(txt); set(gt,'backgroundColor','w');


[Pb,Sb] = polyfit(bnl_Bab_blu, my.Bab_blu_60s,1);
[Pb_,Sb_] = polyfit(my.Bab_blu_60s, bnl_Bab_blu,1);
Pb_bar(1) = (Pb(1) + 1./Pb_(1))./2;Pb_bar(2) = (Pb(2) - Pb_(2))./2;
statsb = fit_stat(bnl_Bab_blu, my.Bab_blu_60s,Pb_bar,Sb);

figure; plot(bnl_Bab_blu, my.Bab_blu_60s, 'bo', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(Pb_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
title(['Absorption coefficient, Blue']);
xlabel('BNL  [1/Mm]'); ylabel('PNL  [1/Mm]');
txt = {['N pts= ', num2str(statsb.N)],...
   ['slope = ',sprintf('%1.4f',Pb_bar(1))]};
gt = gtext(txt); set(gt,'backgroundColor','w');



[Pr,Sr] = polyfit(bnl_Bab_red, my.Bab_red_60s,1);
[Pr_,Sr_] = polyfit(my.Bab_red_60s, bnl_Bab_red,1);
Pr_bar(1) = (Pr(1) + 1./Pr_(1))./2;Pr_bar(2) = (Pr(2) - Pr_(2))./2;
statsr = fit_stat(bnl_Bab_red, my.Bab_red_60s,Pr_bar,Sr);

figure; plot(bnl_Bab_red, my.Bab_red_60s, 'ro', ...
   [0,maxd],[0,maxd],'k--', [0,maxd],polyval(Pr_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
title(['Absorption coefficient, Red']);
xlabel('BNL  [1/Mm]'); ylabel('PNL  [1/Mm]');
txt = {['N pts= ', num2str(statsr.N)],...
   ['slope = ',sprintf('%1.4f',Pr_bar(1))]};
gt = gtext(txt); set(gt,'backgroundColor','w');

% Okay, demonstrated pretty good agreement between my results and SRS



T = 2;
dt = diffN(psapb1.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flow)./(60.*17.81); % mm per second
dL = dL ./ (1000); %m / sec;
dL = dL.*dt;
Bap_G = diffN(-log(Tr_green),60)./dL; %smoothed over 1 minute
k1=1.317; ko=0.866; 
kf = 1./(k1.*psapa1.transmittance_G + ko);
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

% psap_flow = 738.23 * flow_AD 
% 
% mf0p3=1132
% mf2p0=2387
% mv = (2387-1132)./(2-0.3) = 1255/1.7 = 738.2353 mv/lpm; % 0.00135456 lpm/mv
% mv_offset = 1132 - 221.47 = 910
% lpm = (mv-910)./738.2353
% (1672-910)./738.2353

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
%            = (-K1 + (part1 - part2).^0.5)./(2.*K2) ;
T = 2;
dt = diffN(psapb1.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flow)./(60.*17.81); % mm per second
dL = dL ./ (1000); %m / sec;
dL = dL.*dt;
Bap_G = diffN(-log(Tr_green),60)./dL; %smoothed over 1 minute
k1=1.317; ko=0.866; 
kf = 1./(k1.*psapa1.transmittance_G + ko);
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





figure; plot(serial2hs(psapb1.time), kf.*Bap_G*1e6,'r.', serial2hs(psapa1.time), psapa1.Ba_G_PSAP3W,'kx' );
legend('b1 (derived)','a1 (PSAP)');
% Yay, looks good enough.

[~, changes] = find((diff2(psapb1.transmittance_blue)> 0.01),1,'first');


return