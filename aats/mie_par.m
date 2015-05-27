function x=mie_par(r,lambda)
% MIE_PAR     calculates Mie parameter 
%
% Created 23.04.97 by Th. Ingold, IAP
% Last Modified 23.04.97 by Th. Ingold, IAP
%
% Input: r      - radius vector
%        lambda - wavelength vector
%
% Output: Mie parameter matrix
%          hor: lambda
%          ver: radius
r=r(:);
lambda=lambda(:);
invers=(1./lambda)';
x=2*pi*vek_mult(r,invers);


