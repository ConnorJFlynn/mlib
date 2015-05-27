function [aero_2, aero_1, eps, mad, abs_dev] = alex_screen(time, tau, window1, window2, aot_base);
%[aero_2, aero_1, eps, max_tau, min_tau] = alex_screen(time, tau, window,window2,aot_base);
% Requires time and time-series of optical depth values
% Optional renormalization aot, time window1 and time window2, and  value), to calculate the homogeneity parameter epsilon
%aero_1, true (1) eps< eps_thresh
%aero_2, true for aero_1 and for times passing a MAD test.
% time is in units of day, so Matlab serial dates work as do jd.
% If specified, window in minutes

if ~exist('aot_base','var')
    aot_base = .2;
end
if ~exist('window1','var')
    window1 = 5;
end
if ~exist('window2','var')
    window2 = 2*window1;
end
tau_min_thresh = 1.1;
tau_max_thresh = 1.1;
eps_thresh = 1e-4;
%Compute tau prime, a renormalized tau
tau_bar = zeros(size(tau));
mad = tau_bar;
abs_dev = tau_bar;
tau_prime = tau_bar;
eps = ones(size(tau));
aero_1 = (eps<eps_thresh);
aero_2 = (eps<eps_thresh);
pos_tau = find((tau>0)&(tau<2));
close_by = tau_bar;
if length(pos_tau)>0
    for t = fliplr(pos_tau)
        bar = find(abs(time(t)-time(pos_tau))<=(window1/(24*60))); %look for data within 5 minute span
        if length(bar)>5
            tau_bar(t) = mean(tau(pos_tau(bar)));
            tau_prime(t) = tau(t)- tau_bar(t)+aot_base;
        end
    end
% disp('Done with first for')
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
% disp('Done with second for')
    aero_1 = (eps<eps_thresh); % Using empirical threshold of eps_thresh to flag cloud.
    aero_2 = aero_1;
    if any(aero_1)
        for tt = length(pos_tau):-1:1
            t = pos_tau(tt);
            bar = find((abs(time(t)-time)<=(window2/(24*60)))&aero_1);
            if length(bar)>1
                %gbar(t) = exp(mean(log(y(bar))));
                tau_bar = mean(tau(bar));
                tau_bar = exp(mean(log(tau(bar))));
                ad = abs(tau(bar)-tau_bar);
                mad(t) = mean(ad);
                mad(t) = exp(mean(log(ad)));
                abs_dev(t) = abs(tau(t)-tau_bar);
                if (abs_dev(t)<(6*mad(t)))|aero_1(t)
                    aero_2(t) = 1;
                end
            end
        end
    end
end
