function ap_out = ap_taihu_20080406(range);
%ap_out = ap_taihu_20080406(range)
% Now subsumed under "ap_taihu_"
% returns ap with .range, .cop, .crs
disp('Afterpulse corrections for Taihu MPL interpolated to supplied range')
ap = loadinto('ap_taihu_20080406.mat');
ap_out.cop =  interp1(ap.range, ap.cop, range,'nearest','extrap');
ap_out.crs =  interp1(ap.range, ap.crs, range,'nearest','extrap');
