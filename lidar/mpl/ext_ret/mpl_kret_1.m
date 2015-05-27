% This version of mpl_kret uses mplnor to determine acceptable profiles
close('all'); ncclose('all'); clear
mpl_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplC1.a1\cdf\'];
mplnor_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplnor1campC1.c1\cdf\'];
mpl_ret_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplret1flynn.c1\cdf\'];
sonde_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgplssondeC1\cdf\'];
%[dirlist,pname] = dir_list('D:\datastream\case_studies\Aerosol_IOP\xmfrx_od\joe\nimfr.aot.*');

nimfr_pname = ['D:\datastream\case_studies\Aerosol_IOP\xmfrx_od\joe\'];
nimfr = get_nimfr(nimfr_pname); 
% list = dir([nimfr_pname, 'nimfr.aot.*']);
% nimfr.raw = [];
% for nimfr_file = 1:length(list)
%    nimfr_in = load([nimfr_pname, list(nimfr_file).name], '-ascii');
%    nimfr.raw = [nimfr.raw; nimfr_in];
%    %disp(['loaded ', dirlist(nimfr_file).name]);
% end
% 
% nimfr.time = datenum('00-Jan-2003') + nimfr.raw(:,2);
% nimfr.aod415 = nimfr.raw(:,4);
% nimfr.aod500 = nimfr.raw(:,5);
% nimfr.aod615 = nimfr.raw(:,6);
% nimfr.aod673 = nimfr.raw(:,7);
% nimfr.aod870 = nimfr.raw(:,8);
% %angstrom = -delta(ln tau)/delta(ln wavelength)
% nimfr.angstrom = nimfr.raw(:,9);
% nimfr.aod523 = nimfr.aod500.*((500/523).^nimfr.angstrom);
% nimfr.airmass = 1./nimfr.raw(:,3);
% nimfr = rmfield(nimfr, 'raw');

% figure; plot(serial2doy1(nimfr.time), nimfr.aod415, 'b.',serial2doy1(nimfr.time), nimfr.aod500, 'g.',serial2doy1(nimfr.time), nimfr.aod615, 'y.',serial2doy1(nimfr.time), nimfr.aod673, 'r.',serial2doy1(nimfr.time), nimfr.aod870, 'm.'); title('aot from nimfr')
% legend('415 nm', '500 nm', '615 nm', '673 nm', '870 nm', 0); zoom;
% figure; plot(serial2doy1(nimfr.time), nimfr.angstrom, '.'); zoom; title('angstrom')
nimfr_fig = figure; 
plot(serial2doy1(nimfr.time), nimfr.aod523, 'g.'); zoom; 
title('NIMFR aot 523 nm for entire IOP');

% For each MPLnor file found, check to see if there are any nimfr aod for the time period
% If there are, then read MPLnor to determine clear sky periods.

% [dirlist,pname] = dir_list([mplnor_pname, '*.cdf']);
% for mplnor_file = 1:length(dirlist)
%    fname = dirlist(mplnor_file).name;

   clear mplnor mpl 
   [fname pname] = uigetfile([mplnor_pname, '*.cdf']);
 
   [mplnor_id] = ncmex('open', [mplnor_pname, fname], 'write');
   mplnor.time = nc_time(mplnor_id);
   mplnor.range = nc_getvar(mplnor_id, 'height');
   mplnor.prof = nc_getvar(mplnor_id, 'backscatter');
   mplnor.cloud_mask_2 = nc_getvar(mplnor_id, 'cloud_mask_2');
   ncmex('close', mplnor_id);

   [mplnor] = mplnor_timefill(mplnor);
%This avoids misaligned images due to missing time chunks
   
%    figure; imagesc(serial2Hh(mplnor.time),mplnor.range, mplnor.prof); axis('xy'); colormap('jet');title(['normalized profiles: ', datestr(mplnor.time(1),0)]); zoom;
%    axis([0 24 0 20 0 1 0 1]);
%    title('Zoom into the region of time to use for retrievals.') 
%    pause   
%    v = axis;
   %See if there is any nimfr aot data for this time period...
   nimfr_times = find((serial2doy1(nimfr.time)>=serial2doy1(min(mplnor.time))-1)&(serial2doy1(nimfr.time)<=serial2doy1(max(mplnor.time))+1));
   if max(size(nimfr_times))>1
      
      figure(nimfr_fig); 
      title(['NIMFR aot 523 nm for period covering MPL data on ', datestr(nimfr.time(nimfr_times(1)),1),' (Jd1=', num2str(floor(serial2doy1(nimfr.time(nimfr_times(1))))), ').']);
      axis([floor(serial2doy1(nimfr.time(min(nimfr_times))))-1, ceil(serial2doy1(nimfr.time(max(nimfr_times))))+1, 0.9*min(nimfr.aod523(nimfr_times)), 1.1*max(nimfr.aod523(nimfr_times))]);
%close(nimfr_fig)
      %Find clear_sky periods based on cloud_mask_2.
      cloud_mask_fig = figure; 
      imagesc(serial2Hh(mplnor.time),mplnor.range, mplnor.cloud_mask_2); 
      axis('xy'); colormap('jet');
      title(['filtered cloud mask #2: ', datestr(mplnor.time(1),1)]);
%       axis([0 24 0 20 0 1 0 3])

      prof_fig = figure; 
      imagesc(serial2Hh(mplnor.time),mplnor.range, mplnor.prof); 
      axis('xy'); colormap('jet');
      title(['normalized profiles: ', datestr(mplnor.time(1),0)]); zoom;
      axis([serial2Hh(min(mplnor.time)), serial2Hh(max(mplnor.time)), min(mplnor.range), max(mplnor.range), 0 1 0 1]);
      title('Zoom to select the region of time to use for retrievals.  Hit enter when done.') 
      disp('Zoom to select the region of time to use for retrievals.  Hit enter when done.') 
      pause   
      figure(prof_fig);
      zoom off;
      title(['MPLnor profiles for selected region of ', datestr(mplnor.time(1),1)]);
      v = axis;
      figure(cloud_mask_fig);
      axis([v(1), v(2), v(3), v(4), 0, 1, 0, 3]);
      title(['Filtered cloud mask #2 for selected region of ', datestr(mplnor.time(1),1)]);
      any_clouds_fig = figure; 
      plot(serial2Hh(mplnor.time), any(mplnor.cloud_mask_2), 'bx');
      title('Clear = 0, cloudy (anywhere in column) = 1'); axis([v(1), v(2), -.25 1.25])
      close(cloud_mask_fig)
      figure(prof_fig);
      pause(.5)

      mplnor.t.zoom = (find(serial2Hh(mplnor.time)>=v(1)&serial2Hh(mplnor.time)<=v(2)));
      mplnor.t.cloudy2 = any(mplnor.cloud_mask_2);
      
      clean_nor = find(mplnor.t.cloudy2==0);
% 
%        good_time = find((serial2Hh(mplnor.time)>=14)&(serial2Hh(mplnor.time)<=17))';
%        clean_nor = unique([clean_nor, good_time]);
%        bad_times = find(((serial2Hh(mplnor.time)<14))|(serial2Hh(mplnor.time)>17))';
%        clean_nor = setdiff(clean_nor, bad_times);
      clean_nor = intersect(mplnor.t.zoom, clean_nor);
      
      % The next line redefines clean_nor, essentially ignoring
      % mplnor-detected clouds above
      clean_nor = mplnor.t.zoom;

% The following two lines was used to identify and remove a spike cloud at ~2km
%      cloud_range = find(mplnor.range>.5 & mplnor.range<2.5);
%     clean_nor = mplnor.t.zoom(~any(mplnor.prof(cloud_range,mplnor.t.zoom)>1));
      
      [pileA, pileB] = sift_nolog(mplnor.range, mplnor.prof(:,clean_nor));
      clean_nor = clean_nor(pileA);
    
      %Get a1-level MPL data, correct with MPL_con_nor, downsample
      [mpl,status] = mpl_con_nor([mpl_pname, fname]);
      mpl.t.zoom = find((mpl.time>=mplnor.time(mplnor.t.zoom(1)))&(mpl.time<=mplnor.time(mplnor.t.zoom(end))));
% This lets the data set be limited in time and in range
            %Get sonde data
      [mpl.sonde] = time4sonde(mpl.range, [sonde_pname fname]);
      [mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature, mpl.sonde.pressure);
      
      figure; imagesc(serial2doy1(mpl.time(mpl.t.zoom)),mpl.range, mpl.prof(:,mpl.t.zoom)); axis('xy'); colormap('jet');title(['mpl a1-level profiles: ', datestr(mpl.time(1),0)]); zoom;
      axis([serial2doy1(mpl.time(mpl.t.zoom(1))) serial2doy1(mpl.time(mpl.t.zoom(end))) 0 40 0 1 0 5]);
%      figure; semilogy(mplnor.range, mplnor.prof(:,clean_nor)); zoom      
      %Find pre-averaged MPL data matching up with MPLnor clear sky
%      figure; plot(serial2Hh(mplnor.time), mplnor.t.cloudy2, '*'); axis([0 24 -.5 1.5]) ; title(['clear sky flags: ', num2str(length(clean_nor)),' (0=clear): ', datestr(mplnor.time(1),1)]); zoom;
      %clean_nor = [1:length(mplnor.t.cloudy2)];
      clean_mpl = [];
      for clear_bin = 1:(length(clean_nor)-1)
         [clean_mpl] = [clean_mpl find((mpl.time>mplnor.time(clean_nor(clear_bin)))&(mpl.time<mplnor.time(clean_nor(clear_bin)+1)))];
      end
      [clean_mpl] = [clean_mpl find((mpl.time>mplnor.time(clean_nor(max(clear_bin))-1))&(mpl.time<mplnor.time(clean_nor(max(clear_bin)))))];
      [clean_mpl] = unique(clean_mpl);
      
    % The following two lines was used to identify and remove a spike cloud at ~2km
%     cloud_range = find(mpl.range>.5 & mpl.range<2.5);
%     figure; imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_10), mpl.prof(mpl.r.lte_10,:));axis('xy'); colorbar;
%     clean_mpl = clean_mpl(~any(mpl.prof(cloud_range,clean_mpl)>25));
%    cloud_range = find(mpl.range>.5 & mpl.range<2);
%    figure; imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_10), mpl.prof(mpl.r.lte_10,:));axis('xy'); colorbar;
%    clean_mpl = clean_mpl(~any(mpl.prof(cloud_range,clean_mpl)<.5));
    
      [pileA, pileB] = sift_nolog(mpl.range, mpl.prof(:,clean_mpl));
      clean_mpl = clean_mpl(pileA);

