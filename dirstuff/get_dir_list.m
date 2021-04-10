function [dirlist, pname] = get_dir_list(pname, mask);
% function [dirlist,pname] = get_dir_list(pname, mask)
% This function does not use uigetfile.  It accepts a supplied path and mask, returning 
% a list of unique filenames as an Mx1 length structure.
% The mask may be delimited with space, semi-colon, comma, or colon.
%
% This function was drastically re-written to use new functionality of Matlab 6.1
% In particular, the output is a Mx1 structure instead of a space-padded array.
% 2002-07-22: modified to permit multiple token masks such as '*.cdf;*.nc'
% The mask may be delimited with space, semi-colon, comma, or colon.

if nargin >= 2
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
   
elseif nargin == 1
   dirtemp = dir(pname);
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
else
   dirlist = dir('*.*');
end


