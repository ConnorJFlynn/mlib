function [afterpulse, mpl] = get_ap(darkcounts);
% [afterpulse, mpl] = get_ap(darkcounts);
% Accepts a darkcounts value, prompts for a raw MPL afterpulse file, lets
% the user sift the afterpulse profiles, and generates an averaged
% afterpulse profile.  
% The averaged afterpulse profile is returned a mpl.statics.afterpulse and
% also save to file *.ap.
if nargin==0
   disp('Select a pre-saved darkcounts mat file.')
   [fid, fname, pname] = getfile('*.dk','darkcnts')
   fclose(fid);
   pause(1)
   eval(['load ', pname, fname, ' -mat']);
   pause(1)
end
disp('Select an MPL binary file of an afterpulse measurement. ');
mpl = read_mpl;
[PileA, PileB] = trimsift_nolog(mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:));
[bins,profs] = size(mpl.rawcts(:,PileA));
afterpulse = mean(mpl.rawcts(:,PileA)')' - darkcounts ;
figure; plot(mpl.range, mean(mpl.rawcts(:,PileA)')', mpl.range, afterpulse);
figure; semilogy(mpl.range, mean(mpl.rawcts(:,PileA)')', mpl.range, afterpulse);
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
  this = [mpl.range, afterpulse];
  save([pname fname], 'this', '-mat');
  % eval(['save ', pname, fname, ' afterpulse mpl.range']);
end
mpl.statics.afterpulse.profile = afterpulse;
mpl.statics.aferpulse.pname = [pname];
mpl.statics.aferpulse.fname = [fname];
