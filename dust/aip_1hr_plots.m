function aip_1h = aip_1hr_plots(aip_1h);
%
%
%% met T, P, RH
%
fig = figure;
first_fig = fig;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip_1h.time), aip_1h.RH_Ambient,'.',serial2doy(aip_1h.time), aip_1h.T_Ambient,'.');
lg = legend('RH_Ambient','T_Ambient'); set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip_1h.time), aip_1h.P_Ambient,'.');
lg = legend('P_Ambient');set(lg,'interp','none')
xlabel('day of year (Jan. 1 2006 = 1)'); xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
%
%
%% winds
% %
% fig = figure;
% ax(fig).sub(1) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.wind_spd,'.');
% title('wind speed')
% ylabel('wind speed (m/s)')
% ax(fig).sub(2) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.wind_dir,'.');
% title('wind dir')
% ylabel('wind dir (CW from N)')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%%

%
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
scatter(serial2doy(aip_1h.time), aip_1h.wind_N,4*(1+(aip_1h.wind_spd)), (aip_1h.wind_spd),'filled');colorbar
title('wind speed, North component')
ylabel('m/s')
ax(fig).sub(2) = subplot(2,1,2);
scatter(serial2doy(aip_1h.time), aip_1h.wind_E,4*(1+(aip_1h.wind_spd)), (aip_1h.wind_spd), 'filled');colorbar
title('wind speed, East component');
ylabel('m/s')
xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
%
%% ccn_cor, cpc_corr
% %
% fig = figure;
% ax(fig).sub(1) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.CN_contr,'b-',serial2doy(aip_1h.time), aip_1h.cpc_corr,'k.');
% lg = legend('CN_contr', 'cpc_corr');set(lg,'interp','none')
% ax(fig).sub(2) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), [aip_1h.CN_frac_gtp5,aip_1h.CN_frac_gtp7,aip_1h.CN_frac_gtp9,aip_1h.CN_frac_gt1p2],'-');
% lg = legend('0.5%', '0.7%', '0.9%', '1.2%');set(lg,'interp','none')
% title('CN_fraction at different supersaturation settings.')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% MFRSR AOD and Ang_500_800 2x1
%
% v = axis;
fig = figure;
ax(fig).sub(1) = subplot(2,1,1);
plot(serial2doy(aip_1h.time), [aip_1h.aod_500nm],'g.',serial2doy(aip_1h.time),aip_1h.aod_870nm,'r.');
title('Aerosol optical depth from MFRSR, corrected for forward scattering')
ylabel('aod')
lg = legend('aod_500nm', 'aod_870nm');set(lg,'interp','none')
ax(fig).sub(2) = subplot(2,1,2);
plot(serial2doy(aip_1h.time), aip_1h.ang_500_870_MFRSR,'k.');
ylabel('angstrom exponent')
lg = legend('ang_500_870_MFRSR');set(lg,'interp','none')
xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% axis(v)
%
%

%% Bsp(BGR) 1um and 10 um, 2x1
%
% fig = figure;
% ax(fig).sub(2) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
% lg = title('Total scattering coefficient, 10 um size cut');
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% ax(fig).sub(1) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
% lg = title('Total scattering coefficient, 1 um size cut'); 
% ylabel('1/Mm')
% 
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Bsp (1um 10um) B G R , 3x1
%
%Seems like this 3-pane (separated by RGB) isn't as informative
% as the two-pane separated by size cut.ne
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-bx');
% lg = title('Bsp_B_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(2) = subplot(3,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'G.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'Gx');
% lg = title('Bsp_G_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(3) = subplot(3,1,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-rx');
% lg = title('Bsp_R_(1um 10um)'); set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
% %
% %% Bbsp(BGR) 1um and 10 um, 2x1
% %
% fig = figure;
% ax(fig).sub(2) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_10um,'-r.');
% lg = title('Backscattering coefficient, 10 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% 
% 
% ax(fig).sub(1) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_1um,'-r.');
% lg = title('Backscatterring coefficient, 1 um size cut'); set(lg,'interp','none');
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% ylabel('1/Mm');

%
%
% %% Bbsp (1um 10um) B G R , 3x1
% %
% %Seems like this 3-pane (separated by RGB) isn't as informative
% % as the two-pane separated by size cut.
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_10um,'-bx');
% lg = title('Bbsp_B_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(2) = subplot(3,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_1um,'G.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_10um,'Gx');
% lg = title('Bbsp_G_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(3) = subplot(3,1,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_1um,'-r.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_10um,'-rx');
% lg = title('Bbsp_R_(1um 10um)'); set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')


