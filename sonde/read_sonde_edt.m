function [sonde] = read_sonde_edt();
%[sonde] = read_sonde_edt();
% 20050428 In progress
% wanting to read entire file into string and then process to permit robust
% error catching.
[fid, fname, pname] = getfile;
fullfile = fread(fid);
[c,position] =  textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'headerLines', 39);
[d,position] =  textscan(string(fullfile), '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'headerLines', 39);

