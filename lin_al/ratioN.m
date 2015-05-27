function difN = ratioN(A, N, dim);
% This function is analogous to diffN.
% Both differ from diff in that they return a vector of the same original size
% with the definition difN(1+(N./2):(end-N./2)) = (A((1+N):end,:)-A(1:(end-N),:))./N;
% This ignores edges and will only handle even N

%% fix this to handle matrix
 
if ~exist('N','var')
   N = 2;
end

if ~exist('dim','var')
   dim = find(size(A)~=1,1,'first');
end


[A,NSHIFTS] = shiftdim(A,dim-1);
difN = ones(size(A));
difN(1+(N./2):(end-N./2),:) = (A((1+N):end,:)./A(1:(end-N),:));
% difN = [A(2,:)-A(1,:); (A(3:end,:)-A(1:end-2,:))./2; A(end,:)-A(end-1,:)];
% dif2 = [A(1,:);diff(A)];
difN = shiftdim(difN,NSHIFTS);

%    dlogd = [log10(x_range(2)/x_range(1))  ...
%        log10(x_range(3:Nx) ./ x_range(1:(Nx-2)))/2 ...
%        log10(x_range(Nx) / x_range(Nx-1))];


return