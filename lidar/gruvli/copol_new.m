% Outputs non-dtc bkgnd-sub range^2 to copol and copol_log to netcdf file

clear
[fname pname] = uigetfile('*.nc');
[cdfid] = ncmex('OPEN', [pname, fname], 'NC_WRITE');

[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid)
[name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cdfid, 'detector_A_532nm')
[status]  = ncmex('REDEF',cdfid);

  status = ncmex('VARDEF', cdfid, 'copol_532nm', datatype, ndims, dims)
  value = 'Total detected counts of copolarized elastic backscatter return per bin per averaging interval.';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'long_name', 'NC_CHAR', length(value), value);
  value = 'Corrections which have been applied are listed below:';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'Corrections', 'NC_CHAR', length(value), value);
  value = 'Background subtraction using middle 90% of bins preceding the laser pulse';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'background_subtraction', 'NC_CHAR', length(value), value);
  value = 'Range-squared correction based on zero time bin of first profile in file';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'range-squared', 'NC_CHAR', length(value), value);
  value = 'Counts';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'units', 'NC_CHAR', length(value), value);
  
  status = ncmex('VARDEF', cdfid, 'copol_532nm_log', datatype, ndims, dims)
  value = 'Natural Log of total detected counts of copolarized elastic backscatter return per bin per averaging interval.';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'long_name', 'NC_CHAR', length(value), value);
  value = 'The following three-part background suppression has process has been applied:';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'Corrections', 'NC_CHAR', length(value), value);
  value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_1', 'NC_CHAR', length(value), value);
  value = 'Second part, take the natural log of the remaining signal from above.';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_2', 'NC_CHAR', length(value), value);
  value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_3', 'NC_CHAR', length(value), value);
  value = 'log(Counts)';
  status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'units', 'NC_CHAR', length(value), value);
  
[status]  = ncmex('ENDEF',cdfid);
  
base_time = nc_getvar(cdfid, 'base_time');
time  = nc_getvar(cdfid, 'time');
time_Hh = time / 3600;
range  = nc_getvar(cdfid,  'range');
bin_resolution = nc_getvar(cdfid, 'bin_resolution');
bin_resolution = bin_resolution * 1e-9;
accumulates = nc_getvar(cdfid, 'accumulates');
samples = nc_getvar(cdfid, 'samples');
detector_A_532nm = nc_getvar(cdfid, 'detector_A_532nm');
optical_power_532nm = nc_getvar(cdfid, 'optical_power_532nm');
time_zero_bin = nc_getvar(cdfid, 'time_zero_bin');

[row,col] = size(detector_A_532nm);
copol_532nm = zeros([row,col]);
copol_532nm_log = zeros([row,col]);

under_range = find(range<0);
range(under_range)=0;
r2 = range .* range;

for i = 1:col
   bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
   bkgnd_ub = floor(0.95*time_zero_bin(i));
   copol_532nm(:,i) = detector_A_532nm(:,i) - mean(detector_A_532nm(bkgnd_lb:bkgnd_ub,i));
   copol_532nm(:,i) = copol_532nm(:,i) .* r2';
   copol_532nm_log(:,i) = log(detector_A_532nm(:,i) - 0.99*min(detector_A_532nm(:,i)));
   copol_532nm_log(:,i) = copol_532nm_log(:,i) - mean(copol_532nm_log(bkgnd_lb:bkgnd_ub,i));
end;
clear detector_A_532nm;

status = ncmex('VARPUT', cdfid, 'copol_532nm', [0,0], [-1,-1], copol_532nm);
status = ncmex('VARPUT', cdfid, 'copol_532nm_log', [0,0], [-1,-1], copol_532nm_log);

status = ncmex('CLOSE', cdfid);
sub = find((range>=60)&(range<=18060));

figure
imagesc(time_Hh, range(sub),copol_532nm(sub,:))
Title('Range-corrected Copol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
axis xy

axis xy
figure
imagesc(time_Hh, range(sub),copol_532nm_log(sub,:))
Title('Log-Scaled Copol 532 nm');
xlabel('Time (H.h GMT)');
ylabel('Range (meters)');
axis xy

