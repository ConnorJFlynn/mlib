function status = grli_base2_corr(cdfid, detA_to_detB);
% Requires open lidar netcdf file of at least data_level 0 (has history and data_level already)
% Applies background subtraction (of two types), range-correction, log, and SNR determination
% Populates: copol_532nm ,copol_532nm_log, copol_532nm_SNR, 
%            depol_532nm, depol_532nm_log, depol_532nm_SNR,
%            depol_ratio_532nm, depol_strength_532nm, bkgnd_A_by_bkgnd_B

% get det_A, det_A_std, det_A_bkgnd, range
% copol_532nm = (det_A - det_A_bkgnd)
% copol_532nm_log = log(det_A - min(det_A))
% copol_532nm_SNR = copol_532nm / sqrt(det_A * accums * samples * bin_time)
% Now, apply range correction: copol_532nm = copol_532nm * range^2
% get det_B, det_B_std, det_B_bkgnd
% depol_532nm = (det_B - det_B_bkgnd)
% depol_532nm_log = log(det_B - min(det_B))
% depol_532nm_SNR = depol_532nm / sqrt(det_B * accums * samples * bin_time)
% Now, apply range correction: depol_532nm = depol_532nm * range^2
% bkgnd_A_by_bkgnd_B = bkgnd_A / bkgnd_B
% depol_ratio_532nm = 
% depol_strength_532nm =

% Append to history
% set data_level bit_n on

% get detector_A (copol)
% detA_to_detB is an adhoc calibration of channel A versus channel B.  Initially, this is one.
if (nargin<2)
  detA_to_detB = 1 ;
end
% General-use variables --- get several variables from the netcdf file what are required for 
% both copol and depol channels. 
% disp(['Getting general use variables...']);
var_name = 'range';
[range , status] = nc_getvar(cdfid, var_name);
if (status < 0) ; disp(['error getting ',var_name,' from netcdf file' ]); pause; end;
var_name = 'bin_resolution';
[bin_resolution, status] = nc_getvar(cdfid, var_name);
if (status < 0) ; disp(['error getting ', var_name, ' from netcdf file' ]); pause; end;
% Convert bin_resolution (initially stored in nanoseconds) to seconds.
bin_resolution = bin_resolution * 1e-9;    
var_name = 'accumulates';
[accumulates, staus]= nc_getvar(cdfid, var_name);
if (status < 0) ; disp(['error getting ', var_name, ' from netcdf file' ]); pause; end;
var_name = 'samples';
samples = nc_getvar(cdfid, var_name);
[optical_power_532nm, status] = nc_getvar(cdfid, 'optical_power_532nm');
if (status < 0) ; disp(['error getting ', var_name, ' from netcdf file' ]); pause; end;
far = find(range>310000);

% disp(['Getting detector counts and sample std dev.']);
var_name = 'detector_A_532nm';
[detector_counts , status] = nc_getvar(cdfid, var_name);
[row,col] = size(detector_counts);
if (status < 0) ; disp(['error getting ',var_name,' from netcdf file' ]); pause; end;
var_name = 'detector_A_532nm_bkgnd';
[bkgnd, status] = nc_getvar(cdfid, var_name);
if (status < 0) ; disp(['error getting ', var_name, ' from netcdf file' ]); pause; end;
noise = zeros([row,col]);
for i = 1:col
    if (min(detector_counts(:,i)<=0)); 
        disp('Hey, detector_counts is zero!'); 
        pause; 
    end;
    signal(:,i) = (detector_counts(:,i) - bkgnd(i));
    detector_counts(:,i) = detector_counts(:,i) + 1e-7*bkgnd(i);
    signal_log(:,i) = log(detector_counts(:,i) - 0.999*min(detector_counts(:,i)));
    signal_log(:,i) = signal_log(:,i) * optical_power_532nm(i);
    noise(:,i) = sqrt(detector_counts(:,i) * (accumulates * bin_resolution * samples(i)));
    noise(:,i) = noise(:,i)/(accumulates * bin_resolution * samples(i));
end;
good = find((noise>0)&(signal>0));
SNR = zeros(size(signal));
SNR(good) = signal(good) ./ noise(good);
mean_log = mean(signal_log);
for i = 1:col
    range_corr = ones(size(range));
    signal(:,i) = signal(:,i).*(range).^2)';
    signal(:,i) = signal(:,i)/optical_power_532nm(i);
    signal_log(:,i) = signal_log(:,i) - mean_log(i);
end;
bkgnd_A = bkgnd;
copol = signal;
status = ncmex('VARPUT', cdfid, 'copol_532nm', [0,0], [-1,-1], signal);
status = ncmex('VARPUT', cdfid, 'copol_532nm_log', [0,0], [-1,-1], signal_log);
status = ncmex('VARPUT', cdfid, 'copol_532nm_SNR', [0,0], [-1,-1], SNR);