%       [avg] = mpl_timeavg3(mpl,10,clean_mpl);
      [avg] = mpl_timeavg3(mpl,15,clean_mpl);
      %figure; imagesc(serial2Hh(avg.time), mpl.range, avg.nor); axis('xy'); colormap('jet'); zoom
      %axis([0 24 0 40 0 1 0 5])
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
      clear avg
      missing = find((mpl.hk.bg<=-9998)&(mpl.hk.bg>=-10000));
      non_missing = setdiff([1:length(mpl.hk.bg)], missing);
      
      %Nimfr data...
      mpl.mfr.aod_523(non_missing) = interp1(serial2doy0(nimfr.time(nimfr_times))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), nimfr.aod523(nimfr_times), serial2doy0(mpl.time(non_missing))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), 'linear', 'extrap');
%      mpl.mfr.aod_523(non_missing) = interp1(serial2doy0(nimfr.time(nimfr_times))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), nimfr.aod523(nimfr_times), serial2doy0(mpl.time(non_missing))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), 'nearest', 'extrap');
      mpl.mfr.aod_523(missing) = -9999;
      % angstrom = interp1(serial2doy0(mfrod.time(good_od))-145, mfrod.angstrom(good_od), serial2doy0(mpl.time)-145, 'nearest', 'extrap');
      % mpl.mfr.aod_500 = lowess(serial2doy0(mpl.time)-145, aod_500, .02);
      % mpl.mfr.angstrom = lowess(serial2doy0(mpl.time)-145, angstrom, .02);
      % mpl.mfr.aod_523 = mpl.mfr.aod_500 .* ((500/532).^(mpl.mfr.angstrom));

     
      %Pause execution to permit user to zoom into aerosol-free cal region.
      calrange_fig = figure; imagesc(serial2Hh(mpl.time),mpl.range, mpl.prof); 
      axis('xy'); colormap('jet'); zoom;
      axis([v(1), v(2), v(3), v(4), 0, 1, 0, 2]);

      title(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
      disp(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
      pause;
      figure(calrange_fig);
      zoom off;
      cal_v = axis;
      axis(v);
      title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
      %title(['MPLnor profiles for selected region of ', datestr(mplnor.time(1),1)]);

      mpl.r.cal = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
      %To permit alternate specification of calibration range...
      %keyboard; 
      mpl.r.lte_cal = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal))));
      mpl.cal.atten_ray = mean(mpl.sonde.atten_prof(mpl.r.cal));
      mpl.cal.mean_prof(non_missing) = mean(mpl.prof(mpl.r.cal,(non_missing)));
      mpl.cal.mean_prof(missing) = -9999;
      mpl.cal.lowess_mean_prof(non_missing) = lowess(serial2doy0(mpl.time(non_missing))-floor(serial2doy0(mpl.time((non_missing(1))))), mpl.cal.mean_prof(non_missing), .02)';
      mpl.cal.lowess_mean_prof(missing) = -9999;
      mpl.cal.C(non_missing) = mpl.cal.lowess_mean_prof(non_missing) ./ (mpl.cal.atten_ray .* exp(-2*mpl.mfr.aod_523(non_missing))); 
      mpl.cal.C(missing) = -9999;
