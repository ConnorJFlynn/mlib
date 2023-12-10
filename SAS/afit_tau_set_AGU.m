function [all_legs, ttau] = afit_tau_set_AGU(ttau, show)
% [lang_legs, ttau] = afit_tau_set_AGU(ttau, show)
% Modifying afit_lang_tau_series_sgp to use for AGU, zenradcal stuff.
% Removing Langley related.  Just use initial part to aggregate AOD from Cimel and
% MFRSR7nch.  Must use cloud-screened version of both.

% step 1: compose a time series of aod from one or more confident sources
% step 2: apply aod-fit in 0.1 airmass increments (for each day? instead of leg, remove LW and 940 nm)
% step 3: Plot good AODs and ttau to see how well they agree.
% step 4: Once they agree well enough, return AOD 415 time series.
% step 5: Merge with MFRSR DDR time series
% step 6: Compute SSA (and zrad?)


% https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_zenith_radiance_v3?site=ARM_SGP&year=2023&month=1&day=1&year2=2023&month2=12&day2=31&ZEN00=1&AVG=10&if_no_html=1

if isavar('show')&&~isempty(show)&show
   show = true;
else
   show = false;
end

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
         ttau.pres_atm = [ttau.pres_atm; cim.Pressure_hPa(good)];
         ttau.nm = [ttau.nm; wl.*ones(size(cim.time(good)))];
         ttau.srctag = [ttau.srctag; src.*ones(size(cim.time(good)))];
         ttau.aod = [ttau.aod; cim.(aods{f})(good)];
         if isfield(cim,'Site_Latitude_Degrees'),
            ttau.Lat = unique(cim.Site_Latitude_Degrees);
            ttau.Lat = ttau.Lat(1);
         end
         if isfield(cim,'Site_Longitude_Degrees'),
            ttau.Lon = unique(cim.Site_Longitude_Degrees);
            ttau.Lon = ttau.Lon(1);
         end
      end
      cimfile = getfullname('*.*','anet_aod_v3');
   end

   mfr_files = getfullname('*mfr*.mat','aod1mich');
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
      mfr_files = getfullname('*mfr*.mat','aod1mich');
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
   noon = 12;
   src_color = colororder;src_color;
   day = floor(ttau.time_LST);
   dates = unique(floor(ttau.time_LST));
end
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
% end

dd = 1;
nms = unique(round(10.*ttau.nm)./10);
wl_out = unique([[300:20:1040],nms(nms<550)']);
day_leg.wl = wl_out;
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
      day_str = ['Date_',datestr(dates(dd),'yyyymmdd')];
      this_day = day==dates(dd)&ttau.airmass<8;
      this_i = find(this_day,1);
      %     src_str{unique(ttau.srctag(this_day))}
     day_leg.airmass = []; day_leg.pres_atm = []; day_leg.aod_fit = []; day_leg.time_UT = []; day_leg.time_LST = []; day_leg.nm = []; day_leg.src = [];
      %% day leg
      while ~isempty(this_i) && this_i < length(day) && this_i < max(find(this_day)) %
         % Find "these_m" within +/- 0.1 airmass
         these_m = day==dates(dd) & abs(ttau.airmass-ttau.airmass(this_i))<.1 & abs(ttau.time_LST-ttau.time_LST(this_i))<(5./(24*60));
         srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
         % Loop over all unique sources, taking mean of each source by wl
         % Plotting each in a different color.
         clear this_am src
         this_am.src = []; this_am.nm = []; this_am.aod = [];
         this_am.time_UT = mean(ttau.time(these_m));
         this_am.time_LST = mean(ttau.time_LST(these_m));
         if show
                 figure_(22); clf; cla; hold('on');
                 title({[datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', AM airmass = %2.1f',mean(ttau.airmass(these_m)))];...
                     ['Sources: ',srcs_str]});
         end
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
            if show
                        figure_(22); plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:)); logx; logy; hold('on');
                        pause(.025)
            end
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
         % this_am.aod(this_am.nm>1100) = []; this_am.nm(this_am.nm>1100) = [];
         [aod_fit, good_wl_, fit_rms, fit_bias] = rfit_aod_basis([this_am.nm], [this_am.aod], wl_out, mad_factor);
         if show
                 figure_(22);plot(wl_out, aod_fit,'k--');pause(.025)
                 lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
         end
         day_leg.time_UT = [day_leg.time_UT; this_am.time_UT];
         day_leg.time_LST = [day_leg.time_LST; this_am.time_LST];
         day_leg.aod_fit = [day_leg.aod_fit; aod_fit];
         day_leg.airmass = [day_leg.airmass; mean(ttau.airmass(these_m))];
         day_leg.pres_atm = [day_leg.pres_atm; mean(ttau.pres_atm(these_m))];
         day_leg.nm = unique([day_leg.nm; this_am.nm]);
         day_leg.src = unique([day_leg.src; this_am.src]);
         this_i = max(find(these_m))+1;
      end % of AM leg
      if ~isfield(lang_legs,day_str)&&isavar('day_leg')&&length(day_leg.airmass)>10
         lang_legs.(day_str)=day_leg;
      end
      if show
         figure_(23);plot(day_leg.time_LST, day_leg.aod_fit(:,6),'.');pause(.025)
         dynamicDateTicks;  lg = legend('aod_fit 415 nm'); set(lg,'interp','none');pause(.01)
      end
      dd = dd +1
   end
