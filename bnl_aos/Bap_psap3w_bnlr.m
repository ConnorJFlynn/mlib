function psapr = Bap_psap3w_bnlr(ins);
%%

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*psap3wr*.tsv','bnl_psap');
end
if ~isstruct(ins)
    psapr = read_psap3w_bnlr(ins);
else
    psapr = ins;
end

psap3w = read_psap3w_bnl(strrep(strrep(ins,'psap3wr','psap3w'),'psap3wR','psap3w'));
%%

% From Springston &Sedlacek
% Tr(t)= (sum(sig)/sum(ref))/(sum(sig)/sum(ref) at t=0)

% From 3W PSAP manual:
% B_ap= - (a/flow_rate*dt) * ln( Trt/Tr0)*Fr,

% Bond et al indicate that  Bap_PSAP(reported) = B_ap(raw)/2.*(0.5398 Tr + 0.355)
% Suggesting that Fr (from PSAP manual) = 1/(2.*(0.5398 Tr + 0.355)) 
% = 1/ (1.0796 Tr + 0.71)
% but they indicate the reported value be further adjusted as 
% B_ap_true  = Bap_PSAP/K2 - K1*Bsp/K2 with K2 = 1.22, 1/K2= 0.82 and K1 =
% 0.02 so K1/K2 = 0.01639

% However the PSAP 3W manual indicates b=b0/(Tr*B + A), B = 1.317, A = 0.866 
% under a description "Calibration function for transmittance", so possibly
% this is an alternate/newer transfer function?  I'm not 100% sure what if
% anything this implies about the Bond et al K1 and K2 parameters but these
% differences abount to 10% or less, so proceed anyway.
% Also from the 3W PSAP manual: Lambda from 3W PSAP manual: 470, 522, 660nm

% Smooth darks.
% Subtract darks from sigs and refs.
% Smooth refs.
% Divide sigs by refs.
% Subtract darks
%
%%
psapr.dark_ref_sm = smooth(psapr.dark_ref,120);
psapr.dark_sig_sm = smooth(psapr.dark_sig,120);
psapr.red_ref_sm = smooth(psapr.red_ref-psapr.dark_ref_sm,120);
psapr.grn_ref_sm = smooth(psapr.grn_ref-psapr.dark_ref_sm,120);
psapr.blu_ref_sm = smooth(psapr.blu_ref-psapr.dark_ref_sm,120);

psapr.red_sig_detrend = (psapr.red_sig-psapr.dark_sig_sm)./psapr.red_ref_sm;
psapr.grn_sig_detrend = (psapr.grn_sig-psapr.dark_sig_sm)./psapr.grn_ref_sm;
psapr.blu_sig_detrend = (psapr.blu_sig-psapr.dark_sig_sm)./psapr.blu_ref_sm;

% psapr.red_sig_detrend = (psapr.red_sig-psapr.dark_sig_sm);
% psapr.grn_sig_detrend = (psapr.grn_sig-psapr.dark_sig_sm);
% psapr.blu_sig_detrend = (psapr.blu_sig-psapr.dark_sig_sm);
%%
figure; plot(serial2doy(psapr.time), max(psap3w.Tr_red(psap3w.Tr_red<=1))*psapr.red_sig_detrend./max(psapr.red_sig_detrend),'r.', ...
    serial2doy(psapr.time), max(psap3w.Tr_grn(psap3w.Tr_grn<=1))*psapr.grn_sig_detrend./max(psapr.grn_sig_detrend),'g.', ...
    serial2doy(psapr.time), max(psap3w.Tr_blu(psap3w.Tr_blu<=1))*psapr.blu_sig_detrend./max(psapr.blu_sig_detrend),'b.')
%%
psapr.red_sig_detrend = max(psap3w.Tr_red(psap3w.Tr_red<=1))*psapr.red_sig_detrend./max(psapr.red_sig_detrend);
psapr.grn_sig_detrend = max(psap3w.Tr_grn(psap3w.Tr_grn<=1))*psapr.grn_sig_detrend./max(psapr.grn_sig_detrend);
psapr.blu_sig_detrend = max(psap3w.Tr_blu(psap3w.Tr_blu<=1))*psapr.blu_sig_detrend./max(psapr.blu_sig_detrend);

psapr.red_sig_detrend = smooth(psapr.red_sig_detrend,4);
psapr.grn_sig_detrend = smooth(psapr.grn_sig_detrend,4);
psapr.blu_sig_detrend = smooth(psapr.blu_sig_detrend,4);

X = 2;
II = [1:length(psapr.time)-X];
JJ = II + X;
a = 17.81; % This is in mm^2.  
a = 1e-2.*a; % Converting to cm^2
%%

flow = psapr.flow_lpm(JJ); % Flow is in lpm = 1000 cc pm.
flow = flow .* 1000./60; % Now flow is in cc per sec
psapr.dt = 24.*60.*60.*(psapr.time(JJ)-psapr.time(II));
col_L_cm = (flow./a).*psapr.dt; 
col_L_Mm = col_L_cm / 1e8;
%%

psapr.B_ap_blu = (psapr.blu_sig_detrend(II)-psapr.blu_sig_detrend(JJ))./col_L_Mm;
psapr.B_ap_grn = (psapr.grn_sig_detrend(II)-psapr.grn_sig_detrend(JJ))./col_L_Mm;
psapr.B_ap_red = (psapr.red_sig_detrend(II)-psapr.red_sig_detrend(JJ))./col_L_Mm;
%%
figure; plot(serial2Hh(psapr.time(2:end-1)), [psapr.B_ap_blu,psapr.B_ap_grn, psapr.B_ap_red],'.')

%%
B = 1.317;
A = 0.866
fB = 1./(psap3w.Tr_blu*B + A);
fG = 1./(psap3w.Tr_grn*B + A);
fR = 1./(psap3w.Tr_red*B + A);
%%
figure; 
s1(1) = subplot(2,1,1);
plot(serial2doy(psapr.time((1+X):end)), cumsum([fB(II).*psapr.B_ap_blu,fG(II).*psapr.B_ap_grn,fR(II).*psapr.B_ap_red]),'.')
legend('blu','grn','red');
title(psapr.fname,'interp','none');
s1(2) = subplot(2,1,2);
plot(serial2doy(psap3w.time), cumsum([psap3w.Bap_blu,psap3w.Bap_grn,psap3w.Bap_red]),'.')
legend('blu','grn','red');
title(psap3w.fname,'interp','none');
linkaxes(s1,'xy')

zoom('on');
%%


%% This is equivalent to end-Tr averaging.  But not quite as good as computing from the averaged Tr 
return