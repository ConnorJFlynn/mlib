% This version does not use mplnor at all.
% AWG Nov meeting
% disp('Cleaning up...');
% pause(.2);
close('all'); 
%ncclose('all'); clear
% pause(.2);
clear
pause(.1)
mpl_pname = ['C:\case_studies\Alive\data\flynn-mpl-102\Nov2006\day\'];
%mplnor_pname = ['c:\case_studies\Aerosol_IOP\sgpmplnor1campC1.c1\cdf\'];
mpl_ret_pname = ['C:\case_studies\Alive\data\flynn-mpl-102\Nov2006\ext\Nov2006\'];

load odC1.mat
aeroC1 = (odC1.vars.variability_flag.data<1e-4);
odC1 = ancsift(odC1, odC1.dims.time, aeroC1);
odC1.aod523 = odC1.vars.aerosol_optical_depth_filter2.data .*((500/523) .^ odC1.vars.angstrom_exponent.data);

if ~exist('mpl', 'var')
    mpl = mpl102_alive;
end;
% [mpl.sonde.temperature,mpl.sonde.pressure] = std_atm(mpl.range(mpl.r.lte_30));
% [mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature,mpl.sonde.pressure);
% [mpl.sonde.atten_ray] = std_ray_atten(mpl.range);
mfr_times = find((serial2doy(odC1.time)>=serial2doy(min(mpl.time))-1)&(serial2doy(odC1.time)<=serial2doy(max(mpl.time))+1));
if max(size(mfr_times))>1
   %!! 2004-12-04 Adding manual selection of "clear sky" section.  If none
   %provide, then a pre-saved clear sky profile is used.
   prof_fig = figure;
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:));
   axis('xy'); colormap('jet');
   axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
   caxis([ 0 25]);
   title('Select a time range with some clear sky.  Hit enter when done zooming or to skip.')
   disp('Select a time range with some clear sky.  Hit enter when done zooming or to skip.')
   figure(prof_fig);
   pause;
   if exist('clear_sky2.mat', 'file')
      keep = input('Press enter again to use this region or type "X" to use a pre-saved Rayleigh profile: ', 's');
      if isempty(keep)
         keep = ' ';
      end;
      if (upper(keep) == ' ') % Use mean of selected region for clear_sky
         figure(prof_fig);
         zoom off;
         title(['Clear sky for ', datestr(mpl.time(1),1)]);
         v = axis;
         pause(.1);
         clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
         mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
         [pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clear_sky_time));
         clear_sky_time = clear_sky_time(pileA);
         clear_sky = mean(mpl.prof(:,clear_sky_time)')';
         clear_sky = smooth(mpl.range,clear_sky,20,'moving');
         figure; semilogy(mpl.range(mpl.r.lte_30), clear_sky(mpl.r.lte_30));zoom
         title('Now zoom to select the region to pin a Rayleigh profile to...');
         pause
         v = axis;
         ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
         clear_sky = mpl.sonde.atten_ray * (mean(clear_sky(ray_range))/mean(mpl.sonde.atten_ray(ray_range)));
         save('clear_sky2.mat', 'clear_sky')
      else
         load('clear_sky2.mat');
      end
   else
      figure(prof_fig);
      zoom off;
      title(['Clear sky for ', datestr(mpl.time(1),1)]);
      v = axis;
      pause(.1);
      clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
      mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
      [pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clear_sky_time));
      clear_sky_time = clear_sky_time(pileA);
      clear_sky = mean(mpl.prof(:,clear_sky_time)')';
      clear_sky = smooth(mpl.range,clear_sky,20,'moving');
      figure; semilogy(mpl.range(mpl.r.lte_30), clear_sky(mpl.r.lte_30));zoom
      title('Now zoom to select the region to pin a Rayleigh profile to...');
      pause
      v = axis;
      ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
      clear_sky = mpl.sonde.atten_ray * (mean(clear_sky(ray_range))/mean(mpl.sonde.atten_ray(ray_range)));
      save('clear_sky2.mat', 'clear_sky')
   end
   %!!
   frac_fig = figure;
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:)./(clear_sky(mpl.r.lte_30)*ones(size(mpl.time))));
   axis('xy'); colormap('jet');
   title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom;
   axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
   caxis([0,5]);
   title('Zoom to select the region of time to use for retrievals.  Hit enter when done.')
   disp('Zoom to select the region of time to use for retrievals.  Hit enter when done.')
   pause
   figure(frac_fig);
   zoom off;
   title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
   frac_axis = axis;
   pause(.5)

   mpl.t.zoom = (find(serial2Hh(mpl.time)>=frac_axis(1)&serial2Hh(mpl.time)<=frac_axis(2)));
   mpl.r.zoom = find((mpl.range>=frac_axis(3))&(mpl.range<=frac_axis(4)));
   clean_mpl = mpl.t.zoom;
   [pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clean_mpl)./(clear_sky(mpl.r.zoom)*ones(size(clean_mpl))));

   clean_mpl = clean_mpl(pileA);
   old_clean_mpl = clean_mpl;
   clean_times = mpl.time(clean_mpl);

   %     The following two lines were used to identify and remove a spike cloud at ~2km
   %     cloud_range = find(mpl.range>.5 & mpl.range<2.5);
   %     clean_mpl = clean_mpl(~any(mpl.prof(cloud_range,clean_mpl)>25));

   [avg] = mpl_timeavg3(mpl,10,clean_mpl);
   %[avg] = downsample_mpl(mpl, 9*12);
   %       mpl = rmfield(mpl, 'nor');
   mpl = rmfield(mpl, 'time');
   mpl = rmfield(mpl, 'rawcts');
   mpl = rmfield(mpl, 'prof');
   mpl.time = avg.time;
   mpl.prof = avg.prof;
   mpl.rawcts = avg.rawcts;
   %       mpl.nor = avg.nor;
   mpl = rmfield(mpl, 'hk');
   mpl.hk = avg.hk;
   mpl.clean = avg.clean;
   clear avg
   missing = find((mpl.hk.bg<=-9998)&(mpl.hk.bg>=-10000));
   non_missing = setdiff([1:length(mpl.hk.bg)], missing);
   %Commented out on 10-19-2004 to avoid unnecessary "missing" designations
   clean_mpl = [];
   for ct = 1:length(clean_times)-1
      [clean_mpl] = [clean_mpl find((mpl.time>=clean_times(ct))&(mpl.time<=clean_times(ct+1)))'];
   end
   [clean_mpl] = [clean_mpl find((mpl.time>=clean_times(end-1))&(mpl.time<=clean_times(end)))'];
   [clean_mpl] = unique(clean_mpl);
   clean_mpl = find(mpl.clean);

   %odC1 data!
   notnan = ~isnan(odC1.aod523(mfr_times));
   nearest(non_missing) = interp1(serial2doy(odC1.time(mfr_times(notnan)))-floor(serial2doy(odC1.time(mfr_times(1)))), odC1.aod523(mfr_times(notnan)), serial2doy(mpl.time(non_missing))-floor(serial2doy(odC1.time(mfr_times(1)))), 'nearest', 'extrap');
   lin_interp(non_missing) = interp1(serial2doy(odC1.time(mfr_times(notnan)))-floor(serial2doy(odC1.time(mfr_times(1)))), odC1.aod523(mfr_times(notnan)), serial2doy(mpl.time(non_missing))-floor(serial2doy(odC1.time(mfr_times(1)))), 'linear', 'extrap');
   nearest(missing) = -9e-9;
   lin_interp(missing) = -9e-9;
   mfr_fig = figure;
   figure(mfr_fig);
   doy = floor(serial2doy(mean(mpl.time)));
   plot(serial2doy(odC1.time), odC1.aod523, 'g.', serial2doy(mpl.time(non_missing)), nearest(non_missing), 'ro',serial2doy(mpl.time(non_missing)), lin_interp(non_missing), 'bx'  ); zoom;
   title(['AOD 523 nm for period covering MPL data on ', datestr(mean(mpl.time),1),' (DOY=', num2str(doy), ').']);
   v = axis;
   axis([(doy -.5), (doy + 1.5), 0, 1]);
   v = axis;
   legend('mfr data', 'nearest neighbor', 'linear interpolation');
   pause(.25)
   aot_interp = input('Select interpolation method: Linear interpolation or Nearest neighbor {<L> N}','s');
%    non_missing = ~isnan(mpl.cal.aod_523);
   if upper(aot_interp)=='N'
      mpl.cal.aod_523(non_missing) = interp1(serial2doy(odC1.time(mfr_times))-floor(serial2doy(odC1.time(mfr_times(1)))), odC1.aod523(mfr_times), serial2doy(mpl.time(non_missing))-floor(serial2doy(odC1.time(mfr_times(1)))), 'nearest', 'extrap');
   else
      mpl.cal.aod_523(non_missing) = interp1(serial2doy(odC1.time(mfr_times))-floor(serial2doy(odC1.time(mfr_times(1)))), odC1.aod523(mfr_times), serial2doy(mpl.time(non_missing))-floor(serial2doy(odC1.time(mfr_times(1)))), 'linear', 'extrap');
   end;
   mpl.cal.aod_523(missing) = -9999;
   plot(serial2doy(odC1.time), odC1.aod523, 'g.', serial2doy(mpl.time(non_missing)), mpl.cal.aod_523(non_missing),'r' ); zoom;
   title(['AOD at 523 nm for period covering MPL data on ', datestr(mean(mpl.time),1),' (DOY=', num2str(doy), ').']);
   axis(v)

pause(0.2);
figure(prof_fig);

   pause(0.2);
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:).*(ones(size(mpl.r.lte_30))*mpl.clean));
   axis('xy'); colormap('jet');zoom
   axis([frac_axis, 0, 25, 0, 25]);
   
   v = axis;
   title(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
   disp(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
   %Pause execution to permit user to zoom into aerosol-free cal region.
   pause;
   figure(prof_fig);
   zoom off;
   cal_v = axis;
   axis([frac_axis,0,25,0,25]);
   title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
   %title(['MPLnor profiles for selected region of ', datestr(mplnor.time(1),1)]);

   mpl.r.cal = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
   %To permit alternate specification of calibration range...
   %keyboard;
   mpl.r.lte_cal = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal))));
   mpl.cal.atten_ray = 10.^(mean(log10(mpl.sonde.atten_ray(mpl.r.cal))));
