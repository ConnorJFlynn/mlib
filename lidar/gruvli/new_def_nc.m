function [status] = new_def_nc(old_cdfid, new_cdfid)
% This process accepts two open cdfids; one for an existing lidar file, one for 
% a new lidar file.  It defines new_cdfid based on the first, except the 3-D variables
% (detector counts) are cast into float and the range field is prepared for re-ranging.
% All attributes are copied from the first file, with modifications/additions pertaining 
% the re-ranging and recasting mentioned above. 

% Limitations: hard-coded for a 2000 Hz pulse rep.

%First, define the dimensions 
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', old_cdfid);
for dimid = 0:ndims-1
    [dim_name, dim_len, status] = ncmex('DIMINQ', old_cdfid, dimid);
    if dimid == recdim; 
        status=ncmex('DIMDEF', new_cdfid, dim_name, 'UNLIMITED');
    else
        status = ncmex('DIMDEF', new_cdfid, dim_name, dim_len);
    end;
end;

%Then the global atts...
disp('Copying globals...');
for gatt = 0:natts-1
    [att_name, status] = ncmex('ATTNAME', old_cdfid, 'NC_GLOBAL', gatt);            
    status = ncmex('ATTCOPY', old_cdfid, 'NC_GLOBAL' , gatt, new_cdfid, 'NC_GLOBAL');
    if status < 0 ; disp(['Problem copying global att:' num2str(gatt)]);end;
end;

% Add history global att or append to it if it already exists...
new_entry = [];

instr = [datestr(now,31) ' : Cast detected counts into float',10];
new_entry = [new_entry , instr];

instr = [datestr(now,31) ' : Add history global attribute',10];
new_entry = [new_entry , instr];

instr = [datestr(now,31) ' : Add data_level static field',10];
new_entry = [new_entry , instr];

instr = [datestr(now,31) ' : Re-zero range fields',10];
new_entry = [new_entry , instr];

att_name = ['history'];
[datatype, len, status] = ncmex('ATTINQ', old_cdfid, -1, att_name);
if (status >= 0)
    % get existing history value, append new info...
    disp(['History global att exists, getting current value.'])
    [value, status] = ncmex('ATTGET', old_cdfid, -1, att_name);
    value = [value , new_entry]';
else
    value = [new_entry]';
end; 
status = ncmex('ATTPUT', new_cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value );

%Next, define the variables, but convert detector count vars from two-D int to float...
for varid = 0:nvars-1;
    [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, varid);
    if (ndims==2)&(datatype==4);
        status = ncmex('VARDEF', new_cdfid, var_name, 5, ndims, var_dim);
    else
        status = ncmex('VARDEF', new_cdfid, var_name, datatype, ndims, var_dim);
    end;
    if status < 0;
        disp([var_name, ' NOT successfully defined.']);
    end;
end;


%Next, create the field level attributes
for varid = 0:nvars-1;
    [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, varid);
    for var_att = 0:(natts-1)
        status = ncmex('ATTCOPY', old_cdfid, varid , var_att, new_cdfid, var_name);
        if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
    end;
end;

var_name = 'range';
att_name = 'missing_value';
datatype = 5;
len = 1;
value = -9999;
status = ncmex('ATTPUT', new_cdfid, var_name, att_name, datatype, len, value);
if status < 0;
    disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
end;        

att_name = 'comment_on_zero_range';
datatype = 2;
value = 'The range field has been adjusted to place zero range at the first bin.';
len = length(value);
status = ncmex('ATTPUT', new_cdfid, var_name, att_name, datatype, len, value);
if status < 0;
    disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
end;        

att_name = 'comment_on_far_range';
datatype = 2;
value = 'The far range was taken from bins collected prior to the laser flash.';
len = length(value);
status = ncmex('ATTPUT', new_cdfid, var_name, att_name, datatype, len, value);
if status < 0;
    disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
end;        
    
