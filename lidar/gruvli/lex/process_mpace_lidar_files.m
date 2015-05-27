function [status] = process_mpace_lidar_files;
% [status] = process_mpace_lidar_files;
% This function converts and corrects raw parsl lidar files (from MPACE) in a selected directory 

disp('Please select a file in the directory containing MPACE PARSL Lidar netcdf files.');
[dirlist, pname] = dir_list('green*.nc');

for i = 1:length(dirlist);
    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);

    ncid = ncmex('open', [[pname, dirlist(i).name]]);
    if ncid>0
       
       if ~exist([pname, 'raw_out'],'dir')
          mkdir([pname] , 'raw_out');
       end
       base_time = nc_getvar(ncid,'base_time');
       first_time = min(nc_getvar(ncid, 'time'));
       base_name = datestr(epoch2serial(base_time+first_time), 30);

       ncmex('close', ncid);
       [date_part, time_part] = strtok(base_name,'T');
       time_part = strtok(time_part, 'T');
       if ~exist([pname, 'out'],'dir')
          status = mkdir(pname, 'out')
       end
       out_name = [pname, 'out\parsl_lidar.c1.',date_part,'.',time_part, '.nc'];
       [status] = process_MPACE_lidar_file([pname, dirlist(i).name], out_name);
       system(['move ', pname, dirlist(i).name, ' ', pname, 'raw_out'])
    else
       system(['ren ', pname, dirlist(i).name, ' ', pname, dirlist(i).name, '.bad'])
    end
%     [lidar] = read_mpace_lidar();
%     status = mpace_lidar_images(lidar, pname);
%     close('all');
%     clear lidar
    disp(['Done processing ', dirlist(i).name]);    
end;
   

% disp(['Finished with processing all files in directory ' pname])
% disp(['Now bundling files into a daily netcdf file.'])
% cd([pname, 'out\'])
% if ~exist([pname, 'out\daily'],'dir')
%    mkdir([pname, 'out\'], 'daily');
% else
%    delete(['daily\*.nc']);
% end
%    
% ! D:\cygwin\usr\local\bin\nc_bundle -i *.nc -o daily -never 
% disp(' ')

status = 1;