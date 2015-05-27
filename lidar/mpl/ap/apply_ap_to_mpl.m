function mpl = apply_ap_to_mpl(mpl, ap_prof );
% mpl = apply_ap_to_mpl(mpl, ap_prof);
% In addition to subtracting the supplied afterpulse profile, it also updates
% the background, and statics.afterpulse_subtracted flag.
% CJF 2005-02-25
% CJF 2006-10-28: adjust ap_prof with factor (max_raw - bg)/max_raw. This
% may be erroneous if the laser spike is not the max raw value as may
% happen if the spike is strong enough to supress the signal

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
    bg = mean(mpl.rawcts(mpl.r.bg,:));
    [mpl.ap.max_raw_val mpl.ap.max_raw_ind] = max(mpl.rawcts(1:20,:));
    mpl.ap.factor = ((mpl.ap.max_raw_val-bg)./mpl.ap.max_raw_val);
%     max_raw = mpl.ap.max_raw_val;
    ap_prof_adj = ap_prof * mpl.ap.factor;
    problem = find(any(ap_prof_adj(5:20,:)>mpl.rawcts(5:20,:)));
    if ~isempty(problem)
        disp(['Afterpulse exceeds signal in records: ',num2str(problem)]);
    end
    mpl.rawcts = mpl.rawcts - ap_prof_adj;
%     mpl.rawcts = mpl.rawcts - ap_prof*ones([1,cols]);
    mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
    mpl.prof = (mpl.rawcts - (ones(size(mpl.range))*mpl.hk.bg)).*((mpl.range.^2)*ones(size(mpl.time)));
    mpl.statics.afterpulse_subtracted='yes';
    mpl.statics.afterpulse.profile = ap_prof;

else
    disp(['Already afterpulse_subtracted, so skipping subtraction.']);
end
