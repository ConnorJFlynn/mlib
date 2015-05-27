% SphereSc	Stoke's vector of scattered light.
%		SphereSc(m,x,I,ang) returns the scattered Light for
%		a sphere, size x, refractive index relative to medium m
%		at angle ang.
%		Incident light has Stoke's Vector I.

% Written by and copyright
%		Dave Barnett
%		Optical Engineering Group
%		Dept. of Electrical and Electronic Engineering
%		Loughborough University
%		20th November 1996

%		Corrected 4th September 1997
%			i missing from calculation of S34

%		5th September 1997
%			calculation of E made more efficient.

function S = SphereSc(m, x, I, ang)

nc = ceil(x+4.05*(x^(1/3))+2);
n=(1:nc)';
E(n,1) = (2*n+1)./(n.*(n+1));
[p,t] = ALegendr(ang,nc);
[a,b] = ScatCoef(m,x,nc);
a = a.*E;
b = b.*E;
S1 = a'*p + b'*t;
S2 = a'*t + b'*p;
S11 = ((S2.*conj(S2))+(S1.*conj(S1)))/2;
S12 = ((S2.*conj(S2))-(S1.*conj(S1)))/2;
S33 = ((S1.*conj(S2))+(S2.*conj(S1)))/2;
S34 = i*((S1.*conj(S2))-(S2.*conj(S1)))/2;
S = [I(1)*S11 + I(2)*S12; I(1)*S12 + I(2)*S11; I(3)*S33 + I(4)*S34; -I(3)*S34 + I(4)*S33];