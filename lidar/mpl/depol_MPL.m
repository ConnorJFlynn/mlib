read_mpl_dep;
seconds = mod(time,100);
time = floor(time/100);
minutes = mod(time,100);
hours = floor(time/100);
time = seconds/3600 + minutes/60 + hours;
day = time/24;
clear seconds minutes hours
clear two_byte temp preliminary_cbh pname four_byte fname first_dif fidstart fidend date bigarray 
clear Voltag* UnitSN ShotsSummed PulseRep PacketSize NumPackets
clear NumBins MaxAltitude LaserTemp InstrumentTemp FilterTemp FileLength FileFormat DetectorTemp
clear BackgroundSignal 
range_far = find((range>0.03)&(range >= (0.8*max(range))));
range_sans_far = find((range>0.03)&(range <(0.8*max(range))));
range_lte_3km = find((range>=.3)&(range <= 3));
profiles = ProfileBins(range_sans_far,:) - ones(size(range_sans_far))*mean(ProfileBins(range_far,:));
if ~exist('copol','var')
    copol = [];
    depol = [];
    all_time = [];
end;
%load 20030325
Bin50 = mean(ProfileBins(range_lte_3km,:));
short = [1:(length(time) -2)];
%now remove inadvertant relative extrema
relext = 1+ find((Bin50(short)<Bin50(short+1))&(Bin50(short+2)<Bin50(short+1)));
diffs = diff(relext);
bad_diffs = find(diffs<(0.5*median(diffs)));
while any(bad_diffs)
    relmax(min(bad_diffs)+1) = [];
  diffs = diff(relext);
  bad_diffs = find(diffs<(0.5*median(diffs)));
end;
relmax = relext;

relext = 1+ find((Bin50(short)>Bin50(short+1))&(Bin50(short+2)>Bin50(short+1)));
diffs = diff(relext);
bad_diffs = find(diffs<(0.5*median(diffs)));
while any(bad_diffs)
    relmax(min(bad_diffs)+1) = [];
  diffs = diff(relext);
  bad_diffs = find(diffs<(0.5*median(diffs)));
end;
relmin = relext;

% now crop trailing unmatched profiles
rellen = min(length(relmax),length(relmin));
relmax = relmax(1:rellen);
relmin = relmin(1:rellen);
copol_bg = mean(ProfileBins([range_far],relmax));
depol_bg = mean(ProfileBins(range_far,relmin));
copol = [copol ProfileBins([range_sans_far],relmax) - ones(size(range_sans_far)) * copol_bg];
depol = [depol ProfileBins([range_sans_far],relmin) - ones(size(range_sans_far)) * depol_bg];
time_copol = time(relmax);
day_copol = time_copol/24;
time_depol = time(relmin);
day_depol = time_depol/24;
r2 = range(range_sans_far).^2;
r2 = r2.*(range(range_sans_far)>0);
copol_r2 = copol .* (r2 * ones(size(time_copol)));
depol_r2 = depol .* (r2 * ones(size(time_depol)));
dpr = (depol./copol).*(copol>0).*(depol>0);
all_time = [all_time time];
