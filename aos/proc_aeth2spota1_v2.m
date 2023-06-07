function aeth = proc_aeth2spota1_v2


% Aetheometer mass absorption cross-sections
% These aren't final form.
% I have confirmed the BC_uncorrected values.  Have not been able to reproduce K, but
% Have been able to produce BC (corrected) from BC_1_NC and ATN1 plus "k" as
% provided, and to visually confirm that BC (corrected) looks good across spot
% advance except for noisiness.
% Therefore, try smoothing Tr1 to get less noisy ATN1 and BC_1_NC, then apply k to
% yield less noisy BC and by inference Bap.
% Then compare to PSAP as below
% Ultimately would want to quantitatively assess:
%    A) The explicit benefit of different duration box-car smoothing on
%    PSAP and on AE33.  Looks likely that Allan variance will limit benefit
%    of longer averaging of AE33 to fairly short durations.
%    B)Quantitative bi-square regression of PSAP vs AE33, both uncorrected
%    C)Quantitative bi-square regression of PSAP vs AE33, both corrected
%    for filter loading, multiple scattering
%    D) Consistent method to assess statistical noise.  Maybe need to
%    request a test with filtered air?

spec_attn.AE31.nm = [370,470,520,590,660,880,950];
spec_attn.AE31.sigma = [39.5, 31.1, 28.1, 24.8, 22.2, 16.6, 15.4];
spec_attn.AE31.P = polyfit(log(spec_attn.AE31.nm./1000), log(spec_attn.AE31.sigma), 1);P.AE31 = spec_attn.AE31.P;

spec_attn.EC.nm = [370,470,520,590,660,880,950];
spec_attn.EC.sigma = [30,23.6,21.3,18.8, 16.8, 12.6, 11.7];
spec_attn.EC.P = polyfit(log(spec_attn.EC.nm./1000), log(spec_attn.EC.sigma), 1);P.EC = spec_attn.EC.P ;

%From Aeth33 manual

spec_attn.AE33.nm = [370,470,520,590,660,880,950];
spec_attn.AE33.sigma = [18.47, 14.54, 13.14, 11.58, 10.35, 7.77, 7.19];
spec_attn.AE33.P = polyfit(log(spec_attn.AE33.nm./1000), log(spec_attn.AE33.sigma), 1);P.AE33 = spec_attn.AE33.P;

% 
% 
% figure; 
% plot(spec_attn.AE31.nm, spec_attn.AE31.sigma, 'bo-', ...
%    spec_attn.EC.nm, spec_attn.EC.sigma, 'ro-', ...
%    spec_attn.AE33.nm, spec_attn.AE33.sigma, 'ko-');
% lg = legend('AE 31','EC','AE 33');set(lg,'interp','none');
% xlabel('wavelength [nm]');
% ylabel('sigma')
% logx; logy;

% The function "anc_bundle_files" reads one or more ARM netcdf files and 
% concatenates or 'bundles' them together into a single structure
% psap3w = ARM_display_beta;
aeth = anc_bundle_files(getfullname('*aosae*.nc','aeth')); % aeth = ARM_display_beta;
% ae_data = aeth.vdata;
% ae_data.time = aeth.time;
% ae_meta.vars = aeth.vatts;
% ae_meta.global = aeth.gatts;

% According to manual, define ATN0 when bit 1 = 0 and bit 2 = 1
ii = find( ~bitget(aeth.vdata.instrument_status,1) & bitget(aeth.vdata.instrument_status,2));

tr_1 = aeth.vdata.sample_intensity_spot_1./aeth.vdata.reference_intensity; 
Tr_1 = tr_1; 
for aa = ii
    Tr_1(:,aa:end) = tr_1(:,aa:end)./(tr_1(:,aa)*ones(size(aeth.time(aa:end))));
end
instrument_status = bitset(aeth.vdata.instrument_status,17,false);
Tr_1(:,instrument_status>0) = NaN;
ATN_1 = -100.*log(Tr_1);

figure_(16); plot(aeth.time, [aeth.vdata.sample_intensity_spot_1(1,:); aeth.vdata.reference_intensity(1,:)],'.'); dynamicDateTicks
figure_(17); these = plot(aeth.time,Tr_1, '-'); title('Tr spot 1'); dynamicDateTicks;
axs(4) = gca; % ylim([-.1, 1.1]);
recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength]); colorbar;
xl = xlim;
figure_(18); these = plot(aeth.time,ATN_1, '-'); title('ATN spot 1'); dynamicDateTicks;
axs(5) = gca; % ylim([-.1, 1.1]);
recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength]); colorbar;

