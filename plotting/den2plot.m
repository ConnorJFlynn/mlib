function D = den2plot(X,Y,d)
if isrowvector(X)
   X = X';
end 
if isrowvector(Y)
   Y = Y';
end

N = length(X);
% ds = zeros(N,N);XX = ds; YY = ds;
dds = zeros(N,N);
X = X-min(X); Y = Y-min(Y);
maxd = max([max(X), max(Y)]);
X = X./maxd; Y = Y./maxd;

% tic
% for i = 1:N
%    for j = (i+1):N
%       ds(i,j) = sqrt((X(i)-X(j)).^2+(Y(i)-Y(j)).^2);
%       ds(j,i) = ds(i,j);
%    end
%    disp(num2str(N-i))
% end
% 
% toc
% tic
% % This is faster but computationally less efficient in that it does not take
% % advantage of the diagonal symmetry ds(i,j) == ds(j,i)
xX = [X;X]; yY = [Y;Y];
for n = N:-1:1
  XX = xX(n:(N+n-1)); 
  YY = yY(n:(N+n-1));
  dds(:,n) = sqrt((XX-X).^2 +   (YY-Y).^2);
  if rem(n,1000)==0
     disp(n./1000)
  end
end
% toc
if ~isavar('d')
   d = .25./sqrt(N);
end
 % Dd = sum(ds<d,1);
 D = sum(dds<d,2);
% figure; 
% sb(1) = subplot(2,1,1); scatter(X,Y,4,D);
% sb(2) = subplot(2,1,2); scatter(X,Y,4,Dd);
% linkaxes(sb,'xy');

end


