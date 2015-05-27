function [c,rw,mad,r] = rob_lowess(x,y, span, method, robust,iter, thresh)
% [c,rw,mad,r] = rob_lowess(x,y, span, method, robust,iter, thresh)
% LOWESS  Smooth data using Lowess or Loess method.
% Returns:
% c smoothed data, rw robust weights, mad mean absolute
% deviation throughout span, r residuals y-c
% Accepts:
% x: independent coordinate
% y: dependent coordinat (to be smoothed) 
% span: number of points to use in span (or % if span < 1)
% method: 'lowess' (DEFAULT linear fit) or 'loess' (quadratic fit)
% robust: boolean flag indicating whether outliers are discarded (0 = no , 1 = yes)
% iter: number of iterations for robust smoothing
% thresh: threshold applied to robust weights.  DEFAULT=1, higher discards more
% robust weights are calculated as robust_weight = (1 - r_by_mad .^2) with r_by_mad = r./(6*mad);
% 

if ~exist('thresh','var')
    thresh = 1;
end
if ~exist('iter','var')
    iter = 5;
end
if ~exist('method','var')
    method = 'lowess';
end
if ~exist('span','var')
    span = .02;
end
if ~exist('robust','var')
    robust = 0;
end

n = length(y);
if ((span>0)&(span<1))
    span = n * span;
end
span = floor(span);
span = min(span,n);
if span <= 0
    error('Span must be an integer between 1 and length of x.');
    span = 1;
end
if span == 1, c = y; return; end

c = zeros(size(y));

% pre-allocate space for lower and upper indices for each fit
if robust
    lbound = zeros(n,1);
    rbound = zeros(n,1);
    dmaxv = zeros(n,1);
end


ws = warning('off');
warning('');

ynan = isnan(y);
seps = sqrt(eps);
for i=1:n
    if i>1 & x(i)==x(i-1)
        c(i) = c(i-1);
        if robust
            lbound(i) = lbound(i-1);
            rbound(i) = rbound(i-1);
            dmaxv(i) = dmaxv(i-1);
        end
        continue;
    end
    mx = x(i);       % center around current point to improve conditioning
    d = abs(x-mx);
    [dsort,idx] = sort(d);
    idx = idx(dsort<=dsort(span) & ~ynan(idx));
    if isempty(idx)
        c(i) = NaN;
        continue
    end
    x1 = x(idx)-mx;
    y1 = y(idx);
    dsort = d(idx);
    dmax = max(dsort);
    if dmax==0, dmax = 1; end
    if robust
        lbound(i) = min(idx);
        rbound(i) = max(idx);
        dmaxv(i) = dmax;
    end
    
    weight = (1 - (dsort/dmax).^3).^1.5; % tri-cubic weight
    if all(weight<seps)
        weight(:) = 1;    % if all weights are 0, just skip weighting
    end
    
    v = [ones(size(x1)) x1];
    if isequal(method,'loess')
        v = [v x1.*x1];
    end
    
    v = weight(:,ones(1,size(v,2))).*v;
    y1 = weight.*y1;
    if size(v,1)==size(v,2)
        % Square v may give infs in the \ solution, so force least squares
        b = [v;zeros(1,size(v,2))]\[y1;0];
    else
        b = v\y1;
    end
    c(i) = b(1);
end

% now that we have a non-robust fit, we can compute the residual and do
% the robust fit if required
mad = zeros(size(x));
rw = ones(size(x));
if robust
    d = zeros(size(c));
    for k = 1:iter
        r = y-c;
        for i=1:n
            if i>1 & x(i)==x(i-1)
                c(i) = c(i-1);
                continue;
            end
            if isnan(c(i)), continue; end
            idx = lbound(i):rbound(i);
            idx = idx(~ynan(idx));
            x1 = x(idx);
            mx = x(i);
            x1 = x1-mx;
            dsort = abs(x1);
            y1 = y(idx);
            r1 = r(idx);
            
            weight = (1 - (dsort/dmaxv(i)).^3).^1.5; % tri-cubic weight
            if all(weight<seps)
                weight(:) = 1;    % if all weights 0, just skip weighting
            end
            
            v = [ones(size(x1)) x1];
            if isequal(method,'loess')
                v = [v x1.*x1];
            end
            r1 = abs(r1-median(r1));
            mad(i) = median(r1);
            if mad(i) > max(abs(y))*eps
                rweight = r1./(6*mad(i));
                id = (rweight<=thresh);
                rweight(~id) = 0;
                rweight(id) = (1-rweight(id).*rweight(id));
                weight = weight.*rweight;
            end
            v = weight(:,ones(1,size(v,2))).*v;
            y1 = weight.*y1;
            if size(v,1)==size(v,2)
                % Square v may give infs in the \ solution, so force least squares
                b = [v;zeros(1,size(v,2))]\[y1;0];
            else
                b = v\y1;
            end
            c(i) = b(1);
        end
        rr = d-c;
        
        r = abs(y-c);
        rw = r./(6*mad);
        id = (rw<=thresh);
        rw = 1 - rw.*rw;
        rw(~id) = 0;  
    end
end
    warning('');
    warning(ws);

