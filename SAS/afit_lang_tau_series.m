function [lang_legs, ttau] = afit_lang_tau_series(ttau, lang_legs)
% step 1: compose a time series of aod from one or more confident sources
% step 2: apply aod-fit in 0.1 airmass increments for each airmass leg,
%         saving sufficiently complete legs for use in tau-weighted langley regression.
% Step 3a: For direct solar beam streams, calc tau_lang
% Step 3b: Collect series of Vos
%          Compare series of orig Vos to tau_lang Vo series.
% Step 4a: Re-cal new direct beam for source
% Step 4b: Compute new AODs for all direct solar sources
% Step 5: Repeat step 1 with new AODs.  Compare to previous AOD time series and spread of new vs orig aods
% Step 6a: Infer Ozone OD from difference between xMFRx 615 AOD and be-fit AOD.
% Step 6b: Retrieve Ozone DU.
% Step 6c: Compare to Anet and OMI Ozone DU.
% Step 7a: Pin SASHe VIS to match be-fit
% Step 7b: Pin SASHe NIR to match VIS at short end and be-fit at long end.


% Cloud-screen ideas: Use of dbl_lang as a cloud screen for even nomimally
% calibrated data looks very promising.Follow this with Alexandrov-Ermold-Flynn
% screen.

% Clean up SASHe: Use MFRSR DDR to address SASHe banding issues and yield presumably
% calibratable direct beam. Attempt to calibrate with tau-lang using afit above.
% Assess SASHe AODs vs afit.  If poor fit, then consider directly scaling SASHe to
% aod-fit at 3 points, zenith and horizon, interpolating between.

% Follow this with tau_langley of individual sources using aod_fit as tau.  Can this
% work for dbl_lang?
% streams before tau_langley
% written by Connor Flynn mostly in 2022
% 2022-08-15: 1.6 micron AOD shows notable steps dependent on whether actual
% measurements exist at the time or are inferred.
% Will attempt to improve this by interpolating 1.6 micron to all times.
% Also eliminate legs with insufficient points to comprise a valid Langley

% Use dbl_lang as a cloud-screen for MFRSR and SASHe nominal AODs.
% From the above anet aod time series, compute aod-fit to provide aod at non-anet
% wavelengths.  Interpolate *not extrapolate* over time within a given AM/PM airmass
% leg to provide AOD for use in tau_langley regressions for (all!) AOD sources. To
% apply tau_langley to original anet retrievals convert to Tr and see how different
% Trs vary from unity.  This should relate directly to how consistent the tau-langley
% retrieved calibration is to the anet calibration. (Hopefully it is close to unity
% but not identical to unity.)

% Then compute AOD from all sources, find aod-fit, repeat tau-Langley.  Do the AOD
% values converge?


% Make contiguous list of all reported tau, one tau per row with time and airmass
% Filter NaNs and missings out.  Sort by time.1020
% Attach a source tag
% Then create a regular matrix with one measurement per WL per time,
% interpolating and extrapolating as necessary.
% Consider creating "weight" matrix with 1 for measurements, 0.5 for
% interpolated values, and possibly other weights depending on MADS or RMS



% Other thought - apply dlb-lang as cloud screen before eps-screen.  See if this
% yields more AODs in challenging environments


