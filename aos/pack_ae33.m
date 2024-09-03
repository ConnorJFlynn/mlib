function [ae33, aeth] = pack_ae33(ins)
% [ae33, aeth] = pack_ae33(ins)
% 2024-06-29: preparing for AMICE


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
% 2024-03-08: this is currently NOT WORKING, all NAN or zero, possibly due to changes
% in the instrument sample interval which went from "fast" (~1s) to "slow" (~1min?)
% I think the issue is in smooth_Bab, but not sure.  Starting _v3 for now.

if ~isavar('ins')||isempty(ins)
   ins = getfullname_('*aeth2spot*.tsv','bnl_ae33','Select a raw BNL AE33 tsv file.');
end

if ~isstruct(ins)
  aeth = rd_bnl_tsv4(ins);
else 
   aeth = ins;
end

spec_attn.AE31.nm = [370,470,520,590,660,880,950];
spec_attn.AE31.sigma = [39.5, 31.1, 28.1, 24.8, 22.2, 16.6, 15.4];
spec_attn.AE31.P = polyfit(log(spec_attn.AE31.nm./1000), log(spec_attn.AE31.sigma), 1);P.AE31 = spec_attn.AE31.P;

spec_attn.EC.nm = [370,470,520,590,660,880,950];
spec_attn.EC.sigma = [30,23.6,21.3,18.8, 16.8, 12.6, 11.7];
spec_attn.EC.P = polyfit(log(spec_attn.EC.nm./1000), log(spec_attn.EC.sigma), 1);P.EC = spec_attn.EC.P ;

%From Aeth33 manual, still current in V1.70, March 2024
spec_attn.AE33.nm = [370,470,520,590,660,880,950];
spec_attn.AE33.sigma = [18.47, 14.54, 13.14, 11.58, 10.35, 7.77, 7.19];% m2/g
spec_attn.AE33.P = polyfit(log(spec_attn.AE33.nm./1000), log(spec_attn.AE33.sigma), 1);P.AE33 = spec_attn.AE33.P;

% ATN = -100*log(I/Io) = -100*log(T)
% T=0.7 ==> ATN = 35.7
% T=.9 ==> ATN = 10

% T = exp(-ATN/100)

ae33.time = aeth.time;
ae33.wl = spec_attn.AE33.nm;
ae33.sigma = spec_attn.AE33.sigma;
ae33.P_logSigmalogwl = spec_attn.AE33.P;
for ch = 7:-1:1
   ae33.Ref(:,ch) = aeth.(['RefCh',num2str(ch)]);
   ae33.Sen1(:,ch) = aeth.(['Sen1Ch',num2str(ch)]);
   ae33.Sen2(:,ch) = aeth.(['Sen2Ch',num2str(ch)]);
   ae33.BC(:,ch) = aeth.(['BC',num2str(ch)]);
   ae33.BC1(:,ch) = aeth.(['BC',num2str(ch),'1']);
   ae33.BC2(:,ch) =aeth.(['BC',num2str(ch),'2']);
   ae33.K(:,ch) = aeth.(['K',num2str(ch)]);
end
% ae33.Tr1 = ae33.Sen1./ae33.Ref;
% ae33.Tr2 = ae33.Sen2./ae33.Ref;

