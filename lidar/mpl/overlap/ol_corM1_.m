function ol_out = ol_corM1_(range,in_time);
% ol_out = ol_cor_(range,in_time);
% The ol functions return ol_out of length(range)
[ol_spot,~] = fileparts(which('ol_corM1_'));
ol_in = load([ol_spot,filesep,'cor_ol.mat']);
ol_out = interp1(ol_in.range, ol_in.corr, range, 'nearest','extrap');

return
