function ol_corr = adjust_ol(mpl, ol_corr,pwr);
% ol_corr = adjust_ol(mpl, ol_corr);
% Adjusts shape of ol_corr but keeps ends pinned.
% 0 < pwr <= 1
if ~exist('pwr','var')
    pwr = 0.8923;
end
if (pwr<=0 )|(pwr>1)
    disp('Adjustment pwr must be 0<=pwr<1')
    pwr = 1;
end
log_ol_corr = log(ol_corr);
mloc = max(log_ol_corr(mpl.r.lte_5));
nlog_olcorr = log_ol_corr/mloc;
nlog_olcorr = nlog_olcorr.^pwr;
log_ol_corr = nlog_olcorr *mloc;
ol_corr = exp(log_ol_corr);
