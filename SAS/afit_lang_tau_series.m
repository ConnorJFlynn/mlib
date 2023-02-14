function [ttau, lang_legs, dirbeams, rVos, ttau2, llegs2, rVos2, dbeams] = afit_lang_tau_series(ttau, lang_legs, rVos)
% [lang_legs, ttau, rVos, dirbeams, ttau2] = afit_lang_tau_series(ttau, lang_legs, rVos)
% v0.9 beta; Connor Flynn 2022-10-11, working to clean up, esp dbeam(s)
% Almost there.  TOD and AOD not computed properly from Vos, but very close.
% ttau: input serialized AOD, often anet.  Accepts both anet and ARM netcdf/mat
% lang_legs: ttau organized by airmass for tau-langley
% dirbeams: selected direct beam fields to calibrate with tau-langley and yield aods
% rVos: robust daily Vos (derived from dirn or dirt) for each supplied dirbeam
% ttau2: serialzed dirbeams for new tau-langleys
% llegs2: ttau2 organized by airmass as lang_legs
% rVos2: robust daily Vos (derived from dirt) for each dbeam
% dbeams: compacted direct beams from ttau2 with with recal applied and aod

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
% measurements exist at the time or are infered.
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
% Filter NaNs and missings out.  Sort by time.
% Attach a source tag
% Then create a regular matrix with one measurement per WL per time,
% interpolating and extrapolating as necessary.
% Consider creating "weight" matrix with 1 for measurements, 0.5 for
% interpolated values, and possibly other weights depending on MADS or RMS

% Other thought - apply dlb-lang as cloud screen before eps-screen.  See if this
% yields more AODs in challenging environments


if ~isavar('ttau')
   ttau = get_ttau;
end

if ~isavar('lang_legs')
   % while dd <= length(dates)
   % % trim dates with insufficient number of points and airmass range
   % % Identify all unique wavelengths at which valid AODs are reported
   % % Interpolate these over all output time spacings.
   % end
   lang_legs = build_lang_legs(ttau);
end

