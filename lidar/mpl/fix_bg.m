% fix_bg: This procedure permists the user to select a directory containing MPL data files of format New_NASA.
% One by one, it steps through the files, replacing the internal background calculation (which has dead-time correction inherent)
% with a non-deadtime corrected background derived from the raw data.

[dirlist, pname] = dir_list('*.??w');
number_of_files = length(dirlist);

for file_number = 1:number_of_files;
    file_in_dir = dirlist(file_number).name;
%    disp(['Opening ' pname file_in_dir ]);
    % Open file, determine if it is larger than 43 bytes.  
    % If so, read first 44 bytes which will be used to determine profile size and number of profiles.
    disp(['fixing ''' file_in_dir, '''  File_number: ', num2str(file_number), ' of ', num2str(number_of_files)]);
    fid = fopen([pname file_in_dir],'r+');
    if fid > 1; 
       %status = fix_mpl_bkgnd_one_file(fid);
       status = fix_mpl_bkgnd_by_parts(fid);
       fclose(fid);
    else
      disp(['The file ' ,[pname file_in_dir], ' could not be opened.']);
   end;   
end; %end of for "number_of_files"loop