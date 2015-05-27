function corr = ISDAC_hsrl_corr_20080406_L1(range);
%corr = ISDAC_hsrl_corr_20080406_L1(range);

% /*--------------------------------------------------------------*/
% double eqn1069(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: C:\\mlib\\lidar\\mpl\\overlap\\isdac_20080406_L2.eqn_1069.c Mar 28, 2009 8:00:34 AM 
%    C:\\TableCurve2Dv5.01\\CLIPBRD.PRN 
%    X= altitude 
%    Y= ol_corr_raw 
%    Eqn# 1069  y=a+bx^2+clnx/x 
%    r2=0.9996363781171938 
%    r2adj=0.999629201369507 
%    StdErr=0.0259745443901047 
%    Fstat=210306.8779464636 
%    a= 2.069674333379217 
%    b= -0.01085455706470102 
%    c= -2.55406273475156 
%  *--------------------------------------------------------------*/
% {
%   double y;
%   double x1,x2 ;
%   x1=x*x;
%   x2=log(x)/x;
%   y=2.069674333379217-0.01085455706470102*x1
%     -2.554062734751560*x2;
%   return(y);
% }
%  

   a= 2.069674333379217 ;
   b= -0.01085455706470102 ;
   c= -2.55406273475156 ;
   
   corr = NaN(size(range));
   pos = range>0;
   x = range(pos);
   x1=x.^2;
   x2=log(x)./x;
   corr(pos) = a + b.*x1 + c.*x2;
