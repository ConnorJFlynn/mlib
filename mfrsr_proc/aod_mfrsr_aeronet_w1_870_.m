% NSA AOD metric, part 3

% load screened nimfr, mfrsr, and anet files
% Generate overlay plot with all three and then regression plots of xmfrx
% vs anet.

% Load abe file (bundled into a single year
% mfrsr = ancload([mfrsr_pname, mfrsr_fname]);
%%
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120716.000000.cdf';
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120716.000000.cdf';

%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2012\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120716.000000.cdf';
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2012_winter\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20121201.000000.cdf';
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2012_fall\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120901.000000.cdf';
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2012_summer\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120716.000000.cdf';

%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2013_01\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130101.000000.cdf';
%%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2013_03\catdir\';
%%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130301.000000.cdf';
%mfrsr_pname = 'X:\b_CIP\x_PVC\mfrsr_2013\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130101.000000.cdf';

%mfrsr_pname = 'X:\b_CIP\x_PVC_v02\mfrsr_2012\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120801.000000.cdf';
%anet_pname = 'X:\b_CIP\x_PVC\120101_131231_ARM_Highlands_MA\';
%anet_fname = '120101_131231_ARM_Highlands_MA.lev20';

%mfrsr_pname = 'X:\b_CIP\x_TWP_v03\twpmfrsraod1michC3.c1_2012\';
%mfrsr_pname = 'X:\b_CIP\x_TWP_v03a\twpmfrsraod1michC3.c1\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20120517.000000.cdf';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20120518.000000.cdf';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20120519.000000.cdf';
%anet_pname = 'X:\b_CIP\x_TWP_v03\120101_121231_ARM_Darwin\';
%anet_fname = '120101_121231_ARM_Darwin.lev20';


%mfrsr_pname = 'X:\b_CIP\x_PVC_v03\pvcmfrsraod1michM1.c1\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130215.000000.cdf';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120809.000000.cdf';

%anet_pname = 'X:\b_CIP\x_PVC\120101_131231_ARM_Highlands_MA\';
%anet_fname = '120101_131231_ARM_Highlands_MA.lev20';

%mfrsr_pname = 'Y:\z_VAP_AOD_2014\PVC\2013\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130327.000000.cdf';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130326.000000.cdf';

%mfrsr_pname = 'Y:\z_VAP_AOD_2014\PVC\2012\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120830.000000.cdf';





%mfrsr_pname = 'Y:\z_VAP_AOD_2014\PVC\2013\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130101.000000.cdf';
%mfrsr_pname = 'Y:\z_VAP_AOD_2014\PVC\2012\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120716.000000.cdf';
%mfrsr_pname = 'U:\z_VAP_AOD_2014\PVC\z_2012_with_new_Io_\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20120709.135300.cdf';
%mfrsr_pname = 'U:\z_VAP_AOD_2014\PVC\z_2013_with_new_Io_\catdir\';
%mfrsr_fname = 'pvcmfrsraod1michM1.c1.20130106.000000.cdf';
%anet_pname = 'Y:\z_VAP_AOD_2014\120101_131231_ARM_Highlands_MA\';
%anet_fname = '120101_131231_ARM_Highlands_MA.lev20';



%mfrsr_pname = 'U:\z_VAP_AOD_2014\TWP\2010\catdir\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20100101.000000.cdf';
%mfrsr_pname = 'U:\z_VAP_AOD_2014\TWP\2011\catdir\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20110101.000000.cdf';
%mfrsr_pname = 'U:\z_VAP_AOD_2014\TWP\2012\catdir\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20120405.000000.cdf';
%mfrsr_pname = 'U:\z_VAP_AOD_2014\TWP\2013\catdir\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20130101.000000.cdf';
mfrsr_pname = 'U:\z_VAP_AOD_2014\TWP\2014\catdir\';
mfrsr_fname = 'twpmfrsraod1michC3.c1.20140101.000000.cdf';
anet_pname = 'U:\z_VAP_AOD_2014\TWP\100101_141231_ARM_Darwin\';
anet_fname = '100101_141231_ARM_Darwin.lev20';




%mfrsr_pname = 'Y:\z_VAP_AOD_2014\TWP\2014\catdir\';
%mfrsr_fname = 'twpmfrsraod1michC3.c1.20140101.000000.cdf';
%anet_pname = 'Y:\z_VAP_AOD_2014\100101_141231_ARM_Darwin\';
%anet_fname = '100101_141231_ARM_Darwin.lev20';


mfrsr = ancload([mfrsr_pname, mfrsr_fname]);
mfrsr = ancsift(mfrsr,mfrsr.dims.time, mfrsr.vars.aerosol_optical_depth_filter5.data>0);
%mfrsr = ancsift(mfrsr,mfrsr.dims.time, mfrsr.vars.aerosol_optical_depth_filter2.data>0);
%mfrsr = ancsift(mfrsr,mfrsr.dims.time, mfrsr.vars.aerosol_optical_depth_filter2.data<1);
%mfrsr = ancsift(mfrsr,mfrsr.dims.time, mfrsr.vars.aerosol_optical_depth_filter2.data<2);
anet = read_cimel_2p0([anet_pname, anet_fname]);
%%

%%
[ainb, bina] = nearest(anet.time,mfrsr.time);
%%

%figure; plot(serial2doy(mfrsr.time(bina)), mfrsr.vars.aerosol_optical_depth_filter2.data(bina), 'gx',...
%   serial2doy(anet.time(ainb)), anet.aod_500(ainb),'k+');
figure; plot(serial2doy(mfrsr.time(bina)), mfrsr.vars.aerosol_optical_depth_filter5.data(bina), 'gx',...
   serial2doy(anet.time(ainb)), anet.aod_870(ainb),'b+');
legend('MFRSR','AERONET');
hold('on')
plot(serial2doy(mfrsr.time), mfrsr.vars.aerosol_optical_depth_filter5.data, 'kx',...
   serial2doy(anet.time), anet.aod_870,'k+',...
   serial2doy(mfrsr.time(bina)), mfrsr.vars.aerosol_optical_depth_filter5.data(bina), 'gx',...
   serial2doy(anet.time(ainb)), anet.aod_870(ainb),'b+');
hold('off')
legend('MFRSR','AERONET');
title('MFRSR AOD coincident with AERONET, PVC 2012');
xlabel('day of year');
ylabel('AOD');
%xlim([50,300]);
xlim([0,300]);
zoom('on')
%
%%
%[P_mfrsr,S_mfrsr] = polyfit(anet.aod_500(ainb)',mfrsr.vars.aerosol_optical_depth_filter2.data(bina),1);
%mfrsr_stats = fit_stat(anet.aod_500(ainb)',mfrsr.vars.aerosol_optical_depth_filter2.data(bina),P_mfrsr,S_mfrsr);

[P_mfrsr,S_mfrsr] = polyfit(anet.aod_870(ainb)',mfrsr.vars.aerosol_optical_depth_filter5.data(bina),1);
mfrsr_stats = fit_stat(anet.aod_870(ainb)',mfrsr.vars.aerosol_optical_depth_filter5.data(bina),P_mfrsr,S_mfrsr);

mfrsr_txt = {['N = ', num2str(mfrsr_stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',mfrsr_stats.bias)], ...
    ['slope = ',sprintf('%1.3g',P_mfrsr(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P_mfrsr(2))],...
    ['R^2 = ',sprintf('%1.3f',mfrsr_stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',mfrsr_stats.RMSE)]};


%figure; plot(anet.aod_500(ainb),mfrsr.vars.aerosol_optical_depth_filter2.data(bina),'bo',[0,1],[0,1],'k:',anet.aod_500(ainb), polyval(P_mfrsr,anet.aod_500(ainb)),'r-')
%xlabel('AERONET AOD (500 nm)')
%ylabel('MFRSR AOD (500 nm)');
% Replace "plot" with "scatter"
figure; plot(anet.aod_870(ainb),mfrsr.vars.aerosol_optical_depth_filter5.data(bina),'bo',[0,1],[0,1],'k:',anet.aod_870(ainb), polyval(P_mfrsr,anet.aod_870(ainb)),'r-')
figure; scatter(anet.aod_870(ainb),mfrsr.vars.aerosol_optical_depth_filter5.data(bina),8,serial2doy(mfrsr.time(bina))); colorbar
caxis([0,365])
hold('on');
plot([0,1],[0,1],'k:',anet.aod_870(ainb), polyval(P_mfrsr,anet.aod_870(ainb)),'r-');
xlabel('AERONET AOD (870 nm)')
ylabel('MFRSR AOD (870 nm)');
title('AERONET AOD vs MFRSR AOD: PVC (2012)');
xlim([0,.6]); ylim([0,.6]);axis('square');

mfrsr_gt = gtext(mfrsr_txt);
set(mfrsr_gt,'fontsize',14);
set(mfrsr_gt,'units','normalized');

%%
%k = menu('Resize plot and press okay when done','ok');
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.png']);
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.fig']);
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_nimfr.emf']);
%%

%anet_aod = anet.aod_500(ainc);
%good_abe = anet_aod>0 & anet_aod<.3 & ~isNaN(anet_aod)&~isNaN(abe.vars.be_aod_500.data(cina))';
% good_ang = anet_aod>0 & anet.ang_440_870(ainc)>0; %
%

%[P_abe,S_abe] = polyfit(anet.aod_500(ainc(good_abe))',abe.vars.be_aod_500.data(cina(good_abe)),1);
%stats_abe = fit_stat(anet.aod_500(ainb)',nimfr.vars.aerosol_optical_depth_filter2.data(bina),P_abe,S_abe);

%txt_abe = {['N = ', num2str(stats_abe.N)],...
%    ['bias (y-x) =  ',sprintf('%1.1g',stats_abe.bias)], ...
%    ['slope = ',sprintf('%1.3g',P_abe(1))], ...
%    ['Y\_int = ', sprintf('%0.02g',P_abe(2))],...
%    ['R^2 = ',sprintf('%1.3f',stats_abe.R_sqrd)],...
%    ['RMSE = ',sprintf('%1.3f',stats_abe.RMSE)]};


%figure; plot(anet.aod_500(ainc(good_abe)),abe.vars.be_aod_500.data(cina(good_abe)),'bo',[0,1],[0,1],'k:',anet.aod_500(ainc), polyval(P_abe,anet.aod_500(ainc)),'r-');
%hold('off')
%xlabel('AERONET aod 500 nm [unitless]')
%ylabel('ABE aod 500 nm [unitless]');
%title('AERONET vs ABE');
%xlim([0,.6]); ylim([0,.6]);axis('square');
%gt_abe = gtext(txt_abe);
%set(gt_abe,'fontsize',14)
%set(gt_abe,'units','normalized');
%%
%k = menu('Resize plot and press okay when done','ok');
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.png']);
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.fig']);
%saveas(gcf,[abe_pname,filesep,'aeronet_vs_abe.emf']);
%%
%[pname, fname, ext] = fileparts(abe.fname);
%abe.fname = [pname, filesep,'aod_metric_2009',ext];
%abe.vars = rmfield(abe.vars, 'effective_height');
%abe = anccheck(abe); abe.clobber = true; abe.quiet = true; ancsave(abe);
%abe_ = abe;
%abe_.vars = rmfield(abe_.vars, 'rh_source');
%abe_.vars = rmfield(abe_.vars, 'aod_source_flag');
%abe_.vars = rmfield(abe_.vars, 'effect_ht_flag');

%abe_hour = ancdownsample(abe_, 6);
%abe_hour.fname = [pname, filesep,'hourly_aod_metric_2009',ext];
%abe_hour = anccheck(abe_hour); abe_hour.clobber = true; abe_hour.quiet = true; ancsave(abe_hour);

%abe_day = ancdownsample(abe_hour, 24);
%abe_day.vars = rmfield(abe_day.vars,'solar_zenith_angle');
%abe_day.fname = [pname, filesep,'daily_aod_metric_2009',ext];
%abe_day = anccheck(abe_day); abe_day.clobber = true; abe_day.quiet = true; ancsave(abe_day);
