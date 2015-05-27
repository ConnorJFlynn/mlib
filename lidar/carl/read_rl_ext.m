function rl = read_rl_ext(file_path);
% rl = read_rl_ext(file_path);
      pname = [];
if ~exist('file_path', 'var')
   while isempty(pname)
      [fname, pname] = uigetfile(['*.*']);
   end
else
   if exist(file_path, 'file')
      [pname, fname, ext] = fileparts(file_path);
      pname = [pname, '/'];
      fname = [fname,'.', ext];
   elseif exist('file_path', 'dir')

      while isempty(pname)
         [fname, pname] = uigetfile([file_path,'*.*']);
      end
   end
end
disp(['Loading ', fname]);
rl = ancload([pname, fname]);

missing_val = rl.vars.extinction_married1.atts.missing_value.data;
missing = find(abs(rl.vars.extinction_married1.data-missing_val)<1);
rl.vars.extinction_married1.data(missing) = NaN;
figure; imagesc(serial2Hh(rl.time), rl.vars.height_high.data , ...
   rl.vars.extinction_married1.data); axis('xy'); colorbar;
cv = caxis; v = axis;

missing_val = rl.vars.backscatter.atts.missing_value.data;
missing = find(abs(rl.vars.backscatter.data-missing_val)<1);
rl.vars.backscatter.data(missing) = NaN;
figure; imagesc(serial2Hh(rl.time), rl.vars.height_high.data , ...
   rl.vars.backscatter.data); axis('xy'); colorbar;
cv = caxis([0, .002]); v = axis;




