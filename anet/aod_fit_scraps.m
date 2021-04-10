
% after loading 'aod_SD_nmode.mat'
% Compose AOD of bi-modal PSD with VMR_F = 151 nm, VMR_C = 3.2 um. std .45 .55
% But what about VC?


wl_mfr = [415,500,615,673,870,1605];
wl_cim = [340,380,440,500,675,870,1020,1640];
wl_pom2 = [315,340,380,400,500,675,870,1020,1627,2200];
wl_aats14 = [354, 453, 499, 519, 604, 675, 778, 865, 1241, 1558, 2139]; 
aod_mfr = interp1(aod_SD_nmode.log_wl, taod, log(wl_mfr),'linear','extrap');
aod_cim = interp1(aod_SD_nmode.log_wl, taod, log(wl_cim),'linear','extrap');
aod_pom = interp1(aod_SD_nmode.log_wl, taod, log(wl_pom2),'linear','extrap');
aod_aats = interp1(aod_SD_nmode.log_wl, taod, log(wl_aats14),'linear','extrap');

[mfr_aod_fit, mfr_fit_rms, mfr_nolog_fit, mfr_nolog_rms, mfr_fit_abserr, mfr_nolog_abserr, mfr_fit_pcterr, mfr_nolog_pcterr, Ks,log_modes, Ks_, nonlog_modes] = fit_aod_basis_(wl_mfr, aod_mfr, wl_out(1:10:end));
[P,S,Mu] = polyfit(log(wl_mfr), log(aod_mfr), 2); mfr_pfit =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));
[P,S,Mu] = polyfit(log(wl_mfr(1:end-1)), log(aod_mfr(1:end-1)), 2); mfr_pfit_SW =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));

[cim_aod_fit, cim_fit_rms, cim_nolog_fit, cim_nolog_rms, cim_fit_abserr, cim_nolog_abserr, cim_fit_pcterr, cim_nolog_pcterr, Ks,log_modes, Ks_, nonlog_modes] = fit_aod_basis_(wl_cim, aod_cim, wl_out(1:5:end));
[P,S,Mu] = polyfit(log(wl_cim), log(aod_cim), 2); cim_pfit =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));
[P,S,Mu] = polyfit(log(wl_cim(1:end-1)), log(aod_cim(1:end-1)), 2); cim_pfit_SW =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));

[pom_aod_fit, pom_fit_rms, pom_nolog_fit, pom_nolog_rms, pom_fit_abserr, pom_nolog_abserr, pom_fit_pcterr, pom_nolog_pcterr, Ks,log_modes, Ks_, nonlog_modes] = fit_aod_basis_(wl_pom2, aod_pom, wl_out(1:5:end));
[P,S,Mu] = polyfit(log(wl_pom2), log(aod_pom), 2); pom_pfit =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));
[P,S,Mu] = polyfit(log(wl_pom2(1:end-2)), log(aod_pom(1:end-2)), 2); pom_pfit_SW =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));

[aats_aod_fit, aats_fit_rms, aats_nolog_fit, aats_nolog_rms, aats_fit_abserr, aats_nolog_abserr, aats_fit_pcterr, aats_nolog_pcterr, Ks,log_modes, Ks_, nonlog_modes] = fit_aod_basis_(wl_aats14, aod_aats, wl_out(1:5:end));

[P,S,Mu] = polyfit(log(wl_aats14), log(aod_aats), 2); aats_pfit =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));
[P,S,Mu] = polyfit(log(wl_aats14(1:end-3)), log(aod_aats(1:end-3)), 2); aats_pfit_SW =exp( polyval(P,log(wl_out(1:10:end)),S,Mu));

figure;  plot(wl_out(1:10:end),[mfr_pfit,cim_pfit,pom_pfit,aats_pfit],'-',wl_out, taod,'k-'); logy; logx; 
legend('mfr','cim','pom','aats','taod')

