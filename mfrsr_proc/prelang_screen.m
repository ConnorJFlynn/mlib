function [mfr, nom] = prelang_screen(mfr,nom)
% mfr = prelang_screen(mfr)
% Apply various screens to "mfr" data to attempt to salvage tau-langley
% calibratable time series.  Especially attempt to use for sites with
% frequent broken skies such as HOU, COR, ENA, ASI

% Check whether file has even nominally calibrated direct normal
% irradiances.  If not, attempt an adhoc nominal calibration by (what...)
% Then attempt to apply aod_screen perhaps with multiple pre-screens to
% permit eps-screen application. Explore soft eps limits and time bounds in
% order to hopefully recover some clear sky between clouds.

anet = rd_anetaod_v3;

if ~isavar('mfr')
    mfr = anc_load(['*mfr*.b1.*.cdf; *mfr*.b1.*.nc'],'xmfr');
end

%test filter 2 and filter 5 to see if their maximum intensities yield:
% 1. physically plausible Rayleigh subtracted AOD (greater than zero...)
% 2. Reasonable angstrom exponent >.5 < 3

% So, I guess we initially assume that Io is ESR. So we need to load Guey

guey = load('guey.mat'); if isfield(guey,'guey') guey = guey.guey; end;
ESR.nm = guey(:,1); ESR.Io = guey(:,3); 

Io_2 = interp1(ESR.nm, ESR.Io, sscanf(mfr.vatts.direct_normal_narrowband_filter2.centroid_wavelength, '%f'),'linear');
Io_5 = interp1(ESR.nm, ESR.Io, sscanf(mfr.vatts.direct_normal_narrowband_filter5.centroid_wavelength, '%f'),'linear');
 [zen, az, soldst, ha, dec, el, am] = sunae(mfr.vdata.lat, mfr.vdata.lon, mfr.time); soldst = mean(soldst);
nm_2 = sscanf(mfr.vatts.direct_normal_narrowband_filter2.centroid_wavelength, '%f');
nm_5 = sscanf(mfr.vatts.direct_normal_narrowband_filter5.centroid_wavelength, '%f');
RayOD_2 = rayleigh_ht(nm_2./1000);
RayOD_5 = rayleigh_ht(nm_5./1000);
% Adjust Io to get Ip aka I_prime, 'If ang<0, increase Io_2 or decrease Io_5'
Ip_2 = Io_2.*1.15; Ip_5 = Io_5.*.975;
Tr_2 = (soldst.^2).*mfr.vdata.direct_normal_narrowband_filter2./Ip_2;
Tr_5 = (soldst.^2).*mfr.vdata.direct_normal_narrowband_filter5./Ip_5;
miss = Tr_2<0 | Tr_5<0; Tr_2(miss) = NaN; Tr_5(miss) = NaN;
TOT_2 = -log(Tr_2); TOD_2 = TOT_2./am; AOD_2 = TOD_2-RayOD_2;
TOT_5 = -log(Tr_5); TOD_5 = TOT_5./am; AOD_5 = TOD_5-RayOD_5;
ang = log(AOD_2./AOD_5)./log(nm_5./nm_2);
am_leg = am<15 & am > 1.5 & az<180;
am_leg_ii = find(am_leg&isfinite(Tr_2)&Tr_2>0);
[Vo,tau,Vo_, tau_, good] = dbl_lang(am(am_leg_ii),Tr_2(am_leg_ii),3,10,1,1);
figure_(33);
 ss(1) = subplot(2,1,1); 
 plot(mfr.time(am_leg), AOD_2(am_leg), 'o', mfr.time(am_leg), AOD_5(am_leg),'+', mfr.time(am_leg), ang(am_leg), 'x');  dynamicDateTicks; logy
title('If ang<0, increase Io_2 or decrease Io_5')
% aod_screen(time, tau,tau_min, tau_max,pre_window, mad_thresh, eps_thresh,eps_window,  post_window, aot_base)
% run aod_screen with 7-min window (+/- 3.5 mins) and 5e-2 threshold


figure_(33);
 ss(2) = subplot(2,1,2); 
 plot(mfr.time(am_leg_ii(good)), AOD_2(am_leg_ii(good)), 'o', mfr.time(am_leg_ii(good)), AOD_5(am_leg_ii(good)),'+', mfr.time(am_leg_ii(good)), ang(am_leg_ii(good)), 'x');  dynamicDateTicks; logy

[aero, eps, aero_eps, mad, abs_dev] = aod_screen(mfr.time, AOD_2,[],[],3.5,[],5e-2,3.5,3.5);
figure_(34); plot(mfr.time, AOD_2,'.',mfr.time(aero), AOD_2(aero),'o'); dynamicDateTicks
% linkexes


return