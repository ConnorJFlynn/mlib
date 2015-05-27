function [lang] = lang_anal2(arg)
% 2008-01-08: changing default clear sky to false in absence of SWFLUXANAL
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

[fpath, fname, ext] = fileparts(mfr.fname);
[site, dstem, fac, dlevel, ddate] = splitarmname([fname,ext]);
lang.fname = [fpath,filesep,'langley',filesep,site,dstem,'langley',fac,'.cc1.',datestr(ddate,'yyyymmdd.HHMMss'),'.nc'];

if ~exist([fpath, filesep, 'langplot'],'dir')
   mkdir(fpath, 'langplot');
end
if ~exist([fpath, filesep, 'langley'],'dir')
   mkdir(fpath, 'langley');
end

mfr = preclean_mfr(mfr); %remove baggage
[zen, az, r_au, ha, dec, el, airmass] = sunae(mfr.vars.lat.data, mfr.vars.lon.data, mfr.time+5/(24*60*60));
mfr.vars.zen_angle.data = zen;
mfr.vars.cos_zen.data = cos(zen*pi/180);
mfr.vars.az_angle.data = az;
mfr.vars.r_au.data = r_au;
mfr.vars.el_angle = mfr.vars.zen_angle;
mfr.vars.el_angle.data = el;
mfr.vars.el_angle.atts.long_name.data = 'solar elevation angle';
mfr.vars.hour_angle.data = ha;
mfr.vars.hour_angle.dims = mfr.vars.time_offset.dims;
mfr.vars.hour_angle.atts = mfr.vars.time_offset.atts;
mfr.vars.hour_angle.atts.long_name.data = 'hour_angle';
mfr.vars.hour_angle.atts.long_name.datatype = 2;
mfr.vars.hour_angle.atts.units.data = 'degrees';
mfr.vars.hour_angle.atts.units.datatype = 2;
mfr.vars.airmass.data = airmass;

% Compute tau using some nominal calibration

%Use nominal 500 nm channel for cloud screen
nulls = (mfr.vars.cordirnorm_filter2.data<=0)|(el<=0);
V = mfr.vars.cordirnorm_filter2.data .* r_au.^2;
V(nulls) = NaN;
mfr.vars.skytest.data = zeros(size(mfr.time));
mfr.vars.skytest.datatype = 1;
if ~isnan(Vo)
   tau = (log(Vo) - log(V)) .* cos(zen*pi/180);
   [aero, mfr.vars.eps.data] = aod_screen(mfr.time, tau);
   mfr.vars.skytest.data = bitset(mfr.vars.skytest.data,1,aero);
else
   mfr.vars.skytest.data = bitset(mfr.vars.skytest.data,1);
   mfr.vars.eps.data = zeros(size(mfr.time));
