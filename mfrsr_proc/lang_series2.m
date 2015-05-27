function [lang_common] = lang_series2(inarg);
% [lang_common, langs] = lang_series(inarg);
% calls common_mfr_lang for 1 or more MFRSR files.

if ~exist('inarg','var')
   inarg = [];
end
inarg = test_inarg(inarg);

in_dir = inarg.indir;
if ~exist(in_dir,'dir')
   error('Specified input directory does not exist!')
end
langplot_outdir = [in_dir,'langplot',filesep];
if ~exist(langplot_outdir,'dir')
   mkdir(langplot_outdir);
end
badlang_outdir = [in_dir,'badlang',filesep];
if ~exist(badlang_outdir,'dir')
   mkdir(badlang_outdir);
end
Io_outdir = [in_dir,'lang_Io_mats',filesep];
if ~exist(Io_outdir,'dir')
   mkdir(Io_outdir);
end
in_file = dir([in_dir, '*mfr*.cdf']);
%%
lang_common.time = NaN([1,2*length(in_file)]);
lang_common.time_min = lang_common.time;
lang_common.time_max = lang_common.time;
lang_common.airmass_min = lang_common.time;
lang_common.airmass_max = lang_common.time;
lang_common.time_delta = lang_common.time;
lang_common.airmass_delta = lang_common.time;
lang_common.soldst = lang_common.time;
lang_common.Ngood = lang_common.time;
lang_common.Vo_filter1 = NaN([1,2*length(in_file)]);
lang_common.Vo_filter2 = lang_common.Vo_filter1;
lang_common.Vo_filter3 = lang_common.Vo_filter1;
lang_common.Vo_filter4 = lang_common.Vo_filter1;
lang_common.Vo_filter5 = lang_common.Vo_filter1;
lang_common.status = false(size(lang_common.time));

good_legs = 0;
for fnum = 1:length(in_file)
   disp(['Reading ',in_file(fnum).name, ': #',num2str(fnum),' of ',num2str(length(in_file))]);
   day = ancload([in_dir, in_file(fnum).name]);
   [pname, fname, ext] = fileparts(day.fname);
   [part1,fname] = strtok(fname, '.');[part2,fname] = strtok(fname, '.');
   langplot_fstem = [part1,'.',part2,'.',datestr(day.time(1),'yyyymmdd'),'.doy',num2str(floor(serial2doy(day.time(1))))];
   AM_status = true;
   PM_status = true;
   % AM leg
   nn = 1+2*(fnum-1);
   %    AM = (day.vars.airmass.data > 2) & (day.vars.airmass.data < 4) & (day.vars.azimuth_angle.data <180) & (day.vars.elevation_angle.data >14);
   AM = (day.vars.airmass.data > 2) & (day.vars.airmass.data < 8) & (day.vars.azimuth_angle.data <180);
   if sum(AM)>=inarg.tests.Ntimes
      leg = ancsift(day, day.dims.time,AM);
      [status, lang_result,langplot] = common_mfr_lang2(leg,inarg);
      if status
         good_legs = good_legs +1;
         disp(['Good langleys: ',num2str(good_legs)]);
         %          save([langplot_outdir,langplot_fstem,'.langplot_AM.mat'],'langplot');
         gen_langplot(langplot,[langplot_outdir,langplot_fstem,'.langplot_PM.png'],' morning leg');
      else
         save([langplot_outdir,langplot_fstem,'.langplot_AM.bad.mat'],'langplot');
      end
      % Save langplot as mat file.
      lang_common.time(nn) = lang_result.time;
      lang_common.time_min(nn) = lang_result.time_min;
      lang_common.time_max(nn) = lang_result.time_max;
      lang_common.airmass_min(nn) = lang_result.airmass_min;
      lang_common.airmass_max(nn) = lang_result.airmass_max;
      lang_common.time_delta(nn) = lang_result.time_delta;
      lang_common.airmass_delta(nn) = lang_result.airmass_delta;
      lang_common.soldst(nn) = lang_result.soldst;
      lang_common.Ngood(nn) = lang_result.Ngood;
      lang_common.status(nn) = lang_result.status;
      AM_status = status;
      if status
         lang_common.Vo_filter1(nn) = lang_result.Vo_filter1;
         lang_common.Vo_filter2(nn) = lang_result.Vo_filter2;
         lang_common.Vo_filter3(nn) = lang_result.Vo_filter3;
         lang_common.Vo_filter4(nn) = lang_result.Vo_filter4;
         lang_common.Vo_filter5(nn) = lang_result.Vo_filter5;
      end
   end
   % PM leg
   nn = 2*fnum;
   %    PM = (day.vars.airmass.data > 2) & (day.vars.airmass.data < 4) & (day.vars.azimuth_angle.data >180) & (day.vars.elevation_angle.data >17);
   PM = (day.vars.airmass.data > 2) & (day.vars.airmass.data < 8) & (day.vars.azimuth_angle.data >180);
   if sum(PM)>inarg.tests.Ntimes
      leg = ancsift(day, day.dims.time,PM);
      [status, lang_result,langplot] = common_mfr_lang2(leg,inarg);
      % Save langplot as mat file.
      langplot.settings = inarg;
      if status
         good_legs = good_legs +1;
         disp(['Good langleys: ',num2str(good_legs)]);
         %          save([langplot_outdir,langplot_fstem,'.langplot_PM.mat'],'langplot');
         gen_langplot(langplot,[langplot_outdir,langplot_fstem,'.langplot_PM.png'],' afternoon leg');
      else
         save([langplot_outdir,langplot_fstem,'.langplot_PM.bad.mat'],'langplot');
      end
      lang_common.time(nn) = lang_result.time;
      lang_common.time_min(nn) = lang_result.time_min;
      lang_common.time_max(nn) = lang_result.time_max;
      lang_common.airmass_min(nn) = lang_result.airmass_min;
      lang_common.airmass_max(nn) = lang_result.airmass_max;
      lang_common.time_delta(nn) = lang_result.time_delta;
      lang_common.airmass_delta(nn) = lang_result.airmass_delta;
      lang_common.soldst(nn) = lang_result.soldst;
      lang_common.Ngood(nn) = lang_result.Ngood;
      lang_common.status(nn) = lang_result.status;
      PM_status = status;
      if status
         lang_common.Vo_filter1(nn) = lang_result.Vo_filter1;
         lang_common.Vo_filter2(nn) = lang_result.Vo_filter2;
         lang_common.Vo_filter3(nn) = lang_result.Vo_filter3;
         lang_common.Vo_filter4(nn) = lang_result.Vo_filter4;
         lang_common.Vo_filter5(nn) = lang_result.Vo_filter5;
      end
   end
   if ~(AM_status||PM_status)
      disp(['Moving ',in_file(fnum).name,' to bad Langley directory.'])
      system(['move ',in_dir, in_file(fnum).name,' ',badlang_outdir])
   end
