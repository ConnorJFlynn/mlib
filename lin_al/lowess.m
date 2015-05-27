function new_y = lowess(X,Y,pct);
% new_y = lowess(X,Y,pct);
% Local linear regression smoothing.
% Data must be sorted in X
% Date must be column vectors Mx1
% If pct is not specified, 0.05 = 5% is assumed
% If a pct > 1 is supplied, it is taken as an explicit span.

[row,col] = size(X);
if row==1 
    X = X';
end

[row,col] = size(Y);
if row==1 
    Y = Y';
end

if nargin < 3
    pct = .05;
end;
if (pct <=0)
    pct = .05;
end
    

if (any(diff(X)<0)&any(diff(X)>0))
    disp('X coordinate must be monotonic.');
    return
end;

if (pct > 1)
    span = pct;
else 
    span = floor(length(X)*pct);
end
span = max(ceil(span/2),2);
for i = length(X):-1:1
    bottom = max([1, i-span]);
    top = min([length(X), i+span]);
    dx = abs(X(top) - X(bottom));
    w = ones(size(X(bottom:top)));
    for j = bottom:top
        w(j-bottom+1) = (1- (abs(X(j)-X(i))/dx)^3)^3;
    end;
    [coefs] = lls(X(bottom:top)-mean(X(bottom:top)),Y(bottom:top),w);
    new_y(i) = coefs(1) + coefs(2)*X(i);
end