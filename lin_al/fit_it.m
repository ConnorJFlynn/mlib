function K = fit_it(X,Y,eq,V)
% usual syntax: K = fit_it(X,Y,eq, V);
% % X and Y must be Mx1 column vectors.  Optional array V has cells of length Mx1.  
% The equation eq must be given as a string matrix with each row
% being a seperable arithmetic element referencing X or the Mx1 cells of V
 
% For example "X + X.^2 + ln(X) + 1./X + X.*exp(X) + V{1}" would be 
% 	eq =
% 	X        
% 	X.^2     
% 	ln(X)    
% 	1./X     
% 	X.*exp(X)
% Also, don't forget the "dots" !
% Modified 2019-12-28 to allow for non-X dependent V
% Previously modified to permit evaluation of n-dimensional Y yielding N-dim K

[order,str_len] = size(eq);
base_e = zeros([length(X),order]);
for i = 1:order
  base_e(:,i) = eval(eq{i});
end 
size(Y);
size(base_e);
K = Y'/base_e'; 
% Z = eval_eq(X,K,eq);
%for i = 1:order
%  Z = Z + K(i).*eval(eq(i,:));
%end;
