function ap = ap_mpl004_20040516(range);
% ap = sgpmplC1.20040516(range);
% Accepts range in km
% Returns afterpulse in MHz
%    Eqn# 1614  y^(-1)=a+b/x^(0.5)+c/x^2 
%    r2=0.9740020186640806 
%    r2adj=0.9739613120127195 
%    StdErr=0.1906115499550184 
%    Fstat=35909.74710023598 
    a= -0.2069912707456796 ;
    b= -0.1693521241773382 ;
    c= -0.003220211499415258 ;

   %We'll be dividing by range, so cull out all non-positive points
   ap = zeros(size(range));
   pos = find(range>0);
   x=range(pos);
   y = zeros(size(x));
   y = a + b./(x.^.5) + c./(x.^2);
   y = 1./y;
   ap(pos) = 10.^y;
    
