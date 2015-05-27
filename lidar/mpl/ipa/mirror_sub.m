function mpl_out = mirror_sub(mpl_in, these_times, ophir, mirror, mpl_out);
%mpl_sub = mirror_sub(mpl_in, mpl_times,these_times, ophir, mirror, mpl_out);
% MPL_SUB is a subset of MPL_IN with only those times bracketed by mirror
% times.  Also, MPL_SUB is populated with energy monitor values from OPHIR
% and transceiver_zenith_angle from MIRROR.
mpl_times = these_times.mpl;

mpl_sub.rawcts = mpl_in.rawcts(:,mpl_times);
mpl_sub.noise_MHz = mpl_in.noise_MHz(:,mpl_times);

%mpl_sub.prof = mpl_in.prof(:,mpl_times);
mpl_sub.time = mpl_in.time(mpl_times);
mpl_sub.statics = mpl_in.statics;
mpl_sub.range = mpl_in.range;
mpl_sub.r = mpl_in.r;
%    mpl_sub.hk.cbh = mpl_in.hk.cbh(mpl_times);
mpl_sub.hk.instrument_temp = mpl_in.hk.instrument_temp(mpl_times);
mpl_sub.hk.filter_temp = mpl_in.hk.filter_temp(mpl_times);
mpl_sub.hk.laser_temp = mpl_in.hk.laser_temp(mpl_times);
mpl_sub.hk.detector_temp = mpl_in.hk.detector_temp(mpl_times);
mpl_sub.hk.bg = mpl_in.hk.bg(mpl_times);
if isfield(mpl_in.hk,'pulse_rep')
    mpl_sub.hk.pulse_rep = mpl_in.hk.pulse_rep(mpl_times);
else
    mpl_sub.hk.pulse_rep = ones(size(mpl_times))*mpl_in.statics.pulse_rep;
end
if isfield(mpl_in.hk,'shots_summed')
    mpl_sub.hk.shots_summed = mpl_in.hk.shots_summed(mpl_times);
    %    else
    %        mpl_sub.hk.shots_summed = ones(size(mpl_times))*mpl_in.statics.shots_summed;
end
if isfield(mpl_in,'pol_mode')
    mpl_sub.pol_mode.odd_even = mpl_in.pol_mode.odd_even(mpl_times);
    mpl_sub.pol_mode.odd_even_span = mpl_in.pol_mode.odd_even_span(mpl_times);
    mpl_sub.pol_mode.gt_mean_span = mpl_in.pol_mode.gt_mean_span(mpl_times);
end
for ps = length(mpl_times):-1:1
    lte = max(find(ophir.time(these_times.ophir)<=mpl_in.time(mpl_times(ps))));
    gte = min(find(ophir.time(these_times.ophir)>=mpl_in.time(mpl_times(ps))));
    if isempty(lte)
        lte = 1;
    end
    if isempty(gte)
        gte = length(these_times.ophir);
    end
    if gte == 0
        mpl_sub.hk.energy_monitor(ps) = [NaN];
    else
        mpl_sub.hk.energy_monitor(ps) = [mean(ophir.power(these_times.ophir(lte:gte)))];
    end
end
mpl_sub.hk.zenith_angle(1:length(mpl_times)) = mirror.angle(these_times.mirror);
if nargin<5
    mpl_out = mpl_sub;
else
    mpl_out.rawcts = [mpl_out.rawcts, mpl_sub.rawcts];
    mpl_out.noise_MHz = [mpl_out.noise_MHz, mpl_sub.noise_MHz];

    %    mpl_out.prof = [mpl_out.prof, mpl_in.prof(:,mpl_times)];
    mpl_out.time = [mpl_out.time , mpl_sub.time];
    %    mpl_out.hk.cbh = [mpl_out.hk.cbh mpl_in.hk.cbh(mpl_times)];
    mpl_out.hk.instrument_temp = [mpl_out.hk.instrument_temp, mpl_sub.hk.instrument_temp];
    mpl_out.hk.filter_temp = [mpl_out.hk.filter_temp, mpl_sub.hk.filter_temp];
    mpl_out.hk.laser_temp = [mpl_out.hk.laser_temp, mpl_sub.hk.laser_temp];
    mpl_out.hk.detector_temp = [mpl_out.hk.detector_temp, mpl_sub.hk.detector_temp];
    mpl_out.hk.bg = [mpl_out.hk.bg, mpl_sub.hk.bg];
    mpl_out.hk.pulse_rep = [mpl_out.hk.pulse_rep, mpl_sub.hk.pulse_rep];
    mpl_out.hk.shots_summed = [mpl_out.hk.shots_summed mpl_sub.hk.shots_summed];
if isfield(mpl_in,'pol_mode')
    mpl_out.pol_mode.odd_even =[mpl_out.pol_mode.odd_even mpl_sub.pol_mode.odd_even];
    mpl_out.pol_mode.odd_even_span = [mpl_out.pol_mode.odd_even_span mpl_sub.pol_mode.odd_even_span];
    mpl_out.pol_mode.gt_mean_span = [mpl_out.pol_mode.gt_mean_span mpl_sub.pol_mode.gt_mean_span];
end
    mpl_out.hk.energy_monitor = [mpl_out.hk.energy_monitor, mpl_sub.hk.energy_monitor];
    mpl_out.hk.zenith_angle = [mpl_out.hk.zenith_angle, mpl_sub.hk.zenith_angle];
end

