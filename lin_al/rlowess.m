function new_y = rlowess(X,Y,pct,wi);
% new_y = rlowess(X,Y,pct,wi);
% Robust local linear regression smoothing.
% If pct is not specified, 5% is assumed
% If incoming weights are not specified they are assumed 1
% Data must be sorted in X

if nargin < 4
    wi = ones(size(X));
end
if nargin < 3
    pct = .05;
end;
if (pct <=0)|(pct>=1)
    pct = .05;
end;

[row,col] = size(X);
if row==1 
    X = X';
end

[row,col] = size(Y);
if row==1 
    Y = Y';
end


if (any(diff(X)<0)&any(diff(X)>0))
    disp('X coordinate must be monotonic.');
    return
end;
figs = figure; 
%robust weights initially one
wr = ones(size(wi));
new_y = ones(size(Y));

for iteration = 1:5;
    W = wi .* wr;    
    span = floor(length(X)*pct);
    for i = 1:length(X)
        bottom = max([1, i-span]);
        top = min([length(X), i+span]);
        dx = abs(X(top) - X(bottom));
        w = ones(size(X(bottom:top)));
        for j = bottom:top
            w(j-bottom+1) = (1- (abs(X(j)-X(i))/dx)^3)^3;
        end;
        [coefs] = lls(X(bottom:top),Y(bottom:top),w.*W(bottom:top));
        new_y(i) = coefs(1) + coefs(2)*X(i);
    end
    good_W = find(W > 0);
    resids = Y - new_y;
    MAD = median(abs(resids(good_W)));
    wr = (resids./(6*MAD)).^2;
    outliers = find(wr>=1);
    figure(figs); plot(X,Y,'r.', X,new_y,'g', X(outliers), Y(outliers), '.c');
    pause(1);
    wr = (1-wr).^2;
    wr(outliers) = 0;
end;

return
