function D = den2plot(X,Y,d)
N = length(X);
ds = zeros(N,N);XX = ds; YY = ds;
dds = ds;
X = X-min(X); Y = Y-min(Y);
X = X./max(X); Y = Y./max(Y);

% tic
% for i = 1:N
%    for j = (i+1):N
%       ds(i,j) = sqrt((X(i)-X(j)).^2+(Y(i)-Y(j)).^2);
%       ds(j,i) = ds(i,j);
%    end
% end
% toc
% tic
% This is faster but computationally less efficient in that it does not take
% advantage of the diagonal symmetry ds(i,j) == ds(j,i)
xX = [X;X]; yY = [Y;Y];
for n = N:-1:1
  XX(:,n) = xX(n:(N+n-1)); 
  YY(:,n) = yY(n:(N+n-1));
  dds(:,n) = sqrt((XX(:,n)-XX(:,1)).^2 +   (YY(:,n)-YY(:,1)).^2);
end
% toc
if ~isavar('d')
   d = 0.01;
end
% D = sum(ds<d);
Dd = sum(dds<d,2);
end


