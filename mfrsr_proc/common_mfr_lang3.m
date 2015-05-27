function [status, lang_result,lang_plot] = common_mfr_lang3(leg,inarg);
% [status, lang_result,lang_plot] = common_mfr_lang3(leg, inarg);
% Computes langley results for a single airmass leg (AM or PM)
% The idea is to first test specified filters using multilang.
% If enough points remain, compute normal langleys for filters 1-5
% Then apply an angstrom test to retrieved taus.
% "leg" is an ancstruct containing the airmass leg for the Langley
% "inarg" is a struct with the following defaults:
%    inarg.leg = []; to hold boolean airmass definition
%    inarg.show = 0; 0/1/2 for noplots/finalplot/runningplots
%    inarg.tests.test_filters=[5 2];
%    inarg.tests.stdev_mult=2.75;
%    inarg.tests.steps = 5;
%    inarg.tests.Ntimes = 50;
%    inarg.tests.tau_max = 1;
%    inarg.tests.prscreen.on = false;
% cjf: Jan 7,2010: modified to handle new mfr format with filter details in
% global attributes and convert to mV or cts.
status = false;
if ~exist('leg','var')
   leg = ancload(getfullname_('*.*','xmfrx_netcdf','Select a MFRSR or NIMFR netcdf file.'));
end
if ~exist('inarg','var')
   inarg = [];
end
inarg = test_inarg(inarg);
% unroll inarg
tests = inarg.tests;
show = inarg.show;
if ~isempty(inarg.leg)
   leg = ancsift(leg,leg.dims.time,leg);
end
good = true(size(leg.time));
if isfield(leg.vars,'sun_to_earth_distance')
   soldst = leg.vars.sun_to_earth_distance.data;
else
   [zen, az, soldst, ha, dec, el, am] = ...
      sunae(leg.vars.lat.data, leg.vars.lon.data, mean(leg.time));
end

for filt = inarg.tests.test_filters;
%    Vo.(['filter',num2str(filt)]) = [];
   if isfield(leg.atts,['filter',num2str(filt),'_CWL_measured'])
   lambda = sscanf(leg.atts.(['filter',num2str(filt),'_CWL_measured']).data, '%g');
   elseif isfield(leg.vars.(['wavelength_filter',num2str(filt)]).atts, 'actual_wavelength')
      lambda = sscanf(leg.vars.(['wavelength_filter',num2str(filt)]).atts.actual_wavelength.data, '%g');
   end
   %lambda = sscanf(leg.vars.(['wavelength_filter',num2str(filt)]).atts.actual_wavelength.data, '%g');
   
   dirn = leg.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
   if isfield(leg.atts,['filter',num2str(filt),'_TOA_direct_normal'])&&isfield(leg.vars,['Io_filter',num2str(filt)])
      TOA = sscanf(leg.atts.(['filter',num2str(filt),'_TOA_direct_normal']).data, '%g');
   Io = leg.vars.(['Io_filter',num2str(filt)]).data;
   else
      TOA = 1; Io = 1;
   end
   nomCal = leg.vars.(['nominal_calibration_factor_filter',num2str(filt)]).data;
   dirn = ((dirn./TOA).*Io).*nomCal; %Now in mV or cts
   dirn = dirn.*(soldst .^2);
   in.time =leg.time(good);
   in.V = dirn(good);
   in.airmass = leg.vars.airmass.data(good);
   in.lambda_nm = lambda;
   %       in.Vo = Vo.(['filter',num2str(filt)]);
   [good(good),Vo,tau,Vo_, tau_,settings, final_stats]  = multi_lang_max(in,tests,show);
%    [good(good), ...
%       langs.(['Vo_filter',num2str(filt)]),langs.(['tau_filter',num2str(filt)]),...
%       langs.(['Vo_uw_filter',num2str(filt)]), langs.(['tau_uw_filter',num2str(filt)])] ...
%       = multi_lang(in,tests,show);
   Ngood = sum(good);
   %       leg = leg & good;
   %       Vo.(['filter',num2str(filt)]) =
   %       langs.(['Vo_filter',num2str(filt)]);
end
% if sum(good_times)>=tests.Ntimes
if sum(good)>=tests.Ntimes
   status = true;
   lang_plot.time = leg.time;
   lang_plot.good= good;
   good_ii = find(good);
   lang_plot.airmass = leg.vars.airmass.data;
   lang_plot.time_mean = mean(leg.time(good));
   [lang_plot.airmass_min, ind] = min(lang_plot.airmass(good));
   lang_plot.time_min = lang_plot.time(good_ii(ind));
   [lang_plot.airmass_max, ind] = max(lang_plot.airmass(good));
   lang_plot.time_max = lang_plot.time(good_ii(ind));
   lang_plot.airmass_delta = lang_plot.airmass_max-lang_plot.airmass_min;
   lang_plot.time_delta = abs(lang_plot.time_max-lang_plot.time_min);
   lang_plot.soldst = soldst;
   lang_plot.settings = settings;
   lang_plot.final_stats = final_stats;
   
   lang_result.time = lang_plot.time_mean;
   lang_result.airmass_min = lang_plot.airmass_min;
   lang_result.time_min = lang_plot.time_min;
   lang_result.airmass_max = lang_plot.airmass_max;
   lang_result.time_max = lang_plot.time_max;
   lang_result.airmass_delta = lang_plot.airmass_delta;
   lang_result.time_delta = lang_plot.time_delta;
   lang_result.soldst = lang_plot.soldst;
   lang_result.Ngood = sum(good);
   for filt = [1:5]
      dirn = leg.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
