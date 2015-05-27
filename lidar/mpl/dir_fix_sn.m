% dir_fix_sn: This procedure permits the user to select a directory containing 
% New NASA MPL data files of format New_NASA. One by one, it steps through the 
% files, replacing the internal UnitSN with a user supplied number.

disp('Select the directory containing MPL files to be corrected with new UnitSN.');
[dirlist, pname] = dir_list('*.??w; *.??W');
number_of_files = length(dirlist);
if (number_of_files < 1)
  disp('No files selected, no action to be taken...');
else
  UnitSN = input('Enter the correct unit number for these files. ');
  disp(['The serial number entered was: ' num2str(UnitSN)]);
  if (UnitSN > 99)
    disp('This unit number exceeds 99 and is too high!  No can do, Buckaroo!');
  else  
     for file_number = 1:number_of_files;
       disp(['file_number: ', num2str(file_number), ' of ', num2str(number_of_files)]);
       file_in_dir = dirlist(file_number).name;
       disp(['Opening ' pname file_in_dir ]);
       status = fix_sn_win(UnitSN, file_in_dir, pname);
       disp(['Changing serial number to ' num2str(status)]);
     end; % of for "number_of_files" loop
  end; 
end;