end
leg_names = fieldnames(lang_legs);
all_legs = lang_legs.(leg_names{1});
all_legs = rmfield(all_legs,{'nm','src'});
for LN = 2:length(leg_names)
   legx = lang_legs.(leg_names{LN});
   all_legs.airmass = [all_legs.airmass; legx.airmass];
   all_legs.pres_atm = [all_legs.pres_atm; legx.pres_atm];
   all_legs.time_LST = [all_legs.time_LST; legx.time_LST];
   all_legs.time_UT = [all_legs.time_UT; legx.time_UT];
   all_legs.aod_fit = [all_legs.aod_fit; legx.aod_fit];
end
[all_legs.time_UT,ij] = sort(all_legs.time_UT);
all_legs.time_LST = all_legs.time_LST(ij);
all_legs.airmass = all_legs.airmass(ij);
all_legs.pres_atm = all_legs.pres_atm(ij);
all_legs.aod_fit = all_legs.aod_fit(ij,:);
all_legs.aod_615 = exp(interp1(log(all_legs.wl(16:17)),log(all_legs.aod_fit(:,16:17)'),log(615),'linear'))'; 
all_legs.rod_615 = rayleigh_ht(615./1000).*all_legs.pres_atm;

o3_615_du_od = 2.5738e+03;


end


% function dirbeam = load_dirbeam 
% 
% dirbeam_files = getfullname('*.*','dir_beam','Select direct beam file(s)');
% dirbeam = [];
% if ~isempty(dirbeam_files)
%    if iscell(dirbeam_files)
%       test = dirbeam_files{1};
%    else
%       test = dirbeam_files;
%    end
%    [pname, fname, ext] = fileparts(test); pname = strrep([pname, filesep], [filesep, filesep], filesep);
% 
%    if any(foundstr(ext,'.mat'))||any(foundstr(ext,'.nc'))||any(foundstr(ext,'.cdf'))
%       probably xmfrx file
%       if any(foundstr(ext,'.mat'))
%          infile = load(test);
%       else
%          infile = anc_bundle_files(dirbeam_files);
%       end
%       if length(dirbeam_files)==1
%          save([pname, fname, '.mat'],'-struct','infile');
%       elseif length(dirbeam_files)>1
%          last_date = datestr(infile.time(end), 'yyyymmdd');
%          [~,emanf] = strtok(fliplr(fname),'.');
%          fname = fliplr(emanf); fname(end) = '_';
%          fname = [fname, last_date];
%          save([pname, fname, '.mat'],'-struct','infile');
%       end
%    else
%       infile = read_cimel_aod_v3(test);
%    end
%    dirbeam.pname = pname; dirbeam.fname = fname; 
%    dirbeam.time = []; dirbeam.wl = []; dirbeam.dirn = []; dirbeam.oam = []; dirbeam.AU = [];
%    if isfield(infile,'vdata')
%       [~, ~, AU, ~, ~, ~, oam] = sunae(infile.vdata.lat, infile.vdata.lon, infile.time);
%       if isfield(infile.vdata,'direct_normal_narrowband_filter1')
%          for f = 1:5
%             dirn = infile.vdata.(['direct_normal_narrowband_filter',num2str(f)]);
%             dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
%             if isfield(infile.gatts,'filter1_CWL_measured')
%                wl = sscanf(infile.gatts.(['filter',num2str(f),'_CWL_measured']), '%f');
%             elseif isfield(infile.vatts.wavelength_filter1,'centroid_wavelength')
%                wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).centroid_wavelength,'%f');
%             elseif isfield(infile.vatts.wavelength_filter1,'actual_wavelength')
%                wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).actual_wavelength,'%f');
%             end
%             dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+wl];
%             dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
%             dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
%          end
%       end
%       if isfield(infile.vdata,'direct_normal_narrowband_filter7')
%          for f = 7
%             dirn = infile.vdata.(['direct_normal_narrowband_filter',num2str(f)]);
% 
%          dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
%             if isfield(infile.gatts,'filter1_CWL_measured')
%                wl = sscanf(infile.gatts.(['filter',num2str(f),'_CWL_measured']), '%f');
%             elseif isfield(infile.vatts.wavelength_filter1,'centroid_wavelength')
%                wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).centroid_wavelength,'%f');
%             elseif isfield(infile.vatts.wavelength_filter1,'actual_wavelength')
%                wl = sscanf(infile.vatts.(['wavelength_filter',num2str(f)]).actual_wavelength,'%f');
%             end
%          dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+wl];
%          dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
%          dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)]
%          end
%       end
%    else % now handle anet 
%       fields = fieldnames(infile);
%       fields = fields(foundstr(fields,'AOD_')); fields = fields(foundstr(fields,'_Total'));
%       [~, ~, AU, ~, ~, ~, ~] = sunae(0, 0, infile.time');
%       for fld = 1:length(fields)
%          field = fields{fld};
%          dirn = infile.(field)'; 
%          dirbeam.time =[dirbeam.time, infile.time(dirn>0)'];
%          wl = sscanf(field,'AOD_%f');
%          dirbeam.wl = [dirbeam.wl,zeros(size(dirn(dirn>0)))+wl];
%          dirbeam.dirn = [dirbeam.dirn, exp(-dirn(dirn>0).*infile.Optical_Air_Mass(dirn>0)')];
%          dirbeam.oam = [dirbeam.oam, infile.Optical_Air_Mass(dirn>0)'];
%          dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
%       end
% 
%    end
%    [dirbeam.time, ij] = sort(dirbeam.time); 
%    dirbeam.wl = dirbeam.wl(ij);
%    dirbeam.wls = unique(dirbeam.wl);
%    dirbeam.dirn = dirbeam.dirn(ij);
%    dirbeam.oam = dirbeam.oam(ij); 
%    dirbeam.AU = dirbeam.AU(ij);
% 
%    end
% end
% 
% load a datastream containing N time-series direct solar measurements.
% This function recognizes and parses anet and xmfrx files to obtain direct normal or
% direct transmission at all provided wavelengths and populates a consistent struct
% with tag, time, wavelength, airmass, and direct beam (normal or transmittance) in
% similar organization as ttau; namely single dimensioned, sorted but non-unique
% times, one per WL at a given airmass.  within afit_lang_tau_series, we'll
% interpolate the fitted aod values in lang_leg in log-log space in wl and then
% linearly in airmass to produce tau_lang inputs for dbl_lang.
% 
% Initial idea, use getfilename.  if not empty, check first file.  
% If ext = .nc .cdf or .mat assume it is an xmfrx type file
% check for direct_normal_transmittance fields.  
% If any, read 1-5 and 7 if exist along with wavelengths. 
% If no *transmittance*, then read direct_normal_narrowband 1-5 and 7 if exist.
% if not xmfrx, assume anet.  Identify AODs.  (careful!  Look at both AOD and TOT
% files to ensure logic is robust and precise)
% Compute and populate airmass and AU from sunae(time, lat, lon)


