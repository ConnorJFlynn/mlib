function posiprof = semify_prof(prof)
% semify_prof(prof)
% starting from the back end, accumulates values until the mean is >= 0
[II,JJ] = size(prof);

if II==1
    flipped = true;
    prof = prof';
    [II,JJ] = size(prof);
else
    flipped = false;
end
for jj = JJ:-1:1

    ii = II;
    while ii>0
    k = 0;
    while (ii-k)>1 && sum(prof(ii-k:ii,jj))<0 
        k = k+1;
    end
    posiprof(ii-k:ii,jj) = mean(prof(ii-k:ii,jj));
    ii = ii-k-1;
    end

end

if flipped
    posiprof = posiprof';
end


end