figure;  plot(wl_out(1:10:end),[mfr_pfit_SW,cim_pfit_SW,pom_pfit_SW,aats_pfit_SW],'-',wl_out, taod,'k-'); logy; logx; 
legend('mfr SW','cim SW','pom SW','aats  W','taod')

mfrC1 = anc_bundle_files;
mfrE13 = anc_bundle_files;
aod_lev1p5 = rd_anetaod_v3;
aod_lev2 = rd_anetaod_v3; %1640, 1020, 870,675,500,440,380,340

figure; plot(serial2doys(aod_lev2.time), [aod_lev2.AOD_1640nm,aod_lev2.AOD_1020nm,aod_lev2.AOD_870nm,...
    aod_lev2.AOD_675nm, aod_lev2.AOD_500nm,aod_lev2.AOD_440nm,aod_lev2.AOD_380nm,aod_lev2.AOD_340nm],'*',...
    serial2doys(mfrC1.time), mfrC1.vdata.aerosol_optical_depth_filter2,'o', ...
    serial2doys(mfrE13.time), mfrE13.vdata.aerosol_optical_depth_filter2,'x');
xl = xlim;
xlim(xl)
xl_C1 = serial2doys(mfrC1.time)>xl(1) & serial2doys(mfrC1.time)<xl(2);
xl_E13 = serial2doys(mfrE13.time)>xl(1) & serial2doys(mfrE13.time)<xl(2);
xl_anet = serial2doys(aod_lev2.time)>xl(1) & serial2doys(aod_lev2.time)<xl(2);
sum(xl_C1)
sum(xl_E13)
sum(xl_anet)
size(mfrC1.vdata.aerosol_optical_depth_filter1(xl_C1))
AODs =[mfrC1.vdata.aerosol_optical_depth_filter1(xl_C1),...
    mfrE13.vdata.aerosol_optical_depth_filter1(xl_E13),...
mfrC1.vdata.aerosol_optical_depth_filter2(xl_C1),...
mfrE13.vdata.aerosol_optical_depth_filter2(xl_E13),...
mfrC1.vdata.aerosol_optical_depth_filter3(xl_C1),...
mfrE13.vdata.aerosol_optical_depth_filter3(xl_E13),...
mfrC1.vdata.aerosol_optical_depth_filter4(xl_C1),...
mfrE13.vdata.aerosol_optical_depth_filter4(xl_E13),...
mfrC1.vdata.aerosol_optical_depth_filter5(xl_C1),...
mfrE13.vdata.aerosol_optical_depth_filter5(xl_E13),...
aod_lev2.AOD_1640nm(xl_anet)',aod_lev2.AOD_1020nm(xl_anet)',aod_lev2.AOD_870nm(xl_anet)',...
    aod_lev2.AOD_675nm(xl_anet)', aod_lev2.AOD_500nm(xl_anet)',aod_lev2.AOD_440nm(xl_anet)',...
    aod_lev2.AOD_380nm(xl_anet)',aod_lev2.AOD_340nm(xl_anet)'];

wls = [415.*ones(size(mfrC1.vdata.aerosol_optical_depth_filter1(xl_C1))), ...
    415.*ones(size(mfrE13.vdata.aerosol_optical_depth_filter1(xl_E13))), ...
500.*ones(size(mfrC1.vdata.aerosol_optical_depth_filter2(xl_C1))), ...
    500.*ones(size(mfrE13.vdata.aerosol_optical_depth_filter2(xl_E13))), ...
615.*ones(size(mfrC1.vdata.aerosol_optical_depth_filter3(xl_C1))), ...
    615.*ones(size(mfrE13.vdata.aerosol_optical_depth_filter3(xl_E13))), ...
673.*ones(size(mfrC1.vdata.aerosol_optical_depth_filter4(xl_C1))), ...
    673.*ones(size(mfrE13.vdata.aerosol_optical_depth_filter4(xl_E13))), ...
870.*ones(size(mfrC1.vdata.aerosol_optical_depth_filter5(xl_C1))), ...
    870.*ones(size(mfrE13.vdata.aerosol_optical_depth_filter5(xl_E13))),...
    1640.*ones(1,sum(xl_anet)),1020.*ones(1,sum(xl_anet)),870.*ones(1,sum(xl_anet)),...
    675.*ones(1,sum(xl_anet)),500.*ones(1,sum(xl_anet)),440.*ones(1,sum(xl_anet)),...
    380.*ones(1,sum(xl_anet)),340.*ones(1,sum(xl_anet))];
