function [dtc_cts] = dtc_apd10101(raw_cts);
% [dtc_cts] = dtc_apd10101(raw_cts);
% This function uses a tablecurve output fit for the deadtime correction of APD10101
% in the new MPL-4B SN102 provided in August 2005.
%    Eqn# 1535  y^(-1)=a+bx^3+c/x 
%    a= -0.02952023841754335 
%    b= -6.177011361875681E-06 
%    c= 0.8801429047234354 
% 
% %  *--------------------------------------------------------------*/
% This curve generated from a fit of D(MHz) vs R(MHz) on 2005-09-06
   a= -0.02952023841754335 ;
   b= -6.177011361875681E-06; 
   c= 0.8801429047234354 ;

dtc_cts = zeros(size(raw_cts));
pos = find(raw_cts>0);
y = a + b .* (raw_cts(pos).^3) + c ./ raw_cts(pos);
dtc_cts(pos) = 1./y;

