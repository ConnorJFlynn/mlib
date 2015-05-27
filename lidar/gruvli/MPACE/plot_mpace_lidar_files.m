function [status] = plot_mpace_lidar_files;
% [status] = process_mpace_lidar_files;
% This function genrates plots of parsl lidar files (from MPACE) in a selected directory 
% Output is placed in an "images" folder under the current directory that will be created if needed.

disp('Please select a directory containing MPACE PARSL Lidar netcdf files.');
[dirlist, pname] = dir_list('*.nc');

for i = 1:length(dirlist);
    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
    ncid = ncmex('open', [[pname, dirlist(i).name]]);
    if ncid>0
       lidar = read_mpace_lidar_file(ncid);
       if ~exist([pname, 'images'],'dir')
          status = mkdir(pname, 'images')
       end
       out_dir = [pname, 'images\'];
       status = plot_mpace_lidar_file(lidar, out_dir);
       ncmex('close',ncid)
       clear lidar
    end
    disp(['Done processing ', dirlist(i).name]);    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')
status = 1;