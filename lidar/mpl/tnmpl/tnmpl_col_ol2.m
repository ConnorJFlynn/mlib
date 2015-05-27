function ol = tnmpl_col_ol2(x);

   a= 0.8850630927072656; 
   b= 2.374954760483837 ;
   c= -0.6203760761117283; 
   d= 0.4597752722870739 ;
   e= -0.03286946453186137 ;
   f= 0.001019846510959296 ;
   g= -4.272394668907211E-05;

%    Eqn# 6504  y=a+b/x+c/x^2+d/x^3+e/x^4+f/x^5+g/x^6 
ol=a+ b./x + c./(x.^2) + d./(x.^3) + e./(x.^4) + f./(x.^5) + g./(x.^6) ;

    