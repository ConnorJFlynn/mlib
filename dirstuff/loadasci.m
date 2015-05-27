% usage loadasci
% loadasci is a procedure for loading an ascii file from a specific location.
% The basic idea is to use getfile to select the filename from a default
% or previous path.  Then the "load -ascii" command is issued from the selected
% path of getfile, loading the ascii file into a variable of the same name.
%
% getfile uses uigetfile to locate the file.

homedir = pwd;
gotomats;
%customize last to suggest whichever "*.mat" holds the path desired
last = 'lastget.mat';
lastget=[];

if exist(last) 
  eval(['load ',last]);
  if ~exist([lastget,'NUL'])
     eval(['delete ',last,]);
     lastget = [];
  end;
  eval(['cd ''', lastget, '''']);
end;

[fname,pname] = uigetfile('*.*');
if pname == 0 
  fid = -1;
else 
  lastget = pname;
  eval(['cd ''' ,pname, '''']);
  eval(['load ', lower(fname)]); 
end; 

gotomats;
eval(['save ', last, ' lastget']);
gotohome;