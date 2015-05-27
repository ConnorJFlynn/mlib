#include <math.h> 

/*--------------------------------------------------------------*/
double eqn6507(double x)
/*--------------------------------------------------------------*
   TableCurve Function: C:\\mlib\\lidar\\mpl\\overlap\\sgp_20090623_olcorr.c Mar 5, 2009 12:16:31 PM 
   C:\\TableCurve2Dv5.01\\CLIPBRD.PRN 
   X= range 
   Y= ol_corr 
   Eqn# 6507  y=a+b/x+c/x^2+d/x^3+e/x^4+f/x^5+g/x^6+h/x^7+i/x^8+j/x^9 
   r2=0.9999959523062298 
   r2adj=0.9999958874393424 
   StdErr=0.02339577559237505 
   Fstat=17156476.57584973 
   a= 1.004078228431162 
   b= 0.07076482721167648 
   c= -1.132474696039111 
   d= 3.596662464131559 
   e= -1.997545497025638 
   f= 0.6296106816980558 
   g= -0.1185620687255613 
   h= 0.01305783437001198 
   i= -0.000771042921161738 
   j= 1.878499572451964E-05 
 *--------------------------------------------------------------*/
{
  double y;
  x=1.0/x;
  y=1.004078228431162+x*(0.07076482721167648+
    x*(-1.132474696039111+x*(3.596662464131559+
    x*(-1.997545497025638+x*(0.6296106816980558+
    x*(-0.1185620687255613+x*(0.01305783437001198+
    x*(-0.0007710429211617380+x*1.878499572451964E-05))))))));
  return(y);
}
 
