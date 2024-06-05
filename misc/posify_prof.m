function posiprof = posify_prof(prof)
% posify_prof(prof)
% starting from the back end, accumulates values until the mean is > 0, 
% Once done, repeat in reverse until converged.
[II,JJ] = size(prof);
bads = isnan(prof);
prof(bads)=0;
if II==1
    flipped = true;
    prof = prof';
    [II,JJ] = size(prof);
else
    flipped = false;
end
% [sum(prof>0), sum(prof<=0)]
posiprof = posi_end(prof);
posiprof_ = flipud(posi_end(flipud(prof)));
posiprof = posi_end(mean([posiprof, posiprof_],2));

%    posiprof_ = flipud(posi_end(flipud(posiprof)));
% 
% 
% notsame = sum(posiprof~=posiprof_)
% while notsame>1
%    posiprof = mean([posiprof, posiprof_],2);
%    posiprof = posi_end(posiprof);
%    posiprof_ = flipud(posi_end(flipud(posiprof)));
%    notsame2 = sum(posiprof~=posiprof_);
%    if notsame==notsame2
%       notsame = 0;
%    else notsame = notsame2;
%    end
% end

posiprof(bads) = NaN;


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
      prof(ii-k:ii,jj) =mean(prof(ii-k:ii,jj));
      ii = ii-k-1;
   end
end
end