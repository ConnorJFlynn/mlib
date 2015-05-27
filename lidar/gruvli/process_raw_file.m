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

%cd([pname]);
promote_one_raw_file([pname fname], [outdir fname]);
disp(['Done processing ', fname]);
    
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')

