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
    He = anc_cat(He1, proc_sashe_dual_a0(vis,nir,'last'));% For processing when band pattern repeats forward and backward
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
Cal.nm = [340, 380, 415, 440, 500, 615, 675, 870, 1020, 1235, 1625, 1640];
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
Legs = fieldnames(Lang_Legs ); 
figure_(25);
ray_OD = rayleigh_ht(He_fix.vdata.wavelength./1000, 1013.25)*(He_fix.vdata.airmass.*He_fix.vdata.atmos_pressure./101.325);
for L = length(Legs):-1:1
    LLeg = Lang_Legs.(Legs{L});
    if numel(LLeg.src)>0 && length(LLeg.airmass)>5 && (max(LLeg.airmass)-min(LLeg.airmass))>3 && min(LLeg.airmass)<3
        aod_filt_fit = interp1(LLeg.wl, LLeg.aod_fit', Cal.nm,'linear')';
        nm = Cal.nm; nm(nm>max(LLeg.nm))=[]; % This is separate so we can truncate it if needed
        nm_pix = interp1(He_fix.vdata.wavelength, [1:length(He_fix.vdata.wavelength)], nm, 'nearest');
        [Linh, hinL] = nearest(LLeg.time_LST, He_fix.time + double(He_fix.vdata.lon)./15/24);
        % figure; plot(time_LST, aod_filter_fit, '-'); dynamicDateTicks
        % figure; plot(He.time(hina), He.dirh_fix(hina,nm_pix(3)),'k-'); dynamicDateTicks
        for sf = length(nm_pix):-1:1
            AM = He_fix.vdata.airmass(hinL); am_ = AM>=2 & AM<8;
            CSZA = cosd(He_fix.vdata.solar_zenith(hinL));
            T_ray = exp(-ray_OD(nm_pix(sf),hinL));
            R = He_fix.vdata.dirh_ffixed(nm_pix(sf),hinL);
            sky = He_fix.vdata.difh_780nm(hinL);
            R = R./CSZA;
            tau = aod_filt_fit(Linh,sf)'; 
            noNaN = ~isnan(R)&~isnan(tau);       
            % This is a standard Langley
            [LLeg.ro(sf),tau_,Vo_, tau__, good] = dbl_lang(AM(am_&noNaN),R(am_&noNaN)./T_ray(am_&noNaN),[],[],[],1);
%             [P(sf,:),S(sf,:)] = polyfit(AM(am_&noNaN), real(log(R(am_&noNaN))),1);
%             LLeg.ro(sf) = exp(P(sf,2)); 
            % This is a refined tau Langley  
            [LLeg.ro_tau(sf),tau_,Vo_, tau__, good] = dbl_lang(tau(am_&noNaN).*AM(am_&noNaN),R(am_&noNaN)./T_ray(am_&noNaN),[],[],[],1);
%             [P2(sf,:),S2(sf,:)] = polyfit(tau(am_&noNaN).*AM(am_&noNaN), real(log(R(am_&noNaN)./T_ray(am_&noNaN))),1);
%             LLeg.ro_tau(sf) = exp(P(sf,2));            
%             [P(sf,:)] = polyfit(sky(am_&noNaN).*AM(am_&noNaN),real(log(R(am_&noNaN))),1);
%             LLeg.ro_sky(sf) = exp(P(sf,2));
%  Adjust the y-lim of the following subplots so the relevant intercept is
%  the y-min.
            figure_(25); subplot(3,1,1);
            plot(AM(am_), tau(am_),'o',AM, (-log(R./LLeg.ro(sf))-ray_OD(nm_pix(sf),hinL))./AM,'x',...
                AM, (-log(R./LLeg.ro_tau(sf))-ray_OD(nm_pix(sf),hinL))./AM,'+'); legend('tau fit','tau', 'tau Lang');
            title(['Tau and Langley for ',sprintf(' %1.0f nm',nm(sf)) ]);
            xlabel('airmass'); ylabel('AOD')
            xl =xlim; xlim([0,xl(2)]); yl = ylim; ylim([0,1.5.*yl(2)]);logy;
            subplot(3,1,2);
            plot(AM(am_), real(log(R(am_))),'rx'); logy; legend('langley');
            xlabel('airmass'); ylabel('log(Rate)')
            xl =xlim; xlim([0,xl(2)]); yl = ylim; ylim([yl(1),1.2.*log(LLeg.ro(sf))]);
            subplot(3,1,3);
            plot(tau(am_).*AM(am_), real(log(R(am_)./T_ray(am_))),'k+'); logy; legend('tau langley');
            xlabel('airmass * aod'); ylabel('log(Rate/T_ray)')
            xl =xlim; xlim([0,1.1.*xl(2)]); yl = ylim; ylim([yl(1),1.2.*log(LLeg.ro_tau(sf))] )
%             plot(sky(am_).*AM(am_), real(log(R(am_))),'rx'); logy; legend('sky langley')
% "Sky" Langley doesn't work as well as normal or tau-lang, too bad...
% Make sure we're doing tau-langley correctly, probably have to add Ray
% to fit_aod, or remove Ray (divide by T_ray)
% So now, maybe run with tau-Langley for these sentinel AODs and assess how
% well each of them agrees with tau-fit over AM(am_)
% And then run each with ratio Langley against whichever matches tau-fit
% the best. And then interpolate with responsivity to produce calibration
% and thereby TOD at "all" wavelengths, and AOD at some defined subset. 
% (This implies work required on gas subtractions from TOD to yield hAOD (h=hyperspectral)
% Then new aod-fit that includes subsample of SASHe hyperspectral AOD 
% And an accurate representation of the trace gas OD as the residual which
% ultimately facilitates column and/or vertical gas retrievals. 

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

