function [K, Z] = fitme(X,Y,e)
%usual syntax: [K,Z] = fitme(X,Y,e);
Z=zeros(size(X));
[order,str_len] = size(e);
base_e = zeros([length(X),order]);
for i = 1:order
  base_e(:,i) = eval(e(i,:))';
end 
size(Y);
size(base_e);
K = Y/base_e';
for i = 1:order
  Z = Z + K(i).*eval(e(i,:));
end;
