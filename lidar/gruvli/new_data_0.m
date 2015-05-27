function [status] = new_data_0(cdfid)
% This process accepts a single open netcdf file and proceeds to convert 
% Limitations: hard-coded for a 2000 Hz pulse rep.

    % General-use variables --- get several variables from the netcdf file what are required for 
    % both copol and depol channels. 
    % disp(['Getting general use variables...']);
  
range  = nc_getvar(cdfid,  'range');
[bin_resolution, status] = nc_getvar(cdfid, 'bin_resolution');
if (status < 0) ; disp(['error getting ''bin_resolution'' from netcdf file' ]); pause; end;
% Convert bin_resolution (initially stored in nanoseconds) to seconds.
bin_resolution = bin_resolution * 1e-9;    
[accumulates, status]= nc_getvar(cdfid, 'accumulates');
if (status < 0) ; disp(['error getting ''accumulates'' from netcdf file' ]); pause; end;
samples = nc_getvar(cdfid, 'samples');

% get detector_A (copol)
 disp(['Beginning detector_A processing...']);

% disp(['Getting detector counts and sample std dev.']);
[detector_counts , status] = nc_getvar(cdfid, 'detector_A_532nm');
if (status < 0) ; disp(['error getting ''detector_A_532nm'' from netcdf file' ]); pause; end;
[sample_std, status] = nc_getvar(cdfid, 'detector_A_532nm_std');
if (status < 0) ; disp(['error getting ''detector_A_532nm_std'' from netcdf file' ]); pause; end;

% normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
disp(['Normalizing to get count rate in Hz.']);

[row,col] = size(detector_counts);
bkgnd = zeros([1,col]);
bkgnd_range = find(range > 31000); 
for i = 1:col
   detector_counts(:,i) = detector_counts(:,i) / (accumulates * bin_resolution * samples(i));
   if (max(detector_counts(:,i))<=0); 
       disp('Hey, detector_counts is zero!'); 
%       pause; 
   end;
   bkgnd(i) = mean(detector_counts(bkgnd_range,i));
   if (bkgnd(i)<=0);
%       disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
       pause;
   end;
   %Also normalize the sample std 
   sample_std(:,i) = sample_std(:,i)/ (accumulates * bin_resolution * samples(i));
end;
status = ncmex('VARPUT', cdfid, 'detector_A_532nm', [0,0], [-1,-1], detector_counts);
status = ncmex('VARPUT', cdfid, 'detector_A_532nm_std', [0,0], [-1,-1], sample_std);
status = ncmex('VARPUT', cdfid, 'detector_A_532nm_bkgnd', [0], [-1], bkgnd);

clear detector_counts sample_std bkgnd;

% get detector_B (depol)
 disp(['Beginning detector_B processing...']);

% disp(['Getting detector counts and sample std dev.']);
[detector_counts , status] = nc_getvar(cdfid, 'detector_B_532nm');
if (status < 0) ; disp(['error getting ''detector_B_532nm'' from netcdf file' ]); pause; end;
[sample_std, status] = nc_getvar(cdfid, 'detector_B_532nm_std');
if (status < 0) ; disp(['error getting ''detector_B_532nm_std'' from netcdf file' ]); pause; end;

% normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
disp(['Normalizing to get count rate in Hz.']);

[row,col] = size(detector_counts);
bkgnd = zeros([1,col]);
bkgnd_range = find(range > 31000); 
for i = 1:col
   detector_counts(:,i) = detector_counts(:,i) / (accumulates * bin_resolution * samples(i));
   if (max(detector_counts(:,i))<=0); 
       disp('Hey, detector_counts is zero!'); 
 %      pause; 
   end;
   bkgnd(i) = mean(detector_counts(bkgnd_range,i));
   if (bkgnd(i)<=0);
       disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
%       pause;
   end;
   %Also normalize the sample std 
   sample_std(:,i) = sample_std(:,i)/ (accumulates * bin_resolution * samples(i));
end;
status = ncmex('VARPUT', cdfid, 'detector_B_532nm', [0,0], [-1,-1], detector_counts);
status = ncmex('VARPUT', cdfid, 'detector_B_532nm_std', [0,0], [-1,-1], sample_std);
status = ncmex('VARPUT', cdfid, 'detector_B_532nm_bkgnd', [0], [-1], bkgnd);

[datatype, len, status] = ncmex('ATTINQ', cdfid, 'detector_B_532nm','units');
in_str = blanks(len);
in_str(1:2) = ['Hz'];
status = ncmex('ATTPUT', cdfid, 'detector_A_532nm', 'units', datatype, len, in_str);
status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_std', 'units', datatype, len, in_str);
status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_bkgnd', 'units', datatype, len, in_str);
status = ncmex('ATTPUT', cdfid, 'detector_B_532nm', 'units', datatype, len, in_str);
status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_std', 'units', datatype, len, in_str);
status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_bkgnd', 'units', datatype, len, in_str);

status = ncmex('VARPUT1', cdfid, 'data_level', [0], 3);
