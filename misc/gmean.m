function [gbar,goodA ] = gmean(A);
% [gbar,goodA] = gmean(A);
% Returns the geometric mean of positive-definite elements and a boolean
% flag of included.
goodA = A>0;
[row,col] = size(A);
if row==1 || col==1
   gbar = exp(mean(log(A(goodA))));
else
   for c = col:-1:1
      A_col = A(:,c); goodA = A_col>0;
      gbar(c) = exp(mean(log(A_col(goodA))));
   end
end


