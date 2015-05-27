% Simulated MPL data file
%-- 10/14/04  8:02 PM --%
clear
[mpl, status, save_array] = read_mpl;
bg = [1:10:1180];
bg = bg/500;
bg_cts = ones(2000,1)*bg;
exp_prof = exp(-mpl.range./7);
range_corr = range;
range_corr = range_corr / 4;
range_corr = range_corr .* range_corr;
range_corr = 1./range_corr;
ol = range .* (range < 5)/5;
ol = ol + (range >= 5);
olx = ol .^ .5;
atm_prof = olx .* (exp_prof .* range_corr);
ol_corr = 1./olx;
atm_prof = atm_prof ./ 10;
sim_raw = bg_cts + atm_prof * ones(1,118);
%atm_prof = olx .* (exp_prof .* range_corr);
sin_prof = -cos(2*pi*[1:450]/150);
sin_prof = [sin_prof, zeros(1,1550)]';
sin_prof = sin_prof .* (sin_prof > 0);
sin_prof = sin_prof / 3;
exp_prof = exp_prof ./ 10;
sin_prof = sin_prof / 10;

%!!!This may not be right.  It looks like sim_raw already includes bg_cts
%from above.  Small matter though.
sim_noise = sqrt(sim_raw+ bg_cts);
normal_noise = box_muller(sim_noise) .* sim_noise;
sky_raw = sim_raw + normal_noise/1000;
sky_bg = mean(sky_raw(mpl.r.bg,:));
mpl.hk.bg = sky_bg;
mpl.rawcts = sky_raw;
[status, wmpl] = write_winmpl(mpl);