end
%get corresponding swflux anal file (or be flux?)
if ~isempty(swanal)
   sw_file = dir([swanal.pname, swanal.fstem,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
   if length(sw_file)>0
      swanal = ancload([swanal.pname, sw_file(1).name]);
      %[mfr.vars.clearsky] = swanal.vars.flag_clearsky_detection;
      clearsky = flagor(swanal.time, swanal.vars.flag_clearsky_detection.data, mfr.time);
      clearsky = (clearsky > .5);
      mfr.vars.skytest.data = bitset(mfr.vars.skytest.data,2,clearsky);
   else
      disp(['   No swfwanal file found for ', datestr(mfr.time(1),'YYYY-mm-DD')]);
      disp(['   Proceeding as though cloudy.']);
      mfr.vars.skytest.data = bitset(mfr.vars.skytest.data,2,0);
   end
   %Set clearsky to false if NaN
   NaNs = isnan(mfr.vars.skytest.data);
   mfr.vars.skytest.data(NaNs) = bitset(mfr.vars.skytest.data(NaNs),2,0);
end
mfr.vars.skytest.atts.bit_1.data = 'sunny';
mfr.vars.skytest.atts.bit_2.data = 'clearsky';
mfr = clean_mfr_dod(mfr);
mfr = anccheck(mfr);

skyflag.name = {'sunny', 'clearsky'};
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

lang.arg.ch = 5;%Only do langley on filters 1-5, not broadband or 940nm
lang.arg.sky = 2; %Only two tests for sky, aero or clearsky
lang.arg.airmass_min = airmass_min;
lang.arg.airmass_max = airmass_max;
lang.atts = mfr.atts;
lang.recdim = mfr.recdim;
lang.dims.time = mfr.dims.time;
lang.vars.base_time = mfr.vars.base_time;
lang.vars.time_offset = mfr.vars.time_offset;
lang.vars.time = mfr.vars.time;
lang.vars.lat = mfr.vars.lat;
lang.vars.lon = mfr.vars.lon;
lang.vars.alt = mfr.vars.alt;
lang = spec_lang_dod(lang);
t = 3;
for dayleg = 2:-1:1
%     dayleg
   t = t-1;
   %Assign a time to the lang file regardless of whether data exists.
   %But only populate langplot if this AM/PM leg exists
   [max_el, noon] = max(mfr.vars.el_angle.data);
   lang.time(t)   = floor(24*mfr.time(noon))/24 - .25 + (dayleg-1)/2;
   lang.vars.PM.data(t) = (dayleg==2);
   if any(ofnoon.(char(ofnoon.name(dayleg))))
      langplot = ancsift(mfr, mfr.dims.time, (ofnoon.(char(ofnoon.name(dayleg)))>0));
      langplot.dims.time.length = length(langplot.time);
      langplot.vars.PM.data = (dayleg==2);
      langplot.vars.PM.datatype = 4;
      % the langplot.good flag will be of length time but with
      % additional dimensions to reflect airmass ranges
      arg.ch = 5;%Only do langley on filters 1-5, not broadband or 940nm
      arg.sky = 2; %Only two tests for sky, aero or clearsky
      arg.airmass_min = airmass_min;
      arg.airmass_max = airmass_max;
      langplot = spec_langplot_dod(langplot,arg);
      for ch = 5:-1:1
%           ch
         channel = ['cordirnorm_filter',num2str(ch)];
         channel_au = ['cordirnorm_filter',num2str(ch), '_1AU'];
         langplot.vars.(channel_au) = langplot.vars.(channel);
         langplot.vars.(channel_au).data = langplot.vars.(channel_au).data .* langplot.vars.r_au.data.^2;
         V = langplot.vars.(channel_au).data;

         %Data points exist for this AM/PM leg, so calculate the langleys
         for am_num = length(airmass_min):-1:1
%              am_num
            for sky = 2:-1:1;
%                 sky
               mass = (langplot.vars.airmass.data>=airmass_min(am_num)) ...
                  & (langplot.vars.airmass.data<= airmass_max(am_num)) ;
               good = mass &  bitget(langplot.vars.skytest.data,sky)&isfinite(V)&(V>0);
               %                !! Now do your bitmap thang

               if sum(good)<3
%                   lang.midtime(ch,sky,am_num,t) = mean(mfr.time(mass));
                  lang.midtime(ch,sky,am_num,t) = lang.time(t);                  
                  langplot.vars.good.data(am_num,:) = 0;
%                   disp([char(ofnoon.name(dayleg)), ', ',char(skyflag.name(sky)),', ', ['airmass = [',num2str(airmass_min(am_num)),':',num2str(airmass_max(am_num)),']']]);
%                   disp(['Number of pts: ', num2str(sum(good))]);
%                   disp('No fits!')

               else

                  lang.vars.midtime.data(ch,sky,am_num,t) = mean(langplot.time(good));
                  langplot.vars.good.data(am_num,good) = 1;
                  %                if any(good)
                  [old.Vo, old.tau, old.P, old.fit_test] = old_lang(langplot.vars.airmass.data(good), V(good));
                  old.goodfit = (old.fit_test.rsquare >=.99 & old.fit_test.rmse<=0.01);
                  figure(9); subplot(2,1,1); 
                  plot(serial2doy(mfr.time), mfr.vars.cordirnorm_filter2.data, '.')
                  subplot(2,1,2);
                  semilogy(langplot.vars.airmass.data(good), V(good), '.')
                  
                  langplot.vars.langley_Vo.data(ch,sky, am_num) = old.Vo;
                  langplot.vars.langley_tau.data(ch,sky,am_num) = old.tau;
                  langplot.vars.langley_P0.data(ch,sky,am_num) = old.P(1);
                  langplot.vars.langley_P1.data(ch,sky,am_num) = old.P(2);
                  langplot.vars.langley_rsquare.data(ch,sky,am_num) = old.fit_test.rsquare;
                  langplot.vars.langley_rmse.data(ch,sky,am_num) = old.fit_test.rmse;
                  langplot.vars.langley_goodfit.data(ch,sky,am_num) = old.goodfit;
                  
                  lang.vars.langley_Vo.data(ch,sky, am_num,t) = old.Vo;
                  lang.vars.langley_tau.data(ch,sky,am_num,t) = old.tau;
                  lang.vars.langley_P0.data(ch,sky,am_num,t) = old.P(1);
                  lang.vars.langley_P1.data(ch,sky,am_num,t) = old.P(2);
                  lang.vars.langley_rsquare.data(ch,sky,am_num,t) = old.fit_test.rsquare;
                  lang.vars.langley_rmse.data(ch,sky,am_num,t) = old.fit_test.rmse;
                  lang.vars.langley_goodfit.data(ch,sky,am_num,t) = old.goodfit;

                  [new.Vo, new.tau, new.P, new.fit_test] = new_lang(langplot.vars.airmass.data(good), V(good));
                  new.goodfit = (new.fit_test.rsquare >=.99 & new.fit_test.rmse<=0.01);
                  langplot.vars.unweight_Vo.data(ch,sky, am_num) = new.Vo;
                  langplot.vars.unweight_tau.data(ch,sky,am_num) = new.tau;
                  langplot.vars.unweight_P0.data(ch,sky,am_num) = new.P(1);
                  langplot.vars.unweight_P1.data(ch,sky,am_num) = new.P(2);
                  langplot.vars.unweight_rsquare.data(ch,sky,am_num) = new.fit_test.rsquare;
                  langplot.vars.unweight_rmse.data(ch,sky,am_num) = new.fit_test.rmse;
                  langplot.vars.unweight_goodfit.data(ch,sky,am_num) = double(new.goodfit);

                  lang.vars.unweight_Vo.data(ch,sky, am_num,t) = new.Vo;
                  lang.vars.unweight_tau.data(ch,sky,am_num,t) = new.tau;
                  lang.vars.unweight_P0.data(ch,sky,am_num,t) = new.P(1);
                  lang.vars.unweight_P1.data(ch,sky,am_num,t) = new.P(2);
                  lang.vars.unweight_rsquare.data(ch,sky,am_num,t) = new.fit_test.rsquare;
                  lang.vars.unweight_rmse.data(ch,sky,am_num,t) = new.fit_test.rmse;
                  lang.vars.unweight_goodfit.data(ch,sky,am_num,t) = new.goodfit;                  
%                   disp([char(ofnoon.name(dayleg)), ', ',char(skyflag.name(sky)),', ', ['airmass = [',num2str(airmass_min(am_num)),':',num2str(airmass_max(am_num)),']']]);
%                   disp(['Number of pts: ', num2str(sum(good))])
%                   disp(['Vo: ', num2str(old.Vo),', ', num2str(new.Vo)]);
%                   disp(['tau: ',num2str(old.tau), ', ', num2str(new.tau)]);
%                   disp(['Goodfit: ', num2str(old.goodfit), ', ', num2str(new.goodfit)]);
%                   disp(' ');
               end
            end %of skyflag loop
         end % airmass loop
      end %of loop over channel
   langplot = clean_langplot(langplot);
   langplot = anccheck(langplot);
   langplot.clobber = true;
%    langplot.vars.langley_goodfit.datatype = 1;
%    langplot.vars.unweight_goodfit.datatype = 1;
   status = ancsave(langplot);
   else %There isn't any data for this AM/PM leg so...
      %define NaNs for langley values since no data
   end

end % of AM/PM loop
lang = timesync(lang); lang = anccheck(lang);
lang.clobber = true; 
ancsave(lang);
return
end

function [Vo, tau,P,fit_test] = old_lang(airmass, V);
[P,fit_test] = fit(airmass',real(log(V')),fittype('poly1'));
tau = -P.p1;
Vo = exp(feval(P, 0));
%figure; plot(airmass, log_V, '.', airmass, feval(cf_, airmass),'r')
% [P,S] = polyfit(airmass, real(log(V)), 1);
% [Y,DELTA] = polyval(P,0,S);
% Vo = exp(Y);
% tau = -P(1);
return
end

