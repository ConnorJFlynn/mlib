function [status] = raw_to_data1(cdfin, pname);
% This function accepts a single netcdf file, tests for the existence of the data_level field 
% and the history global attribute, creating them if necessary, and sets the data_level to 1.

[cdfid, status] = ncmex('OPEN', [pname cdfin],'WRITE');
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid );

%test for history
[datatype, len, status] = ncmex('ATTINQ', cdfid, -1, 'history');
if status > 0; 
    disp(['The history global attribute already exists in ',cdfin]);
    disp('It may not be raw data, so exiting...');
    raw = -1;
    break;
else
    raw = 1;
end;

%test for data_level
[varid] = ncmex('VARID',cdfid , 'data_level');
if varid > 0;
    disp(['The data_level field already exists in ',cdfin]);
    disp('It may not be raw data, so exiting...');
    raw = -1;
    break;
else
    raw = raw * 1;
end;    

if raw >=0;
    [status] = ncmex('REDEF', cdfid);
    
    %create data_level field in output file
    varid = nvars;
    var_name = 'data_level';
    datatype = 4;
    ndims = 0;
    var_dim = [];
    status = ncmex('VARDEF', cdfid , var_name, datatype, ndims, var_dim);
    if status < 0;
        disp([var_name, ' NOT successfully defined.']);
    end;
    data_level_id = varid;
    
    
    %Add history global attribute to output file 
    new_value = blanks(80);
    instr = [datestr(now,31) ' :  Promoted to 1; add history & data_level, re-zero range fields',10];
    new_value(1:length(instr)) = instr;
    value = (new_value);
   
    att_name = 'history';
    status = ncmex('ATTPUT', cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value' );
    
    %Also add field-level attributes to data_level
    att_name = 'long_name';
    value = 'Data_level indicating which corrections and data processing have been applied.'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    att_name = 'units';
    value = 'unitless'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    att_name = 'comment';
    value = 'The numeric value of data_level is the sum of the following bits representing different corrections.'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;
    
    att_name = 'bit_0_explanation';
    value = 'range and associated fields rearranged to put zero range at first bin position.'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;  
    
    att_name = 'bit_1_explanation';
    value = 'dead-time correction applied.  (Implies conversion of total counts to count rate in Hz.)'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_2_explanation';
    value = 'background-subtracted'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_3_explanation';
    value = 'range-correction applied to copol and depol channels.'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_4_explanation';
    value = 'log taken as 3-part noise suppression for copol_log and depol_log'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_5_explanation';
    value = 'overlap correction applied to non-log data'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    att_name = 'bit_6_explanation';
    value = 'not currently used'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;  
    
    att_name = 'bit_7_explanation';
    value = 'not currently used'; 
    status = ncmex('ATTPUT', cdfid, data_level_id, att_name, 2, length(value), value);
    if status < 0;
        disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
    end;            
    
    [status] = ncmex('ENDEF',cdfid );
    if (status < 0); disp('Problem with endef.');end
    [status] = ncmex('CLOSE', cdfid);
    if (status < 0); disp('Problem with close');end
    [cdfid, status] = ncmex('OPEN',[pname cdfin] , 'WRITE');
    if (status < 0); disp('Problem with OPEN/WRITE near end.');end
    
    [status] = nc_putvar(cdfid, 'data_level', 1);
    if (status < 0); disp('Problem with nc_putvar');end

    [status] = ncmex('CLOSE', cdfid);
    if (status < 0); disp('Problem with CLOSE');end
end;
