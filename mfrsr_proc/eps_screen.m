function [aero, eps] = eps_screen(time, tau, window, eps_thresh, aot_base)
%function [aero, eps] = eps_screen(time, tau, window, eps_thresh, aot_base)
% Required: time and time-series of optical depth values
% Optional: aot_base, tau_min, tau_max, eps_thresh
% time is in units of day, so Matlab serial dates work as do jd.
% If specified, window in minutes

if ~exist('aot_base','var')
    aot_base = .2;
end
if ~exist('window','var')
    window = 5;
end
if ~exist('eps_thresh','var')
    eps_thresh = 1e-5;
end
%Compute tau prime, a renormalized tau
tau_bar = zeros(size(tau));
tau_prime = tau_bar;
eps = ones(size(tau));
aero = (eps<eps_thresh);
%moved pos_tau specification way upstream.
pos_tau = find(tau);
if length(pos_tau)>0
    for t = fliplr(pos_tau)
%         bar = find(abs(time(t)-time(pos_tau))<=(window/(24*60))); %look for data within 5 minute span
        bar = (abs(time(t)-time(pos_tau))<=(window/(24*60)));
        if sum(bar)>5 % used to be if length(bar)
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
%         bar = find(abs(time(t)-time(pos_tau_prime))<=(window/(24*60)));
        bar = (abs(time(t)-time(pos_tau_prime))<=(window/(24*60)));

%         if length(bar)>5
        if sum(bar)>5

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
    aero = (eps<eps_thresh); % Using empirical threshold of eps_thresh to flag cloud.
    aero = aero&(tau>0);
end