% Add new empty 3-D fields for subsequent lidar processing...
% Use details from a 'VARINQ' of detector_A_532nm for the rest...
[name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', new_cdfid, 'detector_A_532nm');

%Define 'copol_532nm'  
var_name = 'copol_532nm';
status = ncmex('VARDEF', new_cdfid, var_name,  'NC_FLOAT', ndims, dims);
    value = 'Copolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'long_name', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'units', 'NC_CHAR', length(value), value);
    value = 'background-subtracted, range-corrected, energy-normalized';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'corrections_applied', 'NC_CHAR', length(value), value);
    value = 'range-corrected only for ranges from 0-30km';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'comment_on_range_correction', 'NC_CHAR', length(value), value);

%Define 'copol_532nm_log'
var_name = 'copol_532nm_log';
status = ncmex('VARDEF', new_cdfid, var_name,  'NC_FLOAT', ndims, dims);
    value = 'Natural log of copolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'long_name', 'NC_CHAR', length(value), value);
    value = 'The following three-part background suppression has process has been applied:';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'Corrections', 'NC_CHAR', length(value), value);
    value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'bkgnd_part_1', 'NC_CHAR', length(value), value);
    value = 'Second part, take the natural log of the remaining signal from above.';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'bkgnd_part_2', 'NC_CHAR', length(value), value);
    value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'bkgnd_part_3', 'NC_CHAR', length(value), value);
    value = 'log(Hz)';
    status = ncmex('ATTPUT', new_cdfid, var_name,  'units', 'NC_CHAR', length(value), value);

%Define 'detector_A_532nm_noise'
% var_name = 'detector_A_532nm_noise';
% status = ncmex('VARDEF', new_cdfid, var_name,  'NC_FLOAT', ndims, dims);
%     value = 'Statistical noise of the 532nm detector A.';
%     status = ncmex('ATTPUT', new_cdfid, var_name,  'long_name', 'NC_CHAR', length(value), value);
%     value = 'This value is based on the sqrt of the total detected counts.';
%     status = ncmex('ATTPUT', new_cdfid, var_name,  'description', 'NC_CHAR', length(value), value);
%     value = '(Hz)*(m^2)/(microjoule)';
%     status = ncmex('ATTPUT', new_cdfid, var_name,  'units', 'NC_CHAR', length(value), value);

%Define 'copol_532nm_SNR'
var_name = 'copol_532nm_SNR';

status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'SNR of copolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as copol_532nm / detector_A_532nm_noise';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);     

%Update attributes of detector_A_532nm_std
var_name = 'detector_A_532nm_std';
    value = 'Scaled to remain on par with copol_532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'corrections_applied', 'NC_CHAR', length(value), value);
    value = 'Normalized against statistical noise.  High values indicate inhomogeneity';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'normalized', 'NC_CHAR', length(value), value);
  
%Update attributes of detector_A_532nm_bkgnd
var_name = 'detector_A_532nm_bkgnd';
    value = 'Scaled to Hz';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'corrections_applied', 'NC_CHAR', length(value), value);

%Define 'depol_532nm'  
%
var_name = 'depol_532nm';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'Depolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);
    value = 'deadtime-corrected, background-subtracted, range-corrected, energy-normalized';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'corrections_applied', 'NC_CHAR', length(value), value);
    value = 'range-corrected only for ranges from 0-30km';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'comment_on_range_correction', 'NC_CHAR', length(value), value);

%Define 'depol_532nm_log'
var_name = 'depol_532nm_log';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'Natural log of depolarized elastic backscatter at 532nm.';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'The following three-part background suppression has process has been applied:';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'Corrections', 'NC_CHAR', length(value), value);
    value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'bkgnd_part_1', 'NC_CHAR', length(value), value);
    value = 'Second part, take the natural log of the remaining signal from above.';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'bkgnd_part_2', 'NC_CHAR', length(value), value);
    value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'bkgnd_part_3', 'NC_CHAR', length(value), value);
    value = 'log(Hz)';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);

