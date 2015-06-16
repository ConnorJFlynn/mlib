function dat_filename = matspool_to_dat(infile)
% datfile = matspool_to_dat(infile)
% the purpose of this function is to generate a temporary ascii data file
% from a mat spool file so that it can be read in with importdata or
% textscan.  This is done merely to facilitate inclusion of the
% corresponding mat spool file in bundlefnt which checks for mat files.

if ~exist('infile','var')
    infile = getfullname('*.mat','spool','Select mat spool file for data file.');
end
if ~isstruct(infile)&&exist(infile,'file')
    infile = load(infile);
end
[pname] = fileparts(mfilename('fullpath'));
fid = fopen([pname, filesep,infile.fname,'.dat'],'w');
if fid>0
    dat_filename = [pname, filesep,infile.fname,'.dat'];
    fwrite(fid, infile.data,'uchar');
    fclose(fid);
    
else
    dat_filename = [];
end

return
