function mpl = noise_calcs2(mpl);
% mpl = noise_calcs2(mpl);

disp('this function is NOT done yet!!')

[bins, times] = size(mpl.raw_cop_1);
avg_interval = min(diff(mpl.time))*24*60*60;
%mpl.hk.PRF = 2500*ones(size(mpl.time)); 
%mpl.hk.shotsSummed = mpl.hk.PRF * 5;
Hz_to_cts = (1e-3*mpl.statics.range_bin_time * (mpl.statics.laser_PRF .* mpl.statics.laser_shots_summed));
%Wrong?! Is it pulse_rep * averaging_int, or shots_summed, not both.

%First, convert rawcts in MHz to cts, then calc noise as sqrt, then convert to MHz
copol_noise = mpl.raw_cop_1 .* (ones(size(mpl.raw_cop_1)) * Hz_to_cts);
copol_noise = sqrt(noise);
copol_noise = copol_noise ./ (ones(size(mpl.raw_cop_1)) * Hz_to_cts);

crosspol_noise = mpl.raw_dep_1 .* (ones(size(mpl.raw_dep_1)) * Hz_to_cts);
crosspol_noise = sqrt(noise);
crosspol_noise = crosspol_noise ./ (ones(size(mpl.raw_dep_1)) * Hz_to_cts);

mpl.cop_snr = zeros(size(mpl.prof));
mpl.dep_snr = zeros(size(mpl.prof));

cop_bg_noise = sqrt(mpl.hk.cop_bg .* Hz_to_cts)./ Hz_to_cts;
cop_bg_noise = ones(size(mpl.range))*cop_bg_noise;
dep_bg_noise = sqrt(mpl.hk.dep_bg .* Hz_to_cts)./ Hz_to_cts;
dep_bg_noise = ones(size(mpl.range))*dep_bg_noise;


low_cts = (noise< bg_noise);
noise  = (noise .* ~low_cts) + (bg_noise.* low_cts);
sig = mpl.rawcts - ones(size(mpl.range))*mpl.hk.bg;
for t = times:-1:1
   pos = find((sig(:,t) > 0) & (noise(:,t) > 0));
   mpl.snr(pos,t) = sig(pos,t)./noise(pos,t);
end;

mpl.noise = noise; clear noise bg_noise