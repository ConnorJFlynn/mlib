%Read Kiedron RSS into matlab matrix
pname = uigetdir(['C:\case_studies\Alive\data\']);
pname = [pname, '/'];
flist = dir([pname, 'RSS*.txt']);

if size(flist,1)>0
   for f = 1:size(flist,1)
      [this, that] = loadit([pname, flist(f).name]);
      % For whatever reason, the array is coming in as float instead of char
      tmp.time = this(:,1) + datenum('01-01-1900','dd-mm-yyyy') + this(:,2)/24 - 1;
      tmp.SEA = this(:,3);
      tmp.pres = this(:,4);
      tmp.ozone = this(:,5);
      tmp.aod_360nm = this(:,6);
      tmp.aod_500nm = this(:,7);
      tmp.aod_780nm = this(:,8);
      tmp.aod_870nm = this(:,9);
      if ~exist('rss','var')
         rss = tmp;
      else
         rss.time = [rss.time ; tmp.time];
         rss.SEA = [rss.SEA ; tmp.SEA];
         rss.pres = [rss.pres ; tmp.pres];
         rss.ozone = [rss.ozone ; tmp.ozone];
         rss.aod_360nm = [rss.aod_360nm ; tmp.aod_360nm];
         rss.aod_500nm = [rss.aod_500nm ; tmp.aod_500nm];
         rss.aod_780nm = [rss.aod_780nm ; tmp.aod_780nm];
         rss.aod_870nm = [rss.aod_870nm ; tmp.aod_870nm];
      end
   end
end

save rss_alive rss
aero = alex_screen(rss.time, rss.aod_500nm);;
plot(serial2doy0(cimel.time), cimel.AOT_500,'k.', ...
serial2doy0(C1.time), C1.vars.aod_cloud_screened500nm.data, 'b.', ...
serial2doy0(E13.time), E13.vars.aod_cloud_screened500nm.data, 'r.', ...
serial2doy0(rss.time(aero)), rss.aod_500nm(aero), 'g.')
title('Aerosol optical depths at 500 nm')
ylabel('aerosol optical depth');
v = axis;
vv = find((serial2doy0(E13.time)>= v(1))&(serial2doy0(E13.time)<=v(2)));
doystr = [datestr(floor(mean(E13.time(vv)))), ' = ', ...
   num2str(floor(serial2doy0(mean(E13.time(vv)))))];
xlabel(['day of year (Jan 1 = 0, ',doystr, ')'])
legend('Cimel', 'MFRSR C1', 'MFRSR E13', 'RSS');
 
   