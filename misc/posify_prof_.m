function posiprof = posify_prof_(prof)
% posify_prof(prof)
% starting from the end, accumulates values until the mean is > 0
[II,JJ] = size(prof);

if II==1
    flipped = true;
    prof = prof';
    [II,JJ] = size(prof);
else
    flipped = false;
end

posiprof = posi_end(prof);
while any(posiprof<0) && any(posiprof>0)
   profposi = flipud(posi_end(flipud(posiprof)));
   posiprof = mean([posiprof,profposi],2);
end
if flipped
    posiprof = posiprof';
end


end

function prof = posi_end(prof)
[II,JJ] = size(prof);
for jj = JJ:-1:1
   ii = II;
   while ii>0
      k = 0;
      while (ii-k)>1 && sum(prof(ii-k:ii,jj))<=0
         k = k+1;
      end
      prof(ii-k:ii,jj) = real(exp(mean(log(prof(ii-k:ii,jj)))));
      ii = ii-k-1;
   end
end
prof(isnan(prof)) = 0;
end
