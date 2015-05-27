%rd_pcasp_xls
% Deprecated, reads a pcasp excel file created by importing the pcasp .csv
% file.  Not needed much anymore.
[num,txt]=xlsread([pname, fname]);
ad_ch = num(2:end,9:39);
i_ch = num(2:end,51:112);
b_ch = num(2:end,113:152);
ip_ch = num(2:end,153:end);
figure; plot([1:size(ad_ch,2)],sum(ad_ch),'.')
figure; plot([1:size(i_ch,2)],sum(i_ch),'.')
