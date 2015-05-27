% Reads an MPL binary file of darkcounts and an MPL binary file of afterpulse to generate a background-subtracted
% afterpulse profile.  The resulting  variables darkcounts and afterpulse( with associated range variable)
% are saved to matlab files "darkcnts" and "aftpulse"


disp('Select a pre-saved darkcounts mat file.')
[fid, fname, pname] = getfile('*.dk','darkcnts')
fclose(fid);
pause(1)
eval(['load ', pname, fname, ' -mat']);
pause(1)
disp('Select an MPL binary file of an afterpulse measurement. ');
read_mpl;
[bins,profs] = size(ProfileBins);
afterpulse = mean(ProfileBins')' - darkcounts ;
earlybins = afterpulse(1:10);
first_bin = min(find(earlybins > 1));
offset = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12 ; % The "0.5" centers the first bin
ap_range = [1:bins]';
ap_range = ap_range*RangeBinTime*c/2*1e-12 - offset ;
ap_range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - offset)/2;

[fname, pname] = putfile('*.ap','aftrpuls');
if pname~=0
  eval(['save ', pname, fname, ' afterpulse ap_range'])
end
