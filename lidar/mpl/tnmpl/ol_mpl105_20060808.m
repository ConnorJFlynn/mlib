function ol_corr = ol_mpl105_20060808(range);
load olcorr_mpl105_20060808.mat
ol_corr = ones(size(range));
r.ol = find((range>= corr(1,1))&(range<=corr(end,1)));
ol_corr(r.ol) = interp1(corr(:,1), corr(:,2), range(r.ol));