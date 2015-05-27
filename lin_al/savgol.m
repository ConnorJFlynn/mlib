function cn = savgol(left, right, order, prime);

for i = -left:right
    row = i+left+1;
    for j = 0:order
        col = j + 1;
        A(row,col) = i^j;
    end;
end

sol = (A' * A)\eye(size(A'*A));

for n = -left:right
    ndx = n + left + 1;
    c(ndx) = 0;    
    for m = 0:order
        c(ndx) = sol(1,m+1)*(n^m);
    end
end;