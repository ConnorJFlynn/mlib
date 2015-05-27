function [status] = save_dk;
% [status] = save_dk;
% Reads an MPL binary file of darkcounts and an MPL binary file of afterpulse to generate a background-subtracted
% afterpulse profile.  The resulting  variables darkcounts and afterpulse( with associated range variable)
% are saved to matlab files "darkcnts" and "aftpulse"
x = 1;
X = 1;
darkcounts = input('Enter the dark counts or an x (or X) to select an MPL binary file of a darkcounts measurement. ');
if darkcounts == 1
  read_mpl;
  [bins,profs] = size(ProfileBins);
  darkcounts = mean(ProfileBins(.1* bins:.9*bins,profs));
  darkcounts = mean(darkcounts)
end

[fname, pname] = putfile('*.dk','darkcnts');
if pname~=0
  save([pname fname], 'darkcounts', '-ascii');
end