% leg_names = fieldnames(lang_legs);
% all_legs = lang_legs.(leg_names{1});
% all_legs = rmfield(all_legs,{'nm','src'});
% for LN = 2:length(leg_names)
%    legx = lang_legs.(leg_names{LN});
%    all_legs.airmass = [all_legs.airmass; legx.airmass];
%    all_legs.pres_atm = [all_legs.pres_atm; legx.pres_atm];
%    all_legs.time_LST = [all_legs.time_LST; legx.time_LST];
%    all_legs.time_UT = [all_legs.time_UT; legx.time_UT];
%    all_legs.aod_fit = [all_legs.aod_fit; legx.aod_fit];
% end
% [all_legs.time_UT,ij] = sort(all_legs.time_UT);
% all_legs.time_LST = all_legs.time_LST(ij);
% all_legs.airmass = all_legs.airmass(ij);
% all_legs.pres_atm = all_legs.pres_atm(ij);
% all_legs.aod_fit = all_legs.aod_fit(ij,:);
% all_legs.aod_615 = exp(interp1(log(all_legs.wl(16:17)),log(all_legs.aod_fit(:,16:17)'),log(615),'linear'))';
% all_legs.rod_615 = rayleigh_ht(615./1000).*all_legs.pres_atm;
% o3_615_du_od = 2.5738e+03;

if ~isavar('rVos')  % We need to load dirbeam(s), execute tau-langley to generate Vos and rVos.
   % load dirbeam streams
   % One lang_leg at a time, run tau_lang for each filter/wl
   dirbeam = load_dirbeam;
  [dirbeams, langs, ~, rVos] = calc_Vos_from_dirbeam(dirbeam, lang_legs);
  elseif isempty(rVos) % An empty Vo has been passed in signaling we should load presaved
   Vo = getfullname('*Vo.mat','Vo','Select a Vo mat file');
   while ~isempty(Vo)
      % See if the loaded Vo is just one really multiple.
      if isafile(Vo)
         Vo = load(Vo);
         tag = [];
         if isfield(Vo,'fname')
            if foundstr(Vo.fname,'C1')&&foundstr(Vo.fname, 'mfrsr')
               tag = 'mfrC1';
            elseif foundstr(Vo.fname, 'M1')&&foundstr(Vo.fname, 'mfrsr')
               tag = 'mfrM1';
            elseif foundstr(Vo.fname, 'E13')&&foundstr(Vo.fname, 'mfrsr')
               tag = 'mfrE13';
            elseif foundstr(Vo.fname, 'nimfr') && foundstr(Vo.fname, '.b1')
               tag = 'nimfrb1';
            elseif foundstr(Vo.fname, 'nimfr') && foundstr(Vo.fname, '.c1')
               tag = 'nimfr';
            elseif foundstr(Vo.fname, 'sashemfr')
               tag = 'sashemfr';
            elseif foundstr(Vo.fname, 'sashevis')
               tag = 'sashevis';
            elseif foundstr(Vo.fname, 'sashenir')
               tag = 'sashenir';
            else
               tag = 'anet';
            end
            Vo.tag = tag;
            rVos.(tag) = Vo;
         else
            tags = fieldnames(Vo);
            for t = 1:length(tags)
               Vo.(tags(t)).tag = tags(t);
               rVos.(tags(t)) = Vo.(tags(t));
            end
         end
      end
      Vo = getfullname('*Vo.mat','Vo','Select a Vo mat file');
   end
   % Vo has been passed in.  If empty, then we need to load Vos.
end
% At this point, we have generated rVos and recalibrated provided dirbeams
% Now, compute new best fit, new langs, new Vo2 and rVo2s
if ~isavar('tags') tags = []; end
[ttau2, dirbeams2] = calc_ttau2_dbeams(ttau, dirbeams, rVos);

% Then compose ttau2 into lang_legs2 with corresponding fitted-aod

dd = 1;
wl_out = [300:20:1740];
AM_leg.wl = wl_out;
PM_leg.wl = wl_out;
mad_factor = 3;
noon = 12;
src_str = ttau2.srcs;
day = floor(ttau2.time_LST);
dates = unique(floor(ttau2.time_LST));

% Then llegs2 from ttau2
llegs2.mt = []; llegs2 = rmfield(llegs2, 'mt');

while dd <= length(dates)
   %     fig22 = figure_(22); set(fig22,'visible','off')
   AM_str = ['AM_',datestr(dates(dd),'yyyymmdd')];
   PM_str = ['PM_',datestr(dates(dd),'yyyymmdd')];
   this_day = day==dates(dd)&ttau2.oam<6&ttau2.oam>1.5;
   this_i = find(this_day,1);
   %     src_str{unique(ttau.srctag(this_day))}
   AM_leg.oam = []; AM_leg.pres_atm = []; AM_leg.aod_fit = []; AM_leg.time_UT = []; AM_leg.time_LST = []; AM_leg.nm = []; AM_leg.tag = [];
   PM_leg.oam = []; PM_leg.pres_atm = []; PM_leg.aod_fit = []; PM_leg.time_UT = []; PM_leg.time_LST = []; PM_leg.nm = []; PM_leg.tag = [];
   %% AM leg
   while ~isempty(this_i) && this_i < length(day) && serial2Hh(ttau2.time_LST(this_i)) < (noon-.5) && this_i < find(this_day,1,'last')%
      % Find "these_m" within +/- 0.1 airmass
      these_m = day==dates(dd) & (serial2Hh(ttau2.time_LST')' < (noon-.5)) & abs(ttau2.oam-ttau2.oam(this_i))<.2;
      srcs = unique(ttau2.src(these_m)); %srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
      % Loop over all unique sources, taking mean of each source by wl
      % Plotting each in a different color.
      clear this_am src
      this_am.tag = []; this_am.nm = []; this_am.tod = []; this_am.aod = [];
      this_am.time_UT = mean(ttau2.time(these_m));
      this_am.time_LST = mean(ttau2.time_LST(these_m));
      %         figure_(22); clf; cla; hold('on');
      %         title({[datestr(mean(ttau2.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', AM airmass = %2.1f',mean(ttau2.oam(these_m)))];...
      %             ['Sources: ',srcs_str]});
      for s_i = 1:length(srcs) % check that srcs is the right orientation
         src(s_i).str = src_str(srcs(s_i));
         s_ = ttau2.src==srcs(s_i);
         wls = unique(ttau2.nm(these_m & s_));
         src(s_i).nm = wls;
         for wl_i = 1:length(wls)
            wl_ = ttau2.nm == wls(wl_i);
            src(s_i).tod(wl_i,1) = mean(ttau2.tod(these_m & s_ & wl_));
            src(s_i).aod(wl_i,1) = mean(ttau2.aod(these_m & s_ & wl_));
         end
         this_am.nm = [this_am.nm; src(s_i).nm'];
         this_am.aod = [this_am.aod; src(s_i).aod];
         this_am.tag = [this_am.tag ; srcs(s_i).*ones(size(src(s_i).tod))];
         %             figure_(22); plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:)); logx; logy; hold('on');
         %             pause(.025)
      end
      % rfit best AOD and plot in black dots every 20 nm for this am and time.
      if max(this_am.nm) < 1200
         this_am.nm = [this_am.nm; 1640]; %try excluding 615 nm from fit due to ozone
         this_am.aod = [this_am.aod; mean(ttau2.aod_1p6(these_m & s_ & wl_))];
         this_am.tag = [this_am.tag ; srcs(1)];
      end
      nm_615 = find(this_am.nm>610 & this_am.nm<620);
      this_am.nm(nm_615) = [];this_am.aod(nm_615) = [];
      [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm(~isnan(this_am.aod)),...
         this_am.aod(~isnan(this_am.aod)), wl_out, mad_factor);
      %         figure_(22);plot(wl_out, aod_fit,'k--');pause(.025)
      %         lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
      AM_leg.time_UT = [AM_leg.time_UT; this_am.time_UT];
      AM_leg.time_LST = [AM_leg.time_LST; this_am.time_LST];
      AM_leg.aod_fit = [AM_leg.aod_fit; aod_fit];
      AM_leg.oam = [AM_leg.oam; mean(ttau2.oam(these_m))];
      AM_leg.pres_atm = [AM_leg.pres_atm; mean(ttau2.pres_atm(these_m))];
      AM_leg.nm = unique([AM_leg.nm; this_am.nm]);
      AM_leg.tag = unique([AM_leg.tag; this_am.tag]);
      this_i = find(these_m, 1,'last')+1;
   end % of AM leg
   AM_range = max(AM_leg.oam)-min(AM_leg.oam);
   if ~isfield(llegs2,AM_str)&&isavar('AM_leg')&&length(AM_leg.oam)>10&&(AM_range>3)&&(min(AM_leg.oam)<3.5)&&(max(AM_leg.oam)>4.5)
      llegs2.(AM_str)=AM_leg;
   end

   % Start PM leg

   this_i = find(this_day & (serial2Hh(ttau2.time_LST)>(noon+.5)),1,'first');
   %    this_j = find(this_day & (serial2Hh(ttau2.time_LST')'>(noon+.5)),1,'last');
   while  ~isempty(this_i) && this_i < length(day)&& (this_i < find(this_day,1,'last'))%
      %         figure_(22); set(gcf,'visible','off')
      these_m = day==dates(dd) & (serial2Hh(ttau2.time_LST')' > (noon+.5)) & abs(ttau2.oam-ttau2.oam(this_i))<.2;
      srcs = unique(ttau2.src(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
      % Loop over all unique sources, taking mean of each source by wl
      % Plotting each in a different color.
      clear this_am src
      this_am.tag = []; this_am.nm = []; this_am.aod = [];  this_am.tod = [];
      this_am.time_UT = mean(ttau2.time(these_m));
      this_am.time_LST = mean(ttau2.time_LST(these_m));
      %         clf; cla; hold('on')
      %                 title({[datestr(mean(ttau2.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', PM airmass = %2.1f',mean(ttau2.oam(these_m)))];...
      %             ['Sources: ',srcs_str]});
      for s_i = 1:length(srcs) % check that srcs is the right orientation
         src(s_i).str = src_str(srcs(s_i));
         s_ = ttau2.src==srcs(s_i);
         wls = unique(ttau2.nm(these_m & s_));
         src(s_i).nm = wls;
         for wl_i = 1:length(wls)
            wl_ = ttau2.nm == wls(wl_i);
            src(s_i).aod(wl_i,1) = mean(ttau2.aod(these_m & s_ & wl_));
            src(s_i).tod(wl_i,1) = mean(ttau2.tod(these_m & s_ & wl_));
         end
         this_am.aod = [this_am.aod; src(s_i).aod];
         this_am.nm = [this_am.nm; src(s_i).nm'];
         this_am.tag = [this_am.tag ; srcs(s_i).*ones(size(src(s_i).aod))];
         %             figure_(22);plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:));
         %             logx; logy; hold('on');set(gcf,'visible','off');
         %              pause(.025);
      end
      % Fit best AOD and plot in black dots every 20 nm for this am and time.
      % Save best fit AOD
      if max(this_am.nm) < 1200
         this_am.aod = [this_am.aod; mean(ttau2.aod_1p6(these_m & s_ & wl_))];
         this_am.nm = [this_am.nm; 1640];
         this_am.tag = [this_am.tag ; srcs(1)];
      end
      nm_615 = find(this_am.nm>610 & this_am.nm<620);
      this_am.nm(nm_615) = [];this_am.aod(nm_615) = [];
      %         [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm;this_am.nm], [this_am.aod;this_am.aod], wl_out, mad_factor);
      [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm(~isnan(this_am.aod)),...
         this_am.aod(~isnan(this_am.aod)), wl_out, mad_factor);
      %         figure_(22); plot(wl_out, aod_fit, 'r--');pause(.025); set(fig22,'visible','on')
      %         lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
      PM_leg.time_UT = [PM_leg.time_UT; this_am.time_UT];
      PM_leg.time_LST = [PM_leg.time_LST; this_am.time_LST];
      PM_leg.aod_fit = [PM_leg.aod_fit; aod_fit];
      PM_leg.oam = [PM_leg.oam; mean(ttau2.oam(these_m))];
      PM_leg.pres_atm = [PM_leg.pres_atm; mean(ttau2.pres_atm(these_m))];
      PM_leg.nm = unique([PM_leg.nm; this_am.nm]);
      PM_leg.tag = unique([PM_leg.tag; this_am.tag]);
      this_i = find(these_m, 1,'last')+1;
   end % of PM leg
   PM_range = max(PM_leg.oam)-min(PM_leg.oam);
   if ~isfield(llegs2,PM_str)&&length(PM_leg.oam)>10&&(PM_range>3)&&(min(PM_leg.oam)<3.5)&&(max(PM_leg.oam)>4.5)
      llegs2.(PM_str)=PM_leg;
   end
   length(dates) - dd
   dd = dd +1;
end


tags = fieldnames(dirbeams2);
for tg = length(tags):-1:1
   tag = tags{tg}
   pause(.5)
   dbeam = dirbeams2.(tag);

   langs2.pname = dbeam.pname;
   langs2.fname = dbeam.fname;
   langs2.nm = [];
   langs2.time_UT = []; langs2.time_LST = [];
   langs2.ngood = [];
   langs2.min_oam = [];
   langs2.max_oam = [];
   langs2.Co = [];
   langs2.Co_uw = [];
   leg_name = fieldnames(llegs2);
   for L = 1:length(leg_name)
      disp(num2str(length(leg_name)-L))
      leg = llegs2.(leg_name{L});
      %       wl_x = interp1(leg.wl, [1:length(leg.wl)],[1020,1700],'nearest');
      title_str = leg_name{L}; disp(title_str);
      %        figure_(9); title(title_str);
      for wl_ii = length(dbeam.wls):-1:1
         nm = dbeam.wls(wl_ii);
         L_ = (dbeam.time>=leg.time_UT(1))&(dbeam.time<=leg.time_UT(end));
         if sum(L_)>4
            WL.nm = nm; WL.AU = mean(dbeam.AU(L_));WL.pres_atm = mean(leg.pres_atm);
            WL.time = dbeam.time(L_); WL.time_LST = dbeam.time_LST(L_); WL.dirt = dbeam.dirt(wl_ii,L_);
            WL.oam = dbeam.oam(L_);
            nonan = ~isnan(WL.dirt); WL.dirt = WL.dirt(nonan);
            WL.time = WL.time(nonan); WL.time_LST = WL.time_LST(nonan); WL.oam = WL.oam(nonan);

            %Interpolate leg.aod_fit (in log-log space) to match wl of filter
            % Probably also interpolate in time to match times of mfr "minl" but in this case it is 1:1
            % Also, interpolate atm_pres_hPa from leg to wl, scale rayOD
            WL.RayOD = rayleigh_ht(nm./1000);
            aod_fit = exp(interp1(log(leg.wl), log(leg.aod_fit'), log(nm),'linear'))';
            WL.aod = interp1(leg.time_UT, aod_fit, WL.time','linear')';
            WL.iT_g = exp(WL.RayOD.*WL.pres_atm.*WL.oam); % Inverse gas transmittance (so multiply by instead of divide)
            if ~isempty(WL.oam)&&~isempty(WL.aod)&&~isempty(WL.iT_g)&&~isempty(WL.dirt)
               [Co,~,Co_, ~, good] = dbl_lang(WL.oam.*WL.aod,WL.iT_g.*WL.dirt,2.25,[],1,0);
               if ~isempty(Co) && ~isempty(good) && any(good)
%                   aod_lang = -log(WL.dirt./mean([Co, Co_]))./WL.oam - WL.RayOD.*WL.pres_atm;
                  %             figure_(9); plot(WL.time(good), aod_lang(good),'.'); legend(num2str(nm));dynamicDateTicks; hold('on'); title(title_str);
                  if (sum(good)>=10) && ((max(WL.oam(good))./min(WL.oam(good)))>=2.75)||((max(WL.oam(good))-min(WL.oam(good)))>2.75)
                     langs2.nm(end+1) = nm;
                     langs2.time_UT(end+1) = mean(WL.time(good)) ;
                     langs2.time_LST(end+1) = mean(WL.time_LST(good));
                     langs2.ngood(end+1) = sum(good);
                     langs2.min_oam(end+1) = min(WL.oam(good));
                     langs2.max_oam(end+1) = max(WL.oam(good));
                     langs2.Co(end+1) = Co;
                     langs2.Co_uw(end+1) = Co_;
                     langs2.pres_atm = WL.pres_atm;
                  end
               end
            end
         end
      end
   end
   if ~isempty(langs2.time_UT)
      [~, ~, langs2.AU, ~, ~, ~, ~] = sunae(0, 0, langs2.time_UT);
   else
      disp('empty time_UT');
   end
   langs2.Co_AU = langs2.Co;
   langs2.tag = dbeam.tag;
   Vos2.(dbeam.tag) = langs2;
   rVos2.(dbeam.tag) = rVos_from_lang_Vos(Vos2.(dbeam.tag), 21,1);
   % So now interpolate these daily rVos2s to the native times of their respective
   % dbeam, and compute dirt and tod
   dbeam.Vo_AU =interp1(rVos2.(dbeam.tag).time_UT, rVos2.(dbeam.tag).Vo_AU',dbeam.time, 'nearest')';
   dbeam.oam(dbeam.oam<0|dbeam.oam>10) = NaN;
   dbeam.dirt = dbeam.dirt./dbeam.Vo_AU;
   dbeam.tod = -log(dbeam.dirt)./(ones(size(dbeam.wls'))*dbeam.oam);
   dbeam.rod = rayleigh_ht(dbeam.wls'./1000)*dbeam.pres_atm;
   dbeam.aod = dbeam.tod - dbeam.rod;
   dbeams.(dbeam.tag) = dbeam;
   % And one last best-fit?  Yes, I think.
end
% Then Vo2, rVo2, dirbeams2 (including tod, rod, aod, agod?)
% Then compare anet to dirbeam2.anet.aod



% By now, we've recalibrated all tags (original AOD and new from dirbeam)
% Now, compute new BE using all available AOD streams.
% Then recalibrate all again, compare
% Does it make any sense or matter if we compute BE one last time from these?


% Next action: compute AOD from all dirbeam sources with these robust Vos.
% Visually better when comparing ttau (collected measurements from aeronet, MFRSR C1, and MFRSR E13_
% to AODs (TOD-Ray) from the recalibrated systems

% Add tau-lang cals of SASHe VIS and NIR channels:
% vis: 340,355, 368, 387, 408, 415, 440, 500, 532, 615, 650, 673, 762, 870, 910, 975
% nir: 976, 1020, 1030, 1225, 1550, 1625, 1637

% Also, check what to do with gas subtractions.
%
% Check MFRSR Ozone vs OMI vs Cimel over a year each, SGP and HOU

% Evaluate multi-variate fit of Cimel AOD vs a + b*RH + c*mean_PBL_RH + d*rh*log(scat)
% Compare to Cimel Lunar

end

function [ttau, src_str] = get_ttau
ttau.time = [];
ttau.time_LST = [];
ttau.airmass = [];
ttau.pres_atm = [];
ttau.nm = [];
ttau.aod = [];
ttau.srctag = [];

src = 0;

cimfile = getfullname('*.*','anet_aod_v3','Select Aeronet file with AODs');
[pname, ~]= fileparts(cimfile);
pname = [pname, filesep]; pname = strrep(pname, [filesep, filesep], filesep);
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
      ttau.pres_atm = [ttau.pres_atm; cim.Pressure_hPa(good)];
      ttau.nm = [ttau.nm; wl.*ones(size(cim.time(good)))];
      ttau.srctag = [ttau.srctag; src.*ones(size(cim.time(good)))];
      ttau.aod = [ttau.aod; cim.(aods{f})(good)];
      if isfield(cim,'Site_Latitude_Degrees')
         ttau.Lat = unique(cim.Site_Latitude_Degrees);
         ttau.Lat = ttau.Lat(1);
      end
      if isfield(cim,'Site_Longitude_Degrees')
         ttau.Lon = unique(cim.Site_Longitude_Degrees);
         ttau.Lon = ttau.Lon(1);
      end
   end
   cimfile = getfullname('*.*','anet_aod_v3');
end

mfr_files = getfullname('*aod1mich*','aod1mich','Select ARM file with AODs');
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
      if isfield(mfr.vdata,'lat')
         ttau.Lat = unique(mfr.vdata.lat);
         ttau.Lat = ttau.Lat(1);
      end
      if isfield(mfr.vdata,'lon')
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


if ~isfield(ttau,'time_LST')
   ttau.time_LST = ttau.time - 6.5/24; % Assume SGP
end
if ~isfield(ttau,'srctag')&&isfield(ttau,'src')
   ttau.srctag = ttau.src; ttau = rmfield(ttau,'src');
end

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

% save ttau
%   save(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\sgp\SGP_TTAU_20180801_20190731_2.mat'],'-struct','ttau')

end
function lang_legs = build_lang_legs(ttau)
src_str = ttau.src_str;
wl_out = [300:20:1740];
AM_leg.wl = wl_out;
PM_leg.wl = wl_out;
mad_factor = 3;
noon = 12;

day = floor(ttau.time_LST);
dates = unique(floor(ttau.time_LST));

lang_legs.mt = []; lang_legs = rmfield(lang_legs, 'mt');
dd = 1;
% while dd <= length(dates)
% % trim dates with insufficient number of points and airmass range
% % Identify all unique wavelengths at which valid AODs are reported
% % Interpolate these over all output time spacings.
% end
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
   while ~isempty(this_i) && this_i < length(day) && serial2Hh(ttau.time_LST(this_i')') < (noon-.5) && this_i < find(this_day,1,'last')%
      % Find "these_m" within +/- 0.1 airmass
      these_m = day==dates(dd) & (serial2Hh(ttau.time_LST')' < (noon-.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.2;
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

   % Start PM leg
   these_aods = this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)) & ttau.nm==500;
   this_i = find(this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)),1,'first');
   this_j = find(this_day & (serial2Hh(ttau.time_LST')'>(noon+.5)),1,'last');
   while  ~isempty(this_i) && this_i < length(day)&& (this_i < find(this_day,1,'last'))%
      %         figure_(22); set(gcf,'visible','off')
      these_m = day==dates(dd) & (serial2Hh(ttau.time_LST')' > (noon+.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.2;
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
   length(dates) - dd
   dd = dd +1;
end
% Save lang_legs...
%    save(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\sgp\SGP_LLegs_20180801_20190731_2.mat'],'-struct','lang_legs');

end


function dirbeam = load_dirbeam(dirbeam_files)

if ~isavar('dirbeam_files')
   dirbeam_files = getfullname('*.*','dir_beam','Select direct beam file(s)');
end
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
         save([pname, fname, '.mat'],'-struct','infile');
      end
      %       if length(dirbeam_files)==1

      %       elseif length(dirbeam_files)>1
      %          last_date = datestr(infile.time(end), 'yyyymmdd');
      %          [~,emanf] = strtok(fliplr(fname),'.');
      %          fname = fliplr(emanf); fname(end) = '_';
      %          fname = [fname, last_date];
      %          save([pname, fname, '.mat'],'-struct','infile');
      %       end
   else
      infile = read_cimel_aod_v3(test);
   end
   dirbeam.pname = pname; dirbeam.fname = fname;
   dirbeam.time = []; dirbeam.wl = []; dirbeam.dirn = []; dirbeam.oam = []; dirbeam.AU = [];
   if isfield(infile,'vdata')
      [~, ~, ~, ~, ~, ~, oam] = sunae(infile.vdata.lat, infile.vdata.lon, infile.time);
      infile = anc_sift(infile, oam>0 & oam<=10);
      [~, ~, AU, ~, ~, ~, oam] = sunae(infile.vdata.lat, infile.vdata.lon, infile.time);
      if isfield(infile.vdata, 'direct_normal_vis') % It is sashevis file
         WL = [340,355,368,387,408,415,440,500,532,615,650,673,762,870,910,975];
         wl_i = interp1(infile.vdata.wavelength_vis, [1:length(infile.vdata.wavelength_vis)],WL,'nearest');
         WL_nm = infile.vdata.wavelength_vis(wl_i);
         for ww = 1:length(WL)
            dirn = infile.vdata.direct_normal_vis(wl_i(ww),:);
            dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+WL_nm(ww)];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      elseif isfield(infile.vdata, 'direct_normal_nir') % It is sashenir file
         WL = [976,1020,1030,1225,1550,1625,1637];
         wl_i = interp1(infile.vdata.wavelength_nir, [1:length(infile.vdata.wavelength_nir)],WL,'nearest');
         WL_nm = infile.vdata.wavelength_nir(wl_i);
         for ww = 1:length(WL)
            dirn = infile.vdata.direct_normal_nir(wl_i(ww),:);
            dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+WL_nm(ww)];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      elseif isfield(infile.vdata,'direct_normal_transmittance') %it is sashe aod file
         if min(infile.vdata.wavelength) < 500
            WL = [340,355,368,387,408,415,440,500,532,615,650,673,762,870,910,975];
         else
             WL = [976,1020,1030,1225,1550,1625,1637];
         end
         wl_i = interp1(infile.vdata.wavelength, [1:length(infile.vdata.wavelength)],WL,'nearest');
         WL_nm = infile.vdata.wavelength(wl_i);
         for ww = 1:length(WL)
            dirn = infile.vdata.direct_normal_transmittance(wl_i(ww),:);
            dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+WL_nm(ww)];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      elseif isfield(infile.vdata, 'direct_normal_415nm') % It is sashe mfr file
         WL = [415, 500, 615, 673, 870];
         for f = 1:5
            WL_nm = WL(f);
            dirn = infile.vdata.(['direct_normal_',num2str(WL_nm),'nm']);
            dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+WL_nm];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      elseif isfield(infile.vdata,'direct_normal_narrowband_filter1')
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
            if isfield(infile.gatts,'filter1_CWL_measured')
               wl = sscanf(infile.gatts.(['filter',num2str(f),'_CWL_measured']), '%f');
            elseif isfield(infile.vatts.wavelength_filter1,'centroid_wavelength')
               wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).centroid_wavelength,'%f');
            elseif isfield(infile.vatts.wavelength_filter1,'actual_wavelength')
               wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).actual_wavelength,'%f');
            end
            dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+wl];
            dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
            dirbeam.oam = [dirbeam.oam, oam(dirn>0)];
            dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
         end
      end
   else % now handle anet
      fields = fieldnames(infile);
      fields = fields(foundstr(fields,'AOD_')); fields = fields(foundstr(fields,'_Total'));
      if isfield(infile,'time')
         time = infile.time;
      elseif isfield(infile, 'time_UT')
         time = infile.time_UT;
      end
      [~, ~, AU, ~, ~, ~, ~] = sunae(0, 0, time');
      for fld = 1:length(fields)
         field = fields{fld};
         dirn = infile.(field)';
         dirbeam.time =[dirbeam.time, infile.time(dirn>0)'];
         wl = sscanf(field,'AOD_%f');
         dirbeam.wl = [dirbeam.wl,zeros(size(dirn(dirn>0)))+wl];
         dirbeam.dirn = [dirbeam.dirn, exp(-dirn(dirn>0).*infile.Optical_Air_Mass(dirn>0)')];
         % isn't this really "dirt"?
         dirbeam.oam = [dirbeam.oam, infile.Optical_Air_Mass(dirn>0)'];
         dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
      end
   end
   [dirbeam.time, ij] = sort(dirbeam.time);
   if isfield(infile,'Site_Longitude_Degrees')
      tz = double(infile.Site_Longitude_Degrees(1)/15)./24;
   elseif isfield(infile.vdata, 'lon')
      tz = double(infile.vdata.lon/15)./24;
   end
   tz = floor(24.*tz)./24;
   dirbeam.time_LST = dirbeam.time + tz;
   dirbeam.wl = dirbeam.wl(ij);
   dirbeam.wls = unique(dirbeam.wl);
   dirbeam.dirn = dirbeam.dirn(ij);
   dirbeam.oam = dirbeam.oam(ij);
   dirbeam.AU = dirbeam.AU(ij);
   % Assign tag
   if (foundstr(dirbeam.fname,'C1.c1')||foundstr(dirbeam.fname,'C1.b1'))&&foundstr(dirbeam.fname, 'mfrsr')
      dirbeam.tag = 'mfrC1';
   elseif foundstr(dirbeam.fname, 'M1.c1')&&foundstr(dirbeam.fname, 'mfrsr')
      dirbeam.tag = 'mfrM1';
   elseif foundstr(dirbeam.fname, 'M1.b1')&&foundstr(dirbeam.fname, 'mfrsr')
      dirbeam.tag = 'mfrM1b1';
   elseif (foundstr(dirbeam.fname, 'mfrsr')&&(foundstr(dirbeam.fname, 'E13.c1'))||foundstr(dirbeam.fname, 'E13.b1'))
      dirbeam.tag = 'mfrE13';
   elseif foundstr(dirbeam.fname, 'nimfr') && foundstr(dirbeam.fname, '.b1')
      dirbeam.tag = 'nimfrb1';
   elseif foundstr(dirbeam.fname, 'nimfr') && foundstr(dirbeam.fname, '.c1')
      dirbeam.tag = 'nimfr';
   elseif foundstr(dirbeam.fname, 'sashemfr')
      dirbeam.tag = 'sashemfr';
   elseif foundstr(dirbeam.fname, 'sashevis')
      dirbeam.tag = 'sashevis';
   elseif foundstr(dirbeam.fname, 'sashenir')
      dirbeam.tag = 'sashenir';
   elseif foundstr(dirbeam.fname, 'ARM')
      dirbeam.tag = 'anet';
   else
      dirbeam.tag = 'anon';
   end
end
end

function [dirbeams, langs, Vos, rVos] = calc_Vos_from_dirbeam(dirbeam, lang_legs)

while ~isempty(dirbeam)
   langs.pname = dirbeam.pname;
   langs.fname = dirbeam.fname;
   langs.nm = [];
   langs.time_UT = []; langs.time_LST = [];
   langs.ngood = [];
   langs.min_oam = [];
   langs.max_oam = [];
   langs.Co = [];
   langs.Co_uw = [];
   leg_name = fieldnames(lang_legs);
   for L = 1:length(leg_name)
      leg = lang_legs.(leg_name{L});
      %          wl_x = interp1(leg.wl, [1:length(leg.wl)],[1020,1700],'nearest');
      title_str = leg_name{L}; disp(title_str);
      %        figure_(9); title(title_str);
      for wl_ii = length(dirbeam.wls):-1:1
         nm = dirbeam.wls(wl_ii);
         L_ = (dirbeam.wl==nm)&(dirbeam.time>=leg.time_UT(1))&(dirbeam.time<=leg.time_UT(end));
         if sum(L_)>4
            WL.nm = nm; WL.AU = mean(dirbeam.AU(L_));WL.pres_atm = mean(leg.pres_atm);
            WL.time = dirbeam.time(L_); WL.time_LST = dirbeam.time_LST(L_); WL.dirn = dirbeam.dirn(L_);
            WL.oam = dirbeam.oam(L_);

            %Interpolate leg.aod_fit (in log-log space) to match wl of filter
            % Probably also interpolate in time to match times of mfr "minl" but in this case it is 1:1
            % Also, interpolate atm_pres_hPa from leg to wl, scale rayOD
            WL.RayOD = rayleigh_ht(nm./1000);
            aod_fit = exp(interp1(log(leg.wl), log(leg.aod_fit'), log(nm),'linear'))';
            WL.aod = interp1(leg.time_UT, aod_fit, WL.time','linear')';
            WL.iT_g = exp(WL.RayOD.*WL.pres_atm.*WL.oam); % Inverse gas transmittance (so multiply by instead of divide)
            %                try
            if ~isempty(WL.oam)&&~isempty(WL.aod)&&~isempty(WL.iT_g)&&~isempty(WL.dirn)
               [Co,~,Co_, ~, good] = dbl_lang(WL.oam.*WL.aod,WL.iT_g.*WL.dirn,2.25,[],1,0);
               aod_lang = -log(WL.dirn./mean([Co, Co_]))./WL.oam - WL.RayOD.*WL.pres_atm;
               %             figure_(9); plot(WL.time(good), aod_lang(good),'.'); legend(num2str(nm));dynamicDateTicks; hold('on'); title(title_str);
               if ~isempty(Co)&&~isempty(Co_)&&sum(good)>=10 && ...
                     (((max(WL.oam(good))./min(WL.oam(good)))>=2.75)||...
                     ((max(WL.oam(good))-min(WL.oam(good)))>2.75))
                  langs.nm(end+1) = nm;
                  langs.time_UT(end+1) = mean(WL.time(good)) ;
                  langs.time_LST(end+1) = mean(WL.time_LST(good)) ;
                  langs.ngood(end+1) = sum(good);
                  langs.min_oam(end+1) = min(WL.oam(good));
                  langs.max_oam(end+1) = max(WL.oam(good));
                  langs.pres_atm = WL.pres_atm;
                  langs.Co(end+1) = Co;
                  langs.Co_uw(end+1) = Co_;
               end
            end
            %                catch
            %                   warning('Try, catch tripped.  Possible issue with polyfit within dbl_lang')
            %                end
         end
      end
      %       pause(.125); close(9);
      %       end
   end
   if ~isempty(langs.time_UT)
      [~, ~, langs.AU, ~, ~, ~, ~] = sunae(0, 0, langs.time_UT);
   else
      disp('empty time_UT');
   end
   %The following lines attempt to address the fact that anet and sashe*aod direct beam is 
   % transmittance derived from the AODs rather than direct normal irradiance.
   % Transmittance already has AU correction built in so set Co_AU = Co.
   if foundstr(langs.fname, 'mfr')||(foundstr(langs.fname, 'sashe')&&~foundstr(langs.fname,'aod'))
      langs.Co_AU = langs.Co.*(langs.AU.^2);
   elseif (foundstr(langs.fname, 'sashe')&&foundstr(langs.fname,'aod'))
      langs.Co_AU = langs.Co;
   else
      langs.Co_AU = langs.Co;
   end
   langs.tag = dirbeam.tag;
   save([langs.pname, langs.fname, '_Vo.mat'],'-struct','langs');
   Vos.(dirbeam.tag) = langs;
   rVos.(dirbeam.tag) = rVos_from_lang_Vos(Vos.(dirbeam.tag), 21,1);
   dirbeams.(dirbeam.tag) = dirbeam;
   dirbeam = load_dirbeam;
end
pname = langs.pname; pname(end)= [];
pname = fileparts(pname); [pname, fname] = fileparts(pname);
pname = [pname, filesep, fname, filesep];
save([pname, upper(fname), '_rVos.mat'],'-struct','rVos');
save([pname, upper(fname), '_DirBeams.mat'],'-struct','dirbeams');
end



function [ttau2,dirbeams] = calc_ttau2_dbeams(ttau, dirbeams, rVos)

ttau2.time = [];
ttau2.time_LST = [];
ttau2.oam = [];
ttau2.pres_atm = [];
ttau2.nm = [];
ttau2.tod = [];
ttau2.aod = [];
ttau2.src = [];
ttau2.srcs = [];
tags = fieldnames(rVos);
ttau2.srcs = tags;
[ttime, ij] = unique(ttau.time);pres_atms = ttau.pres_atm(ij);
ttime(isnan(pres_atms)) = []; pres_atms(isnan(pres_atms)) = [];
for t = 1:length(tags)
   tag = tags{t};
   Vo = rVos.(tag);
   if isavar('dirbeams')&&isfield(dirbeams,tag)
      dirbeam = dirbeams.(tag);
   else
      if isfield(Vo,'pname')&&isfield(Vo,'fname')
         dname = getfullname([Vo.pname, Vo.fname, '*.mat'], tag,'Select dirbeam file(s)');
      else
         dname = getfullname(['*.*'], tag,'Select dirbeam file(s)');
      end
      dirbeam = load_dirbeam(dname);
   end
   dirbeam.Vo_AU = NaN([length(Vo.nm),length(dirbeam.AU)]);

   for nm_i = length(dirbeam.wls):-1:1
      wl_ = dirbeam.wl==dirbeam.wls(nm_i);
      dirbeam.Vo_AU(nm_i,wl_) = interp1(Vo.time_UT, Vo.Vo_AU(nm_i,:),dirbeam.time(wl_),'nearest');
   end
   % I think this line was introduced to handle ANET values that are derived from TOD
   % and thus represent direct transmitance, so don't require AU correction
   % But it might also be useful for SASHe files that have direct_trans also
   if ~isfield(dirbeam,'dirt') && isfield(dirbeam,'dirn') && isfield(dirbeam, 'AU');
      dirbeam.dirt = (dirbeam.dirn.*dirbeam.AU.^2)./dirbeam.Vo_AU;
   else
      dirbeam.dirt = dirbeam.dirt./dirbeam.Vo_AU;
   end
   dirbeam.oam(dirbeam.oam<0|dirbeam.oam>10) = NaN;
   dirbeam.tod = -log(dirbeam.dirt)./dirbeam.oam;

   % Right here we should compact the dirbeam to exclude redundant times and NaNs, etc.
   dbeams.pname = dirbeam.pname; dbeams.fname = dirbeam.fname; dbeams.tag = dirbeam.tag;
   dbeams.time = unique(dirbeam.time); dbeams.time_LST = unique(dirbeam.time_LST);
   dbeams.wls = dirbeam.wls;
   dbeams.oam = NaN(size(dbeams.time)); dbeams.AU = NaN(size(dbeams.time));
   dbeams.dirt = NaN([length(dirbeam.wls),length(dbeams.time)]);
   dbeams.tod = NaN([length(dirbeam.wls),length(dbeams.time)]);

   for w = length(dirbeam.wls):-1:1
      these = ~isnan(dirbeam.tod(w,:));
      ds = interp1(dbeams.time, [1:length(dbeams.time)],dirbeam.time(these),'nearest');
      dbeams.dirt(w,ds) = dirbeam.dirt(w,these);
      dbeams.tod(w,ds) = dirbeam.tod(w,these);
      dbeams.oam(ds) = dirbeam.oam(these);
      dbeams.AU(ds) = dirbeam.AU(these);
   end

   allnan = (all(isnan(dbeams.tod)));
   dbeams.time(allnan)= []; dbeams.time_LST(allnan)= [];
   dbeams.tod(:,allnan) = []; dbeams.dirt(:,allnan) = [];
   dbeams.oam(allnan) = [];dbeams.AU(allnan) = [];
   dbeams.pres_atm =interp1(ttime, pres_atms, dbeams.time, 'nearest', 'extrap');
   rod = rayleigh_ht(dbeams.wls./1000)';
   dbeams.aod = dbeams.tod-(rod*dbeams.pres_atm);
   % should we compute rod and aod?
   dirbeams.(tag) = dbeams; clear dirbeam

   % then make ttau2 (from all these dbeams)
   for nm = length(dbeams.wls):-1:1
      wl = dbeams.wls(nm);
      ttau2.time = [ttau2.time, dbeams.time];
      ttau2.time_LST = [ttau2.time_LST, dbeams.time_LST];
      ttau2.oam = [ttau2.oam,dbeams.oam];
      ttau2.pres_atm = [ttau2.pres_atm, dbeams.pres_atm];
      ttau2.nm = [ttau2.nm, wl.*ones(size(dbeams.time))];
      ttau2.src = [ttau2.src, t.*ones(size(dbeams.time))];
      ttau2.tod = [ttau2.tod, dbeams.tod(nm,:)];
      ttau2.aod = [ttau2.aod, dbeams.aod(nm,:)];
   end
   % now sort them...
   [ttau2.time, ij] = sort(ttau2.time);
   ttau2.time_LST = ttau2.time_LST(ij);
   ttau2.oam = ttau2.oam(ij);
   ttau2.pres_atm = ttau2.pres_atm(ij);
   ttau2.nm = ttau2.nm(ij);
   ttau2.src = ttau2.src(ij);
   ttau2.tod = ttau2.tod(ij);
   ttau2.aod = ttau2.aod(ij);
end

% Then build the 1.6 um continuous stream just in case one doesn't select any dbeams
% containing 1.6

sub_1u.time = ttau2.time(ttau2.nm > 1000 & ttau2.nm < 1200);
sub_1u.aod = ttau2.aod(ttau2.nm > 1000 & ttau2.nm < 1200);
[sub_1u.time, ij] = sort(sub_1u.time); sub_1u.aod = sub_1u.aod(ij);

sub_1p6.time = ttau2.time(ttau2.nm > 1400);
sub_1p6.aod = ttau2.aod(ttau2.nm > 1400);
[sub_1p6.time, ij] = sort(sub_1p6.time); sub_1p6.aod = sub_1p6.aod(ij);

for ij = length(sub_1u.time):-1:2
   n = 1;
   if sub_1u.time(ij-1)==sub_1u.time(ij)
      n = n+1;
      sub_1u.time(ij) = [NaN];
      sub_1u.aod(ij-1) = sub_1u.aod(ij-1)+sub_1u.aod(ij); sub_1u.aod(ij) = [NaN];
   else
      sub_1u.aod(ij) = sub_1u.aod(ij)./n;
   end
end
for ij = length(sub_1p6.time):-1:2
   n = 1;
   if sub_1p6.time(ij-1)==sub_1p6.time(ij)
      n = n+1;
      sub_1p6.time(ij) = [NaN];
      sub_1p6.aod(ij-1) = sub_1p6.aod(ij-1)+sub_1p6.aod(ij); sub_1p6.aod(ij) = [NaN];
   else
      sub_1p6.aod(ij) = sub_1p6.aod(ij)./n;
   end
end
nans = isnan(sub_1u.time)|isnan(sub_1u.aod);
sub_1u.time(nans) = []; sub_1u.aod(nans) = [];
nans = isnan(sub_1p6.time)|isnan(sub_1p6.aod);
sub_1p6.time(nans) = []; sub_1p6.aod(nans) = [];
%     [sub_1u.time, ij] = unique(sub_1u.time); sub_1u.aod = sub_1u.aod(ij);
%     [sub_1p6.time, ij] = unique(sub_1p6.time); sub_1u.aod = sub_1p6.aod(ij);
% So sub_1u and sub_1p6 should be free of duplicate times and contain averaged values
% of aod in place of dup times.

LW.time = ttau2.time;
LW.aod_1p6 = interp1(sub_1p6.time, sub_1p6.aod, ttau2.time,'linear');
LW.aod_1u = interp1(sub_1u.time, sub_1u.aod, ttau2.time,'linear');
bad = isnan(LW.aod_1p6) | isnan(LW.aod_1u) |(LW.aod_1p6./LW.aod_1u > .95);
gtime = LW.time(~bad); gaod = LW.aod_1p6(~bad);
[gtime, ij] = unique(gtime); gaod = gaod(ij);
LW.aod_1p6(bad) =interp1(gtime, gaod, LW.time(bad), 'nearest','extrap');
ttau2.aod_1p6 = LW.aod_1p6; clear LW


end
%