ae33.nor1 = ae33.Sen1;
ae33.nor2 = ae33.Sen2; 
ae33.nref = ae33.Ref;
first = find(all(ae33.nor1>0 & ae33.nor2>0 &ae33.nref>0,2),1,'first');
ii = sort([first, find( ~bitget(aeth.Status,1) & bitget(aeth.Status,2))']);
% if isempty(ii) ii = 1; end

for aa = ii
    ae33.nor1(aa:end,:) = ae33.nor1(aa:end,:)./ae33.nor1(aa,:);
    ae33.nor2(aa:end,:) = ae33.nor2(aa:end,:)./ae33.nor2(aa,:);
    ae33.nref(aa:end,:) = ae33.nref(aa:end,:)./ae33.nref(aa,:);

end
ae33.Tr1 = ae33.nor1./ae33.nref;
ae33.Tr2 = ae33.nor2./ae33.nref;

instrument_status = bitset(aeth.Status,17,false);
ae33.Tr1(instrument_status>0,:) = NaN; ae33.Tr2(instrument_status>0,:) = NaN;
ae33.ATN_1 = -100.*log(ae33.Tr1);
ae33.ATN_2 = -100.*log(ae33.Tr2);

flds = fieldnames(aeth); flds(1) = []; flds(end-4:end) = [];
flds = flds(~foundstr(flds,'Ch')); flds = flds(~foundstr(flds,'BC')); flds = flds(~foundstr(flds,'K'));
for f = 1:length(flds)
   fld = flds{f};
   ae33.(fld) = aeth.(fld);
end
flds = flds(foundstr(flds,'Status'));
for f = 1:length(flds)
   fld = flds{f};
   ae33.(fld) = uint32(ae33.(fld));
end
% According to manual, define ATN0 when bit 1 = 0 and bit 2 = 1


% figure_(16); plot(aeth.time, [aeth.vdata.sample_intensity_spot_1(1,:); aeth.vdata.reference_intensity(1,:)],'.'); dynamicDateTicks
% figure_(17); these = plot(aeth.time,Tr_1, '-'); title('Tr spot 1'); dynamicDateTicks;
% axs(4) = gca; % ylim([-.1, 1.1]);
% recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength]); colorbar;
% xl = xlim;
% figure_(18); these = plot(aeth.time,ATN_1, '-'); title('ATN spot 1'); dynamicDateTicks;
% axs(5) = gca; % ylim([-.1, 1.1]);
% recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength]); colorbar;
% 
%  we have tape 8050 with an assumed Zeta 0.025
ae33.zeta_leak = 0.025;
% % % Also according MaGee according to Gunnar, AE33 spot size is 10 mm diam
ae33.spot_area = pi .* 5.^2;
% 
% disp('Be patient, the integral and smoother take a little while');
% 
% tic
% % the new idea 2023-03-18
% % new idea is to smooth Tr, recompute ATN, 
% [Bab_1_raw_1m, dV1_ss, dL1_ss] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,60, spot_area);
% % [Bab_1_raw_1m, Tr_1m, dV_1m, dL_1m] = smooth_Tr_i_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,60, spot_area);
% % ATN1_1m = -100.*log(Tr_1m);
% toc
% 
%  [Bap] = Bap_ss(time, sample_flow, Tr,ss, spot_area);

% Wein_C = 1.57; % Weingartner multiple scattering correction parameter C
ae33.Wein_C = 1.39; % C consistent with lab testing at TROPOS in Leipzig.
% % Wein_C = 1.77; % Weingartner multiple scattering correction parameter C
%  % suggestion from Gunnar that we use zeta 0.025
%  % results in a strong match between McGee reported BC values (smoothed to
%  % 60s) and my 1m comparable value computed from raw intensities with
%  % Wein_C = 1.39 and zeta correction applied. 
ae33.zeta_leak = 0.025; 
ae33.Bap1_raw = Bap_ss(ae33.time, ae33.Flow1.*(1-ae33.zeta_leak)./1000, ae33.Tr1, 60, ae33.spot_area);
figure; plot(ae33.time, ae33.Bap1_raw,'-'); dynamicDateTicks; sgtitle('AE33'); 
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = ae33.time>xl(1)&ae33.time<xl(2);

   Bap = Bap_ss(ae33.time, ae33.Flow1.*(1-ae33.zeta_leak)./1000, ae33.Tr1(:,3), 1, ae33.spot_area);
   time = ae33.time(xl_); 
   Bap = Bap(xl_); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'linear'); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'nearest','extrap'); 
   v.time = time; 
   v.Bap = Bap;
   DATA.freq= v.Bap; DATA.rate = 1;
   v.retval = allan(DATA, 'AE33');




ae33.Bap2_raw = Bap_ss(ae33.time, ae33.Flow2.*(1-ae33.zeta_leak), ae33.Tr2, 60, ae33.spot_area);
ae33.Bap_raw = (ae33.Bap1_raw.*ae33.Flow1  +  ae33.Bap2_raw.*ae33.Flow2)./ae33.FlowC; 
for t = length(ae33.time):-1:1
   P_aae = polyfit(log(ae33.wl), log(ae33.Bap1_raw(t,:)),2);
   P_aae = polyder(P_aae);
   ae33.AAE1(t,:) = -real(polyval(P_aae,log(ae33.wl)));
   ae33.AAE_500(t) = -real(polyval(P_aae,log(500)));
