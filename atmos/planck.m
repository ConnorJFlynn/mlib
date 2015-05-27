function rad = planck(lambda,T);
c = 3e8;
h = 6.626e-34;
k = 1.38e-23;

rad = 2*pi*c^2*h/lambda^5 * (exp(h*c/(lambda*k*T))-1)^(-1);
