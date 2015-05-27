function [afterpulse, mpl_ap] = use_for_ap(mpl_dark, mpl_ap);
% [afterpulse, mpl_ap] = use_for_ap(mpl_dark, mpl_ap);
% Accepts a darkcounts structure or value, prompts for a raw MPL afterpulse file, lets
% the user sift the afterpulse profiles, and generates an averaged
% afterpulse profile.  
% The averaged afterpulse profile is returned as mpl.statics.afterpulse and
% also save to file *.ap.
if nargin == 0
    mpl_dark = 0;
end
if isstruct(mpl_dark)
    if ~isfield(mpl_dark,'value')
        mpl_dark = mpl_dark.statics.darkcounts;
    end
    darkcounts = mpl_dark.value;
else
    if mpl_dark==0
        [darkcounts, mpl_dark] = use_for_dark;
    else
        darkcounts = mpl_dark;
        clear mpl_dark
    end
end
if nargin<2
  disp('Select an MPL binary file of an afterpulse measurement. ');
  mpl_ap = read_mpl;
end
[PileA, PileB] = trimsift_nolog(mpl_ap.range(mpl_ap.r.lte_30), mpl_ap.prof(mpl_ap.r.lte_30,:));
[bins,profs] = size(mpl_ap.rawcts(:,PileA));
afterpulse = mean(mpl_ap.rawcts(:,PileA)')' - darkcounts ;
% figure; plot(mpl_ap.range, mean(mpl_ap.rawcts(:,PileA)')', mpl_ap.range, afterpulse);
% figure; semilogy(mpl_ap.range, mean(mpl_ap.rawcts(:,PileA)')', mpl_ap.range, afterpulse);
% earlybins = afterpulse(1:10);
% first_bin = min(find(earlybins > 1));
% offset = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12 ; % The "0.5" centers the first bin
% ap_range = [1:bins]';
% ap_range = ap_range*RangeBinTime*c/2*1e-12 - offset ;
% ap_range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - offset)/2;
disp(['Afterpulse has been calculated.']);
disp(['Select a destination and file name for the afterpulse results.']);
[fname, pname] = putfile('*.ap','aftrpuls');
if pname~=0
  this = [mpl_ap.range, afterpulse];
  save([pname, fname], 'this', '-mat');
  save([pname, fname, '.dat'], 'this', '-ascii');
  % eval(['save ', pname, fname, ' afterpulse mpl.range']);
end
if exist('mpl_dark', 'var')
    mpl_ap.statics.darkcounts = mpl_dark;
else
    mpl_ap.statics.darkcounts.value = darkcounts;
    mpl_ap.statics.darkcounts.dk_file = ['manual entry'];
end
mpl_ap.statics.afterpulse.profile = afterpulse;
mpl_ap.statics.afterpulse.pname = [pname];
mpl_ap.statics.afterpulse.fname = [fname];

