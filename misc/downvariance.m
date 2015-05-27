function [C,nanC] = downvariance(D,n,dim);
% [C,nanC] = downvariance(D,n,dim);
% C is a variance over N samples of D having length/n
% nanC is the number of NaNs in each downsampled division
% Each C(i) = sum(D(i:i+n-1,:))./(n-nanC)
% Modified on Jan 10 to handle complex quantities.

if ~exist('dim','var')
   dim = find(size(D)~=1,1,'first');
end
[D,NSHIFTS] = shiftdim(D,dim-1);
nand = isNaN(D);
D(nand) = 0;
S = size(D);
%Have to make sure that all n following records have same number of subsamples
max_length = floor(S(1)./n)*n; 
C1 = zeros([floor(max_length./n),S(2:end)]);
C2 = C1;
nanC = C1;

for d = 0:(n-1)
   r = [1+d:n:max_length];
   C1 = C1 + D(r,:);
   C2 = C2 + D(r,:).*conj(D(r,:));
   nanC = nanC + real(nand(r,:));
end
nanC = shiftdim(nanC,NSHIFTS);
C1 = (shiftdim(C1,NSHIFTS)./(n-nanC)).*conj((shiftdim(C1,NSHIFTS)./(n-nanC)));
C2 = (shiftdim(C2,NSHIFTS))./(n-nanC);
C = C2 - C1;