% RB2	the Ricatti-Bessel function of the second kind
%		RB2(rho, nmax) for the value rho from n=1 to n=nmax.

% Written by and copyright
%		Dave Barnett
%		Optical Engineering Group
%		Dept. of Electrical and Electronic Engineering
%		Loughborough University
%		20th November 1996

function zeta = RB2(rho, nmax)
zeta(1,1) = -cos(rho)/rho - sin(rho);
zeta(2,1) = 3*zeta(1)/rho + cos(rho);
for n=3:nmax
	zeta(n,1) = (2*n-1)*zeta(n-1)/rho - zeta(n-2);
end