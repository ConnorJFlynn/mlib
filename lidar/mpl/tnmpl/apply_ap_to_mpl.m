function mpl = apply_ap_to_mpl(mpl, ap_prof );
% mpl = apply_ap_to_mpl(mpl, ap_prof);
% In addition to subtracting the supplied afterpulse profile, it also updates
% the background, and statics.afterpulse_subtracted flag.
% CJF 2005-02-25

if nargin<2
    disp(['Error in "apply_ap_to_mpl": not enough arguments'])
    return
end
[rows,cols] = size(mpl.rawcts);
if ~isfield(mpl.statics, 'afterpulse_subtracted')
    mpl.statics.afterpulse_subtracted = 'no';
end
if ~ischar(mpl.statics.afterpulse_subtracted)
    if mpl.statics.afterpulse_subtracted==1
        mpl.statics.afterpulse_subtracted = 'yes';
    else
        mpl.statics.afterpulse_subtracted = 'no';
    end
end
if findstr(upper(mpl.statics.afterpulse_subtracted),'NO')
    mpl.rawcts = mpl.rawcts - ap_prof*ones([1,cols]);
    mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
    mpl.prof = (mpl.rawcts - (ones(size(mpl.range))*mpl.hk.bg)).*((mpl.range.^2)*ones(size(mpl.time)));
    mpl.statics.afterpulse_subtracted='yes';
    mpl.statics.afterpulse.profile = ap_prof;

else
    disp(['Already afterpulse_subtracted, so skipping subtraction.']);
end
