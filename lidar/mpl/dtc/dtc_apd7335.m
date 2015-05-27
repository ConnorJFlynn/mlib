function R = dtc_apd7335(x);
%R = dtc_apd7335_1(x);
% This function implements TableCurve function 2086 
% Provided with Detected Counts x in MHz, it calculates the dtc and applies
% it to return Real Counts in MHz.

%    DTC AQR-FC 7335 IPA OCR 
%    X= MHz 
%    Y= DTC 
%    Eqn# 2086  y=a+bx+cx^3+de^x 
%    r2=0.999306086268856 
%    r2adj=0.9991739122248286 
%    StdErr=0.03509347898088838 
%    Fstat=10560.74307761132 
   a= 1.026054044865266 ;
   b= 0.0377548879652907 ;
   c= 0.0006398285205394298; 
   d= 2.63218180120628E-07 ;

  y = a + b .* x + c .* (x.^3) + d .* exp(x);
  R = x .* y;
