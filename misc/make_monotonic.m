function t_in = make_monotonic(t_in)
% Forces a supplied vector to be monotonic by interpolating across strictly
% increasing intervals
ts = length(t_in);
i = 1;
while i < ts
if t_in(i+1)>t_in(i)
    i = i + 1;
else
   before = t_in(i);
   k = 1;
     while ((i+k) < ts) && (t_in(i+k)<= before)
        t_in(i+k) = NaN;
        k = k + 1;
     end
     i = i+k;
end
end
bad = isNaN(t_in);
if ~isempty(bad)
   t_in(bad) = interp1(find(~bad),t_in(~bad),find(bad),'linear','extrap');
end

return










return