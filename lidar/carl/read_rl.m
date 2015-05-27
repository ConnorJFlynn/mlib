function rl = read_rl(file_path);
% rl = read_rl(file_path);

if ~exist('file_path', 'var')
   while isempty(pname)
      [fname, pname] = uigetfile([file_path,'*.*']);
   end
else
   if exist('file_path', 'file')
      [pname, fname, ext] = fileparts(file_path);
      pname = [pname, '/'];
      fname = [fname,'.', ext];
   elseif exist('file_path', 'dir')
      pname = [];
      while isempty(pname)
         [fname, pname] = uigetfile([file_path,'*.*']);
      end
   end
end
rl = ancload([pname, fname]);
