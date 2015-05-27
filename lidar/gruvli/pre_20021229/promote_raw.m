% This procedure interactively requests a raw data file directory, 
% copies netcdf files to an output directory within the raw directory
% and adds data_level and history to the file using raw_to_data1 function.
% Then the file is promoted to datalevel 1 by converting from raw counts 
% to count rate.

disp('Please select a file from a raw data directory.');
disp('All files will be copied to an output directory.');
disp('Then they will have a history attribute added and be processed to data level 1.');
[dirlist,pname] = dir_list('*.nc;*.cdf', 'data');
if ~exist([pname 'output'], 'dir');
    mkdir(pname, 'output');
end;
outdir = [pname, 'output\'];
cd([pname]);
for i = 1:length(dirlist);
%    system(['copy /y ' dirlist(i).name, ' output']);
    disp(' ');
    disp(['File #',num2str(i),' of ',num2str(length(dirlist))]);
    disp(['Running rerange for file: ', dirlist(i).name]);
    status = rerange(dirlist(i).name, pname);
    disp(['Running raw_to_data1 for file: ', dirlist(i).name]);
    status = raw_to_data1(dirlist(i).name, outdir);
    if status < 0;
        disp(['There was a problem promoting the datafile ', dirlist(i).name]);
        break;
    end;
end;
        