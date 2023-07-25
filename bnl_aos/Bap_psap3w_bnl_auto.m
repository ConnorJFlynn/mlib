function psapr = Bap_psap3w_bnl_auto(ins)
% psapr = Bap_psap3w_bnl_auto(ins)
% Update date of old function processing BNL "r" and " " packets to reproduce PSAP Bap values with S&S smoothing applied.
% We read the "r" packets to compute Tr from raw data at highest digital and temporal resolution, 
% but we renormalize these Tr values against transmittances in the " " packets which report the front-panel values. 
% Removing all detrending and smoothing of darks and reference values as this was
% introducing artificial features and offers neglible noise reduction when used with
% S&S processing.

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*psap3wr*.tsv','bnl_psap');
end
if ~isstruct(ins)
    psapr = read_psap3w_bnlr(ins);
else
    psapr = ins;
end

psap3w = read_psap3w_bnl(strrep(strrep(ins,'psap3wr','psap3w'),'PSAP3wR_','PSAP3W_'));
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
figure_(8); ss(1) = subplot(2,1,1); plot([1:length(psap3w.time)], [psap3w.Tr_blu, psap3w.Tr_grn, psap3w.Tr_red],'.');
ss(2) = subplot(2,1,2); plot([1:length(psapr.time)], [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.'); linkaxes(ss,'xy');
figure_(9); st(1) = subplot(2,1,1); plot(psap3w.time, [psap3w.Tr_blu, psap3w.Tr_grn, psap3w.Tr_red],'.');dynamicDateTicks
st(2) = subplot(2,1,2); plot(psapr.time, [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.');dynamicDateTicks; linkaxes(st,'xy')
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
      figure_(97); plot(psapr.time, [psapr.Tr_B, psapr.Tr_G, psapr.Tr_R],'.'); dynamicDateTicks
      newf_i =newf_j  + find(psap3w.Tr_red(newf_j:end)<.996& ...
      psap3w.Tr_grn(newf_j:end)<.996& ...
      psap3w.Tr_blu(newf_j:end)<.996, 1,'first');
   end

   mini = newf_i ;
end
psapr.flow_lpm = interp1(psap3w.time, psap3w.flow_lpm, psapr.time, 'linear');
psapr.Bap_B_ss = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_B,600); psapr.Bap_B_wbo = psapr.Bap_B_ss.*WeissBondOgren(psapr.Tr_B);
psapr.Bap_G_ss = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_G,600); psapr.Bap_G_wbo = psapr.Bap_G_ss.*WeissBondOgren(psapr.Tr_G);
psapr.Bap_R_ss = Bap_ss(psapr.time,psapr.flow_lpm, psapr.Tr_R,600); psapr.Bap_R_wbo = psapr.Bap_R_ss.*WeissBondOgren(psapr.Tr_R);

figure; plot(psapr.time, [psapr.Bap_B_wbo,psapr.Bap_G_wbo, psapr.Bap_R_wbo],'.'); dynamicDateTicks; legend('Ba_S_S B','Ba_S_S G','Ba_S_S R')
if isavar('v');
   axis(v)
end

% Next, load neph data. several potential steps:
% Average neph data to 60 s
% Adjust to PSAP WL with AngExp
neph = rd_tsv_neph;
neph.Bs_B = 1e6.*smooth(neph.Blue_T,600,'moving'); % smoothed to same 300 second window as PSAP
neph.Bs_G = 1e6.*smooth(neph.Green_T,600,'moving');
neph.Bs_R = 1e6.*smooth(neph.Red_T,600,'moving');

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
% figure; plot(neph.time, AE_BG,'o');
% shows AE_BG>0.6 so k1 = 0.02; k2 = 1.22, so scattering Bond scattering subtraction
% is k1./k2 .* Bs_*
psapr.Bap_B_Bond = psapr.Bap_B_ss.*WeissBondOgren(psapr.Tr_B) - (.02./1.22).*psapr.Bs_B_unc;
psapr.Bap_G_Bond = psapr.Bap_G_ss.*WeissBondOgren(psapr.Tr_G) - (.02./1.22).*psapr.Bs_G_unc;
psapr.Bap_R_Bond = psapr.Bap_R_ss.*WeissBondOgren(psapr.Tr_R) - (.02./1.22).*psapr.Bs_R_unc;
figure; plot(psapr.time, [psapr.Bap_B_wbo,psapr.Bap_G_wbo,psapr.Bap_R_wbo], '.', psapr.time, [psapr.Bap_B_Bond, psapr.Bap_G_Bond, psapr.Bap_R_Bond],'k.')
% Surprisingly large difference from Bond subtraction, but seems correct
psapr.Bs_B_trunc = interp1(neph.time, Bs_B.*AO_trn_B, psapr.time, 'linear'); % interpolate truncation corrected to PSAPr times
psapr.Bs_G_trunc = interp1(neph.time, Bs_G.*AO_trn_G, psapr.time, 'linear');
psapr.Bs_R_trunc = interp1(neph.time, Bs_R.*AO_trn_R, psapr.time, 'linear');

% figure; plot(psapr.time, [psapr.Bs_B_unc, psapr.Bs_G_unc, psapr.Bs_R_unc],'.',...
% psapr.time, [psapr.Bs_B_trunc, psapr.Bs_G_trunc, psapr.Bs_R_trunc],'k.');
psapr.Ba_B_V = Virk_wi_sca(psapr.Tr_B, psapr.Bap_B_ss ,psapr.Bs_B_trunc,4);
psapr.Ba_G_V = Virk_wi_sca(psapr.Tr_G, psapr.Bap_G_ss ,psapr.Bs_G_trunc,4);
psapr.Ba_R_V = Virk_wi_sca(psapr.Tr_R, psapr.Bap_R_ss ,psapr.Bs_R_trunc,4);

figure; plot(psapr.time, [psapr.Ba_B_V,psapr.Ba_G_V,psapr.Ba_R_V], '.',...
   psapr.time, [psapr.Bap_B_Bond,psapr.Bap_G_Bond,psapr.Bap_R_Bond], 'k.'); dynamicDateTicks; 

psapr.Ba_B_combined = (psapr.Ba_B_V + psapr.Bap_B_Bond)./2;
psapr.Ba_G_combined = (psapr.Ba_G_V + psapr.Bap_G_Bond)./2;
psapr.Ba_R_combined = (psapr.Ba_R_V + psapr.Bap_R_Bond)./2;

figure; plot(psapr.time, [psapr.Ba_B_combined, psapr.Ba_G_combined, psapr.Ba_R_combined],'.'); 
legend('Ba_B','Ba_G','Ba_R'); dynamicDateTicks; 
xlabel('time'); ylabel('Abs coef [1/Mm]'); 
title('Aerosol absorption at BNL, Canadian Fire Event, June 12-14 2023');

SSA_B = smooth(psapr.Bs_B_trunc ./ (psapr.Bs_B_trunc + psapr.Ba_B_combined),600,'moving');
SSA_G = smooth(psapr.Bs_G_trunc ./ (psapr.Bs_G_trunc + psapr.Ba_G_combined),600,'moving');
SSA_R = smooth(psapr.Bs_R_trunc ./ (psapr.Bs_R_trunc + psapr.Ba_R_combined),600,'moving');
SSA_B(SSA_B<0 | SSA_B>1) = NaN;
SSA_G(SSA_G<0 | SSA_G>1) = NaN;
SSA_R(SSA_R<0 | SSA_R>1) = NaN;
figure; plot(psapr.time, [SSA_B, SSA_G, SSA_R],'.'); legend('SSA_B','SSA_G','SSA_R'); dynamicDateTicks;
psapr.SSA_B = SSA_B; psapr.SSA_G = SSA_G; psapr.SSA_R = SSA_R;

% Psap 464, 529, 648
psapr.AAE_BG = smooth(real(ang_exp(psapr.Ba_B_combined, psapr.Ba_G_combined,464, 529 )),600,'moving');
psapr.AAE_BR = smooth(real(ang_exp(psapr.Ba_B_combined, psapr.Ba_R_combined,464, 648 )),600,'moving');
psapr.AAE_GR = smooth(real(ang_exp(psapr.Ba_G_combined, psapr.Ba_R_combined, 529, 648)),600,'moving');

bads = isnan(SSA_B)|isnan(SSA_G)|isnan(SSA_R);
psapr.AAE_BG(bads) = NaN; psapr.AAE_BR(bads) = NaN; psapr.AAE_GR(bads) = NaN; 

figure; plot(psapr.time, [psapr.AAE_BG, psapr.AAE_BR, psapr.AAE_GR],'.'); dynamicDateTicks
legend('AAE_B_G','AAE_B_R','AAE_G_R');

% Date, Time, Ba_B, Ba_G, Ba_R, AAE_BG, AAE_BR, AAE_GR, SSA_B, SSA_G, SSA_R, Bs_B, Bs_G, Bs_R, Tr_B, Tr_G, Tr_R  
dv = datevec(psapr.time);
DD = [dv(:,1), dv(:,2), dv(:,3),dv(:,4), dv(:,5), floor(dv(:,6)), ...
   psapr.Ba_B_combined, psapr.Ba_G_combined, psapr.Ba_R_combined,...
   psapr.AAE_BG, psapr.AAE_BR, psapr.AAE_GR,...
   psapr.SSA_B, psapr.SSA_G, psapr.SSA_R,...
   psapr.Bs_B_trunc, psapr.Bs_G_trunc, psapr.Bs_R_trunc,...
   psapr.Tr_B, psapr.Tr_G, psapr.Tr_R]';

col_header = 'YYYY-MM-DD, HH:MM:SS, Ba_B, Ba_G, Ba_R, AAE_BG, AAE_BR, AAE_GR, SSA_B, SSA_G, SSA_R, Bs_B, Bs_G, Bs_R, Tr_B, Tr_G, Tr_R';
fid = fopen('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\BNL_PSAP\CAMS_PSAP_CFE.dat','w+');
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