function [C,nanC] = downsample(D,n,dim);
% [C,nanC] = downsample(D,n,dim);
% C is a downsampled version of D with dimension dim having length/n
% nanC is the number of NaNs in each downsampled division
% Each C(i) = sum(D(i:i+n-1,:))./(n-nanC)

if ~exist('dim','var')
   dim = find(size(D)~=1,1,'first');
end
[D,NSHIFTS] = shiftdim(D,dim-1);
nand = builtin('isnan',D);
D(nand) = 0;
S = size(D);
%Have to make sure that all n following records have same number of subsamples
max_length = floor(S(1)./n)*n; 
if isempty(strfind(class(D),'log'))
    C = zeros([floor(max_length./n),S(2:end)],class(D));
else
    C = false([floor(max_length./n),S(2:end)]);
end
nanC = zeros([floor(max_length./n),S(2:end)]);
for d = 0:(n-1)
   r = [1+d:n:max_length];
   C = C + D(r,:);
   nanC = nanC + real(nand(r,:));
end
nanC = shiftdim(nanC,NSHIFTS);
C = double(shiftdim(C,NSHIFTS))./(n-nanC);
