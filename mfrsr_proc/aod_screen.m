function [aero, eps, aero_eps, mad, abs_dev] = aod_screen(time, tau,tau_min, tau_max,pre_window, mad_thresh, eps_thresh,eps_window,  post_window, aot_base)
%[aero, eps, aero_eps, mad, abs_dev] = aod_screen(time, tau,tau_min,tau_max,pre_window, mad_thresh, eps_thresh, eps_window, post_window, aot_base)

if nargin <2
   eval('help aod_screen')
   return
end
if ~exist('tau_min','var')||isempty(tau_min)
    tau_min = 0;
end
if ~exist('tau_max','var')||isempty(tau_max)
    tau_max = 2;
end
if ~exist('pre_window','var')||isempty(pre_window)
    pre_window = 5;
end
if ~exist('mad_thresh','var')||isempty(mad_thresh)
    mad_thresh = 6;
end

if ~exist('eps_window','var')||isempty(eps_window)
    eps_window = pre_window;
end
% Unless specificed, AOT base is now derived from data points 
% passing the first pre-screen.  Looks pretty good.
% if ~exist('aot_base','var')
%     aot_base = .2;
% end
if ~exist('eps_thresh','var')||isempty(eps_thresh)
    eps_thresh = 1e-4;
end
if ~exist('post_window','var')||isempty(post_window)
    post_window = 2*eps_window;
end

aero = logical(zeros(size(time)));
aero_eps = logical(zeros(size(time)));
eps = (ones(size(time)));
mad = zeros(size(time));
abs_dev = zeros(size(time));
if ~isempty(time)
%     figure;
   for d = floor(time(end)):-1:floor(time(1))
      disp(['Processing day ',num2str(d-floor(time(1)))]);
      day = (time>=d)&(time<(d+1))&(tau>tau_min)&(tau<tau_max);
      if sum(day)>0
         [aero(day), mad(day), abs_dev(day)] = aod_prescreen(time(day), tau(day), pre_window, mad_thresh);
         if sum(aero&day)
            %            if ~exist('aot_base','var')
            %     aot_base = .2;
            %            end
            if ~exist('aot_base','var')
               %                aot_base2 = mean(tau(aero&day));
               aot_base2 = hmean(tau(aero&day));
            else
               aot_base2 = aot_base;
            end
            %            [aero_eps(aero&day), eps(aero&day)] = eps_screen(time(aero&day), tau(aero&day), eps_window, 5e-4, aot_base2);
            %            if ~exist('aot_base','var')
            %                aot_base2 = mean(tau(aero_eps&day));
            %            else
            %                aot_base2 = aot_base;
            %            end
            [aero_eps(aero&day), eps(aero&day)] = eps_screen(time(aero&day), tau(aero&day), eps_window, eps_thresh, aot_base2);
            % [aero(aero&day)] = aero_eps(aero&day); %This statement could be used in
            % place of the one below to remove the post-screen
            [aero(aero&day)] = post_screen(time(aero&day), tau(aero&day), aero_eps(aero&day), post_window);
         end
      end
   end
end
eps(~isfinite(eps)) = NaN; 
% sb(1) = subplot(2,1,1); plot(serial2Hh(time(aero)), tau(aero), 'yo',serial2Hh(time(aero_eps)), tau(aero_eps), 'go', serial2Hh(time(~aero&tau>0)), tau(~aero&tau>0),'rx');
% legend('suspect','good','bad');
% title('optical depth');
% ylabel('tau')
% sb(2) = subplot(2,1,2); semilogy(serial2Hh(time(aero)), eps(aero), 'y.', serial2Hh(time(aero_eps)), eps(aero_eps), 'g.',serial2Hh(time(~aero&tau>0)), eps(~aero&tau>0),'r.'); linkaxes(sb,'x')
% title('variability parameter')
% ylabel('eps');
% legend('second pass','first pass','bad')
return