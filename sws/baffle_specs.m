%%
d = 25.4;
alpha_d = 2;
alpha = alpha_d*pi/180;
L1 = 8*25.4;
LL = 30*35.4;
A1 = atan(alpha).*L1*2 +d;
AA = atan(alpha).*LL*2 +d;
AA_in = AA./(2*25.4);
%if L1 = L2, then beta follows
beta = atan((A1+d)./(2*L1));
beta_d = beta * 180/pi;
%%






%%






%%





%%




