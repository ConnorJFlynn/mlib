function [status] = process_gr_li(cdf_file)
% Opens indicated gr_li netcdf file and carries out two separate signal extraction methods
%
% The first approach is a standard background subtraction using the mid-90% of bins preceding the 
% laser pulse followed by and range correction determined from the first profile in the file.  These 
% results are stored in the netcdf file as copol_532nm and depol_532nm.
%
% The second method is a 3-part approach with an initial removal of 99% of the minimum of each profile
% followed by a log, followed by a final removal of residual bkgnd determined from mid-90% of bins preceding the
% laser pulse (as in the first method).  The results are stored in the netcdf file as copol_532nm_log 
% and depol_532nm_log.

[cdfid] = ncmex('OPEN', cdf_file, 'NC_WRITE');

[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid);
[name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cdfid, 'detector_A_532nm');
[status]  = ncmex('REDEF',cdfid);

  status = ncmex('VARDEF', cdfid, 'copol_532nm', 'NC_FLOAT', ndims, dims);
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
  
  status = ncmex('VARDEF', cdfid, 'copol_532nm_log', 'NC_FLOAT', ndims, dims);
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
  
  status = ncmex('VARDEF', cdfid, 'depol_532nm', 'NC_FLOAT', ndims, dims);
  value = 'Total detected counts of depolarized elastic backscatter return per bin per averaging interval.';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'long_name', 'NC_CHAR', length(value), value);
  value = 'Corrections which have been applied are listed below:';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'Corrections', 'NC_CHAR', length(value), value);
  value = 'Background subtraction using middle 90% of bins preceding the laser pulse';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'background_subtraction', 'NC_CHAR', length(value), value);
  value = 'Range-squared correction based on zero time bin of first profile in file';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'range-squared', 'NC_CHAR', length(value), value);
  value = 'Counts';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'units', 'NC_CHAR', length(value), value);
  
  status = ncmex('VARDEF', cdfid, 'depol_532nm_log', 'NC_FLOAT', ndims, dims);
  value = 'Natural Log of total detected counts of copolarized elastic backscatter return per bin per averaging interval.';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'long_name', 'NC_CHAR', length(value), value);
  value = 'The following three-part background suppression has process has been applied:';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'Corrections', 'NC_CHAR', length(value), value);
  value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_1', 'NC_CHAR', length(value), value);
  value = 'Second part, take the natural log of the remaining signal from above.';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_2', 'NC_CHAR', length(value), value);
  value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_3', 'NC_CHAR', length(value), value);
  value = 'log(Counts)';
  status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'units', 'NC_CHAR', length(value), value);
  
  
[status]  = ncmex('ENDEF',cdfid);
  
base_time = nc_getvar(cdfid, 'base_time');
time  = nc_getvar(cdfid, 'time');
time_Hh = time / 3600;
range  = nc_getvar(cdfid,  'range');
bin_resolution = nc_getvar(cdfid, 'bin_resolution');
bin_resolution = bin_resolution * 1e-9;
accumulates = nc_getvar(cdfid, 'accumulates');
samples = nc_getvar(cdfid, 'samples');
optical_power_532nm = nc_getvar(cdfid, 'optical_power_532nm');
time_zero_bin = nc_getvar(cdfid, 'time_zero_bin');

under_range = find(range<0);
range(under_range)=0;
r2 = range .* range;

detector_A_532nm = nc_getvar(cdfid, 'detector_A_532nm');
[row,col] = size(detector_A_532nm);
copol_532nm = zeros([row,col]);
copol_532nm_log = zeros([row,col]);

for i = 1:col
   detector_A_532nm(:,i) = detector_A_532nm(:,i) / (accumulates * bin_resolution * samples(i));
   bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
   bkgnd_ub = floor(0.95*time_zero_bin(i));
   copol_532nm(:,i) = detector_A_532nm(:,i) - mean(detector_A_532nm(bkgnd_lb:bkgnd_ub,i));
   copol_532nm(:,i) = copol_532nm(:,i) .* r2';
   %following step ensures non-negative values unless mean is actually zero in which case we have a problem
   copol_532nm_log(:,i) = detector_A_532nm(:,i) + 0.00001 * mean(detector_A_532nm(bkgnd_lb:bkgnd_ub,i));
   copol_532nm_log(:,i) = log(copol_532nm_log(:,i) - 0.99*min(copol_532nm_log(:,i)));
   copol_532nm_log(:,i) = copol_532nm_log(:,i) - mean(copol_532nm_log(bkgnd_lb:bkgnd_ub,i));
end;

clear detector_A_532nm;
status = ncmex('VARPUT', cdfid, 'copol_532nm', [0,0], [-1,-1], copol_532nm);
status = ncmex('VARPUT', cdfid, 'copol_532nm_log', [0,0], [-1,-1], copol_532nm_log);
clear copol_532nm;
clear copol_532nm_log;

detector_B_532nm = nc_getvar(cdfid, 'detector_B_532nm');
[row,col] = size(detector_B_532nm);
depol_532nm = zeros([row,col]);
depol_532nm_log = zeros([row,col]);
for i = 1:col
   detector_B_532nm(:,i) = detector_B_532nm(:,i) / (accumulates * bin_resolution * samples(i) );
   bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
   bkgnd_ub = floor(0.95*time_zero_bin(i));
   depol_532nm(:,i) = detector_B_532nm(:,i) - mean(detector_B_532nm(bkgnd_lb:bkgnd_ub,i));
   depol_532nm(:,i) = depol_532nm(:,i) .* r2';
   %following step ensures non-negative values unless mean is actually zero in which case we have a problem   
   depol_532nm_log(:,i) = detector_B_532nm(:,i) + 0.00001 * mean(detector_B_532nm(bkgnd_lb:bkgnd_ub,i));
   depol_532nm_log(:,i) = log(depol_532nm_log(:,i) - 0.99*min(depol_532nm_log(:,i)));
   depol_532nm_log(:,i) = depol_532nm_log(:,i) - mean(depol_532nm_log(bkgnd_lb:bkgnd_ub,i));
end
clear detector_B_532nm;

status = ncmex('VARPUT', cdfid, 'depol_532nm', [0,0], [-1,-1], depol_532nm);
status = ncmex('VARPUT', cdfid, 'depol_532nm_log', [0,0], [-1,-1], depol_532nm_log);

clear copol_532nm;
clear copol_532nm_log;

status = ncmex('CLOSE', cdfid);
