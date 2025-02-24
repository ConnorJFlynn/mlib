function D = ptdens2(X,Y,d)
% D = ptdens(X,Y,d)
% ptdens computes point density of X,Y pairs as number N / distance d
if length(X)~=length(Y)
   error('X and Y must be equal length');
end
N = length(X);
if ~isavar('d')
   d = 1./sqrt(N);
end
D = zeros(size(X));
if isrow(X)
   X = X';
end 
if isrow(Y)
   Y = Y';
end

for n = N:-1:1
   dx = abs(X-X(n))<d;
   dx(dx) = abs(Y(dx)-Y(n))<d;
   D(n) = sum(dx);
  if rem(n,10000)==0
     disp(n./10000)
  end
end
D = D./n;

end


