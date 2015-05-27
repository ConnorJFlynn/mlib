
function [alls] = nimmfrsrod(arg);
% %%
% Now extend to all filters 1-5
% pstem = getdir([],'dust','Select dust directory');
% smos_path = getdir([],'dust_smos','Select surface pressure source.');
% toms_path = getdir([],'dust_ozone','Select ozone source.');
% mfr_dir = getdir([],'dust_mfrsr','Select mfrsr directory.');
% lang_dir  = getdir([],'dust_lang', 'Select langley directory.');

pstem = ['C:\case_studies\dust\'];
smos_path = ['C:\case_studies\dust\nimmetM1.b1\'];
toms_path = ['C:\case_studies\dust\gecomiX1.a1\'];
mfr_dir = ['C:\case_studies\dust\nimmfrsrM1.b1\solarday\'];
lang_dir  = ['C:\case_studies\dust\nimmfrsrM1.b1\solarday\langley\bundle\'];

fig_dir = [pstem, 'fig\'];
mat_dir = [pstem, 'mat\'];
png_dir = [pstem, 'png\'];
nc_dir = [pstem, 'nc\'];
txt_dir = [pstem, 'txt\'];
if ~exist(png_dir, 'dir')
   mkdir(pstem, 'png');
end
if ~exist(fig_dir, 'dir')
   mkdir(pstem, 'fig');
end
if ~exist(mat_dir, 'dir')
   mkdir(pstem, 'mat');
end
if ~exist(txt_dir, 'dir')
   mkdir(pstem, 'txt');
end
%%

load nim_lang.mat
load nim_pres.mat
load nim_ozone.mat
load o3_coef.mat
% Now load one mfr file (to get lat and lon) and TOMS
%

%%
figure;
subplot(3,1,1); plot(con_lang.time, con_lang.I_new5, 'b.');
datetick('keeplimits')
subplot(3,1,2); plot(pres.time, pres.pres, 'm.');
subplot(3,1,3); plot(ozone.time, ozone.dob, 'g.');
datetick('keeplimits')

% mfr = ancload(getfullname_([],'dust_mfrsr','Select an MFRSR file for coords.'));

%%

%get_dir_list
%For all matching files in list, do.
mask = '*.cdf';
[mfr_list, mfr_dir] = get_dir_list(mfr_dir, mask);
close('all')
%[dirlist,pname] = dir_list('*.cdf');
for i = 1:length(mfr_list);

   disp(['Processing ', mfr_list(i).name, ' : ', num2str(i), ' of ', num2str(length(mfr_list))]);
   mfr = ancload([mfr_dir, mfr_list(i).name]);
   file_date_str = datestr(mfr.time(1), 'yyyymmdd');
   [spas.zen_angle, spas.az_angle, spas.r_au, spas.hour_angle, dec, el, airmass] = sunae(mfr.vars.lat.data, mfr.vars.lon.data, mfr.time);
   spas.time = mfr.time;
   mfr.vars.cordirnorm_1AU_415nm = mfr.vars.direct_normal_narrowband_filter1;
   mfr.vars.cordirnorm_1AU_415nm.data = mfr.vars.direct_normal_narrowband_filter1.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_500nm = mfr.vars.direct_normal_narrowband_filter2;
   mfr.vars.cordirnorm_1AU_500nm.data = mfr.vars.direct_normal_narrowband_filter2.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_615nm = mfr.vars.direct_normal_narrowband_filter3;
   mfr.vars.cordirnorm_1AU_615nm.data = mfr.vars.direct_normal_narrowband_filter3.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_673nm = mfr.vars.direct_normal_narrowband_filter4;
   mfr.vars.cordirnorm_1AU_673nm.data = mfr.vars.direct_normal_narrowband_filter4.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_870nm = mfr.vars.direct_normal_narrowband_filter5;
   mfr.vars.cordirnorm_1AU_870nm.data = mfr.vars.direct_normal_narrowband_filter5.data .* spas.r_au .* spas.r_au;
   sundown = (spas.zen_angle >= 90);
   airmass(sundown) = NaN;
   good_air = find((airmass > .9)&(airmass<9));
   mean_time = mean(mfr.time(good_air));
   mean_ozone = interp1(ozone.time, ozone.dob, mean_time);
   if isNaN(mean_ozone)
      mean_ozone = mean(ozone.dob);
   end
   mean_Io1 = interp1(con_lang.time, con_lang.I_new1, mean_time);
   mean_Io2 = interp1(con_lang.time, con_lang.I_new2, mean_time);
   mean_Io3 = interp1(con_lang.time, con_lang.I_new3, mean_time);
   mean_Io4 = interp1(con_lang.time, con_lang.I_new4, mean_time);
   mean_Io5 = interp1(con_lang.time, con_lang.I_new5, mean_time);
      
   if length(good_air>0)
      spas.airmass = 1./(cos(spas.zen_angle*(pi/180)));
      mfr.tau_415nm = NaN(size(mfr.vars.cordirnorm_1AU_415nm.data));
      gtz = mfr.vars.cordirnorm_1AU_415nm.data>0 ;
      mfr.tau_415nm(gtz) = (log(mean_Io1) - ...
         log(mfr.vars.cordirnorm_1AU_415nm.data(gtz)))./airmass(gtz);
      mfr.tau_500nm = NaN(size(mfr.vars.cordirnorm_1AU_500nm.data));
      gtz = mfr.vars.cordirnorm_1AU_500nm.data>0 ;
      mfr.tau_500nm(gtz) = (log(mean_Io2) - ...
         log(mfr.vars.cordirnorm_1AU_500nm.data(gtz)))./airmass(gtz);
      mfr.tau_615nm = NaN(size(mfr.vars.cordirnorm_1AU_615nm.data));
      gtz = mfr.vars.cordirnorm_1AU_615nm.data>0 ;
      mfr.tau_615nm(gtz) = (log(mean_Io3) - ...
         log(mfr.vars.cordirnorm_1AU_615nm.data(gtz)))./airmass(gtz);
      mfr.tau_673nm = NaN(size(mfr.vars.cordirnorm_1AU_673nm.data));
      gtz = mfr.vars.cordirnorm_1AU_673nm.data>0 ;
      mfr.tau_673nm(gtz) = (log(mean_Io4) - ...
         log(mfr.vars.cordirnorm_1AU_673nm.data(gtz)))./airmass(gtz);
      mfr.tau_870nm = NaN(size(mfr.vars.cordirnorm_1AU_870nm.data));
      gtz = mfr.vars.cordirnorm_1AU_870nm.data>0 ;
      mfr.tau_870nm(gtz) = (log(mean_Io5) - ...
         log(mfr.vars.cordirnorm_1AU_870nm.data(gtz)))./airmass(gtz);
      % Now load smos file for same day
      mfr.pres = interp1(pres.time, pres.pres, mfr.time);
      if all(isNaN(mfr.pres))
         mfr.pres = ones(size(mfr.time)).* mean(pres.pres);
      else
         NaNs = isNaN(mfr.pres);
         mfr.pres(NaNs) = interp1(mfr.time(~NaNs), mfr.pres(~NaNs),mfr.time(NaNs),'nearest','extrap');
      end
      mfr.pres_frac = mfr.pres./101.3;
      wl = sscanf(char(mfr.vars.direct_normal_narrowband_filter1.atts.actual_wavelength.data),'%f');
      mfr.tod_ray_415nm = tod_Rayleigh(wl) .* mfr.pres_frac;
      o3_coef_415nm = interp1(o3(:,1), o3(:,2), wl);
      mfr.o3_od_415nm = o3_coef_415nm*mean_ozone/1000;
      wl = sscanf(char(mfr.vars.direct_normal_narrowband_filter2.atts.actual_wavelength.data),'%f');
      mfr.tod_ray_500nm = tod_Rayleigh(wl) .* mfr.pres_frac;
      o3_coef_500nm = interp1(o3(:,1), o3(:,2), wl);
      mfr.o3_od_500nm = o3_coef_500nm*mean_ozone/1000;
      wl = sscanf(char(mfr.vars.direct_normal_narrowband_filter3.atts.actual_wavelength.data),'%f');
      mfr.tod_ray_615nm = tod_Rayleigh(wl) .* mfr.pres_frac;
      o3_coef_615nm = interp1(o3(:,1), o3(:,2), wl);
      mfr.o3_od_615nm = o3_coef_615nm*mean_ozone/1000;
      wl = sscanf(char(mfr.vars.direct_normal_narrowband_filter4.atts.actual_wavelength.data),'%f');
      mfr.tod_ray_673nm = tod_Rayleigh(wl) .* mfr.pres_frac;
      o3_coef_673nm = interp1(o3(:,1), o3(:,2), wl);
      mfr.o3_od_673nm = o3_coef_673nm*mean_ozone/1000;
      wl = sscanf(char(mfr.vars.direct_normal_narrowband_filter5.atts.actual_wavelength.data),'%f');
      mfr.tod_ray_870nm = tod_Rayleigh(wl) .* mfr.pres_frac;
      o3_coef_870nm = interp1(o3(:,1), o3(:,2), wl);
      mfr.o3_od_870nm = o3_coef_870nm*mean_ozone/1000;
      mfr.aod_415nm = mfr.tau_415nm - mfr.tod_ray_415nm - mfr.o3_od_415nm;
      mfr.aod_500nm = mfr.tau_500nm - mfr.tod_ray_500nm - mfr.o3_od_500nm;
      mfr.aod_615nm = mfr.tau_615nm - mfr.tod_ray_615nm - mfr.o3_od_615nm;
      mfr.aod_673nm = mfr.tau_673nm - mfr.tod_ray_673nm - mfr.o3_od_673nm;
      mfr.aod_870nm = mfr.tau_870nm - mfr.tod_ray_870nm - mfr.o3_od_870nm;      
      nonNaN = find(~isNaN(mfr.aod_500nm));
      if length(nonNaN)>5
         [aero,eps] = aod_screen(mfr.time(nonNaN), mfr.aod_870nm(nonNaN),0,4,5,2,1e-2);
         if any(aero)
            if ~exist('alls','var')
               alls.time = mfr.time(nonNaN(aero));
               alls.pres = mfr.pres(nonNaN(aero));
               alls.pres_frac = mfr.pres_frac(nonNaN(aero));
               alls.tau_415nm = mfr.tau_415nm(nonNaN(aero));
               alls.aod_415nm = mfr.aod_415nm(nonNaN(aero));
               alls.tau_500nm = mfr.tau_500nm(nonNaN(aero));
               alls.aod_500nm = mfr.aod_500nm(nonNaN(aero)); 
               alls.tau_615nm = mfr.tau_615nm(nonNaN(aero));
               alls.aod_615nm = mfr.aod_615nm(nonNaN(aero)); 
               alls.tau_673nm = mfr.tau_673nm(nonNaN(aero));
               alls.aod_673nm = mfr.aod_673nm(nonNaN(aero)); 
               alls.tau_870nm = mfr.tau_870nm(nonNaN(aero));
               alls.aod_870nm = mfr.aod_870nm(nonNaN(aero));                
               alls.eps = eps(aero);
            else
               alls.time = [alls.time, mfr.time(nonNaN(aero))];
               alls.pres = [alls.pres,mfr.pres(nonNaN(aero))];
               alls.pres_frac = [alls.pres_frac,mfr.pres_frac(nonNaN(aero))];
               alls.tau_415nm = [alls.tau_415nm,mfr.tau_415nm(nonNaN(aero))];
               alls.aod_415nm = [alls.aod_415nm,mfr.aod_415nm(nonNaN(aero))];
               alls.tau_500nm = [alls.tau_500nm,mfr.tau_500nm(nonNaN(aero))];
               alls.aod_500nm = [alls.aod_500nm,mfr.aod_500nm(nonNaN(aero))];
               alls.tau_615nm = [alls.tau_615nm,mfr.tau_615nm(nonNaN(aero))];
               alls.aod_615nm = [alls.aod_615nm,mfr.aod_615nm(nonNaN(aero))];
               alls.tau_673nm = [alls.tau_673nm,mfr.tau_673nm(nonNaN(aero))];
               alls.aod_673nm = [alls.aod_673nm,mfr.aod_673nm(nonNaN(aero))];
               alls.tau_870nm = [alls.tau_870nm,mfr.tau_870nm(nonNaN(aero))];
               alls.aod_870nm = [alls.aod_870nm,mfr.aod_870nm(nonNaN(aero))];              
               alls.eps = [alls.eps,eps(aero)];
            end
            alls.mean_time(i) = mean_time;
            alls.mean_ozone(i) = mean_ozone;
            alls.Io_415nm(i) = mean_Io1;
            alls.Io_500nm(i) = mean_Io2;
            alls.Io_615nm(i) = mean_Io3;
            alls.Io_673nm(i) = mean_Io4;
            alls.Io_870nm(i) = mean_Io5;
         end
      end
   end
   if mod(i,100)==0
      save flynn_nimaod.mat alls
   end
end
save flynn_nimaod.mat alls

function sandbox
arg.fmask = 'sgpmfrsrE13';
arg.pstem = ['D:\case_studies\new_xmfrx_proc\',arg.fmask,'\'];
arg.swflux_path = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
arg.smos_path = ['D:\case_studies\new_xmfrx_proc\sgp30smosE13.b1\'];
arg.toms_path = ['D:\case_studies\new_xmfrx_proc\toms\'];
filter_trace_path = [arg.pstem, 'corrs\filter_traces\'];
arg.lang_file = [arg.fmask,'.Vo_series.20050402.nc'];
pstem = arg.pstem;
mfr_dir = [pstem, 'b1\solarday\'];
lang_dir  = [pstem, 'Langleys\'];

arg.mfr_dir = [pstem, 'b1\'];
arg.fig_dir = [pstem, 'fig\'];
arg.mat_dir = [pstem, 'mat\'];
arg.png_dir = [pstem, 'png\'];
arg.nc_dir = [pstem, 'nc\'];
arg.txt_dir = [pstem, 'txt\'];
arg.raw_corrpath = [pstem, '\corrs\'];
arg.corr_matpath = [pstem, '\corr_mat\'];
arg.filter_trace_path = [arg.raw_corrpath, '\filter_traces\'];
Alive_mfrsrod(arg);

arg.fmask = 'sgpmfrsrC1';
arg.pstem = ['D:\case_studies\new_xmfrx_proc\',arg.fmask,'\'];
arg.swflux_path = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
arg.smos_path = ['D:\case_studies\new_xmfrx_proc\sgp30smosE13.b1\'];
arg.toms_path = ['D:\case_studies\new_xmfrx_proc\toms\'];
filter_trace_path = [arg.pstem, 'corrs\filter_traces\'];
arg.lang_file = [arg.fmask,'.Vo_series.20050402.nc'];
pstem = arg.pstem;
mfr_dir = [arg.pstem, 'b1\'];
lang_dir  = [arg.pstem, 'Langleys\'];

arg.mfr_dir = [pstem, 'b1\'];
arg.fig_dir = [pstem, 'fig\'];
arg.mat_dir = [pstem, 'mat\'];
arg.png_dir = [pstem, 'png\'];
arg.nc_dir = [pstem, 'nc\'];
arg.txt_dir = [pstem, 'txt\'];
arg.raw_corrpath = [pstem, '\corrs\'];
arg.corr_matpath = [pstem, '\corr_mat\'];
arg.filter_trace_path = [arg.raw_corrpath, '\filter_traces\'];
Alive_mfrsrod(arg);
