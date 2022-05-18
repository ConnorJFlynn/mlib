function yp = lorentp(X,params, P2, P3, C);
if length(params)==1
    P1 = params;
else
    P1 = params(1);
    P2 = params(2);
    P3 = params(3);
    C = params(4);
end
yp = P1./((X-P2).^2 + P3) + C;
end