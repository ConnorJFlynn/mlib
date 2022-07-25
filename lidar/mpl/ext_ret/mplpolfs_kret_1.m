function mpl = mplpolfs_kret_1
% mpl = mplpolfs_kret_1
% Re-writing MPL ext code in order to check RL and AAFPOPS
% This version loads the mat-file output from batch_fsb1todaily 
% Like mpl_kret_3, it is highly interactive, requiring the user to select
% various ranges and to manually cloud screen the profiles. 
% This version attempts a far_range correction of the averaged attenuated 
% profiles prior to the retrieval.

anet_aod = rd_anetaod_v3(getfullname('*.lev*','anet_aod'));
aod_fig = figure_(42); plot(anet_aod.time, anet_aod.AOD_500nm,'*'); dynamicDateTicks; title('AOD vs time')

mpl = load(getfullname('*mpl*.mat','mpl_mat','Select an MPL mat file to process...')); mpl = mpl.polavg;

mpl_ret_pname = ['c:\case_studies\Aerosol_IOP\sgpmplret1flynn.c1\cdf\'];
%[dirlist,pname] = dir_list('D:\datastream\case_studies\Aerosol_IOP\xmfrx_od\joe\nimfr.aot.*');

%Get sonde data for the same time as the MPL file.
[sonde.atten_prof,sonde.tau,sonde.maxalt,sonde.temperature,sonde.pressure] = sonde_std_atm_ray_atten;
[mpl.sonde] = sonde;
[mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature, mpl.sonde.pressure);

% figure; plot(mpl.sonde.maxalt, mpl.sonde.atten_prof,'-' )
% %Check for anet ao data for this time period...

[mina, ainm] = nearest(mpl.time, anet_aod.time);
figure_(aod_fig); plot(anet_aod.time, anet_aod.AOD_500nm,'.k',anet_aod.time(ainm), anet_aod.AOD_500nm(ainm),'go'); dynamicDateTicks
if length(mina)>=1

   %!! 2004-12-04 Adding manual selection of "clear sky" section.  If none
   %provide, then a pre-saved clear sky profile is used.
   prof_fig = figure_(1111);
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_20), mpl.attn_bscat(mpl.r.lte_20,:));
   axis('xy'); colormap('jet');zoom('on');
   axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_20)), max(mpl.range(mpl.r.lte_20)), 0 4 0 4]);
   title('Select a region of clear sky.  Select OK on menu when done zooming or to skip.')
 menu('Select a region of clear sky.  Select OK when done zooming or to skip.','OK')
   figure_(prof_fig);
   if exist('clear_sky2.mat', 'file')
%       keep = input('Press enter again to use this region or type "X" to use a pre-saved Rayleigh profile: ', 's');
      keep = menu('Use this selected region or pre-saved clear sky profile?','This region','Pre-saved');

      if keep<2 % Use mean of selected region for clear_sky
         figure_(prof_fig);
         zoom off;
         title(['Clear sky for ', datestr(mpl.time(1),1)]);
         v = axis;
         pause(.1);
         clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
         mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
         [pileA, pileB] = trimsift_menu(mpl.range(mpl.r.zoom), mpl.attn_bscat(mpl.r.zoom,clear_sky_time));
         clear_sky_time = clear_sky_time(pileA);
         clear_sky = mean(mpl.attn_bscat(:,clear_sky_time)')';
         clear_sky = smooth(mpl.range,clear_sky,20,'moving');
         figure; semilogy(mpl.range(mpl.r.lte_20), clear_sky(mpl.r.lte_20));zoom('on');
         menu('Now zoom to select the region to pin a Rayleigh profile to. Click OK when done', 'OK');
%          pause
         v = axis;
         ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
         [atten_bscat] = std_ray_atten(mpl.range);
         %This really isn't a measured clear sky.  It is a Rayleigh profile pinned
         %to the clear sky measurement.  This is just to generate a plot with high
         %contrast but a known colorscale.
         clear_sky = atten_bscat * (mean(clear_sky(ray_range))/mean(atten_bscat(ray_range)));
         save('clear_sky2.mat', 'clear_sky');
      else
         load('clear_sky2.mat');
      end
   else
      figure_(prof_fig);
      zoom off;
      title(['Clear sky for ', datestr(mpl.time(1),1)]);
      v = axis;
      pause(.1);
      clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
      mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
      [pileA, pileB] = trimsift_menu(mpl.range(mpl.r.zoom), mpl.attn_bscat(mpl.r.zoom,clear_sky_time));
      clear_sky_time = clear_sky_time(pileA);
      clear_sky = mean(mpl.attn_bscat(:,clear_sky_time)')';
      clear_sky = smooth(mpl.range,clear_sky,20,'moving');
      figure; semilogy(mpl.range(mpl.r.lte_20), clear_sky(mpl.r.lte_20));zoom('on');
      title('Now zoom to select the region to pin a Rayleigh profile to...');
      pause
      v = axis;
      ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
      [atten_bscat] = std_ray_atten(mpl.range);
      clear_sky = atten_bscat * (mean(clear_sky(ray_range))/mean(atten_bscat(ray_range)));
      save('clear_sky2.mat', 'clear_sky')
   end
   %!!

   frac_fig = figure_(1111);
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_20), mpl.attn_bscat(mpl.r.lte_20,:)./(clear_sky(mpl.r.lte_20)*ones(size(mpl.time))));
   axis('xy'); colormap('jet');
   title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom('on');
   axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_20)), max(mpl.range(mpl.r.lte_20)), -1 25 -1 25]);
   title('Zoom to select the contiguous time range to use for retrievals.  Select OK on menu when done.')
   menu('Zoom to select the contiguous time range to use for retrievals.  Select OK when done.','OK')
