% read aod and aip
% compare RH fields

aos = ancload(['C:\case_studies\abe\Feb2006_proc20100336\sgpnoaaaosC1.b0\sgpnoaaaosC1.b0.20060515.000000.cdf']);
aip = ancload(['C:\case_studies\abe\Feb2006_proc20100336\sgpaip1ogrenC1.c1\sgpaip1ogrenC1.c1.20060515.000000.cdf']);
%%
 figure; plot(serial2doy(aip.time), [aip.vars.RH_NephVol_Dry.data; ...
    aip.vars.RH_NephVol_Wet.data; aip.vars.RH_postHG.data],'o',...
    serial2doy(aos.time), [aos.vars.RH_NephVol_Dry.data; ...
    aos.vars.RH_NephVol_Wet.data; aos.vars.RH_postHG.data],'x',...
    serial2doy(aip.time), aip.vars.calculated_RH_NephVol_Wet.data,'k.');
 legend('dry','wet','post HG','aos dry','aos wet','aos post','calc');
 
 %%
 dewpt = calc_dp(aos.vars.T_postHG.data, aos.vars.RH_postHG.data)-273.15;
 figure; plot(serial2doy(aos.time), dewpt,'k.',serial2doy(aip.time), aip.vars.Td_postHG.data-273.15,'ro')
 %%
 rh = rh_from_dp(aos.vars.T_NephVol_Wet.data+273.15, dewpt+273.15);
 figure; plot(serial2doy(aip.time), aip.vars.calculated_RH_NephVol_Wet.data,'k.',...
    serial2doy(aos.time), 100.*rh,'ro');
 
 %%
 dp_main = calc_dp(aos.vars.T_MainInlet.data + 273.15, aos.vars.RH_MainInlet.data./100);
 dp_neph_vol_dry = calc_dp(aos.vars.T_NephVol_Dry.data + 273.15, aos.vars.RH_NephVol_Dry.data./100);
 dp_preHG = calc_dp(aos.vars.T_preHG.data + 273.15, aos.vars.RH_preHG.data./100);
 figure; plot(serial2doy(aip.time), dp_main-273.15,'k.',...
    serial2doy(aos.time), dp_neph_vol_dry-273.15,'ro',...
    serial2doy(aos.time), dp_preHG-273.15,'bx');
 leg = legend('main','neph_vol_dry','preHG'); set(leg,'interp','none')
 
 