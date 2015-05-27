% On-screen plots of background-subtracted and range-corrected data, no dtc
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
detector_A_532nm = nc_getvar(cdfid, 'detector_A_532nm');
detector_B_532nm = nc_getvar(cdfid, 'detector_B_532nm');
optical_power_532nm = nc_getvar(cdfid, 'optical_power_532nm');
time_zero_bin = nc_getvar(cdfid, 'time_zero_bin');

[row,col] = size(detector_A_532nm);
ch_A = zeros([row,col]);
ch_A_r2 = zeros([row,col]);
ch_A_4log = zeros([row,col]);
ch_B = zeros([row,col]);
ch_B_r2 = zeros([row,col]);
ch_B_4log = zeros([row,col]);

for i = 1:col
   bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
   bkgnd_ub = floor(0.95*time_zero_bin(i));
   ch_A(:,i) = detector_A_532nm(:,i) - mean(detector_A_532nm(bkgnd_lb:bkgnd_ub,i));
   ch_B(:,i) = detector_B_532nm(:,i) - mean(detector_B_532nm(bkgnd_lb:bkgnd_ub,i));
end;
under_range = find(range<0);
range(under_range)=0;
r2 = range .* range;
for i = 1:col
   ch_B_r2(:,i) = ch_B(:,i) .* r2';
   ch_A_r2(:,i) = ch_A(:,i) .* r2';
end

for i = 1:col
   ch_B_log(:,i) = log(detector_B_532nm(:,i) - 0.99*min(detector_B_532nm(:,i)));
   ch_B_log(:,i) = ch_B_log(:,i) - mean(ch_B_log(bkgnd_lb:bkgnd_ub,i));
   ch_A_log(:,i) = log(detector_A_532nm(:,i) - 0.99*min(detector_A_532nm(:,i)));
   ch_A_log(:,i) = ch_A_log(:,i) - mean(ch_A_log(bkgnd_lb:bkgnd_ub,i));
end
sub = find((range>=60)&(range<=18060));

figure
imagesc(time_Hh, range(sub),ch_A_r2(sub,:))
Title('Range-corrected Copol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
axis xy

figure
imagesc(time_Hh, range(sub),ch_B_r2(sub,:))
Title('Range-corrected Depol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');

axis xy
figure
imagesc(time_Hh, range(sub),ch_A_log(sub,:))
Title('Log-Scaled Copol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
axis xy

figure
imagesc(time_Hh, range(sub),ch_B_log(sub,:))
Title('Log-Scaled Depol 532 nm');
axis xy
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
