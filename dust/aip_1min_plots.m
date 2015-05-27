function aip = aip_1min_plots(aip);
%aip_1d.aod_500nm(notNaN)
%
%% met T, P, RH
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.RH_Ambient,'.',serial2doy(aip.time), aip.T_Ambient,'.');
lg = legend('RH_Ambient','T_Ambient'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.P_Ambient,'.');
lg = legend('P_Ambient');set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% winds
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.wind_spd,'.');
title('wind speed')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.wind_dir,'.');
title('wind dir')
linkaxes(ax(fig).sub,'x')
 xlim(ax(fig).sub(2), [47.5 50.5])
%
%
%% ccn_cor, cpc_corr
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.CN_contr,'x',serial2doy(aip.time), aip.cpc_corr,'k.');
lg = legend('CN_contr', 'cpc_corr');set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.CN_amb,'x',serial2doy(aip.time), aip.ccn_corr,'k.');
lg = legend('CN_amb', 'ccn_corr');set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% ccn_cor, color by SS_pct
%
fig = figure;
scatter(serial2doy(aip.time), aip.CN_amb,24,aip.SS_pct,'filled');
title('ccn_cor, color by SS_pct','interp','none')
%
%
%% MFRSR AOD and Ang_500_800 2x1
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip.time), [aip.aod_415nm,aip.aod_500nm,aip.aod_615nm,aip.aod_673nm,aip.aod_870nm],'.');
lg = legend('aod_415nm', 'aod_500nm', 'aod_615nm', 'aod_673nm', 'aod_870nm');set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.ang_500_870_MFRSR,'.');
lg = legend('ang_500_800_MFRSR');set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bsp(BGR) 1um and 10 um, 2x1
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um');;set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bsp (1um 10um) B G R , 3x1
%
%Seems like this 3-pane (separated by RGB) isn't as informative
% as the two-pane separated by size cut.ne
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_B_Dry_10um,'bx');
lg = title('Bsp_B_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time), aip.Bsp_G_Dry_1um,'G.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'Gx');
lg = title('Bsp_G_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'rx');
lg = title('Bsp_R_(1um 10um)'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bbsp(BGR) 1um and 10 um, 2x1
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.Bbsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bbsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bbsp_R_Dry_1um,'r.');
lg = title('Bbsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.Bbsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bbsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bbsp_R_Dry_10um,'r.');
lg = title('Bbsp_(BGR)_10um');;set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bbsp (1um 10um) B G R , 3x1
%
%Seems like this 3-pane (separated by RGB) isn't as informative
% as the two-pane separated by size cut.
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip.time), aip.Bbsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bbsp_B_Dry_10um,'bx');
lg = title('Bbsp_B_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time), aip.Bbsp_G_Dry_1um,'G.',...
   serial2doy(aip.time), aip.Bbsp_G_Dry_10um,'Gx');
lg = title('Bbsp_G_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.Bbsp_R_Dry_1um,'r.',...
   serial2doy(aip.time), aip.Bbsp_R_Dry_10um,'rx');
lg = title('Bbsp_R_(1um 10um)'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')


%% Bsp_WET_BGR both size cuts, Wet Neph RH
%
fig = figure;
ax(fig).sub(1) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.Bsp_B_Wet_1um./aip.Bsp_B_Dry_1um,'b.',...
 serial2doy(aip.time), aip.Bsp_G_Wet_1um./aip.Bsp_G_Dry_1um,'g.',...
 serial2doy(aip.time), aip.Bsp_R_Wet_1um./aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um (Wet/Dry)'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time), aip.RH_Neph_Wet,'R.');
lg = title('RH_Neph_Wet'); set(lg,'interp','none');
ax(fig).sub(3) = subplot(3,1,1);
plot(serial2doy(aip.time), aip.Bsp_B_Wet_10um./aip.Bsp_B_Dry_10um,'b.',...
 serial2doy(aip.time), aip.Bsp_G_Wet_10um./aip.Bsp_G_Dry_10um,'g.',...
 serial2doy(aip.time), aip.Bsp_R_Wet_10um./aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um (Wet/Dry)'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Pressure, ambient and in Neph
%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.P_Neph_Dry_1um,'.',...
   serial2doy(aip.time), aip.P_Neph_Dry_10um,'.',...
   serial2doy(aip.time), aip.P_Neph_Wet_1um,'x',...
   serial2doy(aip.time), aip.P_Neph_Wet_10um,'x')
title('Pressures at Neph')
lg = legend('Dry_1um','Dry_10um','Wet_1um','Wet_10um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.P_Ambient,'.');
lg = title('P_Ambient'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bap (BGR) 1um 10um 2x1
%

fig = figure;
ax(fig).sub(1) = subplot(2,1,2);
plot(serial2doy(aip.time), aip.Bap_B_3W_1um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_1um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_1um,'r.');
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,1);
plot(serial2doy(aip.time), aip.Bap_B_3W_10um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_10um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_10um,'r.');
lg = title('Bap_(BGR)_10um');;set(lg,'interp','none')
linkaxes(ax(fig).sub,'xy')
%
%
%% Bap (1um 10um), B G R 3x1
%
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip.time), aip.Bap_B_3W_1um,'b.',...
   serial2doy(aip.time), aip.Bap_B_3W_10um,'bx');
