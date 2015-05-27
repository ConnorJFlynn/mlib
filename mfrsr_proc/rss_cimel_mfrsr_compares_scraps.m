Sept = serial2doy0(datenum(['Sept 1 2005'])) -1;

plot(serial2doy0(C1.time)-Sept, C1.vars.aod_cloud_screened500nm.data, 'b.', ...
serial2doy0(rss.time(aero))-Sept, rss.aod_500nm(aero), 'g.', ...
serial2doy0(cimel.time)-Sept, cimel.AOT_500,'r.')


title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');
xlabel('September 2005')
legend('MFRSR C1','RSS', 'Cimel');

axis([10,24, 0, 0.6])
Sept = serial2doy0(datenum(['Sept 1 2005'])) -1;

plot(... 
serial2doy0(C1.time)-Sept, C1.vars.aod_cloud_screened500nm.data, 'g.', ...
serial2doy0(C1.time)-Sept, C1.vars.aod_cloud_screened870nm.data, 'c.', ...
serial2doy0(rss.time(aero))-Sept, rss.aod_500nm(aero), 'k.', ...
serial2doy0(rss.time(aero))-Sept, rss.aod_870nm(aero), 'k.' ...
)

axis([1,31, 0, 0.6])
title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');
xlabel('September 2005')
legend('MFRSR C1','MFRSR E13', 'RSS', 'Cimel');


C1torss = interp1(C1.time, C1.vars.aod_cloud_screened500nm.data, rss.time);
notnan = ~isnan(C1torss)&~isnan(rss.aod_500nm);
[P_C1torss, S_C1torss] = polyfit(C1torss, rss.aod_500nm)

rss_interp = interp1(rss.time, rss.aod_500nm, C1.time, 'linear');
notnan = ~isnan(rss_interp)&~isnan(C1.vars.aod_cloud_screened500nm.data);
[P_rss_C1, S] = polyfit(rss_interp(notnan), C1.vars.aod_cloud_screened500nm.data(notnan), 1)
figure; plot(rss_interp, C1.vars.aod_cloud_screened500nm.data, '.', ... 
   [0, .5], polyval(P_rss_C1, [0, .5]), 'r', [0,.5], [0,.5], 'k'); 
axis([0,.3, 0, .3])
title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');

rss_interp = interp1(rss.time, rss.aod_500nm, E13.time, 'linear');
notnan = ~isnan(rss_interp)&~isnan(E13.vars.aod_cloud_screened500nm.data);
[P_rss_E13, S] = polyfit(rss_interp(notnan), E13.vars.aod_cloud_screened500nm.data(notnan), 1)
figure; plot(rss_interp, E13.vars.aod_cloud_screened500nm.data, '.', ... 
   [0, .5], polyval(P_rss_E13, [0, .5]), 'r', [0,.5], [0,.5], 'k'); 
axis([0,.3, 0, .3])
title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');

cimel_interp = interp1(cimel.time, cimel.AOT_500, rss.time, 'linear');
notnan = ~isnan(cimel_interp)&~isnan(rss.aod_500nm);
[P_rss_E13, S] = polyfit(rss.aod_500nm(notnan), cimel_interp(notnan), 1)
figure; plot(rss_interp, cimel.aod_500.data, '.', ... 
   [0, .5], polyval(P_rss_E13, [0, .5]), 'r', [0,.5], [0,.5], 'k'); 
axis([0,.3, 0, .3])
title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');