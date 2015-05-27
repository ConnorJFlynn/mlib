% ScatCoef	Scattering coefficients
%		[a,b]=ScatCoef(m,x,nmax)
%		returns the two column vectors a and b containing
%		the scattering coefficients for particles of size x
%		and refractive index relative to medium m, from n=1
%		to n=nmax.

% Written by and copyright
%		Dave Barnett
%		Optical Engineering Group
%		Dept. of Electrical and Electronic Engineering
%		Loughborough University
%		20th November 1996

%		Corrected 4th September 1997
%			m missing from calculation of dphim

%		5th September 1997
%			computation method optimised by use of vector methods

function [a,b] = ScatCoef(m,x,nmax)

N = (1:nmax)';
phi = RB1(x, nmax);
phim = RB1(m*x, nmax);
zeta = RB2(x, nmax);
xi = phi + i * zeta;
phin_1 = [sin(x);phi(1:nmax-1)];
phimn_1 = [sin(m*x);phim(1:nmax-1)];
zetan_1 = [-cos(x);zeta(1:nmax-1)];
dphi = phin_1-N.*phi/x;
dphim = phimn_1-N.*phim/(m*x);
dzeta = zetan_1-N.*zeta/x;
dxi = dphi + i * dzeta;
a = (m*phim.*dphi - phi.*dphim) ./ (m*phim.*dxi - xi.*dphim);
b = (phim.*dphi - m*phi.*dphim) ./ (phim.*dxi - m*xi.*dphim);