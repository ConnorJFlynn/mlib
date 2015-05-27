function [x] = lubksb(a, indx, b), 
ii=0;
n = length(indx);
for i=1:n
   ip=indx(i);
   sum=b(ip);
   b(ip)=b(i);
   if ii
      for j=ii:i-1
         sum=sum-a(i,j)*b(j);
      end;
  elseif sum;
      ii=i;
   end;
   b(i)=sum;
end;

for i=n:-1:1
   sum=b(i);
   for j=i+1:n
      sum=sum - a(i,j)*b(j);
   end;
   b(i)=sum/a(i,i);
end;,
x = b;