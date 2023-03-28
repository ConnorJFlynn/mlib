% apply_mfr7_corrs
% Load an MFRSR7nch file.
% Based on either filename or metadata determine the pattern to specify the
% correction c0 file. 

% Also obtain a file containing PWV and one containing atmos. pressure (if
% MFRSR doesn't)

mfr7 = anc_load(getfullname('*mfrsr7nch*b1*','mfr7'));

corr_stem = [mfr7.gatts.site_id,mfr7.gatts.platform_id, mfr7.gatts.facility_id,'.c0.*'];
mfr7_corrs = anc_load(getfullname(corr_stem,'xtra'));

mwrlos = anc_load(getfullname('*mwrlos*','mwrlos'));
met = anc_load(getfullname('*metM1.b1*','met'));

pwv = interp1(mwrlos.time, mwrlos.vdata.vap,mfr7.time, 'pchip');
bad =(pwv<0)|isnan(pwv);
pwv(bad) = interp1(mwrlos.time, mwrlos.vdata.vap,mfr7.time(bad), 'nearest','extrap');

pres = interp1(met.time, met.vdata.atmos_pressure,mfr7.time, 'pchip');
bad =(pres<90)|isnan(pres);
pres(bad) = interp1(met.time, met.vdata.atmos_pressure,mfr7.time(bad), 'nearest','extrap');
pres = pres./101.325; % Unitless in fraction of ATM

P_h2o = mfr7_corrs.vatts.filter7_gas_OD.ln_h2o_poly_vs_pwv;
h2o_od = polyval(pwv,exp(polyval(P_h2o,pwv)));
figure; plot(mfr7.time, h2o_od,'o'); legend('H2O OD'); dynamicDateTicks
ray_od = pres.*mfr7_corrs.vatts.filter7_gas_OD.ray_od_1atm;
figure; plot(mfr7.time, ray_od,'r.'); legend('Rayleigh OD'); dynamicDateTicks

oam = mfr7.vdata.airmass; 
ok = oam>1 & oam<=6;
P_ch4 = mfr7_corrs.vatts.filter7_gas_OD.ch4_poly_vs_oam;
ch4_od = polyval(P_ch4,oam);
ch4_od(~ok) = NaN;
figure; plot(mfr7.time, ch4_od,'c.'); legend('CH4 OD'); dynamicDateTicks
P_co2 = mfr7_corrs.vatts.filter7_gas_OD.co2_poly_vs_oam;
co2_od = polyval(P_co2,oam);
co2_od(~ok) = NaN;
figure; plot(mfr7.time, co2_od,'g.'); legend('Co2 OD'); dynamicDateTicks

vgod = ray_od + h2o_od + ch4_od+co2_od;
tgod = oam .* vgod;
Tr_god = exp(-tgod);
dirn_ch7 =  mfr7.vdata.direct_normal_narrowband_filter7;
figure; plot(oam(ok), dirn_ch7(ok),'-',oam(ok), dirn_ch7(ok)./Tr_god(ok),'-')


am_leg = ok & oam>2 & oam <5.75 & mfr7.vdata.azimuth_angle-180<0;
pm_leg = ok & oam>2 & oam <5.75 & mfr7.vdata.azimuth_angle-180>0;

figure; plot(oam(am_leg), dirn_ch7(am_leg),'-',oam(am_leg), dirn_ch7(am_leg)./Tr_god(am_leg),'-');logy; legend('AM Lang','AM Ref')
figure; plot(oam(pm_leg), dirn_ch7(pm_leg),'-',oam(pm_leg), dirn_ch7(pm_leg)./Tr_god(pm_leg),'-');logy; legend('PM Lang','PM Ref')

good_am = am_leg;
AR_Vo = dbl_lang(oam(am_leg),dirn_ch7(am_leg)./Tr_god(am_leg),2,20,1,2,'AR leg');
AL_Vo = dbl_lang(oam(am_leg),dirn_ch7(am_leg),2,20,1,2,'AL leg');
PR_Vo = dbl_lang(oam(pm_leg),dirn_ch7(pm_leg)./Tr_god(pm_leg),2,20,1,2,'PR leg');
PL_Vo = dbl_lang(oam(pm_leg),dirn_ch7(pm_leg),2,20,1,2,'PL leg');
[abs(AR_Vo-PR_Vo), abs(AL_Vo-PL_Vo)]

Io_ch7 = mean([AR_Vo, PR_Vo]);
Tr_ch7 = dirn_ch7./Io_ch7;
tod_ch7 = -log(Tr_ch7)./oam;
aod_ch7 = tod_ch7-vgod;
figure; plot(mfr7.time(oam>0&oam<15),aod_ch7(oam>0&oam<15),'*',mfr7.time(oam>0&oam<15),tod_ch7(oam>0&oam<15),'kx',...
  mfr7.time(oam>0&oam<15),vgod(oam>0&oam<15),'r.' ); dynamicDateTicks
legend('AOD','TOD','gas OD')