%Define 'detector_B_532nm_noise'
%var_name = 'detector_B_532nm_noise';
% status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
%     value = 'Statistical noise of the 532nm detector B.';
%     status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
%     value = 'This value is based on the sqrt of the total detected counts.';
%     status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
%     value = '(Hz)*(m^2)/(microjoule)';
%     status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);

%Define 'depol_532nm_SNR'
var_name = 'depol_532nm_SNR';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'SNR of depolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as depol_532nm / detector_B_532nm_noise';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);     

%Define 'depol_ratio'
var_name = 'depol_ratio_532nm';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'depolarization ratio of elastic backscatter at 532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as (depol)/(copol + depol)';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
    value = 'depol has been scaled with bkgnd_A_by_bkgnd_B';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'scaling of depol', 'NC_CHAR', length(value), value);  
    value = 'Unitless';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);  

%Define 'depol_strength_532nm'
var_name = 'depol_strength_532nm';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', ndims, dims);
    value = 'relative measure of depol_ratio strength';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as depol_ratio * depol_SNR^2';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);      
    
%Define 'bkgnd_A_by_bkgnd_B'
var_name = 'bkgnd_A_by_bkgnd_B';
status = ncmex('VARDEF', new_cdfid, var_name, 'NC_FLOAT', 0, []);
    value = 'Ratio of background at 532nm from detector A to detector B.';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as mean(bkgnd_A / bkgnd)) for bkgnd > 0.8 * mean(bkgnd)';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'units', 'NC_CHAR', length(value), value);     

%Update attributes of detector_B_532nm_std
var_name = 'detector_B_532nm_std';
    value = 'scaled on par with depol_532nm';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'corrections_applied', 'NC_CHAR', length(value), value);
    value = 'Normalized against statistical noise.  Low values indicate homogeneous conditions';
    status = ncmex('ATTPUT', new_cdfid, var_name, 'normalized', 'NC_CHAR', length(value), value);
  
%Update attributes of detector_B_532nm_bkgnd
    value = 'scaled to Hz';
    status = ncmex('ATTPUT', new_cdfid, 'detector_B_532nm_bkgnd', 'corrections_applied', 'NC_CHAR', length(value), value);

%Next, check for data_level field, define it if it doesn't exist.
var_name = 'data_level';
[var_id, status] = ncmex('VARID', old_cdfid, var_name);
if status < 0 ;
    %create data_level field in output file
    varid = nvars;
    var_name = 'data_level';
    datatype = 4;
    ndims = 0;
    var_dim = [];
    status = ncmex('VARDEF', new_cdfid , var_name, datatype, ndims, var_dim);
    if status < 0;
        disp([var_name, ' NOT successfully defined.']);
    end;
    data_level_id = varid;
end

    %Also add field-level attributes to data_level
var_name = 'data_level';
    att_name = 'long_name';
    value = 'Data_level indicating which corrections and data processing have been applied.'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    att_name = 'units';
    value = 'unitless'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    att_name = 'comment';
    value = 'The numeric value of data_level is the sum of the following bits representing different corrections.'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    
    att_name = 'bit_0_explanation';
    value = 'range and associated fields rearranged to put zero range at first bin position.'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;  
    
    att_name = 'bit_1_explanation';
    value = 'conversion of raw counts to count rate';
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_2_explanation';
    value = 'dead-time correction applied.  (Implies conversion of total counts to count rate in Hz.)'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_3_explanation';
    value = 'background-subtracted'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_4_explanation';
    value = 'range-correction applied to copol and depol channels.'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_5_explanation';
    value = 'log taken as 3-part noise suppression for copol_log and depol_log'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_6_explanation';
    value = 'overlap correction applied to non-log data'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;  
    
    att_name = 'bit_7_explanation';
    value = 'not currently used'; 
    status = ncmex('ATTPUT', new_cdfid, var_name, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end; 
    
% disp(['Parting status is: ' num2str(status)]);