%    mpl.cal.nor_sonde = mpl.sonde.atten_prof(mpl.r.cal)/mpl.cal.atten_ray;
   mpl.cal.mean_prof(non_missing) = 10.^(mean(real(log10(mpl.prof(mpl.r.cal,(non_missing))))));
   for t = length(mpl.time):-1:1
      mpl.cal.P(t,:) = polyfit(mpl.range(mpl.r.cal), real(log10(mpl.prof(mpl.r.cal,t))),1);
      %test = 10.^(polyval(P(t,:), mean(mpl.range(mpl.r.cal))));
   end
   mpl.cal.mean_prof(missing) = -9999;
   mpl.cal.lowess_mean_prof(non_missing) = lowess(serial2doy(mpl.time(non_missing))-floor(serial2doy(mpl.time((non_missing(1))))), mpl.cal.mean_prof(non_missing), .02)';
   mpl.cal.lowess_mean_prof(missing) = -9999;
   mpl.cal.C(non_missing) = mpl.cal.lowess_mean_prof(non_missing) ./ (mpl.cal.atten_ray .* exp(-2*mpl.cal.aod_523(non_missing)));
   mpl.cal.C(missing) = -9999;
   %       if any(mpl.cal.C(non_missing)<0)
   %          disp('Negative lidar C encountered!');
   %          pause
   %       end

   %figure; plot(serial2Hh(mpl.time), mpl.cal.lowess_mean_prof,'o'); title('smoothed mean profile value at Z_c_a_l');
   %axis([serial2Hh(min(mpl.time)),serial2Hh(max(mpl.time)), 0, max(mpl.cal.lowess_mean_prof)]);zoom
   %figure; plot(serial2Hh(mpl.time), mpl.cal.C,'.c'); title('lidar constant C');
   %axis([serial2Hh(min(mpl.time)),serial2Hh(max(mpl.time)), 0, max(mpl.cal.C)]);zoom

   Sa = 30;
   i = 0;

   klett_fig = figure;

   total = [1:length(mpl.time)];
   missings = setdiff(total, clean_mpl);
   if length(mpl.r.lte_15)<length(mpl.r.lte_cal)
      shorter = mpl.r.lte_15;
      longer = mpl.r.lte_cal;
   else
      shorter = mpl.r.lte_cal;
      longer = mpl.r.lte_15;
   end
   range = mpl.range(shorter);


   %set missings
   mpl.klett.alpha_a(longer,total) = -9999*ones([length(longer),length(total)]);
   mpl.klett.beta_a = mpl.klett.alpha_a;
   mpl.klett.Sa = -9999*ones(size(mpl.time));



   for clear_bin = [clean_mpl]
      figure(klett_fig);
      i = i + 1;
      %         [dump, closest] = min(abs(mpl.time-mplnor.time(clear_bin)));
      %         [mpl.klett.alpha_a(mpl.r.lte_cal,closest), mpl.klett.beta_a(mpl.r.lte_cal,closest), mpl.klett.Sa(closest)] = mpl_autoklett(mpl.range(mpl.r.lte_cal), mpl.prof(mpl.r.lte_cal,closest), mpl.cal.aod_523(closest), mpl.cal.C(closest), mpl.sonde.beta_R(mpl.r.lte_cal), Sa);
      profile = mpl.prof(shorter,clear_bin);
      aod = mpl.cal.aod_523(clear_bin);
      lidar_C = mpl.cal.C(clear_bin);
      beta_m = mpl.sonde.beta_R(shorter);
      subplot(1,2,1); semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_ray(mpl.r.lte_cal), mpl.range(mpl.r.lte_cal), 'r');
      axis([ 1e-2, 1e2, min(range), max(range)])
      [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
      if(mpl.klett.Sa(clear_bin)>(8*pi/3))&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0))
         mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
         mpl.klett.beta_a(shorter,clear_bin) = beta_a;
         Sa = mpl.klett.Sa(clear_bin);
         title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl), mpl.cal.aod_523(clear_bin),Sa,mpl.cal.C(clear_bin)));
      else
         title_str = (sprintf(['Retrieval failure for  #%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),')'],i ,length(clean_mpl)));
         % title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
         Sa = 30;
      end
      subplot(1,2,2); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b');
      axis([0 .2 min(range), max(range) ]);
      subplot(1,2,1);
      title(title_str);
      pause(.5)
   end
   close(klett_fig);
   mpl.klett.Sa(missings) = -9999;
   ext_fig = figure; imagesc(serial2Hh(mpl.time),mpl.range(shorter), mpl.klett.alpha_a(shorter,:)); axis('xy'); colormap('jet');title(['aerosol extinction: ', datestr(mpl.time(1),1)]); zoom;
   axis([v(1), v(2), 0, max(mpl.range(shorter)) 0 1 -.001 .15])
   aod_fig = figure; plot(serial2Hh(mpl.time),mpl.cal.aod_523, 'g.'); axis('xy'); colormap('jet');title(['aod 523nm']); axis([0 24 0 1.1*max(mpl.cal.aod_523)]); zoom;
   lidarC_fig = figure; 
   subplot(2,1,1);
   plot(serial2Hh(mpl.time),mpl.cal.C,'r.'); axis('xy'); colormap('jet');title(['lidar C']); axis([0 24 300 1.1*max(mpl.cal.C)]);
   subplot(2,1,2);
   plot(serial2Hh(mpl.time),mpl.klett.Sa,'r.'); axis('xy'); colormap('jet');title(['Ext to Bscat ratio']); axis([0 24 8 1.1*max(mpl.klett.Sa)]);
   zoom;
   %Then output the results to a file
   fstem = 'mpl102.ext.';
   dstem = datestr(mpl.time(1), 'yyyymmdd.');
   vstem = datestr(now, 'yymmdd');
   %[fname, mpl_ret_pname] = uiputfile([mpl_ret_pname,fstem,dstem,'ver_',vstem,'.cdf']);
   status = write_mpl_ret(mpl,[mpl_ret_pname,fstem,dstem,'v',vstem,'.cdf']);
end
