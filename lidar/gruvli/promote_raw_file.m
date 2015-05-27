% This procedure interactively requests a raw data file directory, 
% copies netcdf files to an output directory within the raw directory
% and adds data_level and history to the file using raw_to_data1 function.
% Then the file is promoted to datalevel 1 by converting from raw counts 
% to count rate.

disp('Please select a file from a raw data directory.');
[fname, pname] = file_path('*.nc;*.cdf', 'data');
if ~exist([pname 'output'], 'dir');
    mkdir(pname, 'output');
end;
outdir = [pname, 'output\'];

disp(' ');

[old_cdfid] = ncmex('OPEN', [pname fname], 'NC_NOWRITE');
[new_cdfid] = ncmex('CREATE', [outdir fname], 'NC_CLOBBER');
if (old_cdfid)
    if (new_cdfid)
        disp(['Duplicating structure of ',pname fname]);
        status = new_def_nc(old_cdfid, new_cdfid);
        status = ncmex('ENDEF', new_cdfid);
        if status < 0;
            disp(['There was a problem using ENDEF with new_cdfid.']);
        else
            disp('Copying data and rearranging...');
            status = new_data_nc(old_cdfid, new_cdfid);
            disp('Converting to counts per second.');
            status = new_data_0(new_cdfid);
        end; 
        %disp(['Writing data to new version of ', pname fname]);
        %status = new_data_nc(in_ncid, out_ncid);
        %status = raw_to_data1(in_ncid, out_ncid);
        if status < 0;
            disp(['There was a problem promoting the datafile ', dirlist(i).name]);
            break;
        end;
        [status] = ncmex('close',new_cdfid);
    else
        disp(['There was a problem opening the output file in define mode.']);
    end;
    [status] = ncmex('close',old_cdfid);
else
    disp(['There was a problem opening the input file.']);
end;
        