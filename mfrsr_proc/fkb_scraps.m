% First, identify the input MFRSR data source:
% in_dir.mfr

% Collect langley time series
% lang_series
   % loop over 
%       common_mfr_lang
      % multi_lang
   % Save raw langley series
   % Generate IQF series
   % Save IQF series
   
% Compute OD data set, either from scratch or as correction to existing
%   Scratch requires pressure and Ozone.
%   Correction requires existing OD and Ios.
   % Save raw OD data set
   

% Screen raw OD data set as with fkb_aod_screen2
% Save screened results

% Check corrected AOD on good Langley days and on Aeronet matched times:
   % Plot log(aod) vs log(lambda) for filter angstrom check
   % Get water vapor (MWR or MWRP), pressure (met or MWRP), to compare SBDART and
   % SW_short_direct (QCrad or skyrad) 


% Save screened results

% Once again cycle through data files...
% If pressure and ozone are available, compute optical depths from scratch
% from the same data set used to generate the Ios above.  Alternately,
% apply corrections to existing optical depth based on ratio of
% previous Io to new Io.  Would be good to do both as a double-check.
% In either case, it would be _convenient_ to have a subset containing only
% the optical depths.

% Next, screen the entire series of OD as in fkb_aod_screen2.  Create a
% screened subset of data for working with later.




