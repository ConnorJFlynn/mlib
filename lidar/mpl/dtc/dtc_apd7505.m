function R = dtc_apd7505(x);
%R = dtc_apd7505(x);
% This function implements TableCurve function 2086 
% Provided with Detected Counts x in MHz, it calculates the dtc and applies
% it to return Real Counts in MHz.

%    TableCurve Function: .\CDE9.tmp Feb 16, 2005 11:41:36 PM 
%    APD 10443 GRUVLI COPOL MPACE 
%    X= MHz 
%    Y= dtc 
%    Eqn# 2086  y=a+bx+cx^3+de^x 
%    r2=0.9999043834730896 
%    r2adj=0.9998788857325801 
%    StdErr=0.01685262132630959 
%    Fstat=55773.02952572842 
   a= 1.004651368951925 
   b= 0.07107200152346514 
   c= 0.0007438143590974061 
   d= 6.917021328626028E-06 
 
  y = a + b .* x + c .* (x.^3) + d .* exp(x);
  R = x .* y;
