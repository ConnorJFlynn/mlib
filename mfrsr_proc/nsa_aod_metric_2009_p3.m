% %% 
% % make subsettted abe without height fields
%  abe_pname = ['C:\case_studies\2009_metric\nsaaerosolbe1turnC1.c1\no_mfrsr_with_fixes\'];
%  abes = dir([abe_pname,'*.cdf']);
%  for in = 1:length(abes)
%  abe = ancload([abe_pname,abes(in).name]);
% 
%  abe.dims = rmfield(abe.dims, 'height');
%  fld = fieldnames(abe.vars);
%  for f = 1:length(fld)
%     if any(strcmp(abe.vars.(char(fld{f})).dims,'height'))
%        abe.vars = rmfield(abe.vars,fld{f});
%     elseif any(strfind(fld{f},'mfrsr'))
%        abe.vars = rmfield(abe.vars,fld{f});
%         elseif any(strfind(fld{f},'_rl'))
%        abe.vars = rmfield(abe.vars,fld{f});
%     end
%  end
%  abe.vars = rmfield(abe.vars, 'be_aod_355');
%  [pname, fname, ext] = fileparts(abe.fname);
%  pname = [pname, filesep,'abe_sub',filesep];
%  abe.fname = [pname,fname,ext];
%  abe = anccheck(abe);
%  abe.clobber = true;
%  abe.quiet = true;
%  disp(['Saving ', abe.fname]);
%  ancsave(abe);    
%  end
%  
 % load screened nimfr, mfrsr, and anet files
% Generate overlay plot with all three and then regression plots of xmfrx
% vs anet.

% Load abe file (bundled into a single year

%%
nimfr_pname = 'C:\case_studies\2009_metric\nsanimfraod1michC1.c1\T_screen\screened\never\';
nimfr_fname = 'nsanimfraod1michC1.c1.20080311.000020.cdf';
% mfrsr_pname = 'C:\case_studies\2009_metric\nsamfrsraod1michC1.c1\T_screen\screened\never\';
% mfrsr_fname = 'nsamfrsraod1michC1.c1.20080311.193720.cdf';
anet_pname = 'C:\case_studies\2009_metric\aeronet\';
anet_fname = '070101_091231_Barrow.lev20';
abe_pname = 'C:\case_studies\2009_metric\nsaaerosolbe1turnC1.c1\no_mfrsr_with_fixes\abe_sub\never\';
abe_fname = 'nsaaerosolbe1turnC1.c1.20080101.000000.cdf';
nimfr = ancload([nimfr_pname, nimfr_fname]);
nimfr = ancsift(nimfr,nimfr.dims.time, nimfr.vars.aerosol_optical_depth_filter2.data>0);
% mfrsr = ancload([mfrsr_pname, mfrsr_fname]);
anet = read_cimel_2p0([anet_pname, anet_fname]);
%%
abe = ancload([abe_pname, abe_fname]);
vars = fieldnames(abe.vars);
for v = 1:length(vars)
   NaNs = abe.vars.(char(vars{v})).data<-500;
    abe.vars.(char(vars{v})).data(NaNs) = NaN;
end
too_high = abe.vars.be_aod_500.data>0.4;
abe.vars.be_aod_500.data(too_high) = NaN;
abe_coords = ancload(['C:\case_studies\2009_metric\nsaaerosolbe1turnC1.c1\nsaaerosolbe1turnC1.c1.20080602.000000.cdf']);
abe.vars.lat.data = abe_coords.vars.lat.data;
abe.vars.lon.data = abe_coords.vars.lon.data;
abe.vars.alt.data = abe_coords.vars.alt.data;

% abe.vars.solar_zenith_angle.data = 180.*abe.vars.solar_zenith_angle.data./pi;
% abe = ancsift(abe, abe.dims.time, abe.vars.be_aod_500.data>0);
%
%%
plots_ppt;
figure; plot(serial2doy(abe.time), abe.vars.be_aod_500.data, 'bo',...
   serial2doy(nimfr.time), nimfr.vars.aerosol_optical_depth_filter2.data, 'gx');
% ,...
%    serial2doy(anet.time), anet.aod_500,'kx');
legend('ABE','NIMFR');
% legend('ABE','NIMFR','AERONET');
title('Time series of Aerosol Optical Depth at 500 nm, Barrow 2008');
xlabel('day of year (Feb 19 = 50, Oct 26 = 300)');
ylabel('AOD (unitless)');
ylim([0,.42]);
xlim([50,300]);
zoom('on')
k = menu('Resize plot and press okay when done','ok');
% saveas(gcf,[abe_pname,filesep,'aod_nimfr_abe.png']);
% saveas(gcf,[abe_pname,filesep,'aod_nimfr_abe.fig']);
% saveas(gcf,[abe_pname,filesep,'aod_nimfr_abe.emf']);

%%
[ainb, bina] = nearest(anet.time,nimfr.time);
[ainc, cina] = nearest(anet.time,abe.time);
%%

figure; plot(serial2doy(abe.time(cina)), abe.vars.be_aod_500.data(cina), 'bo',...
serial2doy(nimfr.time(bina)), nimfr.vars.aerosol_optical_depth_filter2.data(bina), 'gx',...
   serial2doy(anet.time(unique([ainb;ainc]))), anet.aod_500(unique([ainb;ainc])),'k+');
legend('ABE','NIMFR','AERONET');
title('ABE and NIMFR AOD coincident with AERONET, Barrow 2008');
xlabel('day of year (Feb 19 = 50, Oct 26 = 300)');
ylabel('AOD (unitless)');
xlim([50,300]);
zoom('on')
%
k = menu('Resize plot and press okay when done','ok');
% saveas(gcf,[abe_pname,filesep,'aod_with_aeronet.png']);
% saveas(gcf,[abe_pname,filesep,'aod_with_aeronet.fig']);
% saveas(gcf,[abe_pname,filesep,'aod_with_aeronet.emf']);
%%
[P_nimfr,S_nimfr] = polyfit(anet.aod_500(ainb)',nimfr.vars.aerosol_optical_depth_filter2.data(bina),1);
nimfr_stats = fit_stat(anet.aod_500(ainb)',nimfr.vars.aerosol_optical_depth_filter2.data(bina),P_nimfr,S_nimfr);

nimfr_txt = {['N = ', num2str(nimfr_stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',nimfr_stats.bias)], ...
    ['slope = ',sprintf('%1.3g',P_nimfr(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P_nimfr(2))],...
    ['R^2 = ',sprintf('%1.3f',nimfr_stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',nimfr_stats.RMSE)]};


figure; plot(anet.aod_500(ainb),nimfr.vars.aerosol_optical_depth_filter2.data(bina),'bo',[0,1],[0,1],'k:',...
   anet.aod_500(ainb), polyval(P_nimfr,anet.aod_500(ainb)),'r-')
xlabel('AERONET aod 500 nm [unitless]')
ylabel('NIMFR aod 500 nm [unitless]');
title('AERONET vs NIMFR');
xlim([0,.6]); ylim([0,.6]);axis('square');
 nimfr_gt = gtext(nimfr_txt);
set(nimfr_gt,'fontsize',14);
set(nimfr_gt,'units','normalized');

%%
k = menu('Resize plot and press okay when done','ok');
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.png']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.fig']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.emf']);
%%


anet_aod = anet.aod_500(ainc);
good_abe = anet_aod>0 & anet_aod<.3 & ~isNaN(anet_aod)&~isNaN(abe.vars.be_aod_500.data(cina))';
% good_ang = anet_aod>0 & anet.ang_440_870(ainc)>0;
%

[P_abe,S_abe] = polyfit(anet.aod_500(ainc(good_abe))',abe.vars.be_aod_500.data(cina(good_abe)),1);
stats_abe = fit_stat(anet.aod_500(ainc(good_abe))',abe.vars.be_aod_500.data(cina(good_abe)),P_abe,S_abe);

txt_abe = {['N = ', num2str(stats_abe.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats_abe.bias)], ...
    ['slope = ',sprintf('%1.3g',P_abe(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P_abe(2))],...
    ['R^2 = ',sprintf('%1.3f',stats_abe.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats_abe.RMSE)]};


figure; plot(anet.aod_500(ainc(good_abe)),abe.vars.be_aod_500.data(cina(good_abe)),'bo',[0,1],[0,1],'k:',...
   anet.aod_500(ainc), polyval(P_abe,anet.aod_500(ainc)),'r-');
xlabel('AERONET aod 500 nm [unitless]')
ylabel('ABE aod 500 nm [unitless]');
title('AERONET vs ABE');
xlim([0,.6]); ylim([0,.6]);axis('square');
 gt_abe = gtext(txt_abe);
set(gt_abe,'fontsize',14)
set(gt_abe,'units','normalized');
%%
% k = menu('Resize plot and press okay when done','ok');
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.png']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.fig']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.emf']);


% Now identify only those points where we have Cimel and ABE but not NIMFR
% Then look at regression
[ainc_notb,notc] = setdiff(ainc,ainb);
datestr(anet.time(ainc_notb(1)));
datestr(abe.time(cina(notc(1))));
anet_aod = anet.aod_500(ainc_notb);
good_abe = anet_aod>0 & anet_aod<.3 & ~isNaN(anet_aod)&~isNaN(abe.vars.be_aod_500.data(cina(notc)))';
% good_ang = anet_aod>0 & anet.ang_440_870(ainc)>0;
%

[P_abe,S_abe] = polyfit(anet_aod(good_abe)',abe.vars.be_aod_500.data(cina(notc(good_abe))),1);
stats_abe = fit_stat(anet_aod(good_abe)',abe.vars.be_aod_500.data(cina(notc(good_abe))),P_abe,S_abe);

txt_abe = {['N = ', num2str(stats_abe.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats_abe.bias)], ...
    ['slope = ',sprintf('%1.3g',P_abe(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P_abe(2))],...
    ['R^2 = ',sprintf('%1.3f',stats_abe.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats_abe.RMSE)]};


figure; plot(anet_aod(good_abe)',abe.vars.be_aod_500.data(cina(notc(good_abe))),'bo',[0,1],[0,1],'k:',...
   anet.aod_500(ainc), polyval(P_abe,anet.aod_500(ainc)),'r-');
xlabel('AERONET aod 500 nm [unitless]')
ylabel('ABE aod 500 nm [unitless]');
title('AERONET vs ABE');
xlim([0,.6]); ylim([0,.6]);axis('square');
 gt_abe = gtext(txt_abe);
set(gt_abe,'fontsize',14)
set(gt_abe,'units','normalized');
%%
k = menu('Resize plot and press okay when done','ok');
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.png']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.fig']);
% saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.emf']);


%%
[pname, fname, ext] = fileparts(abe.fname);
abe.fname = [pname, filesep,'aod_metric_2009',ext];
abe.vars = rmfield(abe.vars, 'effective_height');
% abe = anccheck(abe); abe.clobber = true; abe.quiet = true; ancsave(abe);
abe_ = abe;
abe_.vars = rmfield(abe_.vars, 'rh_source');
abe_.vars = rmfield(abe_.vars, 'aod_source_flag');
abe_.vars = rmfield(abe_.vars, 'effect_ht_flag');

abe_hour = ancdownsample(abe_, 6);
abe_hour.fname = [pname, filesep,'hourly_aod_metric_2009',ext];
% abe_hour = anccheck(abe_hour); abe_hour.clobber = true; abe_hour.quiet = true; ancsave(abe_hour);

abe_day = ancdownsample(abe_hour, 24);
abe_day.vars = rmfield(abe_day.vars,'solar_zenith_angle');
abe_day.fname = [pname, filesep,'daily_aod_metric_2009',ext];
% abe_day = anccheck(abe_day); abe_day.clobber = true; abe_day.quiet = true; ancsave(abe_day);
