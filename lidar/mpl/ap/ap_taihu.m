function ap_out = ap_taihu(range);
%ap = ap_taihu;
% Now subsumed under "ap_taihu_"
%returns ap with .range, .cop, .crs
disp('Afterpulse corrections for Taihu MPL interpolated to supplied range')
ap = loadinto('taihu_ap_.mat');
ap_out.cop =  interp1(ap.range, ap.cop, range,'nearest','extrap');
ap_out.crs =  ap_out.cop; % no difference in this afterpulse
