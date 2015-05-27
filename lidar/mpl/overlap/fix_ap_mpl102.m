function ol_corr = fix_ap_mpl102(mpl, ol_corr);
% ol_corr = fix_ap_mpl102(mpl, ol_corr);
% Trying adhoc overlap correction 

log_ol_corr = log(ol_corr);
mloc = max(log_ol_corr(mpl.r.lte_5));
nlog_olcorr = log_ol_corr/mloc;
nlog_olcorr = nlog_olcorr.^0.8923;
log_ol_corr = nlog_olcorr *mloc;
ol_corr = exp(log_ol_corr);
