function [status] = apply_overlap;
% The general idea is to select the copol overlap file, the depol overlap file, and a directory 
% containing data to correct.

%start with copol overlap...

corr_name = 'copol overlap';

disp(['Please select the ',corr_name, ' file.']);
[fname, pname] = file_path('*.DAT', 'corr');
if length(pname)<=0;
    disp(['Bad path to ', corr_name, ' file?']);
    pause;
    break;
else
    overlap = load([pname fname]);
    max_overlap_range = max(overlap(:,1));
    status = 1;
end;
copol_overlap = overlap;
copol_max_overlap_range = max_overlap_range;

corr_name = 'depol_overlap';
disp(['Please select the ',corr_name, ' file.']);
[fname, pname] = file_path('*.DAT', 'corr');
if length(pname)<=0;
    disp(['Bad path to ', corr_name, ' file?']);
    pause;
    break;
else
    overlap = load([pname fname]);
    max_overlap_range = max(overlap(:,1));
    status = 1;
end;
depol_overlap = overlap;
depol_max_overlap_range = max_overlap_range;

profile_name = 'copol_532nm'

if (status <= 0);
    disp('The overlap selection was bad.');
    break;
else
    disp('Please select a file from the incoming data directory.');
    disp('All files will be processed into an output directory within the selected directory.');
    [dirlist,pname] = dir_list('*.nc', 'data');
    if ~exist([pname 'output'], 'dir');
        mkdir(pname, 'output');
    end;
    outdir = [pname, 'output\'];
    cd([pname]);
    for i = 1:length(dirlist);
            disp(' ');
            disp(['File #',num2str(i),' of ',num2str(length(dirlist))]);
            disp(['Applying overlap correction to file: ', dirlist(i).name]);
        system(['copy /y ' dirlist(i).name, ' output']);
        [cdfid, status] = ncmex('OPEN', [outdir dirlist(i).name],'WRITE');
        if status < 0;
            disp(['Problem opening netcdf file: ', outdir dirlist(i).name]);
            break;
        else 
            [range, status] = nc_getvar(cdfid,'range');
            [time, status] = nc_getvar(cdfid,'time');
            overlap_corr = ones(size(range))';
            
     %begin copol overlap interpolation and application
            [profile,status] = nc_getvar(cdfid, 'copol_532nm');
            overlap = copol_overlap;
            max_overlap_range = copol_max_overlap_range;
            
            corr_range = find((range>0)&(range <= max_overlap_range));
            overlap_corr(corr_range) = interp1(overlap(:,1), overlap(:,2), range(corr_range), 'spline');
            for i = 1:length(time);
                profile(corr_range,i) = profile(corr_range,i) .* overlap_corr(corr_range);
            end;
            [status] = nc_putvar(cdfid, 'copol_532nm', profile);

     %begin depol overlap interpolation and application
            [profile,status] = nc_getvar(cdfid, 'depol_532nm');
            overlap = depol_overlap;
            max_overlap_range = depol_max_overlap_range;
            
            corr_range = find((range>0)&(range <= max_overlap_range));
            overlap_corr(corr_range) = interp1(overlap(:,1), overlap(:,2), range(corr_range), 'spline');
            for i = 1:length(time);
                profile(corr_range,i) = profile(corr_range,i) .* overlap_corr(corr_range);
            end;
            [status] = nc_putvar(cdfid, 'depol_532nm', profile);
            
            %Update data_level value
            status = nc_putvar(cdfid, 'data_level', 63);
            
            %Get history global attribute, add update, write to file. 
            att_name = 'history';
            [value,status] = ncmex('ATTGET', cdfid, 'NC_GLOBAL', att_name);
            new_value = blanks(80);
            in_str = [datestr(now,31) ' :  Promoted to 63; zero ranged, dtc, bkgnd, r2, log, overlap',10];
            new_value(1:length(in_str)) = in_str;
            value = strvcat(value, new_value); 
            [status] = ncmex('REDEF', cdfid);
            status = ncmex('ATTPUT', cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value' );
            [status] = ncmex('ENDEF', cdfid);
            if status < 0;
                disp([':' att_name, ' NOT sucessfully defined.']);
            end;
            
        end;
        [status] = ncmex('CLOSE', cdfid);
    end;
end;
            
           
            