function [Vo,tau,P,fit_test] = new_lang(airmass, V);
[P,fit_test] = fit(1./airmass',real(log(V'))./airmass',fittype('poly1'));
Vo = exp(P.p1);
tau = -feval(P,0);
%       [P,S] = polyfit(1./airmass, real(log(V))./airmass, 1);
%       Vo = exp(P(1));
%       y_int = polyval(P, 0, S);
%       tau = -y_int;
return
end

function mfr = preclean_mfr(mfr);
mfr.dims = rmfield(mfr.dims, 'bench_angle');
remove_fields = { 'bench_angle'
    'hemisp_broadband'
    'th_broadband'
    'hemisp_narrowband_filter1'
    'th_filter1'
    'hemisp_narrowband_filter2'
    'th_filter2'
    'hemisp_narrowband_filter3'
    'th_filter3'
    'hemisp_narrowband_filter4'
    'th_filter4'
    'hemisp_narrowband_filter5'
    'th_filter5'
    'hemisp_narrowband_filter6'
    'th_filter6'
    'diffuse_hemisp_broadband'
    'dif_broadband'
    'diffuse_hemisp_narrowband_filter1'
    'dif_filter1'
    'diffuse_hemisp_narrowband_filter2'
    'dif_filter2'
    'diffuse_hemisp_narrowband_filter3'
    'dif_filter3'
    'diffuse_hemisp_narrowband_filter4'
    'dif_filter4'
    'diffuse_hemisp_narrowband_filter5'
    'dif_filter5'
    'diffuse_hemisp_narrowband_filter6'
    'dif_filter6'
    'direct_normal_broadband'
    'direct_normal_narrowband_filter1'
    'direct_normal_narrowband_filter2'
    'direct_normal_narrowband_filter3'
    'direct_normal_narrowband_filter4'
    'direct_normal_narrowband_filter5'
    'direct_normal_narrowband_filter6'
    'direct_horizontal_broadband'
    'direct_horizontal_narrowband_filter1'
    'direct_horizontal_narrowband_filter2'
    'direct_horizontal_narrowband_filter3'
    'direct_horizontal_narrowband_filter4'
    'direct_horizontal_narrowband_filter5'
    'direct_horizontal_narrowband_filter6'
    'diff_corr_err_broadband'
    'diff_corr_err_filter1'
    'diff_corr_err_filter2'
    'diff_corr_err_filter3'
    'diff_corr_err_filter4'
    'diff_corr_err_filter5'
    'diff_corr_err_filter6'
    'SN_response_broadband'
    'SN_response_filter1'
    'SN_response_filter2'
    'SN_response_filter3'
    'SN_response_filter4'
    'SN_response_filter5'
    'SN_response_filter6'
    'WE_response_broadband'
    'WE_response_filter1'
    'WE_response_filter2'
    'WE_response_filter3'
    'WE_response_filter4'
    'WE_response_filter5'
    'WE_response_filter6'
};
for d = 1:length(remove_fields)
   mfr.vars = rmfield(mfr.vars, char(remove_fields{d}));
