% [AATS, lidar] = ALIVE_AATS_MPL_plots
% Starting with ALIVE_plots (now ALIVE_AATS_MPL_plots)
% 0. get AOD from alive_aod.mat, use mfrC1
% 1. step through AATS profiles,
% 2. find nearest MPL file,
% 3. get comparable AOD from alive_aod.mat, mfrC1
% 4. Correct MPL profile
% 5. Determine calibration factor
% 6. Retrieve ext and Sa
function [AATS, lidar] = ALIVE_AATS_MPL_plots
%creates ALIVE multiframe plots of aerosol profiles
%compares with MPL
load('C:\matlib\alive_aod.mat')
clear rss
load('odC1.mat'); %This was being used in alive004_kret_N.m
% Appears to be the same aod values but with different cloud screen
% applied.
aod523C1 = mfrC1_filtered.vars.aerosol_optical_depth_filter2.data .*((500/523) .^ mfrC1_filtered.vars.angstrom_exponent.data);
% odC1.aod523 = odC1.vars.aerosol_optical_depth_filter2.data .*((500/523) .^ odC1.vars.angstrom_exponent.data);
all_aats = get_aats_aod;
lidar.type = 'MPL';
MPL = 'Yes';

lidar.Latitude_SGP=36.6;    %SGP
lidar.Longitude_SGP=-97.48;  %SGP
product='aod_profile';
lidar.product = product;
% AOD profile produced by ext_profile_ave.m

lidar.zmax=8.00; %max altitude for binning [km]
lidar.bw=0.020; %bin width for AATS-14
% if strcmp(lidar.type,'MPL')
lidar.zmax=8.010; %max altitude for binning [km]
lidar.bw=0.030; %bin width for MPL
lidar.ext_all=[];
lidar.aod_all=[];
% end

%empty arrays
AATS.dist_all=[];
AATS.ext519_all=[];
AATS.ext519_Error_all=[];
AATS.AOD519_all=[];
AATS.AOD_Error519_all=[];

%read all AATS-14 extinction profile names in directory
if strcmp(product,'aod_profile')
   pathname='C:\case_studies\Alive\data\schmid-aats\atts.01-Mar-2006\Ver2\';
   direc=dir(fullfile(pathname,'*p.asc'));
   [filelist{1:length(direc),1}] = deal(direc.name);
   filelist(25:28,:)=[]; % delete profiles not over SGP
end

nprofiles=length(filelist);

