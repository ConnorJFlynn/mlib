function status = grli_dtc_maxcts(cdfid, det_A_dt, det_B_dt);
% Accepts open netcdf file and two scalar values specifying the deadtimes of detector A
% and detector B.  Applies deadtime correction R = D/(1-D*dt) with D as detected counts and
% dt as the supplied deadtimes. This method is being used instead of a parameterization of 
% the vendor-supplied dtc table because many of the counts seem to exceed the vendor-specified 
% saturation value.  Possibly a problem with the daq code or maybe associated with shorter bin 
% times.  Not yet determined... 

% Actions peformed:  deadtime correction, data_level increment, history append.

% get det_A, det_A_std, det_A_bkgnd
% apply dt for A
% get det_B, det_B_std, det_B_bkgnd
% apply dt for B
% set data_level bit_2 on
% Append to history

   
% get detector_A (copol)

% disp(['Getting detector counts and sample std dev.']);
[range , status] = nc_getvar(cdfid, 'range');
if (status < 0) ; disp(['error getting ''range'' from netcdf file' ]); pause; end;
[detector_counts , status] = nc_getvar(cdfid, 'detector_A_532nm');
if (status < 0) ; disp(['error getting ''detector_A_532nm'' from netcdf file' ]); pause; end;
[sample_std, status] = nc_getvar(cdfid, 'detector_A_532nm_std');
if (status < 0) ; disp(['error getting ''detector_A_532nm_std'' from netcdf file' ]); pause; end;
dt = det_A_dt;

% normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
% disp(['Normalizing to get count rate in Hz.']);

[row,col] = size(detector_counts);
bkgnd = zeros([1,col]);
bkgnd_range = find(range > 31000); 
good_cnts = find(detector_counts>0);
detector_corrected = zeros(size(detector_counts));
detector_corrected(good_cnts) = detector_counts(good_cnts) ./ (1-detector_counts(good_cnts) * dt);
%sample_std is scaled to the square root of the ratio of the corrected and uncorrected detector counts
sample_std(good_cnts) = sample_std(good_cnts) .* sqrt(detector_corrected(good_cnts) ./ detector_counts(good_cnts));
for i = 1:col
   bkgnd(i) = mean(detector_corrected(bkgnd_range,i));
   if (bkgnd(i)<=0);
%       disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
       pause;
   end;
   %Also normalize the sample std 
end;
status = ncmex('VARPUT', cdfid, 'detector_A_532nm', [0,0], [-1,-1], detector_corrected);
status = ncmex('VARPUT', cdfid, 'detector_A_532nm_std', [0,0], [-1,-1], sample_std);
status = ncmex('VARPUT', cdfid, 'detector_A_532nm_bkgnd', [0], [-1], bkgnd);

% get detector_B (depol)
% disp(['Getting detector counts and sample std dev.']);
[detector_counts , status] = nc_getvar(cdfid, 'detector_B_532nm');
if (status < 0) ; disp(['error getting ''detector_B_532nm'' from netcdf file' ]); pause; end;
[sample_std, status] = nc_getvar(cdfid, 'detector_B_532nm_std');
if (status < 0) ; disp(['error getting ''detector_B_532nm_std'' from netcdf file' ]); pause; end;
dt = det_B_dt;

% normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
% disp(['Normalizing to get count rate in Hz.']);

[row,col] = size(detector_counts);
bkgnd = zeros([1,col]);
bkgnd_range = find(range > 31000); 
good_cnts = find(detector_counts>0);
detector_corrected = zeros(size(detector_counts));
detector_corrected(good_cnts) = detector_counts(good_cnts) ./ (1-detector_counts(good_cnts) * dt);
%sample_std is scaled to the square root of the ratio of the corrected and uncorrected detector counts
sample_std(good_cnts) = sample_std(good_cnts) .* sqrt(detector_corrected(good_cnts) ./ detector_counts(good_cnts));
for i = 1:col
   bkgnd(i) = mean(detector_corrected(bkgnd_range,i));
   if (bkgnd(i)<=0);
%       disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
       pause;
   end;
   %Also normalize the sample std 
end;
status = ncmex('VARPUT', cdfid, 'detector_B_532nm', [0,0], [-1,-1], detector_corrected);
status = ncmex('VARPUT', cdfid, 'detector_B_532nm_std', [0,0], [-1,-1], sample_std);
status = ncmex('VARPUT', cdfid, 'detector_B_532nm_bkgnd', [0], [-1], bkgnd);
[data_level, status] = nc_getvar(cdfid, 'data_level');
if (status < 0); disp(['Problem getting data_level ', var_name, '...']); end;
[data_level, data_level_str] = bit_on(data_level, 2);
status = ncmex('VARPUT1', cdfid, 'data_level', [0], data_level);
[status] = ncmex('REDEF', cdfid);
if (status < 0)
    disp('Error opening file for redef (before modifying range and history atts).');
else
    % append to history ...
    att_name = ['history'];
    new_entry = [];
    instr = [datestr(now,31) ' : Apply deadtime correction as R = D/(1-D*dt)',10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : Detector A deadtime = ' num2str(det_A_dt) ,10];
    new_entry = [new_entry , instr];
    instr = [datestr(now,31) ' : Detector B deadtime = ' num2str(det_B_dt) ,10];
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
    [status] = ncmex('ENDEF', cdfid);
end;
