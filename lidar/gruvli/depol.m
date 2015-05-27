clear
[fname pname] = uigetfile('*.nc');
[cdfid] = ncmex('OPEN', [pname, fname], 'NC_WRITE');

base_time = nc_getvar(cdfid, 'base_time');
time  = nc_getvar(cdfid, 'time');
time_Hh = time / 3600;
range  = nc_getvar(cdfid,  'range');
bin_resolution = nc_getvar(cdfid, 'bin_resolution');
bin_resolution = bin_resolution * 1e-9;
accumulates = nc_getvar(cdfid, 'accumulates');
samples = nc_getvar(cdfid, 'samples');
detector_B_532nm = nc_getvar(cdfid, 'detector_B_532nm');
optical_power_532nm = nc_getvar(cdfid, 'optical_power_532nm');
time_zero_bin = nc_getvar(cdfid, 'time_zero_bin');

[row,col] = size(detector_B_532nm);
depol_532nm = zeros([row,col]);
depol_532nm_log = zeros([row,col]);

under_range = find(range<0);
range(under_range)=0;
r2 = range .* range;

for i = 1:col
   bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
   bkgnd_ub = floor(0.95*time_zero_bin(i));
   depol_532nm(:,i) = detector_B_532nm(:,i) - mean(detector_B_532nm(bkgnd_lb:bkgnd_ub,i));
   depol_532nm(:,i) = depol_532nm(:,i) .* r2';
   depol_532nm_log(:,i) = log(detector_B_532nm(:,i) - 0.99*min(detector_B_532nm(:,i)));
   depol_532nm_log(:,i) = depol_532nm_log(:,i) - mean(depol_532nm_log(bkgnd_lb:bkgnd_ub,i));
end
clear detector_B_532nm;

sub = find((range>=60)&(range<=18060));

figure
imagesc(time_Hh, range(sub),depol_532nm(sub,:))
Title('Range-corrected Depol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
axis xy

figure
imagesc(time_Hh, range(sub),depol_532nm_log(sub,:))
Title('Log-Scaled Depol 532 nm');
axis xy
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
