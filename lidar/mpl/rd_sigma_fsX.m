function [lidar, status] = rd_sigma_fsx(filename,start_here);
% [lidar,status] = rd_sigma_fsx(filename,start_here)
% Reads an entire Sigma raw MPL files in its entirety populating MPL structure

if nargin==0
   disp('Select a raw ASRC MPL file:');
   filename = getfullname('*.*','mplpol');
   %      = [pname fname];
end
if ~exist('start_here','var')
   start_here = 0;
end
status = 0;
fid = fopen(filename);
disp(['filename: ',filename]);
rd_sigmaraw_fsx;
fclose(fid);
%[lidar, status] = read_sigmaraw(fid);
if ~bad_file
   statics.fname = filename;
   statics.unitSN = UnitSN(1);
   statics.VerNum = ver_num(1);
   
   FileFormat = 'SIGMA_FS';
   statics.datastream = FileFormat;
   % clear UnitSN FileFormat ProfileBins;
   % hk.cbh = preliminary_cbh;
   time = datenum(Year, Month, Day, Hours, Minutes, Seconds);
   hk.energy_monitor = energy_monitor;
   hk.instrument_temp = instrument_temp ;
   hk.laser_temp = laser_temp;
   hk.detector_temp = detector_temp;
   hk.filter_temp = filter_temp;
   hk.temp4 = temp4;
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
   hk.AD_bad_flag = bad_flag;
   hk.file_ver = file_ver;
   hk.MCS_mode = MCS_mode;
   hk.first_bin = first_bin;
   lidar.time = time;
   lidar.statics = statics;
   lidar.hk = hk;
   c =  2.99792458e8;
   range = 1e-3*[0:numbins-1]*c*1e-9*range_bin_time/2;

   
   if ~isstruct(profile_bins)
      r.bg = find(range>=.75.*max_altitude./1000 & range <=.95.*max_altitude./1000);
      lidar.rawcts = profile_bins;
      lidar.hk.bg = mean(lidar.rawcts(r.bg,:));
      lidar.hk.std_bg = std(lidar.rawcts(r.bg,:));
      prof = lidar.rawcts - ones(size(lidar.rawcts,1))*lidar.hk.bg;
   else
      r.bg = [1:hk.first_bin];
      ch = fieldnames(profile_bins);
      for ch_i = 1:length(ch)
         lidar.rawcts.(ch{ch_i}) = profile_bins.(ch{ch_i});
         lidar.hk.bg.(ch{ch_i}) = mean(lidar.rawcts.(ch{ch_i})(r.bg,:));
         lidar.hk.std_bg.(ch{ch_i}) = std(lidar.rawcts.(ch{ch_i})(r.bg,:));
      end
      prof = lidar.rawcts.ch_1 - ones([size(lidar.rawcts.ch_1,1),1])*lidar.hk.bg.ch_1;
      tzb = [1:length(range)]'*ones([size(time)]);
      first_block = 1:length(range);
      if ~any(prof(first_block,:)>1)
          first_block = true(size(range));
          tzb = find(first_block')*ones(size(time));
      end
      tzb(prof(first_block,:)<1) = NaN;
      tzb = min(tzb);
      tzb(isNaN(tzb)) = min(tzb);
      if isempty(tzb)||all(isNaN(tzb))
         tzb=1;
      end
      range_offset = range(tzb);
%       range = [0:(range(2)-range(1)):30]';
%       keep = [0:length(range)-1]';
      
   end
   bins = length(range);
keep = false(size(prof));
for t = 1:length(lidar.time)
%    keep(tzb:tzb+bins-1,t) = true;
      keep(tzb:end,t) = true;
end
clear prof profile_bins
lidar.range = range';
r.squared = (lidar.range>0).*(lidar.range.^2);
r.lte_5 = lidar.range>=0 & lidar.range<=5;
r.lte_10 = lidar.range>=0 & lidar.range<=10;
r.lte_15 = lidar.range>=0 & lidar.range<=15;
r.lte_20 = lidar.range>=0 & lidar.range<=20;
r.lte_25 = lidar.range>=0 & lidar.range<=25;
r.lte_30 = lidar.range>=0 & lidar.range<=30;
if ~isstruct(lidar.rawcts)
      lidar.prof = lidar.rawcts - ones(size(lidar.range))*lidar.hk.bg;
   lidar.prof = lidar.prof .* (r.squared * ones(size(lidar.time)));
else
    ch = fieldnames(lidar.rawcts);
    block = zeros([bins,t]);
    for ch_i = 1:length(ch)
%       block = lidar.rawcts.(ch{ch_i})(keep);
%       lidar.rawcts.(ch{ch_i}) = block;
      lidar.prof.(ch{ch_i}) = lidar.rawcts.(ch{ch_i}) - ones(size(lidar.range))*lidar.hk.bg.(ch{ch_i});
      lidar.prof.(ch{ch_i}) = lidar.prof.(ch{ch_i}) .* (r.squared * ones(size(lidar.time)));
   end
end


lidar.r = r;
% lidar.hk.bg_raw = bkgnd;
% lidar.hk.bg_std = bkgnd_std;
% if ~isstruct(profile_bins)
%    lidar.hk.bg = bg;
%    lidar.prof = lidar.rawcts - ones(size(range))*lidar.hk.bg;
%    lidar.prof = lidar.prof .* (r.squared * ones(size(lidar.time)));
% else
%    for ch_i = 1:length(ch)
%       lidar.hk.bg.(ch{ch_i}) = bg.(ch{ch_i});
%       lidar.prof.(ch{ch_i}) = lidar.rawcts.(ch{ch_i}) - ones(size(range))*lidar.hk.bg.(ch{ch_i});
%       lidar.prof.(ch{ch_i}) = lidar.prof.(ch{ch_i}) .* (r.squared * ones(size(lidar.time)));
%    end
% end

% clear ch_1



else
   lidar = [];
   status = -1;
end
% ProfileBins is averaged over ShotSummed shots and is in units of cts/microsecond.
%To get the original shots per bin, multiply ProfileBins by ShotsSummed and by BinTime in microseconds
% ProfileBins = ProfileBins * ShotsSummmed/(BinTime/1000);
%%
return
