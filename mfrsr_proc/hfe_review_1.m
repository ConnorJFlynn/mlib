% %%
% Canabalizing fkb_review_1
% Checking out HFE MFRSR results
% First read in global Langley with all Ios.  
% Run IQF for small variety of lsfitsd values.
% Read in daily Ios from mfrsraod files.
% Compare to smoothed Ios from IQF.
% Make monthly bundles and look at with plot_qc ?
%%
lang = ancload('C:\case_studies\hfe\hfemfrsrlangleyM1.c1\hfemfrsrlangleyM1.c1.20080529.225120.cdf');

%%
lte_030 = (lang.vars.michalsky_standard_deviation_filter2.data <= 0.030)&...
   (lang.vars.michalsky_standard_deviation_filter2.data > 0);
lte_024 = (lang.vars.michalsky_standard_deviation_filter2.data <= 0.024)&...
   (lang.vars.michalsky_standard_deviation_filter2.data > 0);
lte_018 = (lang.vars.michalsky_standard_deviation_filter2.data <= 0.018)&...
   (lang.vars.michalsky_standard_deviation_filter2.data > 0);
lte_012 = (lang.vars.michalsky_standard_deviation_filter2.data <= 0.012)&...
   (lang.vars.michalsky_standard_deviation_filter2.data > 0);
lte_006 = (lang.vars.michalsky_standard_deviation_filter2.data <= 0.006)&...
   (lang.vars.michalsky_standard_deviation_filter2.data > 0);


figure; scatter(lang.time(lte_030)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_030), 32,...
   lang.vars.michalsky_standard_deviation_filter2.data(lte_030),'filled'); colorbar
%%
hold('on');
biq_lte_030 = IQF_lang(lang.time(lte_030)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_030),45);
biq_lte_024 = IQF_lang(lang.time(lte_024)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_024),45);
biq_lte_018 = IQF_lang(lang.time(lte_018)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_018),45);
biq_lte_012 = IQF_lang(lang.time(lte_012)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_012),45);
biq_lte_006 = IQF_lang(lang.time(lte_006)-lang.time(1), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_006),45);
%%
 figure; 
plot(lang.time(lte_030)-lang.time(1),biq_lte_030,'.-',lang.time(lte_024)-lang.time(1),biq_lte_024,'.-',...
   lang.time(lte_018)-lang.time(1),biq_lte_018,'.-',lang.time(lte_012)-lang.time(1),biq_lte_012,'.-',...
   lang.time(lte_006)-lang.time(1),biq_lte_006,'.-'); 
legend('030','024','018','012','006')

%%

new_dir = 'C:\case_studies\fkb\fkbmfrsraod1michM1.c1\';
news = dir([new_dir, '*.cdf']);
x = 0;
for f = 1:length(news);
   disp(['Reading ',num2str(f), ' of ',num2str(length(news))]);
   mfr = ancload([new_dir, news(f).name]);
   if length(mfr.time)>1
   x = x + 1;
   new_Io.time(x) = mfr.time(1);
   new_Io.filter1(x) = mfr.vars.Io_filter1.data;
   new_Io.filter2(x) = mfr.vars.Io_filter2.data;
   new_Io.filter3(x) = mfr.vars.Io_filter3.data;
   new_Io.filter4(x) = mfr.vars.Io_filter4.data;
   new_Io.filter5(x) = mfr.vars.Io_filter5.data;
   end
end
%
new_Io.filter1_ = new_Io.filter1 / mean(new_Io.filter1);
new_Io.filter2_ = new_Io.filter2 / mean(new_Io.filter2);
new_Io.filter3_ = new_Io.filter3 / mean(new_Io.filter3);
new_Io.filter4_ = new_Io.filter4 / mean(new_Io.filter4);
new_Io.filter5_ = new_Io.filter5 / mean(new_Io.filter5);

%%
save('C:\case_studies\fkb\fkbmfrsraod1michM1.c1\daily_Io.mat' ,'new_Io' )
%%
figure; plot(serial2doy(new_Io.time), [new_Io.filter1_; new_Io.filter2_; new_Io.filter3_; ...
   new_Io.filter4_; new_Io.filter5_],'.');
legend('415','500','615','673','870');
title('New Io values, normalized to mean.')
xlabel('day of year')
v = axis;
%%
figure; plot(lang.time(lte_018)-lang.time(1),biq_lte_018,'b.-', lang.time(lte_006)-lang.time(1),biq_lte_006,'r.-',new_Io.time - lang.time(1), new_Io.filter2, 'ro')

%%
% Plot time series of number of Io within window centered on current day
% plot time serieds of pct_dev of Io found within this window