end
lang_common.settings = inarg;
lang_common.Nvalid = sum(lang_common.status==1);
if sum(lang_common.status)>=4
   lang_common.IQF = filter_lang_series(lang_common,lang_common.status==true ,inarg.filter.W);
  lang_out_txt(lang_common, txt_fname);
end
if sum(lang_common.status)>0
v = 1;
while exist([Io_outdir, 'lang_Ios_raw.v',num2str(v),'.mat'],'file')
   v = v+1;
end
lang_out = [Io_outdir, 'lang_Ios_raw.v',num2str(v),'.mat'];
display(['Saving ',lang_out]);
save(lang_out,'lang_common');
end
return
%%
function gen_langplot(langplot, fname, AM_str);
for ff = 1:5
   good = langplot.good;
   pos = langplot.(['dirn_1AU_filter',num2str(ff)])>0;
   logV = log(langplot.(['dirn_1AU_filter',num2str(ff)]));
   P = polyfit(langplot.airmass(good&pos),logV(good&pos),1);
   Vo = exp(polyval(P,0));
   tau = -P(1);
   legstr{ff} = ['Filter ',num2str(ff), ': Io= ',sprintf('%2.3f',Vo), ',  tau=', sprintf('%2.3f',tau)];
   Ps.(['filter',num2str(ff)]) = P;
end
figure(99);
semilogy(langplot.airmass, langplot.dirn_1AU_filter1./langplot.Vo_filter1,'k.', ...
   langplot.airmass, langplot.dirn_1AU_filter2./langplot.Vo_filter2,'k.', ...
   langplot.airmass, langplot.dirn_1AU_filter3./langplot.Vo_filter3,'k.', ...
   langplot.airmass, langplot.dirn_1AU_filter4./langplot.Vo_filter4,'k.', ...
   langplot.airmass, langplot.dirn_1AU_filter5./langplot.Vo_filter5,'k.', ...
   langplot.airmass(good), langplot.dirn_1AU_filter1(good)./langplot.Vo_filter1,'b.', ...
   langplot.airmass(good), langplot.dirn_1AU_filter2(good)./langplot.Vo_filter2,'g.', ...
   langplot.airmass(good), langplot.dirn_1AU_filter3(good)./langplot.Vo_filter3,'c.', ...
   langplot.airmass(good), langplot.dirn_1AU_filter4(good)./langplot.Vo_filter4,'y.', ...
   langplot.airmass(good), langplot.dirn_1AU_filter5(good)./langplot.Vo_filter5,'r.', ...
   [0,langplot.airmass,8], exp(polyval(Ps.filter1, [0,langplot.airmass,8]))./langplot.Vo_filter1, 'b-', ...
   [0,langplot.airmass,8], exp(polyval(Ps.filter2,  [0,langplot.airmass,8]))./langplot.Vo_filter2, 'g-', ...
   [0,langplot.airmass,8], exp(polyval(Ps.filter3,  [0,langplot.airmass,8]))./langplot.Vo_filter3, 'c-', ...
   [0,langplot.airmass,8], exp(polyval(Ps.filter4,  [0,langplot.airmass,8]))./langplot.Vo_filter4, 'y-', ...
   [0,langplot.airmass,8], exp(polyval(Ps.filter5,  [0,langplot.airmass,8]))./langplot.Vo_filter5, 'r-');
