function [lidar] = read_mpace_lidar_raw(ncid)
% [lidar] = read_mpace_lidar(ncid);
% Read a PARSL lidar file from MPACE, apply corrections, generate plots
if nargin>1
   disp('usage: [lidar] = read_mpace_lidar(fname);');
   return;
elseif nargin == 0
  [fid, fname, pname] = getfile('*.nc','mpace');
  fname = [pname fname];
  fclose(fid);
  ncid = ncmex('open', [fname]);
end
max_out_range = 20; % Max range in km for output profiles.
%based on eyeball comparisons of depolarization ratio, we need about a factor of
%two reduction in depol.  Thus...
gain_adjust = 2.5;


base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time');

lidar.time = epoch2serial(base_time + time_offset);
statics.bin_resolution = nc_getvar(ncid, 'bin_resolution');
statics.accumulates = nc_getvar(ncid, 'accumulates');
hk.samples = nc_getvar(ncid, 'samples');
hk.laser_power = nc_getvar(ncid, 'optical_power_532nm');
raw.time_zero_bin = nc_getvar(ncid, 'time_zero_bin');

detA = nc_getvar(ncid, 'detector_A_532nm');
detB = nc_getvar(ncid, 'detector_B_532nm');
OCR  = nc_getvar(ncid, 'OCR_532nm');

[raw.ranges, times] = size(detA);
statics.range_bin_width = statics.bin_resolution * 1e-9 * 3e8 * 1e-3 / 2; %range bin width in km

raw.range_bin = [1:raw.ranges];
lidar.range = [0:statics.range_bin_width:max_out_range]';
lidar.r.ranges = length(lidar.range);
% Below we identify the laser spike, determine backgrounds, and output
% truncated profiles for copol, depol, and OCR.
for t = times:-1:1
   %spike = max(copol(:,t))'; % Not sure if it's better to use copol or
   %depol for spike detection...
   spike = max(detA(:,t))';
   spike = min(find(detA(:,t)==spike));
   if abs(spike-raw.time_zero_bin(t))>10
       spike = raw.time_zero_bin(t);
   end
   hk.cop_tz_bin(t) = spike;
   spike = max(detB(:,t))';
   spike = min(find(detB(:,t)==spike));
   if abs(spike-raw.time_zero_bin(t))>10
       spike = raw.time_zero_bin(t);
   end
   hk.dep_tz_bin(t) = spike;
   hk.tz_bin(t) = spike;
   hk.copol_bg(t) = mean(detA(1:floor(0.85*hk.tz_bin(t)),t));
   hk.depol_bg(t) = mean(detB(1:floor(0.85*hk.tz_bin(t)),t));
   hk.OCR_bg(t) = mean(OCR(1:floor(0.85*hk.tz_bin(t)),t));
   lidar.copol(:,t) = detA(spike:spike+lidar.r.ranges-1,t);
   lidar.depol(:,t) = detB(spike:spike+lidar.r.ranges-1,t);
   lidar.OCR(:,t) = OCR(spike:spike+lidar.r.ranges-1,t);
end
%clear detA detB OCR;
hk.copol_bg = hk.copol_bg;
hk.depol_bg = hk.depol_bg;
hk.OCR_bg = hk.OCR_bg;
hk.tz_bin = hk.tz_bin;
hk.cop_tz_bin = hk.cop_tz_bin;
hk.dep_tz_bin = hk.dep_tz_bin;
lidar.copol_noise = sqrt(lidar.copol);
lidar.depol_noise = sqrt(lidar.depol);
lidar.OCR_noise = sqrt(lidar.OCR);

r.r2 = (lidar.range > 0).*(lidar.range) .^2; 
r.lte_3 = find(lidar.range >0 & lidar.range <= 3);
r.lte_4 = find(lidar.range >0 & lidar.range <= 4);
r.lte_5 = find(lidar.range >0 & lidar.range <= 5);
r.lte_6 = find(lidar.range >0 & lidar.range <= 6);
r.lte_9 = find(lidar.range >0 & lidar.range <= 9);
r.lte_10 = find(lidar.range >0 & lidar.range <= 10);
r.lte_12 = find(lidar.range >0 & lidar.range <= 12);
r.lte_15 = find(lidar.range >0 & lidar.range <= 15);

[range, ol_corr] = mpace_overlap_20040928;
[ranges,times] = size(lidar.copol);
%Next subtract background and correct for range squared losses
[copol_ap, range] = mpace_copol_ap_20040928;
lidar.copol = (lidar.copol - ones(length(lidar.range),1)*(hk.copol_bg)) .* (r.r2 * ones(1,length(lidar.time)));
lidar.copol_noise = lidar.copol_noise .* (r.r2 * ones(1,length(lidar.time)));
% next, divide by the number of samples collected
lidar.copol = lidar.copol ./ (ones(length(lidar.range),1)*hk.samples);
lidar.copol_noise = lidar.copol_noise ./ (ones(length(lidar.range),1)*hk.samples);
% next, normalize in units of MHz by dividing by the number
% of accumulates per samples and by the bin resolution in microseconds
lidar.copol = lidar.copol ./(statics.accumulates * statics.bin_resolution * 1e-3);
lidar.copol_noise = lidar.copol_noise ./(statics.accumulates * statics.bin_resolution * 1e-3);
lidar.copol = (lidar.copol - copol_ap(1:ranges)*ones(1,times));