%% Bsp_WET_BGR both size cuts, Wet Neph RH
% %
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Wet_1um./aip_1h.Bsp_B_Dry_1um,'-b.',...
%  serial2doy(aip_1h.time), aip_1h.Bsp_G_Wet_1um./aip_1h.Bsp_G_Dry_1um,'-g.',...
%  serial2doy(aip_1h.time), aip_1h.Bsp_R_Wet_1um./aip_1h.Bsp_R_Dry_1um,'-r.');
% lg = title('Bsp_(BGR)_1um (Wet/Dry)'); set(lg,'interp','none')
% ax(fig).sub(2) = subplot(3,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.RH_Neph_Wet,'R.');
% lg = title('RH_Neph_Wet'); set(lg,'interp','none');
% ax(fig).sub(3) = subplot(3,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Wet_10um./aip_1h.Bsp_B_Dry_10um,'-b.',...
%  serial2doy(aip_1h.time), aip_1h.Bsp_G_Wet_10um./aip_1h.Bsp_G_Dry_10um,'-g.',...
%  serial2doy(aip_1h.time), aip_1h.Bsp_R_Wet_10um./aip_1h.Bsp_R_Dry_10um,'-r.');
% lg = title('Bsp_(BGR)_10um (Wet/Dry)'); set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
% %% Pressure, ambient and in Neph
% %
% fig = figure;
% ax(fig).sub(1) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.P_Neph_Dry_1um,'.',...
%    serial2doy(aip_1h.time), aip_1h.P_Neph_Dry_10um,'.',...
%    serial2doy(aip_1h.time), aip_1h.P_Neph_Wet_1um,'x',...
%    serial2doy(aip_1h.time), aip_1h.P_Neph_Wet_10um,'x')
% title('Pressures at Neph')
% lg = legend('Dry_1um','Dry_10um','Wet_1um','Wet_10um'); set(lg,'interp','none')
% ax(fig).sub(2) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.P_Ambient,'.');
% lg = title('P_Ambient'); set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Bap (BGR) 1um 10um 2x1
% %
% 
% fig = figure;
% ax(fig).sub(2) = subplot(2,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.');
% lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% 
% ax(fig).sub(1) = subplot(2,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.');
% lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x') % linkaxes(ax(fig).sub,'xy')
% %
%
%% Bap (1um 10um), B G R 3x1
%
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-bx');
% lg = title('Bap_B_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(2) = subplot(3,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'G.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'Gx');
% lg = title('Bap_G_(1um 10um)'); set(lg,'interp','none')
% ax(fig).sub(3) = subplot(3,1,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-rx');
% lg = title('Bap_R_(1um 10um)'); set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')

%
%
%% cpc_corr, Bsp_B, and ratio - not so useful 3x1
% %
% aip_1h.Bsp_B_frac = aip_1h.Bsp_B_Dry_1um ./ aip_1h.cpc_corr;
% aip_1h.Bsp_frac = (aip_1h.Bsp_B_Dry_1um + aip_1h.Bsp_G_Dry_1um+aip_1h.Bsp_R_Dry_1um) ./ aip_1h.cpc_corr;
% %
% gf = aip_1h.Bsp_B_frac<2e-2;
% %
% fig = figure;
% ax(fig).sub(1) = subplot(3,1,1);
% semilogy(serial2doy(aip_1h.time), aip_1h.cpc_corr,'-r.', aip_1h.time(gf)-min(aip_1h.time), aip_1h.cpc_corr(gf),'-g.');
% lg = legend('cpc'); set(lg,'interp','none')
% title('Although it looked hopeful at first, it does not look promising.');
% %Good tracking is only obvious when B_frac is low, but these aren't really
% %our problem points.  Also, there are still clear outliers that don't track
% %well even though Bsp_frac is small, and "good" tracking is relative. The
% %fraction is small but varies by factors so that would propagate as a large
% %error source.
% ax(fig).sub(2) = subplot(3,1,2);
% semilogy(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um, '-b.',...
%   aip_1h.time(gf)-min(aip_1h.time), aip_1h.Bsp_B_Dry_1um(gf), '-g.' );
% lg = legend('Bsp_B_1um','gf');set(lg,'interp','none')
% ax(fig).sub(3) = subplot(3,1,3);
% semilogy(serial2doy(aip_1h.time), aip_1h.Bsp_B_frac, '-b.',...
%    aip_1h.time(gf)-min(aip_1h.time), aip_1h.Bsp_B_frac(gf), '-g.');
% lg = title('Bsp_B_frac = Bsp_B ./ cpc');set(lg,'interp','none')
% lg = legend('Bsp_B_frac','Bsp_frac');set(lg,'interp','none')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Bap (1um 10um), Ang, and submicron ratios 4x1
%
% disp('This is a great plot for illustration.')
fig = figure;
ax(fig).sub(1) = subplot(4,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.');
lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
legend('Blue','Green','Red')
ylabel('1/Mm');
ax(fig).sub(2) = subplot(4,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.');
lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
ax(fig).sub(4) = subplot(4,1,3);
plot(serial2doy(aip_1h.time), aip_1h.subfrac_Ba_B,'-b.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Ba_G,'-g.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Ba_R,'-r.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none')
ylabel('unitless ratio')
ax(fig).sub(3) = subplot(4,1,4);
plot(serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_1um,'-r.', ...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_10um,'-bx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_10um,'-gx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_10um,'-rx');
lg = title('Absorption angstrom exponent'); set(lg,'interp','none');
ylabel('unitless exponent')

xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% axis(ax(fig).sub(2), [15.5 18.5 0,400])
%
%
%% Bsp (1um 10um), Ang, and submicron ratios 4x1
%
fig = figure;
ax(fig).sub(2) = subplot(4,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
legend('Blue','Green','Red')

ax(fig).sub(1) = subplot(4,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');


ax(fig).sub(4) = subplot(4,1,3);
plot(serial2doy(aip_1h.time), aip_1h.subfrac_Bs_B,'-b.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Bs_G,'-g.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Bs_R,'-r.');
lg = title('Submicron scattering fraction'); set(lg,'interp','none')
ylabel('unitless ratio')

ax(fig).sub(3) = subplot(4,1,4);
plot(serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_1um,'-r.', ...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_10um,'-bx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_10um,'-gx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_10um,'-rx');
lg = title('Scattering angstrom exponent'); set(lg,'interp','none')
ylabel('unitless exponent')

xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
%
%
%% Bsp (1um 10um), Bap (1um 10um), Ang, and submicron ratios 4x2
%
% fig = figure;
% ax(fig).sub(1) = subplot(4,2,4);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.');
% lg = title('Aerosol absorption coefficient, 1 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% ax(fig).sub(2) = subplot(4,2,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.');
% lg = title('Aerosol absorption coefficient, 10 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% % legend('Blue','Green','Red')
% ax(fig).sub(3) = subplot(4,2,8);
% plot(serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_1um,'-r.', ...
%    serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_10um,'-bx',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_10um,'-gx',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_10um,'-rx');
% lg = title('Absorption angstrom exponents'); set(lg,'interp','none')
% ylabel('unitless exponent')
% ax(fig).sub(4) = subplot(4,2,6);
% plot(serial2doy(aip_1h.time), aip_1h.subfrac_Ba_B,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.subfrac_Ba_G,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.subfrac_Ba_R,'-r.');
% lg = title('Submicron absorption fraction'); set(lg,'interp','none');
% ylabel('unitless ratio')
% ax(fig).sub(5) = subplot(4,2,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
% lg = title('Scattering coefficient, 1 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% ax(fig).sub(6) = subplot(4,2,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
% lg = title('Scattering coefficient, 10 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% % legend('Blue','Green','Red')
% ax(fig).sub(7) = subplot(4,2,7);
% plot(serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_1um,'-r.', ...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_10um,'-bx',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_10um,'-gx',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_10um,'-rx');
% lg = title('Scattering angstrom exponent'); set(lg,'interp','none')
% ylabel('unitless exponent')
% ax(fig).sub(8) = subplot(4,2,5);
% plot(serial2doy(aip_1h.time), aip_1h.subfrac_Bs_B,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.subfrac_Bs_G,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.subfrac_Bs_R,'-r.');
% lg = title('Submicron scattering fraction'); set(lg,'interp','none')
% ylabel('unitless ratio')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Single-scattering albedo at both size cuts, 3x2
%
% fig = figure;
% ax(fig).sub(1) = subplot(3,2,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
% lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% ax(fig).sub(2) = subplot(3,2,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.')
% lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% ax(fig).sub(3) = subplot(3,2,5);
% plot(serial2doy(aip_1h.time), aip_1h.w_B_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.w_G_10um,'-g.',...
%       serial2doy(aip_1h.time), aip_1h.w_R_10um,'-r.');
% lg = title('Single scattering albedo, 10 um size cut'); set(lg,'interp','none');
% xlabel('day of year (Jan. 1 2006 = 1)');
% ylabel('unitless ratio')
% ax(fig).sub(4) = subplot(3,2,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
% lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% ax(fig).sub(5) = subplot(3,2,4);
% plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.')
% lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none');
% ylabel('1/Mm');
% ax(fig).sub(6) = subplot(3,2,6);
% plot(serial2doy(aip_1h.time), aip_1h.w_B_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.w_G_1um,'-g.',...
%       serial2doy(aip_1h.time), aip_1h.w_R_1um,'-r.');
% lg = title('Single scattering albedo, 1 um size cut'); set(lg,'interp','none')
% ylabel('unitless ratio')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Single-scattering albedo 10 um and then 1 um, 3x1
%
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.')
lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip_1h.time), aip_1h.w_B_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.w_G_10um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.w_R_10um,'-r.');
lg = title('Single scattering albedo, 10 um size cut'); set(lg,'interp','none');
xlabel('day of year (Jan. 1 2006 = 1)');
ylabel('unitless ratio')
%
%%
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.')
lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip_1h.time), aip_1h.w_B_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.w_G_1um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.w_R_1um,'-r.');
lg = title('Single scattering albedo, 1 um size cut'); set(lg,'interp','none');
xlabel('day of year (Jan. 1 2006 = 1)');
ylabel('unitless ratio')
%
%
% %% Backscatter fraction at both size cuts, 3x2
% %
% fig = figure;
% ax(fig).sub(1) = subplot(3,2,1);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
% lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% ax(fig).sub(2) = subplot(3,2,3);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_10um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_10um,'-r.');
% lg = title('Backscattering coefficient, 10 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% ax(fig).sub(3) = subplot(3,2,5);
% plot(serial2doy(aip_1h.time), aip_1h.bsf_B_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.bsf_G_10um,'-g.',...
%       serial2doy(aip_1h.time), aip_1h.bsf_R_10um,'-r.');
% lg = title('Backscatter fraction, 10 um size cut'); set(lg,'interp','none')
% ylabel('unitless ratio')
% xlabel('day of year (Jan. 1 2006 = 1)');
% ax(fig).sub(4) = subplot(3,2,2);
% plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
% lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% legend('Blue','Green','Red')
% ax(fig).sub(5) = subplot(3,2,4);
% plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_1um,'-r.');
% lg = title('Backscattering coefficient, 1 um size cut'); set(lg,'interp','none')
% ylabel('1/Mm');
% ax(fig).sub(6) = subplot(3,2,6);
% plot(serial2doy(aip_1h.time), aip_1h.bsf_B_1um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.bsf_G_1um,'-g.',...
%       serial2doy(aip_1h.time), aip_1h.bsf_R_1um,'-r.');
% lg = title('Backscatter fraction, 1 um size cut'); set(lg,'interp','none')
% ylabel('unitless ratio')
% xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% %
%
%% Backscatter fraction at 10 um, then 1 um, 3x1
%
fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.');
lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_10um,'-r.');
lg = title('Backscattering coefficient, 10 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip_1h.time), aip_1h.bsf_B_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.bsf_G_10um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.bsf_R_10um,'-r.');
lg = title('Backscatter fraction, 10 um size cut'); set(lg,'interp','none')
ylabel('unitless ratio')
xlabel('day of year (Jan. 1 2006 = 1)');

fig = figure;
ax(fig).sub(1) = subplot(3,1,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.');
lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(2) = subplot(3,1,2);
plot(serial2doy(aip_1h.time), aip_1h.Bbsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bbsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bbsp_R_Dry_1um,'-r.');
lg = title('Backscattering coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
ax(fig).sub(3) = subplot(3,1,3);
plot(serial2doy(aip_1h.time), aip_1h.bsf_B_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.bsf_G_1um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.bsf_R_1um,'-r.');
lg = title('Backscatter fraction, 1 um size cut'); set(lg,'interp','none')
ylabel('unitless ratio')
xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
%%

last_fig = fig;
%%
all_ax = [];
for f = first_fig: last_fig
all_ax = [all_ax; ax(f).sub(:)];
end
linkaxes(all_ax,'x');

% disp('Hit any key')
% % pause
% close('all'); clear ax
% pause(1)

% % Make images with utc on y and doy on x
% mat = NaN([24,365]);
% % for f = 2:length(field)
%    %%
%    f =1;
%    %%
%    f = f+1
%    
%    if length(aip_1h.(field{f}))==8760;
%       mat(:) = aip_1h.(field{f})(:);
%       figure; imagesc(mat); colormap; colorbar; axis('xy')
%       tl = title(field{f}); set(tl,'interp','none');
%       pause(1)
%    end
%    %%