% function [common_lang, langs] = sandbox;
% % 
% % all_Ios = ancload(['E:\case_studies\fkb\fkbmfrsrlangleyM1.c1\fkbmfrsrlangleyM1.c1.20070321.153000.cdf']);
% % %%
% % mIo = all_Ios.vars.michalsky_solar_constant_sdist_filter5.data;
% % bIo = all_Ios.vars.barnard_solar_constant_sdist_filter5.data;
% % mgood = mIo>0& mIo<2.6;
% % bgood = bIo>0;
% % figure; plot(serial2doy(all_Ios.time(mgood)), mIo(mgood),'mo',   ...
% % serial2doy(all_Ios.time(bgood)), bIo(bgood),'bx',   ...   
% %    serial2doy(Ios.time), Ios.vars.Io_filter1.data, 'k.');
% % 
% % %%
% % figure
% % miq = IQF_lang(all_Ios.time(mgood), mIo(mgood),90);
% % %%
% % 
% % figure;
% % biq = IQF_lang(all_Ios.time(bgood), bIo(bgood),90);
% % %%
% % figure; plot(all_Ios.time(mgood), miq,'m.',all_Ios.time(bgood),biq,'b.')
% % %%
% % figure; plot(serial2doy(Ios.time),Ios.vars.Io_filter1.data,'k.',...
% %    serial2doy(all_Ios.time(mgood)), miq,'mo');
% % xlabel('doy')
% % ylabel('Arbitrary units')
% % legend('From VAP','miq')
% 
% %%
% in_dir = 'E:\fkb\fkbmfrsraod1flynnM1.c0\';
% in_file = dir([in_dir, 'fkbmfrsr*.cdf']);
% %%
% tests.stdev_mult=2.75;
% tests.steps = 5;
% tests.Ntimes = 50;
% tests.tau_max = 1;
% show = 0; %Show no plots
% prescreen.on = false; % Don't prescreen
% common_lang.Vo_filter1 = NaN([1,2*length(in_file)]);
% common_lang.Vo_filter2 = common_lang.Vo_filter1;
% common_lang.Vo_filter3 = common_lang.Vo_filter1;
% common_lang.Vo_filter4 = common_lang.Vo_filter1;
% common_lang.Vo_filter5 = common_lang.Vo_filter1;
% %[Vo,tau,Vo_, tau_, Ngood, good] = multi_lang(in_time,V,
% %airmass,lambda_nm,Vo, stdev_mult,steps,tests.Ntimes,show)
% %multi_lang(day05.time(am_05),
% %day05.vars.direct_normal_narrowband_filter5.data(am_05),day05.vars.airmass.data(am_05),870,[],2,5,50,2);
% %%
% for fnum = 1:length(in_file)
%    disp(['reading ',num2str(fnum),' of ',num2str(length(in_file))])
% day = ancload([in_dir, in_file(fnum).name]);
% 
% leg = day.vars.airmass.data > 0 & day.vars.azimuth_angle.data <180 & day.vars.elevation_angle.data >14;
% Vo.filter1 = [];
% Vo.filter2 = [];
% Vo.filter5 = [];
% % good_times = true(size(day.time));
% good = false(size(day.time));
% nn = 1+2*(fnum-1);
% % AM leg
% for filt = [2 5];
%    lambda = sscanf(day.vars.(['wavelength_filter',num2str(filt)]).atts.actual_wavelength.data, '%g');
%    dirn = day.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
%    dirn = dirn.*(day.vars.sun_to_earth_distance.data .^2);
%    leg = leg & (dirn>0);
%    if sum(leg)>tests.Ntimes
% %       good = false(size(day.time));
%       in.time =day.time(leg);
%       in.V = dirn(leg);
%       in.airmass = day.vars.airmass.data(leg);
%       in.lambda_nm = lambda;
%       in.Vo = Vo.(['filter',num2str(filt)]);
%       [langs.(['Vo_filter',num2str(filt)])(nn),langs.(['tau_filter',num2str(filt)])(nn),...
%          langs.(['Vo_uw_filter',num2str(filt)])(nn), langs.(['tau_uw_filter',num2str(filt)])(nn),...
%          langs.(['Ngood_filter',num2str(filt)])(nn), good(leg)] = ...
%       multi_lang(in,tests,show,prescreen);
%    leg = leg & good;
%       Vo.(['filter',num2str(filt)]) = langs.(['Vo_filter',num2str(filt)])(nn);
% %       if langs.(['Ngood_filter',num2str(filt)])(nn) > tests.Ntimes
% %          good_times = good_times&good;
% %       else
% %          good_times = false(size(day.time));
% %       end
%    end
% end
% % if sum(good_times)>=tests.Ntimes
% if sum(good)>=tests.Ntimes   
%    common_lang.time(nn) = mean(day.time(good));
%    for filt = [1:5]
%       dirn = day.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data(good); 
%       dirn = dirn.*(day.vars.sun_to_earth_distance.data .^2);
%       airmass = day.vars.airmass.data(good);
%    [out_Vo, out_tau,out_P,out_S,out_Mu,out_delta] = lang(airmass, dirn);
%    common_lang.(['Vo_filter',num2str(filt)])(nn) = out_Vo;
%    end
%    disp(['Good Langleys: ',num2str(sum(common_lang.Vo_filter5>0))]);
% end
% 
% % PM leg
% leg = day.vars.airmass.data > 0 & day.vars.azimuth_angle.data >180& day.vars.elevation_angle.data >18;
% Vo.filter1 = [];
% Vo.filter2 = [];
% Vo.filter5 = [];
% % good_times = true(size(day.time));
% good = false(size(day.time));
% nn = 2*fnum;
% for filt = [2 5];
%    lambda = sscanf(day.vars.(['wavelength_filter',num2str(filt)]).atts.actual_wavelength.data, '%g');
%    dirn = day.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
%    dirn = dirn.*(day.vars.sun_to_earth_distance.data .^2);
%    leg = leg & (dirn>0);
%    if sum(leg)>tests.Ntimes
% %       good = false(size(day.time));
%       in.time =day.time(leg);
%       in.V = dirn(leg);
%       in.airmass = day.vars.airmass.data(leg);
%       in.lambda_nm = lambda;
%       in.Vo = Vo.(['filter',num2str(filt)]);
%       [langs.(['Vo_filter',num2str(filt)])(nn),langs.(['tau_filter',num2str(filt)])(nn),...
%          langs.(['Vo_uw_filter',num2str(filt)])(nn), langs.(['tau_uw_filter',num2str(filt)])(nn),...
%          langs.(['Ngood_filter',num2str(filt)])(nn), good(leg)] = ...
%       multi_lang(in,tests,show,prescreen);
%    leg = leg & good;
%       Vo.(['filter',num2str(filt)]) = langs.(['Vo_filter',num2str(filt)])(nn);
% %       if langs.(['Ngood_filter',num2str(filt)])(nn) > tests.Ntimes
% %          good_times = good_times&good;
% %       else
% %          good_times = false(size(day.time));
% %       end
%    end
% end
% % if sum(good_times)>=tests.Ntimes
% if sum(good)>=tests.Ntimes   
%    common_lang.time(nn) = mean(day.time(good));
%    for filt = [1:5]
%       dirn = day.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data(good); 
%       dirn = dirn.*(day.vars.sun_to_earth_distance.data .^2);
%       airmass = day.vars.airmass.data(good);
%    [out_Vo, out_tau,out_P,out_S,out_Mu,out_delta] = lang(airmass, dirn);
%    common_lang.(['Vo_filter',num2str(filt)])(nn) = out_Vo;
%    end
%    disp(['Good Langleys: ',num2str(sum(common_lang.Vo_filter5>0))]);
% end
% % Now if we have any good times common to the supplied filters, we run
% % Langleys for all filters using these points. 
% end
% %%
% save('common_lang.mat','common_lang')