%    pause
   figure_(frac_fig);
   zoom off;
   title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
   frac_axis = axis;
   pause(.5)

   %Logic could really be improved.  

   mpl.t.zoom = (find(serial2Hh(mpl.time)>=frac_axis(1)&serial2Hh(mpl.time)<=frac_axis(2)));
   mpl.r.zoom = find((mpl.range>=frac_axis(3))&(mpl.range<=frac_axis(4)));
   clean_mpl = mpl.t.zoom;
   [pileA, pileB] = trimsift_menu(mpl.range(mpl.r.zoom), mpl.attn_bscat(mpl.r.zoom,clean_mpl)./(clear_sky(mpl.r.zoom)*ones(size(clean_mpl))));

   clean_mpl = clean_mpl(pileA);
   missing = find((mpl.hk.cop_bg<=-9998)&(mpl.hk.cop_bg>=-10000)|isnan(mpl.hk.cop_bg));
   non_missing = setdiff([1:length(mpl.hk.cop_bg)], missing);


   [ainm, mina] = nearest(anet_aod.time, mpl.time);
   %ANET AOD data...
   lin_interp = interp1(serial2doy(anet_aod.time(ainm)), anet_aod.AOD_500nm(ainm)', serial2doy(mpl.time(non_missing)), 'linear', 'extrap');
%    nearest_aod(missing) = -9e-9;
   figure_(aod_fig);
   doy = floor(serial2doy(mean(mpl.time)));
   plot(serial2doy(anet_aod.time), anet_aod.AOD_500nm, 'g.', serial2doy(mpl.time(mina)), anet_aod.AOD_500nm(ainm), 'ro',serial2doy(mpl.time(non_missing)), lin_interp, 'bx'  ); zoom;
   title(['AOD 500 nm for period covering MPL data on ', datestr(mean(mpl.time),1),' (DOY=', num2str(doy), ').']);
   v = axis;
   axis([(doy -.5), (doy + 1.5), v(3), v(4) ]);
   v = axis;
   legend('Native AOD', 'nearest neighbor', 'linear interpolation');
   aot_interp = menu('Select interpolation method: ','<Linear>','Nearest');
   if aot_interp==2
      mpl.mfr.aod_523(non_missing) =interp1(serial2doy(anet_aod.time(ainm)), anet_aod.AOD_500nm(ainm), serial2doy(mpl.time(non_missing)), 'nearest', 'extrap');
   else
      mpl.mfr.aod_523(non_missing) = interp1(serial2doy(anet_aod.time(ainm)), anet_aod.AOD_500nm(ainm), serial2doy(mpl.time(non_missing)), 'linear', 'extrap');
   end;

 figure_(prof_fig)
   mask = nan(size(mpl.attn_bscat(mpl.r.lte_20,:))); mask(:,clean_mpl) = 1;
   pause(0.2);
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_20), mpl.attn_bscat(mpl.r.lte_20,:).*mask);
   axis('xy'); colormap('jet');zoom
   axis([frac_axis, 0, 4, 0, 4]);
   
   v = axis;
   menu(['Zoom in to select an aerosol-free region for calibration.  Hit OK when done.'],'OK');
   
   figure_(prof_fig);
   zoom off;
   cal_v = axis;
   axis([frac_axis,0,4,0,4]);
   title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
   %title(['MPLnor profiles for selected region of ', datestr(mplnor.time(1),1)]);

   mpl.r.cal = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
   %To permit alternate specification of calibration range...
   %keyboard;
   mpl.r.lte_cal = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal))));
   mpl.cal.atten_ray = 10.^(mean(log10(mpl.sonde.atten_prof(mpl.r.cal))));
   mpl.cal.mean_attn_bscat(non_missing) = 10.^(mean(real(log10(mpl.attn_bscat(mpl.r.cal,(non_missing))))));
   mpl.cal.C(non_missing) = mpl.cal.mean_attn_bscat(non_missing) ./ (mpl.cal.atten_ray .* exp(-2*mpl.mfr.aod_523(non_missing)));

   figure_(1114); plot(serial2Hh(mpl.time), mpl.cal.C,'.c'); title('lidar constant C');
   axis([serial2Hh(min(mpl.time)),serial2Hh(max(mpl.time)), 0, max(mpl.cal.C)]);zoom
