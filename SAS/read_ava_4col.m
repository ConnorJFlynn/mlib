function in_file = read_ava_4col(filename,header_rows);
%This reads the Avantes txt data
if ~isavar('filename')
   filename= getfullname('*.txt','ava_txt');
end

if iscell(filename)&&length(filename)>1&&isafile(filename{1})
   infile_ = read_ava_4col(filename(2:end)); if isfield(infile_,'fname') infile_ = rmfield(infile_,'fname'); end
   infile = read_ava_4col(filename{1}); infile = rmfield(infile,'fname');
   in_file = cat_timeseries(infile, infile_);  in_file.pname = unique(in_file.pname);  
elseif iscell(filename)&&length(filename)==1&&isafile(filename{1})
   in_file = read_ava_4col(filename{1});
else
   % Integration time [ms]: 100.000
   % Averaging Nr. [scans]: 9
   % Smoothing Nr. [pixels]: 0
   % Data measured with spectrometer [name]: 0911147U1
   % Wave   ;Sample   ;Dark     ;Reference;
   % [nm]   ;[counts] ;[counts] ;[counts] ;
   %
   %  893.59; 1603.000; 1570.444; 1610.444;
   format_str = ['%f %f %f %f'];
   fid = fopen(filename);
   if fid>0
      [pname, fname,ext] = fileparts(filename);
      fname = [fname,ext];
      % in_file.filename = filename;
      in_file.fname = {fname};
      in_file.pname = {pname};
      [~, tim] = strtok(in_file.fname{1},'_');
      in_file.time = datenum(tim,'_ddmmmyy_HHMMSS_');
      done = false;
      if ~exist('header_rows','var')
         header_rows = 8;
      end
      in_file.header_rows = header_rows;
      fseek(fid,0,-1);
      txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',';','treatAsEmpty','N/A');fclose(fid);
      in_file.nm = txt{1};
      in_file.sample = txt{2};
      % in_file.dark = txt{3};
      % in_file.ref = txt{4};
   end
end
return;
