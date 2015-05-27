function c = rob_window(x,y, span)
% IN PROGRESS!! 
%c = rob_window(x,y, span)
% A robust sliding window average
% Returns:
% c smoothed data, rw robust weights, mad mean absolute
% deviation throughout span, r residuals y-c
% Accepts:
% x: independent coordinate
% y: dependent coordinat (to be smoothed) 
% span: number of points to use in span (or % if span < 1)
% robust: boolean flag indicating whether outliers are discarded (0 = no , 1 = yes)
% iter: number of iterations for robust smoothing
% thresh: threshold applied to robust weights.  DEFAULT=1, higher discards more
% robust weights are calculated as robust_weight = (1 - r_by_mad .^2) with r_by_mad = r./(6*mad);
% 
ynan = isnan(y);
span = floor(span);
n = length(y);
span = min(span,n);
width = span-1+mod(span,2); % force it to be odd
xreps = any(diff(x)==0);
if width==1 & ~xreps & ~any(ynan), c = y; return; end
if ~xreps & ~any(ynan)
   % simplest method for most common case
   c = filter(ones(width,1)/width,1,y);
   cbegin = cumsum(y(1:width-2)); 
   cbegin = cbegin(1:2:end)./(1:2:(width-2))';
   cend = cumsum(y(n:-1:n-width+3)); 
   cend = cend(end:-2:1)./(width-2:-2:1)';
   c = [cbegin;c(width:end);cend];
elseif ~xreps
   % with no x repeats, can take ratio of two smoothed sequences
   c = repmat(NaN,n,1);
   yy = y;
   yy(ynan) = 0;
   nn = double(~ynan);
   ynum = moving(x,yy,span);
   yden = moving(x,nn,span);
   c = ynum ./ yden;
else
   % with some x repeats, loop
   notnan = ~ynan;
   yy = y;
   yy(ynan) = 0;
   c = zeros(n,1);
   for i=1:n
     if i>1 & x(i)==x(i-1)
        c(i) = c(i-1);
        continue;
     end
     R = i;                                 % find rightmost value with same x
     while(R<n & x(R+1)==x(R))
        R = R+1;
     end
     hf = ceil(max(0,(span - (R-i+1))/2));  % need this many more on each side
     hf = min(min(hf,(i-1)), (n-R));
     L = i-hf;                              % find leftmost point needed
     while(L>1 & x(L)==x(L-1))
        L = L-1;
     end
     R = R+hf;                              % find rightmost point needed
     while(R<n & x(R)==x(R+1))
        R = R+1;
     end
     c(i) = sum(yy(L:R)) / sum(notnan(L:R));
   end
end

            r1 = abs(r1-median(r1));
            mad(i) = median(r1);
            r = abs(y-c);
        rw = r./(6*mad);
        id = (rw<=thresh);
        rw = 1 - rw.*rw;
        rw(~id) = 0;  
