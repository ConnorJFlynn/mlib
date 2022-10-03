function [Cals, Lang_Legs] = test_fixed_tau_lang(vis, nir, He, mfr, Lang_Legs)
%  [Cals, Lang_Legs] = test_fixed_tau_lang(vis, nor, He, Lang_Legs)
% Run proc_sashe_dual_a0 to get re-banded SASHe VIS/NIR 
%Then run fix_sas_ddr to get better direct beam.
% Then pull in Lang_Legs to get airmasses and aod_fit
% Then compute tau-Langleys

% Processing steps:
% 1. Call proc_sashe_1s
tic
if ~isavar('vis')
    vis = anc_bundle_files(getfullname('sgpsashe*.a0.*', 'sashevis'));
end
if ~isavar('nir')
    nir = anc_bundle_files(getfullname('sgpsashe*.a0.*', 'sashenir'));
end
if ~isavar('He')
    He1 = proc_sashe_dual_a0(vis, nir);
    He = anc_cat(He1, proc_sashe_dual_a0(vis,nir,'last'));
end
% Orient time vector if necessary
% He.time = He.time';
%Populate with LST and airmass using vis

He.vdata.airmass(He.vdata.airmass<1) = NaN; He.vdata.airmass(He.vdata.airmass>50) = NaN;
% Load sgpmfrsrmesh.mat to get best-estimate DDR
% mfr = load('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\archive\sgp\sgpmfrsrmesh.mat');

% if isafile(which('sgpmfrsrmesh.mat'))
%     M1 = load('sgpmfrsrmesh.mat');
% else
    M1 = MFRxDDR;
% end
%% 

He_fix = fix_sas_ddr(He, M1);

%Union of MFRSR and Cimel WLs
Cal.nm = [340, 380, 415, 440, 500, 615, 675, 870, 1020, 1625, 1640];
cals = NaN(size(Cal.nm));
Cal.time_LST = []; Cal.ro = [];
if isafile(which('lang_legs.mat'))
    Lang_Legs = load('lang_legs');
else
    [Lang_Legs,ttau] = lang_tau_series;
end
if isfield(Lang_Legs,'lang_legs')
    Lang_Legs = Lang_Legs.lang_legs;
end
Legs = fieldnames(Lang_Legs ); figure_(25);
for L = length(Legs):-1:1
    LLeg = Lang_Legs.(Legs{L});
    if numel(LLeg.src)>0 && length(LLeg.airmass)>5 && (max(LLeg.airmass)-min(LLeg.airmass))>3 && min(LLeg.airmass)<3
        aod_filt_fit = interp1(LLeg.wl, LLeg.aod_fit', Cal.nm,'linear')';
        nm = Cal.nm; nm(nm>max(LLeg.nm))=[]; % This is separate so we can truncate it if needed
        nm_pix = interp1(He_fix.vdata.wavelength, [1:length(He_fix.vdata.wavelength)], nm, 'nearest');
        [Linh, hinL] = nearest(LLeg.time_LST, He_fix.time + double(He_fix.vdata.lon)./15/24);
        % figure; plot(time_LST, aod_filter_fit, '-'); dynamicDateTicks
        % figure; plot(He.time(hina), He.dirh_fix(hina,nm_pix(3)),'k-'); dynamicDateTicks
        for sf = 1:length(nm_pix)
            V = He_fix.vdata.airmass(hinL)'; tau = aod_filt_fit(Linh,sf); noNaN = ~isnan(V)&~isnan(tau);
            [P(sf,:)] = polyfit(tau(noNaN).*He_fix.vdata.airmass(hinL(noNaN))', ...
                real(log(V(noNaN).*He_fix.vdata.airmass(hinL(noNaN)))),1);


            [P(sf,:)] = polyfit(aod_filt_fit(Linh,sf).*He_fix.vdata.airmass(hinL)', ...
                real(log(He_fix.vdata.dirh_ffixed(nm_pix(sf),hinL).*He_fix.vdata.airmass(hinL))),1);
            LLeg.ro(sf) = exp(P(sf,2));   

            subplot(2,1,1);
            plot(He_fix.vdata.airmass(hinL)', ...
                real(log(He_fix.vdata.dirh_ffixed(nm_pix(sf),hinL)./cosd(He_fix.vdata.solar_zenith(hinL)))),'rx'); logy
            plot(2,1,2);
            plot(aod_filt_fit(Linh,sf).*He_fix.vdata.airmass(hinL)', ...
                real(log(He_fix.vdata.dirh_ffixed(nm_pix(sf),hinL)./cosd(He_fix.vdata.solar_zenith(hinL)))),'rx'); logy


        end
        Lang_Legs.(Legs{L}).nm = nm;
        Lang_Legs.(Legs{L}).ro = LLeg.ro;
        Cal.time_LST(L) = mean(LLeg.time_LST);
        Cal.ro(L,:) = cals;
        Cal.ro(L,nm<=max(LLeg.nm)) = LLeg.ro;
    end
end
disp('Done!')
toc
%% 
end

