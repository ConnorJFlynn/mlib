function [status] = mpace_reformat(in_ncid, out_ncid, in_filename)
%[status] = mpace_reformat(in_ncid, out_ncid)
% This process accepts two open ncids; one for an existing lidar file, one for 
% a new lidar file.  It defines out_ncid with input from the first but not exclusively.
% Limitations: hard-coded for a 2000 Hz pulse rep and 30 meter resolution.
% Exclusions: sample std_dev are not included in this initial product.

%Parse the in_filename to strip the path
while length(in_filename)>0
  [fname, in_filename] = strtok(in_filename, '/\');
end
%First, read in the existing file
[lidar] = read_mpace_lidar_raw(in_ncid);
%Next, define the dimensions 
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', in_ncid);

for dimid = 0:ndims-1
   [dim_name, dim_len, status] = ncmex('DIMINQ', in_ncid, dimid);
   if dimid == recdim; %then this is 'time' which is unlimited.
      status=ncmex('DIMDEF', out_ncid, dim_name, 'UNLIMITED');
   else %then this is range.  Redefine the length to 667 for 20.0 km max range with 30 meter bins
      status = ncmex('DIMDEF', out_ncid, dim_name, length(lidar.range));
   end;
   if status < 0;
      disp([dim_name, ' NOT successfully defined.']);
   end;
end;

%Global atts
att_name = 'ingest_software';
value = ['PARSL GR_LI lidar_daq.exe'];
status = ncmex('ATTPUT', out_ncid, 'nc_global', att_name, 'nc_char', length(value)+1, value);

att_name = 'input-source';
value = [fname];
status = ncmex('ATTPUT', out_ncid, 'nc_global', att_name, 'nc_char', length(value)+1, value);

att_name = 'zeb_platform';
value = ['mpace.oliktok.parsl_lidar.c1'];
status = ncmex('ATTPUT', out_ncid, 'nc_global', att_name, 'nc_char', length(value)+1, value);

% Add history global att 
new_entry = [];

instr = [datestr(now,31) ' : Add history global attribute',10];
new_entry = [new_entry , instr];

% instr = [datestr(now,31) ' : Add data_level static field',10];
% new_entry = [new_entry , instr];

att_name = ['history'];
[datatype, len, status] = ncmex('ATTINQ', in_ncid, -1, att_name);
value = [new_entry]';

status = ncmex('ATTPUT', out_ncid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value );
if status < 0;
   disp([att_name, ' NOT successfully defined.']);
end;
    
%Next, define the variables...
%define base_time
in_var = 'base_time';
out_var = 'base_time';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;

% 
% for var_att = 0:(natts-1)
%    [att_name, status] = ncmex('ATTNAME', in_ncid, in_var, var_att);
%    [datatype, len, status] = ncmex('ATTINQ', in_ncid, in_var, att_name);
%    [value, status] = ncmex('ATTGET', in_ncid, in_var, var_att);
%    status = ncmex('ATTPUT', out_ncid, out_var, att_name, datatype, len, value);
%    if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
% end;

%define the 'time-offset' field ala ARM using the 'time' field
in_var = 'time';
out_var = 'time_offset';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
% for var_att = 0:(natts-1)
%    [att_name, status] = ncmex('ATTNAME', in_ncid, in_var, var_att);
%    [datatype, len, status] = ncmex('ATTINQ', in_ncid, in_var, att_name);
%    [value, status] = ncmex('ATTGET', in_ncid, in_var, var_att);
%    status = ncmex('ATTPUT', out_ncid, out_var, att_name, datatype, len, value);
% %    status = ncmex('ATTCOPY', in_ncid, in_var , var_att, out_ncid, out_var);
%    if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
% end;

%also define the new 'time' field based on 00:00 UTC
in_var = 'time';
out_var = 'time';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
% for var_att = 0:(natts-1)
%    [att_name, status] = ncmex('ATTNAME', in_ncid, in_var, var_att);
%    [datatype, len, status] = ncmex('ATTINQ', in_ncid, in_var, att_name);
%    [value, status] = ncmex('ATTGET', in_ncid, in_var, var_att);
%    status = ncmex('ATTPUT', out_ncid, out_var, att_name, datatype, len, value);
% %    status = ncmex('ATTCOPY', in_ncid, in_var , var_att, out_ncid, out_var);
%    if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
% end;

%define the 'range' field 
in_var = 'range';
out_var = 'range';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['range to the center of the corresponding bin'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

att_name = 'units';
value = ['km'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define accumulates
in_var = 'accumulates';
out_var = in_var;
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
att_name = 'long_name';
value = ['Number of laser pulse profile accumulated on MCS for each acquisition.'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define bin_resolution
in_var = 'bin_resolution';
out_var = in_var;
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
att_name = 'long_name';
value = ['resolution of MCS bins'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['ns'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define bin_resolution
out_var = 'range_bin_width';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
att_name = 'long_name';
value = ['range bin spatial width'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['km'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define static range-reference fields:
%copol afterpulse correction
in_var = 'range';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);

out_var = 'copol_532nm_ap';
%lidar.statics.copol_ap = copol_ap;
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['afterpulse correction for copol 532nm channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'source';
value = ['green_lidar.ap.20040928.062221.nc'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);


%define crosspol afterpulse correction
out_var = 'crosspol_532nm_ap';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['afterpulse correction for crosspol 532nm channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'source';
value = ['green_lidar.ap.20040928.062221.nc'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%lidar.statics.depol_ap = depol_ap;

%define OCR afterpulse correction
out_var = 'OCR_532nm_ap';
%lidar.statics.OCR_ap = OCR_ap;
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['afterpulse correction for OCR 532nm channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'source';
value = ['green_lidar.ap.20040928.062221.nc'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define overlap correction 532nm 
out_var = 'ol_corr_532nm';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['overlap correction for 532nm narrow field of view channels'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'source';
value = ['Vertical clear sky data on 2004-09-28 used in Matlab function mpace_overlap_20040928.m'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%lidar.statics.ol_corr = ol_corr;
%

%define optical_power_532nm;
in_var = 'optical_power_532nm';
out_var = 'optical_power_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);

status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['optical power of 532nm laser'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['mW'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define samples;
in_var = 'samples';
out_var = in_var;
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);

status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['accumulated samples per averaging interval'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define time_zero_bin;
in_var = 'time_zero_bin';
out_var = in_var;
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);

status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['bin index of laser spike'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined by the lidar_daq as the first bin to exceed a supplied threshold value'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define cop_tz_bin;
out_var = 'cop_tz_bin';
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['bin index of laser spike determined from copol profile'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined as the bin index of the maximum value during each averaging interval'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define dep_tz_bin;
out_var = 'dep_tz_bin';
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['bin index of laser spike determined from crosspol profile'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined as the bin index of the maximum value during each averaging interval'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define copol_bg
in_var = 'detector_A_532nm_bkgnd';
out_var = 'copol_bg';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
att_name = 'long_name';
value = ['background in copol channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined from 80% of bins before zero_time_bin.'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define depol_bg
in_var = 'detector_B_532nm_bkgnd';
out_var = 'crosspol_bg';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
att_name = 'long_name';
value = ['background in depol channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined from 80% of bins before zero_time_bin.'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define OCR_bg
in_var = 'OCR_532nm_bkgnd';
out_var = 'OCR_bg';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
att_name = 'long_name';
value = ['background in OCR channel'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['count'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Determined from 80% of bins before zero_time_bin.'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define copol_532nm;
in_var = 'detector_A_532nm';
out_var = 'copol_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['sample-averaged co-polarized elastic backscatter'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'detector_type';
status = ncmex('ATTCOPY', in_ncid, in_var, 'name', out_ncid, out_var);
att_name = 'description';
value = ['This is uncalibrated attenuated backscatter as the raw detector count rate with corrections applied for background, range-squared, afterpulse and overlap'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define copol_by_power;
out_var = 'copol_by_power';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['co-polarized elastic backscatter normalized to laser power'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz/mW'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['Not sure if noise in power measurement is greater than the actual power fluctuation. Also not sure yet how to propagate error. '];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define copol_532nm_SNR;
out_var = 'copol_532nm_SNR';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['co-polarized elastic backscatter signal to noise'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['The signal to noise ratio is based on assumed Poisson statistic'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);


%define crosspol_532nm;
in_var = 'detector_B_532nm';
out_var = 'crosspol_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['sample-averaged cross-polarized elastic backscatter'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'detector_type';
status = ncmex('ATTCOPY', in_ncid, in_var, 'name', out_ncid, out_var);
att_name = 'description';
value = ['This is uncalibrated attenuated backscatter as the raw detector count rate with corrections applied for background, range-squared, afterpulse and overlap'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);


%define crosspol_532nm_SNR;
out_var = 'crosspol_532nm_SNR';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['cross-polarized elastic backscatter signal to noise'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['The signal to noise ratio is based on assumed Poisson statistic'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);


%define OCR_532nm;
in_var = 'OCR_532nm';
out_var = 'OCR_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['sample-averaged Overlap Correction Receiver elastic backscatter'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['MHz'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'detector_type';
status = ncmex('ATTCOPY', in_ncid, in_var, 'name', out_ncid, out_var);
att_name = 'description';
value = ['This is wide-field of view channel is used to correct for near-field overlap issues.'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define OCR_532nm_SNR;
out_var = 'OCR_532nm_SNR';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['Overlap Correction Receiver signal to noise ratio'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'description';
value = ['The signal to noise ratio is based on assumed Poisson statistic'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define dpr_532nm;
out_var = 'dpr_532nm';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['elastic backscatter linear depolarization ratio'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'definition';
value = ['dpr_532nm = crosspol_532nm / copol_532nm'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define dpr_532nm_SNR;
out_var = 'dpr_532nm_SNR';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['elastic backscatter linear depolarization signal to noise ratio'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);

%define dpr_masked;
out_var = 'dpr_532nm_masked';
status = ncmex('VARDEF', out_ncid, out_var, 'nc_float', ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
att_name = 'long_name';
value = ['elastic backscatter linear depolarization ratio'];
status = ncmex('ATTPUT', out_ncid, out_var, att_name, 'nc_char', length(value)+1, value);
att_name = 'units';
value = ['unitless'];
status = ncmex('ATTPUT', out_ncid, out_var , att_name, 'nc_char', length(value)+1, value);
att_name = 'explanation';
value = ['dpr_532nm but set to zero when dpr_SNR < 3'];
status = ncmex('ATTPUT', out_ncid, out_var , att_name, 'nc_char', length(value)+1, value);


% %create data_level field in output file
% in_var = 'data_level';
% out_var = 'data_level';
% [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', in_ncid, in_var);
% status = ncmex('VARDEF', out_ncid, out_var, datatype, ndims, var_dim);
% if status < 0;
%    disp([var_name, ' NOT successfully defined.']);
% end;
% for var_att = 0:(natts-1)
% [att_name, status] = ncmex('ATTNAME', in_ncid, in_var, var_att);
%    [datatype, len, status] = ncmex('ATTINQ', in_ncid, in_var, att_name);
%    [value, status] = ncmex('ATTGET', in_ncid, in_var, var_att);
%    status = ncmex('ATTPUT', out_ncid, out_var, att_name, datatype, len, value);
%    if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
% end;

status = ncmex('ENDEF', out_ncid);

%Next, fix the time fields. 
in_var = 'base_time';
out_var = 'base_time';
[base_time,status] = nc_getvar(in_ncid,in_var);
in_var = 'time';
out_var = 'time_offset';
time_offset = nc_getvar(in_ncid,in_var);
epoch_time = base_time + time_offset;

base_time = min(epoch_time);
serial_base_time = epoch2serial(base_time);
[status] = nc_putvar(out_ncid, 'base_time', base_time);

att_name = 'string';
base_time_str = [datestr(serial_base_time,1),',', datestr(serial_base_time,13), ' GMT'];
len = length(base_time_str)+1;
status = ncmex('ATTPUT', out_ncid, 'base_time', 'string', 'nc_char', len, base_time_str);

att_name = 'long_name';
value = 'Base time in Epoch';
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'base_time', att_name, 'nc_char', len, value);

att_name = 'units';
value = 'seconds since 1970-1-1 0:00:00 0:00';
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'base_time', att_name, 'nc_char', len, value);


time_offset = epoch_time - base_time;
[status] = nc_putvar(out_ncid, 'time_offset', time_offset);

att_name = 'long_name';
value = 'Time offset from base_time';
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'time_offset', att_name, 'nc_char', len, value);

att_name = 'units';
value = ['seconds since ', datestr(serial_base_time,29), ' ', datestr(serial_base_time,13), ' 0:00'];
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'time_offset', att_name, 'nc_char', len, value);

serial_time = epoch2serial(epoch_time);

time_base = serial2epoch(floor(serial_time(1)));
time = epoch_time - time_base;
[status] = nc_putvar(out_ncid, 'time', time);

att_name = 'long_name';
value = 'Time offset from midnight';
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'time', att_name, 'nc_char', len, value);

att_name = 'units';
value = ['seconds since ', datestr(floor(serial_time(1)),29), ' ', datestr(floor(serial_time(1)),13), ' 0:00'];
len = length(value)+1;
status = ncmex('ATTPUT', out_ncid, 'time', att_name, 'nc_char', len, value);

[status] = nc_putvar(out_ncid, 'range', lidar.range);
[status] = nc_putvar(out_ncid, 'time_zero_bin', lidar.hk.tz_bin);
[status] = nc_putvar(out_ncid, 'copol_532nm_ap', lidar.statics.copol_ap);
[status] = nc_putvar(out_ncid, 'crosspol_532nm_ap', lidar.statics.depol_ap);
[status] = nc_putvar(out_ncid, 'OCR_532nm_ap', lidar.statics.OCR_ap);
[status] = nc_putvar(out_ncid, 'ol_corr_532nm', lidar.statics.ol_corr);

[status] = nc_putvar(out_ncid, 'cop_tz_bin', lidar.hk.cop_tz_bin);
[status] = nc_putvar(out_ncid, 'dep_tz_bin', lidar.hk.dep_tz_bin);
[status] = nc_putvar(out_ncid, 'copol_bg', lidar.hk.copol_bg);
[status] = nc_putvar(out_ncid, 'crosspol_bg', lidar.hk.depol_bg);
[status] = nc_putvar(out_ncid, 'OCR_bg', lidar.hk.OCR_bg);
[status] = nc_putvar(out_ncid, 'samples', lidar.hk.samples);
[status] = nc_putvar(out_ncid, 'laser_power', lidar.hk.laser_power);


[status] = nc_putvar(out_ncid, 'bin_resolution', lidar.statics.bin_resolution);
[status] = nc_putvar(out_ncid, 'range_bin_width', lidar.statics.range_bin_width);

[status] = nc_putvar(out_ncid, 'copol_532nm', lidar.copol);
[status] = nc_putvar(out_ncid, 'copol_by_power', lidar.copol_by_power);
[status] = nc_putvar(out_ncid, 'copol_532nm_SNR', lidar.copol_SNR);

[status] = nc_putvar(out_ncid, 'crosspol_532nm', lidar.depol);
[status] = nc_putvar(out_ncid, 'crosspol_532nm_SNR', lidar.depol_SNR);

[status] = nc_putvar(out_ncid, 'OCR', lidar.OCR);

[status] = nc_putvar(out_ncid, 'dpr_532nm', lidar.dpr);
[status] = nc_putvar(out_ncid, 'dpr_532nm_SNR', lidar.dpr_SNR);
[status] = nc_putvar(out_ncid, 'dpr_532nm_masked', lidar.dpr_masked);

[status] = nc_putvar(out_ncid, 'accumulates', lidar.statics.accumulates);
[test] = nc_getvar(out_ncid, 'accumulates');
if (test ~= lidar.statics.accumulates)
   disp('Bad nc read');
end;
