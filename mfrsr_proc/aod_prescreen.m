function [w, mad, abs_dev] = aod_prescreen(time, tau, window1, thresh);
%[w, mad, abs_dev] = aod_prescreen(time, tau, window1, thresh);
% Requires time and time-series of optical depth values
% This is a pre-screen intended to remove egregious outliers using a MADS filter
% prior to using the Alexandrov filter 
%aero_2, true for aero_1 and for times passing a MAD test.
% time is in units of day, so Matlab serial dates work as do jd.
% If specified, window in minutes

if ~exist('window1','var')
    window1 = 5;
end
if ~exist('thresh','var')
    thresh = 6;
end

tau_bar = zeros(size(tau));
mad = tau_bar;
abs_dev = tau_bar;
w = false(size(tau));
pos_tau = tau>0;
if length(tau(pos_tau))>0
    for t = fliplr(find(pos_tau))
        bar = find((abs(time(t)-time)<=(window1/(24*60)))&pos_tau);
        if length(bar)>1
            %gbar(t) = exp(mean(log(y(bar))));
%             tau_bar = mean(tau(bar));
            tau_bar = exp(mean(log(tau(bar))));
            ad = abs(tau(bar)-tau_bar);
             mad(t) = mean(ad);
%            mad(t) = exp(mean(log(ad)));
            abs_dev(t) = abs(tau(t)-tau_bar);
            w(t) = logical(abs_dev(t)<(thresh*mad(t)));
        end
%         if mod(t,1000)==0
%             disp(num2str(t))
%         end
    end
end
