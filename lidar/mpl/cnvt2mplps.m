function mplps = cnvt2mplps(filename)
% mplps = cnvt2mplps(filename)
% This function reads a raw or netcdf mplps file, identifies the zerobin,
% applies background subtraction (saving as prof), does NOT apply range
% correction but does create r.squared to facilitate application, separates
% the incoming profiles into copol and depol blocks by assuming larger
% near-field return from copol.

%2004-08-02: CJF: Re-writing as a function call making use of the function
%"read_mpl" instead of "read_mpl_dep" which seems unecessary.


if nargin==0
    [fid, fname, pname] = getfile('*.*', 'mpl_data');
    filename = [pname fname];
    fclose(fid);
end

lidar = read_mpl(filename);
range = lidar.range;
r = lidar.r;
r.lte_3 = find((lidar.range>.045)&(lidar.range<=3));
time = lidar.time;

lower_atm = mean(lidar.prof(r.lte_3,:));
trimmed = [1:(length(time) -2)];
%now remove inadvertant relative extrema
relext = 1+ find((lower_atm(trimmed)<lower_atm(trimmed+1))&(lower_atm(trimmed+2)<lower_atm(trimmed+1)));
diffs = diff(relext);
bad_diffs = find(diffs<(0.5*median(diffs)));
while any(bad_diffs)
    relmax(min(bad_diffs)+1) = [];
  diffs = diff(relext);
  bad_diffs = find(diffs<(0.5*median(diffs)));
end;
relmax = relext;

relext = 1+ find((lower_atm(trimmed)>lower_atm(trimmed+1))&(lower_atm(trimmed+2)>lower_atm(trimmed+1)));
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
relmax = relmax(1:rellen); %These correspond to co-pol signal
relmin = relmin(1:rellen); % These are for depol signal

copol.bg = mean(lidar.rawcts(r.bg,relmax));
copol.cts = lidar.rawcts(:,relmax) - ones(size(lidar.range))*copol.bg;

depol.bg = mean(lidar.rawcts(r.bg,relmin));
depol.cts = lidar.rawcts(:,relmin) - ones(size(lidar.range))*depol.bg;

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
