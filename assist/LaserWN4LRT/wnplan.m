function planck=wnplan(vn,tem)
%Boltzmann Constan
	b = 1.380658d-16;
% Velocity of Light
	c = 2.99792458d+10;
% Planck Constant
	h = 6.6260755d-27;

	c1 = 2.d0*h*c*c;
	c2 = h*c/b;
	%bnt(x,y,z)=x/(exp(y/z)-1.d0)
    x=c1*vn^3;
    y=c2*vn;
    z=tem;
    planck=x/(exp(y/z)-1.d0);
