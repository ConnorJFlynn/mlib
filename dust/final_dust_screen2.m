function   aip_1h = final_dust_screen(aip_1h);

% %Generate surrogate of Bsp from vis10.
% NaNs_1h =
% isNaN(aip_1h.pwd_avg_vis_10_min)|(aip_1h.pwd_avg_vis_10_min<=0)|...
%    isNaN(aip_1h.Bsp_G_Dry_10um)|(aip_1h.Bsp_G_Dry_10um<200);
% %%
% [P_1h,S_1h,MU_1h] = polyfit(1./aip_1h.pwd_avg_vis_10_min(~NaNs_1h),aip_1h.Bsp_G_Dry_10um(~NaNs_1h),1);
% 
% Bsp_G_10um_vis = polyval(P_1h, 1./aip_1h.pwd_avg_vis_10_min, [],MU_1h);
% NaNs = (Bsp_G_10um_vis>5000)|isNaN(Bsp_G_10um_vis);
% Bsp_G_10um_vis(NaNs) = NaN;
% figure; plot(1./aip_1h.pwd_avg_vis_10_min(~NaNs_1h), aip_1h.Bsp_G_Dry_10um(~NaNs_1h), 'b.',...
%    1./aip_1h.pwd_avg_vis_10_min, Bsp_G_10um_vis, 'b');
% v = axis;

% Apply tests that define metric.
Bsp_G_10_0 = 450; %gte test1
Bsp_G_10 = 200; %gte test1
Ang_Bs_BG_10 = .5; %lte test2
Ang_Bs_BG_1 = 1;  %lte test 3
% subfrac_Ba_R = .5; %lte
% Ang_Ba_GR_1 = 2; %gte
subfrac_Bs_G = 0.25; %lte test 4
subfrac_Bs_G2 = 0.6; %lte test 5 , with below is test 6
w_G_10um = .89; % gte test5, with above is test 6
test0  = true(size(aip_1h.time));
test1 = true(size(aip_1h.time));
test2 = test1; test3 = test1; test4 = test1; test5 = test1; test6= test1;

test0 = (aip_1h.Bsp_G_Dry_10um > Bsp_G_10_0)|(aip_1h.Bsp_G_10um_vis >Bsp_G_10_0./3 );
test1 = (aip_1h.Bsp_G_Dry_10um > Bsp_G_10);
test2 = (aip_1h.Ang_Bs_B_G_10um<Ang_Bs_BG_10) ;
NaNs = isNaN(aip_1h.Ang_Bs_G_R_1um);
test3(~NaNs) = (aip_1h.Ang_Bs_B_G_1um(~NaNs)<Ang_Bs_BG_1) ;
NaNs = isNaN(aip_1h.subfrac_Bs_G)|isNaN(aip_1h.w_G_10um);
test4(~NaNs) = (aip_1h.subfrac_Bs_G(~NaNs)<subfrac_Bs_G);
test5(~NaNs) = ((aip_1h.subfrac_Bs_G(~NaNs)<subfrac_Bs_G2)&(aip_1h.w_G_10um(~NaNs)>w_G_10um));
test6(~NaNs) = test4(~NaNs) | test5(~NaNs);
dust = test0 | test1 & test2 & test3  & test6;

fig = figure; plot(serial2doy(aip_1h.time), [test1, 2*test2, 3*test3, 4*test4, 5*test5, 6*test6, 10*dust], '.')
pause(.1);ax(fig).sub = gca;pause(.1);

windowSize = 3;
dust = filter(ones(1,windowSize)/windowSize,1,dust)==1;
sum(dust)
dust_days = (unique(serial2doy(floor(aip_1h.time(dust)))));
length(dust_days)
dust = filter(ones(1,windowSize)/windowSize,1,dust)>.2;
sum(dust)
dust_days = (unique(serial2doy(floor(aip_1h.time(dust)))));
length(dust_days)

for d = 1:length(dust_days);
dust = dust|(floor(serial2doy(aip_1h.time))==dust_days(d));
end
sum(dust)
dust_days = (unique(serial2doy(floor(aip_1h.time(dust)))));
length(dust_days)
length(dust_days(diff2(dust_days)>1))
aip_1h.dust = dust;
% plot the results.
%% Bsp (1um 10um), Bap (1um 10um), Ang, and submicron ratios 4x2