% % get detector_B (depol)
% disp(['Getting detector counts and sample std dev.']);
var_name = 'detector_B_532nm';
[detector_counts , status] = nc_getvar(cdfid, var_name);
[row,col] = size(detector_counts);
if (status < 0) ; disp(['error getting ',var_name,' from netcdf file' ]); pause; end;
var_name = 'detector_B_532nm_bkgnd';
[bkgnd, status] = nc_getvar(cdfid, var_name);
if (status < 0) ; disp(['error getting ', var_name, ' from netcdf file' ]); pause; end;
noise = zeros([row,col]);
for i = 1:col
    if (min(detector_counts(:,i)<=0)); 
        disp('Hey, detector_counts is zero!'); 
        pause; 
    end;
    signal(:,i) = (detector_counts(:,i) - bkgnd(i));
    detector_counts(:,i) = detector_counts(:,i) + 1e-7*bkgnd(i);
    signal_log(:,i) = log(detector_counts(:,i) - 0.999*min(detector_counts(:,i)));
    signal_log(:,i) = signal_log(:,i) * optical_power_532nm(i);
    noise(:,i) = sqrt(detector_counts(:,i) * (accumulates * bin_resolution * samples(i)));
    noise(:,i) = noise(:,i)/(accumulates * bin_resolution * samples(i));
end;
good = find((noise>0)&(signal>0));
SNR = zeros(size(signal));
SNR(good) = signal(good) ./ noise(good);
mean_log = mean(signal_log);
for i = 1:col
    signal(:,i) = signal(:,i).*(range.^2)';
    signal(:,i) = signal(:,i)/optical_power_532nm(i);
    signal_log(:,i) = signal_log(:,i) - mean_log(i);
end;
bkgnd_B = bkgnd;
depol = signal;
status = ncmex('VARPUT', cdfid, 'depol_532nm', [0,0], [-1,-1], signal);
status = ncmex('VARPUT', cdfid, 'depol_532nm_log', [0,0], [-1,-1], signal_log);
status = ncmex('VARPUT', cdfid, 'depol_532nm_SNR', [0,0], [-1,-1], SNR);

 depol = depol * detA_to_detB;

 good_sig = find(copol>0);
 depol_ratio = zeros(size(depol));
 depol_ratio(good_sig) = depol(good_sig)./(depol(good_sig) + copol(good_sig));
 depol_strength = depol_ratio .* SNR .* SNR;

 status = ncmex('VARPUT', cdfid, 'depol_ratio_532nm', [0,0], [-1,-1], depol_ratio);
 status = ncmex('VARPUT', cdfid, 'depol_strength_532nm', [0,0], [-1,-1], depol_strength);

[data_level, status] = nc_getvar(cdfid, 'data_level');
if (status < 0); disp(['Problem getting data_level ', var_name, '...']); end;
[data_level, data_level_str] = bit_on(data_level, 3);
[data_level, data_level_str] = bit_on(data_level, 4);
[data_level, data_level_str] = bit_on(data_level, 5);
status = ncmex('VARPUT1', cdfid, 'data_level', [0], data_level);
[status] = ncmex('REDEF', cdfid);
if (status < 0)
    disp('Error opening file for redef (before modifying range and history atts).');
else
    % append to history ...
    att_name = ['history'];
    new_entry = [];
    instr = [datestr(now,31) ' : background subtracted from copol_ and depol_ fields',10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : SNR calculated for copol_ and depol_ fields',10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : ratio of bkgnds calculated for depol ratio calcs',10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : depol ratio and depol ''strength'' calculated',10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : range-squared correction applied to copol and depol' ,10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : 3-part noise suppression of copol__log and depol__log' ,10];
    new_entry = [new_entry , instr];
    [datatype, len, status] = ncmex('ATTINQ', cdfid, -1, att_name);
    if (status >= 0)
        % get existing history value, append new info...
        % disp(['History global att exists, getting current value.'])
        [value, status] = ncmex('ATTGET', cdfid, -1, att_name);
        value = [value , new_entry]';
    else
        value = [new_entry]';
    end; 
    status = ncmex('ATTPUT', cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value );
    if (status < 0); disp(['Problem appending to history... ']); end;
    status = ncmex('ATTPUT', cdfid, 'depol_ratio_532nm', 'det_A_by_det_B', 5, 1, detA_to_detB);
    if (status < 0); disp(['Problem adding det_by_det attribute to depol_ratio_532nm... ']); end;
    [status] = ncmex('ENDEF', cdfid);
end;
