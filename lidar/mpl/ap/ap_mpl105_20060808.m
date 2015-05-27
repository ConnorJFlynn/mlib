function y = ap_mpl105_20060808(range);

load ap_mpl105_20060808.mat
% This is a pre-dtc afterpulse profile
y = interp1(ap.range, ap.afterpulse, range);