function new_y = local_val(X_in,Y_in,new_X,pct);
% new_y = local_val(X_in,Y_in,new_X,pct);
% Local linear regression smoothing.
% If pct is not specified, 0.05 = 5% is assumed
% If pct is specified greater than 1, it is assumed to be an explicit span
% Data must be sorted in X

[row,col] = size(X_in);
if row==1 
    X_in = X_in';
end

[row,col] = size(new_X);
if row==1 
    new_X = new_X';
end

[row,col] = size(Y_in);
if row==1 
    Y_in = Y_in';
end
 
if nargin < 3
    new_X = X_in;
end
if nargin < 4
    pct = .05;
end;
if (pct <=0)
    pct = .05;
end;

if (any(diff(X_in)<0)&any(diff(X_in)>0))
    disp('X coordinate must be monotonic.');
    return
end;

for index = length(new_X):-1:1
    
    [X, old_spot] = sort([new_X(index) X_in']');
    tempY = [0 Y_in']';
    [Y] = tempY(old_spot);
%     new_y = zeros(size(new_X));
    if pct <= 1
        span = floor(length(X)*pct);
    else
        span = pct;
    end
    i = find(old_spot==1);
    bottom = max([1, i-span]);
    top = min([length(X), i+span]);
    dx = abs(X(top) - X(bottom));
    w = ones(size(X(bottom:top)));
    for j = bottom:top
        if i==j
            w(j-bottom+1) = 0;
        else 
            w(j-bottom+1) = (1- (abs(X(j)-X(i))/dx)^3)^3;
        end
    end;
    [coefs] = lls(X(bottom:top),Y(bottom:top),w);
    new_y(index) = coefs(1) + coefs(2)*X(i);
end