function [C] = downIQ(D,n,dim);
% [C] = downIQ(D,n,dim);
% C is a downsampled version of D obtained by computing the mean of the IQ
% of n samples. 
%%
if ~exist('dim','var')
   dim = find(size(D)~=1,1,'first');
end
in_len = size(D,dim);
out_len = ceil(in_len./n);
[D,NSHIFTS] = shiftdim(D,dim-1);
outsize = size(D);
outsize(1) = ceil(outsize(1)./n);
midsize = [n,outsize];
C = NaN(midsize);
C(1:numel(D)) = D(:);
%%
[tmp,ii] = sort(C);
bot = max([1,floor(n.*.25)]);top = min([n,ceil(n.*.75)]);
C = tmp(bot:top,:); % B = A(IX)
nanC = sum(isNaN(C));
C(isNaN(C)) = 0;

C = sum(C,1);
C = shiftdim(C,NSHIFTS)./([top-bot+1]-nanC);
if all(fliplr(outsize)==size(C))
   C = C';
end
%%