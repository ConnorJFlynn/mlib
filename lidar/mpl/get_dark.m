function [darkcounts, mpl_dark] = get_dark(darkcounts);
% [darkcounts, mpl_dark] = get_dark
% Reads an MPL binary file of darkcounts.  The resulting  variable darkcounts is 
% returned as mpl.statics.darkcounts and saved to file *.dk
if nargin==0
    darkcounts=0;
end
if darkcounts == 0
  mpl_dark = read_mpl;
  [PileA, PileB] = trimsift_nolog(mpl_dark.range(mpl_dark.r.lte_30), mpl_dark.prof(mpl_dark.r.lte_30,:));
  [bins,profs] = size(mpl_dark.rawcts(:,PileA));
%  [bins,profs] = size(mpl.rawcts);
  darkcounts = mean(mean(mpl_dark.rawcts(.1* bins:.9*bins,PileA)));
  %darkcounts = mean(darkcounts);
end

[fname, pname] = putfile('*.dk','darkcnts')
if pname~=0    
%       this = [mpl_ap.range, afterpulse];
%   save([pname fname], 'this', '-mat');    
  eval(['save ', pname, fname, ' darkcounts'])
end
mpl_dark.statics.darkcounts.value = darkcounts;
mpl_dark.statics.darkcounts.pname = [pname];
mpl_dark.statics.darkcounts.fname = [fname];
