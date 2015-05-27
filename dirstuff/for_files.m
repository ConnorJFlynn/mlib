function status = for_files;
% This function is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user-specified internal function for each file.
%outdir = ['F:\datastream\nsa\nsamplpsC1.c1\cdf\'];
disp('Please select a directory.');
directoryname = uigetdir('D:\MFR_Cal_database\Filters', 'Select the directory containing CalibInfo files.');


[flist]= findfile(directoryname,'*',1);

for i = 1:length(flist);

    disp(['Processing ', flist(i).fname, ' : ', num2str(i), ' of ', num2str(length(flist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
status = txt2dos(fullfile(flist(i).fpath,flist(i).fname));
%nomcal = gen_nomcal_file(fullfile(flist(i).fpath,flist(i).fname));
%status = apply_dtc([pname dirlist(i).name]);    
%ncid = get_ncid([pname dirlist(i).name])
%[mplps, status] = mpl_con_ps(pname, dirlist(i).name, outdir);
    %clear mplps
    disp(['Done processing ', flist(i).fname]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' directoryname])
disp(' ')
end


function status = apply_dtc(fname);
% This internal function is used by for_files
ncid = ncmex('open', fname, 'write')
[dtc_att, status] = ncmex('ATTGET', ncid, 'global', 'deadtime_corrected');

[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
[unlim, unlim_length, status] = ncmex('DIMINQ', ncid, recdim);

if ((unlim_length>0) & (length(findstr(upper(dtc_att),'NO')>0)))
   rawcts = nc_getvar(ncid, 'detector_counts');
   disp('Applying deadtime correction');
   dtc = dtc_apd6850_ipa(rawcts);
   status = nc_putvar(ncid, 'detector_counts', dtc);
   [bins,profs] = size(rawcts);
   r = [fix(bins*.87):ceil(bins*.97)];
   bg = nc_getvar(ncid, 'background');
   new_bg = mean(rawcts(r,:));
   status = nc_putvar(ncid, 'background', new_bg);
   status = ncmex('REDEF', ncid);
   status = ncmex('ATTPUT', ncid, 'global', 'deadtime_corrected', 'char', length('Yes'), 'Yes');
   [corr_att, status] = ncmex('ATTGET', ncid, 'detector_counts', 'corrections');
   in_string = 'deadtime-corrected MHz';
   status = ncmex('ATTPUT', ncid, 'detector_counts', 'corrections', 'char', length(in_string), in_string);
   in_string = 'SPCM-AQR-FC 6850a';
   status = ncmex('ATTPUT', ncid, 'detector_counts', 'APD_serial_number', 'char', length(in_string), in_string);
   
   status = ncmex('ENDEF', ncid);
end
status = ncmex('close', ncid);
end