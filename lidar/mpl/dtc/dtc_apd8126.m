function [dtc_cts] = dtc_apd8126(raw_cts);
% [dtc_cts] = dtc_apd8126(raw_cts);
% This function uses a tablecurve output fit for the deadtime correction of
% APD8126 in the MPL at SGP as of 2004-05-16. 
%    Eqn# 1535  y^(-1)=a+bx^3+c/x 
%    a= -0.05578176389719666 
%    b= -3.81300961983901E-06 
%    c= 1.000972202313869 
% 
% %  *--------------------------------------------------------------*/
% This curve generated from a fit of D(MHz) vs R(MHz) on 2005-09-07
   a= -0.05578176389719666 ;
   b= -3.81300961983901E-06 ;
   c= 1.000972202313869 ;


dtc_cts = zeros(size(raw_cts));
pos = find(raw_cts>0);
y = a + b .* (raw_cts(pos).^3) + c ./ raw_cts(pos);
dtc_cts(pos) = 1./y;

