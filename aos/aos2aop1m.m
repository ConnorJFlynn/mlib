function aop = aos2aop1m(neph, psap);
% aop = aos2aop1m(neph, psap);
% Accepts aosneph1m.b1 and aospsap3w.b1 files and computes aop1m files,
% populating an aop1m ancstruct from an existing ARM file.

aop_ = load(getfullname('aop_.mat','aop'));
neph = anc_bundle_files(getfullname('*neph*.nc','nephdry1m','Select AOS Neph Dry 1m files:'));
psap = anc_bundle_files(getfullname('*psap*.nc','psap1m',' Select AOS PSAP 1m files:'));

mint = min([neph.time(1), psap.time(1)]); maxt = max([neph.time(end), psap.time(end)]);
neph = anc_sift(neph, neph.time>= mint); neph = anc_sift(neph, neph.time<=maxt);
psap = anc_sift(psap, psap.time>= mint); psap = anc_sift(psap, psap.time<=maxt);
WL = {'B','G','R'};
while ~isempty(neph.time) && ~isempty(psap.time)
    
    [neph_day, neph] = anc_sift(neph, neph.time<ceil(neph.time(1)));
    [psap_day, psap] = anc_sift(psap, psap.time<ceil(psap.time(1)));
    if ~isempty(neph_day.time) && ~isempty(psap_day.time)
        [ninp, pinn] = nearest(neph_day.time, psap_day.time);
        neph_day = anc_sift(neph_day,ninp);
        psap_day = anc_sift(psap_day, pinn);
        aop_day = aop_; aop_day.time = neph_day.time;
        aop_day.vdata.lat = neph_day.vdata.lat;
        aop_day.vdata.lon = neph_day.vdata.lon;
        aop_day.vdata.alt = neph_day.vdata.alt;
        aop_day.vdata.impactor_state = neph_day.vdata.impactor_state;
        
        for w = 1:length(WL)      
        end
        aop_day.vdata.Bs_B_Dry_Neph3W = neph_day.vdata.Bs_B_Dry_Neph3W;
        aop_day.vdata.Bs_B_Dry_Neph3W_uncorrected = neph_day.vdata.Bs_B_Dry_Neph3W_raw;
        aop_day.vdata.Bs_G_Dry_Neph3W = neph_day.vdata.Bs_G_Dry_Neph3W;
        aop_day.vdata.Bs_G_Dry_Neph3W_uncorrected = neph_day.vdata.Bs_G_Dry_Neph3W_raw;        
        aop_day.vdata.Bs_R_Dry_Neph3W = neph_day.vdata.Bs_R_Dry_Neph3W;
        aop_day.vdata.Bs_R_Dry_Neph3W_uncorrected = neph_day.vdata.Bs_R_Dry_Neph3W_raw;        
        aop_day.vdata.AE_BG = ang_exp(aop_day.vdata.Bs_B_Dry_Neph3W,...
            aop_day.vdata.Bs_G_Dry_Neph3W,450, 500);
        aop_day.vdata.AE_BR = ang_exp(aop_day.vdata.Bs_B_Dry_Neph3W,...
            aop_day.vdata.Bs_R_Dry_Neph3W,450, 700);
        aop_day.vdata.AE_GR = ang_exp(aop_day.vdata.Bs_G_Dry_Neph3W,...
            aop_day.vdata.Bs_R_Dry_Neph3W,500, 700);             
        aop_day.vdata.AE_Bs_BG_uncorrected = ang_exp(aop_day.vdata.Bs_B_Dry_Neph3W_uncorrected,...
            aop_day.vdata.Bs_G_Dry_Neph3W_uncorrected,450, 500);
        aop_day.vdata.AE_Bs_BR_uncorrected = ang_exp(aop_day.vdata.Bs_B_Dry_Neph3W_uncorrected,...
            aop_day.vdata.Bs_R_Dry_Neph3W_uncorrected,450, 700);
        aop_day.vdata.AE_Bs_GR_uncorrected = ang_exp(aop_day.vdata.Bs_G_Dry_Neph3W_uncorrected,...
            aop_day.vdata.Bs_R_Dry_Neph3W_uncorrected,500, 700);
        aop_day.vdata.Bs_B = ang_coef(aop_day.vdata.Bs_B_Dry_Neph3W,aop_day.vdata.AE_BG, 450, 464);
        aop_day.vdata.Bs_B_uncorrected = ang_coef(aop_day.vdata.Bs_B_Dry_Neph3W_uncorrected ,aop_day.vdata.AE_Bs_BG_uncorrected, 450, 464);
        aop_day.vdata.Bs_G = ang_coef(aop_day.vdata.Bs_G_Dry_Neph3W,aop_day.vdata.AE_BG,550, 529);
        aop_day.vdata.Bs_G_uncorrected = ang_coef(aop_day.vdata.Bs_G_Dry_Neph3W_uncorrected,aop_day.vdata.AE_Bs_BG_uncorrected ,550, 529);
        aop_day.vdata.Bs_R = ang_coef(aop_day.vdata.Bs_R_Dry_Neph3W,aop_day.vdata.AE_GR,700,648);
        aop_day.vdata.Bs_R_uncorrected = ang_coef(aop_day.vdata.Bs_R_Dry_Neph3W_uncorrected,aop_day.vdata.AE_Bs_GR_uncorrected ,700,648);
        aop_day.vdata.K1_B = 0.02; aop_day.vdata.K1_G = 0.02; aop_day.vdata.K1_R = 0.02;         
  %     comment_impactor_state_10um = If AE_Bs_BG_uncorrected = -9999, K1 = -9999. If AE_Bs_BG_uncorrected < 0.02, K1 = 0.00668. If (0.2 < AE_Bs_BG_uncorrected < 0.6), K1 = 0.0334 * AE_Bs_BG_uncorrected). If AE_Bs_BG_uncorrected > 0.6, K1 = 0.02
         miss =  AE_Bs_BG_uncorrected==-9999;    
        for w = 1:length(WL)
            aop_day.vdata.(['Bs_',WL{w},'_Dry_Neph3W_uncorrected']) = neph_day.vdata.(['Bs_',WL{w},'_Dry_Neph3W_raw']);
        end  
return