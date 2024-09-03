function in_file = read_ava_5col(filename,header_rows);
%This reads the Avantes txt data 
if ~isavar('filename')
   filename= getfullname('*.txt','ava_txt');
end

% Integration time [ms]: 100.000
% Averaging Nr. [scans]: 9
% Smoothing Nr. [pixels]: 0
% Data measured with spectrometer [name]: 0911147U1
% Wave   ;Sample   ;Dark     ;Reference;Transmittance
% [nm]   ;[counts] ;[counts] ;[counts] ;[%]
% 
%  893.59; 1603.000; 1570.444; 1610.444;81.38885
format_str = ['%f %f %f %f %f'];
fid = fopen(filename);
if fid>0
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
   in_file.filename = filename;
   in_file.fname = fname;
   in_file.pname = pname;
   done = false; 
   if ~exist('header_rows','var')
   header_rows = 8;
      end
in_file.header_rows = header_rows;
   fseek(fid,0,-1);
   txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',';','treatAsEmpty','N/A');fclose(fid);
   in_file.nm = txt{1};
   in_file.sample = txt{2};
   in_file.dark = txt{3};
   in_file.ref = txt{4};
   in_file.Tr = txt{5};   
end

return;
