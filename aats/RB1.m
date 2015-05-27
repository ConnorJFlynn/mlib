% RB1	the Ricatti-Bessel function of the first kind
%		RB1(rho, nmax) for the value rho from n=1 to n=nmax.

% Written by and copyright
%		Dave Barnett
%		Optical Engineering Group
%		Dept. of Electrical and Electronic Engineering
%		Loughborough University
%		20th November 1996

function phi = RB1(rho, nmax)
nst = ceil(nmax + sqrt(101+rho));
phi(nst,1) = 0;
phi(nst-1,1) = 1e-10;
for n=nst-2:-1:1
	phi(n,1) = (2*n+3)*phi(n+1)/rho - phi(n+2);
end
phi0 = 3*phi(1)/rho - phi(2);
phi0 = sin(rho)/phi0;
phi = phi(1:nmax,:) * phi0;