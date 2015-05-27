function anet_out = season_avg(anet)
% anet = season_avg(anet)

V = datevec(anet.time);
sy = V(1,1);
ey = V(end,1);
sm = V(1,2);
em = V(end,2);

months = [sm:3:((em-sm+1)+12*(ey-sy))]';
mon_star = months-1;
mon_end = months+1;

mid_V = [sy+floor(months/12), mod(months,12),ones(size(months))];
start_V = [sy+floor(mon_star/12), mod(mon_star,12),ones(size(mon_star))];
end_V = [sy+floor(mon_end/12), mod(mon_end,12),ones(size(mon_end))];

mid_time = datenum(mid_V);
start_time = datenum(start_V);
end_time = datenum(end_V);
anet_out.time = mid_time;
fields = fieldnames(anet);
for f = 2:length(fields)
   if ~all(size(anet.(fields{f}))==size(V(:,1)))&&~all(size(anet.(fields{f}))==size(V(:,1)'))
      anet_out.(fields{f}) =anet.(fields{f});
   end
end

for v = 1:length(anet_out.time)
   for f = 2:length(fields)
      if length(anet.(fields{f}))==length(V(:,1))
         NaNs = isNaN(anet.(fields{f}));
         in = (anet.time>=start_time(v))&(anet.time<end_time(v));
         anet_out.(fields{f})(v) = mean(anet.(fields{f})(~NaNs&in));
      end
   end
end
%
%
% end
% end
% start_year = V(1,1);
% end_year = V(end,1);
% seasons = [1 4 7 10 13];
% [tmp,ind] =min(abs(V(1,2)-seasons));
% if ind==5
% start_month = mod(ind,4);
% start_year = start_year+1;
% end
% [tmp,ind] =min(abs(V(end,2)-seasons));
% if ind==5
% start_month = mod(ind,4);
% end_year = end_year+1;
% end
% done = false
%
% month = start_month;
% year = start_year;
% i = 1;
% while ~done
% end
% end
% anet_out.time(i) = datenum([year, month,1]);
% i = i+1;
% month = month+3;
% if month==13
%    year = year +1;
%    month = 1;
% end
%
%
%
% start_month = V(1,2); % [1 4 7 10 13]
% start_time = V(1,:);
% end_time = V(end,:);
% fields = fieldnames(anet);
% m_ind = 0;
% for yr = start_year:end_year;
%    y = (V(:,1) == yr);
%    for mon = [1:3:12]
%       m_ind = m_ind+1;
%       m = (V(:,2) == mon)|(V(:,2) == mon+1)|(V(:,2) == mon+2);
% anet_out.time(m_ind) = datenum([yr,mon+1,1]);
%       for f = 2:length(fields)
%          if length(anet.(fields{f}))==length(V(:,1))
%             NaNs = isNaN(anet.(fields{f}));
%             anet_out.(fields{f})(m_ind) = mean(anet.(fields{f})(~NaNs&m&y));
%          end
%       end
%    end
% end

return