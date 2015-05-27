function anet = anet_avg(anet,V_);
% anet = anet_avg(anet,V_);
% V_ is a 6-element vector indicating which columns of time vector V to use in averaging


% [anet.time, ind] = sort([cart.time; CART.time]);
fields = fieldnames(anet);
% for f = 1:10
%    anet.(fields{f}) = cart.(fields{f});
% end
% for f = 11:length(fields)
%    tmp = [cart.(fields{f}); CART.(fields{f})];
%    anet.(fields{f}) = tmp(ind);
% end
%%
if ~any(V_>1)
   V_ = logical(V_);
   Vi = find(V_);
end
done = false;
V = datevec(anet.time);
next = length(anet.time);
while ~done
   mon = true(size(anet.time));
   for v = Vi
      mon = mon&(V(:,v) == V(next,v));
   end
%       mon = (V(:,1) == V(next,1));
   ind = find(mon); mon_end = ind(end); ind = ind(1);
   next = ind-1;
   for f = length(fields):-1:12
%       disp(f)
      NaNs = isNaN(anet.(fields{f}));
      %take mean of Non-NaNs and sum of Non-NaN Ns
      if ~isempty(findstr('N_',fields{f}))
         tmp = sum(anet.(fields{f})(mon&~NaNs));
      else
         tmp = mean(anet.(fields{f})(mon&~NaNs));
      end
      anet.(fields{f}) = [anet.(fields{f})(1:ind-1); tmp; anet.(fields{f})(mon_end+1:end)];
   end
   NaNs = isNaN(anet.time);
   tmp = mean(anet.time(mon&~NaNs));
   anet.time = [anet.time(1:ind-1); tmp; anet.time(mon_end+1:end)];
   V = datevec(anet.time);
   if (next==0)
      done = true;
   end
end
