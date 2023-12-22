function psapr = Bap_psap3w_bnl_auto(ins, Ns_avg)
% psapr = Bap_psap3w_bnl_auto(ins,Ns_avg); 
% Designed to process BNL collected closure data. Expects/requires PSAP3WR, PSAP3W,
% CAPS, and Neph ASCII files.
% All arguments are optional.
%   ins is a full-path list of PSAP3WR files to process. If empty, will be prompted
%   Ns_avg is averaging/downsampling time in seconds.  Default it 60s

% Update date of old function processing BNL "r" and " " packets to reproduce PSAP Bap values with S&S smoothing applied.
% We read the "r" packets to compute Tr from raw data at highest digital and temporal resolution, 
% but we renormalize these Tr values against transmittances in the " " packets which report the front-panel values. 
% We don't use the PSAP "i" packets.
% Removing all detrending and smoothing of darks and reference values as this was
% introducing artificial features and offers neglible noise reduction when used with
% S&S processing.

% 2023-12-16: Connor - should make some changes for robustness (to handle corrupt
% data files gracefully) 
% 2023-12-16: Connor - should adhere to figure convention with lower tier / previous data product
% in black and newer in RBG. 
% 2023-12-16: Connor - Generate figures for Weiss, Bond/Ogren, Virk SCA, Virk Ext.
% The ext input can identify closure failure the others might miss since Ba should
% NEVER exceed Be

if ~isavar('ins') || isempty(ins)|| ~isafile(ins)
    ins = getfullname_('*psap3wr*.tsv','bnl_psap');
end
if ~isstruct(ins)
    psapr = read_psap3w_bnlr(ins);
else
    psapr = ins;
end

if ~isavar('Ns_avg')||isempty(Ns_avg)
   Ns_avg = 150; 
end
ins = strrep(strrep(ins,'PSAP3wR','PSAP3w'),'psap3wR','psap3w');
for in = length(ins):-1:1
   if ~isafile(ins{in})
      ins(in) = [];
   end
end
psap3w = read_psap3w_bnl(strrep(strrep(ins,'PSAP3wR','PSAP3w'),'psap3wR','psap3w'));
%%

% From Springston &Sedlacek
% Tr(t)= (sum(sig)/sum(ref))/(sum(sig)/sum(ref) at t=0)

% From 3W PSAP manual:
% B_ap= - (a/flow_rate*dt) * ln( Trt/Tr0)*Fr,


psapr.red_ref = (psapr.red_ref-psapr.dark_ref)./psapr.red_adc_cnt;
psapr.grn_ref = (psapr.grn_ref-psapr.dark_ref)./psapr.grn_adc_cnt;
psapr.blu_ref = (psapr.blu_ref-psapr.dark_ref)./psapr.blu_adc_cnt;

psapr.red_sig_detrend = (psapr.red_sig-psapr.dark_sig)./psapr.red_adc_cnt./psapr.red_ref;
psapr.grn_sig_detrend = (psapr.grn_sig-psapr.dark_sig)./psapr.grn_adc_cnt./psapr.grn_ref;
psapr.blu_sig_detrend = (psapr.blu_sig-psapr.dark_sig)./psapr.blu_adc_cnt./psapr.blu_ref;