if ~isavar('ttau')
   ttau.time = [];
   ttau.time_LST = [];
   ttau.airmass = [];
   ttau.pres_atm = [];
   ttau.nm = [];
   ttau.aod = [];
   ttau.srctag = [];

   src = 0;

   cimfile = getfullname('*.*','anet_aod_v3');
   while ~isempty(cimfile)&&isafile(cimfile)

      src = src + 1;
      src_str(src) = {input('Enter a label for this source: ','s')};
      cim = read_cimel_aod_v3(cimfile);
      if ~isavar('cims') cims(1)=cim;
      else cims(end+1) = cim;
      end
      aods = fields(cim);
      aod_ = foundstr(aods, 'AOD_')&foundstr(aods, 'nm_AOD');
      aods = aods(aod_);
      for f = 1:length(aods)
         good = cim.(aods{f})>0 ;
         wl = sscanf(aods{f},'AOD_%f');
         %Maybe only add records with aod>0 (handled this later ~146)
         ttau.time = [ttau.time; cim.time(good)];
         ttau.airmass = [ttau.airmass; cim.Optical_Air_Mass(good)];
         ttau.pres_atm = [ttau.pres_atm; cim.Pressure_hPa_(good)];
         ttau.nm = [ttau.nm; wl.*ones(size(cim.time(good)))];
         ttau.srctag = [ttau.srctag; src.*ones(size(cim.time(good)))];
         ttau.aod = [ttau.aod; cim.(aods{f})(good)];
         if isfield(cim,'Site_Latitude_Degrees_'),
            ttau.Lat = unique(cim.Site_Latitude_Degrees_);
            ttau.Lat = ttau.Lat(1);
         end
         if isfield(cim,'Site_Longitude_Degrees_'),
            ttau.Lon = unique(cim.Site_Longitude_Degrees_);
            ttau.Lon = ttau.Lon(1);
         end
      end
      cimfile = getfullname('*.*','anet_aod_v3');
   end

   mfr_files = getfullname('*aod1mich*','aod1mich');
   while ~isempty(mfr_files)

      src = src + 1;
      src_str(src) = {input('Enter a label for this source: ','s')};
      mfr = anc_bundle_files(mfr_files);
      if ~isavar('mfrs') mfrs(1) = mfr;
      else
         mfrs(end+1) = mfr;
      end
      flds = fields(mfr.vdata);
      qc_aod_ = foundstr(flds, 'qc_aerosol_optical_depth');
      qc_ii = find(qc_aod_);
      for qc = 1:sum(qc_aod_)
         wl = sscanf(mfr.gatts.(['filter',num2str(qc),'_CWL_measured']),'%f');
         ttau.time = [ttau.time; mfr.time'];
         ttau.airmass = [ttau.airmass; mfr.vdata.airmass'];
         ttau.pres_atm = [ttau.pres_atm; zeros(size(mfr.vdata.airmass'))+mfr.vdata.surface_pressure.*10];
         ttau.nm = [ttau.nm; wl.*ones([length(mfr.time),1])];
         ttau.srctag = [ttau.srctag; src.*ones([length(mfr.time),1])];
         qs = anc_qc_impacts(mfr.vdata.(flds{qc_ii(qc)}), mfr.vatts.(flds{qc_ii(qc)}));
         good = qs==0; sus = qs == 1;
         good = qs<2; % To accept suspect, uncomment this line
         tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
         ttau.aod = [ttau.aod; tmp_aod];
         if isfield(mfr.vdata,'lat'),
            ttau.Lat = unique(mfr.vdata.lat);
            ttau.Lat = ttau.Lat(1);
         end
         if isfield(mfr.vdata,'lon'),
            ttau.Lon = unique(mfr.vdata.lon);
            ttau.Lon = ttau.Lon(1);
         end
      end
      mfr_files = getfullname('*aod1mich*','aod1mich');
   end
   [ttau.time, ij] = sort(ttau.time);
   ttau.airmass = ttau.airmass(ij);
   ttau.pres_atm = ttau.pres_atm(ij)./1013.25; % Units of atm
   ttau.nm = ttau.nm(ij);
   ttau.srctag = ttau.srctag(ij);
   ttau.aod = ttau.aod(ij);
   bad = ttau.time<0 | ttau.airmass<0 | ttau.aod <0| isnan(ttau.time)|isnan(ttau.airmass)|isnan(ttau.aod);
   ttau.time(bad) = [];ttau.airmass(bad) = []; ttau.pres_atm(bad) = [];
   ttau.nm(bad) = [];ttau.srctag(bad) = []; ttau.aod(bad) = [];
   ttau.time_LST = ttau.time + double(ttau.Lon/15)./24;
   ttau.src_str = src_str;
else
   if ~isfield(ttau,'time_LST')
      ttau.time_LST = ttau.time - 6.5/24; % Assume SGP
   end
   if ~isfield(ttau,'srctag')&&isfield(ttau,'src')
      ttau.srctag = ttau.src; ttau = rmfield(ttau,'src');
   end
   src_str = ttau.src_str;

   % ttau.time_LST = ttau.time - 6.5/24;
   % [sza, saz, ~, ~, ~, sel, sun_am] = sunae(ttau.Lat, ttau.Lon, ttau.time);
   noon = 12;
   src_color = colororder;src_color;
   day = floor(ttau.time_LST);
   dates = unique(floor(ttau.time_LST));

   % This is just a quasi-continuous series of 1.6 micron AOD since leaving it
   % out or substituting an alternative has negative consequences on the 1.6
   % um Langley

   LW.time = ttau.time;
   wl_1p6 = ttau.nm > 1400; wl_1u = ttau.nm > 1000 & ttau.nm < 1200;
   LW.aod_1p6 = interp1(ttau.time(wl_1p6), ttau.aod(wl_1p6), ttau.time,'linear');
   LW.aod_1u = interp1(ttau.time(wl_1u), ttau.aod(wl_1u), ttau.time,'linear');
   bad = isnan(LW.aod_1p6) | isnan(LW.aod_1u) |(LW.aod_1p6./LW.aod_1u > .95);
   gtime = LW.time(~bad); gaod = LW.aod_1p6(~bad);
   [gtime, ij] = unique(gtime); gaod = gaod(ij);
   LW.aod_1p6(bad) =interp1(gtime, gaod, LW.time(bad), 'nearest','extrap');
   ttau.aod_1p6 = LW.aod_1p6; clear LW
end

dd = 1;
wl_out = [300:20:1740];
AM_leg.wl = wl_out;
PM_leg.wl = wl_out;
mad_factor = 3;

% while dd <= length(dates)
% % trim dates with insufficient number of points and airmass range
% % Identify all unique wavelengths at which valid AODs are reported
% % Interpolate these over all output time spacings.
% end
if ~isavar('lang_legs')
   lang_legs.mt = []; lang_legs = rmfield(lang_legs, 'mt');

   while dd <= length(dates)
      %     fig22 = figure_(22); set(fig22,'visible','off')
      AM_str = ['AM_',datestr(dates(dd),'yyyymmdd')];
      PM_str = ['PM_',datestr(dates(dd),'yyyymmdd')];
      this_day = day==dates(dd)&ttau.airmass<6&ttau.airmass>1.5;
      this_i = find(this_day,1);
      %     src_str{unique(ttau.srctag(this_day))}
      AM_leg.airmass = []; AM_leg.pres_atm = []; AM_leg.aod_fit = []; AM_leg.time_UT = []; AM_leg.time_LST = []; AM_leg.nm = []; AM_leg.src = [];
      PM_leg.airmass = []; PM_leg.pres_atm = []; PM_leg.aod_fit = []; PM_leg.time_UT = []; PM_leg.time_LST = []; PM_leg.nm = []; PM_leg.src = [];
      %% AM leg
      while ~isempty(this_i) && serial2Hh(ttau.time_LST(this_i)) < (noon-.5) && this_i < find(this_day,1,'last')%
         % Find "these_m" within +/- 0.1 airmass
         these_m = day==dates(dd) & (serial2Hh(ttau.time_LST')' < (noon-.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
         srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
         % Loop over all unique sources, taking mean of each source by wl
         % Plotting each in a different color.
         clear this_am src
         this_am.src = []; this_am.nm = []; this_am.aod = [];
         this_am.time_UT = mean(ttau.time(these_m));
         this_am.time_LST = mean(ttau.time_LST(these_m));
         %         figure_(22); clf; cla; hold('on');
         %         title({[datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', AM airmass = %2.1f',mean(ttau.airmass(these_m)))];...
         %             ['Sources: ',srcs_str]});
         for s_i = 1:length(srcs) % check that srcs is the right orientation
            src(s_i).str = src_str(srcs(s_i));
            s_ = ttau.srctag==srcs(s_i);
            wls = unique(ttau.nm(these_m & s_));
            src(s_i).nm = wls;
            for wl_i = 1:length(wls)
               wl_ = ttau.nm == wls(wl_i);
               src(s_i).aod(wl_i,1) = mean(ttau.aod(these_m & s_ & wl_));
            end
            this_am.aod = [this_am.aod; src(s_i).aod];
            this_am.nm = [this_am.nm; src(s_i).nm];
            this_am.src = [this_am.src ; srcs(s_i).*ones(size(src(s_i).aod))];
            %             figure_(22); plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:)); logx; logy; hold('on');
            %             pause(.025)
         end
         % rfit best AOD and plot in black dots every 20 nm for this am and time.
         if max(this_am.nm) < 1200
            this_am.nm = [this_am.nm; 1640]; %try excluding 615 nm from fit in order to use it to retrieve ozone
            this_am.aod = [this_am.aod; mean(ttau.aod_1p6(these_m & s_ & wl_))];
            nm_615 = find(this_am.nm>610 & this_am.nm<620);
            this_am.nm(nm_615) = [];this_am.aod(nm_615) = [];
            this_am.src = [this_am.src ; srcs(1)];

            %             sub_ = this_am.nm>600 & this_am.nm<1000;
            %             P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
            %            [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; 1.5.*tau_1p6], wl_out, mad_factor);
            %         else
            %             [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
         end
         %         [aod_fit, good_wl_, fit_rms, fit_bias] = rfit_aod_basis([this_am.nm;this_am.nm], [this_am.aod;this_am.aod], wl_out, mad_factor);
         [aod_fit, good_wl_, fit_rms, fit_bias] = rfit_aod_basis([this_am.nm], [this_am.aod], wl_out, mad_factor);
         %         figure_(22);plot(wl_out, aod_fit,'k--');pause(.025)
         %         lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
         AM_leg.time_UT = [AM_leg.time_UT; this_am.time_UT];
         AM_leg.time_LST = [AM_leg.time_LST; this_am.time_LST];
         AM_leg.aod_fit = [AM_leg.aod_fit; aod_fit];
         AM_leg.airmass = [AM_leg.airmass; mean(ttau.airmass(these_m))];
         AM_leg.pres_atm = [AM_leg.pres_atm; mean(ttau.pres_atm(these_m))];
         AM_leg.nm = unique([AM_leg.nm; this_am.nm]);
         AM_leg.src = unique([AM_leg.src; this_am.src]);
         this_i = find(these_m, 1,'last')+1;
      end % of AM leg
      AM_range = max(AM_leg.airmass)-min(AM_leg.airmass);
      if ~isfield(lang_legs,AM_str)&&isavar('AM_leg')&&length(AM_leg.airmass)>10&&(AM_range>3)&&(min(AM_leg.airmass)<3.5)&&(max(AM_leg.airmass)>4.5)
         lang_legs.(AM_str)=AM_leg;
      end
      % By this time, we should have points for AM Langley if conditions permit
      %     if length(AM_leg.airmass)>3 && (max(AM_leg.airmass)-min(AM_leg.airmass))>3
      %         figure_(24); set(gcf,'visible','off')
      %         xx(1) = subplot(2,1,1);
      %         plot(AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');logy;
      %         xl = xlim; xlim([-0.25, xl(2)])
      %         title([datestr(mean(AM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', AM Leg']);
      %         ylabel('Tr')
      %         xx(2) = subplot(2,1,2);
      %         plot(AM_leg.aod_fit(:,11).*AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');logy;
      %         xl = xlim; xlim([0, xl(2)])
      %         xlabel('airmass*aod');
      %         ylabel('Tr');
      %         linkaxes(xx,'y');
      %         pause(0.01)
      %     end
      %     this_i = find(these_m, 1,'last')+1;

      % Start PM leg
      these_aods = this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)) & ttau.nm==500;
      this_i = find(this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)),1,'first');
      this_j = find(this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)),1,'last');
      while  ~isempty(this_i)&&(this_i < find(this_day,1,'last'))%
         %         figure_(22); set(gcf,'visible','off')
         these_m = day==dates(dd) & (serial2Hh(ttau.time_LST')' > (noon+.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
         srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
         % Loop over all unique sources, taking mean of each source by wl
         % Plotting each in a different color.
         clear this_am src
         this_am.src = []; this_am.nm = []; this_am.aod = [];
         this_am.time_UT = mean(ttau.time(these_m));
         this_am.time_LST = mean(ttau.time_LST(these_m));
         %         clf; cla; hold('on')
         %                 title({[datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', PM airmass = %2.1f',mean(ttau.airmass(these_m)))];...
         %             ['Sources: ',srcs_str]});
         for s_i = 1:length(srcs) % check that srcs is the right orientation
            src(s_i).str = src_str(srcs(s_i));
            s_ = ttau.srctag==srcs(s_i);
            wls = unique(ttau.nm(these_m & s_));
            src(s_i).nm = wls;
            for wl_i = 1:length(wls)
               wl_ = ttau.nm == wls(wl_i);
               src(s_i).aod(wl_i,1) = mean(ttau.aod(these_m & s_ & wl_));
            end
            this_am.aod = [this_am.aod; src(s_i).aod];
            this_am.nm = [this_am.nm; src(s_i).nm];
            this_am.src = [this_am.src ; srcs(s_i).*ones(size(src(s_i).aod))];
            %             figure_(22);plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:));
            %             logx; logy; hold('on');set(gcf,'visible','off');
            %              pause(.025);
         end
         % Fit best AOD and plot in black dots every 20 nm for this am and time.
         % Save best fit AOD
         if max(this_am.nm) < 1200
            this_am.aod = [this_am.aod; mean(ttau.aod_1p6(these_m & s_ & wl_))];
            this_am.nm = [this_am.nm; 1640];
            this_am.src = [this_am.src ; srcs(1)];
            nm_615 = find(this_am.nm>610 & this_am.nm<620);
            this_am.nm(nm_615) = [];this_am.aod(nm_615) = [];
            %             sub_ = this_am.nm>600 & this_am.nm<1000;
            %             P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
            %            [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; mean(1.5.*[tau_1p6])], wl_out, mad_factor);
            %         else
            %             [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
         end
         %         [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm;this_am.nm], [this_am.aod;this_am.aod], wl_out, mad_factor);
         [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
         %         figure_(22); plot(wl_out, aod_fit, 'r--');pause(.025); set(fig22,'visible','on')
         %         lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
         PM_leg.time_UT = [PM_leg.time_UT; this_am.time_UT];
         PM_leg.time_LST = [PM_leg.time_LST; this_am.time_LST];
         PM_leg.aod_fit = [PM_leg.aod_fit; aod_fit];
         PM_leg.airmass = [PM_leg.airmass; mean(ttau.airmass(these_m))];
         PM_leg.pres_atm = [PM_leg.pres_atm; mean(ttau.pres_atm(these_m))];
         PM_leg.nm = unique([PM_leg.nm; this_am.nm]);
         PM_leg.src = unique([PM_leg.src; this_am.src]);
         this_i = find(these_m, 1,'last')+1;
      end % of PM leg
      PM_range = max(PM_leg.airmass)-min(PM_leg.airmass);
      if ~isfield(lang_legs,PM_str)&&length(PM_leg.airmass)>10&&(PM_range>3)&&(min(PM_leg.airmass)<3.5)&&(max(PM_leg.airmass)>4.5)
         lang_legs.(PM_str)=PM_leg;
      end
      % This was just a plot illustrating consistency/validity of lang, tau_lang
      %     if length(PM_leg.airmass)>3 && (max(PM_leg.airmass)-min(PM_leg.airmass))>3
      %         figure_(24); set(gcf,'visible','on')
      %         xx(1) = subplot(3,1,1);
      %         plot(PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');logy;
      %         xl = xlim; xlim([0, xl(2)]); yl = ylim; ylim([yl(1),1]);
      %         P_11 = polyfit(PM_leg.airmass, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
      %         tau_bar = -P_11(1); Io = exp(P_11(2));
      %         title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
      %         ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
      %         hold('on'); plot([0,7], exp(polyval(P_11,[0,7])),'r--')
      %
      %         xx(2) = subplot(3,1,2);
      %         plot(PM_leg.airmass.*tau_bar, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');logy;
      %         xl = xlim; xlim([0, xl(2)])
      %         P_11_bar = polyfit(PM_leg.airmass*tau_bar, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
      %         tau_bar_bar = -P_11_bar(1); Io_bar = exp(P_11_bar(2));
      %         title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
      %         ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
      %         hold('on'); plot([0,7], exp(polyval(P_11_bar,[0,7])),'r--')
      %
      %         xx(3) = subplot(3,1,3);
      %         plot(PM_leg.airmass.*PM_leg.aod_fit(:,11), exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'o');logy;
      %         xl = xlim; xlim([0, xl(2)])
      %         P_11_bar = polyfit(PM_leg.airmass.*PM_leg.aod_fit(:,11), -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
      %         tau_bar_bar = -P_11_bar(1); Io_bar = exp(P_11_bar(2));
      %         title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
      %         ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
      %         hold('on'); plot([0,7], exp(polyval(P_11_bar,[0,7])),'r--')
      %
      %
      %         plot(PM_leg.aod_fit(:,11).*PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
      %         xl = xlim; xlim([0, xl(2)])
      %         xlabel('airmass*tau');
      %         ylabel('Tr');
      %         linkaxes(xx,'y');
      %         pause(.01)
      %     end
      dd = dd +1
   end
end
% load dirn stream
% One lang_leg at a time, run tau_lang for each filter/wl
dirbeam = load_dirbeam;

while ~isempty(dirbeam)
   langs.pname = dirbeam.pname;
   langs.fname = dirbeam.fname;
   langs.nm = [];
   langs.time_UT = [];
   langs.ngood = [];
   langs.min_oam = [];
   langs.max_oam = [];
   langs.Vo = [];
   langs.Vo_uw = [];
   leg_name = fieldnames(lang_legs);
   for L = 1:length(leg_name)
      leg = lang_legs.(leg_name{L});
      wl_x = interp1(leg.wl, [1:length(leg.wl)],[1020,1700],'nearest');
      % replace bad fits where aod(1700)>aod(1020)
      % Probably unnecessary after finding error in madf rejecting wrong points
%       bad_fit = leg.aod_fit(:,wl_x(1))<leg.aod_fit(:,wl_x(2)); sum(bad_fit);
%       try
%       leg.aod_fit(bad_fit,:) = interp1(leg.time_LST(~bad_fit), leg.aod_fit(~bad_fit,:),leg.time_LST(bad_fit),'linear');
%       catch
%          warning('Whatsup?');
%       end
      %       figure; pp = plot(leg.time_LST, leg.aod_fit,'-'); logy; dynamicDateTicks; xlabel('time LST'); ylabel('aod'); recolor(pp,leg.wl)
      %       figure; plot(leg.airmass, leg.aod_fit,'-'); logy; xlabel('airmass'); ylabel('aod')
      ok = 1; %ok = menu('Use this leg?','Y','N')
      %       if ok == 1
      figure_(9);
      for wl_ii = length(dirbeam.wls):-1:1
         nm = dirbeam.wls(wl_ii);
         L_ = (dirbeam.wl==nm)&(dirbeam.time>=leg.time_UT(1))&(dirbeam.time<=leg.time_UT(end));
         WL.nm = nm; WL.AU = mean(dirbeam.AU(L_));WL.pres_atm = mean(leg.pres_atm);
         WL.time = dirbeam.time(L_); WL.dirn = dirbeam.dirn(L_);
         WL.oam = dirbeam.oam(L_);

         %Interpolate leg.aod_fit (in log-log space) to match wl of filter
         % Probably also interpolate in time to match times of mfr "minl" but in this case it is 1:1
         % Also, interpolate atm_pres_hPa from leg to wl, scale rayOD
         WL.RayOD = rayleigh_ht(nm./1000);
         aod_fit = exp(interp1(log(leg.wl), log(leg.aod_fit'), log(nm),'linear'))';
         WL.aod = interp1(leg.time_UT, aod_fit, WL.time','linear')';
         WL.iT_g = exp(WL.RayOD.*WL.pres_atm.*WL.oam); % Inverse gas transmittance (so multiply by instead of divide)
         try
         [Vo,~,Vo_, ~, good] = dbl_lang(WL.oam.*WL.aod,WL.iT_g.*WL.dirn,[],[],1,1);
         aod_lang = -log(WL.dirn./mean([Vo, Vo_]))./WL.oam - WL.RayOD.*WL.pres_atm;
         figure_(9); plot(WL.time(good), aod_lang(good),'.'); legend(num2str(nm));dynamicDateTicks; hold('on');
         if sum(good)>=10 && (max(WL.oam(good))-min(WL.oam(good)))>=3
            langs.nm(end+1) = nm;
            langs.time_UT(end+1) = mean(WL.time(good)) ;
            langs.ngood(end+1) = sum(good);
            langs.min_oam(end+1) = min(WL.oam(good));
            langs.max_oam(end+1) = max(WL.oam(good));
            langs.Vo(end+1) = Vo;
            langs.Vo_uw(end+1) = Vo_;
         end
         catch
           warning('Try, catch tripped.  Possible issue with polyfit within dbl_lang')  
         end
      end
      pause(.25); close(9);
      %       end
   end
   figure; scatter(langs.time_UT, langs.Vo, 8,langs.nm); title(dirbeam.fname); dynamicDateTicks
   save([langs.pname, langs.fname, '_Vos.mat'],'-struct','langs');
   dirbeam = load_dirbeam;
end

% Consider dividing this code into at least two stand-alone functions, one to produce
% the best-estimate Legs.  Another that reads these along with the dirbeam sources 

% Next action is to compute robust Vo values from the langs 
% then compute AOD from all dirbeam sources with these robust Vos. 
% then explore retrieving ozone DU from the difference between
% the aod_fit (that excludes 615 nm measurements) and the actual 615 nm measurements
% as computed from the tau_langley approach here.
% Also, check what to do with AU and gas subtractions.



end

function dirbeam = load_dirbeam 

dirbeam_files = getfullname('*.*','dir_beam','Select direct beam file(s)');
dirbeam = [];
if ~isempty(dirbeam_files)
   if iscell(dirbeam_files)
      test = dirbeam_files{1};
   else
      test = dirbeam_files;
   end
   [pname, fname, ext] = fileparts(test); pname = strrep([pname, filesep], [filesep, filesep], filesep);

   if any(foundstr(ext,'.mat'))||any(foundstr(ext,'.nc'))||any(foundstr(ext,'.cdf'))
      % probably xmfrx file
      if any(foundstr(ext,'.mat'))
         infile = load(test);
      else
         infile = anc_bundle_files(dirbeam_files);
      end
      if length(dirbeam_files)==1
         save([pname, fname, '.mat'],'-struct','infile');
      elseif length(dirbeam_files)>1
         last_date = datestr(infile.time(end), 'yyyymmdd');
         [~,emanf] = strtok(fliplr(fname),'.');
         fname = fliplr(emanf); fname(end) = '_';
         fname = [fname, last_date];
         save([pname, fname, '.mat'],'-struct','infile');
      end
   else
      infile = read_cimel_aod_v3(test);
%       fields = fieldnames(infile);
%       fields = fields(foundstr(fields,'AOD_')); fields = fields(foundstr(fields,'_Total'));
%       [~, ~, AU, ~, ~, ~, ~] = sunae(0, 0, infile.time);
%       for fld = 1:length(fields)
%          field = fields{f};
%          dirn = infile.(field); 
%          dirbeam.time =[dirbeam.time, infile.time(dirn>0)];
%          wl = sscanf(field,'AOD_%f');
%          dirbeam.wl = [dirbeam.wl,zeros(size(dirn(dirn>0)))];
%          dirbeam.oam = [dirbeam.oam, infile.Optical_Air_Mass(dirn>0)];
%          dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
%       end

      % get list of "AOD" fields, screen out those will all zeros.
   end
   dirbeam.pname = pname, dirbeam.fname = fname; 
   dirbeam.time = []; dirbeam.wl = []; dirbeam.dirn = []; dirbeam.oam = []; dirbeam.AU = [];
   if isfield(infile,'vdata')
      [~, ~, AU, ~, ~, ~, oam] = sunae(infile.vdata.lat, infile.vdata.lon, infile.time);
      if isfield(infile.vdata,'direct_normal_narrowband_filter1')
         for f = 1:5
            dirn = infile.vdata.(['direct_normal_narrowband_filter',num2str(f)]);
            dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
            if isfield(infile.gatts,'filter1_CWL_measured')
               wl = sscanf(infile.gatts.(['filter',num2str(f),'_CWL_measured']), '%f');
            elseif isfield(infile.vatts.wavelength_filter1,'centroid_wavelength')
               wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).centroid_wavelength,'%f');
            elseif isfield(infile.vatts.wavelength_filter1,'actual_wavelength')
               wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).actual_wavelength,'%f');
            end
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+wl];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      end
      if isfield(infile.vdata,'direct_normal_narrowband_filter7')
         for f = 7
            dirn = infile.vdata.(['direct_normal_narrowband_filter',num2str(f)]);

         dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
         wl = sscanf(infile.gatts.(['filter',num2str(f),'_CWL_measured']), '%f');
         dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+wl];
         dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
         dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)]
         end
      end
   else % now handle anet 
      fields = fieldnames(infile);
      fields = fields(foundstr(fields,'AOD_')); fields = fields(foundstr(fields,'_Total'));
      [~, ~, AU, ~, ~, ~, ~] = sunae(0, 0, infile.time');
      for fld = 1:length(fields)
         field = fields{fld};
         dirn = infile.(field)'; 
         dirbeam.time =[dirbeam.time, infile.time(dirn>0)'];
         wl = sscanf(field,'AOD_%f');
         dirbeam.wl = [dirbeam.wl,zeros(size(dirn(dirn>0)))+wl];
         dirbeam.dirn = [dirbeam.dirn, exp(-dirn(dirn>0).*infile.Optical_Air_Mass(dirn>0)')];
         dirbeam.oam = [dirbeam.oam, infile.Optical_Air_Mass(dirn>0)'];
         dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
      end

   end
   [dirbeam.time, ij] = sort(dirbeam.time); 
   dirbeam.wl = dirbeam.wl(ij);
   dirbeam.wls = unique(dirbeam.wl);
   dirbeam.dirn = dirbeam.dirn(ij);
   dirbeam.oam = dirbeam.oam(ij); 
   dirbeam.AU = dirbeam.AU(ij);
   end
end


% load a datastream containing N time-series direct solar measurements.
% This function recognizes and parses anet and xmfrx files to obtain direct normal or
% direct transmission at all provided wavelengths and populates a consistent struct
% with tag, time, wavelength, airmass, and direct beam (normal or transmittance) in
% similar organization as ttau; namely single dimensioned, sorted but non-unique
% times, one per WL at a given airmass.  within afit_lang_tau_series, we'll
% interpolate the fitted aod values in lang_leg in log-log space in wl and then
% linearly in airmass to produce tau_lang inputs for dbl_lang.

% Initial idea, use getfilename.  if not empty, check first file.  
% If ext = .nc .cdf or .mat assume it is an xmfrx type file
% check for direct_normal_transmittance fields.  
% If any, read 1-5 and 7 if exist along with wavelengths. 
% If no *transmittance*, then read direct_normal_narrowband 1-5 and 7 if exist.
% if not xmfrx, assume anet.  Identify AODs.  (careful!  Look at both AOD and TOT
% files to ensure logic is robust and precise)
% Compute and populate airmass and AU from sunae(time, lat, lon)