end
return
end

function mfr = clean_mfr_dod(mfr);
%%
% mfr.vars.skytest.dims = {'time'};
% mfr.vars.skytest.atts.long_name.datatype = 2;
% mfr.vars.skytest.atts.units.datatype = 2;
% mfr.vars.skytest.atts.bit_1.datatype = 2;
% mfr.vars.skytest.atts.bit_2.datatype = 2;
% %%

%%

mfr.vars.skytest.dims = mfr.vars.time_offset.dims;
mfr.vars.skytest.datatype = 1;
mfr.vars.skytest.atts = mfr.vars.time_offset.atts;
mfr.vars.skytest.atts.long_name.data = 'Cloud-screen and clear-sky tests';
mfr.vars.skytest.atts.long_name.datatype = 2;
mfr.vars.skytest.atts.units.data = 'bitmap';
mfr.vars.skytest.atts.units.datatype = 2;
mfr.vars.skytest.atts.BIT_1.data = '1 = cloud-free direct beam';
mfr.vars.skytest.atts.BIT_1.datatype = 2;
mfr.vars.skytest.atts.BIT_2.data = '1 = hemispheric clear sky';
mfr.vars.skytest.atts.BIT_2.datatype = 2;

mfr.vars.eps.dims = mfr.vars.time_offset.dims;
mfr.vars.eps.datatype = 5;
mfr.vars.eps.atts = mfr.vars.time_offset.atts;
mfr.vars.eps.atts.long_name.data = 'variability parameter';
mfr.vars.eps.atts.long_name.datatype = 2;
mfr.vars.eps.atts.units.data = 'unitless';
mfr.vars.eps.atts.units.datatype = 2;
mfr.vars.eps.atts.description.data = 'typically cloud-free for eps<1e-4';
mfr.vars.eps.atts.description.datatype = 2;
return
end