fig = figure;
mask = double(dust);
NaNs = (mask ==0);
mask(NaNs) = NaN;
mask(dust==1) = dust(dust==1);
subplot(3,1,1);
 plot(serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_Dry_10um,'-k.', ...
    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'g.',...
 serial2doy(aip_1h.time), aip_1h.Bsp_G_10um_vis,'r.',...
 serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_Dry_10um,'-k.', ...
serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_10um_vis,'-k.');
legend('dust','Bsp G 10 micron')
lg = title('Dust Events Over the Entire Deployment.'); set(lg,'interp','none');
xlim([0,125]);
xlabel('days of year, dry season #1')
ylabel('1/Mm');
subplot(3,1,2);
 plot(serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'g.',...
      serial2doy(aip_1h.time), aip_1h.Bsp_G_10um_vis,'r.',...
serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_Dry_10um,'-k.', ...
serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_10um_vis,'-k.');
legend('from AOS','from VIS')
ylabel('1/Mm');
xlim([125,302]);
xlabel('days of year, wet season')
subplot(3,1,3);
 plot(serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'g.',...
      serial2doy(aip_1h.time), aip_1h.Bsp_G_10um_vis,'r.',...
serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_Dry_10um,'-k.', ...
serial2doy(aip_1h.time), mask.*aip_1h.Bsp_G_10um_vis,'-k.');
ylabel('1/Mm');
xlim([302,365]);
xlabel('days of year, dry season #2')
% 
% ax(fig).sub(2) = subplot(4,1,2);
% plot(serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_1um,'-g.',...
%    serial2doy(aip_1h.time), aip_1h.Ang_Bs_B_G_10um,'-b.',...
% serial2doy(aip_1h.time(dust)), aip_1h.Ang_Bs_B_G_1um(dust),'k.',...
% serial2doy(aip_1h.time(dust)), aip_1h.Ang_Bs_B_G_10um(dust),'k.');
% ln = line([xlim],[Ang_Bs_BG_10,Ang_Bs_BG_10]); 
% set(ln,'color','m','linestyle','--');
% ln = line([xlim],[Ang_Bs_BG_1,Ang_Bs_BG_1]);
% set(ln,'color','b','linestyle','--');
% lg = title('Scattering angstrom exponent'); set(lg,'interp','none')
% ylabel('unitless exponent')
% % plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_1um(dust),'k.');
% % lg = title('Scattering coefficient, 1 um size cut'); set(lg,'interp','none')
% % ylabel('1/Mm');
% 
% ax(fig).sub(3) = subplot(4,1,3);
% plot(serial2doy(aip_1h.time), aip_1h.subfrac_Bs_G,'-g.',...
%    serial2doy(aip_1h.time(dust)), aip_1h.subfrac_Bs_G(dust),'k.');
% ln = line([xlim],[subfrac_Bs_G,subfrac_Bs_G]);
% set(ln,'color','m','linestyle','--');
% ln = line([xlim],[subfrac_Bs_G2,subfrac_Bs_G2]);
% set(ln,'color','g','linestyle','--');
% lg = title('Submicron scattering fraction'); set(lg,'interp','none')
% ylabel('unitless ratio')
% 
% ax(fig).sub(4) = subplot(4,1,4);
% plot(serial2doy(aip_1h.time), aip_1h.w_B_10um,'-b.',...
%    serial2doy(aip_1h.time), aip_1h.w_G_10um,'-g.',...
%       serial2doy(aip_1h.time), aip_1h.w_R_10um,'-r.',...
% serial2doy(aip_1h.time(dust)), aip_1h.w_B_10um(dust),'k.');
% ln = line([xlim],[w_G_10um,w_G_10um]);
% set(ln,'color','m','linestyle','--');
% title('Single-scattering albedo');
% xlabel('day of year (Jan. 1 2006 = 1)');
% 
% % ax(fig).sub(5) = subplot(4,2,2);
% % plot(   serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.',...
% %    serial2doy(aip_1h.time(dust)), aip_1h.Bap_G_3W_10um(dust),'-k.');
% % lg = title('Aerosol absorption coefficient, 10 um size cut'); set(lg,'interp','none');
% % ylabel('1/Mm');
% % 
% % ax(fig).sub(6) = subplot(4,2,4);
% % plot( serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.',...
% %    serial2doy(aip_1h.time(dust)), aip_1h.Bap_G_3W_1um(dust),'k.');
% % lg = title('Aerosol absorption coefficient, 1 um size cut'); set(lg,'interp','none');
% % ylabel('1/Mm');
% % % legend('Blue','Green','Red')
% % 
% % ax(fig).sub(7) = subplot(4,2,6);
% % plot(serial2doy(aip_1h.time), aip_1h.subfrac_Ba_R,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.subfrac_Ba_R(dust),'k.');
% % lg = title('Submicron absorption fraction'); set(lg,'interp','none');
% % ylabel('unitless ratio')
% % % legend('Blue','Green','Red')
% % 
% % ax(fig).sub(8) = subplot(4,2,8);
% % plot(   serial2doy(aip_1h.time), aip_1h.Ang_Ba_G_R_1um,'-r.', ...
% %    serial2doy(aip_1h.time(dust)), aip_1h.Ang_Ba_G_R_1um(dust),'k.');
% % lg = title('Absorption angstrom exponents'); set(lg,'interp','none')
% % ylabel('unitless exponent');
% % xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% % % ln = line([xlim],[Ang_Ba_GR_1,Ang_Ba_GR_1]);
% % set(ln,'color','m','linestyle','--');
% 
% %% Single-scattering albedo at both size cuts, 3x2
% % 
% % fig = figure;
% % ax(fig).sub(1) = subplot(3,2,1);
% % plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_10um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_10um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_10um,'-r.', ...
% %    serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_10um(dust),'k.');
% % lg = title('Total scattering coefficient, 10 um size cut'); set(lg,'interp','none')
% % ylabel('1/Mm');
% % legend('Blue','Green','Red')
% % ax(fig).sub(2) = subplot(3,2,3);
% % plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_10um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_10um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_10um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.Bap_B_3W_10um(dust),'k.')
% % lg = title('Absorption coefficient, 10 um size cut'); set(lg,'interp','none');
% % ylabel('1/Mm');
% % ax(fig).sub(3) = subplot(3,2,5);
% % plot(serial2doy(aip_1h.time), aip_1h.w_B_10um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.w_G_10um,'-g.',...
% %       serial2doy(aip_1h.time), aip_1h.w_R_10um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.w_B_10um(dust),'k.');
% % ln = line([xlim],[w_G_10um,w_G_10um]);
% % set(ln,'color','m','linestyle','--');
% % 
% % lg = title('Single scattering albedo, 10 um size cut'); set(lg,'interp','none');
% % xlabel('day of year (Jan. 1 2006 = 1)');
% % ylabel('unitless ratio')
% % ax(fig).sub(4) = subplot(3,2,2);
% % plot(serial2doy(aip_1h.time), aip_1h.Bsp_B_Dry_1um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_G_Dry_1um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bsp_R_Dry_1um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.Bsp_B_Dry_1um(dust),'k.');
% % lg = title('Total scattering coefficient, 1 um size cut'); set(lg,'interp','none')
% % ylabel('1/Mm');
% % legend('Blue','Green','Red')
% % ax(fig).sub(5) = subplot(3,2,4);
% % plot(serial2doy(aip_1h.time), aip_1h.Bap_B_3W_1um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_G_3W_1um,'-g.',...
% %    serial2doy(aip_1h.time), aip_1h.Bap_R_3W_1um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.Bap_R_3W_1um(dust),'k.')
% % lg = title('Absorption coefficient, 1 um size cut'); set(lg,'interp','none');
% % ylabel('1/Mm');
% % ax(fig).sub(6) = subplot(3,2,6);
% % plot(serial2doy(aip_1h.time), aip_1h.w_B_1um,'-b.',...
% %    serial2doy(aip_1h.time), aip_1h.w_G_1um,'-g.',...
% %       serial2doy(aip_1h.time), aip_1h.w_R_1um,'-r.',...
% % serial2doy(aip_1h.time(dust)), aip_1h.w_B_1um(dust),'k.');
% % lg = title('Single scattering albedo, 1 um size cut'); set(lg,'interp','none')
% % ylabel('unitless ratio')
% % xlabel('day of year (Jan. 1 2006 = 1)'); % linkaxes(ax(fig).sub,'x')
% % %
% % 
% % linkaxes([ax(2).sub(:)],'x');
% % linkaxes([ax(1).sub(:); ax(2).sub(:)],'x')
% %