%       TOA = sscanf(leg.atts.(['filter',num2str(filt),'_TOA_direct_normal']).data, '%g');
%       Io = leg.vars.(['Io_filter',num2str(filt)]).data;
         if isfield(leg.atts,['filter',num2str(filt),'_TOA_direct_normal'])&&isfield(leg.vars,['Io_filter',num2str(filt)])
      TOA = sscanf(leg.atts.(['filter',num2str(filt),'_TOA_direct_normal']).data, '%g');
   Io = leg.vars.(['Io_filter',num2str(filt)]).data;
   else
      TOA = 1; Io = 1;
   end
      nomCal = leg.vars.(['nominal_calibration_factor_filter',num2str(filt)]).data;
%       dirn = ((dirn./TOA).*Io); %Now in mV or cts
       dirn = ((dirn./TOA).*Io).*nomCal; %Now in mV or cts
      dirn = dirn.*(soldst .^2);
      pos = dirn>0;
      airmass = leg.vars.airmass.data(good&pos);
      [out_Vo, out_tau,out_P,out_S,out_Mu] = lang(airmass, dirn(good&pos));
      lang_plot.(['dirn_1AU_filter',num2str(filt)]) = dirn;
      lang_plot.(['Vo_filter',num2str(filt)]) = out_Vo;
      lang_plot.(['tau_filter',num2str(filt)]) = out_tau;
      lang_result.(['Vo_filter',num2str(filt)]) = out_Vo;
      lang_result.(['tau_filter',num2str(filt)]) = out_tau;
   end
else
   lang_plot.time = leg.time;
   lang_plot.airmass = leg.vars.airmass.data;
   lang_plot.time_mean = mean(leg.time);
   [lang_plot.airmass_min, ind] = min(lang_plot.airmass);
   lang_plot.time_min = lang_plot.time(ind);
   [lang_plot.airmass_max, ind] = max(lang_plot.airmass);
   lang_plot.time_max = lang_plot.time(ind);
   lang_plot.airmass_delta = lang_plot.airmass_max-lang_plot.airmass_min;
   lang_plot.time_delta = abs(lang_plot.time_max-lang_plot.time_min);
   lang_plot.soldst = soldst;
   
   lang_result.time = lang_plot.time_mean;
   lang_result.airmass_min = lang_plot.airmass_min;
   lang_result.time_min = lang_plot.time_min;
   lang_result.airmass_max = lang_plot.airmass_max;
   lang_result.time_max = lang_plot.time_max;
   lang_result.airmass_delta = lang_plot.airmass_delta;
   lang_result.time_delta = lang_plot.time_delta;
   lang_result.soldst = lang_plot.soldst;
   lang_result.Ngood = sum(good);
   for filt = [1:5]
      dirn = leg.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
      dirn = dirn.*(soldst .^2);
%       airmass = leg.vars.airmass.data(good);
      %       [out_Vo, out_tau,out_P,out_S,out_Mu,out_delta] = lang(airmass,
      %       dirn);
      lang_plot.(['dirn_1AU_filter',num2str(filt)]) = dirn;
      lang_plot.(['Vo_filter',num2str(filt)]) = NaN;
      lang_result.(['Vo_filter',num2str(filt)]) = NaN;
   end
