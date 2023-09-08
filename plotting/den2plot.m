function D = den2plot(X,Y,d)
N = length(X);
ds = zeros(N,N);XX = ds; YY = ds;
X = X-min(X); Y = Y-min(Y);
X = X./max(X); Y = Y./max(Y);
% xX = [X;X]; yY = [Y;Y];
% for n = 1:N
%   XX(:,n) = xX(n:(N+n-1)); 
%   YY(:,n) = yY(n:(N+n-1));
%   ds(:,n) = sqrt((XX(:,n)-XX(:,1)).^2 +   (YY(:,n)-YY(:,1)).^2);
% end

for i = 1:N
   for j = (i+1):N
      ds(i,j) = sqrt((X(i)-X(j)).^2+(Y(i)-Y(j)).^2);
      ds(j,i) = ds(i,j);
   end
end
if ~isavar('d')
   d = 0.01;
end
D = sum(ds<d);

end