wl_out = min(unique(wls)).*.8 : 20 : max(unique(wls).*1.5);
wl_1640 = wls==1640;
aod_fit = fit_aod_basis(wls, AODs, wl_out);
aod_fits = fit_aod_basis_(wls, AODs, wl_out);
figure; plot(wls, AODs, '*',wl_out,aod_nfit,'r-x')
aod_fit_ = fit_aod_nbasis(wls(~wl_1640), AODs(~wl_1640), wl_out);
aod_fit = fit_aod_basis(wls, AODs, wl_out);
[aod_fit,good] = rfit_aod_basis(wls(~wl_1640), AODs(~wl_1640), wl_out);
[aod_fit,good] = rfit_aod_basis(1000.*star.w(w_ii), star.tau_aero_subtract_all(sun_ii,w_ii),1000.*star.w);

figure; plot(1000.*star.w, star.tau_aero_subtract_all(sun_ii,:),'.',...
    1000.*star.w, aod_fit,'-', 1000.*star.w(w_ii), star.tau_aero_subtract_all(sun_ii,w_ii),'ro'); logy; logx;
ww = 1000.*star.w(w_ii); tau = star.tau_aero_subtract_all(sun_ii,w_ii);
ww_ = ww<950 | (ww>1060);sum(ww_)
aod_fit = fit_aod_basis(ww(ww_), tau(ww_), [300:20:2200]);

wls_fit = unique(wls);
figure; plot(wls(~wl_1640), AODs(~wl_1640), 'x',wl_out, aod_fit,'k-*');
logx; logy

% Explore variability in AERONET observed log-normal parameters
vol_alm_15 = rd_anetaip_v3;
vol_alm_20 = rd_anetaip_v3;
vol_hyb_15 = rd_anetaip_v3;
vol_hyb_20 = rd_anetaip_v3;
rin_hyb_20 = rd_anetaip_v3;
rin_hyb = rd_anet_rin_v3;
siz_hyb_20 = rd_anet_siz_v3;
cad_hyb_20 = rd_anetaip_v3;
Rin_Darwin=rd_anet_rin_v3;
Rin_OLI=rd_anet_rin_v3;
figure; hist(Rin_OLI.Refractive_Index_Real_Part(:,4),20)
Rin_SGP = rd_anet_rin_v3;
figure; hist(Rin_SGP.Refractive_Index_Real_Part(:,4),20)

Rin_ENA;
Rin_OLI;
Rin_Darwin;
Rin_ASI;
% Compare ALM, HYB for version 1.5 and 2.0.
figure; hist(vol_alm_20.VMR_F,20); title('ALM 2.0');
figure; hist(vol_alm_15.VMR_C,20); title('SGP ALM 1.5 2013-2021, VMR Coarse');
figure; hist(vol_hyb_15.VMR_C,20); title('HYB 1.5');
figure; hist(vol_hyb_20.VMR_F,20); title('HYB 2.0');
% Conclusion: no significant difference between these product, at least at SGP.
% Fine mean radius varies from .12 to .22 (skew low) with std varying from .375 to .58
%   So possibly span with 3 fine modes .13, .165, .2 with std .375, .45, .6
% Coarse mean radius 1.7 to 4 (skey hi) with std from .55 to .82 
%   So possibly span with 3 coarse modes .18, .29, .4, 

