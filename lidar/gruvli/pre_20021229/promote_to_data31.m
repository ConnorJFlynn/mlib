% This procedure interactively requests a raw data file directory, 
% copies netcdf files to an output directory within the raw directory
% and adds data_level and history to the file using raw2data0 function.

disp('Please select a file from a data directory.  All files will be copied to an output directory.');
disp('The output files will have the history attribute modified, and be processed to data level n.');
disp('This processing includes ...');

[dirlist,pname] = dir_list('*.nc', 'data');
if ~exist([pname 'output'], 'dir');
    mkdir(pname, 'output');
end;
outdir = [pname, 'output\'];
cd([pname]);
for i = 1:length(dirlist);
    disp(' ');
    disp(['File #',num2str(i),' of ',num2str(length(dirlist))]);
    disp(['Processing to data level 31 for file: ', dirlist(i).name]);
    
    system(['copy /y ' dirlist(i).name, ' output']);
%     disp(['The infile is ',dirlist(i).name]);
%     disp(['The outdir is ', outdir]);
    status = data1_to_data31([outdir dirlist(i).name]);
    if status < 0;
        disp(['There was a problem promoting the datafile ', dirlist(i).name]);
        break;
    end;
end;
        