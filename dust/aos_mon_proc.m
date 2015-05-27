function aos_mon_proc
%%
aos_mon_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos\'];
aos_1min_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos_1min\'];
aos_um_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos_um\'];
aip_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aip\'];
aip_1h_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aip_1h\'];
aip_1d_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aip_1d\'];
if ~exist(aos_1min_dir,'dir')
   mkdir(aos_1min_dir);
end
if ~exist(aos_um_dir,'dir')
   mkdir(aos_um_dir);
end
if ~exist(aip_dir,'dir')
   mkdir(aip_dir);
end
if ~exist(aip_1h_dir,'dir')
   mkdir(aip_1h_dir);
end
if ~exist(aip_1d_dir,'dir')
   mkdir(aip_1d_dir);
end
%
% In the code below commented lines may be commented or uncommented
% depending on how far up the processing train you want to start.
% The function "impact_aos_h_2" is time consuming.  Skip if possible!
% mats = dir([aos_mon_dir, 'aos.*.mat']);
mats = dir([aos_um_dir, 'aos_um.*.mat']);
for m = 1:length(mats)
   %    aos_mon = loadinto([aos_mon_dir, mats(m).name]);
   %    dstr = datestr(aos_mon.time(1),'yyyy_mm_dd');
   %    aos_um = impact_aos_h_2(aos_mon);
   %    save([aos_um_dir, 'aos_um.',dstr,'.mat'],'aos_um');
   aos_um = loadinto([aos_um_dir, mats(m).name]);
   dstr = datestr(aos_um.time(1),'yyyy_mm_dd');
   disp(dstr);

   aos_um = add_winds(aos_um);
   %    save([aos_um_dir, 'aos_um.',dstr,'.mat'],'aos_um');
   disp('Putting on 1 minute grid.')
   aos_1min = grid_aos_1min(aos_um);
   save([aos_1min_dir, 'aos_1min.',dstr,'.mat'],'aos_1min');

   disp('Computing intensive properties.')
   aip = aos_aip(aos_1min);
   % aip = aip_1min_plots(aip);
   %    aip = final_dust_screen(aip);
   save([aip_dir, 'aip.',dstr,'.mat'],'aip');
   disp('Computing hourly averages');
   aip_1h = grid_1hr(aip);
   save([aip_1h_dir, 'aip_1h.',dstr,'.mat'],'aip_1h');
   %    aip_1h = aip_1hr_plots(aip_1h);
end
clear aos_mon aos_um aos_1min aip aip_1h aip_1d
mats = dir([aip_1h_dir, 'aip_1h.*.mat']);
for m = 1:length(mats)
   if ~exist('aip_1h','var')
      aip_1h = loadinto([aip_1h_dir, mats(m).name]);
   else
      aip_1h = cat_aip(aip_1h, loadinto([aip_1h_dir, mats(m).name]));
   end
end
disp('Saving year-long hourly averages.')
save([aip_1h_dir, '../aip_1h.mat'],'aip_1h');
aip_1h = bad_times(aip_1h);
aip_1h = make_subs(aip_1h);
aip_1h = final_dust_screen2(aip_1h);
save([aip_1h_dir, '../aip_1h.mat'],'aip_1h');
%    aip_1h = aip_1hr_plots(aip_1h);
disp('Computing daily averages');
%    aip_1d = grid_1day(aip);
aip_1d = grid_1day2(aip_1h);
%    aip_1d = bad_times(aip_1d);

save([aip_1d_dir, 'aip_1d.',dstr,'.mat'],'aip_1d');
%    aip_1d = aip_1hr_plots(aip_1d);

mats = dir([aip_1d_dir, 'aip_1d.*.mat']);
for m = 1:length(mats)
   if ~exist('aip_1d','var')
      aip_1d = loadinto([aip_1d_dir, mats(m).name]);
   else
      aip_1d = cat_aip(aip_1d, loadinto([aip_1d_dir, mats(m).name]));
   end
end
disp('Saving year-long daily averages.')
save([aip_1d_dir, '../aip_1d.mat'],'aip_1d');
clear aip_1d

function aip = cat_aip(aip, new_aip);
[new_time,ind] = unique([aip.time; new_aip.time]);
field = fieldnames(aip);
new_field = fieldnames(new_aip);
if all(strcmp(field,new_field))
   for f = 1:length(field)
      if all(size(new_aip.(field{f}))==size(new_aip.time))
         tmp = [aip.(field{f}); new_aip.(field{f})];

         aip.(field{f}) = tmp(ind);
      end
   end
   aip.time = new_time;
else
   disp(['Not same shape structure, not concatenating.']);
   disp(['Returning initial structure unmodified.']);
end
return
%%



