function D = ptdens3d(X,Y,Z,d)
% D = ptdens3d(X,Y,Z,d)
% ptdens computes point density of X,Y,Z pairs as number N / distance d
if length(X)~=length(Y)
   error('X and Y must be equal length');
end
N = length(X);
if ~isavar('d')
   d = 1./sqrt(N);
end
D = zeros(size(X));

if size(X,1)==1 && size(X,2)>1
   X = X';
end 
if size(Y,1)==1
   Y = Y';
end
if size(Z,1)==1
   Z = Z';
end
for n = N:-1:1
   dX = (abs(X-X(n))<d); 
   dY = (abs(Y-Y(n))<d);
   dZ = (abs(Z-Z(n))<d);
   % D(n) = sum(dX.*dY.*dZ);
   D(n) = sum(dX&dY&dZ);
   % D(n) = sum((sqrt((X-X(n)).^2)<d)&(sqrt((Y-Y(n)).^2)<d));
  if rem(n,10000)==0
     disp(n./10000)
  end
end
D = D./d.^3;
end


