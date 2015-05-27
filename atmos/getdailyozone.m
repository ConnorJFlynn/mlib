function Du = getdailyozone(time, lat, lon);
% Du = getdailyozone(time, lat, lon);
% Modify this to call get_oz which finds a gaussian weighted value for
% robustness.
!Modify_me!
file_date_str = datestr(time(1), 'yyyymmdd');
toms_path = 'C:\case_studies\ozone\toms\';
      % Now load toms file for same day
      if exist('toms_list', 'var')
         if ~findstr(toms_list(1).name,file_date_str(1:end-2))
            toms_list = dir([toms_path, '*',file_date_str(1:end-2),'*.cdf']);
            toms = ancload([toms_path, toms_list(1).name]);
         else
            toms_list = dir([toms_path, '*',file_date_str(1:end-2),'*.cdf']);
            toms = ancload([toms_path, toms_list(1).name]);
         end
      else
         toms_list = dir([toms_path, '*',file_date_str(1:end-2),'*.cdf']);
         toms = ancload([toms_path, toms_list(1).name]);
      end
      % Should also probably add either interpolation or use of a baseline
      % value if toms is not available for given date.
      toms_lat = [max(find(toms.vars.lat.data < lat)):min(find(toms.vars.lat.data > lat))];
      toms_lon = [max(find(toms.vars.lon.data < lon)):min(find(toms.vars.lon.data > lon))];
      toms_time = find(floor(toms.time)==floor(time(1)));
      Du = mean(mean(toms.vars.ozone.data(toms_lat, toms_lon, toms_time)));
      