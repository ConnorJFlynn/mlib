function mat1 = stitch_in_time(mat1, mat2)
% mat1 = stitch_in_time(mat1, mat2)
% stitches two mat files together along time
time_len = length(mat1.time);
% [~, ii] = sort([mat1.scanNb,mat2.scanNb]);
% [~,iii] = unique([mat1.scanNb,mat2.scanNb]);
[~,ii] = unique([mat1.time;mat2.time]);
mat_fields = (fieldnames(mat1));

for f = length(mat_fields):-1:1
   jj = find(size(mat1.(mat_fields{f}))==time_len);
   if jj==1
      X = [mat1.(mat_fields{f});mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii,:);
   elseif jj==2
      X = [mat1.(mat_fields{f}),mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii);
   end
   
end

return
%%