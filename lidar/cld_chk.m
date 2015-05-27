function ht = cld_chk(mpl,THRESH);
% ht = cld_chk(mpl);
% Cloud check, take log, then derivative, then filter, then threshold
% Need to check size of threshold now that I'm computing a derivative
% rather than just "diff"ing the prof.
% Also need to identify useful range limit
% This should be virtually immune to relative power changes.
if ~exist('THRESH','var')
THRESH = 3;
end
% Compute background and std of background.  Use this as representative of
% the minimum noise in the measurement.
bg = mean(mpl.rawcts(mpl.r.bg,:));
bg_std = std(mpl.rawcts(mpl.r.bg,:));
min_val = 2 .* bg_std;
min_vals = ((ones(size(mpl.range)))*min_val);
low_sig = mpl.prof<min_vals;
mpl.prof(low_sig) = min_vals(low_sig);
log_prof = log10(mpl.prof);
dlog_prof =diff2(log_prof)./(diff2(mpl.range)*ones(size(mpl.time)));
dlog_prof = filter(ones(1,3)/3,1,dlog_prof);
dlog_prof(mpl.range<.15,:) = NaN;
cld = abs(dlog_prof)>THRESH;
ranges = mpl.range*ones(size(mpl.time));
ranges(~cld) = NaN;
ht = min(ranges);
figure; plot(serial2Hh(mpl.time), ht,'.');