%     1: byte, uchar, uint
%     2: char
%     3: short
%     4: long
%     5: float
%     6: double

function langplot = spec_langplot_dod(langplot, arg);
[fpath, filename, ext] = fileparts(langplot.fname);
% if ~exist([fpath, filesep, 'langplot'],'dir')
%    mkdir(fpath, 'langplot');
% end
[site, dstem, fac, dlevel, ddate] = splitarmname([filename,ext]);

if langplot.vars.PM.data
   leg = 'PM';
else
   leg = 'AM';
end
fstem = ['langplot',lower(leg)];
% [fstem, rest] = strtok(fname, '.');
fpath = [fpath, filesep, 'langplot'];
langplot.fname = fullfile(fpath,[site,fstem,fac,'.cc1.',datestr(ddate,'yyyymmdd.HHMMSS'),'.nc']);


% langplot.fname = fullfile(fpath,'langplot',[fstem, datestr(langplot.time(1), '.yyyymmdd.'),leg,ext]);

langplot.dims.channel.length = arg.ch; ch = arg.ch;
langplot.dims.channel.isunlim = false;
langplot.dims.airmass_range.length = length(arg.airmass_min); 
langplot.dims.airmass_range.isunlim = false;
langplot.dims.skyflag.id = 9;
langplot.dims.skyflag.length = arg.sky;
langplot.dims.skyflag.isunlim = false;

% langplot.dims.channel.id = 2;
langplot.vars.channel.data = [1:5]';
langplot.vars.channel.datatype = 1;
langplot.vars.channel.dims = {'channel'};
langplot.vars.channel.atts.long_name.data = 'channel number';
langplot.vars.channel.atts.long_name.datatype = 2;
langplot.vars.channel.atts.units.data = 'unitless';
langplot.vars.channel.atts.units.datatype = 2;

am_num = length(arg.airmass_min); 
langplot.dims.airmass_range.id = 8;
langplot.vars.airmass_range.data = [1:length(arg.airmass_min)]';
langplot.vars.airmass_range.datatype = 1;
langplot.vars.airmass_range.dims = {'airmass_range'};
langplot.vars.airmass_range.atts.long_name.data = 'combinations of upper and lower airmass limits';
langplot.vars.airmass_range.atts.long_name.datatype = 2;
langplot.vars.airmass_range.atts.units.data = 'unitless';
langplot.vars.airmass_range.atts.units.datatype = 2;


langplot.vars.PM.dims = langplot.vars.base_time.dims;
langplot.vars.PM.datatype = 1;
langplot.vars.PM.atts.long_name.data = 'AM/PM Flag';
langplot.vars.PM.atts.long_name.datatype = 2;
langplot.vars.PM.atts.units.data = 'boolean';
langplot.vars.PM.atts.units.datatype = 2;
langplot.vars.PM.atts.values.data = '0=AM, 1=PM';
langplot.vars.PM.atts.values.datatype = 2;

sky = arg.sky;

langplot.vars.skyflag.dims = {'skyflag'};
langplot.vars.skyflag.data = [1:arg.sky]';
langplot.vars.skyflag.datatype = 1;
langplot.vars.skyflag.atts.long_name.data = 'coordinate field for skyflag tests';
langplot.vars.skyflag.atts.long_name.datatype = 2;
langplot.vars.skyflag.atts.units.data = 'unitless';
langplot.vars.skyflag.atts.units.datatype = 2;
langplot.vars.skyflag.atts.values.data = '1=cloud-screened direct beam, 2=hemispheric clear sky';
langplot.vars.skyflag.atts.values.datatype = 2;

langplot.vars.airmass_min.data = arg.airmass_min';
langplot.vars.airmass_min.datatype = 5;
langplot.vars.airmass_min.dims = {'airmass_range'};
langplot.vars.airmass_min.atts.long_name.data = 'minimum airmass limit';
langplot.vars.airmass_min.atts.units.data = 'unitless';
langplot.vars.airmass_max.data = arg.airmass_max';
langplot.vars.airmass_max.datatype = 5;
langplot.vars.airmass_max.dims = {'airmass_range'};
langplot.vars.airmass_max.atts.long_name.data = 'maximum airmass limit';
langplot.vars.airmass_max.atts.units.data = 'unitless';

