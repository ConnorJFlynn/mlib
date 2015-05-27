function dif2 = diff2(A, dim);
% This function differs from diff in that it returns a vector of the same original size
% This is accomplished through the definition of diff2(i) = A(i) - A(i-1) 
% and diff2(1) = A(1).  This permits cumsum to be complementary with diff2.

%% fix this to handle matrix
if ~exist('dim','var')
   dim = find(size(A)~=1,1,'first');
end

[A,NSHIFTS] = shiftdim(A,dim-1);
dif2 = [A(2,:)-A(1,:); (A(3:end,:)-A(1:end-2,:))./2; A(end,:)-A(end-1,:)];
% dif2 = [A(1,:);diff(A)];
dif2 = shiftdim(dif2,NSHIFTS);

%    dlogd = [log10(x_range(2)/x_range(1))  ...
%        log10(x_range(3:Nx) ./ x_range(1:(Nx-2)))/2 ...
%        log10(x_range(Nx) / x_range(Nx-1))];
