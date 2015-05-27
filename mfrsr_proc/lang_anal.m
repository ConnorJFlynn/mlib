function [lang, langplot,old, new] = lang_anal(arg)
%Modify to remove AM/PM as a separate field.
% Replace with a binary flag PM, ~PM
% Add time field centered on airmass in AM or PM
% Remove conditional based on tolerances, but store fit_test results. 
% lang will have at most two time records per day, one per atmos leg.
% two langplots will be generated, one per atm leg.
% Work with 3 months of data?
%[what] = lang_anal(arg)
old = struct;
new = struct;
if ~exist('arg','var')
   arg = setarg;
end
if isfield(arg, 'mfr')
   if ~isstruct(arg.mfr)&exist(arg.mfr,'file')
      mfr = ancload(arg.mfr);
   elseif isfield(arg.mfr,'fname')
      if exist(arg.mfr.fname,'file')
         mfr = ancload(arg.mfr.fname);
      else
         mfr = ancload;
      end
   else
      mfr = ancload;
   end
else
   mfr = ancload;
end
if isfield(arg, 'swanal')
   swanal = arg.swanal;
else
   swanal = [];
end
if isfield(arg, 'Vo')
   Vo = arg.Vo;
else
   Vo = NaN;
end

[zen, az, r_au, ha, dec, el, airmass] = sunae(mfr.vars.lat.data, mfr.vars.lon.data, mfr.time+5/(24*60*60));
% Compute tau using some nominal calibration

nulls = (mfr.vars.cordirnorm_filter2.data<=0)|(el<=0);
V = mfr.vars.cordirnorm_filter2.data .* r_au.^2;
V(nulls) = NaN;
if ~isnan(Vo)
   tau = (log(Vo) - log(V)) .* cos(zen*pi/180);
   [skyflag.sunny, eps] = alex_screen(mfr.time, tau);
else
   skyflag.sunny = ones(size(mfr.time))>0;
   eps = zeros(size(mfr.time));