t = length(langplot.time);
langplot.vars.good.data = zeros(am_num,t);
langplot.vars.good.datatype = 1;
langplot.vars.good.dims = {'airmass_range', 'time'};
langplot.vars.good.atts.long_name.data = 'Data passing all criteria';
langplot.vars.good.atts.units.data = 'boolean';

langplot.vars.langley_Vo.data = NaN(ch,sky,am_num);
langplot.vars.langley_Vo.datatype = 5;
langplot.vars.langley_tau.data = NaN(ch,sky,am_num);
langplot.vars.langley_tau.datatype = 5;
langplot.vars.langley_P0.data = NaN(ch,sky,am_num);
langplot.vars.langley_P0.datatype = 5;
langplot.vars.langley_P1.data = NaN(ch,sky,am_num);
langplot.vars.langley_P1.datatype = 5;
langplot.vars.langley_rsquare.data = NaN(ch,sky,am_num);
langplot.vars.langley_rsquare.datatype = 5;
langplot.vars.langley_rmse.data = NaN(ch,sky,am_num);
langplot.vars.langley_rmse.datatype = 5;
langplot.vars.langley_goodfit.data= NaN(ch,sky,am_num);
langplot.vars.langley_goodfit.datatype = 1;
langplot.vars.langley_goodfit.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_Vo.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_tau.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_P0.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_P1.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_rsquare.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.langley_rmse.dims = {'channel','skyflag', 'airmass_range'};

langplot.vars.unweight_Vo.data = NaN(ch,sky, am_num);
langplot.vars.unweight_Vo.datatype = 5;
langplot.vars.unweight_tau.data = NaN(ch,sky,am_num);
langplot.vars.unweight_tau.datatype = 5;
langplot.vars.unweight_P0.data = NaN(ch,sky,am_num);
langplot.vars.unweight_P0.datatype = 5;
langplot.vars.unweight_P1.data = NaN(ch,sky,am_num);
langplot.vars.unweight_P1.datatype = 5;
langplot.vars.unweight_rsquare.data = NaN(ch,sky,am_num);
langplot.vars.unweight_rsquare.datatype = 5;
langplot.vars.unweight_rmse.data = NaN(ch,sky,am_num);
langplot.vars.unweight_rmse.datatype = 5;
langplot.vars.unweight_goodfit.data = NaN(ch,sky,am_num);
langplot.vars.unweight_goodfit.datatype = 1;
langplot.vars.unweight_Vo.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_tau.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_P0.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_P1.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_rsquare.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_rmse.dims = {'channel','skyflag', 'airmass_range'};
langplot.vars.unweight_goodfit.dims = {'channel','skyflag', 'airmass_range'};

return
end

function lang = spec_lang_dod(lang);
% [fpath, fname, ext] = fileparts(lang.fname);
% if ~exist([fpath, filesep, 'langley'],'dir')
%    mkdir(fpath, 'langley');
% end
% 
% [fstem, rest] = strtok(fname, '.');
% lang.fname = fullfile(fpath,'langley',[fstem, datestr(lang.time(1), '.yyyymmdd.'),ext]);
arg = lang.arg;
lang.recdim.length = 2;
lang.dims.time.length = 2;
lang.vars.base_time.data = [];
lang.vars.time_offset.data = [];
lang.vars.time.data = [];

lang.dims.channel.length = arg.ch; ch = arg.ch;
lang.dims.channel.isunlim = false;
%lang.dims.channel.id = 2;
lang.vars.channel.data = [1:5]';
lang.vars.channel.datatype = 1;
lang.vars.channel.dims = {'channel'};

lang.dims.airmass_range.length = length(arg.airmass_min); 
am_num = length(arg.airmass_min); 
lang.dims.airmass_range.id = 4;
lang.dims.airmass_range.isunlim = false;
lang.vars.airmass_range.data = [1:length(arg.airmass_min)]';
lang.vars.airmass_range.datatype = 1;
lang.vars.airmass_range.dims = {'airmass_range'};
lang.vars.airmass_min.data = arg.airmass_min';
lang.vars.airmass_min.datatype = 5;
lang.vars.airmass_min.dims = {'airmass_range'};
lang.vars.airmass_max.data = arg.airmass_max';
lang.vars.airmass_max.dims = {'airmass_range'};
lang.vars.airmass_max.datatype = 5;

