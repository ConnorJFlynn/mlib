function D = ptdens(X,Y,d)
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
if isrowvector(X)
   X = X';
end 
if isrowvector(Y)
   Y = Y';
end

for n = N:-1:1
   D(n) = sum((abs(X-X(n))<d)&(abs(Y-Y(n))<d));

  if rem(n,10000)==0
     disp(n./10000)
  end
end
D = D./n;

end


