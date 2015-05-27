function [aero_2, aero_1, eps, max_tau, min_tau] = alex_screen(time, tau, window1, window2, aot_base);
%[aero_2, aero_1, eps, max_tau, min_tau] = alex_screen(time, tau, window,window2,aot_base);
% Requires time and time-series of optical depth values 
% Optional renormalization aot, time window1 and time window2, and  value), to calculate the homogeneity parameter epsilon
%aero_1, true (1) eps< 1e-4
%aero_2, true for aero_1 and for times where tau is within window2 minutes 
% and within threshold limits of max_tau and min_tau.
% time is in units of day, so Matlab serial dates work as do jd.
% If specified, window in minutes

if ~exist('aot_base','var')
    aot_base = .2;
end
if ~exist('window1','var')
    window1 = 5;
end
if ~exist('window2','var')
    window2 = 30;
end
tau_min_thresh = 1.1;
tau_max_thresh = 1.1;
%Compute tau prime, a renormalized tau
tau_bar = zeros(size(tau));
min_tau = tau_bar;
max_tau = tau_bar;
tau_prime = tau_bar;
eps = ones(size(tau));
aero_1 = (eps<1e-4);
aero_2 = (eps<1e-4);
pos_tau = find((tau>0)&(tau<2));
close_by = tau_bar;
if length(pos_tau)>0
    for t = pos_tau(1):pos_tau(end)
        bar = find(abs(time(t)-time(pos_tau))<=(window1/(24*60))); %look for data within 5 minute span
        if length(bar)>5
            tau_bar(t) = mean(tau(pos_tau(bar)));
            tau_prime(t) = tau(t)- tau_bar(t)+aot_base;
        end
    end

    %Now compute tau_prime_bar, the average of tau_prime
    tau_prime_bar = ones(size(tau));
    bar_log_tau_prime = tau_prime_bar;

    pos_tau_prime = find(tau_prime>0);
    for tt = length(pos_tau_prime):-1:1
        t = pos_tau_prime(tt);
        bar = find(abs(time(t)-time(pos_tau_prime))<=(window1/(24*60)));
        if length(bar)>5
            tau_prime_bar(t) = mean(tau_prime(pos_tau_prime(bar)));
            % Tests alternate definitions of "mean", arithmetic, geometric, harmonic...
            %       abar(t)= tau_prime_bar(t);
            %       gbar(t) = exp(sum(log(tau_prime(pos_tau_prime(bar))))/length(bar));
            %       hbar(t) = length(bar)/sum(1./tau_prime(pos_tau_prime(bar)));
            bar_log_tau_prime(t) = mean(log(tau_prime(pos_tau_prime(bar))));
            %       elogbar(t) = exp(bar_log_tau_prime(t));
            %       logebar(t) = log(mean(exp(tau_prime(pos_tau_prime(bar)))));
            eps(t) = 1 - exp(bar_log_tau_prime(t))./tau_prime_bar(t);
        end
    end

    aero_1 = (eps<1e-4); % Using empirical threshold of 1e-4 to flag cloud.
    if any(aero_1)
        for t = pos_tau(1):pos_tau(end)
            close_by(t) = min(abs(time(t)-time(aero_1)))<(window2/(24*60)); % True if nearest aero_1 is within 1/2 hour
        end
        hard_aero = find(aero_1>0);
        for tt = length(hard_aero):-1:1
            t = hard_aero(tt);
            bar = find(abs(time(t)-time(hard_aero))<=(window1/(24*60)));
            if length(bar)>0
                min_tau(t) = min(tau(hard_aero(bar)))/tau_min_thresh;
                max_tau(t) = tau_max_thresh*max(tau(hard_aero(bar)));
            end
        end
        if length(hard_aero)>1
        min_tau = interp1(time(hard_aero), min_tau(hard_aero), time,'linear','extrap');
        max_tau = interp1(time(hard_aero), max_tau(hard_aero), time,'linear','extrap');        
        end
        aero_2 = (aero_1>0)|((tau>=min_tau)&(tau<=max_tau)&close_by);
    end

end





