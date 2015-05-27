function [aero_2] =post_screen_(time, tau, aero_1,window2,mad_thresh)
%[aero_2] =post_screen_(time, tau, aero_1,window2,mad_thresh);
% Requires time, time-series of optical depth values, and aero_1.
% time is in units of day, so Matlab serial dates work as do jd.
% If specified, window2 is in minutes

% I may be able to speed this up by chunking the data by day
if ~exist('window2','var')
    window2 = 10;
end
if ~exist('mad_thresh','var');
   mad_thresh = 6;
end
aero_2 = aero_1;
%Initialize tau prime, a renormalized tau
tau_bar = zeros(size(tau));
mad = tau_bar;
abs_dev = tau_bar;

for d = floor(time(end)):-1:floor(time(1))
   disp(['Day ',num2str(d)])
   day = (time>=d)&(time<(d+1))&(tau>0)&isfinite(tau);
   if sum(day)>0
      pos_tau = find(day&isfinite(tau)&(tau>0)&~aero_1);
      if (length(pos_tau)>0)
         for tt = length(pos_tau):-1:1
%             ss = floor(tt./window2);
%             if mod(ss,500)==0
%                disp(num2str(ss))
%             end
            t = pos_tau(tt);
            bar = day&aero_1&(abs(time(t)-time)<=(window2/(24*60)));
%             bar = find((abs(time(t)-time)<=(window2/(24*60)))&aero_1);
            if sum(bar)>1
               %gbar(t) = exp(mean(log(y(bar))));
               %                 tau_bar = mean(tau(bar));
               tau_bar = exp(mean(log(tau(bar)))); %gmean
               ad = abs(tau(bar)-tau_bar);
               %                 mad(t) = mean(ad);
               mad(t) = exp(mean(log(ad)));
               abs_dev(t) = abs(tau(t)-tau_bar);
               %                 aero_2(t) = (abs_dev(t)<(mad_thresh*mad(t)))||aero_1(t);% I think the 'or' is never true given pos_tau includes ~aero_1
               aero_2(t) = (abs_dev(t)<(mad_thresh*mad(t)))||(tau(t)<tau_bar);% I think the 'or' is never true given pos_tau includes ~aero_1
               %                 if (abs_dev(t)<(6*mad(t)))||aero_1(t)
               %                     aero_2(t) = 1;
               %                 end
            end
         end
         %     end
      end
   end
end