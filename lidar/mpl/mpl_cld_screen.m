function [eps, cld] = mpl_cld_screen(mpl);
%time, root_bg, base_bg);
%[eps, aero] = mpl_cld_screen(time, root_bg, base_bg);
% time is in units of day, so Matlab serial dates work as do jd.
time = mpl.time;
root_bg = mpl.hk.bg ./ sqrt(smooth(serial2Hh(mpl.time), mpl.hk.bg,.1,'lowess')');
base_bg = mean(root_bg(root_bg>.1));

%Compute root_bg prime, a renormalized root_bg
root_bg_bar = zeros(size(root_bg));
root_bg_prime = root_bg_bar;
pos_root_bg = find((root_bg>0)&(root_bg<2));
for t = pos_root_bg(1):pos_root_bg(end)
   bar = find(abs(time(t)-time(pos_root_bg))<=(5/(24*60)));
   if length(bar)>5
      root_bg_bar(t) = mean(root_bg(pos_root_bg(bar)));
      root_bg_prime(t) = root_bg(t)- root_bg_bar(t)+base_bg;
   end
end
%Now compute root_bg_prime_bar, the average of root_bg_prime
root_bg_prime_bar = ones(size(root_bg));
eps = ones(size(root_bg));
pos_root_bg_prime = find(root_bg_prime>0);
for t = pos_root_bg_prime
   bar = find(abs(time(t)-time(pos_root_bg_prime))<=(5/(24*60)));
   if length(bar)>5
      root_bg_prime_bar(t) = mean(root_bg_prime(pos_root_bg_prime(bar)));
      bar_log_root_bg_prime(t) = mean(log(root_bg_prime(pos_root_bg_prime(bar))));
      eps(t) = 1 - exp(bar_log_root_bg_prime(t))./root_bg_prime_bar(t);
   end
end

cld = (eps>1e-2);
