function cals = mfrcal_ts(indir)
if ~exist('indir','var')
   
indir = uigetdir;
   indir = [indir,filesep];
end
files = dir([indir,filesep,'*mfr*.cdf']);
cals = get_mfr_cals(ancload([indir,files(1).name]));   %
%%
for f = 2:length(files)
   disp(['Read ',num2str(f-1),' of ',num2str(length(files)),' files.']);
cals = anccat(cals,get_mfr_cals(ancload([indir,files(f).name])));
end
ancsave(cals);
%%
figure; plot(serial2doy(cals.time), ...
   [cals.vars.Io_filter1.data;...
   cals.vars.Io_filter2.data;...
   cals.vars.Io_filter3.data;...
   cals.vars.Io_filter4.data;...
   cals.vars.Io_filter5.data],'o'); 
title('Nominal cals (dots) and I_os (circles)');
legend('filter1','filter2','filter3','filter4','filter5')
hold('on');
plot(serial2doy(cals.time), [cals.vars.nominal_calibration_factor_filter1.data;...
   cals.vars.nominal_calibration_factor_filter2.data;...
   cals.vars.nominal_calibration_factor_filter3.data;...
   cals.vars.nominal_calibration_factor_filter4.data;...
   cals.vars.nominal_calibration_factor_filter5.data],'.')
hold('off');

%%