%%
common_lang = loadinto('C:\case_studies\fkb\common_lang.mat')
% common_lang =
% loadinto('C:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\common_lang.mat')
common_lang.fname = 'C:\case_studies\fkb\common_lang.mat';

good = common_lang.Vo_filter5>0;

fiq.time = common_lang.time(good);
fiq.filter1 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter1(good),70);
fiq.filter2 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter2(good),70);
fiq.filter3 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter3(good),70);
fiq.filter4 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter4(good),70);
fiq.filter5 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter5(good),70);
common_lang.fiq = fiq;
save(common_lang.fname,'common_lang')
%%
figure; 
xx(1) = subplot(2,1,1);
plot(serial2doy(fiq.time),[fiq.filter1; fiq.filter2; fiq.filter3; fiq.filter4; fiq.filter5], '.-');
legend('filter1','filter2','filter3','filter4','filter5')
grid;

xx(2) = subplot(2,1,2); 
plot(serial2doy(fiq.time),[fiq.filter1./mean(fiq.filter1); ...
   fiq.filter2./mean(fiq.filter2); fiq.filter3./mean(fiq.filter3); ...
   fiq.filter4./mean(fiq.filter4); fiq.filter5./mean(fiq.filter5)], '.-');
legend('filter1','filter2','filter3','filter4','filter5')
grid;
linkaxes(xx,'x');

