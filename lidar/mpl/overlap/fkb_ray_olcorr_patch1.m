function patch1 = fkb_ray_olcorr_patch1(x);

% #include <math.h> 
% 
% /*--------------------------------------------------------------*/
% double eqn39(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: C:\\mlib\\lidar\\mpl\\overlap\\fkb_ray_ol_patch1.c Mar 9, 2009 0:04:02 AM 
%    C:\\TableCurve2Dv5.01\\CLIPBRD.PRN 
%    X= range 
%    Y= patch1 
%    Eqn# 39  lny=a+b/x^(1.5) 
%    r2=0.9902898204290416 
%    r2adj=0.9901902288436984 
%    StdErr=0.01533998426220576 
%    Fstat=19989.00261171311 
%    a= -0.06530147463329494 
%    b= 1.740289299597634 
%  *--------------------------------------------------------------*/
% {
%   double y;
%   double x1 ;
%   x1=1.0/(x*sqrt(x));
%   y=-0.06530147463329494+1.740289299597634*x1;
%   return(exp(y));
% }
%  
   a= -0.06530147463329494; 
   b= 1.740289299597634;
   patch1=exp(a+b./(x.^(1.5)));
return