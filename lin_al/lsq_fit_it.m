function [K, Z] = lsq_fit_it(X,Y,eqq)
% usual syntax: [K,Z] = lsq_fit_it(X,Y,eq);
% The equation eq must be given as space delimited string of seperable arithmetic elements. 
% For example eqq = 'X  X.^2 ln(X) 1./X  X.*exp(X)' 
% Also, don't forget the "dots" !
eq = textscan(eqq,'%s', 'MultipleDelimsAsOne',true'); eq = eq{:};
Z=zeros(size(X));
[order,str_len] = size(eq);
base_e = zeros([length(X),order]);
for i = 1:order
  base_e(:,i) = eval(eq{i});
end 
% size(Y);
% size(base_e);
K = Y/base_e';
Z = eval_eq(X,K,eq);
%for i = 1:order
%  Z = Z + K(i).*eval(eq(i,:));
%end;
