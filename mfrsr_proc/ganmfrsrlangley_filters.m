% We've created two bundled netcdf files combining all the operationally
% produced mfrsrlang files.  There was an inconsistency on Jan 3 2011
% forcing us to have two bundled files rather than one.  No matter...

% Load the first bundled file ganmfrsrlangleyM1.c1.20110924.021740.cdf
ganlang1 = ancload(getfullname_('*.cdf','ganlang','select Gan Langley file'));

% load the second bundled file ganmfrsrlangleyM1.c1.20120103.023600
ganlang2 = ancload(getfullname_('*.cdf','ganlang','select Gan Langley file'));
%%
% Screen the data for values < 0 (includes "missing value" = -9999 and
% other bad points
good1 = ganlang1.vars.michalsky_solar_constant_sdist_filter2.data>0;
good2 = ganlang2.vars.michalsky_solar_constant_sdist_filter2.data>0;

% Plot both data sets together...
figure; plot(serial2doys([ganlang1.time(good1),ganlang2.time(good2)]),...
    [ganlang1.vars.michalsky_solar_constant_sdist_filter2.data(good1), ...
    ganlang2.vars.michalsky_solar_constant_sdist_filter2.data(good2)], 'o');
xlabel('time [days of year after Jan 1 2010]')
ylabel('Io');
title({'Io values for filter 2, ganmfrsrlangleyM1.c1'})

%%
savefig

%%
% Next step is to filter the good Io values with the interquartile filter
% IQF and generate a smoothed time series of Io values for each filter.
% Then we provide these Io values to Annette so she can re-run MFRSR AOD
% for Gan.