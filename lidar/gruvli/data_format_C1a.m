function [status] = data_format_C1a(old_cdfid, new_cdfid)

% This process accepts two open cdfids; one for an existing lidar file, one for 
% a new lidar file.  It defines new_cdfid with input from the first but not exclusively.

% The only difference between C1a and C1 is that range for C1a extends to 17.5 km 1188 bins

% Limitations: hard-coded for a 2000 Hz pulse rep.

%First, define the dimensions 
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', old_cdfid);

for dimid = 0:ndims-1
   [dim_name, dim_len, status] = ncmex('DIMINQ', old_cdfid, dimid);
   if dimid == recdim; %then this is 'time' which is unlimited.
      status=ncmex('DIMDEF', new_cdfid, dim_name, 'UNLIMITED');
%    else %then this is range.  Redefine the length to 1018 for 15 km max range
%       status = ncmex('DIMDEF', new_cdfid, dim_name, 1018);
   else %then this is range.  Redefine the length to 1188 for 17.5 km max range
      status = ncmex('DIMDEF', new_cdfid, dim_name, 1188);
   end;
   if status < 0;
      disp([dim_name, ' NOT successfully defined.']);
   end;
end;

% Add history global att 
new_entry = [];

instr = [datestr(now,31) ' : Add history global attribute',10];
new_entry = [new_entry , instr];

instr = [datestr(now,31) ' : Add data_level static field',10];
new_entry = [new_entry , instr];

att_name = ['history'];
[datatype, len, status] = ncmex('ATTINQ', old_cdfid, -1, att_name);
value = [new_entry]';

status = ncmex('ATTPUT', new_cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value );
if status < 0;
   disp([att_name, ' NOT successfully defined.']);
end;
    
%Next, define the variables...
%define base_time
old_var = 'base_time';
new_var = 'base_time';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
   [att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define the 'time-offset' field ala ARM using the 'time' field
old_var = 'time';
new_var = 'time_offset';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
   [att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
%    status = ncmex('ATTCOPY', old_cdfid, old_var , var_att, new_cdfid, new_var);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%   status = ncmex('ATTPUT', cdfid, varid, 'name', datatype, len, value) 
%   [datatype, len, status]) = ncmex('ATTINQ', cdfid, varid, 'name')
%   [value, len, status] = ncmex('ATTGET', cdfid, varid, 'name')

%define the 'range' field 
old_var = 'range';
new_var = 'range';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
   [att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value,  status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
%   status = ncmex('ATTCOPY', old_cdfid, old_var , var_att, new_cdfid, new_var);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define copol_532nm;
old_var = 'copol_532nm';
new_var = 'copol_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define copol_532nm_std;
old_var = 'detector_A_532nm_std';
new_var = 'copol_532nm_std';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define copol_532nm_SNR;
old_var = 'copol_532nm_SNR';
new_var = 'copol_532nm_SNR';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;
%define depol_532nm;
old_var = 'depol_532nm';
new_var = 'depol_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;
%define depol_532nm_std;
old_var = 'detector_B_532nm_std';
new_var = 'depol_532nm_std';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;
%define depol_532nm_SNR;
old_var = 'depol_532nm_SNR';
new_var = 'depol_532nm_SNR';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define depol_ratio_532nm;
old_var = 'depol_ratio_532nm';
new_var = 'depol_ratio_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
   [att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%define depol_strength_532nm;
old_var = 'depol_strength_532nm';
new_var = 'depol_strength_532nm';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

%create data_level field in output file
old_var = 'data_level';
new_var = 'data_level';
[var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, old_var);
status = ncmex('VARDEF', new_cdfid, new_var, datatype, ndims, var_dim);
if status < 0;
   disp([var_name, ' NOT successfully defined.']);
end;
for var_att = 0:(natts-1)
[att_name, status] = ncmex('ATTNAME', old_cdfid, old_var, var_att);
   [datatype, len, status] = ncmex('ATTINQ', old_cdfid, old_var, att_name);
   [value, status] = ncmex('ATTGET', old_cdfid, old_var, var_att);
   status = ncmex('ATTPUT', new_cdfid, new_var, att_name, datatype, len, value);
   if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
end;

status = ncmex('ENDEF', new_cdfid);

%Next, copy appropriate variables that won't change:
old_var = 'base_time';
new_var = 'base_time';
[value,status] = nc_getvar(old_cdfid,old_var);
[status] = nc_putvar(new_cdfid, new_var, value);
if status < 0 ; disp(['Problem copying values for: ' new_var]); end;

old_var = 'time';
new_var = 'time_offset';
[value,status] = nc_getvar(old_cdfid,old_var);
[status] = nc_putvar(new_cdfid, new_var, value);
if status < 0 ; disp(['Problem copying values for: ' new_var]); end;

% if status < 0;
%     disp(['There was a problem using ENDEF with new_cdfid.']);
% else
%     %Now copy variables from old_cdfid...
%     % disp('Copying variables ...');
%     [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', old_cdfid);
%     for varid = 0:(nvars-1)
%         [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, varid);
%         %  if status >= 0;
%         %     disp(['var_id:' ,num2str(varid), ' has var_name ''' var_name, '''.']);
%         %  end;
%         clear value;
%         [value,status] = nc_getvar(old_cdfid,var_name);
%         [status] = nc_putvar(new_cdfid, var_name, value);
%     end;
%     status = ncmex('VARPUT1', new_cdfid, 'data_level', [0], 0);
% end;