psapr.Tr_B = psapr.blu_sig_detrend.*psap3w.Tr_blu(1)./psapr.blu_sig_detrend(1);
psapr.Tr_G = psapr.grn_sig_detrend.*psap3w.Tr_grn(1)./psapr.grn_sig_detrend(1);
psapr.Tr_R = psapr.red_sig_detrend.*psap3w.Tr_red(1)./psapr.red_sig_detrend(1);
% figure_(8); ss(1) = subplot(2,1,1); plot([1:length(psap3w.time)], [psap3w.Tr_blu, psap3w.Tr_grn, psap3w.Tr_red],'.');
% ss(2) = subplot(2,1,2); plot([1:length(psapr.time)], [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.'); linkaxes(ss,'xy');
% figure_(9); st(1) = subplot(2,1,1); plot(psap3w.time, [psap3w.Tr_blu, psap3w.Tr_grn, psap3w.Tr_red],'.');dynamicDateTicks
% st(2) = subplot(2,1,2); plot(psapr.time, [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.');dynamicDateTicks; linkaxes(st,'xy')
% Want to identify filter changes and renormalize based on psap3w.Tr_* 
mini = 1;
while ~isempty(mini)
   % Look for front panel Tr readings  <=1 and >.99.
      newf_i = mini - 1 + find(psap3w.Tr_red(mini:end)>.996&psap3w.Tr_red(mini:end)<=1 & ...
      psap3w.Tr_grn(mini:end)>.996&psap3w.Tr_grn(mini:end)<=1 & ...
      psap3w.Tr_blu(mini:end)>.996&psap3w.Tr_blu(mini:end)<=1, 1,'first');
      newf_j = newf_i + 1 + find(psap3w.Tr_red(newf_i:end)<psap3w.Tr_red(newf_i) | ...
      psap3w.Tr_grn(newf_i:end)<psap3w.Tr_grn(newf_i) | ...
      psap3w.Tr_blu(newf_i:end)<psap3w.Tr_blu(newf_i), 1,'first');
% If found, then identify the last good value from the old filter as the earliest min
% of all three filter colors, and find the last time after the filter change started
% when at least one color Tr is unchanged from the initial value.

   if ~isempty(newf_i)
      [~,min_b] = min(psap3w.Tr_blu(mini:newf_i)); [~,min_g] = min(psap3w.Tr_grn(mini:newf_i)); [~,min_r] = min(psap3w.Tr_red(mini:newf_i)); 
      mini = mini+min([min_b, min_g, min_r]);
      mask_i = interp1(psapr.time, [1:length(psapr.time)],psap3w.time(mini),'nearest');
      mask_j = interp1(psapr.time, [1:length(psapr.time)],psap3w.time(newf_i),'nearest');
     
      psapr.Tr_B(mask_i:mask_j-1) = NaN; psapr.Tr_G(mask_i:mask_j-1) = NaN; psapr.Tr_R(mask_i:mask_j-1) = NaN;
      psapr.Tr_B(mask_j:end) = psapr.Tr_B(mask_j:end)./psapr.Tr_B(mask_j);
      psapr.Tr_G(mask_j:end) = psapr.Tr_G(mask_j:end)./psapr.Tr_G(mask_j);
      psapr.Tr_R(mask_j:end) = psapr.Tr_R(mask_j:end)./psapr.Tr_R(mask_j);
      figure_(90); plot(psapr.time, [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.')
      legend('Tr_B','Tr_G','Tr_R'); dynamicDateTicks;
      newf_i =newf_j  + find(psap3w.Tr_red(newf_j:end)<.996& ...
      psap3w.Tr_grn(newf_j:end)<.996& ...
      psap3w.Tr_blu(newf_j:end)<.996, 1,'first');
   end
   mini = newf_i ;
end
yl = ylim;
yl(2) = 1.1; ylim(yl);
trunk = [fileparts(psapr.pname),filesep];
title('PSAP normalized filter transmittances'); ylabel('Tr')
saveas(90,[trunk,'PSAP_Tr_normalized.png'])
% Note, the Bap_ss function generates output at the same temporal spacing as the
% input but with a sliding window applied to improve SNR as per Springson & Sedlacek
% this is the raw "attenuation" coefficient before all filter corrections
psapr.flow_lpm = interp1(psap3w.time, psap3w.flow_lpm, psapr.time, 'linear');
psapr.Bap_B_raw = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_B,Ns_avg); 
psapr.Bap_G_raw = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_G,Ns_avg); 
psapr.Bap_R_raw = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_R,Ns_avg);

psapr.Bap_B_ravg = smooth(psapr.Bap_B_raw,Ns_avg,'moving');
psapr.Bap_G_ravg = smooth(psapr.Bap_G_raw,Ns_avg,'moving');
psapr.Bap_R_ravg = smooth(psapr.Bap_R_raw,Ns_avg,'moving');


figure_(98); plot(psapr.time, [psapr.Bap_B_raw,psapr.Bap_G_raw, psapr.Bap_R_raw],'.',...
   psapr.time, [psapr.Bap_B_ravg,psapr.Bap_G_ravg,psapr.Bap_R_ravg],'k.'); dynamicDateTicks; 
ylabel('Absorption [1/Mm]'); legend('Ba_S_S B raw','Ba_S_S G raw','Ba_S_S R raw',sprintf('%1.1f min avg',Ns_avg./60));
title(['PSAP Raw']);
yl = ylim; yl(1) = 0; yl(2) = min([50,max(psapr.Bap_B_raw)]).*1.1;
ylim(yl);
trunk = [fileparts(psapr.pname),filesep];
saveas(98,[trunk,'PSAP_Ba_raw_with_avg.png'])

%Apply Weiss filter-loading correction (precursor to Bond/Ogren correction)
psapr.Bap_B_wbo = psapr.Bap_B_raw.*WeissBondOgren(psapr.Tr_B);
psapr.Bap_G_wbo = psapr.Bap_G_raw.*WeissBondOgren(psapr.Tr_G);
psapr.Bap_R_wbo = psapr.Bap_R_raw.*WeissBondOgren(psapr.Tr_R);

psapr.Bap_B_avg_wbo = psapr.Bap_B_ravg.*WeissBondOgren(psapr.Tr_B);
psapr.Bap_G_avg_wbo = psapr.Bap_G_ravg.*WeissBondOgren(psapr.Tr_G);
psapr.Bap_R_avg_wbo = psapr.Bap_R_ravg.*WeissBondOgren(psapr.Tr_R);

figure_(99); 
plot(psapr.time, [psapr.Bap_B_avg_wbo, psapr.Bap_G_avg_wbo, psapr.Bap_R_avg_wbo],'.',...
   psapr.time, [psapr.Bap_B_ravg, psapr.Bap_G_ravg, psapr.Bap_R_ravg],'k.'); dynamicDateTicks; 
ylabel('Absorption [1/Mm]'); legend('Ba_B Weiss','Ba_G Weiss','Ba_R Weiss','Ba raw (avg)');
title(['PSAP Weiss and Raw, averaged']);
yl = ylim; yl(1) = 0; yl(2) = max(psapr.Bap_B_ravg).*1.1; yl(2) = min([50,max(psapr.Bap_B_ravg)]).*1.1;
ylim(yl)
trunk = [fileparts(psapr.pname),filesep];
saveas(99,[trunk,'PSAP_Ba_raw_with_Weiss.png'])


% Next, load neph data. several potential steps:
% Average neph data to 60 s
% Adjust to PSAP WL with AngExp
ins = getfullname('*NEPH*.tsv;*neph*.tsv','neph');
neph = rd_tsv_neph(ins);
% The neph is not at 1s rate, so we need to adjust the averaging accordingly
N_avg = round(Ns_avg./round(mean(diff(neph.time))*24*60*60));
neph.Bs_B = 1e6.*smooth(neph.Blue_T,N_avg,'moving'); % 
neph.Bs_G = 1e6.*smooth(neph.Green_T,N_avg,'moving');
neph.Bs_R = 1e6.*smooth(neph.Red_T,N_avg,'moving');

% Neph 450, 550, 700
% Psap 464, 529, 648
% Next, compute AngExp 
AE_BG = real(ang_exp(neph.Bs_B, neph.Bs_G, 450, 550)); 
AE_BR = real(ang_exp(neph.Bs_B, neph.Bs_R, 450, 700));
AE_GR = real(ang_exp(neph.Bs_G, neph.Bs_R, 550, 700));
AO_trn_B = (1.165 - (0.046 .* AE_BG));
AO_trn_G = (1.152 - (0.044 .* AE_BR));
AO_trn_R = (1.12 - (0.035 .* AE_GR));

Bs_B = real(ang_coef(neph.Bs_B, AE_BG, 450, 464)); % Adjust to PSAP WLs
Bs_G = real(ang_coef(neph.Bs_G, AE_BG, 550, 529));
Bs_R = real(ang_coef(neph.Bs_R, AE_GR, 700, 648));

psapr.Bs_B_unc = interp1(neph.time, Bs_B, psapr.time, 'linear'); % interpolate to PSAPr times
psapr.Bs_G_unc = interp1(neph.time, Bs_G, psapr.time, 'linear');
psapr.Bs_R_unc = interp1(neph.time, Bs_R, psapr.time, 'linear');

psapr.Bs_B_trunc = interp1(neph.time, Bs_B.*AO_trn_B, psapr.time, 'linear'); % interpolate truncation corrected to PSAPr times
psapr.Bs_G_trunc = interp1(neph.time, Bs_G.*AO_trn_G, psapr.time, 'linear');
psapr.Bs_R_trunc = interp1(neph.time, Bs_R.*AO_trn_R, psapr.time, 'linear');

figure_(97); plot(psapr.time, [psapr.Bs_B_trunc, psapr.Bs_G_trunc, psapr.Bs_R_trunc],'*',...
   psapr.time, [psapr.Bs_B_unc, psapr.Bs_G_unc, psapr.Bs_R_unc],'k.');
dynamicDateTicks;
title('Neph Scattering wi/wo Truncation Correction');
ylabel('Bs [1/Mm]');
legend('Bs B trunc','Bs G trunc','Bs R trunc','Bs B uncor','Bs G uncor','Bs R uncor'); 
yl = ylim; yl(1) = 0; yl(2) = max(psapr.Bs_B_trunc).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(97,[trunk,'Neph_avg.png'])

% figure; plot(neph.time, AE_BG,'o');
% shows AE_BG>0.6 so k1 = 0.02; k2 = 1.22, so scattering Bond scattering subtraction
% is k1./k2 .* Bs_*
psapr.Bap_B_Bond = psapr.Bap_B_avg_wbo - (.02./1.22).*psapr.Bs_B_unc;
psapr.Bap_G_Bond = psapr.Bap_G_avg_wbo - (.02./1.22).*psapr.Bs_G_unc;
psapr.Bap_R_Bond = psapr.Bap_R_avg_wbo - (.02./1.22).*psapr.Bs_R_unc;
figure_(96); plot( psapr.time, [psapr.Bap_B_Bond, psapr.Bap_G_Bond, psapr.Bap_R_Bond],'*',...
   psapr.time, [psapr.Bap_B_avg_wbo, psapr.Bap_G_avg_wbo, psapr.Bap_R_avg_wbo], 'k.');
dynamicDateTicks;
title(['PSAP with Weiss and Bond/Ogren corrections']); 
ylabel('Ba [1/Mm]'); 
legend('Ba_B Ogren','Ba_G Ogren', 'Ba_R Ogren','Ba_B Weiss','Ba_G Weiss', 'Ba_R Weiss');
yl = ylim; yl(1) = 0; yl(2) = min([25,max(psapr.Bap_B_avg_wbo)]).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(97,[trunk,'Ba_Weiss_and_Bond.png'])

[psapr.Ba_B_V,~,~,~,~,~,~, psapr.SSA_B_Vs] = Virk_wi_sca(psapr.Tr_B, psapr.Bap_B_ravg ,psapr.Bs_B_trunc,4);
[psapr.Ba_G_V,~,~,~,~,~,~, psapr.SSA_G_Vs] = Virk_wi_sca(psapr.Tr_G, psapr.Bap_G_ravg ,psapr.Bs_G_trunc,4);
[psapr.Ba_R_V,~,~,~,~,~,~, psapr.SSA_R_Vs] = Virk_wi_sca(psapr.Tr_R, psapr.Bap_R_ravg ,psapr.Bs_R_trunc,4);

figure_(96); plot(psapr.time, [psapr.Ba_B_V,psapr.Ba_G_V,psapr.Ba_R_V], '*',...
   psapr.time, [psapr.Bap_B_Bond,psapr.Bap_G_Bond,psapr.Bap_R_Bond], 'k.'); dynamicDateTicks; 
title('Bond and Virkkula corrected PSAP Absorption');
ylabel('Ba [1/Mm]');
legend('Ba_B Bond', 'Ba_G Bond', 'Ba_R Bond', 'Ba_B Vs', 'Ba_G Vs', 'Ba_R Vs')
yl = ylim; yl(1) = 0; yl(2) = min([25,max(psapr.Ba_B_V)]).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(96,[trunk,'Ba_Bond_and_Virk.png'])

psapr.Ba_B_combined = (psapr.Ba_B_V + psapr.Bap_B_Bond)./2;
psapr.Ba_G_combined = (psapr.Ba_G_V + psapr.Bap_G_Bond)./2;
psapr.Ba_R_combined = (psapr.Ba_R_V + psapr.Bap_R_Bond)./2;

figure_(95); plot(psapr.time, [psapr.Ba_B_combined, psapr.Ba_G_combined, psapr.Ba_R_combined],'.'); 
legend('Ba_B','Ba_G','Ba_R'); dynamicDateTicks; 
xlabel('time'); ylabel('Abs coef [1/Mm]'); 
title(['Aerosol absorption at BNL, ',datestr(psapr.time(1),'mmm dd yyyy')]);

yl = ylim; yl(1) = 0; yl(2) = min([20,max(psapr.Ba_B_combined)]).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(95,[trunk,'Ba_combined.png'])

SSA_B = psapr.Bs_B_trunc ./ (psapr.Bs_B_trunc + psapr.Ba_B_combined);
SSA_G = psapr.Bs_G_trunc ./ (psapr.Bs_G_trunc + psapr.Ba_G_combined);
SSA_R = psapr.Bs_R_trunc ./ (psapr.Bs_R_trunc + psapr.Ba_R_combined);
SSA_B(SSA_B<0 | SSA_B>1) = NaN;
SSA_G(SSA_G<0 | SSA_G>1) = NaN;
SSA_R(SSA_R<0 | SSA_R>1) = NaN;

figure_(94); plot(psapr.time, [psapr.SSA_B_Vs, psapr.SSA_G_Vs, psapr.SSA_R_Vs],'o',...
   psapr.time, [SSA_B, SSA_G, SSA_R],'x'); 
title(['SSA from Vs']); 
legend('SSA_B Vs','SSA_G Vs','SSA_R Vs','SSA_B','SSA_G','SSA_R'); dynamicDateTicks;
ylabel('SSA')
yl = ylim; yl(1) = 0; yl(2) = max(SSA_B).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(94,[trunk,'SSA_Virk_Combined.png'])

psapr.SSA_B = SSA_B; psapr.SSA_G = SSA_G; psapr.SSA_R = SSA_R;

% Psap 464, 529, 648
psapr.AAE_BG = smooth(real(ang_exp(psapr.Ba_B_combined, psapr.Ba_G_combined,464, 529 )),600,'moving');
psapr.AAE_BR = smooth(real(ang_exp(psapr.Ba_B_combined, psapr.Ba_R_combined,464, 648 )),600,'moving');
psapr.AAE_GR = smooth(real(ang_exp(psapr.Ba_G_combined, psapr.Ba_R_combined, 529, 648)),600,'moving');

bads = isnan(SSA_B)|isnan(SSA_G)|isnan(SSA_R);
psapr.AAE_BG(bads) = NaN; psapr.AAE_BR(bads) = NaN; psapr.AAE_GR(bads) = NaN; 

figure_(93); plot(psapr.time, [psapr.AAE_BG, psapr.AAE_BR, psapr.AAE_GR],'.'); dynamicDateTicks
title(['AAE from combined']);
legend('AAE_B_G comb','AAE_B_R comb','AAE_G_R comb');
ylabel('AAE comb')
yl = ylim; yl(1) = 0; yl(2) = max(psapr.AAE_BG).*1.1;
ylim(yl)
trunk = [fileparts(neph.pname),filesep];
saveas(93,[trunk,'AAE_Combined.png'])

%read_psap3w_bnl(strrep(ins,'PSAP3wR','PSAP3w'));
caps = rd_bnl_tsv_caps(getfullname('*CAPS*.tsv;*caps*.tsv','caps'));
good_caps = caps.Status_Blue < 10500;
% interpolate good caps to PSAPr times 
Bext_B_raw = interp1(caps.time(good_caps), caps.Extinction_Blue(good_caps), psapr.time, 'linear'); 
Bext_G_raw = interp1(caps.time(good_caps), caps.Extinction_Green(good_caps), psapr.time, 'linear');
Bext_R_raw = interp1(caps.time(good_caps), caps.Extinction_Red(good_caps), psapr.time, 'linear');

psapr.Bext_B_avg = smooth(Bext_B_raw,Ns_avg,'moving');
psapr.Bext_G_avg = smooth(Bext_G_raw,Ns_avg,'moving');
psapr.Bext_R_avg = smooth(Bext_R_raw,Ns_avg,'moving');


figure_(100); plot(psapr.time, [psapr.Bext_B_avg, psapr.Bext_G_avg, psapr.Bext_R_avg],'.',...
psapr.time, [Bext_B_raw, Bext_G_raw, Bext_R_raw] ,'k.'); dynamicDateTicks; 
ylabel('CAPS Ext [1/Mm]'); legend('Be_B avg','Be_G avg','Be_R avg','Be raw');
title(['CAPS "good" Extinction at PSAPR times'])

figure_(100); plot(psapr.time, [psapr.Bext_B_avg, psapr.Bext_G_avg, psapr.Bext_R_avg],'.'); dynamicDateTicks; 
ylabel('CAPS Ext [1/Mm]'); legend('Be_B avg','Be_G avg','Be_R avg');
title(['CAPS "good" Extinction at PSAPR times'])
yl = ylim; yl(1) = 0; yl(2) = max(psapr.Bext_B_avg).*1.1; ylim(yl)
trunk = [fileparts(caps.pname),filesep];
saveas(100,[trunk,'CAPS3w_Ext_avg.png'])


% This uses averaged Bap and Bext
[psapr.Ba_B_Ve, ~,k0,k1,h0,h1,s,psapr.SSA_B_Ve] = Virk_wi_ext(psapr.Tr_B, psapr.Bap_B_ravg ,psapr.Bext_B_avg,4);
[psapr.Ba_G_Ve, ~,k0,k1,h0,h1,s,psapr.SSA_G_Ve] = Virk_wi_ext(psapr.Tr_G, psapr.Bap_G_ravg ,psapr.Bext_G_avg,4);
[psapr.Ba_R_Ve, ~,k0,k1,h0,h1,s,psapr.SSA_R_Ve] = Virk_wi_ext(psapr.Tr_R, psapr.Bap_R_ravg ,psapr.Bext_R_avg,4);

SSA_B = psapr.SSA_B_Ve; %smooth(psapr.SSA_Ve_B,60,'moving');
SSA_G = psapr.SSA_G_Ve; %smooth(psapr.SSA_Ve_G,60,'moving');
SSA_R = psapr.SSA_R_Ve; %smooth(psapr.SSA_Ve_R,60,'moving');
SSA_B(SSA_B<0 | SSA_B>1) = NaN;
SSA_G(SSA_G<0 | SSA_G>1) = NaN;
SSA_R(SSA_R<0 | SSA_R>1) = NaN;

psapr.Ba_B_Ve(isNaN(SSA_B)|isNaN(SSA_G)|isnan(SSA_R)) = NaN;
psapr.Ba_G_Ve(isNaN(SSA_B)|isNaN(SSA_G)|isnan(SSA_R)) = NaN;
psapr.Ba_R_Ve(isNaN(SSA_B)|isNaN(SSA_G)|isnan(SSA_R)) = NaN;

figure_(101); 
plot(psapr.time, [psapr.Ba_B_Ve, psapr.Ba_G_Ve, psapr.Ba_R_Ve] ,'.'); dynamicDateTicks 
ylabel('Absorption [1/Mm]'); legend('Ba_B Navg Vext','Ba_G Navg Vext','Ba_R Navg Vext');
title(['Virk Ext Navg']);yl = ylim; yl(1) = 0; yl(2) = max(psapr.Ba_B_Ve).*1.05; ylim(yl)
trunk = [fileparts(caps.pname),filesep];
saveas(101,[trunk,'Virk_Ext_avg.png'])

figure_(102)
plot(psapr.time, [SSA_B, SSA_G, SSA_R],'.'); legend('SSA_B','SSA_G','SSA_R'); dynamicDateTicks;
ylabel('SSA VirkExt'); legend('SSA_B Ext','SSA_G Ext','SSA_R Ext');
title('SSA from Vext');

trunk = [fileparts(caps.pname),filesep];
saveas(102,[trunk,'SSA_VExt_avg.png'])
% Psap 464, 529, 648
AAE_BG_Ve = smooth(real(ang_exp(psapr.Ba_B_Ve, psapr.Ba_G_Ve,464, 529 )),600,'moving');
AAE_BR_Ve = smooth(real(ang_exp(psapr.Ba_B_Ve, psapr.Ba_R_Ve,464, 648 )),600,'moving');
AAE_GR_Ve = smooth(real(ang_exp(psapr.Ba_G_Ve, psapr.Ba_R_Ve, 529, 648)),600,'moving');

bads = isnan(SSA_B)|isnan(SSA_G)|isnan(SSA_R);
AAE_BG_Ve(bads) = NaN; AAE_BR_Ve(bads) = NaN; AAE_GR_Ve(bads) = NaN; 
psapr.AAE_BG_Ve = AAE_BG_Ve; psapr.AAE_BR_Ve = AAE_BR_Ve; psapr.AAE_GR_Ve = AAE_GR_Ve; 


figure_(103); plot(psapr.time, [psapr.AAE_BG_Ve, psapr.AAE_BR_Ve, psapr.AAE_GR_Ve],'.'); dynamicDateTicks
legend('AAE_B_G Ve','AAE_B_R Ve','AAE_G_R Ve'); ylabel('AAE_Ve');
yl = ylim; yl(1) = 0; yl(2) = min([5,max(psapr.AAE_BG_Ve)]).*1.05; ylim(yl)
% Closure figures:
% Ba_Bond Ba and SSA_bond
% Ba_Virk_sca and SSA_sca
% Ba_comb and SSA
% Ba_Virk_ext and SSA_ext
figure_(887); 
sl(1) = subplot(2,2,1); 
 plot(psapr.time, [psapr.Bap_B_Bond, psapr.Ba_B_V, psapr.Ba_B_combined, psapr.Ba_B_Ve],'.')
dynamicDateTicks; ylabel('Ba'); lg = legend('Bond', 'Virk', 'Comb', 'V ext'); lg.Location='northwest'
yl = ylim; yl(1) = 0; yl(2) = min([25,max(psapr.Bap_B_Bond)]).*1.05; ylim(yl)
sl(2) = subplot(2,2,3); 
ssa_B_bond = psapr.Bs_B_trunc./(psapr.Bs_B_trunc + psapr.Bap_B_Bond);
 plot(psapr.time, [ssa_B_bond, psapr.SSA_B_Vs, psapr.SSA_B,psapr.SSA_B_Ve],'.')
dynamicDateTicks; ylabel('SSA'); lg = legend('Bond', 'Virk', 'Comb', 'V ext'); lg.Location='northwest'
yl = ylim; yl(1) = 0; yl(2) = min([1,max(ssa_B_bond)]).*1.05; ylim(yl)
sr(1) = subplot(2,2,2); 
Baps = mean([psapr.Bap_B_Bond, psapr.Ba_B_V, psapr.Ba_B_combined, psapr.Ba_B_Ve]')';
 plot(psapr.time, [psapr.Bap_B_Bond-Baps, psapr.Ba_B_V-Baps, psapr.Ba_B_combined-Baps, psapr.Ba_B_Ve-Baps],'.')
dynamicDateTicks; ylabel('Ba'); lg = legend('Bond', 'Virk', 'Comb', 'V ext'); lg.Location='northwest';
yl = ylim;  ylim([-1,1])
sr(2) = subplot(2,2,4); 
ssa_B_bond = psapr.Bs_B_trunc./(psapr.Bs_B_trunc + psapr.Bap_B_Bond);
ssas = mean([ssa_B_bond, psapr.SSA_B_Vs, psapr.SSA_B,psapr.SSA_B_Ve]')';
 plot(psapr.time, [ssa_B_bond-ssas, psapr.SSA_B_Vs-ssas, psapr.SSA_B-ssas,psapr.SSA_B_Ve-ssas],'.')
dynamicDateTicks; ylabel('SSA'); lg = legend('Bond', 'Virk', 'Comb', 'V ext'); lg.Location='northwest';
yl = ylim;  ylim([-.05,.05])
linkaxes([sl, sr],'x')

trunk = [fileparts(caps.pname),filesep];
saveas(887,[trunk,'Ba_SSA_comparisons.png'])


figure_(886);% closure between _combined and CAPS extinction
xx(1) = subplot(2,2,1); % plot both extinctions
plot(psapr.time, [psapr.Bs_B_trunc + psapr.Ba_B_combined, psapr.Bext_B_avg],'.'); 
dynamicDateTicks; title('Extinction closure'); ylabel('Be [1/Mm]'); legend('Be_B Comb','Be_B CAPS');
yl = ylim;  ylim([0,max(psapr.Bext_B_avg)*1.05])
xx(2) = subplot(2,2,3); % Plot difference in extinction
plot(psapr.time, [psapr.Bs_B_trunc + psapr.Ba_B_combined - psapr.Bext_B_avg],'.'); 
dynamicDateTicks; ylabel('Be [1/Mm]'); legend('Be_B Comb - Be_B CAPS');
l = ylim;  ylim([-20,+20])
xx(3) = subplot(2,2,2); % plot both absorptions
plot(psapr.time, [psapr.Ba_B_combined, (1-psapr.SSA_B_Ve).* psapr.Bext_B_avg],'.'); 
dynamicDateTicks; title('Absorption closure'); ylabel('Ba [1/Mm]'); legend('Ba_B Comb','CAPS Be_B * COA');
ylim([0,30]);
xx(4) = subplot(2,2,4); % Plot difference in absorption
plot(psapr.time, [psapr.Ba_B_combined- (1-psapr.SSA_B_Ve).* psapr.Bext_B_avg],'.'); 
dynamicDateTicks; ylabel('Bap [1/Mm]'); legend('Ba_B Comb - CAPS Be_B * COA');
ylim([-1,1]);
linkaxes(xx,'x');
trunk = [fileparts(caps.pname),filesep];
saveas(887,[trunk,'Be_Bap_closure.png'])


% Date, Time, Ba_B, Ba_G, Ba_R, AAE_BG, AAE_BR, AAE_GR, SSA_B, SSA_G, SSA_R, Bs_B, Bs_G, Bs_R, Tr_B, Tr_G, Tr_R  
dv = datevec(psapr.time);
DD = [dv(:,1), dv(:,2), dv(:,3),dv(:,4), dv(:,5), floor(dv(:,6)), ...
   psapr.Ba_B_combined, psapr.Ba_G_combined, psapr.Ba_R_combined,...
   psapr.AAE_BG, psapr.AAE_BR, psapr.AAE_GR,...
   psapr.SSA_B, psapr.SSA_G, psapr.SSA_R,...
   psapr.Bs_B_trunc, psapr.Bs_G_trunc, psapr.Bs_R_trunc,...
   psapr.Tr_B, psapr.Tr_G, psapr.Tr_R]';

col_header = 'YYYY-MM-DD, HH:MM:SS, Ba_B, Ba_G, Ba_R, AAE_BG, AAE_BR, AAE_GR, SSA_B, SSA_G, SSA_R, Bs_B, Bs_G, Bs_R, Tr_B, Tr_G, Tr_R';
fid = fopen([trunk,'ARM-Like_AOP.',datestr(psapr.time(1),'yyyymmdd_'),datestr(psapr.time(end),'yyyymmdd.'),sprintf('_%ds_avg_',Ns_avg), '.csv'],'w+');
fprintf(fid, '%s \n',col_header);
fprintf(fid, '%d-%d-%d, %0.2d:%0.2d:%0.2d, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f \n',DD)
fclose(fid)
%C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\BNL_PSAP


% Next, compute AAE and SSA

% Interpolate to psapr.time
% Apply Bond subtraction
% Apply truncation correction
% Compute Virk_wi_scat
% Compute combined average of Bab
% Compute SSA and AAE

return