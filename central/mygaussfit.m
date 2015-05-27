function [sigma,mu,A,FWHM,peak]=mygaussfit(x,y,h)
% [sigma,mu,A]=mygaussfit(x,y)
% [sigma,mu,A]=mygaussfit(x,y,h)
% see gaussian, gaussian_fwhm, gaussian_sigma
%
% this function is doing fit to the function
% y=(A ./sigma.*sqrt(2*pi))* exp( -(x-mu)^2 / (2*sigma^2) )
% A is scaling factor relative to unit area gaussian
% Peak = (A ./sigma.*sqrt(2*pi))
% the fitting is been done by a polyfit
% the lan of the data.
%
% h is the threshold which is the fraction
% from the maximum y height that the data
% is been taken from.
% h should be a number between 0-1.
% if h have not been taken it is set to be 0.2
% as default.
%


%% threshold
if nargin==2, h=0.2; end

%% cutting
ymax=max(y);
xnew=x(y>=ymax.*h);
ynew=y(y>=ymax.*h);

%% fitting
ylog=log(ynew);
mu0 = mean(xnew);
[p]=polyfit(xnew-mu0,ylog,2);
A2=p(1);
A1=p(2);
A0=p(3);
sigma=sqrt(-1/(2*A2));
mu=A1*sigma^2;
A=sigma.*sqrt(2.*pi).*exp(A0+mu^2/(2*sigma^2));
mu = mu + mu0;
FWHM = (2.*sqrt(2.*log(2))).*sigma;
peak = (A ./(sigma.*sqrt(2*pi)));

%%
% figure; semilogy(x,y,'o',xnew,ynew,'.',x,exp(polyval(p,x-mu0)),'b-',x,A.*gaussian_sigma(x-mu0,mu, sigma),'r-')
%%