end
figure; plot(ae33.time, ae33.AAE1,'.', ae33.time, ae33.AAE1_,'k.');dynamicDateTicks



figure; plot(ae33.time, ae33.Bap_raw,'-'); dynamicDateTicks
figure; plot(ae33.time, ae33.Tr1,'-'); dynamicDateTicks
ae33.Bap2_Wein_1p39 = ae33.Bap2_raw./ae33.Wein_C; 
Bap = (ae33.BC./1e3).*(ones(size(ae33.time))*spec_attn.AE33.sigma);
figure; sb(1) = subplot(2,1,1);
plot(ae33.time, smooth(Bap(:,3),300), 'g-'); dynamicDateTicks
 sb(2) = subplot(2,1,2);
plot(ae33.time, smooth(ae33.BC(:,3),300), 'k.',ae33.time, smooth(ae33.BC(:,7),300), 'r.'); dynamicDateTicks
linkaxes(sb,'x');

% nanmean(smooth(ae33.BC(:,6),300)./smooth(Bap(:,5),300))
% 
% % psap1s = anc_load;
% % figure; plot(aeth.time, Bab_1_raw_1m(2,:), '-x', psap1s.time, psap1s.vdata.Ba_B_raw,'kx-'); dynamicDateTicks
% % figure; plot(aeth.time, Bab_1_1m(2,:), '-x', psap1s.time, psap1s.vdata.Ba_B_raw,'kx-'); dynamicDateTicks
% %The values for B2_raw and B1_raw are from the raw file reported by AE33
% B1_raw = aeth.vdata.equivalent_black_carbon_spot_1_uncorrected;
% 
% % The values for B1 and B2 below are computed from the raw intensities in
% % the file but have been averaged as per smooth_Bab
% % units.  Bab is in 1/Mm.  sigma is m2/g but BC is in ng/m^3
% BC1 = 1e3.*Bab_1_1m ./ (spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));
% k = aeth.vdata.loading_correction_factor;
% BC = BC1./(1-k.*ATN_1);
% v = axis;
% figure; plot(aeth.time, BC1(2,:), 'x',smooth(aeth.time,60), smooth(B1_raw(2,:),60),'o'); dynamicDateTicks; zoom('on');
% legend('mine BC raw','McGee BC raw');
% 
% figure; plot(aeth.time, BC(2,:), 'x',smooth(aeth.time,60), smooth(aeth.vdata.equivalent_black_carbon(2,:),60),'o'); dynamicDateTicks; zoom('on');
% legend('mine BC','McGee BC smoothed');
% % OK, not only does the BC correct for loading, but also my BC and McGee BC agree
% % Hmm...  Not so well at EPC.  Was it better at HOU? Pretty good on 3/30/2021 and 09/24/2022
% % Now, convert back to Bap
% 
% Bap = (BC./1e3).*(spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));
% aop = anc_bundle_files;
% figure; plot(aop.time, [aop.vdata.Ba_B_combined;aop.vdata.Ba_G_combined;aop.vdata.Ba_R_combined],'o') ;dynamicDateTicks
% figure; plot(aeth.time, Bap([2,3 5],:), 'x'); dynamicDateTicks;
% 
% xl_sub = xlim; sub_ = aeth.time>=xl_sub(1)&aeth.time<xl_sub(2);
% xl_sup = xlim; sup_ = aeth.time>=xl_sup(1)&aeth.time<xl_sup(2);
% 
% figure; plot(aeth.vdata.wavelength, mean(Bap(:,sub_),2),'-o', aeth.vdata.wavelength, mean(Bap(:,sup_),2),'-x')  ; logx; logy;
% 
% sub_der = polyder(polyfit(log(aeth.vdata.wavelength), log(mean(Bap(:,sub_),2)),1));
% sup_der = polyder(polyfit(log(aeth.vdata.wavelength), log(mean(Bap(:,sup_),2)),1));
% 
% [oine, eino] = nearest(aop.time, aeth.time);
% figure; plot(aop.vdata.Ba_B_combined(oine).*((Bap(2,eino)>0)&(aop.vdata.Ba_B_combined(oine)>0)), Bap(2,eino).*((Bap(2,eino)>0)&(aop.vdata.Ba_B_combined(oine)>0)), 'bo'); axis('square');

return




