function raw_file = read_raw_file(filename);
% This function attempts to read an ascii file using load.
% On failure, it uses tail and head to trim the first line and last
% two lines of the file and then calls itself again until success or
% zero file length
%%
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.*');
   filename = [pname, fname];
end
%%
[pname, fname, ext] = fileparts(filename);
pname = [pname, filesep];
fname = [fname, ext];

try 

raw_file = load([pname, fname]);

catch 
newname = [fname,'.tmp'];
system(['tail --lines=+2 ',[pname fname], ' | head --lines=-1 > ', [pname, newname]]);

raw_file = read_raw_file([pname, newname]);
delete([pname, newname]);

end
%%
