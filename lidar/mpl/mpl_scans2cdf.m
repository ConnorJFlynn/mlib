function [status] = mpl_scans2cdf();
% [mpl_ipa] = mpl_scans2cdf();
% This function was written to process data from the IOP in Indiana PA.
% This first stage combines organizing the data by scan and also
% conversion to netcdf.  
% Subsequent processes will read these netcdf files
%
% It first reads a cumulative mirror position file.
% Then, it reads all available OCR data (if any) creating averages for each
% mirror position.
% It also reads all available mpl-ps data, separating into copol and depol,
% and creating averages for each mirror position.

%If cumulative file exists, then read it.
%Then query for the directory where more .pos files exist.


fullname = 'D:\ARM\devices\mpl\Pitts\mirror\mirror.pos';
load(fullname, '-mat');

%Select a directory containing NASA format OCR files...
disp('Select a directory containing NASA format OCR files...');
[dirlist,pname] = dir_list('*.??W');
for i = 1:length(dirlist);
    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
     [lidar, status] = read_mpl([pname dirlist(i).name]);
     lidar.time = lidar.time + 4/24; % Adjust for EDT timezone to give GMT
     lidar_ocr = [];
     %find the mirror interval nearest to the start of this OCR file.
     first = max(find(mirror.start_time < lidar.time(1)));
     last = min(find(mirror.start_time > max(lidar.time)));
     for index = first:last
        interval = find(lidar.time>mirror.start_time(index)&lidar.time<mirror.end_time(index));
        if length(interval>0);
           lidar_ocr = sub_interval(lidar, interval, lidar_ocr);
        end
     end %for
     lidar_ocr.statics.channels = 2;
     lidar_ocr.statics.ocr = 1;
     lidar_ocr.statics.lat = 40.62;
     lidar_ocr.statics.lon = -79.155;
     lidar_ocr.statics.alt = 396.5;
     status = write_mplocr_a0(lidar_ocr, pname);
    disp(['Done processing file:', dirlist(i).name, '.']);
 end %for;
 status = 1;
end %function;



