function mpl = noise_calcs(mpl);
% mpl = noise_calcs(mpl);

[bins, times] = size(mpl.prof);
avg_interval = min(diff(mpl.time))*24*60*60;
noise = mpl.rawcts .* ((0.2 * ones([bins,1]))* (mpl.hk.PRF * avg_interval));
noise = sqrt(noise); 
noise = noise ./ ((0.2 * ones([bins,1]))* (mpl.hk.PRF * avg_interval));

 mpl.snr = zeros(size(mpl.prof));
 
    mpl.prof = mpl.prof - ones(size(mpl.range))*mpl.hk.bg;
    bg_noise = sqrt(mpl.hk.bg .* ((0.2) * (mpl.hk.PRF * avg_interval)))./ ((0.2)* (mpl.hk.PRF * avg_interval));
    bg_noise = ones(size(mpl.range))*bg_noise;
    
    low_cts = (noise< bg_noise);
    noise  = (noise .* ~low_cts) + (bg_noise.* low_cts);
 for t = times:-1:1
    pos = find((mpl.prof(:,t) > 0) & (noise(:,t) > 0));
    mpl.snr(pos,t) = mpl.prof(pos,t)./noise(pos,t);
 end;
  
 mpl.noise = noise; clear noise bg_noise 