end
if status
   lang_result.alt = leg.vars.alt.data;
   status = lang_ang_test(lang_result);
   
   if sum(good)<tests.Ntimes||status==false
      lang_plot.time = leg.time;
      lang_plot.airmass = leg.vars.airmass.data;
      lang_plot.time_mean = mean(leg.time);
      [lang_plot.airmass_min, ind] = min(lang_plot.airmass);
      lang_plot.time_min = lang_plot.time(ind);
      [lang_plot.airmass_max, ind] = max(lang_plot.airmass);
      lang_plot.time_max = lang_plot.time(ind);
      lang_plot.airmass_delta = lang_plot.airmass_max-lang_plot.airmass_min;
      lang_plot.time_delta = abs(lang_plot.time_max-lang_plot.time_min);
      lang_plot.soldst = soldst;
      
      lang_result.time = lang_plot.time_mean;
      lang_result.airmass_min = lang_plot.airmass_min;
      lang_result.time_min = lang_plot.time_min;
      lang_result.airmass_max = lang_plot.airmass_max;
      lang_result.time_max = lang_plot.time_max;
      lang_result.airmass_delta = lang_plot.airmass_delta;
      lang_result.time_delta = lang_plot.time_delta;
      lang_result.soldst = lang_plot.soldst;
      lang_result.Ngood = sum(good);
      for filt = [1:5]
         dirn = leg.vars.(['direct_normal_narrowband_filter',num2str(filt)]).data;
         dirn = dirn.*(soldst .^2);
         %       airmass = leg.vars.airmass.data(good);
         %       [out_Vo, out_tau,out_P,out_S,out_Mu,out_delta] = lang(airmass,
         %       dirn);
         lang_plot.(['dirn_1AU_filter',num2str(filt)]) = dirn;
         lang_plot.(['Vo_filter',num2str(filt)]) = NaN;
         lang_result.(['Vo_filter',num2str(filt)]) = NaN;
      end
   end
end
lang_plot.status = status;
lang_result.status = status;

return % common_mfr_lang3

function status = lang_ang_test(lang_result)
% status = lang_ang_test(lang_plot)
% Check angstrom exponent of langley results
filt_wl = [415,500,615,676,870];
for filt = 5:-1:1
   tau(filt) = lang_result.(['tau_filter',num2str(filt)]);
   [~,tmp, ray_tod(filt)] = std_ray_atten([0:5:lang_result.alt]./1000, filt_wl(filt));
   ray_ot(filt) = ray_tod(filt) - tmp(end);

end
%%
%    ray_ot = tod_Rayleigh(filt_wl);
   aod = tau - ray_ot;
ang_tau = polyfit(log(filt_wl),log(tau),1);
ang_ray = polyfit(log(filt_wl),log(ray_ot),1);
pos = aod>0;
ang_aod = polyfit(log(filt_wl(pos)),(log(aod(pos))),1);
%
figure(33); loglog(   filt_wl, ray_ot,'ro',...
   filt_wl, tau,'b*',...
   filt_wl(pos), aod(pos),'kx',...
      filt_wl, exp(polyval(ang_ray,log(filt_wl))),'r-',...
   filt_wl, exp(polyval(ang_tau,log(filt_wl))),'b-',...
   filt_wl, exp(polyval(ang_aod,log(filt_wl))),'k-');
title(['Angstroms for ',datestr(lang_result.time,'yyyy-mm-dd HH PM'), ' leg']);
legend(['Rayleigh ang = 4'],['tod ang = ',sprintf('%1.1f ',-1.*ang_tau(1))],...
   ['aod ang = ',sprintf('%1.1f',-1.*ang_aod(1))]);
xlim([400,900]);
ylim([0.5.*ray_ot(5),2.*max([ray_ot(1),tau(1)])]);
set(gca,'xtick',filt_wl,'xgrid','on','ygrid','on');
xlabel('wavelength [nm]');
ylabel('optical depth');
%%
a_tau = -1*ang_tau(1);
a_aod = -1*ang_aod(1);
status = a_tau >1 && a_aod>.25 && a_aod<4;
return %lang_ang_test

function inarg = test_inarg(inarg)
if isempty(inarg)
   inarg.leg = [];
   inarg.show = 0;
   inarg.tests.test_filters=[5,2];
   inarg.tests.stdev_mult=2.75;
   inarg.tests.std_max=0.025;
   inarg.tests.steps = 1;
   inarg.tests.Ntimes = 50;
   inarg.tests.tau_max = 1;
   inarg.tests.prescreen.on = false;
else
   if ~isfield(inarg,'show');
      inarg.show = 0;
   end
   if ~isfield(inarg,'leg');
      inarg.leg = [];
   end
   if ~isfield(inarg,'tests')
      inarg.tests.test_filters=[5,2];
      inarg.tests.stdev_mult=2.75;
      inarg.tests.std_max=0.025;
      inarg.tests.steps = 1;
      inarg.tests.Ntimes = 50;
      inarg.tests.tau_max = 1;
      inarg.tests.prescreen.on = false;
   end
   if ~isfield(inarg.tests,'prescreen')
      inarg.tests.prescreen.on = false;
   end
   if ~isfield(inarg.tests,'stdev_mult')
      inarg.tests.stdev_mult=2.75;
   end
      if ~isfield(inarg.tests,'stdev_max')
      inarg.tests.std_max=0.025;
   end
   if ~isfield(inarg.tests,'test_filters')
      inarg.tests.test_filters=[5,2];
   end
   if ~isfield(inarg.tests,'steps')
      inarg.tests.steps = 1;
   end
   if ~isfield(inarg.tests,'Ntimes')
      inarg.tests.Ntimes = 50;
   end
   if ~isfield(inarg.tests,'tau_max')
      inarg.tests.tau_max = 1;
   end
end
return % of test_inarg