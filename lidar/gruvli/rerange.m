function [status] = rerange(in_file,pname)
% This process accepts a netcdf file with lidar profiles as a function of range and 
% creates a second netcdf file with zero range positioned at the first range bin.
% Limitations:
% Creates an outgoing directory "output" beneath the incoming data directory
% This m-file is hard-coded for a 2000 Hz pulse rep.

% 2002-12-12
% Attempting to identify problem with bin_resolution being incorrectly assigned the value = 1
% Found it.  An inappropriate assignment to datalevel was being attempted.  (Datalevel and History 
% manipulations had been moved to raw2data1.m)

%open original
[old_cdfid] = ncmex('OPEN', [pname in_file], 'NC_NOWRITE');
%open new
outfile = [pname 'output/' in_file];
[new_cdfid] = ncmex('CREATE', outfile, 'NC_CLOBBER');
%     status = ncmex('REDEF', new_cdfid);
%     if status < 0; disp('Could not REDEF newfile.'); end;
if (old_cdfid)
    if (new_cdfid)
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

        for gatt = 0:(natts-1)
            [att_name, status] = ncmex('ATTNAME', old_cdfid, 'NC_GLOBAL', gatt);
            [datatype, len, status] = ncmex('ATTINQ', old_cdfid, 'NC_GLOBAL', att_name);
            if datatype==2; value=' ';
            else value = 0;
            end;
            status = ncmex('ATTPUT', new_cdfid, 'NC_GLOBAL', att_name, datatype, len, value);
            if status < 0;
                disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
                %                 else
                %                     disp([var_name, ':' att_name, ' properly defined.']);
            end;
        end;
        
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
            for vatt = 0:(natts-1)
                [att_name, status] = ncmex('ATTNAME', old_cdfid, varid, vatt);
                [datatype, len, status] = ncmex('ATTINQ', old_cdfid, varid, att_name);
                %disp(['From ATTINQ: datatype, len, status: ', num2str(datatype), ' ', num2str(len), ' ', num2str(status)]);
                value = ' ';
                status = ncmex('ATTPUT', new_cdfid, varid, att_name, datatype, len, value);
                if status < 0;
                    disp([var_name, ':' att_name, ' NOT sucessfully defined.']);
                    %                     else
                    %                         disp([var_name, ':' att_name, ' properly defined.']);
                end;
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
        
        %next leave define mode
        status = ncmex('ENDEF', new_cdfid);
        if status < 0; 
            disp(['new_cdfid did not exit define mode properly']);
        end;
        status = ncmex('CLOSE', new_cdfid);
        if status < 0; 
            disp(['new_cdfid did not close properly']);
        end;
        %             disp('Opening new file in WRITE mode.');
        [new_cdfid, status] = ncmex('OPEN', outfile, 'NC_WRITE');
        if status < 0; 
            disp(['new_cdfid did not re-open properly in write mode.']);
            %             else disp(['new_cdfid opened okay in WRITE mode.']);
        end;
        
        %Now copy variables and attributes from old_cdfid...
