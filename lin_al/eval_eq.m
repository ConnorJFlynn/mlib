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
[order] = length(K);
Z=zeros(size(X));
if iscell(eq)
   for i = 1:order
      Z = Z + K(i).*eval(eq{i});
   end
else
   for i = 1:order
      Z = Z + K(i).*eval(eq(i,:));
   end
end
return
