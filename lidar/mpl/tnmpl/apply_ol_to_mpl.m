function mpl = apply_ol_to_mpl(mpl, ol_corr);
% mpl = apply_ol_to_mpl(mpl, ol_corr);
% In addition to applying the supplied overlap correction, it also updates
% the statics.overlap field.
% CJF 2005-09-11

if nargin<2
    disp(['Error in "apply_ol_to_mpl": not enough arguments'])
    return
end
[rows,cols] = size(mpl.rawcts);
if ~isfield(mpl.statics, 'overlap')
    mpl.statics.overlap.applied = 'no';
end
if ~ischar(mpl.statics.overlap.applied)
    if mpl.statics.overlap.applied==1
        mpl.statics.overlap.applied = 'yes';
    else
        mpl.statics.overlap.applied = 'no';
    end
end
if findstr(upper(mpl.statics.overlap.applied),'NO')
    mpl.prof = (mpl.prof .* ((ol_corr) * ones(size(mpl.time))));
%    mpl.prof = (mpl.prof .* ((ol_corr .^ .85) * ones(size(mpl.time))));
    mpl.statics.overlap.applied='yes';
    mpl.statics.overlap.corr = ol_corr;

else
    disp(['Already overlap corrected, so skipping...']);
end
