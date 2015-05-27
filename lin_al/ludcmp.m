    function [LU,indx,d] = ludcmp(a);
%LU decomposition from Numerical Recipes via Donna
tiny=1.0e-20;
n = max(size(a));

vv = zeros([1:n]);
d=1;
for i=1:n
   big=0;
   for j=1:n
      temp=abs(a(i,j));
      if temp > big
         big=temp;
      end;
   end;
   vv(i)=1.0/big;
end;

for j=1:n
   for i=1:j-1     %i<j
      sum=a(i,j);
      for k=1:i-1  %k<i
         sum=sum-a(i,k)*a(k,j);
      end;
      a(i,j)=sum;
   end;
   big=0.0;
   for i=j:n
      sum=a(i,j);
      for k=1:j-1 %k<j
         sum=sum-a(i,k)*a(k,j);
      end;
      a(i,j)=sum;
      dum=vv(i)*abs(sum);
      if dum >= big
         big=dum;
         imax=i;
      end;
    end;

    if j~=imax
       for k=1:n
          dum=a(imax,k);
          a(imax,k)=a(j,k);
          a(j,k)=dum;
       end;
       d=-d;
       vv(imax)=vv(j);
    end;

    indx(j)=imax;
    if a(j,j)==0
       a(j,j)=tiny;
    end;
    if j~=n
       dum=1/a(j,j);
       for i=j+1:n
          a(i,j)=a(i,j)*dum;
       end;
    end;
end
LU = a;
