function output_m300_files(m300);
if ~exist('m300','var')
   m300 = read_m300;
end
[pname,fname, ext] = fileparts(m300.fullname);
outpath = [pname,fname];
if ~exist(outpath,'dir')
   mkdir(outpath);
end

files = fieldnames(m300.files)';

for f = files
   [tmp,filename,ext] = fileparts(m300.files.(char(f)).filename);
%    disp([filename,ext]);
  status = 0;
  disp(['Saving ',[filename,ext]])
  while status ~= length(m300.files.(char(f)).filedata)
   fid = fopen([outpath,filesep,filename,ext],'w');
   status = fwrite(fid,m300.files.(char(f)).filedata,'char');
   fclose(fid);
   if status ~= length(m300.files.(char(f)).filedata)
      disp('Trying again...')
   end
   pause(0.02)
  end
end   
disp(['Saved ',num2str(length(files)),' files.']);

  