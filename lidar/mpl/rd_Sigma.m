function [lidar, status] = rd_sigma(filename,start_here);
% [lidar,status] = rd_sigma(filename,start_here)
% Reads an entire Sigma raw MPL files in its entirety populating MPL structure

if nargin==0
    disp('Select a raw ASRC MPL file:');
    filename = getfullname_('*.*','mplpol');
%      = [pname fname];
end
if ~exist('start_here','var')
    start_here = 0;
end
status = 0;
fid = fopen(filename);
disp(['filename: ',filename]);
rd_sigmaraw;
fclose(fid);
%[lidar, status] = read_sigmaraw(fid);
if ~bad_file
statics.fname = filename;
statics.unitSN = UnitSN(1);
statics.VerNum = ver_num(1);
FileFormat = 'SIGMA';
statics.datastream = FileFormat;
% clear UnitSN FileFormat ProfileBins;
% hk.cbh = preliminary_cbh;
time = datenum(Year, Month, Day, Hours, Minutes, Seconds);
    hk.energy_monitor = energy_monitor/1000;
    hk.instrument_temp = instrument_temp ;
    hk.laser_temp = laser_temp;
    hk.detector_temp = detector_temp;
    hk.filter_temp = filter_temp;
    hk.pulse_rep = pulse_rep;
    hk.shots_summed = shots_summed;
    if any(range_bin_time ~=(range_bin_time(1)))
    hk.range_bin_time = range_bin_time;
    end
    statics.range_bin_time = range_bin_time(1);
    
hk.scanning_flag = scan_flag;
hk.pol_flag = pol_flag;
hk.az_deg = az_deg;
hk.el_deg = el_deg;
hk.compass_deg = comp_deg;
hk.pol_V1 = pol_v1;
hk.pol_V2 = pol_v2;
hk.pol_V3 = pol_v3;
hk.pol_V4 = pol_v4;
hk.preliminary_cbh = preliminary_cbh;
lidar.time = time;
lidar.statics = statics;
lidar.hk = hk;
c =  2.99792458e8;
range = 1e-3*[0:numbins-1]*c*1e-9*range_bin_time/2;
range = range';
r.bg = (range>=40)&(range<=57);
if sum(r.bg)==0
    r.bg = (range>=0.75.*max_altitude./1000)&(range<=0.95.*max_altitude./1000);
end

if ~isstruct(profile_bins)
   lidar.rawcts = profile_bins;
   bg = mean(lidar.rawcts(r.bg,:));
   
 else
   ch = fieldnames(profile_bins);
   for ch_i = 1:length(ch)
      lidar.rawcts.(ch{ch_i}) = profile_bins.(ch{ch_i});
      bg.(ch{ch_i}) = mean(lidar.rawcts.(ch{ch_i})(r.bg,:));
   end
end
if ~isstruct(profile_bins)
   prof = mean((lidar.rawcts - ones(size(range))*bg)')';
else
   prof = mean((lidar.rawcts.(ch{1}) - ones(size(range))*bg.(ch{1}))')';
end
   tzb = find((prof>1),1,'first');

   if isempty(tzb)
      tzb=0;
   end
    range = range - range(tzb);
lidar.range = range;
r.squared = (lidar.range>0).*(lidar.range.^2);
% r.bg = find((lidar.range>=40)&(lidar.range<=57));
% r.lte_5 = find((lidar.range>.045)&(lidar.range<=5));
% r.lte_10 = find((lidar.range>.045)&(lidar.range<=10));
% r.lte_15 = find((lidar.range>.045)&(lidar.range<=15));
% r.lte_20 = find((lidar.range>.045)&(lidar.range<=20));
% r.lte_25 = find((lidar.range>.045)&(lidar.range<=25));
% r.lte_30 = find((lidar.range>.045)&(lidar.range<=30));

r.bg = find((lidar.range>=40)&(lidar.range<=57));
r.lte_5 = lidar.range>=0 & lidar.range<=5;
r.lte_10 = lidar.range>=0 & lidar.range<=10;
r.lte_15 = lidar.range>=0 & lidar.range<=15;
r.lte_20 = lidar.range>=0 & lidar.range<=20;
r.lte_25 = lidar.range>=0 & lidar.range<=25;
r.lte_30 = lidar.range>=0 & lidar.range<=30;

lidar.r = r;
lidar.hk.bg_raw = bkgnd;
lidar.hk.bg_std = bkgnd_std;
if ~isstruct(profile_bins)
   lidar.hk.bg = bg;
   lidar.prof = lidar.rawcts - ones(size(range))*lidar.hk.bg;
   lidar.prof = lidar.prof .* (r.squared * ones(size(lidar.time)));
else
   for ch_i = 1:length(ch)
      lidar.hk.bg.(ch{ch_i}) = bg.(ch{ch_i});
      lidar.prof.(ch{ch_i}) = lidar.rawcts.(ch{ch_i}) - ones(size(range))*lidar.hk.bg.(ch{ch_i});
      lidar.prof.(ch{ch_i}) = lidar.prof.(ch{ch_i}) .* (r.squared * ones(size(lidar.time)));
   end
end

% clear ch_1



else
   lidar = [];
   status = -1;
end
% ProfileBins is averaged over ShotSummed shots and is in units of cts/microsecond.
%To get the original shots per bin, multiply ProfileBins by ShotsSummed and by BinTime in microseconds
% ProfileBins = ProfileBins * ShotsSummmed/(BinTime/1000);
%%