%       if any(mpl.cal.C(non_missing)<0)
%          disp('Negative lidar C encountered!');
%          pause
%       end
      
      %figure; plot(serial2Hh(mpl.time), mpl.cal.lowess_mean_prof,'o'); title('smoothed mean profile value at Z_c_a_l');
      %axis([serial2Hh(min(mpl.time)),serial2Hh(max(mpl.time)), 0, max(mpl.cal.lowess_mean_prof)]);zoom
      %figure; plot(serial2Hh(mpl.time), mpl.cal.C,'.c'); title('lidar constant C');
      %axis([serial2Hh(min(mpl.time)),serial2Hh(max(mpl.time)), 0, max(mpl.cal.C)]);zoom
      
      %Find post-averaged MPL data matching up with MPLnor clear sky
%       clean_nor = find(mplnor.t.cloudy2==0);
%       clean_nor = intersect(mplnor.t.zoom, clean_nor);
 %     good_time = find(serial2Hh(mplnor.time)>=0)';
 %     clean_nor = unique([clean_nor, good_time]);
 %     bad_times = find(serial2Hh(mplnor.time)<12)';
 %     clean_nor = setdiff(clean_nor, bad_times);

      %clean_nor = [1:length(mplnor.t.cloudy2)];
%Commented out on 10-19-2004 to avoid unnecessary "missing" designations
      clean_mpl = [];
      for clear_bin = 1:(length(clean_nor)-1)
         [clean_mpl] = [clean_mpl find((mpl.time>=mplnor.time(clean_nor(clear_bin)))&(mpl.time<=mplnor.time(clean_nor(clear_bin)+1)))'];
      end
      [clean_mpl] = [clean_mpl find((mpl.time>=mplnor.time(clean_nor(max(clear_bin))-1))&(mpl.time<=mplnor.time(clean_nor(max(clear_bin)))))'];
      [clean_mpl] = unique(clean_mpl); 
      
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
         %         [mpl.klett.alpha_a(mpl.r.lte_cal,closest), mpl.klett.beta_a(mpl.r.lte_cal,closest), mpl.klett.Sa(closest)] = mpl_autoklett(mpl.range(mpl.r.lte_cal), mpl.prof(mpl.r.lte_cal,closest), mpl.mfr.aod_523(closest), mpl.cal.C(closest), mpl.sonde.beta_R(mpl.r.lte_cal), Sa);
         profile = mpl.prof(shorter,clear_bin);
         aod = mpl.mfr.aod_523(clear_bin);
         lidar_C = mpl.cal.C(clear_bin);
         beta_m = mpl.sonde.beta_R(shorter);
         subplot(1,2,1); semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_prof(mpl.r.lte_cal), mpl.range(mpl.r.lte_cal), 'r');
         axis([ 1e-1, 10, min(range), max(range)])
         [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
         if(mpl.klett.Sa(clear_bin)>(8*pi/3))&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0)) 
            mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
            mpl.klett.beta_a(shorter,clear_bin) = beta_a;
            Sa = mpl.klett.Sa(clear_bin);
            title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl), mpl.mfr.aod_523(clear_bin),Sa,mpl.cal.C(clear_bin)));
        else 
            title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
            Sa = 30;
         end
         subplot(1,2,2); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b'); 
         axis([0 .1 min(range), max(range) ]);
         title(title_str);
         pause(1)
      end
      close(klett_fig);

      %      mpl.prof(:,missings) = -9999;
      
      mpl.klett.Sa(missings) = -9999;
