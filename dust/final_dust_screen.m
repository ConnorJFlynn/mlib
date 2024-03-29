function   aip_1h = final_dust_screen(aip_1h);
% Apply tests that define metric.
Bsp_G_10 = 200;
Ang_Bs_BG_10 = .5;
Ang_Bs_GR_1 = 1;
Ang_Bs_BG_1 = 1;
subfrac_Bs_G = 0.25;
subfrac_Bs_G2 = 0.7;
w_G_10um = .89;
   dust = (aip_1h.Bsp_G_Dry_10um > Bsp_G_10)&(aip_1h.Ang_Bs_B_G_10um<Ang_Bs_BG_10)&...
(aip_1h.Ang_Bs_G_R_1um<Ang_Bs_GR_1)& ...
((aip_1h.subfrac_Bs_G<subfrac_Bs_G)|...
((aip_1h.subfrac_Bs_G>subfrac_Bs_G)&(aip_1h.subfrac_Bs_G<subfrac_Bs_G2)&(aip_1h.w_G_10um>w_G_10um)));
% dust = (aip_1h.Bsp_G_Dry_10um > Bsp_G_10)&(aip_1h.Ang_Bs_B_G_10um<Ang_Bs_BG_10)&...
% (aip_1h.Ang_Bs_B_G_1um<Ang_Bs_BG_1)& ...
% ((aip_1h.subfrac_Bs_G<subfrac_Bs_G)|...
% ((aip_1h.subfrac_Bs_G>subfrac_Bs_G)&(aip_1h.subfrac_Bs_G<subfrac_Bs_G2)&(aip_1h.w_G_10um>w_G_10um)));
sum(dust)
length(unique(serial2doy(floor(aip_1h.time(dust)))))
% plot the results.
%% Bsp (1um 10um), Bap (1um 10um), Ang, and submicron ratios 4x2

fig = figure;
ax(fig).sub(1) = subplot(4,2,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_10um(dust),'k.');
ln = line([xlim],[Bsp_G_10,Bsp_G_10]); set(ln,'color','m','linestyle','--');
lg = title('Scattering coefficient, 10 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(2) = subplot(4,2,3);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_1um(dust),'k.');

lg = title('Scattering coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
ax(fig).sub(3) = subplot(4,2,5);
plot(serial2doy(aip_1h.time), aip_1h.subfrac_Bs_B,'-b.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Bs_G,'-g.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Bs_R,'-r.',...
   serial2doy(aip_1h.time(dust)), aip_1h.subfrac_Bs_B(dust),'k.');
ln = line([xlim],[subfrac_Bs_G,subfrac_Bs_G]);
set(ln,'color','m','linestyle','--');
ln = line([xlim],[subfrac_Bs_G2,subfrac_Bs_G2]);
set(ln,'color','m','linestyle','--');


lg = title('Submicron scattering fraction'); set(lg,'interp','none')
ylabel('unitless ratio')
ax(fig).sub(4) = subplot(4,2,7);
plot(serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_1um,'-r.', ...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_10um,'-bx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_R_10um,'-gx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Bs_G_R_10um,'-rx',...
serial2doy(aip_1h.time(dust)), aip_1h.Ang_Bs_B_G_1um(dust),'k.',...
serial2doy(aip_1h.time(dust)), aip_1h.Ang_Bs_B_G_10um(dust),'kx');
ln = line([xlim],[Ang_Bs_BG_10,Ang_Bs_BG_10]); 
set(ln,'color','m','linestyle','--');
ln = line([xlim],[Ang_Bs_GR_1,Ang_Bs_GR_1]);
set(ln,'color','m','linestyle','--');
lg = title('Scattering angstrom exponent'); set(lg,'interp','none')
ylabel('unitless exponent')
xlabel('day of year (Jan. 1 2006 = 1)');
ax(fig).sub(5) = subplot(4,2,2);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.',...
   serial2doy(aip_1h.time(dust)), aip_1h.Bap_B_3W_10um(dust),'k.');
lg = title('Aerosol absorption coefficient, 10 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(6) = subplot(4,2,4);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.',...
   serial2doy(aip_1h.time(dust)), aip_1h.Bap_B_3W_1um(dust),'k.');
lg = title('Aerosol absorption coefficient, 1 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
% legend('Blue','Green','Red')
ax(fig).sub(7) = subplot(4,2,6);
plot(serial2doy(aip_1h.time), aip_1h.subfrac_Ba_B,'-b.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Ba_G,'-g.',...
   serial2doy(aip_1h.time), aip_1h.subfrac_Ba_R,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.subfrac_Ba_B(dust),'k.');
lg = title('Submicron absorption fraction'); set(lg,'interp','none');
ylabel('unitless ratio')
% legend('Blue','Green','Red')
ax(fig).sub(8) = subplot(4,2,8);
plot(serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_1um,'-r.', ...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_G_10um,'-bx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_B_R_10um,'-gx',...
   serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_10um,'-rx',...
   serial2doy(aip_1h.time(dust)), aip_1h.Ang_Ba_B_G_1um(dust),'k.',...
   serial2doy(aip_1h.time(dust)), aip_1h.Ang_Ba_B_G_10um(dust),'kx');
lg = title('Absorption angstrom exponents'); set(lg,'interp','none')
ylabel('unitless exponent');
xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')

%% Single-scattering albedo at both size cuts, 3x2

fig = figure;
ax(fig).sub(1) = subplot(3,2,1);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.', ...
   serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_10um(dust),'k.');
lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(2) = subplot(3,2,3);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.Bap_B_3W_10um(dust),'k.')
lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(3) = subplot(3,2,5);
plot(serial2doy(aip_1h.time), aip_1h.w_B_10um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.w_G_10um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.w_R_10um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.w_B_10um(dust),'k.');
ln = line([xlim],[w_G_10um,w_G_10um]);
set(ln,'color','m','linestyle','--');

lg = title('Single scattering albedo, 10 um size cut'); set(lg,'interp','none');
xlabel('day of year (Jan. 1 2006 = 1)');
ylabel('unitless ratio')
ax(fig).sub(4) = subplot(3,2,2);
plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_1um(dust),'k.');
lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
ylabel('1/Mm');
legend('Blue','Green','Red')
ax(fig).sub(5) = subplot(3,2,4);
plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
   serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.Bap_R_3W_1um(dust),'k.')
lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none');
ylabel('1/Mm');
ax(fig).sub(6) = subplot(3,2,6);
plot(serial2doy(aip_1h.time), aip_1h.w_B_1um,'-b.',...
   serial2doy(aip_1h.time), aip_1h.w_G_1um,'-g.',...
      serial2doy(aip_1h.time), aip_1h.w_R_1um,'-r.',...
serial2doy(aip_1h.time(dust)), aip_1h.w_B_1um(dust),'k.');
lg = title('Single scattering albedo, 1 um size cut'); set(lg,'interp','none')
ylabel('unitless ratio')
xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
%


linkaxes([ax(1).sub(:); ax(2).sub(:)],'x')
%
