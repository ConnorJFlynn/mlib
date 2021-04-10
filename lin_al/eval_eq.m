function [Z] = eval_eq(X,K,eq)
% usual syntax: [Z] = eval_eq(X,K,eq);
% The equation eq must be given as a string matrix with each row
% being a seperable arithmetic elements. 
% For example "X + X.^2 + ln(X) + 1./X + X.*exp(X)" would be 
% 	eq =
% 	X        
% 	X.^2     
% 	ln(X)    
% 	1./X     
% 	X.*exp(X)
% Also, don't forget the "dots" !
% Modified 2019-08-23 for evaluation of n-dimensional K
[order] = size(K,2);
Z=zeros([size(X,1),size(K,1)]);
if iscell(eq)
   for i = 1:order
      term = eval(eq{i});
      if numel(term)==1
         term = term.*ones(size(X));
      end
      Z = Z + term*(K(:,i)');
   end
else
   for i = 1:order
      term = eval(eq(i));
      if numel(term)==1
         term = term.*ones(size(X));
      end
      Z = Z + term*(K(:,i)');
   end
end
return