%       mpl.cal.C(missings) = -9999;
%       
%       mpl.mfr.aod_523(missings) = -9999;
%       mpl.hk.bg(missings) = -9999;
%       mpl.hk.energyMonitor(missings) = -9999;
      
      ext_fig = figure; imagesc(serial2Hh(mpl.time),mpl.range(shorter), mpl.klett.alpha_a(shorter,:)); axis('xy'); colormap('jet');title(['aerosol extinction: ', datestr(mpl.time(1),1)]); zoom;
      axis([v(1), v(2), 0, max(mpl.range(shorter)) 0 1 -.001 .15])
      aod_fig = figure; plot(serial2Hh(mpl.time),mpl.mfr.aod_523, 'g.'); axis('xy'); colormap('jet');title(['aod 523nm']); axis([0 24 0 1.1*max(mpl.mfr.aod_523)]); zoom;
      lidarC_fig = figure; plot(serial2Hh(mpl.time),mpl.cal.C,'r.'); axis('xy'); colormap('jet');title(['lidar C']); axis([0 24 300 1.1*max(mpl.cal.C)]); zoom;
     %Then output the results to a file 
      status = write_mpl_ret(mpl,[mpl_ret_pname, fname]);
   end

% function nimfr = get_nimfr(nimfr_pname);   
% list = dir([nimfr_pname, 'nimfr.aot.*']);
% nimfr.raw = [];
% for nimfr_file = 1:length(list)
%    nimfr_in = load([nimfr_pname, list(nimfr_file).name], '-ascii');
%    nimfr.raw = [nimfr.raw; nimfr_in];
%    %disp(['loaded ', dirlist(nimfr_file).name]);
% end
% 
% nimfr.time = datenum('00-Jan-2003') + nimfr.raw(:,2);
% nimfr.aod415 = nimfr.raw(:,4);
% nimfr.aod500 = nimfr.raw(:,5);
% nimfr.aod615 = nimfr.raw(:,6);
% nimfr.aod673 = nimfr.raw(:,7);
% nimfr.aod870 = nimfr.raw(:,8);
% %angstrom = -delta(ln tau)/delta(ln wavelength)
% nimfr.angstrom = nimfr.raw(:,9);
% nimfr.aod523 = nimfr.aod500.*((500/523).^nimfr.angstrom);
% nimfr.airmass = 1./nimfr.raw(:,3);
% nimfr = rmfield(nimfr, 'raw');
% return