function [lidar, status, save_array] = read_mpl(filename)
% [lidar,status] = read_mpl(filename)
% Reads an entire raw MPL files in its entirety populating MPL structure
% 
% First, tests file to see if netcdf or packed 
% If netcdf, range is read from file.
% If packed binary, converts bin-time to range using the speed of light
if nargin==0
    disp(['Select an MPL data file'])
    [fid, fname, pname] = getfile('*.*', 'mpl_data');
    filename = [pname fname];
    fclose(fid);
end
status = 0;
ncid = mexnc('open', filename, 'write');
if (ncid>0)  %It's a valid netcdf file so read it
    ncmex('close', ncid);
    [lidar, status] = nc_readmpl(filename);
%    disp(['Reading ' filename]);

%     [lidar, status] = read_mpl_nc(ncid);
%     ncclose(ncid);
else %It's not a valid netcdf file so assume it's raw data and try to read it.
    fid = fopen(filename);
    %disp(['filename: ',filename]);
    [lidar, status, save_array] = read_mplraw(fid,filename);
    fclose(fid);
end;
lidar.statics.mpl = 1; %This lidar structure contains MPL data.
[pname,fname,ext] = fileparts(filename);
lidar.statics.fname = [fname ext];
lidar.statics.pname = [pname, filesep];
%Done reading in data...
% By this time, data has been read in.  
% Now generate some useful range selections...
if isfield(lidar,'r')
    r = lidar.r;
end
if isfield(lidar, 'range')
r.lte_5 = find((lidar.range>.045)&(lidar.range<=5));
r.lte_10 = find((lidar.range>.045)&(lidar.range<=10));
r.lte_15 = find((lidar.range>.045)&(lidar.range<=15));
r.lte_20 = find((lidar.range>.045)&(lidar.range<=20));
r.lte_25 = find((lidar.range>.045)&(lidar.range<=25));
r.lte_30 = find((lidar.range>.045)&(lidar.range<=30));
% r.squared = lidar.range.^2;
lidar.r = r;
end

%cts_to_MHz = (1./(lidar.hk.shots_summed*lidar.statics.range_bin_time/1000));
MHz_to_cts = (lidar.hk.shots_summed*lidar.statics.range_bin_time/1000);
try
    lidar.noise_MHz = sqrt(lidar.rawcts./(ones(size(lidar.range))*MHz_to_cts));
catch
    for b = length(lidar.range):-1:1
        lidar.noise_MHz(b,:) = sqrt(lidar.rawcts(b,:)./MHz_to_cts);
    end
end
   % lidar.noise_MHz = sqrt(lidar.rawcts./(ones(size(lidar.range))*MHz_to_cts));
bg_bin_noise = sqrt(lidar.hk.bg ./ MHz_to_cts);
for t = 1:length(lidar.time)
    low_cts = find(lidar.rawcts(:,t)<lidar.hk.bg(t));
    lidar.noise_MHz(low_cts,t) = bg_bin_noise(t);
end
bg_bins = length(lidar.r.bg);
lidar.hk.bg_noise = sqrt(lidar.hk.bg ./(MHz_to_cts*bg_bins));
lidar.statics.filename = filename;
% Note that this treats range like MSL instead of AGL.
% No choice since MPL data file does not include ground level AGL.
lidar.sonde.range = lidar.range(lidar.r.lte_30);
[lidar.sonde.temperature,lidar.sonde.pressure] = std_atm(lidar.range(lidar.r.lte_30));
[lidar.sonde.alpha_R, lidar.sonde.beta_R] = ray_a_b(lidar.sonde.temperature,lidar.sonde.pressure);
[lidar.sonde.atten_ray] = std_ray_atten(lidar.range(lidar.r.lte_30));
%!!Add lidar_bg_noise and handle rawcts < bg by assigning their noise to be equal to bg_noise
% ProfileBins is averaged over ShotSummed shots and is in units of cts/microsecond.
%To get the original shots per bin, multiply ProfileBins by ShotsSummed and by BinTime in microseconds
% ProfileBins = ProfileBins * ShotsSummmed/(BinTime/1000);
%To get ProfileBins in cts/km divide by the speed of light in km/microsecond: 2.99792458e-1 
% ProfileBins = ProfileBins/(c*1e-9);