function bad = aos_despike(time, y,y_min, y_max,pre_window, mad_thresh, eps_thresh,eps_window,  post_window, y_base);

% We'll want a pre-screen that applies a MADS screen combined with filter
% removing the top outliers




cpcf = anc_bundle_files(getfullname('*.cdf *.nc','cpcf','Select cpcf files'));

cpcf = ARM_nc_display(cpcf);
% (time, tau,tau_min, tau_max,pre_window, mad_thresh, eps_thresh,eps_window,  post_window, aot_base)
[aero, eps, aero_eps, mad, abs_dev] = aod_screen(cpcf.time, cpcf.vdata.concentration,min(cpcf.vdata.concentration), 5000,2,2.5);



 [aero(day), mad(day), abs_dev(day)] = aod_prescreen(time(day), tau(day), pre_window, 2.5);
 figure; plot(serial2doys(time(day)), tau(day), 'r.', serial2doys(time(day&aero)), tau(day&aero),'k.') 
 
 [aero_eps(aero&day), eps(aero&day)] = eps_screen(time(aero&day), tau(aero&day), eps_window./2, 5e-3, aot_base2);
 figure; plot(serial2doys(time(day)), tau(day), 'r.',serial2doys(time(day&aero)), tau(day&aero), 'k.', serial2doys(time(day&aero_eps)), tau(day&aero_eps),'g.') 
  figure; plot(serial2doys(time(day)), eps(day), 'r.'); legend('eps')




















return