%         disp('Copying variables and attributes...');
        
        [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', old_cdfid);
        
        %copy global atts
%         disp('Copying globals...');
        for gatt = 0:natts-1
            [att_name, status] = ncmex('ATTNAME', old_cdfid, 'NC_GLOBAL', gatt);            
            status = ncmex('ATTCOPY', old_cdfid, 'NC_GLOBAL' , gatt, new_cdfid, 'NC_GLOBAL');
            if status < 0 ; disp(['Problem copying global att:' num2stsr(gatt)]);end;
        end;
        
        for varid = 0:(nvars-1)
            [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, varid);
            %                 if status >= 0;
            %                     disp(['var_id:' ,num2str(varid), ' has var_name ''' var_name, '''.']);
            %                 end;
            for var_att = 0:(natts-1)
                status = ncmex('ATTCOPY', old_cdfid, varid , var_att, new_cdfid, var_name);
                if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
            end;
            clear value;
            [value,status] = nc_getvar(old_cdfid,var_name);
            [status] = nc_putvar(new_cdfid, var_name, value);
            clear check_val;
            [check_val, status] = nc_getvar(new_cdfid,var_name);
   %         if ndims==0; disp([var_name, ' = ', num2str(value), ' = ', num2str(check_val)]); end;
   %         if (value == check_val); disp([var_name, ' copied okay...']); end;
        end;
        
        %now (finally!) re-arrange range associated fields...
        %             disp('Next, re-arrange range associated fields...');
        
        % speed of light c = 3e8 m/s
        c = 3e8;
        % MTC_Clock_Rate = 80 MHz = 80e6 tics/sec;
        MTC_Clock_Rate = 80e6;
        % MTC_Train_Rate = 40e3 tics/pulse;
        MTC_Train_Rate = 40e3;
        
        var_name = 'time_zero_bin';
        [value, status] = nc_getvar(old_cdfid, var_name);
        if status < 0; disp(['Problem getting ', var_name, ' from old_cdfid!']); 
            %             else disp('Got time_zero-bin okay...');
        end;
        time_zero_bin = value;
%         disp(['Length of time_zero_bin: ', num2str(length(time_zero_bin))]);

        var_name = 'range';
        [value, status] = nc_getvar(old_cdfid, var_name);
        if status < 0; disp(['Problem getting ', var_name, ' from old_cdfid!']); 
            %             else disp('Got range okay...');
        end;
        range = value;

%         disp(['Re-ranging ', var_name, '...']);
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
        
        status = nc_putvar(new_cdfid, 'range', range); 
        if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;

        %Now prepare to rearrange matrices containing range-dimensioned data...
        %The time_zero_bin for each profile is used as this reference
        
        %re-range detector_A_532nm
        var_name = 'detector_A_532nm';
%         disp(['Re-ranging ', var_name, '...']);
        [matrix, status] = nc_getvar(old_cdfid, var_name);
        [ranges, times] = size(matrix);
        if status < 0; disp(['Problem getting ', var_name, 'from old_cdfid!']); end;
        for i = 1:times;
            new_matrix(1:(ranges-time_zero_bin(i)+1),i) = matrix(time_zero_bin(i):ranges,i);
            new_matrix(2+(ranges-time_zero_bin(i)):ranges,i) = matrix(1:time_zero_bin(i)-1,i);
        end;
        status = nc_putvar(new_cdfid, var_name, new_matrix); 
        if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;

        %re-range detector_B_532nm
        var_name = 'detector_B_532nm';
%         disp(['Re-ranging ', var_name, '...']);
        [matrix, status] = nc_getvar(old_cdfid, var_name);
        if status < 0; disp(['Problem getting ', var_name, 'from old_cdfid!']); end;
        for i = 1:times;
            new_matrix(1:(ranges-time_zero_bin(i)+1),i) = matrix(time_zero_bin(i):ranges,i);
            new_matrix(2+(ranges-time_zero_bin(i)):ranges,i) = matrix(1:time_zero_bin(i)-1,i);
        end;
        status = nc_putvar(new_cdfid, var_name, new_matrix); 
        if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
                     
        %re-range detector_A_532nm_std
        var_name = 'detector_A_532nm_std';
%         disp(['Re-ranging ', var_name, '...']);
        [matrix, status] = nc_getvar(old_cdfid, var_name);
        if status < 0; disp(['Problem getting ', var_name, 'from old_cdfid!']); end;
        for i = 1:times;
            new_matrix(1:(ranges-time_zero_bin(i)+1),i) = matrix(time_zero_bin(i):ranges,i);
            new_matrix(2+(ranges-time_zero_bin(i)):ranges,i) = matrix(1:time_zero_bin(i)-1,i);
        end;
        status = nc_putvar(new_cdfid, var_name, new_matrix); 
        if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
                     
        %re-range detector_B_532nm_std
        var_name = 'detector_B_532nm_std';
%         disp(['Re-ranging ', var_name, '...']);
        [matrix, status] = nc_getvar(old_cdfid, var_name);
        if status < 0; disp(['Problem getting ', var_name, 'from old_cdfid!']); end;
        for i = 1:times;
            new_matrix(1:(ranges-time_zero_bin(i)+1),i) = matrix(time_zero_bin(i):ranges,i);
            new_matrix(2+(ranges-time_zero_bin(i)):ranges,i) = matrix(1:time_zero_bin(i)-1,i);
        end;
        status = nc_putvar(new_cdfid, var_name, new_matrix); 
        if (status < 0); disp(['Problem re-ranging ', var_name, '...']); end;
        
%         disp('Assigning data_level.');
%         var_name = 'data_level';
%         status = nc_putvar(new_cdfid, var_name, 1);             

        %%%
         for varid = 0:(nvars-1)
            [var_name, datatype, ndims, var_dim, natts, status] = ncmex('VARINQ', old_cdfid, varid);
            %                 if status >= 0;
            %                     disp(['var_id:' ,num2str(varid), ' has var_name ''' var_name, '''.']);
            %                 end;
            for var_att = 0:(natts-1)
                status = ncmex('ATTCOPY', old_cdfid, varid , var_att, new_cdfid, var_name);
                if status < 0 ; disp(['Problem with copying attributes for ' var_name]); end;
            end;
            clear value;
            [value,status] = nc_getvar(old_cdfid,var_name);
            clear check_val;
            [check_val, status] = nc_getvar(new_cdfid,var_name);
            if ((ndims == 0) & (value ~= check_val)); 
                disp([var_name, ' var_id:',num2str(varid),' did not check okay...']); 
                disp([var_name, ' = ', num2str(value), ' = ', num2str(check_val)]);
            end;
        end;
        
        %%%
        
        %disp('Closing outfile.');
        [status] = ncmex('CLOSE',new_cdfid);
        if status <0; 
            disp(['new_cdfid did not close properly']);
        end;
    else 
        disp(['new_cdfid was not opened correctly.']);
    end;
    
    %     disp('Closing infile.');
    status = ncmex('CLOSE', old_cdfid);
    if status < 0; 
        disp(['old cdfid did not close properly']);
    end;
else
    disp(['old_cdfid was not opened correctly.']);
end;

% disp(['Parting status is: ' num2str(status)]);
