#include <math.h> 

/*--------------------------------------------------------------*/
double eqn6504(double x)
/*--------------------------------------------------------------*
   TableCurve Function: C:\\mlib\\lidar\\mpl\\overlap\\tnmpl_col_ol.c Oct 13, 2009 12:18:04 PM 
   C:\\TableCurve2Dv5.01\\CLIPBRD.PRN 
   X= range (km) 
   Y= ol_corr 
   Eqn# 6504  y=a+b/x+c/x^2+d/x^3+e/x^4+f/x^5+g/x^6 
   r2=0.9999375313999432 
   r2adj=0.9999371642461226 
   StdErr=0.05262204110419395 
   Fstat=3180065.761962524 
   a= 0.7875005085090033 
   b= 3.046237592157198 
   c= -1.978184121716092 
   d= 0.9150213980530104 
   e= -0.1271009697478762 
   f= 0.00873559946989401 
   g= -0.0002488108295352162 
 *--------------------------------------------------------------*/
{
  double y;
  x=1.0/x;
  y=0.7875005085090033+x*(3.046237592157198+
    x*(-1.978184121716092+x*(0.9150213980530104+
    x*(-0.1271009697478762+x*(0.008735599469894010+
    x*-0.0002488108295352162)))));
  return(y);
}
 