%%
in_dir = ['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\'];
in_file = dir([in_dir, '*.cdf']);
for fnum = 1:length(in_file)
   disp(['Updating file ',num2str(fnum),' of ',num2str(length(in_file))])
   day = ancload([in_dir, in_file(fnum).name]);
%    old_day = ancload(['F:\case_studies\fkb\fkbmfrsraod1michM1.c1\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
%    day = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
   day_time = mean(day.time);
   fiq.time = common_lang.time(good);
   P = gaussian(fiq.time,day_time,30);
   for ii = 1:5;
      Io_old.(['filter',num2str(ii)]) = sscanf(day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).atts.(['Gueymard_TOA_filter',num2str(ii)]).data,'%f');
%       Io = sscanf(new_mfr.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
      %gaussian below may be replaced by an interpolation
      P = gaussian(fiq.time,day_time,15);
      Io_new.(['filter',num2str(ii)]) = trapz(fiq.time,fiq.(['filter',num2str(ii)]).*P)./trapz(fiq.time,P);
%       Io_new.(['filter',num2str(ii)]) = interp1(fiq.time, fiq.(['filter',num2str(ii)]),day_time,'linear');
      day.vars.(['Io_filter',num2str(ii)]).data = single(Io_new.(['filter',num2str(ii)]));
      MdTau.(['filter',num2str(ii)]) = log(Io_new.(['filter',num2str(ii)])./Io_old.(['filter',num2str(ii)]));
      pos = (day.vars.(['total_optical_depth_filter',num2str(ii)]).data>-9000)&(day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data>-9000);
      OD_gas.(['filter',num2str(ii)]) = NaN(size(day.vars.(['total_optical_depth_filter',num2str(ii)]).data));
      OD_gas.(['filter',num2str(ii)])(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         - day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data(pos);
      day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         + MdTau.(['filter',num2str(ii)])./day.vars.airmass.data(pos);
      day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         - OD_gas.(['filter',num2str(ii)])(pos);
      rad_corr = 1./(Io_new.(['filter',num2str(ii)])./Io_old.(['filter',num2str(ii)]));
      day.vars.(['hemisp_narrowband_filter',num2str(ii)]).data = (rad_corr).*day.vars.(['hemisp_narrowband_filter',num2str(ii)]).data;
      day.vars.(['diffuse_hemisp_narrowband_filter',num2str(ii)]).data = (rad_corr).*day.vars.(['diffuse_hemisp_narrowband_filter',num2str(ii)]).data;
      day.vars.(['direct_horizontal_narrowband_filter',num2str(ii)]).data = (rad_corr).*day.vars.(['direct_horizontal_narrowband_filter',num2str(ii)]).data;
      day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data = (rad_corr).*day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data;      
   end
   day.fname = [day.fname,'.nc'];
   day.clobber = true;
   day.quiet = true;
%    day = anccheck(day);
   ancsave(day);
%    day0 = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
end
%%
   
% 
% lang.time(1+2*(in-1)) = mean(day.time(good)); lang.Ngood(1+2*(in-1))= sum(good); 
% lang.good_1(1+2*(in-1)) = min(day.time(good)); lang.good_end(1+2*(in-1)) = max(day.time(good));
% else
%    lang.Vo_filter1(1+2*(in-1)) = NaN;
%    lang.tau(1+2*(in-1)) = NaN;
%    lang.Vo_(1+2*(in-1)) = NaN;
%    lang.tau_(1+2*(in-1))= NaN;
%    lang.time(1+2*(in-1)) = day.time(1)
%    lang.Ngood(1+2*(in-1))= sum(am); 
%    lang.good_1(1+2*(in-1)) = min(day.time(am)); 
%    lang.good_end(1+2*(in-1)) = max(day.time(am));
% end
% if sum(pm)>100
% [lang.Vo(2*in),lang.tau(2*in),lang.Vo_(2*in), lang.tau_(2*in), good] = dbl_lang(day.vars.airmass.data(am),day.vars.direct_normal_narrowband_filter5.data(am),2,50,5,1);
% lang.Ngood(2*in)= sum(good); lang.good_1(2*in) = min(day.time(good)); lang.good_end(1+2*in) = max(day.time(good));
% lang.time(2*in) = mean(day.time(good));
% else
%    lang.Vo(2*in) = NaN;
%    lang.tau(2*in) = NaN;
%    lang.Vo_(2*in) = NaN;
%    lang.tau_(2*in)= NaN;
%    lang.time(2*in) = day.time(1)
%    lang.Ngood(2*in)= sum(am); 
%    lang.good_1(2*in) = min(day.time(am)); 
%    lang.good_end(2*in) = max(day.time(am));
% end
% end
%  
pos = new_mfr.vars.direct_normal_narrowband_filter5.data>0 & new_mfr.vars.airmass.data>0;
dirn = NaN(size(new_mfr.vars.direct_normal_narrowband_filter5.data));
M =new_mfr.vars.airmass.data;
Io = sscanf(new_mfr.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
atm_T = dirn;
TOT = dirn;
TOD = dirn;
dirn(pos)=new_mfr.vars.direct_normal_narrowband_filter5.data(pos);
dirn(pos) = dirn(pos).*new_mfr.vars.sun_to_earth_distance.data.^2;
atm_T(pos) = dirn(pos)./Io;
TOT(pos) = -log(atm_T(pos));
TOD(pos) = TOT(pos)./M(pos);

figure; plot(serial2Hh(new_mfr.time(pos)), [new_mfr.vars.total_optical_depth_filter5.data(pos)],'r.',...
   serial2Hh(new_mfr.time(pos)), TOD(pos),'go');
legend('orig','confirm');
% axis(v)
%%
old_pos = old_mfr.vars.direct_normal_narrowband_filter1.data>0 & old_mfr.vars.airmass.data>0;
old_dirn = old_mfr.vars.direct_normal_narrowband_filter1.data;
new_pos = new_mfr.vars.direct_normal_narrowband_filter1.data>0 & new_mfr.vars.airmass.data>0;
new_dirn = new_mfr.vars.direct_normal_narrowband_filter1.data;
figure; plot(serial2Hh(old_mfr.time(old_pos)),old_dirn(old_pos),'b.',...
   serial2Hh(new_mfr.time(new_pos)), new_dirn(new_pos),'rx');

%%
old_TOA.filter1 = sscanf(old_mfr.vars.direct_normal_narrowband_filter1.atts.Gueymard_TOA_filter1.data,'%f');
old_TOA.filter2 = sscanf(old_mfr.vars.direct_normal_narrowband_filter2.atts.Gueymard_TOA_filter2.data,'%f');
old_TOA.filter3 = sscanf(old_mfr.vars.direct_normal_narrowband_filter3.atts.Gueymard_TOA_filter3.data,'%f');
old_TOA.filter4 = sscanf(old_mfr.vars.direct_normal_narrowband_filter4.atts.Gueymard_TOA_filter4.data,'%f');
old_TOA.filter5 = sscanf(old_mfr.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
old_Io.filter1 = old_mfr.vars.Io_filter1.data;
old_Io.filter2 = old_mfr.vars.Io_filter2.data;
old_Io.filter3 = old_mfr.vars.Io_filter3.data;
old_Io.filter4 = old_mfr.vars.Io_filter4.data;
old_Io.filter5 = old_mfr.vars.Io_filter5.data;

new_TOA.filter1 = sscanf(new_mfr.vars.direct_normal_narrowband_filter1.atts.Gueymard_TOA_filter1.data,'%f');
new_TOA.filter2 = sscanf(new_mfr.vars.direct_normal_narrowband_filter2.atts.Gueymard_TOA_filter2.data,'%f');
new_TOA.filter3 = sscanf(new_mfr.vars.direct_normal_narrowband_filter3.atts.Gueymard_TOA_filter3.data,'%f');
new_TOA.filter4 = sscanf(new_mfr.vars.direct_normal_narrowband_filter4.atts.Gueymard_TOA_filter4.data,'%f');
new_TOA.filter5 = sscanf(new_mfr.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
new_Io.filter1 = new_mfr.vars.Io_filter1.data;
new_Io.filter2 = new_mfr.vars.Io_filter2.data;
new_Io.filter3 = new_mfr.vars.Io_filter3.data;
new_Io.filter4 = new_mfr.vars.Io_filter4.data;
new_Io.filter5 = new_mfr.vars.Io_filter5.data;
%%
figure; plot(serial2doy(old_day.time), old_day.vars.total_optical_depth_filter5.data, 'k.',...
   serial2doy(day0.time), day0.vars.total_optical_depth_filter5.data, 'rx',...
   serial2doy(day.time), day.vars.total_optical_depth_filter5.data, 'g.',...
   serial2doy(old_day.time), old_day.vars.aerosol_optical_depth_filter5.data, 'k-',...
   serial2doy(day0.time), day0.vars.aerosol_optical_depth_filter5.data, 'r-',...
   serial2doy(day.time), day.vars.aerosol_optical_depth_filter5.data, 'g-');
legend('total orig','total temp','total new','aod orig','aod temp','aod new')
zoom('on'); 
axis(v)

% %% This is how to collect ozone from toms or omi files...
% Load the first file
% fkb_omi = get_oz(fkbmfr.vars.lat.data,fkbmfr.vars.lon.data);
% Concatenate all the others...
% fkb_omi =  anccat(fkb_omi,get_oz(fkbmfr.vars.lat.data,fkbmfr.vars.lon.data));
% .. % Do this for each month
% fkb_omi =  anccat(fkb_omi,get_oz(fkbmfr.vars.lat.data,fkbmfr.vars.lon.data));fkb_omi =  anccat(fkb_omi,get_oz(fkbmfr.vars.lat.data,fkbmfr.vars.lon.data));
% Interpolate to file NaNs.
% NaNs = isNaN(fkb_omi.vars.ozone.data);
% fkb_omi.vars.ozone.data(NaNs) = interp1(fkb_omi.time(~NaNs), fkb_omi.vars.ozone.data(~NaNs), fkb_omi.time(NaNs), 'linear','extrap');
% Save the result
% fkb_omi.fname = ['F:\case_studies\fkb\fbkomiX1.a1\fkbomiX1.20070301_20080131.nc'];
% fkb_omi.clobber = true;
% ancsave(fkb_omi);
