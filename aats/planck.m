function y=planck(lambda,T)
% lambda has to be in micro meters, T in Kelvin
% No idea of the returned units.  Looks quite small.
c1=3.741884e4
c2=1.438769*1e4
x=c2./lambda./T;

y=c1./lambda.^5./(exp(x)-1);

return