xlabel('airmass');
yl = ylim;
ylim([min([0.8*yl(1), 0.75*min(langplot.dirn_1AU_filter1./langplot.Vo_filter1)]),1.2*yl(2)])
ylabel('atmospheric transmittance')
lg =legend(legstr{1}, legstr{2}, legstr{3}, legstr{4}, legstr{5});
set(lg,'location','SouthWest')
title(['Langley plot for ',datestr(langplot.time(1),'yyyy-mm-dd '),' doy:',num2str(floor(serial2doy(langplot.time(1)))),AM_str]);
set(99,'position',[15 375 560 420]);
saveas(99, fname, 'png')
% saveas(99,[fname, '.fig'],'fig');


wl = [415,500,615,676,870];
taus = [langplot.tau_filter1,langplot.tau_filter2,langplot.tau_filter3,...
   langplot.tau_filter4,langplot.tau_filter5];
PP = polyfit(log(wl),log(taus),1);
figure(98);
plot(log10(wl),log10(exp(polyval(PP,log(wl)))),'k-',log10(wl),log10(taus),'o');
set(98,'position',[532 377 560 420]);
legend(['Angstrom alpha = ',num2str(-1*PP(1))])
ylabel('log_1_0(total optical depth)')
xlabel('log_1_0(wavelength[nm])');
title(['Angstrom spectrum for MFRSR on ',datestr(langplot.time(1),'yyyy-mm-dd'),' doy:',num2str(floor(serial2doy(langplot.time(1)))), AM_str]);
ylim([log10(0.8*min(taus)), log10(1.2*max(taus))]);
bck = fliplr(fname);
[dmp,bck] = strtok(bck,'.');[dmp,bck] = strtok(bck,'.');fname = fliplr(bck);
fname = [fname,'AngstromSpectrum.png'];
saveas(98, fname, 'png')

% Compute best-fits, or retrieve if available
% semilogy(airmaas vs dirn_1AU_filtern)
% Legend(filter n, wl, Io, tau)

%next plot is log(wl) vs log(lang_tau)

%P1 = polyfit(langplot.airmass, log10(langplot
% pause(1)
return % of gen_langplot


%%
   function inarg = test_inarg(inarg)
      if isempty(inarg)
         inarg.leg = [];
         inarg.show = 0;
         inarg.tests.test_filters=[5,2];
         inarg.tests.stdev_mult=3; %(default 2.5, lower is more stringent)
         inarg.tests.steps = 1; % number of outliers to reject per cycle
         inarg.tests.Ntimes = 40;
         inarg.tests.tau_max = 1;
         inarg.tests.std_max = 2.5e-2;
         inarg.tests.min_am_span = 1.125;
         inarg.tests.prescreen.on = true;
         inarg.indir = getdir([],'mfr_lang_in','Select directory containing data for Langley analysis.');
         inarg.filter.W = 90; % default filter width is 90 days = +/- 45 days
      else
         if ~isfield(inarg,'indir')
            inarg.indir = getdir([],'mfr_lang_in','Select directory containing data for Langley analysis.');
         end
         if ~isfield(inarg,'show');
            inarg.show = 1;
         end
         if ~isfield(inarg,'leg');
            inarg.leg = [];
         end
         if ~isfield(inarg,'tests')
            inarg.tests.test_filters=[5,2];
            inarg.tests.stdev_mult=2.75;
            inarg.tests.steps = 1;
            inarg.tests.Ntimes = 50;
            inarg.tests.tau_max = 1;
            inarg.tests.prescreen.on = false;
            inarg.tests.std_max = 2.5e-2;
            inarg.tests.min_am_span = 3;
         end
         if ~isfield(inarg.tests,'prescreen')
            inarg.tests.prescreen.on = false;
         end
         if ~isfield(inarg.tests,'stdev_mult')
            inarg.tests.stdev_mult=2.75;
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
         if ~isfield(inarg,'filter')
            inarg.filter.W = 90;
         end
         if ~isfield(inarg.filter,'W')
            inarg.filter.W = 90;
         end
      end
      return % of test_inarg
