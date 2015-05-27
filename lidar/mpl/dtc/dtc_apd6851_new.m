function [dtc_MHz] = dtc_apd6851_new(x);
% [dtc_MHz] = dtc_apd6851_new(x);
% This function uses a tablecurve output fit for the deadtime correction of APD6851.
% It requires counts per microsecond and outputs corrected cts/us.

%    TableCurve Function: .\CDEF.tmp Feb 17, 2005 0:48:23 AM 
%    DTC for APD 6851 in MPL-PS NSA 
%    X= MHz 
%    Y= dtc 
%    Eqn# 2396  y=a+bx^(1.5)+cx^(2.5)+de^x 
%    r2=0.9994340090164588 
%    r2adj=0.9992925112705734 
%    StdErr=0.03659940482474985 
%    Fstat=10006.2713879149 
   a= 1.001487871959732 
   b= 0.02031368727715139 
   c= 0.001204373143467544 
   d= 3.063594129252302E-06 
 *--------------------------------------------------------------*/

  x1= x.*sqrt(x);
  x2=x.*x.*sqrt(x);
  x3=exp(x);
  y = a + b .* x1 + c .* x2 + d .* x3;

  dtc_MHz = y .* x;