function [c,a] = savgo(nl, nr, m, ld);
np=nr+nl+1;
a=zeros(1+m);  
b=zeros([1:1+m]);

%%% The process below could replace all of savgo using Matlab instead of Num. Recipes.
%   
% for j=1:1:m+1
%    j_actual=j-1
%    for i=1:1:nr+nl+1
%       i_actual=i-(nl+1);
%       a(i,j)=i_actual^j_actual;
%    end;
% end;
% 
% a_matrix=(a'*a)^(-1);
% 
% c=ones(size([1:nr+nl+1]));
% 
% for n=1:nr+nl+1
%    n_actual=n-(nl+1);
%    sum=0;
%    for mm=0:1:m
%      sum=sum + a_matrix(1,mm+1)*n_actual^mm;
%    end;
%    c(n)=sum;
%    %disp(sum);
% end;

%%%

i = [-nl:nr];
j = [0:m];

for I = 1:length(i)
    for J = 1:length(j)
        A(I,J) = i(I).^j(J);
    end
end
a = A' * A;

%%%
[a, indx, d] = ludcmp(a);
b(ld+1)=1.0;
x = lubksb(a, indx, b);

for kk=1:1:np
   c(kk)=0.0;
end;

for k=-nl:1:nr
   sum=x(1);
   fac=1.0;
      for mm=1:1:m
         fac=fac*k;
         sum=sum + x(mm+1)*fac;
      end;
   kk=mod((np-k),np) + 1;
%   c(kk)=sum;
   c(k+nl+1)=sum;
end;

   