lidar.copol = lidar.copol .* (ol_corr(1:ranges)*ones(1,times));
lidar.copol_noise = lidar.copol_noise .* (ol_corr(1:ranges)*ones(1,times));
lidar.copol_by_power = lidar.copol ./ (ones(length(lidar.range),1)*hk.laser_power);

lidar.copol_SNR = zeros(size(lidar.copol));
pos = find(lidar.copol_noise>0);
lidar.copol_SNR(pos) = lidar.copol(pos) ./ lidar.copol_noise(pos);

% depol = nc_getvar(ncid, 'detector_B_532nm');
% dep_tz_bin = max(depol);
% lidar.depol_noise = sqrt(depol);
% [row,col] = size(depol);
% for t = col:-1:1
%    spike = max(depol(:,t))';
%    hk.dep_tz_bin(t) = find(depol(:,t)==spike);
%    hk.depol_bg(t) = mean(depol(1:floor(0.85*hk.dep_tz_bin(t)),t))';
% end
% hk.depol_bg = hk.depol_bg';
% hk.dep_tz_bin = hk.dep_tz_bin';
%first subtract background and correct for range squared losses

lidar.depol = (lidar.depol - ones(length(lidar.range),1)*hk.depol_bg) .* (r.r2 * ones(1,length(lidar.time)));
lidar.depol_noise = lidar.depol_noise .* (r.r2 * ones(1,length(lidar.time)));
% next, divide by the number of samples collected
lidar.depol = lidar.depol ./ (ones(length(lidar.range),1)*hk.samples);
lidar.depol_noise = lidar.depol_noise ./ (ones(length(lidar.range),1)*hk.samples);
% next, normalize in units of MHz by dividing by the number
% of accumulates per samples and by the bin resolution in microseconds
lidar.depol = lidar.depol ./(statics.accumulates * statics.bin_resolution * 1e-3);
[depol_ap, range] = mpace_depol_ap_20040928;
lidar.depol = (lidar.depol - depol_ap(1:ranges)*ones(1,times));
lidar.depol_noise = lidar.depol_noise ./(statics.accumulates * statics.bin_resolution * 1e-3);
lidar.depol = lidar.depol .* (ol_corr(1:ranges)*ones(1,times));
lidar.depol_noise = lidar.depol_noise .* (ol_corr(1:ranges)*ones(1,times));
%based on eyeball comparisons of depolarization ratio, we need about a factor of
%two reduction in depol.  Thus...
lidar.depol = lidar.depol / gain_adjust;
lidar.depol_noise = lidar.depol_noise / gain_adjust;

lidar.depol_SNR = zeros(size(lidar.depol));
pos = find(lidar.depol_noise>0);
lidar.depol_SNR(pos) = lidar.depol(pos) ./ lidar.depol_noise(pos);

% OCR = nc_getvar(ncid, 'OCR_532nm');
% lidar.OCR_noise = sqrt(OCR);
% 
% [row,col] = size(copol);
% for t = col:-1:1
%    hk.OCR_bg(t) = mean(OCR(1:floor(0.85*hk.dep_tz_bin(t)),t))';
% end
% hk.OCR_bg = hk.OCR_bg';
%OCR_bg = nc_getvar(ncid, 'detector_A_532nm_bkgnd');
%first subtract background and correct for range squared losses
lidar.OCR = (lidar.OCR - ones(length(lidar.range),1)*hk.OCR_bg) .* (r.r2 * ones(1,length(lidar.time)));
lidar.OCR_noise = lidar.OCR_noise .* (r.r2 * ones(1,length(lidar.time)));
% next, divide by the number of samples collected
lidar.OCR = lidar.OCR ./ (ones(length(lidar.range),1)*hk.samples);
lidar.OCR_noise = lidar.OCR_noise ./ (ones(length(lidar.range),1)*hk.samples);
% next, normalize in units of MHz by dividing by the number
% of accumulates per samples and by the bin resolution in microseconds
lidar.OCR = lidar.OCR ./(statics.accumulates * statics.bin_resolution * 1e-3);
[OCR_ap, range] = mpace_OCR_ap_20040928;
lidar.OCR = (lidar.OCR - OCR_ap(1:ranges) * ones(1,times));
lidar.OCR_noise = lidar.OCR_noise ./(statics.accumulates * statics.bin_resolution * 1e-3);
lidar.OCR_SNR = zeros(size(lidar.OCR));
pos = find(lidar.OCR_noise>0);
lidar.OCR_SNR(pos) = lidar.OCR(pos) ./ lidar.OCR_noise(pos);

pos = find(lidar.copol>0 & lidar.depol>0);
lidar.dpr = zeros(size(lidar.copol));
lidar.dpr_noise = zeros(size(lidar.copol));
lidar.dpr_SNR = zeros(size(lidar.copol));
lidar.dpr(pos) = lidar.depol(pos)./lidar.copol(pos);
lidar.dpr_noise(pos) = sqrt( (lidar.depol_noise(pos)./lidar.copol(pos)).^2 + ((lidar.depol(pos).*lidar.copol_noise(pos))./(lidar.copol(pos).^2)).^2);
lidar.dpr_SNR(pos) = lidar.dpr(pos) ./ lidar.dpr_noise(pos);
lidar.dpr_masked = lidar.dpr .* (lidar.dpr_SNR > 3);

statics.copol_ap = copol_ap;
statics.depol_ap = depol_ap;
statics.OCR_ap = OCR_ap;
statics.ol_corr = ol_corr;

lidar.statics = statics;
lidar.hk = hk;
lidar.r = r;

clear detA detB OCR;
if nargin == 0
   ncmex('close', ncid);
end