% Using vmr_F = [.12, .16,.22] with std [.375 ,.45, .6]
% Using vmr_C = [1.5, 2.25, 3.45, 5] with std_C = [.5,.55,.5]

% Only a handful of good rin points from ALM 20 from 2017-01-01 thru 2020
% Will zoom into one, define it as "good" to select input vol + rin for
% anet_mie. Evaluate for reproduction of siz and aod.
figure; plot(rin_hyb_20.time, rin_hyb_20.Refractive_Index_Real_Part_440nm_, 'x'); dynamicDateTicks
v = axis; good = rin_hyb_20.time>v(1)&rin_hyb_20.time<v(2)& ...
    rin_hyb_20.Refractive_Index_Real_Part_440nm_>v(3) & rin_hyb_20.Refractive_Index_Real_Part_440nm_<v(4);
rin_hyb_20.Refractive_Index_Real_Part_870nm_(good)
n_i = [rin_hyb_20.Refractive_Index_Real_Part_440nm_(good),rin_hyb_20.Refractive_Index_Real_Part_675nm_(good),...
    rin_hyb_20.Refractive_Index_Real_Part_870nm_(good),rin_hyb_20.Refractive_Index_Real_Part_1020nm_(good)] + ...
    j*[rin_hyb_20.Refractive_Index_Imaginary_Part_440nm_(good),rin_hyb_20.Refractive_Index_Imaginary_Part_675nm_(good),...
    rin_hyb_20.Refractive_Index_Imaginary_Part_870nm_(good),rin_hyb_20.Refractive_Index_Imaginary_Part_1020nm_(good)];
lambda = [440,675,870,1020];
F.vmr = vol_hyb_20.VMR_F(good); F.std = vol_hyb_20.Std_F(good);
C.vmr = vol_hyb_20.VMR_C(good); C.std = vol_hyb_20.Std_C(good);
dV_dlnr = siz_hyb_20.dV_dlnr(good,:);
[aod, ssa] = anet_mie(lambda, n_i, siz_hyb_20.bin_radius,dV_dlnr);

[aod, ssa] = anet_mie(lambda,n_i, F, C);


figure; subplot(2,1,1); hist(vol_alm_15.VMR_F,20); title('ALM 1.5');subplot(2,1,2); hist(vol_alm_15.Std_F,20); title('std')
figure; subplot(2,1,1); hist(vol_alm_15.VMR_C,20); title('ALM 1.5');subplot(2,1,2); hist(vol_alm_15.Std_C,20); title('std')

% Might as well make it 2x2 with VMR and STD for both F and C in one plot. 
figure;
subplot(2,2,1); hist(vol_hyb_15.VMR_F,20); title('VMR_F')
subplot(2,2,3); hist(vol_hyb_15.Std_F,20); title('std_F')
subplot(2,2,2); hist(vol_hyb_15.VMR_C,20); title('VMR_C')
subplot(2,2,4); hist(vol_hyb_15.Std_C,20); title('std_C')
mt = mtit('OLI HYB 1.5'); 
set(mt.th,'fontsize',15,'position',[.5, 1.02]);

figure;
subplot(2,2,1); hist(vol_alm_15.VMR_F,20); title('VMR_F')
subplot(2,2,3); hist(vol_alm_15.Std_F,20); title('std_F')
subplot(2,2,2); hist(vol_alm_15.VMR_C,20); title('VMR_C')
subplot(2,2,4); hist(vol_alm_15.Std_C,20); title('std_C')
mt = mtit('OLI ALM 1.5'); 
set(mt.th,'fontsize',15,'position',[.5, 1.02]);
% At ENA, VMR_F = 0.17, VMR_C = 2.25, std_F = .5, std_C = .7
% At OLI, VMR_F = 0.16, VMR_C = 1.5, skewed shape, std_F = .45, std_C = .7