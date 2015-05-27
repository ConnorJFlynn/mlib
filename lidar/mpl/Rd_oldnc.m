function ncid = getoldnc();
% function ncid = getoldnc(fspec)
% usage: ncid = getfile(fspec)
% if successful, opens an existing netcdf file in read mode. 
% ncid is a positive integer indicating the file identifier
% if unsuccessful, fid is -1
% fspec is a string indicating the file mask to be used with uigetfile
% getfile uses the uigetfile function to locate and open a file in read mode.
if nargin==0 
  fspec = '*';
end;
home = pwd;
if exist('getpath.mat') 
  load getpath.mat;
  eval(['cd ' getpath]);
else 
  getpath = [];
end;
[fname,pname] = uigetfile('*.nc *.cdf');
if pname == 0 
  ncid = -1;
else 
  getpath = pname;
  eval(['cd ' home]);
  save getpath.mat getpath;
  ncid = mexcdf('OPEN',[pname fname]);
end; 