lang.dims.skyflag.id = 3;
lang.dims.skyflag.isunlim = false;
 lang.dims.skyflag.length = arg.sky;sky = arg.sky;
 lang.vars.skyflag.dims = {'skyflag'};
 lang.vars.skyflag.data = [1:arg.sky]';
 lang.vars.skyflag.datatype = 1;
 lang.vars.skyflag.atts.values.data = '1=cloud-screened direct beam, 2=hemispheric clear sky';
 lang.vars.skyflag.atts.values.datatype = 2;
 
lang.vars.PM.dims = {'time'};
lang.vars.PM.datatype = 1;
lang.vars.PM.atts.long_name.data = 'AM/PM Flag';
lang.vars.PM.atts.values.data = '0=AM, 1=PM';

lang.vars.midtime = lang.vars.time;
lang.vars.midtime.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.midtime.datatype = lang.vars.time.datatype; 
t = 2;
lang.vars.midtime.data = NaN(ch,sky,am_num,t);

lang.vars.langley_Vo.data = NaN(ch,sky,am_num,t);
lang.vars.langley_tau.data = NaN(ch,sky,am_num,t);
lang.vars.langley_P0.data = NaN(ch,sky,am_num,t);
lang.vars.langley_P1.data = NaN(ch,sky,am_num,t);
lang.vars.langley_rsquare.data = NaN(ch,sky,am_num,t);
lang.vars.langley_rmse.data = NaN(ch,sky,am_num,t);
lang.vars.langley_goodfit.data= NaN(ch,sky,am_num,t);
lang.vars.langley_goodfit.datatype = 1;
lang.vars.langley_goodfit.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_Vo.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_tau.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_P0.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_P1.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_rsquare.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.langley_rmse.dims = {'channel','skyflag', 'airmass_range', 'time'};

lang.vars.unweight_Vo.data = NaN(ch,sky, am_num,t);
lang.vars.unweight_tau.data = NaN(ch,sky,am_num,t);
lang.vars.unweight_P0.data = NaN(ch,sky,am_num,t);
lang.vars.unweight_P1.data = NaN(ch,sky,am_num,t);
lang.vars.unweight_rsquare.data = NaN(ch,sky,am_num,t);
lang.vars.unweight_rmse.data = NaN(ch,sky,am_num,t);
lang.vars.unweight_goodfit.data= NaN(ch,sky,am_num,t);
lang.vars.unweight_goodfit.datatype = 1;
lang.vars.unweight_Vo.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_tau.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_P0.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_P1.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_rsquare.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_rmse.dims = {'channel','skyflag', 'airmass_range', 'time'};
lang.vars.unweight_goodfit.dims = {'channel','skyflag', 'airmass_range', 'time'};

return
end

function lang = clean_lang(lang);
% Pre-cleans the DOD such that anccheck requires no action

return
end

function langplot = clean_langplot(langplot);
% Pre-cleans the DOD such that anccheck requires no action
%%
langplot.dims.channel.isunlim = false;
langplot.dims.airmass_range.isunlim = false;
langplot.dims.skyflag.isunlim = false;
langplot.vars.PM.atts.units.datatype = 2;
langplot.vars.PM.atts.long_name.datatype = 2;
langplot.vars.PM.atts.values.datatype = 2;
langplot.vars.PM.atts.units.datatype = 2;
langplot.vars.PM.atts.long_name.datatype = 2;
langplot.vars.PM.atts.values.datatype = 2;
%%

return
end

function arg = setarg;
arg.pname = 'C:\case_studies\langley_anal\sgpmfrsrC1\b1\solarday\';
% arg.mfr.fname =[arg.pname,'sgpmfrsrC1.a0.20050427.060000.nc' ];
%arg.mfr.fname = [pname, 'sgpmfrsrC1.a0.20050729.060000.nc'];

arg.mfr.fname =[arg.pname,'sgpmfrsrC1.a0.20050430.060000.nc'];
% arg.Vo
arg.swanal.pname = ['C:\case_studies\langley_anal\sgp1swfanal\'];
arg.swanal.fstem = 'sgp1swfanalbrs1longC1.c1.';
arg.Vo = 1800;
return
end