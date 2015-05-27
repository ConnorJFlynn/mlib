function [dirlist, pname] = dir_list(mask, last);
% function [dirlist,pname] = dir_list(mask, last)
% This function prompts the user to select a file using uigetfile.  The  path of the file
% selected is then used to produce directory listing (with an optional mask) which 
% is returned as an Mx1 length structure.
% The mask may be delimited with space, semi-colon, comma, or colon.
%
% The difference between this function and dir_.m is that this one is
% interactive starting from the supplied pathfile while dir_ merely returns
% the listing of the directory from the pathfile indicated.
% This function was drastically re-written to use new functionality of Matlab 6.1
% In particular, the output is a Mx1 structure instead of a space-padded array.
% 2002-07-22: modified to permit multiple token masks such as '*.cdf;*.nc'
% The mask may be delimited with space, semi-colon, comma, or colon.

if nargin >= 2
  [fid, fname, pname] = getfile(mask,last);
elseif nargin == 1
  [fid, fname, pname] = getfile(mask);
else
  mask = '*.*';
  [fid, fname, pname] = getfile(mask);
end
fclose(fid);
homedir = pwd;
cd(pname);
[tok,mask] = strtok(mask,', ;:');
j = 0;
dirlist = [];
while ~isempty(tok)
    dirtemp = dir(tok);
    if isempty(dirlist);
        clear dirlist;
        dirlist = dirtemp;
    else
        list_len = length(dirlist);
        for i = 1:length(dirtemp);
            duplicate = 0;
            for j = 1:list_len
              if (strcmp(dirlist(j).name, dirtemp(i).name))==1 ; duplicate = 1;  end;
            end;
            if (duplicate ~=1); dirlist(length(dirlist)+1) = dirtemp(i); end;
       end;
   end;
   [tok,mask] = strtok(mask,' ,;:');
end;
cd(homedir);

