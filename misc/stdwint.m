function out = stdwint(t,in,HW)
% out = stdwint(t,in,HW)
% returns the minimum stddev of points within three temporal windows: 
% [t]-2*HW,t],[t-HW:t+HW], [t:t+2*HW], HW in seconds

% convert t to seconds.
% compute diff of t and round to nearest second.
% Interpolate to this grid with nearest neighbor

t = (t-min(t)) * 24*60*60;
delta_t = unique(round(diffN(t,2)));
delta_t = delta_t(delta_t>0); 
delta = delta_t(1);
t_out = floor(t(1)):delta_t:ceil(t(end));
% t_ii = interp1(t_out,[1:length(t_out)],t,'nearest','extrap');
t_ii = interp1(t,[1:length(t)],t_out,'nearest','extrap');

% in_t = interp1(t, in, t_out,'nearest','extrap');

out = stdwin(in,ceil(HW/delta));
 
out = out(t_ii);


% 
% 
% HW = HW/(24*60*60);
% mid = zeros(size(in));
% left = mid; right = mid;
% len_in = length(in);
% for n = 1:(len_in)
%    L = t>=t(n) & t<= t(n)+2*HW;
%    M = t>=(t(n)-HW) & (t<= t(n)+HW);
%    R = t>=(t(n)-2*HW) & t<= t(n);
%    left(n) = std(in(L));
%    mid(n) = std(in(M));
%    right(n) = std(in(R));
% end
% 
% out = min([left; mid; right]);


return
   