%for jprof=1:30
for jprof=1:nprofiles;
%    close('all')
   filename=char(filelist(jprof,:));
   disp(sprintf('Processing %s (No. %i of %i)',filename,jprof,nprofiles))
   
   %determine date and flight number from filename
   flt_no=filename(1:5);
   
   % read AATS-14 profile
   fid=fopen(deblank([pathname,filename]));
   fgetl(fid);
   AATS.file_date=fscanf(fid,'ALIVE%g/%g/%g');     %get date
   AATS.month=AATS.file_date(1);
   AATS.day=AATS.file_date(2);
   AATS.year=AATS.file_date(3);
   fgetl(fid);
   version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1]);
   for i=1:10
      fgetl(fid);
   end
   lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
   fgetl(fid);
   fgetl(fid);
   if strcmp(product,'aod_profile')
      data=fscanf(fid,'%g',[64,inf]);
      fclose(fid);
      AATS.UT=data(1,:);
      AATS.Latitude=data(2,:);
      AATS.Longitude=data(3,:);
      AATS.GPS_Altitude=data(4,:);
      AATS.Pressure_Altitude=data(5,:);
      AATS.Pressure=data(6,:);
      AATS.AOD=data(7:19,:);
      AATS.AOD_Error=data(20:32,:);
      AATS.gamma=-data(33,:);
      AATS.alpha=-data(34,:);
      AATS.a0=data(35,:);
      AATS.Extinction=data(36:48,:);
      AATS.Extinction_Error=data(49:61,:);
      AATS.gamma_ext=-data(62,:);
      AATS.alpha_ext=-data(63,:);
      AATS.a0_ext=data(64,:);
      %         clear dist;
      %         for L = length(Latitude):-1:1
      %             dist(L) = geodist(Latitude(L),Longitude(L),lidar.Latitude_SGP,lidar.Longitude_SGP)/1000;
      %         end
      AATS.dist = geodist2(AATS.Latitude,AATS.Longitude,lidar.Latitude_SGP,lidar.Longitude_SGP)/1000;
      %         dist = dist';
      %         dist=deg2km(distance(Latitude,Longitude,lidar.Latitude_SGP,lidar.Longitude_SGP));
      %bin data in altitude for the AATS-14 wavelengths I need which are 353 nm and 519 nm
      [ResMat]    = binning([AATS.GPS_Altitude',AATS.Extinction( 1,:)'],lidar.bw,0,lidar.zmax);
      AATS.Altitude    = ResMat(:,1);
      
      [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction( 5,:)'],lidar.bw,0,lidar.zmax);
      AATS.ext519 = ResMat(:,2);
      [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction_Error( 5,:)'],lidar.bw,0,lidar.zmax);
      AATS.ext519_Error = ResMat(:,2);
      [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction_Error( 5,:)'],lidar.bw,0,lidar.zmax);
      AATS.AOD519 = ResMat(:,2);
      [ResMat]  =binning([AATS.GPS_Altitude',AATS.AOD_Error( 5,:)'],lidar.bw,0,lidar.zmax);
      AATS.AOD_Error519 = ResMat(:,2);
      
      [ResMat]  =binning([AATS.GPS_Altitude',AATS.dist'],lidar.bw,0,lidar.zmax);
      AATS.dist_bin = ResMat(:,2);
      
      clear ResMat;
      
      %find bottom and top AATS.Extinction_Error
      ii_AATS=~isnan(AATS.ext519);
      i_bot_AATS=min(find(ii_AATS==1));
      i_top_AATS=max(find(ii_AATS==1));
      
      %accumulate data
      AATS.ext519_all=[AATS.ext519_all; AATS.ext519'];
      AATS.ext519_Error_all=[AATS.ext519_Error_all; AATS.ext519_Error'];
      AATS.AOD519_all=[AATS.AOD519_all; AATS.AOD519'];
      AATS.AOD_Error519_all=[AATS.AOD_Error519_all; AATS.AOD_Error519'];
      AATS.dist_all=[AATS.dist_all; AATS.dist_bin'];
   end
   
   AATS.time = datenum([AATS.year.*ones(size(AATS.UT')),AATS.month.*ones(size(AATS.UT')),AATS.day.*ones(size(AATS.UT')), AATS.UT',0.*ones(size(AATS.UT')),0.*ones(size(AATS.UT'))])';
   AATS.UT_start =min(AATS.UT);
   AATS.time_start = datenum([AATS.year,AATS.month,AATS.day, AATS.UT_start, 0,0]);
   AATS.UT_end=max(AATS.UT);
   AATS.time_end = datenum([AATS.year,AATS.month,AATS.day, AATS.UT_end, 0,0]);
   
   %plots
   AATS.hour_start=floor(AATS.UT_start);
   AATS.hour_end=floor(AATS.UT_end);
   AATS.min_start=round((AATS.UT_start-floor(AATS.UT_start))*60);
   AATS.min_end=round((AATS.UT_end-floor(AATS.UT_end))*60);
   
   col=mod(jprof-1,5);
   row=mod(fix((jprof-1)/5),6);
   
   
   tmp = ones(size(AATS.UT'));
   V = [AATS.year.*tmp,AATS.month.*tmp,AATS.day.*tmp,AATS.UT',0.*tmp, 0.*tmp];
   clear tmp;
   AATS.time = datenum(V)';
   %     if strcmp(lidar.type,'MPL')
   mpl_pname = ['C:\case_studies\Alive\data\sgpmplC1.a1\'];
   % load MPL file
   mpl_file = dir([mpl_pname,'*.',datestr(AATS.time(1),'yyyymmdd'),'*.cdf']);
   % apply corrections
   mpl = mpl004_alive([mpl_pname, mpl_file(1).name]);
   %        mpl = rmfield(mpl,'rawcts');
   %        mpl = rmfield(mpl,'noise_MHz');
   
   % sift mpl profiles spanning AATS profile duration
   %load MPL data
   % a1 data is here: C:\case_studies\Alive\data\sgpmplC1.a1
   %         [lidar.z,lidar.UT,lidar.aot,lidar.ext]=read_MPLARM_ALIVE('C:\case_studies\Alive\data\flynn-mpl-102\2007_03_05\ext\',0.319,AATS.day,AATS.month,AATS.year);
   % ii = interp1(serial2Hh(mpl.time), [1:length(mpl.time)],AATS.UT_start+4/60,'nearest','extrap');
   % jj = interp1(serial2Hh(mpl.time), [1:length(mpl.time)],AATS.UT_end-4/60,'nearest','extrap');
   ii = interp1(serial2Hh(mpl.time), [1:length(mpl.time)],AATS.UT_start,'nearest','extrap');
   jj = interp1(serial2Hh(mpl.time), [1:length(mpl.time)],AATS.UT_end,'nearest','extrap');
   
   mfr_ii = interp1(mfrC1_filtered.time, [1:length(mfrC1_filtered.time)],AATS.time_start,'nearest','extrap');
   mfr_jj = interp1(mfrC1_filtered.time, [1:length(mfrC1_filtered.time)],AATS.time_end,'nearest','extrap');
   
   nprof=jj-ii+1;
   mpl = cutmpl(mpl,[ii:jj]);
   if exist('clear_sky004.mat', 'file')
      load('clear_sky004.mat');
   end
   frac_fig = figure(1);
   if length(clear_sky)<(mpl.r.lte_30(end))
      len_cls = length(clear_sky);
      clear_sky(len_cls+1:mpl.r.lte_30(end)) = clear_sky(len_cls);
   end
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:)./(clear_sky(mpl.r.lte_30)*ones(size(mpl.time))));
   axis('xy'); colormap('jet');
   title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom;
   axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_15)), max(mpl.range(mpl.r.lte_15))]);
   caxis([0,5]);
   title('Zoom to select the region to use for retrievals.  Hit enter when done.')
   disp('Zoom to select the region to use for retrievals.  Hit enter when done.')
   ylim([0,10]);
   pause(0.25);
   %     figure(frac_fig);
   %     zoom off;
   %     title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
   frac_axis = axis;
   %     pause(.5)
   
   mpl.t.zoom = (find(serial2Hh(mpl.time)>=frac_axis(1)&serial2Hh(mpl.time)<=frac_axis(2)));
   mpl.r.zoom = find((mpl.range>=frac_axis(3))&(mpl.range<=frac_axis(4)));
   clean_mpl = mpl.t.zoom;
   [pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clean_mpl)./(clear_sky(mpl.r.zoom)*ones(size(clean_mpl))));
   disp(' ')
   disp('Now computing averages of cleaned profiles.')
   clean_mpl = clean_mpl(pileA);
   
   %     mpl.clean = true(size(mpl.time));
   [avg] = mpl_timeavg3(mpl,4,clean_mpl);
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
   mpl.clean = avg.clean; % this is a clean/not clean flag determined while averaging
   clear avg
   missing = find((mpl.hk.bg<=-9998)&(mpl.hk.bg>=-10000));
   non_missing = setdiff([1:length(mpl.hk.bg)], missing);
   clean_mpl = find(mpl.clean);
   %     Calibration versus Rayleigh
   pause(0.2);
   prof_fig = figure(3);
   
   pause(0.2);
   imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_15), mpl.prof(mpl.r.lte_15,:).*(ones(size(mpl.r.lte_15))*mpl.clean));
   axis('xy'); colormap('jet');zoom
   axis([frac_axis, 0, 5, 0, 5]);
   
   v = axis;
   title(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
   disp(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
   %Pause execution to permit user to zoom into aerosol-free cal region.
   pause(.1);
   figure(prof_fig);
   zoom off;
   cal_v = axis;
   cal_v(3) = 7; cal_v(4) = 9;
   axis([frac_axis,0,5,0,5]);
   title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
   mpl.r.cal = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
   
   
   % Now MPL contains only profiles during the AATS flight
   % Sift these profiles to reject bad or cloud contaminated profiles
   %       [pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.lte_15),
   %       mpl.prof(mpl.r.lte_15,:));
   % Now use the mean of these, the mean AOD, and a Rayleigh profile to
   % determine calibration.
   % Then try retrieving the extinction profiles for each lidar profile
   % Take the mean of these, and compare to the extintion profile from
   % the mean
   
   % Now generate lidar calibration:
   % compute mean of MFRSR AOD and Ang, 1 and 2
   %
   mpl.r.cal= mpl.range>=cal_v(3) & mpl.range<=cal_v(4);
   mpl.r.lte_cal = (mpl.range>.1)&(mpl.range<=cal_v(4));
   mpl.cal.atten_ray = 10.^(mean(log10(mpl.sonde.atten_ray(mpl.r.cal))));
   %    mpl.cal.nor_sonde = mpl.sonde.atten_prof(mpl.r.cal)/mpl.cal.atten_ray;
   mpl.cal.mean_prof = mean(10.^(mean(real(log10(mpl.prof(mpl.r.cal,clean_mpl))))));
   mpl.cal.mean_em = mean(mpl.hk.energy_monitor(clean_mpl));
   mpl.cal.aod_523 = mean(aod523C1(mfr_ii:mfr_jj));
   mpl.cal.C = mpl.cal.mean_prof ./ ...
      (mpl.cal.mean_em.* mpl.cal.atten_ray .* exp(-2.*mpl.cal.aod_523));
   
   %!!
   klett_fig = figure(4);
   total = [1:length(mpl.time)];
   mpl.r.lte_15 = mpl.range>=min(mpl.range(mpl.r.lte_15))&mpl.range<=max(mpl.range(mpl.r.lte_15));
   mpl.r.lte_cal = mpl.range >= min(mpl.range(mpl.r.lte_cal)) & mpl.range<=max(mpl.range(mpl.r.lte_cal));
   if sum(mpl.r.lte_15)<sum(mpl.r.lte_cal)
      shorter = mpl.r.lte_15;
      longer = mpl.r.lte_cal;
   else
      shorter = mpl.r.lte_cal;
      longer = mpl.r.lte_15;
   end
   beta_m = mpl.sonde.beta_R(shorter);
   Sa = 30;
   range = mpl.range(shorter);
   
   %set missings
   mpl.klett.alpha_a = -9999*ones([sum(longer),length(total)]);
   mpl.klett.beta_a = mpl.klett.alpha_a;
   mpl.klett.Sa = -9999*ones(size(mpl.time));
   mpl.klett.aod_523nm = mpl.klett.Sa;
%    missings = setdiff(total, clean_mpl);
   clean_mpl = find(mpl.clean & ~isnan(mpl.cal.aod_523));
   
   
   i = 0;
   lidar_C = mpl.cal.C;
   for clear_bin = [clean_mpl]
      figure(klett_fig);
      i = i + 1;
      %         [dump, closest] = min(abs(mpl.time-mplnor.time(clear_bin)));
      %         [mpl.klett.alpha_a(mpl.r.lte_cal,closest), mpl.klett.beta_a(mpl.r.lte_cal,closest), mpl.klett.Sa(closest)] = mpl_autoklett(mpl.range(mpl.r.lte_cal), mpl.prof(mpl.r.lte_cal,closest), mpl.cal.aod_523(closest), mpl.cal.C(closest), mpl.sonde.beta_R(mpl.r.lte_cal), Sa);
      profile = mpl.prof(shorter,clear_bin)./mpl.cal.mean_em;
      %         aod = mpl.cal.aod_523(clear_bin);
      if ~isempty(mfr_ii)&&~isempty(mfr_jj)&&(mfr_jj>mfr_ii)
         aod = interp1(mfrC1_filtered.time(mfr_ii:mfr_jj), aod523C1(mfr_ii:mfr_jj), mpl.time(clear_bin),'linear','extrap');
      else
         aod = aod523C1(mfr_jj);
      end
      mpl.klett.aod_523nm(clear_bin) = aod;
      %         lidar_C = mpl.cal.C(clear_bin);
      subplot(1,2,1); semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_ray(mpl.r.lte_cal), mpl.range(mpl.r.lte_cal), 'r');
      axis([ .01, 10, min(range), max(range)])
      [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
      if(mpl.klett.Sa(clear_bin)>(8*pi/3))&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0))
         mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
         mpl.klett.beta_a(shorter,clear_bin) = beta_a;
         Sa = mpl.klett.Sa(clear_bin);
         title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl), aod,Sa,mpl.cal.C));
      else
         title_str = (sprintf(['Retrieval failure for  #%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),')'],i ,length(clean_mpl)));
         % title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
         Sa = 30;
      end
      subplot(1,2,2); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b');
      grid('on');
      axis([-0.1 .2 min(range), max(range) ]);
      tl = title(title_str);
      set(tl,'FontName','Tahoma','FontWeight','bold','Position',[-0.133    9.25   17.3205]);
      subplot(1,2,1);

      pause(.5)
   end
   
   mpl_ret_pname = ['C:\case_studies\Alive\data\sgpmplC1.a1\ext\May2009\'];
   fstem = 'mpl004.ext.';
   dstem = datestr(mpl.time(1), 'yyyymmdd.');
   vstem = datestr(now, 'yyyymmdd');
   %[fname, mpl_ret_pname] = uiputfile([mpl_ret_pname,fstem,dstem,'ver_',vstem,'.cdf']);
   [status,mpl_ext] = write_mpl_ret(mpl,[mpl_ret_pname,fstem,dstem,'v',vstem,'.cdf']);
   
   lidar.UT=serial2Hh(mpl.time(clean_mpl));
   lidar.z = mpl_ext.vars.range.data' + 0.319;
%disp(z');

   lidar.ext=mpl.klett.alpha_a(:,clean_mpl)';
   lidar.aot=mpl.klett.aod_523nm(clean_mpl); 

%remove profiles that have only values less or equal 0
% lidar.ext(isnan(lidar.ext)) = -9999;
% ii=find(all(lidar.ext<=0,2)==1);
% lidar.ext(ii,:)=[];
% lidar.UT(ii)=[];
% lidar.aot(ii)=[];
%    [lidar.z,lidar.UT,lidar.aot,lidar.ext]=read_MPLARM_ALIVE([mpl_ret_pname,0.319,AATS.day,AATS.month,AATS.year);
   lidar.hour_start=floor(lidar.UT(1));
   lidar.hour_end=floor(lidar.UT(end));
   lidar.min_start=round((lidar.UT(1)-floor(lidar.UT(1)))*60);
   lidar.min_end=round((lidar.UT(end)-floor(lidar.UT(end)))*60);
   
   kk=find(lidar.ext(1,:)~=-9999); %remove altitudes with invalid retrievals
   lidar.ext=mean(lidar.ext(:,kk),1);
   lidar.z=lidar.z(kk)';
   lidar.aot=mean(lidar.aot(:));
   
   lidar.AOD=cumtrapz(lidar.z,lidar.ext);
   lidar.AOD=-lidar.AOD+lidar.AOD(end);
   
   %binning
   [ResMat]=binning([lidar.z,lidar.ext'],lidar.bw,0,lidar.zmax);
   ext_bin= ResMat(:,2);
   [ResMat]=binning([lidar.z,lidar.AOD'],lidar.bw,0,lidar.zmax);
   AOD_bin= ResMat(:,2);
   %accumulate data
   lidar.ext_all=[lidar.ext_all; ext_bin'];
   lidar.aod_all=[lidar.aod_all; AOD_bin'];
   
   %MPL and AATS AOD at min and max AATS altitudes
   ii_mpl=find(isnan(AOD_bin)==0);
   if isempty(ii_mpl)
      lidar.AOD_AATS_bot(jprof)=NaN;
      lidar.AOD_AATS_top(jprof)=NaN;
   else
      lidar.AOD_AATS_bot(jprof)=interp1(AATS.Altitude(ii_mpl),AOD_bin(ii_mpl),AATS.Altitude(i_bot_AATS),'nearest','extrap');
      lidar.AOD_AATS_top(jprof)=interp1(AATS.Altitude(ii_mpl),AOD_bin(ii_mpl),AATS.Altitude(i_top_AATS));
   end
   
   AATS.AOD519_mpl_bot(jprof)=AATS.AOD519(i_bot_AATS);
   AATS.AOD_Error519_mpl_bot(jprof)=AATS.AOD_Error519(i_bot_AATS);
   AATS.AOD519_mpl_top(jprof)=AATS.AOD519(i_top_AATS);
   AATS.AOD_Error519_mpl_top(jprof)=AATS.AOD_Error519(i_top_AATS);
   
   % plot AOD profile
   figure(98)
   set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
   plot(AATS.AOD(5,:), AATS.GPS_Altitude,'-bo')
   hold on
   plot(lidar.AOD,lidar.z,'g.-');
   plot(lidar.aot,0.319,'ro','MarkerFaceColor','r')
   hold off
   legend('AATS','MPL','MFR AOD')
   set(gca,'ylim',[0 8]);
   set(gca,'xlim',[0 0.25]);
   set(gca,'TickLength',[.03 .03]);
   set(gca,'xtick',0:0.05:0.250);
   set(gca,'ytick',0:8);
   titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
   titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
   titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i profiles\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,length(clean_mpl));
   V_mfr_ii = datevec(mfrC1_filtered.time(mfr_ii));
   V_mfr_jj = datevec(mfrC1_filtered.time(mfr_jj));
   titlestr4=sprintf('%02d:%02d-%02d:%02d UT %i points\n',V_mfr_ii(4),V_mfr_ii(5),V_mfr_jj(4),V_mfr_jj(5),1+mfr_jj-mfr_ii);
   text(.08,6.8,titlestr1,'FontName','Tahoma','color','k','FontSize',10);
   text(.08,6.3,titlestr2,'FontName','Tahoma','color','b','FontSize',10);
   text(.08,5.8,titlestr3,'FontName','Tahoma','color','g','FontSize',10);
   text(.08,5.3,titlestr4,'FontName','Tahoma','color','r','FontSize',10);
   titlestr5 = sprintf('lidar C = %2.1f, Sa = %2.1f \n',lidar_C, mean(mpl.klett.Sa(clean_mpl)));
   text(.08,4.8,titlestr5,'FontName','Tahoma','color','g','FontSize',10);

   
   figure(100);
   sb(1) = subplot(2,1,1);
   od_ii = find(odC1.time == mfrC1_filtered.time(mfr_ii));
   od_ii_0 = floor(odC1.time(od_ii));
   mfr_ii_0 = floor(mfrC1_filtered.time(mfr_ii));
   plot(24.*(odC1.time - od_ii_0), odC1.vars.aerosol_optical_depth_filter2.data, 'k.', ...
      24.*(mfrC1_filtered.time-mfr_ii_0), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data,'ko',...
     serial2Hh(mfrC1_filtered.time(mfr_ii:mfr_jj)), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfr_ii:mfr_jj),'g.',...
serial2Hh(mfrC1_filtered.time(mfr_ii:mfr_jj)),aod523C1(mfr_ii:mfr_jj), 'gx');
legend('500 nm, all','500 nm, screened','500 nm, ii to jj','523 nm');
   sb(2) = subplot(2,1,2);
   mfr_ii_0 = floor(mfrC1_filtered.time(mfr_ii));
   plot(24.*(mfrC1_filtered.time-mfr_ii_0), mfrC1_filtered.vars.angstrom_exponent.data,'ko',...
     serial2Hh(mfrC1_filtered.time(mfr_ii:mfr_jj)), mfrC1_filtered.vars.angstrom_exponent.data(mfr_ii:mfr_jj),'g.');
  legend('angstrom exp')
linkaxes(sb,'x')
   
   figure(5)
   set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
   subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
   plot(AATS.AOD(5,:), AATS.GPS_Altitude,'-bo')
   hold on
   plot(lidar.AOD,lidar.z,'g.-');
   plot(lidar.aot,0.319,'ro','MarkerFaceColor','r')
   hold off
   set(gca,'ylim',[0 8]);
   set(gca,'xlim',[0 0.25]);
   set(gca,'TickLength',[.03 .03]);
   set(gca,'xtick',0:0.05:0.250);
   set(gca,'ytick',0:8);
   titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
   titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
   titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
   text(.08,6.8,titlestr1,'FontSize',8);
   text(.08,6.2,titlestr2,'FontSize',8);
   text(.08,5.4,titlestr3,'FontSize',8);
   
   %axis labels and titles
   if col>=1, set(gca,'YTickLabel',[]); end
   if row<5, set(gca,'XTickLabel',[]); end
   if row==5 && col==2
      h22=text(0.0,-2,'AOD');
      set(h22,'FontSize',12)
   end
   if col==0 && row==3
      h33=text(-0.07,5,'Altitude [km]');
      set(h33,'FontSize',12,'Rotation',90)
   end
   
   % plot extinction profile
   figure(99)
   set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
     plot(lidar.ext,lidar.z,'g.-',AATS.Extinction(5,:),AATS.GPS_Altitude,'b.-')
   set(gca,'ylim',[0 8]);
   set(gca,'xlim',[0 0.200]);
   set(gca,'TickLength',[.03 .03]);
   set(gca,'xtick',0:0.05:0.200);
   set(gca,'ytick',0:8);
      legend('MPL','AATS')
   titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
   titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
   titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i profiles\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,length(clean_mpl));
   text(.08,6.8,titlestr1,'FontName','Tahoma','color','k','FontSize',10);
   text(.08,6.3,titlestr2,'FontName','Tahoma','color','b','FontSize',10);
   text(.08,5.8,titlestr3,'FontName','Tahoma','color','g','FontSize',10);
   titlestr4 = sprintf('lidar C = %2.1f, Sa = %2.1f \n',lidar_C, mean(mpl.klett.Sa(clean_mpl)));
   text(.08,5.3,titlestr4,'FontName','Tahoma','color','g','FontSize',10);
   
   figure(6)
   set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
   subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
   %plot(lidar.ext(ii:jj,:),lidar.z,'g.-',Extinction(5,:),AATS.GPS_Altitude,'b.-')
   plot(lidar.ext,lidar.z,'g.-',AATS.Extinction(5,:),AATS.GPS_Altitude,'b.-')
   set(gca,'ylim',[0 8]);
   set(gca,'xlim',[0 0.200]);
   set(gca,'TickLength',[.03 .03]);
   set(gca,'xtick',0:0.05:0.200);
   set(gca,'ytick',0:8);
   titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
   titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
   titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
   text(.08,6.8,titlestr1,'FontSize',8);
   text(.08,6.2,titlestr2,'FontSize',8);
   text(.08,5.4,titlestr3,'FontSize',8);
   
   %axis labels and titles
   if col>=1, set(gca,'YTickLabel',[]); end
   if row<5, set(gca,'XTickLabel',[]); end
   if row==5 && col==2
      h22=text(0.0,-2,'Extinction [km^-^1]');
      set(h22,'FontSize',12)
   end
   if col==0 && row==3
      h33=text(-0.07,5,'Altitude [km]');
      set(h33,'FontSize',12,'Rotation',90)
   end
   %        end
end
%Overall comparisons

%compare AATS and MPL exinction at 519/523 nm
if strcmp(lidar.type,'MPL')
   figure(7)
   x=AATS.ext519_all;
   y=lidar.ext_all;
   ii=find(AATS.dist_all<=30); % remove points beyond 30 km
   x=x(ii); y=y(ii);
   ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
   x=x(ii); y=y(ii);
   plot(x,y,'.')
   hold on
   n=length(x);
   rmsd=(sum((x-y).^2)/(n-1))^0.5;
   bias=mean(y-x);
   range=[-0.01 0.2];
   plot(range,range,'k');
   set(gca,'ylim',range);
   set(gca,'xlim',range);
   xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
   ylabel('Extinction [km^-^1]: MPL','FontSize',14)
   axis square
   set(gca,'FontSize',14)
   set(gca,'xtick',0:.05:0.2);
   set(gca,'ytick',0:.05:0.2);
   
   [my,by,ry,smy,sby]=lsqfity(x,y);
   disp([my,by,ry,smy,sby])
   [y_fit] = polyval([my,by],range);
   plot(range,y_fit,'b-');
   
   [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
   disp([mxi,bxi,rxi,smxi,sbxi])
   [y_fit] = polyval([mxi,bxi],range);
   plot(range,y_fit,'g-');
   
   [m,b,r,sm,sb]=lsqbisec(x,y);
   disp([m,b,r,sm,sb])
   [y_fit] = polyval([m,b],range);
   plot(range,y_fit,'r-')
   
   hold off
   text(0.12,0.08,'\lambda= 519/523 nm','FontSize',12)
   text(0.12,0.07, sprintf('n= %i ',n),'FontSize',12)
   text(0.12,0.06, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
   text(0.12,0.05, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
   text(0.12,0.04, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
   text(0.12,0.03, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
   text(0.12,0.02, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
   text(0.12,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
   
   %compare MPLARM and AATS top and bottom AOD 519/523 nm
   figure(8)
   %top
   y=lidar.AOD_AATS_top;
   x=AATS.AOD519_mpl_top;
   ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
   x=x(ii); y=y(ii);
   subplot(2,2,1)
   plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
   hold on
   xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_top(ii),'k.')
   n=length(x);
   rmsd=(sum((x-y).^2)/(n-1))^0.5;
   bias=mean(y-x);
   range=[0 0.06];
   set(gca,'ylim',range);
   set(gca,'xlim',range);
   xlabel('top AOD: AATS-14','FontSize',14)
   ylabel('top AOD: MPLARM','FontSize',14)
   axis square
   set(gca,'FontSize',14)
   set(gca,'xtick',0:0.01:0.06);
   set(gca,'ytick',0:0.01:0.06);
   
   [my,by,ry,smy,sby]=lsqfity(x,y);
   disp([my,by,ry,smy,sby])
   [y_fit] = polyval([my,by],range);
   plot(range,y_fit,'b-')
   
   [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
   disp([mxi,bxi,rxi,smxi,sbxi])
   [y_fit] = polyval([mxi,bxi],range);
   plot(range,y_fit,'g-')
   
   [m,b,r,sm,sb]=lsqbisec(x,y);
   disp([m,b,r,sm,sb])
   [y_fit] = polyval([m,b],range);
   plot(range,y_fit,'r-',range,range,'k-')
   
   hold off
   text(0.05,0.045 ,'\lambda= 519/523 nm','FontSize',12)
   text(0.05,0.04, sprintf('n= %i ',n),'FontSize',12)
   text(0.05,0.035, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
   text(0.05,0.03, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
   text(0.05,0.025, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
   text(0.05,0.02, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
   text(0.05,0.015, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
   text(0.05,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
   
   %bottom
   y=lidar.AOD_AATS_bot;
   x=AATS.AOD519_mpl_bot;
   ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
   x=x(ii); y=y(ii);
   subplot(2,2,2)
   plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
   hold on
   xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_bot(ii),'k.')
   n=length(x);
   rmsd=(sum((x-y).^2)/(n-1))^0.5;
   bias=mean(y-x);
   range=[0 0.250];
   set(gca,'ylim',range);
   set(gca,'xlim',range);
   xlabel('bottom AOD: AATS-14','FontSize',14)
   ylabel('bottom AOD: MPLARM','FontSize',14)
   axis square
   set(gca,'FontSize',14)
   set(gca,'xtick',0:0.05:0.25);
   set(gca,'ytick',0:0.05:0.25);
   
   [my,by,ry,smy,sby]=lsqfity(x,y);
   disp([my,by,ry,smy,sby])
   [y_fit] = polyval([my,by],range);
   plot(range,y_fit,'b-')
   
   [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
   disp([mxi,bxi,rxi,smxi,sbxi])
   [y_fit] = polyval([mxi,bxi],range);
   plot(range,y_fit,'g-')
   
   [m,b,r,sm,sb]=lsqbisec(x,y);
   disp([m,b,r,sm,sb])
   [y_fit] = polyval([m,b],range);
   plot(range,y_fit,'r-',range,range,'k-')
   
   hold off
   text(0.2,0.15 ,'\lambda= 519/523 nm','FontSize',12)
   text(0.2,0.13, sprintf('n= %i ',n),'FontSize',12)
   text(0.2,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
   text(0.2,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
   text(0.2,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
   text(0.2,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
   text(0.2,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
   text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
   
   %layer
   y=lidar.AOD_AATS_bot-lidar.AOD_AATS_top;
   x=AATS.AOD519_mpl_bot-AATS.AOD519_mpl_top;
   ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
   x=x(ii); y=y(ii);
   subplot(2,2,3)
   plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
   hold on
   xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_bot(ii),'k.')
   n=length(x);
   rmsd=(sum((x-y).^2)/(n-1))^0.5;
   bias=mean(y-x);
   range=[0 0.250];
   set(gca,'ylim',range);
   set(gca,'xlim',range);
   xlabel('layer AOD: AATS-14','FontSize',14)
   ylabel('layer AOD: MPLARM','FontSize',14)
   axis square
   set(gca,'FontSize',14)
   set(gca,'xtick',0:0.05:0.25);
   set(gca,'ytick',0:0.05:0.25);
   
   [my,by,ry,smy,sby]=lsqfity(x,y);
   disp([my,by,ry,smy,sby])
   [y_fit] = polyval([my,by],range);
   plot(range,y_fit,'b-')
   
   [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
   disp([mxi,bxi,rxi,smxi,sbxi])
   [y_fit] = polyval([mxi,bxi],range);
   plot(range,y_fit,'g-')
   
   [m,b,r,sm,sb]=lsqbisec(x,y);
   disp([m,b,r,sm,sb])
   [y_fit] = polyval([m,b],range);
   plot(range,y_fit,'r-',range,range,'k-')
   
   hold off
   text(0.2,0.15 ,'\lambda= 519/523 nm','FontSize',12)
   text(0.2,0.13, sprintf('n= %i ',n),'FontSize',12)
   text(0.2,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
   text(0.2,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
   text(0.2,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
   text(0.2,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
   text(0.2,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
   text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
end
lidar.Altitude = AATS.Altitude;
return

function mpl = cutmpl(mpl,keep);

mpl.time = mpl.time(keep);
mpl.prof = mpl.prof(:,keep);
hks = fieldnames(mpl.hk);
for hk = 1:length(hks)
   mpl.hk.(hks{hk}) = mpl.hk.(hks{hk})(keep);
end
