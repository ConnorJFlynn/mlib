
function mfr = Alive_mfrsrod(arg);

pstem = arg.pstem;
swflux_path = arg.swflux_path ;
smos_path = arg.smos_path;
toms_path = arg.toms_path;

mfr_dir = [pstem, 'b1\solarday\'];
lang_dir  = [pstem, 'Langleys\'];
lang_file = arg.lang_file;
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

% % Now load the pre-bundled bunch of langleys
[lang_name] = [lang_dir, lang_file];
langs = ancload(lang_name);
%langs = get_robust_Io(langs);
%
%get_dir_list
%For all matching files in list, do.
mask = '*.nc';
[mfr_list, mfr_dir] = get_dir_list(mfr_dir, mask);
%[dirlist,pname] = dir_list('*.cdf');
for i = 1:length(mfr_list);
   close('all')
   disp(['Processing ', mfr_list(i).name, ' : ', num2str(i), ' of ', num2str(length(mfr_list))]);
   pause(1)
   %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
   mfr = ancload([mfr_dir, mfr_list(i).name]);
   head_id = deblank(char(mfr.atts.head_id.data));
   arg.head_id = head_id;
   if exist([arg.corr_matpath,arg.fmask,'.',head_id,'.mat'],'file')
      load([arg.corr_matpath,arg.fmask,'.',head_id,'.mat']);
   else
      corrs = get_head_corrs(arg);
      save([corr_matpath,fmask,'.',head_id,'.mat'], 'corrs');
   end
   %mfr_head = corrs.filter_corrs;

   mfr = get_daily_Vo(mfr, langs, 25);
   file_date_str = datestr(mfr.time(1), 'yyyymmdd');

   [spas.zen_angle, spas.az_angle, spas.r_au,spas.hour_angle, spas.inc_angle, spas.sunrise,spas.suntransit, spas.sunset] = spa(mfr.vars.lat.data, mfr.vars.lon.data, mfr.vars.alt.data, mfr.time);
   spas.time = mfr.time;
   mfr.vars.cordn_1AU_415nm = mfr.vars.cordirnorm_filter1;
   mfr.vars.cordirnorm_1AU_415nm.id = ceil(max(id_list(mfr.vars))+1);
   mfr.vars.cordirnorm_1AU_500nm = mfr.vars.cordirnorm_filter2;
   mfr.vars.cordirnorm_1AU_500nm.id = ceil(max(id_list(mfr.vars))+1);
   mfr.vars.cordirnorm_1AU_615nm = mfr.vars.cordirnorm_filter3;
   mfr.vars.cordirnorm_1AU_615nm.id = ceil(max(id_list(mfr.vars))+1);
   mfr.vars.cordirnorm_1AU_673nm = mfr.vars.cordirnorm_filter4;
   mfr.vars.cordirnorm_1AU_673nm.id = ceil(max(id_list(mfr.vars))+1);
   mfr.vars.cordirnorm_1AU_870nm = mfr.vars.cordirnorm_filter5;
   mfr.vars.cordirnorm_1AU_870nm.id = ceil(max(id_list(mfr.vars))+1);
   mfr.vars.cordirnorm_1AU_940nm = mfr.vars.cordirnorm_filter6;
   mfr.vars.cordirnorm_1AU_940nm.id = ceil(max(id_list(mfr.vars))+1);

   mfr.vars.cordirnorm_1AU_415nm.data = mfr.vars.cordirnorm_filter1.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_500nm.data = mfr.vars.cordirnorm_filter2.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_615nm.data = mfr.vars.cordirnorm_filter3.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_673nm.data = mfr.vars.cordirnorm_filter4.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_870nm.data = mfr.vars.cordirnorm_filter5.data .* spas.r_au .* spas.r_au;
   mfr.vars.cordirnorm_1AU_940nm.data = mfr.vars.cordirnorm_filter6.data .* spas.r_au .* spas.r_au;
   airmass = zeros(size(spas.zen_angle));
   sundown = (spas.zen_angle >= 90);
   airmass(~sundown) = 1./(cos(spas.zen_angle(~sundown)*(pi/180)));
   airmass(sundown) = NaN;

   good_air = find((airmass > .9)&(airmass<9));

   if length(good_air>2)
      spas.airmass = 1./(cos(spas.zen_angle*(pi/180)));
      %     Io_415nm_esr = mfr_head.filter{2}.normed.esr_irradiance;
      %     Io_500nm_esr = mfr_head.filter{3}.normed.esr_irradiance;
      Io_415nm = corrs{2}.trace.normed.esr_irradiance; 
      Io_500nm = corrs{3}.trace.normed.esr_irradiance;
      Io_615nm = corrs{4}.trace.normed.esr_irradiance;
      Io_673nm = corrs{5}.trace.normed.esr_irradiance;
      Io_870nm = corrs{6}.trace.normed.esr_irradiance;
      Io_940nm = corrs{7}.trace.normed.esr_irradiance;
      disp([Io_415nm, Io_500nm, Io_615nm, Io_673nm, Io_870nm, Io_940nm])
      Cal_415nm = 1./(mfr.vars.Vo_filter1.data/Io_415nm);
      Cal_500nm = 1./(mfr.vars.Vo_filter2.data/Io_500nm);
      Cal_615nm = 1./(mfr.vars.Vo_filter3.data/Io_615nm);
      Cal_673nm = 1./(mfr.vars.Vo_filter4.data/Io_673nm);
      Cal_870nm = 1./(mfr.vars.Vo_filter5.data/Io_870nm);
      Cal_940nm = 1./(mfr.vars.Vo_filter6.data/Io_940nm);

      %     mfr.tod_415nm = (log(Io_415nm_esr*Io_500nm/Io_500nm_esr)-log(mfr.vars.cordirnorm_1AU_415nm.data))./(airmass);

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));
         gtz = ((mfr.vars.(['Vo_filter',num2str(j)]).data>0)&(mfr.vars.(['cordirnorm_1AU_',NNNnm]).data>0 ));
         mfr.(['tau_',NNNnm]) = zeros(size(mfr.vars.(['Vo_filter',num2str(j)]).data));
         mfr.(['tau_',NNNnm])(~gtz) = NaN;
         mfr.(['tau_',NNNnm])(gtz) = (log(mfr.vars.(['Vo_filter',num2str(j)]).data(gtz)) - ...
            log(mfr.vars.(['cordirnorm_1AU_',NNNnm]).data(gtz)))./(airmass(gtz));
         mfr.vars.(['tau_',NNNnm]).data = mfr.(['tau_',NNNnm]);
         mfr.vars.(['tau_',NNNnm]).atts.units.data = 'unitless';
         mfr.vars.(['tau_',NNNnm]).atts.long_name.data = ['total optical depth at ', NNNnm];
      end

      % Now load smos file for same day
      smos_list = dir([smos_path, '*',file_date_str,'*.cdf']);
      smos30 = ancload([smos_path smos_list(1).name]);

      mfr.pres = interp1(serial2doy0(smos30.time), 10*smos30.vars.bar_pres.data, serial2doy0(mfr.time),'spline', 'extrap');
      mfr.pres_frac = mfr.pres/1013;
      mfr.vars.pres.data = mfr.pres;
      mfr.vars.pres.atts.units.data = 'mB';
      mfr.vars.pres.atts.long_name.data = 'atmospheric pressure';
      mfr.vars.pres.atts.datastream.data = 'sgp30smosE13.b1';

      mfr.vars.pres_frac.data = mfr.pres_frac;
      mfr.vars.pres_frac.atts.units.data = 'unitless';
      mfr.vars.pres_frac.atts.long_name.data = 'pressure fraction relative to 1013 mb std atm';

      mfr.tod_ray_415nm = corrs{2}.trace.normed.tod_ray * mfr.pres_frac;
      mfr.tod_ray_500nm = corrs{3}.trace.normed.tod_ray * mfr.pres_frac;
      mfr.tod_ray_615nm = corrs{4}.trace.normed.tod_ray * mfr.pres_frac;
      mfr.tod_ray_673nm = corrs{5}.trace.normed.tod_ray * mfr.pres_frac;
      mfr.tod_ray_870nm = corrs{6}.trace.normed.tod_ray * mfr.pres_frac;
      mfr.tod_ray_940nm = corrs{7}.trace.normed.tod_ray * mfr.pres_frac;

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
      toms_lat = [max(find(toms.vars.lat.data < mfr.vars.lat.data)):min(find(toms.vars.lat.data > mfr.vars.lat.data))];
      toms_lon = [max(find(toms.vars.lon.data < mfr.vars.lon.data)):min(find(toms.vars.lon.data > mfr.vars.lon.data))];
      toms_time = find(floor(toms.time)==floor(mfr.time(1)));
      mfr.toms = mean(mean(toms.vars.ozone.data(toms_lat, toms_lon, toms_time)));
      mfr.vars.toms.data = mfr.toms;
      mfr.vars.toms.atts.long_name.data = 'Column ozone reported by TOMS';
      mfr.vars.toms.atts.units.data = 'Dobson units';
      mfr.vars.toms.dims = mfr.vars.lat.dims;

      mfr.o3_coef_415nm = corrs{2}.trace.normed.o3_coef;
      mfr.o3_coef_500nm = corrs{3}.trace.normed.o3_coef;
      mfr.o3_coef_615nm = corrs{4}.trace.normed.o3_coef;
      mfr.o3_coef_673nm = corrs{5}.trace.normed.o3_coef;
      mfr.o3_coef_870nm = corrs{6}.trace.normed.o3_coef;
      mfr.o3_coef_940nm = corrs{7}.trace.normed.o3_coef;

      mfr.o3_od_415nm = mfr.o3_coef_415nm*mfr.toms/1000;
      mfr.o3_od_500nm = mfr.o3_coef_500nm*mfr.toms/1000;
      mfr.o3_od_615nm = mfr.o3_coef_615nm*mfr.toms/1000;
      mfr.o3_od_673nm = mfr.o3_coef_673nm*mfr.toms/1000;
      mfr.o3_od_870nm = mfr.o3_coef_870nm*mfr.toms/1000;
      mfr.o3_od_940nm = mfr.o3_coef_940nm*mfr.toms/1000;
      %%!! AOD
      mfr.aod_415nm = mfr.tau_415nm - mfr.tod_ray_415nm - mfr.o3_od_415nm;
      mfr.aod_500nm = mfr.tau_500nm - mfr.tod_ray_500nm - mfr.o3_od_500nm;
      mfr.aod_615nm = mfr.tau_615nm - mfr.tod_ray_615nm - mfr.o3_od_615nm;
      mfr.aod_673nm = mfr.tau_673nm - mfr.tod_ray_673nm - mfr.o3_od_673nm;
      mfr.aod_870nm = mfr.tau_870nm - mfr.tod_ray_870nm - mfr.o3_od_870nm;
      mfr.aod_940nm = mfr.tau_940nm - mfr.tod_ray_940nm - mfr.o3_od_940nm;

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['Io_',NNNnm]).data = eval(['Io_',NNNnm]);
         mfr.vars.(['Io_',NNNnm]).dims = mfr.vars.lat.dims;
         mfr.vars.(['Io_',NNNnm]).atts.units.data = 'W/(m^2 * nm)';
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['Cal_',NNNnm]).data = eval(['Cal_',NNNnm]);
         mfr.vars.(['Cal_',NNNnm]).atts.units.data = 'W/(m^2 * nm * V)';
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['Rayleigh_std_atm_OD_',NNNnm]).data = corrs{j+1}.trace.normed.tod_ray;
         mfr.vars.(['Rayleigh_std_atm_OD_',NNNnm]).dims = mfr.vars.lat.dims;
         mfr.vars.(['Rayleigh_std_atm_OD_',NNNnm]).atts.units.data = 'unitless';
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['Rayleigh_optical_depth_',NNNnm]).data = mfr.(['tod_ray_',NNNnm]);
         mfr.vars.(['Rayleigh_optical_depth_',NNNnm]).atts.units.data = 'unitless';
         mfr.vars.(['Rayleigh_optical_depth_',NNNnm]).atts.scaled_to_ambient_pressure.data = 'Rayleigh OD for std atm scaled to ambient pressure';
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['o3_coef_',NNNnm]).data = corrs{j+1}.trace.normed.o3_coef;
         mfr.vars.(['o3_coef_',NNNnm]).atts.long_name.data = ['Ozone extinction coef. at ',NNNnm];
         mfr.vars.(['o3_coef_',NNNnm]).atts.units.data = ['1/cm'];
         mfr.vars.(['o3_coef_',NNNnm]).dims = mfr.vars.lat.dims;
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['o3_od_',NNNnm]).data = mfr.(['o3_coef_',NNNnm])*mfr.toms/1000;
         mfr.vars.(['o3_od_',NNNnm]).atts.long_name.data = ['Ozone optical depth at ',NNNnm];
         mfr.vars.(['o3_od_',NNNnm]).atts.units.data = ['unitless'];
         mfr.vars.(['o3_od_',NNNnm]).dims = mfr.vars.lat.dims;
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         gtz = ((mfr.vars.(['Vo_filter',num2str(j)]).data>0)&(mfr.vars.(['cordirnorm_1AU_',NNNnm]).data>0 ));
         mfr.(['tod_',NNNnm]) = zeros(size(mfr.vars.(['Vo_filter',num2str(j)]).data));
         mfr.(['tod_',NNNnm])(~gtz) = NaN;
         mfr.(['tod_',NNNnm])(gtz) = (log(mfr.vars.(['Vo_filter',num2str(j)]).data(gtz)) - ...
            log(mfr.vars.(['cordirnorm_1AU_',NNNnm]).data(gtz)))./(airmass(gtz));

         mfr.vars.(['tau_',NNNnm]).data = mfr.(['tod_',NNNnm]);
         mfr.vars.(['tau_',NNNnm]).atts.units.data = 'unitless';
         mfr.vars.(['tau_',NNNnm]).atts.long_name.data = ['total optical depth at ', NNNnm];
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));

         mfr.vars.(['aod_',NNNnm]).data = mfr.(['aod_',NNNnm]) ;
         mfr.vars.(['aod_',NNNnm]).atts.long_name.data = ['aerosol optical depth at ', NNNnm];
         mfr.vars.(['aod_',NNNnm]).atts.units.data = 'unitless';
         mfr.vars.(['aod_',NNNnm]).atts.Comment.data = ['Subtracted Rayleigh and ozone'];
      end

      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));


         mfr.vars.(['aod_cloud_screened',NNNnm]).data = NaN(size(mfr.time));
         mfr.vars.(['aod_cloud_screened',NNNnm]).atts.units.data = 'unitless';
         mfr.vars.(['aod_cloud_screened',NNNnm]).atts.long_name.data = ['cloud screened aerosol optical depth at ', NNNnm];
      end

      mfr.ang_415by673 = log(mfr.aod_415nm./mfr.aod_673nm)/log(673/415);
      mfr.ang_415by615 = log(mfr.aod_415nm./mfr.aod_615nm)/log(615/415);
      mfr.ang_415by500 = log(mfr.aod_415nm./mfr.aod_500nm)/log(500/415);
      mfr.ang_500by673 = log(mfr.aod_500nm./mfr.aod_673nm)/log(673/500);
      mfr.ang_500by615 = log(mfr.aod_500nm./mfr.aod_615nm)/log(615/500);
      mfr.ang_615by673 = log(mfr.aod_615nm./mfr.aod_673nm)/log(673/615);

      mfr.vars.angstrom_415by673.data = mfr.ang_415by673 ;
      mfr.vars.angstrom_415by615.data =  mfr.ang_415by615 ;
      mfr.vars.angstrom_415by500.data =  mfr.ang_415by500 ;
      mfr.vars.angstrom_500by673.data =  mfr.ang_500by673 ;
      mfr.vars.angstrom_500by615.data =  mfr.ang_500by615 ;
      mfr.vars.angstrom_615by673.data =  mfr.ang_615by673 ;

      mfr.vars.angstrom_415by673.atts.units.data = 'unitless';
      mfr.vars.angstrom_415by615.atts.units.data = 'unitless';
      mfr.vars.angstrom_415by500.atts.units.data = 'unitless';
      mfr.vars.angstrom_500by673.atts.units.data = 'unitless';
      mfr.vars.angstrom_500by615.atts.units.data = 'unitless';
      mfr.vars.angstrom_615by673.atts.units.data = 'unitless';

      mfr.aod_355nm_est = mfr.aod_415nm .* (415/355).^(mfr.ang_415by673);

      mfr.vars.aod_355nm_est.data = mfr.aod_355nm_est;
      mfr.vars.aod_355nm_est.atts.long_name.data = ['AOD at 355 nm estimated from angstrom exponent'];
      mfr.vars.aod_355nm_est.atts.units.data = ['unitless'];

      [aero, eps] = alex_screen(mfr.time(good_air), mfr.tod_500nm(good_air));
      eps_threshold = 5e-4;
      aero = (eps<eps_threshold);

      mfr.vars.aero.data = zeros(size(mfr.time));
      mfr.vars.aero.data(good_air) = aero;
      mfr.vars.aero.atts.units.data = 'Boolean';
      mfr.vars.aero.atts.meaning.data = '1 = aerosol, 0 = cloud-contaminated';
      mfr.vars.aero.atts.explanation.data = 'This flag is set based on the variability during a 5-minute window';
      mfr.vars.aero.atts.epsilon.data = ['Set to 1 if epsilon < ',num2str(eps_threshold)];

      mfr.vars.eps.data = NaN(size(mfr.time));
      mfr.vars.eps.data(good_air) = eps;
      mfr.vars.eps.atts.long_name.data = 'Homogeneity parameter epsilon';
      mfr.vars.eps.atts.units.data = 'unitless';
      mfr.vars.eps.atts.basis_for_test.data = 'Based on the difference between arithmetic and geometric means.';
      mfr.vars.aero.atts.comment.data = 'Higher variability in optical depth during the 5-minute window yields higher values of epsilon';
      mfr.vars.aero.atts.threshold.data = ['An empirical threshold of ',num2str(eps_threshold),' is used to detect cloud contamination'];

      aero2 = find(mfr.vars.aero.data == true);
      nm = {'415nm', '500nm','615nm', '673nm', '870nm', '940nm'};
      for j = 1:6
         NNNnm = char(nm(j));
         mfr.vars.(['aod_cloud_screened',NNNnm]).data(aero2) = mfr.vars.(['aod_',NNNnm]).data(aero2);
      end


      options = ['-dpng'];
      [PATHSTR,NAME,EXT] = fileparts([mfr_dir, mfr_list(i).name]);

      %       figure; plot(serial2Hh(mfr.time(good_air)), [mfr.aod_415nm(good_air);mfr.aod_500nm(good_air);mfr.aod_615nm(good_air);mfr.aod_673nm(good_air);mfr.aod_870nm(good_air)], '.');
      %       title(['mfrsrE13 ALL POINTS: ', datestr(floor(mfr.time(1)))]);
      %       v = axis;
      %       axis([12,24,0,v(4)]);
      %       legend('415 nm', '500 nm','615 nm','673 nm','870 nm');
      %       xlabel('time (HH UTC)')
      %       ylabel ('aerosol optical depth')
      %       plot_label = '.all_aod';
      %
      %       print( gcf, '-dpng', [png_dir, NAME,plot_label, '.png'] );
      %       saveas(gcf, [fig_dir,NAME, plot_label, '.fig'], 'fig')

      if length(find(aero==1))>1
         figure; plot(serial2Hh(mfr.time(good_air(aero))), [mfr.aod_355nm_est(good_air(aero)); ...
            mfr.aod_415nm(good_air(aero)); mfr.aod_500nm(good_air(aero)) ; mfr.aod_615nm(good_air(aero)); ...
            mfr.aod_673nm(good_air(aero));mfr.aod_870nm(good_air(aero))], '.');
         title([arg.fmask, ' cloud-screened AOD: ', datestr(floor(mfr.time(1)))]);
         v = axis;
         axis([12,24,0,v(4)]);
         legend('355 nm (est)','415 nm', '500 nm', '615 nm (est)','673 nm', '870 nm')
         xlabel('time (HH UTC)')
         ylabel ('aerosol optical depth')
         %pause
         plot_label = '.screened_aod';
         print( gcf, '-dpng', [png_dir,'screened_aod/', NAME,plot_label, '.png'] );

         saveas(gcf, [fig_dir,NAME, plot_label, '.fig'], 'fig')

         figure; plot(serial2Hh(mfr.time(good_air(aero))), [mfr.ang_415by500(good_air(aero));mfr.ang_415by615(good_air(aero));mfr.ang_415by673(good_air(aero))],'.', serial2Hh(mfr.time(good_air(aero))), [mfr.ang_500by615(good_air(aero));mfr.ang_500by673(good_air(aero))],'+', serial2Hh(mfr.time(good_air(aero))), [mfr.ang_615by673(good_air(aero))],'x' );
         title([arg.fmask, ' cloud-screened angstrom exponents: ', datestr(floor(mfr.time(1)))]);
         legend('415nm vs 500nm','415nm vs 615nm', '415nm vs 673nm','500nm vs 615nm', '500nm vs 673nm', '615nm vs 673nm');
         xlabel('time (HH UTC)');
         ylabel ('angstrom exponent');
         %    v = axis;
         axis([12,24, 0,4]);
         %     pause
         plot_label = '.screened_ang';
         print( gcf, '-dpng', [png_dir,'screened_ang/', NAME,plot_label, '.png'] );
         saveas(gcf, [fig_dir,NAME, plot_label, '.fig'], 'fig')
         V = datevec(mfr.time(good_air(aero)));
         yyyy = V(:,1);
         mm = V(:,2);
         dd = V(:,3);
         HH = V(:,4);
         MM = V(:,5);
         SS = V(:,6);
         doy0 = serial2doy0(mfr.time(good_air(aero)))';
         HHhh = (doy0 - floor(doy0)) *24;
         txt_out = [yyyy, mm, dd, HH, MM, SS, doy0, HHhh, ...
            mfr.aod_415nm(good_air(aero))', mfr.aod_500nm(good_air(aero))', ...
            mfr.aod_615nm(good_air(aero))', mfr.aod_673nm(good_air(aero))', ...
            mfr.aod_870nm(good_air(aero))', mfr.ang_415by500(good_air(aero))', ...
            mfr.ang_415by615(good_air(aero))', mfr.ang_415by673(good_air(aero))', ...
            mfr.ang_500by615(good_air(aero))', mfr.ang_500by673(good_air(aero))' , ...
            mfr.ang_615by673(good_air(aero))'];
         fid = fopen([txt_dir, NAME, '.txt'],'wt');
         fprintf(fid, '%s \n','yyyy, mm, dd, HH, MM, SS, doy0, HHhh, aod415, aod500, aod615, aod673, aod870, ang415_500, ang415_615, ang415_673,  ang500_615, ang500_673, ang615_673');
         fprintf(fid,'%d, %d, %d, %d, %d, %d, %3.6f, %2.4f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n',txt_out');
         fclose(fid);
      end

      clear txt_out
      save( [mat_dir, NAME, '.mat'], 'mfr', '-mat')

      %Now to save the netcdf file...
      [ppart, fpart, ext] = fileparts(mfr.fname);
      mfr_out.fname = char([arg.nc_dir, fpart, '.nc']);

      mfr_out.atts = mfr.atts;
      mfr_out.recdim = mfr.recdim;
      mfr_out.dims = mfr.dims;
      mfr_out.vars = mfr.vars;
      mfr_out.time = mfr.time;
      clear mfr
      mfr_out = ancsetepoch(mfr_out);
      mfr_out.quiet = true;
      mfr_out = anccheck(mfr_out);
      mfr_out.vars.lat.id = ceil(max(id_list(mfr_out.vars))+1);
      mfr_out.vars.lon.id = ceil(max(id_list(mfr_out.vars))+1);
      mfr_out.vars.alt.id = ceil(max(id_list(mfr_out.vars))+1);
      %   mfr_out = anccheck(mfr_out);
      mfr_out.clobber = true;
      mfr_out = ancsave(mfr_out);
      clear mfr_out

      % This is the name of the current netcdf file: [mfr_dir, mfr_list(i).name]
      pause(1)
   end
end

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