%  mpl.cal.C(:) = 450; size(mpl.cal.C)
   if sum(mpl.r.lte_15)<length(mpl.r.lte_cal)
      shorter = find(mpl.r.lte_15);
      longer = mpl.r.lte_cal;
   else
      shorter = mpl.r.lte_cal;
      longer = find(mpl.r.lte_15);
   end
   range = mpl.range(shorter);

      Sa = 30;
      Sm = 8*pi/3;
  

   klett_fig = figure_(1115);

   %set missings
   mpl.klett.alpha_a = nan([length(longer),length(mpl.time)]);
   mpl.klett.beta_a = mpl.klett.alpha_a;
   mpl.klett.Sa = NaN(size(mpl.time));
   
   attn_bscat = posify_prof(mpl.attn_bscat(shorter,:));
   i = 0;
   for clear_bin = [clean_mpl]
      figure_(klett_fig);
      i = i + 1;
      profile = attn_bscat(:,clear_bin);
      aod = mpl.mfr.aod_523(clear_bin);
      lidar_C = mpl.cal.C(clear_bin);
      beta_m = interp1(mpl.sonde.maxalt, mpl.sonde.beta_R, mpl.range(shorter),'linear','extrap');
      subplot(1,2,1); 
      semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_prof(mpl.r.lte_cal), mpl.range(mpl.r.lte_cal), 'r');
      axis([ 1e-2, 10, min(range), max(range)]); hold('on')
      [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
      if(mpl.klett.Sa(clear_bin)>(8*pi/3))&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0))
         mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
         mpl.klett.beta_a(shorter,clear_bin) = beta_a;
         Sa = mpl.klett.Sa(clear_bin);
         title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl), mpl.mfr.aod_523(clear_bin),Sa,mpl.cal.C(clear_bin)));
      else
         title_str = (sprintf(['Retrieval failure for  #%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),')'],i ,length(clean_mpl)));
         % title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
         Sa = 30;
      end
      alpha_m = beta_m .* Sa;
      prof_prime = lidar_C.*slant_attenprof(range, semify_prof(alpha_m+alpha_a), semify_prof(beta_m+beta_a));
      subplot(1,2,2); plot((mpl.klett.alpha_a(shorter, clear_bin)),mpl.range(shorter), '.b');
      axis([0 .2 min(range), max(range) ]);
      subplot(1,2,1);
      semilogx(prof_prime, range, 'k-');hold('off')
      title(title_str);
      pause(.1)
   end
%    close(klett_fig);
   ext_fig = figure_(1116); imagesc(serial2Hh(mpl.time),mpl.range(shorter), real(mpl.klett.alpha_a(shorter,:))); axis('xy'); colormap('jet');
   title(['aerosol extinction: ', datestr(mpl.time(1),1)]); zoom('on'); cb = colorbar; set(get(cb,'title'),'string','1/km')
   axis([v(1), v(2), 0, max(mpl.range(shorter)) 0 1 -.001 .1])
   ext2_fig = figure_(1117); imagesc(serial2Hh(mpl.time),mpl.range(shorter), real(log10(mpl.klett.alpha_a(shorter,:)))); axis('xy'); colormap('jet');
   title(['log_1_0(aerosol extinction): ', datestr(mpl.time(1),1)]); zoom;
   axis([v(1), v(2), 0, max(mpl.range(shorter))]); caxis([-3,-.25])
   aod_fig = figure_(aod_fig); plot(serial2Hh(mpl.time),mpl.mfr.aod_523, 'g.');title(['aod 532 nm']); 
   lidarC_fig = figure_(1118); plot(serial2Hh(mpl.time),mpl.cal.C,'r.'); title(['lidar C']);
   Sa_fig = figure_(1119); plot(serial2Hh(mpl.time),mpl.klett.Sa,'*'); title(['Extinction to Backscatter Ratio']);
   %Then output the results to a file
%    status = write_mpl_ret(mpl,[mpl_ret_pname, fname]);
end
return