in_dir = getdir;
files = dir([in_dir, filesep,'*.txt']);
for f = 1:length(files)
   disp(['Reading file #', num2str(f), ' of ',num2str(length(files)),': ', files(f).name]);
   dat = rd_cas_txt([in_dir, filesep,files(f).name]);
   [pname, fname] = fileparts(dat.fname);
   out_fname = [pname, fname, '.mat'];
   disp(['Saving ', out_fname]);
   save(out_fname,'dat');
end

%%

