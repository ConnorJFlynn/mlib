abe = ancload(['C:\case_studies\abe\Feb2006_proc20100336\sgpaerosolbe1turnC1.c1.20060201.000000.cdf']);
aip = ancload(['C:\case_studies\abe\Feb2006_proc20100336\sgpaip1ogrenC1.c1.20060201.000000.cdf']);
frh = ancload(['C:\case_studies\abe\Feb2006_proc20100336\sgpaipfrhC1.c1.20060201.000000.cdf']);

% First, check Bs fields from aip (native), aip (interpolated), and ABE 
%% % Looks good, new (interpolated) AIP fields match existing/previous ABE fields
close('all')
figure; plot(serial2doy(abe.time), [abe.vars.Bs_R_Dry_1um_Neph3W_1.data;abe.vars.Bs_G_Dry_1um_Neph3W_1.data;abe.vars.Bs_B_Dry_1um_Neph3W_1.data], 'x',...
   serial2doy(abe.time), [abe.vars.scat_coeff_red.data;abe.vars.scat_coeff_green.data;abe.vars.scat_coeff_blue.data], 'o');
title('comparing existing ABE to interpolated AIP: Bs RGB')
legend('new R','new G','new B','old R','old G','old B');

zoom('on')
% Looks good, new (raw) AIP fields overlap existing/previous ABE fields
figure; plot(serial2doy(abe.time), [abe.vars.Bs_R_Dry_1um_Neph3W_1.data;abe.vars.Bs_G_Dry_1um_Neph3W_1.data;abe.vars.Bs_B_Dry_1um_Neph3W_1.data], 'x',...
   serial2doy(aip.time), [aip.vars.Bs_R_Dry_1um_Neph3W_1.data;aip.vars.Bs_G_Dry_1um_Neph3W_1.data;aip.vars.Bs_B_Dry_1um_Neph3W_1.data]/1000, 'o');
legend('abe R','abe G','abe B','aip R','aip G','aip B')
title('comparing existing ABE to native AIP: Bs RGB')
zoom('on')

%% Next, check Bbs fields from aip (native), aip (interpolated), and ABE 
% Looks good, new (interpolated) AIP fields match existing/previous ABE fields
figure; plot(serial2doy(abe.time), [abe.vars.Bbs_R_Dry_1um_Neph3W_1.data;abe.vars.Bbs_G_Dry_1um_Neph3W_1.data;abe.vars.Bbs_B_Dry_1um_Neph3W_1.data], 'x',...
   serial2doy(abe.time), [abe.vars.backscatter_red.data;abe.vars.backscatter_green.data;abe.vars.backscatter_blue.data], 'o');
legend('new R','new G','new B','old R','old G','old B');
title('comparing existing ABE to interpolated AIP: Bbs RGB')

zoom('on')
% % Looks good, new (raw) AIP fields overlap existing/previous ABE fields
figure; plot(serial2doy(abe.time), [abe.vars.Bbs_R_Dry_1um_Neph3W_1.data;abe.vars.Bbs_G_Dry_1um_Neph3W_1.data;abe.vars.Bbs_B_Dry_1um_Neph3W_1.data], 'x',...
   serial2doy(aip.time), [aip.vars.Bbs_R_Dry_1um_Neph3W_1.data;aip.vars.Bbs_G_Dry_1um_Neph3W_1.data;aip.vars.Bbs_B_Dry_1um_Neph3W_1.data]/1000, 'o');
legend('abe R','abe G','abe B','aip R','aip G','aip B')
title('comparing existing ABE to native AIP: Bbs RGB')
zoom('on')

%% Next, check Bap fields from aip (native), aip (interpolated), and ABE 
% Looks good, new (interpolated) AIP fields match existing/previous ABE fields
close('all')
figure; plot(serial2doy(abe.time), [abe.vars.absorp_coef_mean.data;abe.vars.absorp_coef_green.data], 'o');
legend('absorp coef green','absorp coef mean');
title('comparing existing ABE absorp coef green to absorp coef mean')
zoom('on')
%%
figure; plot(serial2doy(abe.time), [abe.vars.Ba_R_Dry_1um_PSAP3W_1.data;abe.vars.Ba_G_Dry_1um_PSAP3W_1.data;abe.vars.Ba_B_Dry_1um_PSAP3W_1.data], 'x',...
   serial2doy(abe.time), [abe.vars.absorp_coef_red.data;abe.vars.absorp_coef_green.data;abe.vars.absorp_coef_blue.data], 'o');
legend('new R','new G','new B','old R','old G','old B');
title('comparing existing ABE to interpolated AIP: Ba RGB')
zoom('on')
%%

% % Looks good, new (raw) AIP fields overlap existing/previous ABE fields
figure; plot(serial2doy(abe.time), [abe.vars.Ba_R_Dry_1um_PSAP3W_1.data;abe.vars.Ba_G_Dry_1um_PSAP3W_1.data;abe.vars.Ba_B_Dry_1um_PSAP3W_1.data], '-x',...
   serial2doy(aip.time), [aip.vars.Ba_R_Dry_1um_PSAP3W_1.data;aip.vars.Ba_G_Dry_1um_PSAP3W_1.data;aip.vars.Ba_B_Dry_1um_PSAP3W_1.data]/1000, 'o');
