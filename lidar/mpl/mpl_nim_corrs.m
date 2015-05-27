function mpl = mpl_nim_corrs;
%%

mpl = read_mpl;
%%
figure; imagegap(serial2doy(mpl.time), mpl.range(mpl.r.lte_10), real(log10(mpl.rawcts(mpl.r.lte_10,:)))); colorbar
% Determine afterpulse from beam blocked part.
%%
ap.tlim = xlim;
ap.tsub = (serial2doy(mpl.time)>ap.tlim(1))&(serial2doy(mpl.time)<ap.tlim(2));
ap.mean_cts = mean(mpl.rawcts(:,ap.tsub),2);
%%
ap.smooth_cts = ap.mean_cts;
%this is a good trick to handle the smoothing over range.
ap.smooth_cts(mpl.range>0) = gsmooth(log10(mpl.range(mpl.range>0)), ap.mean_cts(mpl.range>0),.1);
figure; semilogx(ap.mean_cts, mpl.range, 'b.', ap.smooth_cts,mpl.range,'r');
%%
mpl.prof = mpl.rawcts - ap.smooth_cts*ones(size(mpl.time));
mpl.hk.bg = mean(mpl.prof(mpl.r.bg,:));
mpl.prof = mpl.prof - ones(size(mpl.range))*mpl.hk.bg;
mpl.prof = mpl.prof .* (mpl.range .^2 * ones(size(mpl.time)));
%%
figure; imagegap(serial2doy(mpl.time), mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,:));colorbar; caxis([0,.5])
%%
figure; imagegap(serial2doy(mpl.time), mpl.range(mpl.r.lte_20), real(log10(mpl.prof(mpl.r.lte_20,:))));colorbar; 
%%
ray.tlim = xlim;
ray.tsub = (serial2doy(mpl.time)>ray.tlim(1))&(serial2doy(mpl.time)<ray.tlim(2));
ray.mean_prof = mean(mpl.prof(:,ray.tsub),2);
%%
r_cal = (mpl.range>=10)&((mpl.range<=15));
sonde_cal = (mpl.sonde.range>=10)&(mpl.sonde.range<=15);
A = mean(ray.mean_prof(r_cal));
B = mean(mpl.sonde.atten_ray(sonde_cal));

figure; semilogx((B./A).*ray.mean_prof(mpl.r.lte_30),mpl.range(mpl.r.lte_30), 'b.', mpl.sonde.atten_ray,mpl.sonde.range, 'r')
%%
figure; semilogx(ray.mean_prof(mpl.r.lte_15)./(mpl.range(mpl.r.lte_15).^2),mpl.range(mpl.r.lte_15), 'b.');
xlabel('log mean counts');
ylabel('range');
%%
r.ol = (mpl.range>.5)&(mpl.range<1.5);
clear_sky_raw = ray.mean_prof./(mpl.range.^2);
P = polyfit(mpl.range(r.ol), real(log10(clear_sky_raw(r.ol))),1);
P(1) = P(1)*.9; % adjust steepness to account for exponential aerosol profile instead of constant
Y = 0.7*10.^polyval(P,mpl.range(mpl.r.lte_5));
figure; semilogx(clear_sky_raw(mpl.r.lte_10),mpl.range(mpl.r.lte_10), 'b.', Y,mpl.range(mpl.r.lte_5),'r');
% axis(v)
xlabel('log mean counts');
ylabel('range');
%%
[tmp,join] = sort(abs(Y-clear_sky_raw(mpl.r.lte_5)));
clear_sky_synth = clear_sky_raw;
clear_sky_synth(mpl.r.lte_5(1:join)) = Y(1:join);
figure; semilogy(mpl.range(mpl.r.lte_10),clear_sky_raw(mpl.r.lte_10), 'b.',mpl.range(mpl.r.lte_5), clear_sky_synth(mpl.r.lte_5),'r');
axis(v)
ylabel('log mean counts');
xlabel('range');
clear_sky_synth_r2 = clear_sky_synth .* mpl.range.^2;
figure; semilogy(mpl.range(mpl.r.lte_10), clear_sky_synth_r2(mpl.r.lte_10),'.');
%%
r.ol_fit = (mpl.range>=3)&(mpl.range<=8);
PP = polyfit(mpl.range(r.ol_fit), real(log10(clear_sky_synth_r2(r.ol_fit))),1);
YY = 10.^(polyval(PP,mpl.range(mpl.r.lte_10)));
figure; semilogx( clear_sky_synth_r2(mpl.r.lte_10),mpl.range(mpl.r.lte_10),'.', YY,mpl.range(mpl.r.lte_10),'r');
corr.range = mpl.range;
corr.ol = ones(size(mpl.range));
corr.ol(mpl.r.lte_5) = (10.^(polyval(PP,mpl.range(mpl.r.lte_5))))./clear_sky_synth_r2(mpl.r.lte_5);
%%
figure; imagegap(serial2doy(mpl.time), mpl.range(mpl.r.lte_10), mpl.prof(mpl.r.lte_10,:).*(corr.ol(mpl.r.lte_10)*ones(size(mpl.time)))); colorbar; caxis([0,1])
%%
figure; imagegap(serial2doy(mpl.time), mpl.range(mpl.r.lte_10), real(log10(mpl.prof(mpl.r.lte_10,:).*(corr.ol(mpl.r.lte_10)*ones(size(mpl.time))))));  caxis([-1,0]); colorbar;
corr.ap = ap;
%%
save nim_mpl_corrs.mat corr
