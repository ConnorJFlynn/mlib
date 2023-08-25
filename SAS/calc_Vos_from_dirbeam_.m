function [dirbeams, langs, Vos, rVos] = calc_Vos_from_dirbeam_(dirbeam, lang_legs)
%Evaluating two approaches:
% 1) calc_Vos_from_dirbeam_ Independent dlb Langley for each wavelength
% 2) dbl_lang for 1 (or two?) wavelengths then apply identified "good" airmass screen
% to all wavelengths equally

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
      % The approach below computes independent langleys for each filter. Better is perhaps
      % to compute for one or two, take the intersection of the resulting "good" airmasses,
      % and apply to all wavelengths
      % Something like:        [Co,od,Co_, od_, good1] = dbl_lang(WL.oam.*WL.aod,WL.iT_g.*WL.dirn,2.25,[],1,0);


      for wl_ii = length(dirbeam.wls):-1:1
         nm = dirbeam.wls(wl_ii);
         L_ = (dirbeam.wl==nm)&(dirbeam.time>=leg.time_UT(1))&(dirbeam.time<=leg.time_UT(end));
         if sum(L_)>4 && length(L_)==length(dirbeam.AU)&&length(L_)==length(dirbeam.dirn)
            WL.nm = nm; WL.AU = mean(dirbeam.AU(L_));WL.pres_atm = mean(leg.pres_atm);
            WL.time = dirbeam.time(L_); WL.time_LST = dirbeam.time_LST(L_); WL.dirn = dirbeam.dirn(L_);
            WL.oam = dirbeam.oam(L_);

            WL.RayOD = rayleigh_ht(nm./1000);
            aod_fit = exp(interp1(log(leg.wl), log(leg.aod_fit'), log(nm),'linear'))';
            WL.aod = interp1(leg.time_UT, aod_fit, WL.time','linear')';
            WL.iT_g = exp(WL.RayOD.*WL.pres_atm.*WL.oam); % Inverse gas transmittance (so multiply by instead of divide)
            %                try
            if ~isempty(WL.oam)&&~isempty(WL.aod)&&~isempty(WL.iT_g)&&~isempty(WL.dirn)
               [Co,od,Co_, od_, good] = dbl_lang(WL.oam.*WL.aod,WL.iT_g.*WL.dirn,2.25,[],1,0);
               aod_lang = -log(WL.dirn./mean([Co, Co_]))./WL.oam - WL.RayOD.*WL.pres_atm;
               ndCo = (abs(Co-Co_) ./ abs(Co+Co_)./2)<1e3; 
               phys_aod = max(aod_lang)<5 & min(aod_lang)>0;
               %             figure_(9); plot(WL.time(good), aod_lang(good),'.'); legend(num2str(nm));dynamicDateTicks; hold('on'); title(title_str);
               if ~isempty(Co)&&~isempty(Co_)&&sum(good)>=10 && ...
                     (((max(WL.oam(good))./min(WL.oam(good)))>=2.25)||...
                     ((max(WL.oam(good))-min(WL.oam(good)))>2.25)) && ndCo && phys_aod && Co>0 && Co_>1e-4
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
         end
      end

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
