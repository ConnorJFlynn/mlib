function [status] = data_0_to_1new(cdfid)
% This process accepts a single open netcdf file and proceeds to rearrange the 
% range associated fields to put the zero range at the first range bin.
% Limitations: hard-coded for a 2000 Hz pulse rep.
% Modifications to appropriate attributes, to history, and to data_level
% 2003-01-27: modified to improve memory usage by re-ranging matrices one column at a time.
%

%now (finally!) re-arrange range associated fields...
% disp('Next, re-arrange range associated fields...');

% speed of light c = 3e8 m/s
c = 3e8;
% MTC_Clock_Rate = 80 MHz = 80e6 tics/sec;
MTC_Clock_Rate = 80e6;
% MTC_Train_Rate = 40e3 tics/pulse;
MTC_Train_Rate = 40e3;

var_name = 'time_zero_bin';
[value, status] = nc_getvar(cdfid, var_name);
if status < 0; disp(['Problem getting ', var_name, ' from cdfid!']); 
    % else disp('Got time_zero-bin okay...');
end;
time_zero_bin = value;

var_name = 'range';
[value, status] = nc_getvar(cdfid, var_name);
if status < 0; disp(['Problem getting ', var_name, ' from cdfid!']); 
% else disp('Got range okay...');
end;
range = value;

% disp(['Re-ranging ', var_name, '...']);
%let's try a new definition of range that will be constant from file to file...

% These values are used to shift the range appropriatedly. 
% The idea is to use time_zero_bin to define the zero, but also to define the 
% a range limit short of the full extent of the profile. 
% We'll try a conservative range limit of 30,000 since this also works for 9.5 meter bins
% We also need a range limit in the other direction (before the laser fires).
% We'll try 8700 meters which is 580 bins (90% of 640) at 15 meter resolution.
% The entire range between will be undefined and left as -9999.
% The following conceptual limits are used to define the new range:
% profile_upper_range, profile_upper_range_bin
% profile_lower_range, profile_lower_range_bin
% bkgnd_upper_range, bkgnd_upper_range_bin
% bkgnd_lower_range, bkgnd_lower_range_bin
%The following other values are used to shift the range-dimensioned matrixes. 
% max_range: the effective distance seperating laser pulses
% ranges: simply the length of the range dimension/field
% time_zero_bin: when the laser flash occurs in the raw data

max_range = c /(2* ( MTC_Clock_Rate / MTC_Train_Rate));       
ranges = length(range);
%disp(['Number of range bins: ', num2str(ranges)]);

profile_u_range = 30000; %semi-arbitrarily set the range limit of interest to 30,000 meters
profile_u_range_bin = min(find(range>=profile_u_range));
if isempty(find(range >= profile_u_range));
    profile_u_range_bin = length(range);
end;
profile_l_range = 0;
profile_l_range_bin = min(find(range>=profile_l_range));
bkgnd_u_range = -500;
bkgnd_u_range_bin = max(find(range<bkgnd_u_range));
bkgnd_l_range = -8700;
bkgnd_l_range_bin = min(find(range>=bkgnd_l_range));

%         disp(['profile_u_range_bin = ', num2str(profile_u_range_bin)]);
%         disp(['profile_l_range_bin = ', num2str(profile_l_range_bin)]);
%         disp(['bkgnd_u_range_bin = ', num2str(bkgnd_u_range_bin)]);
%         disp(['bkgnd_l_range_bin = ', num2str(bkgnd_l_range_bin)]);

% prepopulate new_range with missings...
% then do the split/turn-around based on zero range. 
%
filled_range = -9999 * ones(size(range)); 
%Populate measurement profile portion of new_range (from 0 to 30,000 meters);
filled_range(profile_l_range_bin:profile_u_range_bin) = range(profile_l_range_bin:profile_u_range_bin);
%Populate background portion of new_range (8,700 meters before laser flash);
filled_range(bkgnd_l_range_bin:bkgnd_u_range_bin) = max_range + range(bkgnd_l_range_bin:bkgnd_u_range_bin);
% Now do the swapping around.
first_range_bin = min(find(range>0));
range(1:(ranges-first_range_bin+1)) = filled_range(first_range_bin:ranges);
range(2+(ranges-first_range_bin):ranges) = filled_range(1:first_range_bin-1);

status = nc_putvar(cdfid, 'range', range); 
if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;