lg = title('Bap_B_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time), aip.Bap_G_3W_1um,'G.',...
   serial2doy(aip.time), aip.Bap_G_3W_10um,'Gx');
lg = title('Bap_G_(1um 10um)'); set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.Bap_R_3W_1um,'r.',...
   serial2doy(aip.time), aip.Bap_R_3W_10um,'rx');
lg = title('Bap_R_(1um 10um)'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')

%
%
%% cpc_corr, Bsp_B, and ratio - not so useful 3x1
% %
% aip.Bsp_B_frac = aip.Bsp_B_Dry_1um ./ aip.cpc_corr;
% aip.Bsp_frac = (aip.Bsp_B_Dry_1um + aip.Bsp_G_Dry_1um+aip.Bsp_R_Dry_1um) ./ aip.cpc_corr;
% %
% gf = aip.Bsp_B_frac<2e-2;
% %
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,1);
% semilogy(serial2doy(aip.time), aip.cpc_corr,'r.', aip.time(gf)-min(aip.time), aip.cpc_corr(gf),'g.');
% lg = legend('cpc'); set(lg,'interp','none')
% title('Although it looked hopeful at first, it does not look promising.');
% %Good tracking is only obvious when B_frac is low, but these aren't really
% %our problem points.  Also, there are still clear outliers that don't track
% %well even though Bsp_frac is small, and "good" tracking is relative. The
% %fraction is small but varies by factors so that would propagate as a large
% %error source.
% ax(fig).sub(2) = subplot(3,1,2);
% semilogy(serial2doy(aip.time), aip.Bsp_B_Dry_1um, 'b.',...
%   aip.time(gf)-min(aip.time), aip.Bsp_B_Dry_1um(gf), 'g.' );
% lg = legend('Bsp_B_1um','gf');set(lg,'interp','none')
% ax(fig).sub(3) = subplot(3,1,3);
% semilogy(serial2doy(aip.time), aip.Bsp_B_frac, 'b.',...
%    aip.time(gf)-min(aip.time), aip.Bsp_B_frac(gf), 'g.');
% lg = title('Bsp_B_frac = Bsp_B ./ cpc');set(lg,'interp','none')
% lg = legend('Bsp_B_frac','Bsp_frac');set(lg,'interp','none')
% linkaxes(ax(fig).sub,'x')
% %
%
%% Bap (1um 10um), Ang, and submicron ratios 4x2
%
% disp('This is a great plot for illustration.')
fig = figure;
ax(fig).sub(1) = subplot(4,1,1);
plot(serial2doy(aip.time), aip.Bap_B_3W_1um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_1um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_1um,'r.');
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(4,1,2);
plot(serial2doy(aip.time), aip.Bap_B_3W_10um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_10um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_10um,'r.');
lg = title('Bap_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(4,1,3);
plot(serial2doy(aip.time), aip.Ang_Ba_B_G_1um,'b.',...
   serial2doy(aip.time), aip.Ang_Ba_B_R_1um,'g.',...
   serial2doy(aip.time), aip.Ang_Ba_G_R_1um,'r.', ...
   serial2doy(aip.time), aip.Ang_Ba_B_G_10um,'bx',...
   serial2doy(aip.time), aip.Ang_Ba_B_R_10um,'gx',...
   serial2doy(aip.time), aip.Ang_Ba_G_R_10um,'rx');
lg = title('Ang_Ba_(BGR)'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(4,1,4);
plot(serial2doy(aip.time), aip.subfrac_Ba_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Ba_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Ba_R,'r.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
% axis(ax(fig).sub(2), [15.5 18.5 0,400])
 axis(ax(fig).sub(2), [47.5 50.5 0,400])
%!
%% Bsp (1um 10um), Bap (1um 10um), and submicron ratios 3x2
%
% aos = aip;
fig = figure;
ax(fig).sub(1) = subplot(3,2,4);
plot(serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_B_3W_1um(aip.impactor_sub>0),'b.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_G_3W_1um(aip.impactor_sub>0),'g.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_R_3W_1um(aip.impactor_sub>0),'r.');
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,2,2);
plot(serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_B_3W_10um(aip.impactor_sup>0),'b.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_G_3W_10um(aip.impactor_sup>0),'g.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_R_3W_10um(aip.impactor_sup>0),'r.');
lg = title('Bap_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,2,6);
plot(serial2doy(aip.time), aip.subfrac_Ba_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Ba_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Ba_R,'r.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(3,2,3);
plot(serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_B_Dry_1um(aip.impactor_sub>0),'b.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_G_Dry_1um(aip.impactor_sub>0),'g.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_R_Dry_1um(aip.impactor_sub>0),'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(5) = subplot(3,2,1);
plot(serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_B_Dry_10um(aip.impactor_sup>0),'b.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_G_Dry_10um(aip.impactor_sup>0),'g.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_R_Dry_10um(aip.impactor_sup>0),'r.');
lg = title('Bsp_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(6) = subplot(3,2,5);
plot(serial2doy(aip.time), aip.subfrac_Bs_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Bs_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Bs_R,'r.');
lg = title('Submicron scattering fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')

%!
%% Bsp (1um 10um) and submicron ratios 3x1
%
% aos = aip;
fig = figure;
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_B_Dry_1um(aip.impactor_sub>0),'b.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_G_Dry_1um(aip.impactor_sub>0),'g.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bsp_R_Dry_1um(aip.impactor_sub>0),'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_B_Dry_10um(aip.impactor_sup>0),'b.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_G_Dry_10um(aip.impactor_sup>0),'g.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bsp_R_Dry_10um(aip.impactor_sup>0),'r.');
lg = title('Bsp_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.subfrac_Bs_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Bs_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Bs_R,'r.');
lg = title('Submicron scattering fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')

%% Bap (1um 10um) and submicron ratios 3x1
%
% aos = aip;
fig = figure;
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_B_3W_1um(aip.impactor_sub>0),'b.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_G_3W_1um(aip.impactor_sub>0),'g.',...
   serial2doy(aip.time(aip.impactor_sub>0)), aip.Bap_R_3W_1um(aip.impactor_sub>0),'r.');
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_B_3W_10um(aip.impactor_sup>0),'b.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_G_3W_10um(aip.impactor_sup>0),'g.',...
   serial2doy(aip.time(aip.impactor_sup>0)), aip.Bap_R_3W_10um(aip.impactor_sup>0),'r.');
lg = title('Bap_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip.time), aip.subfrac_Ba_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Ba_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Ba_R,'r.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')

%!
%
%% Bsp (1um 10um), Ang, and submicron ratios 4x1
%
fig = figure;
ax(fig).sub(1) = subplot(4,1,2);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(4,1,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(4,1,4);
plot(serial2doy(aip.time), aip.Ang_Bs_B_G_1um,'b.',...
   serial2doy(aip.time), aip.Ang_Bs_B_R_1um,'g.',...
   serial2doy(aip.time), aip.Ang_Bs_G_R_1um,'r.', ...
   serial2doy(aip.time), aip.Ang_Bs_B_G_10um,'bx',...
   serial2doy(aip.time), aip.Ang_Bs_B_R_10um,'gx',...
   serial2doy(aip.time), aip.Ang_Bs_G_R_10um,'rx');
lg = title('Ang_Bs_(BGR)'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(4,1,3);
plot(serial2doy(aip.time), aip.subfrac_Bs_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Bs_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Bs_R,'r.');
lg = title('Submicron scattering fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Bsp (1um 10um), Bap (1um 10um), Ang, and submicron ratios 4x2
%
% aos = aip;
fig = figure;
ax(fig).sub(1) = subplot(4,2,4);
plot(serial2doy(aip.time), aip.Bap_B_3W_1um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_1um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_1um,'r.');
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(4,2,2);
plot(serial2doy(aip.time), aip.Bap_B_3W_10um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_10um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_10um,'r.');
lg = title('Bap_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(3) = subplot(4,2,8);
plot(serial2doy(aip.time), aip.Ang_Ba_B_G_1um,'b.',...
   serial2doy(aip.time), aip.Ang_Ba_B_R_1um,'g.',...
   serial2doy(aip.time), aip.Ang_Ba_G_R_1um,'r.', ...
   serial2doy(aip.time), aip.Ang_Ba_B_G_10um,'bx',...
   serial2doy(aip.time), aip.Ang_Ba_B_R_10um,'gx',...
   serial2doy(aip.time), aip.Ang_Ba_G_R_10um,'rx');
lg = title('Ang_Ba_(BGR)'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(4,2,6);
plot(serial2doy(aip.time), aip.subfrac_Ba_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Ba_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Ba_R,'r.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none')
ax(fig).sub(5) = subplot(4,2,3);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(6) = subplot(4,2,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um');;set(lg,'interp','none')
ax(fig).sub(7) = subplot(4,2,7);
plot(serial2doy(aip.time), aip.Ang_Bs_B_G_1um,'b.',...
   serial2doy(aip.time), aip.Ang_Bs_B_R_1um,'g.',...
   serial2doy(aip.time), aip.Ang_Bs_G_R_1um,'r.', ...
   serial2doy(aip.time), aip.Ang_Bs_B_G_10um,'bx',...
   serial2doy(aip.time), aip.Ang_Bs_B_R_10um,'gx',...
   serial2doy(aip.time), aip.Ang_Bs_G_R_10um,'rx');
lg = title('Ang_Bs_(BGR)'); set(lg,'interp','none')
ax(fig).sub(8) = subplot(4,2,5);
plot(serial2doy(aip.time), aip.subfrac_Bs_B,'b.',...
   serial2doy(aip.time), aip.subfrac_Bs_G,'g.',...
   serial2doy(aip.time), aip.subfrac_Bs_R,'r.');
lg = title('Submicron scattering fraction'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
 xlim(ax(fig).sub(2), [47.5 50.5])
%
%
%% Single-scattering albedo at both size cuts, 3x2
%
fig = figure;
ax(fig).sub(1) = subplot(3,2,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,2,3);
plot(serial2doy(aip.time), aip.Bap_B_3W_10um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_10um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_10um,'r.')
lg = title('Bap_(BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,2,5);
plot(serial2doy(aip.time), aip.w_B_10um,'b.',...
   serial2doy(aip.time), aip.w_G_10um,'g.',...
      serial2doy(aip.time), aip.w_R_10um,'r.');
lg = title('SSA_(BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(3,2,2);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(5) = subplot(3,2,4);
plot(serial2doy(aip.time), aip.Bap_B_3W_1um,'b.',...
   serial2doy(aip.time), aip.Bap_G_3W_1um,'g.',...
   serial2doy(aip.time), aip.Bap_R_3W_1um,'r.')
lg = title('Bap_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(6) = subplot(3,2,6);
plot(serial2doy(aip.time), aip.w_B_1um,'b.',...
   serial2doy(aip.time), aip.w_G_1um,'g.',...
      serial2doy(aip.time), aip.w_R_1um,'r.');
lg = title('SSA_(BGR)_1um'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')
%
%
%% Backscatter fraction at both size cuts, 3x2
%
fig = figure;
ax(fig).sub(1) = subplot(3,2,1);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_10um,'r.');
lg = title('Bsp_(BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(3,2,3);
plot(serial2doy(aip.time), aip.Bbsp_B_Dry_10um,'b.',...
   serial2doy(aip.time), aip.Bbsp_G_Dry_10um,'g.',...
   serial2doy(aip.time), aip.Bbsp_R_Dry_10um,'r.');
lg = title('Bbsp_(BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(3) = subplot(3,2,5);
plot(serial2doy(aip.time), aip.bsf_B_10um,'b.',...
   serial2doy(aip.time), aip.bsf_G_10um,'g.',...
      serial2doy(aip.time), aip.bsf_R_10um,'r.');
lg = title('backscatter fraction (BGR)_10um'); set(lg,'interp','none')
ax(fig).sub(4) = subplot(3,2,2);
plot(serial2doy(aip.time), aip.Bsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bsp_R_Dry_1um,'r.');
lg = title('Bsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(5) = subplot(3,2,4);
plot(serial2doy(aip.time), aip.Bbsp_B_Dry_1um,'b.',...
   serial2doy(aip.time), aip.Bbsp_G_Dry_1um,'g.',...
   serial2doy(aip.time), aip.Bbsp_R_Dry_1um,'r.');
lg = title('Bbsp_(BGR)_1um'); set(lg,'interp','none')
ax(fig).sub(6) = subplot(3,2,6);
plot(serial2doy(aip.time), aip.bsf_B_1um,'b.',...
   serial2doy(aip.time), aip.bsf_G_1um,'g.',...
      serial2doy(aip.time), aip.bsf_R_1um,'r.');
lg = title('backscatter fraction (BGR)_1um'); set(lg,'interp','none')
linkaxes(ax(fig).sub,'x')

% disp('Hit any key')
% pause
% close('all'); clear ax
% pause(1)