% figure; plot(aeth.time, ae_data.power_supply_temperature,'-'); dynamicDateTicks
% legend('power supply temperature');
% xlim(xl);

% ARM_display_beta;
 % According to Gunnar, we have tape 8050 with an assumed Zeta 0.025
% % Also according MaGee according to Gunnar, AE33 spot size is 10 mm diam
spot_area = pi .* 5.^2;

disp('Be patient, the integral and smoother take a little while');

tic
% the new idea 2023-03-18
% new idea is to smooth Tr, recompute ATN, 
[Bab_1_raw_1m, dV1_ss, dL1_ss] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,60, spot_area);
% [Bab_1_raw_1m, Tr_1m, dV_1m, dL_1m] = smooth_Tr_i_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,60, spot_area);
% ATN1_1m = -100.*log(Tr_1m);
toc

Wein_C = 1.57; % Weingartner multiple scattering correction parameter C
Wein_C = 1.39; % C consistent with lab testing at TROPOS in Leipzig.
% Wein_C = 1.77; % Weingartner multiple scattering correction parameter C
 % suggestion from Gunnar that we use zeta 0.025
 % results in a strong match between McGee reported BC values (smoothed to
 % 60s) and my 1m comparable value computed from raw intensities with
 % Wein_C = 1.39 and zeta correction applied. 
zeta_leak = 0.025; 
Bab_1_1m= Bab_1_raw_1m./(Wein_C.*(1-zeta_leak)); 

% psap1s = anc_load;
% figure; plot(aeth.time, Bab_1_raw_1m(2,:), '-x', psap1s.time, psap1s.vdata.Ba_B_raw,'kx-'); dynamicDateTicks
% figure; plot(aeth.time, Bab_1_1m(2,:), '-x', psap1s.time, psap1s.vdata.Ba_B_raw,'kx-'); dynamicDateTicks
%The values for B2_raw and B1_raw are from the raw file reported by AE33
B1_raw = aeth.vdata.equivalent_black_carbon_spot_1_uncorrected;

% The values for B1 and B2 below are computed from the raw intensities in
% the file but have been averaged as per smooth_Bab
% units.  Bab is in 1/Mm.  sigma is m2/g but BC is in ng/m^3
BC1 = 1e3.*Bab_1_1m ./ (spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));
k = aeth.vdata.loading_correction_factor;
BC = BC1./(1-k.*ATN_1);
v = axis;
figure; plot(aeth.time, BC1(2,:), 'x',smooth(aeth.time,60), smooth(B1_raw(2,:),60),'o'); dynamicDateTicks; zoom('on');
legend('mine BC raw','McGee BC raw');

figure; plot(aeth.time, BC(2,:), 'x',smooth(aeth.time,60), smooth(aeth.vdata.equivalent_black_carbon(2,:),60),'o'); dynamicDateTicks; zoom('on');
legend('mine BC','McGee BC smoothed');
% OK, not only does the BC correct for loading, but also my BC and McGee BC agree
% Hmm...  Not so well at EPC.  Was it better at HOU? Pretty good on 3/30/2021 and 09/24/2022
% Now, convert back to Bap

Bap = (BC./1e3).*(spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));
aop = anc_bundle_files;
figure; plot(aop.time, [aop.vdata.Ba_B_combined;aop.vdata.Ba_G_combined;aop.vdata.Ba_R_combined],'o') ;dynamicDateTicks
figure; plot(aeth.time, Bap([2,3 5],:), 'x'); dynamicDateTicks;

xl_sub = xlim; sub_ = aeth.time>=xl_sub(1)&aeth.time<xl_sub(2);
xl_sup = xlim; sup_ = aeth.time>=xl_sup(1)&aeth.time<xl_sup(2);

figure; plot(aeth.vdata.wavelength, mean(Bap(:,sub_),2),'-o', aeth.vdata.wavelength, mean(Bap(:,sup_),2),'-x')  ; logx; logy;

sub_der = polyder(polyfit(log(aeth.vdata.wavelength), log(mean(Bap(:,sub_),2)),1));
sup_der = polyder(polyfit(log(aeth.vdata.wavelength), log(mean(Bap(:,sup_),2)),1));

[oine, eino] = nearest(aop.time, aeth.time);
figure; plot(aop.vdata.Ba_B_combined(oine).*((Bap(2,eino)>0)&(aop.vdata.Ba_B_combined(oine)>0)), Bap(2,eino).*((Bap(2,eino)>0)&(aop.vdata.Ba_B_combined(oine)>0)), 'bo'); axis('square');

return




