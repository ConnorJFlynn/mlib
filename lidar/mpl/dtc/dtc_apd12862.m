function R = dtc_apd12862(x);
%R = dtc_apd10443(x);
% This function implements TableCurve function 7904 
% Provided with Detected Counts x in MHz, it calculates the dtc and applies
% it to return Real Counts in MHz.

% Rank 39  Eqn 7904  y=(a+cx+ex2)/(1+bx+dx2+fx3) [NL]
% r2 Coef Det    	DF Adj r2      	Fit Std Err    	F-value
% 0.9998181692   	0.9996969487   	0.0108302797   	10997.236618
%  Parm  	Value        	Std Error    	t-value      	95% Confidence Limits     	P>|t|
%  a    	1.005732871  	0.004612464  	218.0467760  	0.995455662  	1.016010081  	0.00000
%  b    	-0.15829658  	0.020059432  	-7.89137905  	-0.20299178  	-0.11360138  	0.00001
%  c    	-0.11988192  	0.021687549  	-5.52768430  	-0.16820480  	-0.07155905  	0.00025
%  d    	0.008420117  	0.001629128  	5.168481379  	0.004790194  	0.012050040  	0.00042
%  e    	0.003739942  	0.001077090  	3.472266115  	0.001340037  	0.006139848  	0.00600
%  f    	-0.00014959  	2.91019e-05  	-5.14025632  	-0.00021443  	-8.4748e-05  	0.00044
% Date           	Time           	File Source
% Jun 16, 2006   	10:26:45 PM    	C:\TableCurve2Dv5.01\CLIPBRD.WK1     
 
 a  =  	1.005732871 ; 
 b  =  	-0.15829658 ; 
 c  =  	-0.11988192 ; 
 d  =  	0.008420117 ; 
 e  =  	0.003739942 ; 
 f  =  	-0.00014959 ; 
 
  y=(a + c* x + e* x.^2)./(1+b*x+d*x.^2+f*x.^3);
  
  R = x .* y;
