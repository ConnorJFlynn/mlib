function mpl = apply_dtc_to_mpl(mpl, dtc_function, apd);
% mpl = apply_dtc_to_mpl(mpl, dtc_function);
% This was an internal function is used by for_files
% In addition to applying the deadtime correction, it also updates
% the background, and statics.deadtime_corrected flag.
% CJF 2005-02-25
% CJF 2006-06-16 remove eval by using a function handle?

if nargin<2
    disp(['Error in "apply_dtc_to_mpl": not enough arguments'])
elseif nargin==2
    apd = dtc_function;
end
if ~isfield(mpl.statics, 'deadtime_corrected')
   mpl.statics.deadtime_corrected = 'no';
end
if ~ischar(mpl.statics.deadtime_corrected)
    if mpl.statics.deadtime_corrected==1
        mpl.statics.deadtime_corrected = 'yes';
    else
        mpl.statics.deadtime_corrected = 'no';
    end
end
if findstr(upper(mpl.statics.deadtime_corrected),'NO')
%     eval(['mpl.rawcts = ',dtc_function, '(mpl.rawcts);']);
    mpl.rawcts = eval([dtc_function, '(mpl.rawcts);']);
    mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
    mpl.prof = (mpl.rawcts - (ones(size(mpl.range))*mpl.hk.bg)).*((mpl.range.^2)*ones(size(mpl.time)));
    mpl.statics.deadtime_corrected='yes';
    mpl.statics.apd = apd;
    mpl.statics.dtc_function = dtc_function;
else
    disp(['Already deadtime corrected, so skipping dtc_correction.']);
end