%Now prepare to rearrange matrices containing range-dimensioned data...
%The time_zero_bin for each profile is used as this reference

%re-range detector_A_532nm
var_name = 'detector_A_532nm';
%         disp(['Re-ranging ', var_name, '...']);
[matrix, status] = nc_getvar(cdfid, var_name);
[ranges, times] = size(matrix);
new_column = zeros(ranges,1);
if status < 0; disp(['Problem getting ', var_name, 'from cdfid!']); end;
for i = 1:times;
   new_column(1:(ranges-time_zero_bin(i)+1)) = matrix(time_zero_bin(i):ranges,i);
   new_column(2+(ranges-time_zero_bin(i)):ranges) = matrix(1:time_zero_bin(i)-1,i);
   matrix(:,i) = new_column;
end;
status = nc_putvar(cdfid, var_name, matrix); 
if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
disp('Now done with detector_A_532nm');

%re-range detector_B_532nm
var_name = 'detector_B_532nm';
%         disp(['Re-ranging ', var_name, '...']);
[matrix, status] = nc_getvar(cdfid, var_name);
if status < 0; disp(['Problem getting ', var_name, 'from cdfid!']); end;
for i = 1:times;
   new_column(1:(ranges-time_zero_bin(i)+1)) = matrix(time_zero_bin(i):ranges,i);
   new_column(2+(ranges-time_zero_bin(i)):ranges) = matrix(1:time_zero_bin(i)-1,i);
   matrix(:,i) = new_column;
end;
status = nc_putvar(cdfid, var_name, matrix); 
if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
disp('Now done with detector_B_532nm');

%re-range detector_A_532nm_std
var_name = 'detector_A_532nm_std';
%         disp(['Re-ranging ', var_name, '...']);
[matrix, status] = nc_getvar(cdfid, var_name);
if status < 0; disp(['Problem getting ', var_name, 'from cdfid!']); end;
for i = 1:times;
   new_column(1:(ranges-time_zero_bin(i)+1)) = matrix(time_zero_bin(i):ranges,i);
   new_column(2+(ranges-time_zero_bin(i)):ranges) = matrix(1:time_zero_bin(i)-1,i);
   matrix(:,i) = new_column;
end;
status = nc_putvar(cdfid, var_name, matrix);
if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
disp('Now done with detector_A_532nm_std');

%re-range detector_B_532nm_std
var_name = 'detector_B_532nm_std';
%         disp(['Re-ranging ', var_name, '...']);
[matrix, status] = nc_getvar(cdfid, var_name);
if status < 0; disp(['Problem getting ', var_name, 'from cdfid!']); end;
for i = 1:times;
   new_column(1:(ranges-time_zero_bin(i)+1)) = matrix(time_zero_bin(i):ranges,i);
   new_column(2+(ranges-time_zero_bin(i)):ranges) = matrix(1:time_zero_bin(i)-1,i);
   matrix(:,i) = new_column;
end;
status = nc_putvar(cdfid, var_name, matrix);
disp('Now done with detector_B_532nm_std');

if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
status = ncmex('VARPUT1', cdfid, 'data_level', [0], 1);
[status] = ncmex('REDEF', cdfid);
if (status < 0)
    disp('Error opening file for redef (before modifying range and history atts).');
else
    %add attributes to range field describing the rearranging
    %probably need to use redef and endef for the below...
    
    var_name = 'range';
    att_name = 'missing_value';
    datatype = 5;
    len = 1;
    value = -9999;
    status = ncmex('ATTPUT', cdfid, var_name, att_name, datatype, len, value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;        
    
    att_name = 'comment_on_zero_range';
    datatype = 2;
    value = 'The range field has been adjusted to place zero range at the first bin.';
    len = length(value);
    status = ncmex('ATTPUT', cdfid, var_name, att_name, datatype, len, value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;        
    
    att_name = 'comment_on_far_range';
    datatype = 2;
    value = 'The far range was taken from bins collected prior to the laser flash.';
    len = length(value);
    status = ncmex('ATTPUT', cdfid, var_name, att_name, datatype, len, value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    
    % Add history global att or append to it if it already exists...
    att_name = ['history'];
    new_entry = [];
    instr = [datestr(now,31) ' : Re-zero range fields',10];
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
end;
[status] = ncmex('ENDEF', cdfid);
if (status < 0)
    disp('Error opening file for endef (after modifying range and history atts).');
end;