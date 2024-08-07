function status = txt2mac(filename,force)
% Windows: \r\n
% UNIX: \n x0A 10
% Mac: \r x0D 13

% Replace all \r\n with \n  [13 10] with [10]
% replace all \r with \n [13] with [10]

% for txt2dos, first call txt2unix then replace [10] with [13 10]
% for txt2mac, first call txt2unix then replace [10] with [13]
if ~exist('force', 'var')
   force = false;
end
if ~exist('filename','var')
   [fname, pname] = uigetfile('*.*');
   if length(pname)>0
      filename = [pname, fname];
   end
end
status = txt2unix(filename,force);
if status>=0
   tmpname = [filename,'.unix.txt']
   fid = fopen(tmpname, 'r');
   fid2 = fopen([filename,'.mac.txt'],'w');
   if fid > 0
      txt = fread(fid, 'uchar');
      fclose(fid);
      delete(tmpname);
      if ~any(txt>127)|force
         txt = char(txt');
         txt = regexprep(txt, char(10),char(13));
         status = fwrite(fid2, txt, 'uchar');
         if status > 1
            status = fclose(fid2);
         else
            disp(['Unable to write file ', filename, '.mac.txt']);
         end

         %Either force is true or no high ascii codes found
      else %Probably a binary file.
         status = -1;
      end
   else
      disp(['Unable to open file ', filename])
      status = -1;
   end
end
