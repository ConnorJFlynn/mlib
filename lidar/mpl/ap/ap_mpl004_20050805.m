function y = ap_mpl004_20050805(range);
% /*--------------------------------------------------------------*
%    TableCurve Function: .\CDEFD.tmp Sep 8, 2005 9:25:36 PM 
%    sgpmplC1.20050805.afterpulse 
%    X= range (km) 
%    Y= afterpulse counts (MHz) 
%    Eqn# 7919  y=(a+clnx+e(lnx)^2+g(lnx)^3+i(lnx)^4+k(lnx)^5)/(1+blnx+d(lnx)^2+f(lnx)^3+h(lnx)^4+j(lnx)^5) [NL] 
%    r2=0.9999968748770793 
%    r2adj=0.9999968574713314 
%    StdErr=5.291790915486829E-05 
%    Fstat=63229315.29096655 
%    a= 0.00288377409788465 
%    b= 0.4532866747049693 
%    c= -0.00527603792775683 
%    d= 0.582347690899428 
%    e= 0.006319484122226883 
%    f= 0.3297119217713086 
%    g= -0.00331647132442744 
%    h= 0.08249469350740458 
%    i= 0.0008157655348996462 
%    j= 0.008510195728860461 
%    k= -7.272602457686166E-05 
%  *--------------------------------------------------------------*/
% 
%   double y;
%   x=log(x);
%   y=(0.002883774097884650+x*(-0.005276037927756830+
%     x*(0.006319484122226883+x*(-0.003316471324427440+
%     x*(0.0008157655348996462+x*-7.272602457686166E-05)))))/
%     (1.0+x*(0.4532866747049693+x*(0.5823476908994280+
%     x*(0.3297119217713086+x*(0.08249469350740458+
%     x*0.008510195728860461)))));
%   return(y);
% CJF 20061028: handles zero and negative range with ap=0;
   a= 0.00288377409788465 ;
   b= 0.4532866747049693 ;
   c= -0.00527603792775683; 
   d= 0.582347690899428 ;
   e= 0.006319484122226883; 
   f= 0.3297119217713086 ;
   g= -0.00331647132442744; 
   h= 0.08249469350740458 ;
   i= 0.0008157655348996462; 
   j= 0.008510195728860461 ;
   k= -7.272602457686166E-05; 

y = zeros(size(range));
lnx = log(range(range>0));
y(range>0) = (a + c .* lnx + e .* (lnx).^2 + g .* (lnx).^3 + i .* (lnx).^4 + k .* (lnx).^5) ./ (1 + b .* lnx + d .* (lnx).^2 + f .* (lnx).^3 + h .* (lnx).^4 + j .* (lnx).^5); 
