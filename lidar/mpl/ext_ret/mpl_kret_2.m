% This version does not use mplnor at all.
close('all'); ncclose('all'); clear
mpl_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplC1.a1\cdf\'];
mplnor_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplnor1campC1.c1\cdf\'];
mpl_ret_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgpmplret1flynn.c1\cdf\'];
sonde_pname = ['D:\datastream\case_studies\Aerosol_IOP\sgplssondeC1\cdf\'];
%[dirlist,pname] = dir_list('D:\datastream\case_studies\Aerosol_IOP\xmfrx_od\joe\nimfr.aot.*');

nimfr_pname = ['D:\datastream\case_studies\Aerosol_IOP\xmfrx_od\joe\'];
nimfr = get_nimfr(nimfr_pname); 
nimfr_fig = figure; 
plot(serial2doy0(nimfr.time), nimfr.aod523, 'g.'); zoom; 
title('NIMFR aot 523 nm for entire IOP');

% For each MPL file found, check to see if there are any nimfr aod for the time period
% If there are, then proceed

% [dirlist,pname] = dir_list([mpl_pname, '*.cdf']);
% for mpl_file = 1:length(dirlist)
%    fname = dirlist(mpl_file).name;

   clear mpl 
   [fname pname] = uigetfile([mpl_pname, '*.cdf']);
   [mpl,status] = mpl_con_nor([pname, fname]);
   
   %Get sonde data
      [mpl.sonde] = time4sonde(mpl.range, [sonde_pname fname]);
      [mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature, mpl.sonde.pressure);
      
   %[mplnor] = mplnor_timefill(mplnor);

   %See if there is any nimfr aot data for this time period...
   nimfr_times = find((serial2doy0(nimfr.time)>=serial2doy0(min(mpl.time))-1)&(serial2doy0(nimfr.time)<=serial2doy0(max(mpl.time))+1));
   if max(size(nimfr_times))>1
      
      figure(nimfr_fig); 
      title(['NIMFR aot 523 nm for period covering MPL data on ', datestr(nimfr.time(nimfr_times(1)),1),' (DOY=', num2str(floor(serial2doy0(nimfr.time(nimfr_times(1))))), ').']);
      axis([floor(serial2doy0(nimfr.time(min(nimfr_times))))-1, ceil(serial2doy0(nimfr.time(max(nimfr_times))))+1, 0.9*min(nimfr.aod523(nimfr_times)), 1.1*max(nimfr.aod523(nimfr_times))]);
%       close(nimfr_fig)
      prof_fig = figure; 
      imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:)); 
      axis('xy'); colormap('jet');
      title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom;
      axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30)), 0 4 0 4]);
      title('Zoom to select the region of time to use for retrievals.  Hit enter when done.') 
      disp('Zoom to select the region of time to use for retrievals.  Hit enter when done.') 
      figure(prof_fig);
      pause   
      figure(prof_fig);
      zoom off;
      title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
      v = axis;
      pause(.5)

      mpl.t.zoom = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
      mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
      clean_mpl = mpl.t.zoom;
      [pileA, pileB] = sift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clean_mpl));
      
      clean_mpl = clean_mpl(pileA);
      old_clean_mpl = clean_mpl;
      clean_times = mpl.time(clean_mpl);

      %     The following two lines were used to identify and remove a spike cloud at ~2km
%     cloud_range = find(mpl.range>.5 & mpl.range<2.5);
%     clean_mpl = clean_mpl(~any(mpl.prof(cloud_range,clean_mpl)>25));
    
      [avg] = mpl_timeavg3(mpl,15,clean_mpl);
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
      
      
      %Nimfr data...
      mpl.mfr.aod_523(non_missing) = interp1(serial2doy0(nimfr.time(nimfr_times))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), nimfr.aod523(nimfr_times), serial2doy0(mpl.time(non_missing))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), 'linear', 'extrap');
%      mpl.mfr.aod_523(non_missing) = interp1(serial2doy0(nimfr.time(nimfr_times))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), nimfr.aod523(nimfr_times), serial2doy0(mpl.time(non_missing))-floor(serial2doy0(nimfr.time(nimfr_times(1)))), 'nearest', 'extrap');
      mpl.mfr.aod_523(missing) = -9999;
      % angstrom = interp1(serial2doy0(mfrod.time(good_od))-145, mfrod.angstrom(good_od), serial2doy0(mpl.time)-145, 'nearest', 'extrap');
      % mpl.mfr.aod_500 = lowess(serial2doy0(mpl.time)-145, aod_500, .02);
      % mpl.mfr.angstrom = lowess(serial2doy0(mpl.time)-145, angstrom, .02);
      % mpl.mfr.aod_523 = mpl.mfr.aod_500 .* ((500/532).^(mpl.mfr.angstrom));
     
      %Pause execution to permit user to zoom into aerosol-free cal region.
      calrange_fig = figure; imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:) .* (ones([size(mpl.r.lte_30)])*mpl.clean)); 
      axis('xy'); colormap('jet'); zoom;
      axis([v(1), v(2), v(3), v(4), 0, 3, 0, 3]);

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