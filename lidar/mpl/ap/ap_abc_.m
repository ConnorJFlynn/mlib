function ap_out = ap_abc_(range,in_time);
% MHz =ap_abc_(range,in_time);
% The ap functions return elements of cop, crs, or prof of length(range)
ap.time(1) = [inf];
ap.ap{1} = @ap_none;

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

% function ap_out = ap_hfe_Mar28(range);
% %This was copied from fkb as a starting point, but even the fkb afterpulse
% %looks to have changed (decreased) from this determination
% ap = loadinto('C:\matlib\ap_fkb.Mar28.mat');
% ap_out.cop =  interp1(ap.range, ap.cop, range,'nearest','extrap');
% ap_out.crs =  interp1(ap.range, ap.crs, range,'nearest','extrap');
% return