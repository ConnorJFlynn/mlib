function [X_] = zpd2end_edgar(X,zpd);
% Usage: [X_] = zpd2end_edgar(X,zpd)
% Similar to fftshift except:
% 1. Supplied zpd is used as the pivot
% 2. Only a window of points symmetric about zpd is shifted
% 3. Point beyond symmetric window are zeroed, effectivly truncating igram


% N = size(X,2);
% w = min([zpd-1,N-(zpd-1)]);
% X_ = zeros(size(X));
% X_(:,[1:w]) = X(:,zpd+[0:(w-1)]);
% X_(:,[(1-w+N):N]) = X(:,[zpd+[(-1*w):-1]]);
% if w==0
%    X_(:,1) = X(:,zpd);
% end
% 

N = size(X,2);
w = min([zpd-1,N-(zpd-1)]);
X_ = zeros(size(X));
indx = 1;
for xi = zpd:(N-1)
   X_(:,indx) = X(:,xi);
   indx = indx + 1;
end
for xi = 1:(zpd-1)
   X_(:,indx) = X(:,xi);
   indx = indx +1;
end

X_(:,[1:w]) = X(:,zpd+[0:(w-1)]);
X_(:,[(1-w+N):N]) = X(:,[zpd+[(-1*w):-1]]);
if w==0
   X_(:,1) = X(:,zpd);
end

return
