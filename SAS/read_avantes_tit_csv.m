function in_file = read_avantes_tit_csv(filename,header_rows);
% in_file = read_avantes_tit_csv(filename,header_rows);
%This reads the Avantes csv data (tit) in the format provided via email
if ~exist('filename', 'var')
   filename= getfullname('*.tit','ascii');
end

% MASTER- Dummy Data
% Integration time: 10.00 ms
% Average: 1 scans
% Nr of pixels used for smoothing: 0
% Data measured with spectrometer name: Simulation Channel 0
% Wave   ,Dark     ,Ref      ,Sample   ,Absolute Irradiance  ,Photon Counts
% [nm]   ,[counts] ,[counts] ,[counts] ,[µWatt/cm²/nm]       ,[µMol/s/m²/nm]
% 214.50,0,95.711,520.86,17.959,0.3220
format_str = ['%f %f %f %f %f %f '];
fid = fopen(filename);
if fid>0
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
   in_file.filename = filename;
   in_file.fname = fname;
   in_file.pname = pname;
   done = false; 
   if ~exist('header_rows','var')
   header_rows = 0;

   while ~done
      tmp = fgetl(fid);
      if ((tmp(1)>47)&(tmp(1)<58))|feof(fid)
         done = true;
      else
         header_rows = header_rows +1;
      end
   end
   
   end
in_file.header_rows = header_rows;
   fseek(fid,0,-1);
   txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',',','treatAsEmpty','N/A');
   in_file.nm = txt{1};
   in_file.darks = txt{2};
   in_file.ref = txt{3};
   in_file.DN = txt{4};
   in_file.irad = txt{5};
   in_file.photons = txt{6};
end

return;
