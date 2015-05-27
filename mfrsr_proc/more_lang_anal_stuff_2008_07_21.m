%this block is for Barnard's Ios, raw and smoothed
barn_Io =  read_barnio;
barn_Io_smooth = read_barnio;
biq = IQF_lang(barn_Io.time, barn_Io.filter2_Vo,30);

% Load langley, see if I can replicate Mich bad flag based on fit std
%%

lang = ancload;
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


figure; scatter(lang.time(lte_030), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_030), 32,...
   lang.vars.michalsky_standard_deviation_filter2.data(lte_030),'filled'); colorbar
hold('on');
biq_lte_030 = IQF_lang(lang.time(lte_030), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_030),45);
biq_lte_024 = IQF_lang(lang.time(lte_024), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_024),45);
biq_lte_018 = IQF_lang(lang.time(lte_018), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_018),45);
biq_lte_012 = IQF_lang(lang.time(lte_012), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_012),45);
biq_lte_006 = IQF_lang(lang.time(lte_006), lang.vars.michalsky_solar_constant_sdist_filter2.data(lte_006),45);
%%
 figure; 
plot(lang.time(lte_030),biq_lte_030,'.',lang.time(lte_024),biq_lte_024,'.',...
   lang.time(lte_018),biq_lte_018,'.',lang.time(lte_012),biq_lte_012,'.',...
   lang.time(lte_006),biq_lte_006,'.'); 
legend('030','024','018','012','006')

%%

figure; plot(barn_Io.time-datenum(2006,1,1)+1,barn_Io.filter2_Vo,'r.',...
   barn_Io.time-datenum(2006,1,1)+1,(biq),'g.',...
   barn_Io_smooth.time - datenum(2006,1,1)+1, barn_Io_smooth.filter2_Vo,'bo', ...
   lang.time(lte_030)-datenum(2006,1,1)+1, biq_lte_030,'mo');
title('MFRSR Vo for filter2, relaxed constraints');
xlabel('day of year 2006')
ylabel('Arbitrary units')
%%


