function raw_file = read_rawfile(filename);
% This function attempts to read an ascii file using load.
% On failure, it uses tail and head to trim the first line and last
% two lines of the file and then calls itself again until success or
% zero file length
% On failure, it converts the text to Unix mode (/n ASCII 10 for
% linefeed), trims the first and last line feeds, saves to a tmp file,
% an tries to reload.
% This file was specifically written for MFRSR filter functions and
% contains some dedicated code for that (searches for nm_)
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
   fid = fopen([pname, fname], 'r');
   txt = fread(fid, 'char');
   fclose(fid);
   txt = str2unix(txt);

   if ~isempty(txt)
      nm = findstr(txt,'nm_');
      tmp = [];
      if any(nm)
         nm(end+1) = length(txt);
         for n = 1:(length(nm)-1)
            tmp2 = txt((nm(n)+1):(nm(n+1)-1));
            lf = find(tmp2==10);
            tmp2 = tmp2((lf(1)+1):end);
            tmp = [tmp, tmp2];
         end
         txt = tmp;
      else
         lf = find(txt==10);
         txt = txt((lf(2)+1):lf(end));
%          fid = fopen('tmp.tmp','w');
%          fwrite(fid, txt, 'char');
%          fclose(fid);
%          raw_file = read_rawfile('tmp.tmp');
%          delete('tmp.tmp');
      end
      fid = fopen('tmp.tmp','w');
      fwrite(fid, txt, 'char');
      fclose(fid);
      raw_file = read_rawfile('tmp.tmp');
      delete('tmp.tmp');
   else
      raw_file = [];
   end
end
%%
