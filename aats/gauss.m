%gauss(x,x0,sigma)
function y=gauss(x,x0,sigma)

y=1/sqrt(2*pi)/sigma*exp(-((x-x0).^2/2/sigma^2));

