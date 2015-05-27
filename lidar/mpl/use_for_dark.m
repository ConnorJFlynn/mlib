function [darkcounts, mpl_dark] = use_for_dark(mpl_dark);
% [darkcounts, mpl_dark] = use_for_dark(mpl_dark);
% Uses the supplied (or selected) mpl file for dark counts determination
% The resulting  variable darkcounts is 
% returned as mpl.statics.darkcounts and saved to file *.dk
if nargin<1
  mpl_dark = read_mpl;
end
  [PileA, PileB] = trimsift_nolog(mpl_dark.range(mpl_dark.r.lte_30), mpl_dark.prof(mpl_dark.r.lte_30,:));
  [bins,profs] = size(mpl_dark.rawcts(:,PileA));
%  [bins,profs] = size(mpl.rawcts);
  darkcounts = mean(mean(mpl_dark.rawcts(.1* bins:.9*bins,PileA)));
  %darkcounts = mean(darkcounts);


[fname, pname] = putfile('*.dk','darkcnts');
if pname~=0
    save([pname, fname], 'darkcounts', '-mat');
%  eval(['save ', pname, fname, ' darkcounts'])
end
mpl_dark.statics.darkcounts.value = darkcounts;
mpl_dark.statics.darkcounts.pname = [pname];
mpl_dark.statics.darkcounts.fname = [fname];
