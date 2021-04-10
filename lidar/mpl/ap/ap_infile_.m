function ap_out = ap_infile_(range,in_time);
% ap_out = ap_taihu_(range,in_time);
% The ap functions return elements of cop, crs, or prof of length(range)
ap.time(1) = [inf];
ap.ap{1} = @ap_none;
%ap_taihu_20080406

ap.time(2) = datenum('20080320','yyyymmdd');
ap.ap{2} = @ap_taihu_20080406;
ap.ap{2} = @ap_taihu;
if ~exist('in_time','var')||isempty(in_time)
   in = 1;
else
   first = find(in_time>ap.time,1);
end
first = max([1,first]);
ap_out = ap.ap{first}(range);
return

function ap = ap_none(range);
ap.cop = zeros(size(range));
ap.crs = ap.cop;
ap.prof = ap.cop;
return

function ap_out = ap_taihu(range);
%ap = ap_taihu;
%returns ap with .range, .cop, .crs
disp('Afterpulse corrections for Taihu MPL interpolated to supplied range')
ap = loadinto('taihu_ap_.mat');
ap_out.cop =  interp1(ap.range, ap.cop, range,'nearest','extrap');
ap_out.crs =  ap_out.cop; % no difference in this afterpulse
