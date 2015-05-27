function [mean_1, mean_2] = mean_mask_2dim(A, good, good1, good2)
% [mean_1, mean_2] = mean_mask_2dim(A, good, good1, good2);
% computes mean of 2-D variable in both directions including flagged values while ignoring nans
% flag may be specified in 1-D matching either dimension length or in 2D.
% One may separately provide flags for different dimensions as good, good1,
% good2.  The order is not important as they are "AND"ed.

notsame = find(size(A)~=size(good));
if length(notsame)==1
    if notsame==1
        good = ones(size(A,1),1)*good;
    else
        good= good*ones(1,size(A,2));
    end    
end

if exist('good1','var')
notsame = find(size(A)~=size(good1));
if length(notsame)==1
    if notsame==1
        good1 = ones(size(A,1),1)*good1;
    else
        good1= good1*ones(1,size(A,2));
    end    
end
good = good&good1;    
end

if exist('good2','var')
notsame = find(size(A)~=size(good2));
if length(notsame)==1
    if notsame==1
        good2 = ones(size(A,1),1)*good2;
    else
        good2= good2*ones(1,size(A,2));
    end    
end
good = good&good2;    
end

A(~good) = NaN;
mean_1 = meannonan(A,2);
mean_2 = meannonan(A,1);

return