end
%get corresponding swflux anal file (or be flux?)
if ~isempty(swanal)
   sw_file = dir([swanal.pname, swanal.fstem,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
   if length(sw_file)>0
      swanal = ancload([swanal.pname, sw_file(1).name]);
      [mfr.vars.clearsky] = swanal.vars.flag_clearsky_detection;
      mfr.vars.clearsky.data = flagor(swanal.time, swanal.vars.flag_clearsky_detection.data, mfr.time);
      mfr.vars.clearsky.data = (mfr.vars.clearsky.data > .5);
      skyflag.clearsky = mfr.vars.clearsky.data;
   else
      disp(['   No swfwanal file found for ', datestr(mfr.time(1),'YYYY-mm-DD')]);
      disp(['   Proceeding as though clear.']);
      skyflag.clearsky = true;
   end
   %Set clearsky to true if NaN
   NaNs = isnan(skyflag.clearsky);
   skyflag.clearsky(NaNs) = true;
   
end
skyflag.allclear = skyflag.sunny & skyflag.clearsky;
skyflag.name = {'sunny', 'clearsky', 'allclear'};
ofnoon.AM = az<180 & el>0;
ofnoon.PM = az>180 & el>0;
ofnoon.name = {['AM'], ['PM']};

min_airmass = [1.5:.5:3];
max_airmass = [5:6];
am_num = 0;
% Compute airmass range limits
for a_min = 1:length(min_airmass)
   for a_max = 1:length(max_airmass)
      am_num = am_num+1;
      airmass_min(am_num) = min_airmass(a_min);
      airmass_max(am_num) = max_airmass(a_max);
   end
end

t = 0;
for dayleg = 2:-1:1
   t = t+1;
   %Assign a time to the lang file regardless of whether data exists.
   lang.time(t)   = floor(mfr.time(1)) + .25+(dayleg-1)/2;
   if any(ofnoon.(char(ofnoon.name(dayleg))))
      %But only assign times to langplot if this AM/PM leg exists
      langplot.time = mfr.time(ofnoon.(char(ofnoon.name(dayleg)))>0);
      langplot.good = (zeros([length(langplot.time),2,length(airmass_min)])>1);
      %Data points exist for this AM/PM leg, so do langleys
      for am_num = length(airmass_min):-1:1
         for sky = 3:-1:1;
            old.Vo(t, am_num, sky) = NaN;
            old.tau(t,am_num,sky) = NaN;
            old.P(t,am_num,sky) = {NaN([1,2])};
            old.fit_test(t,am_num,sky)= {''};
            new.Vo(t, am_num, sky) = NaN;
            new.tau(t,am_num,sky) = NaN;
            new.P(t,am_num,sky) = {NaN([1,2])};
            new.fit_test(t,am_num,sky)= {''};
            
            mass = (airmass>=airmass_min(am_num)) ...
               & (airmass<= airmass_max(am_num)) ...
               & ofnoon.(char(ofnoon.name(dayleg)));

            good = mass  & skyflag.(char(skyflag.name(sky)));
            lang.midtime(t,am_num,sky) = mean(mfr.time(good));
            langplot.good(good,am_num,sky) = true;
            if any(good)
               V = mfr.vars.cordirnorm_filter2.data(good) .* r_au(good).^2;
               [Vo, tau, P, fit_test] = old_lang(airmass(good), V);
               old.Vo(t,am_num,sky) = Vo;
               old.tau(t,am_num,sky) = tau;
               old.P(t,am_num,sky)= {P};
               old.fit_test(t,am_num,sky) = {fit_test};
               old.goodfit(t,am_num,sky) = (old.fit_test{t,am_num,sky}.rsquare >=.99 & old.fit_test{t,am_num,sky}.rmse<=0.01);
               [Vo, tau, P, fit_test] = new_lang(airmass(good), V);
               new.Vo(t,am_num,sky) = Vo;
               new.tau(t,am_num,sky) = tau;
               new.P(t,am_num,sky)= {P};
               new.fit_test(t,am_num,sky) = {fit_test};
               new.goodfit(t,am_num,sky) = (new.fit_test{t,am_num,sky}.rsquare >=.99 & new.fit_test{t,am_num,sky}.rmse<=0.01);
               {char(ofnoon.name(dayleg)),char(skyflag.name(sky)), ['airmass = [',num2str(airmass_min(am_num)),':',num2str(airmass_max(am_num)),']']}
               disp(['Vo: ', num2str(old.Vo(t,am_num,sky)),', ', num2str(new.Vo(t,am_num,sky))]);
               disp(['tau: ',num2str(old.tau(t,am_num,sky)), ', ', num2str(new.tau(t,am_num,sky))]);
               disp(['Goodfit: ', num2str(old.goodfit(t,am_num,sky)), ', ', num2str(new.goodfit(t,am_num,sky))]);
            end
         end %of skyflag loop 
      end % airmass loop
   else %There isn't any data for this AM/PM leg so... 
      %define NaNs for langley values since no data
   end
end % of AM/PM loop
return

function [Vo, tau,P,fit_test] = old_lang(airmass, V);
   [P,fit_test] = fit(airmass',real(log(V')),fittype('poly1'));
   tau = -P.p1;
   Vo = exp(feval(P, 0));
   %figure; plot(airmass, log_V, '.', airmass, feval(cf_, airmass),
   %'r')
% [P,S] = polyfit(airmass, real(log(V)), 1);
% [Y,DELTA] = polyval(P,0,S);
% Vo = exp(Y);
% tau = -P(1);
return

   function [Vo,tau,P,fit_test] = new_lang(airmass, V);
      [P,fit_test] = fit(1./airmass',real(log(V'))./airmass',fittype('poly1'));
      Vo = exp(P.p1);
      tau = -feval(P,0);
%       [P,S] = polyfit(1./airmass, real(log(V))./airmass, 1);
%       Vo = exp(P(1));
%       y_int = polyval(P, 0, S);
%       tau = -y_int;
      return

      function arg = setarg;
         pname = 'D:\case_studies\new_xmfrx_proc\alive\sgpmfrsrC1\b1\solarday\';
         arg.mfr.fname =[pname,'sgpmfrsrC1.a0.20050427.060000.nc' ];
         arg.mfr.fname = [pname, 'sgpmfrsrC1.a0.20050729.060000.nc'];
         % arg.Vo
         arg.swanal.pname = ['D:\case_studies\new_xmfrx_proc\alive\sgp1swfanal\'];
         arg.swanal.fstem = 'sgp1swfanalbrs1longC1.c1.';
         arg.Vo = 1800;
         return