legend('abe R','abe G','abe B','aip R','aip G','aip B')
title('comparing existing ABE to native AIP: Ba RGB')
zoom('on')



%% frh Bs frh fields
% Looks good for R and B Bs fits, maybe look at what happens when filling
% for missings
% G Bs looks strange after some point.  Initially interpolates between
% daily averages but then flat-lines
figure; 
ax(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_G_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_G_1um_2p.data(1,:), 'o');
title('Bs G, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_G_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_G_1um_2p.data(2,:), 'o');
title('Bs G, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax,'x');
%%

figure; 
ax2(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_R_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_R_1um_2p.data(1,:), 'o');
title('Bs R, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax2(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_R_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_R_1um_2p.data(2,:), 'o');
title('Bs R, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax2,'x');

figure; 
ax3(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_B_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_B_1um_2p.data(1,:), 'o');
title('Bs B, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax3(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bs_B_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bs_B_1um_2p.data(2,:), 'o');
title('Bs B, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax3,'x');

%%
%% frh Bbs frh fields
% close('all')
figure; 
ax(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_G_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_G_1um_2p.data(1,:), 'o');
title('Bbs G, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_G_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_G_1um_2p.data(2,:), 'o');
title('Bbs G, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax,'x');
%%

figure; 
ax2(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_R_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_R_1um_2p.data(1,:), 'o');
title('Bbs R, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax2(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_R_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_R_1um_2p.data(2,:), 'o');
title('Bbs R, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax2,'x');

figure; 
ax3(1) = subplot(2,1,1); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_B_1um_2p.data(1,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_B_1um_2p.data(1,:), 'o');
title('Bbs B, parameter 1')
legend('abe','aip frh')
ylim([-5,5]);
ax3(2) = subplot(2,1,2); 
plot(serial2doy(abe.time), abe.vars.fRH_Bbs_B_1um_2p.data(2,:), 'x',...
   serial2doy(frh.time), frh.vars.fRH_Bbs_B_1um_2p.data(2,:), 'o');
title('Bbs B, parameter 2')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax3,'x');

%%
% Compare fit_80/45 values
%% frh Bbs frh fields
% close('all')
figure; 
ax(1) = subplot(2,1,1); 
Bs_G_ratio = fitrh_2p(.85,abe.vars.fRH_Bs_G_1um_2p.data(1,:),abe.vars.fRH_Bs_G_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bs_G_1um_2p.data(1,:),abe.vars.fRH_Bs_G_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bs_G_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bs_G_1um_2p.data, 'go');
title('Bs G 80/45 ratio')
legend('abe','aip frh')
ylim([-5,5]);
ax(2) = subplot(2,1,2); 
Bbs_G_ratio = fitrh_2p(.85,abe.vars.fRH_Bbs_G_1um_2p.data(1,:),abe.vars.fRH_Bbs_G_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bbs_G_1um_2p.data(1,:),abe.vars.fRH_Bbs_G_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bbs_G_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bbs_G_1um_2p.data, 'go');
title('Bbs G 80/45 ratio')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax,'x');
%%
figure; 
ax(1) = subplot(2,1,1); 
Bs_R_ratio = fitrh_2p(.85,abe.vars.fRH_Bs_R_1um_2p.data(1,:),abe.vars.fRH_Bs_R_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bs_R_1um_2p.data(1,:),abe.vars.fRH_Bs_R_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bs_R_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bs_R_1um_2p.data, 'ro');
title('Bs R 80/45 ratio')
legend('abe','aip frh')
ylim([-5,5]);
ax(2) = subplot(2,1,2); 
Bbs_R_ratio = fitrh_2p(.85,abe.vars.fRH_Bbs_R_1um_2p.data(1,:),abe.vars.fRH_Bbs_R_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bbs_R_1um_2p.data(1,:),abe.vars.fRH_Bbs_R_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bbs_R_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bbs_R_1um_2p.data, 'ro');
title('Bbs R 80/45 ratio')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax,'x');
%%
figure; 
ax(1) = subplot(2,1,1); 
Bs_B_ratio = fitrh_2p(.85,abe.vars.fRH_Bs_B_1um_2p.data(1,:),abe.vars.fRH_Bs_B_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bs_B_1um_2p.data(1,:),abe.vars.fRH_Bs_B_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bs_B_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bs_B_1um_2p.data, 'bo');
title('Bs R 80/45 ratio')
legend('abe','aip frh')
ylim([-5,5]);
ax(2) = subplot(2,1,2); 
Bbs_B_ratio = fitrh_2p(.85,abe.vars.fRH_Bbs_B_1um_2p.data(1,:),abe.vars.fRH_Bbs_B_1um_2p.data(2,:))./ ....
   fitrh_2p(.40,abe.vars.fRH_Bbs_B_1um_2p.data(1,:),abe.vars.fRH_Bbs_B_1um_2p.data(2,:));
plot(serial2doy(abe.time), Bbs_B_ratio, 'kx',...
   serial2doy(frh.time), frh.vars.ratio_85by40_Bbs_B_1um_2p.data, 'bo');
title('Bbs R 80/45 ratio')
legend('abe','aip frh')
zoom('on')
ylim([-5,5]);
linkaxes(ax,'x');