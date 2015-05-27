 function [Q_ext,Q_scat,a,b]=mie(x,m,N)

% MIE 
% Created        22.04.97 by Thomas Ingold, IAP
% Correction     29.01.98 by Thomas Ingold, IAP 
%
% Calculates Mie extinction, Mie scattering (Mie parameter a_n, b_n)
% (F.T. Ulaby, R.K. Moore, A. K. Fung, Microwave remote sensing: active and passive, Vol. 1, pp. 290-298)
%
% Input Parameter:
%
% x - mie-parameter (x=2*pi*r/lambda ; r-radius, Lambda-wavelength) 
%     Matrix
% m - refractive index
% N - summation index
%     N=100; für Anwendung Sonnenphotometer genügend !
%
% Outputparamter
%
% Q_ext  - Mie-Extinction efficiency 
% Q_scat - Mie-Scattering efficiency
% a,b    - Mie-Scattering coefficients

[MM,NN]=size(x);
x=x(:);
w_1=cos(x)-i*sin(x);
w_0=sin(x)+i*cos(x);
A_0=cot(m*x);
% n=1
%
A(:,1)=-1./(m*x)+1./(1./(m*x)-A_0);
w(:,1)=1./x.*w_0-w_1;
a(:,1)=((A(:,1)/m+1./x).*real(w(:,1))-real(w_0))./(((A(:,1)/m)+1./x).*w(:,1)-w_0);
b(:,1)=((m*A(:,1)+1./x).*real(w(:,1))-real(w_0))./((m*A(:,1)+1./x).*w(:,1)-w_0);
% n=2
%
A(:,2)=-2./(m*x)+1./(2./(m*x)-A(:,1));
w(:,2)=(3./x).*w(:,1)-w_0;
a(:,2)=((A(:,2)/m+2./x).*real(w(:,2))-real(w(:,1)))./(((A(:,2)/m)+2./x).*w(:,2)-w(:,1));
b(:,2)=((m*A(:,2)+2./x).*real(w(:,2))-real(w(:,1)))./((m*A(:,2)+2./x).*w(:,2)-w(:,1));
for n=3:N
        w(:,n)=((2*n-1)./x).*w(:,n-1)-w(:,n-2);
        A(:,n)=-n./(m*x)+1./(n./(m*x)-A(:,n-1));
        a(:,n)=((A(:,n)/m+n./x).*real(w(:,n))-real(w(:,n-1)))./(((A(:,n)/m)+n./x).*w(:,n)-w(:,n-1));
        b(:,n)=((m*A(:,n)+n./x).*real(w(:,n))-real(w(:,n-1)))./((m*A(:,n)+n./x).*w(:,n)-w(:,n-1));
end

a(isnan(a))=0; % these two lines replace NaN caused by too many iteration by 0
b(isnan(b))=0;

% Matrix composition
n_vek=1:N;
for i=2:MM*NN
        n_vek(i,:)=n_vek(1,:);
end
Q_ext=2./x.^2.*sum((n_vek*2+1).*real(a+b),2);
Q_scat=2./x.^2.*sum((n_vek*2+1).*( abs(a).^2+abs(b).^2),2);
Q_ext=reshape(Q_ext,[MM NN]);
Q_scat=reshape(Q_scat,[MM NN]);


