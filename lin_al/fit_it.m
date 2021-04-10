function [K, Z] = fit_it(X,Y,eq)
% usual syntax: [K,Z] = fit_it(X,Y,eq);
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
% Modified 2019-08-23 for evaluation of n-dimensional Y yielding N-dim K
Z=zeros(size(X));
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
