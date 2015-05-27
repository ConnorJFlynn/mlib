function R = dtc_apd6850_ipa(x);
%R = dtc_apd6850_ipa(x);
% This function implements TableCurve function 2041 
% Provided with Detected Counts x in MHz, it calculates the dtc and applies
% it to return Real Counts in MHz.

%    TableCurve Function: .\CDED.tmp Feb 17, 2005 0:02:43 AM 
%    DTC for APD6850 for MPL IPA 
%    X= MHz 
%    Y= dtc 
%    Eqn# 2041  y=a+bx+cx^2+de^x 
%    r2=0.9988825315345133 
%    r2adj=0.9986031644181416 
%    StdErr=0.0489443051633331 
%    Fstat=5065.319085220655 
   a= 1.005607182028925 ;
   b= 0.02152653704516654; 
   c= 0.008130578112000246; 
   d= 2.519789474994764E-06; 

  y = a + b .* x + c .* x.^2 + d .* exp(x);
  R = x .* y;
