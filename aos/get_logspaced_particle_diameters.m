function [LO_DP HI_DP MID_DP ] = get_log_spaced_particle_diameters(RESOLUTION,LIMITS)

if ~exist('RESOLUTION','var')
    RESOLUTION = 64;
end

raw_limits = [1 1000];
decades = log10(max(raw_limits)./min(raw_limits));

bins = RESOLUTION*decades

bin_lo = logspace(log10(raw_limits(1)),log10(raw_limits(2)),bins+1);
bin_hi = bin_lo(2:end);
bin_lo = bin_lo(1:end-1);

bin_spc = mean(bin_hi./bin_lo);

bin_mid = sqrt(bin_hi.*bin_lo);
bin_mid_rnd = round(bin_mid.*100)./100;



if ~exist('LIMITS','var')
    LIMITS = raw_limits
end

gi = find(and(bin_mid_rnd >= LIMITS(1),bin_mid_rnd <= LIMITS(2)));

bin_mid = bin_mid(gi);
bin_lo = bin_lo(gi);
bin_hi = bin_hi(gi);
bin_mid_rnd = bin_mid_rnd(gi);


MID_DP = bin_mid_rnd';
LO_DP = bin_lo';
HI_DP = bin_hi';


return