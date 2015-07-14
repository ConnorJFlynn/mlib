function label = litekmeans(X, k)
%label = litekmeans(X, k)

% From wikipage describing the corresponding Matlab Central function
% https://statinfer.wordpress.com/2011/12/12/efficient-matlab-ii-kmeans-clustering-algorithm/
n = size(X,2);
last = 0;
label = ceil(k*rand(1,n));  % random initialization
while any(label ~= last)
    E = sparse(1:n,label,1,n,k,n);  % transform label into indicator matrix
    m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster
    last = label;
    [~,label] = max(bsxfun(@minus,m'*X,dot(m,m,1)'/2),[],1); % assign samples to the nearest centers
end

return

