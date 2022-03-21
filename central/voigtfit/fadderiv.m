function [vf,dvdpar]= fadderiv(v,par0)
% [vf,dvdpar]= fadderiv(v,par0)
% input  --v: wavenumber
%        --par0: initial parameters. 4 by g matrix,first row is peak
%                position, second row is intensity,third row is Gaussain width, 
%                fourth row is Lorentzian width
% output --     vf:voigt line shape
%           dvdpar:voigtline shape derivatives w.r.t. line parameters,length(v) by 4*g matrix
%           the format is:  [dVdv1 dVds1 dVdag1 dVdal dVdv2 dVds2 dVdag2 dVda2 ...}              
%         

v0=par0(1,:);  % peak position,   [v1 v2 ...]
s=par0(2,:);   % intensity,       [s1 s2 ...]
ag=par0(3,:);  % Gaussian width,  [ag1 ag2 ...]
al=par0(4,:);  % Lorentzian width,[al1 al2 ...]
% vectorize parameters
aD=(ones(length(v),1)*ag);
aL=(ones(length(v),1)*al);
S=(ones(length(v),1)*s);

vv0=v*ones(1,length(v0))-ones(length(v),1)*v0;
x=vv0.*(sqrt(log(2)))./aD;
y=ones(length(v),1)*(al./ag)*(sqrt(log(2)));
z=x+1i*y;
w = fadf(z);       % uses The code written by Sanjar M. Abrarov and Brendan M. Quine, York
%                      % University, Canada, March 2015.
vf=real(w)*s';   
K=real(w);L=imag(w);

% derivatives
dvds=K;
c1=y.*y;
c2=x.*y;
dVdvj=2*(c2.*K-c1.*L)./aL;
dVdad=2*((x.*x-c1).*K-2*c2.*L+y./sqrt(pi))./aD;
dVdal=2*(c2.*L+c1.*K-y./sqrt(pi))./aL;


vjs=dVdvj.*S;
ags=dVdad.*S;
als=dVdal.*S;

der=[vjs ;dvds;ags ;als];
dvdpar=reshape(der,[length(v) numel(par0)]);

end

