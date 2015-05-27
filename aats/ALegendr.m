% ALegendr	the angular dependent Associated Legendre Polynomials
%		[p,t]=ALegendr(ang, nmax)
%		produces matrices p and t with rows n=1 to n=nmax
%		for pi and tau functions rescpectively.

% Written by and copyright
%		Dave Barnett
%		Optical Engineering Group
%		Dept. of Electrical and Electronic Engineering
%		Loughborough University
%		20th November 1996

function [p,t] = ALegendr(ang, nmax)
p(1,:) = ones(1,size(ang,2));
t(1,:) = cos(ang);
p(2,:) = 3*cos(ang);
t(2,:) = 2*cos(ang).*p(2,:)-3;
for n=3:nmax
	p(n,:) = ((2*n-1)*cos(ang).*p(n-1,:) - n*p(n-2,:))/(n-1);
	t(n,:) = n*cos(ang).*p(n,:) - (n+1)*p(n-1,:);
end