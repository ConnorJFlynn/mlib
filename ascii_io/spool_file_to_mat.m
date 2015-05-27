function indata = spool_file_to_mat(infile)
% data = spool_file_to_mat(infile)
% This function accepts an input filename (or prompts for one)
% reads the entire file into a variable which is then saved directly
% to a mat file.  The mat file can then be dumped to recreate the original
% file
if ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname_('*.*','spool','Select a data file to convert to a mat file.');
end
fid = fopen(infile);
if fid>0
    [~, fname, ext] = fileparts(infile);
    indata.fname = fname; 
    indata.data = fread(fid,'uchar=>uchar');
end
fclose(fid);

[pname] = fileparts(mfilename('fullpath'));
save([pname, filesep,indata.fname,'.mat'],'-struct','indata');

return
