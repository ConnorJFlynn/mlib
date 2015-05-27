function [Nmax]=mie_test(x);

% MIE_TEST       N calculation for summation in mie.m 
%
% Created       24.04.97 by Th. Ingold, IAP
% Modified      26.01.98 by B Schmid NASA/Ames (translate comments into English)
%
% Input:  x      - mie parameter x=2*pi*r/l (matrix)
% Output: Nmax   - maximum of summation parameters related to x
%                  W.J. Wiscombe, Improved Mie scattering algorithms,
%                  Applied Optics, Vol. 19, 1505-1509, 1980.


N=ones(size(x)).*NaN;

% 0.02<=x<=8
i1=find(x>=0.02 & x<=8);
N(i1)=x(i1)+4*x(i1).^(1/3)+1;

% 8<x<4200
i2=find(x>8 & x<4200);
N(i2)=x(i2)+4.05*x(i2).^(1/3)+2;

% 4200<=x<=20000
i3=find(x>=4200 & x<=20000);
N(i3)=x(i3)+4*x(i3).^(1/3)+2;

if all(isnan(N))
	disp('Conditions (partially) not fulfilled !')
	Nmax=NaN;
else
   Nmax=ceil(max(max(N)));
   disp(sprintf('Maximum N: %5i',Nmax))
   N=ceil(N);
end
