function mat1 = stitch_mats(mat1, mat2)
% mat1 = stitch_mats(mat1,mat2)
% Combines two ASSIST mat files into a single time series file
time_len = length(mat1.time);
[~, ii] = sort([mat1.scanNb,mat2.scanNb]);
mat_fields = (fieldnames(mat1));

for f = length(mat_fields):-1:1
    jj = find(size(mat1.(mat_fields{f}))==time_len);
    if jj==1
        X = [mat1.(mat_fields{f});mat2.(mat_fields{f})];
        mat1.(mat_fields{f}) = X(ii,:);
    elseif jj==2
        X = [mat1.(mat_fields{f}),mat2.(mat_fields{f})];
        mat1.(mat_fields{f}) = X(:,ii);
    end
end

return