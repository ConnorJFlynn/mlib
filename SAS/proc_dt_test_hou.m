function proc_dt_test 
zenir = rd_SAS_raw(getfullname('*sasze*nir*.csv'));
zevis = rd_SAS_raw(getfullname('*sasze*vis*.csv'));
% This is for second test for HOU as the first didn't work quite right bcuz nir tint hi was 450 ms
% which was longer than the 0.4 sec period, so filled with -9999

WD = 2.^16 -1; WD2 = .999.*WD;

tints = unique(zevis.t_int_ms);
if length(tints) ==2
   vlo = tints(1)
   vhi = tints(2);
% vlo = 2; vhi = 15;
end
dark_ = zevis.Shutter_open_TF==0; 
dark_(1:end-1) = dark_(1:end-1)&dark_(2:end); dark_(2:end) = dark_(1:end-1)&dark_(2:end);
dark_(1:end-1) = dark_(1:end-1)&dark_(2:end); dark_(2:end) = dark_(1:end-1)&dark_(2:end);
dark_lo = dark_ & zevis.t_int_ms==vlo; 
dark_hi = dark_ & zevis.t_int_ms==vhi;
lite_ = zevis.Shutter_open_TF==1; 
lite_(1:end-1) = lite_(1:end-1) & lite_(2:end); lite_(2:end) = lite_(1:end-1) & lite_(2:end);
lite_(1:end-1) = lite_(1:end-1) & lite_(2:end); lite_(2:end) = lite_(1:end-1) & lite_(2:end);
lite_(1:end-1) = lite_(1:end-1) & lite_(2:end); lite_(2:end) = lite_(1:end-1) & lite_(2:end);
lite_lo = lite_ & zevis.t_int_ms==vlo; 
lite_hi = lite_ & zevis.t_int_ms==vhi;

lo_darks = sum(dark_lo(1:end-1)&~dark_lo(2:end)); % dark intervals
lo_darks_i = find(dark_lo);
lo_dark.time = zeros([lo_darks,1]);
lo_dark.vspec = zeros([lo_darks,length(zevis.wl)]);
lo_dark.nspec = zeros([lo_darks,length(zenir.wl)]);
m = lo_darks_i(1); q = 0;p = 1;n = 1;
dtime = zenir.time(lo_darks_i(n));
vdark = zevis.spec(lo_darks_i(n),:);
ndark = zenir.spec(lo_darks_i(n),:);
% compute average darks for vis and nir lo
for n = 2:length(lo_darks_i) 
   if lo_darks_i(n)-m == 1
      dtime = dtime + zenir.time(lo_darks_i(n));
      vdark = vdark + zevis.spec(lo_darks_i(n),:);
      ndark = ndark + zenir.spec(lo_darks_i(n),:);
      p = p +1;
   else
      q = q+1;
      lo_dark.time(q) = dtime./p;
      lo_dark.nspec(q,:) = ndark./p;
      lo_dark.vspec(q,:) = vdark./p;
      p = 1;
      dtime = zenir.time(lo_darks_i(n));
      vdark = zevis.spec(lo_darks_i(n),:);
      ndark = zenir.spec(lo_darks_i(n),:);
   end
   m = lo_darks_i(n);
end

hi_darks = sum(dark_hi(1:end-1)&~dark_hi(2:end)); 
hi_darks_i = find(dark_hi);
hi_dark.time = zeros([hi_darks,1]);
hi_dark.vspec = zeros([hi_darks,length(zevis.wl)]);
hi_dark.nspec = zeros([hi_darks,length(zenir.wl)]);
m = hi_darks_i(1); q = 0;p = 1;n = 1;
dtime = zenir.time(hi_darks_i(n));
vdark = zevis.spec(hi_darks_i(n),:);
ndark = zenir.spec(hi_darks_i(n),:);
% compute average darks for vis and nir hi
for n = 2:length(hi_darks_i)
   if hi_darks_i(n)-m == 1
      dtime = dtime + zenir.time(hi_darks_i(n));
      vdark = vdark + zevis.spec(hi_darks_i(n),:);
      ndark = ndark + zenir.spec(hi_darks_i(n),:);
      p = p +1;
   else
      q = q+1;
      hi_dark.time(q) = dtime./p;
      hi_dark.nspec(q,:) = ndark./p;
      hi_dark.vspec(q,:) = vdark./p;
      p = 1;
      dtime = zenir.time(hi_darks_i(n));
      vdark = zevis.spec(hi_darks_i(n),:);
      ndark = zenir.spec(hi_darks_i(n),:);
   end
   m = hi_darks_i(n);
end

zenir.darks = zeros(size(zenir.spec));
% Interpolate dark_hi and dark_lo to lite_hi and lite_low for NIR
for vw = length(zenir.wl):-1:1
   intime = zenir.time(lite_hi);
   tmp = interp1(hi_dark.time, hi_dark.nspec(:,vw), intime,'linear'); nans = isnan(tmp);
   tmp(nans) = interp1(hi_dark.time, hi_dark.nspec(:,vw), intime(nans),'nearest','extrap');
   zenir.darks(lite_hi,vw) =tmp;

   intime = zenir.time(lite_lo);
   tmp = interp1(lo_dark.time, lo_dark.nspec(:,vw), intime,'linear'); nans = isnan(tmp);
   tmp(nans) = interp1(lo_dark.time, lo_dark.nspec(:,vw), intime(nans),'nearest','extrap');
   zenir.darks(lite_lo,vw) =tmp;   
end

% Interpolate dark_hi and dark_lo to lite_hi and lite_low for VIS
zevis.darks = zeros(size(zevis.spec));
for vw = length(zevis.wl):-1:1
   intime = zenir.time(lite_hi);
   tmp = interp1(hi_dark.time, hi_dark.vspec(:,vw), intime,'linear'); nans = isnan(tmp);
   tmp(nans) = interp1(hi_dark.time, hi_dark.vspec(:,vw), intime(nans),'nearest','extrap');
   zevis.darks(lite_hi,vw) =tmp;

   intime = zevis.time(lite_lo);
   tmp = interp1(lo_dark.time, lo_dark.vspec(:,vw), intime,'linear'); nans = isnan(tmp);
   tmp(nans) = interp1(lo_dark.time, lo_dark.vspec(:,vw), intime(nans),'nearest','extrap');
   zevis.darks(lite_lo,vw) =tmp;  
end

% Compute well-depths before subtracting darks to get sig or computing rates
zevis.wd = zevis.spec./WD; zevis.sig = zevis.spec - zevis.darks; 
zevis.rate(zevis.t_int_ms==vlo,:) = zevis.sig(zevis.t_int_ms==vlo,:)./unique(zevis.t_int_ms(zevis.t_int_ms==vlo));
zevis.rate(zevis.t_int_ms==vhi,:) = zevis.sig(zevis.t_int_ms==vhi,:)./unique(zevis.t_int_ms(zevis.t_int_ms==vhi));

zenir.wd = zenir.spec./WD; zenir.sig = zenir.spec - zenir.darks; 
zenir.rate(zevis.t_int_ms==vlo,:) = zenir.sig(zevis.t_int_ms==vlo,:)./unique(zenir.t_int_ms(zevis.t_int_ms==vlo));
zenir.rate(zevis.t_int_ms==vhi,:) = zenir.sig(zevis.t_int_ms==vhi,:)./unique(zenir.t_int_ms(zevis.t_int_ms==vhi));

% Now, plot both max spectra and adjust ranges to exclude edges and
% low/zero values.
figure; plot(zenir.wl, max(zenir.rate(zevis.t_int_ms==vlo,:)),'r-'); logy; zoom('on')
menu('Zoom as desired.  Points outside limits will be excluded.','OK, done'); nxl = axis; 
nxl_ = zenir.wl>nxl(1) & zenir.wl<nxl(2) & max(zenir.rate(zevis.t_int_ms==vlo,:))>nxl(3);

% shut_ = zevis.Shutter_open_TF==0; 
% shut_(1:end-1) = shut_(1:end-1)|shut_(2:end); shut_(2:end) = shut_(1:end-1)|shut_(2:end);
% shut_(1:end-1) = shut_(1:end-1)|shut_(2:end); shut_(2:end) = shut_(1:end-1)|shut_(2:end);
zenir.rate(:,~nxl_) = NaN; zenir.rate(dark_,:) = NaN; % zenir.rate(shut_,:) = NaN; 
zenir.rate(zenir.spec==WD) = NaN;
nrate_hi = zenir.rate(zevis.t_int_ms==vhi,nxl_);
% ntemp_hi = zenir.Temp_chiller_C(zevis.t_int_ms==vhi);% For scatter, didn't help
nrate_lo = zenir.rate(zevis.t_int_ms==vlo,nxl_);
wd_ni = zenir.wd(zevis.t_int_ms==vhi,nxl_);
wd_ni = wd_ni(:);
wd_no = zenir.wd(zevis.t_int_ms==vlo,nxl_);
wd_no = wd_no(:);

figure; plot(zevis.wl, max(zevis.rate(zevis.t_int_ms==vlo,:)),'b-'); logy; zoom('on')
menu('Zoom as desired.  Points outside limits will be excluded.','OK, done'); vxl = axis; 
vxl_ = zevis.wl>vxl(1) & zevis.wl<vxl(2) & max(zevis.rate(zevis.t_int_ms==vlo,:))>vxl(3);
zevis.rate(:,~vxl_) = NaN;  zevis.rate(dark_,:) = NaN; %zevis.rate(shut_,:) = NaN;
zevis.rate(zevis.spec==WD) = NaN;

% vrate_hi = zevis.rate(zevis.t_int_ms==vhi,vxl_);
vrate_hi = NaN(size(zevis.rate)); vrate_lo = vrate_hi;
vrate_hi(zevis.t_int_ms==vhi,vxl_) = zevis.rate(zevis.t_int_ms==vhi,vxl_);
vrate_hi(zevis.t_int_ms==vlo,vxl_) = interp1(zevis.time(zevis.t_int_ms==vhi),...
   zevis.rate(zevis.t_int_ms==vhi,vxl_), zevis.time(zevis.t_int_ms==vlo), 'linear');
vrate_lo(zevis.t_int_ms==vlo,vxl_) = zevis.rate(zevis.t_int_ms==vlo,vxl_);
vrate_lo(zevis.t_int_ms==vhi,vxl_) = interp1(zevis.time(zevis.t_int_ms==vlo),...
   zevis.rate(zevis.t_int_ms==vlo,vxl_), zevis.time(zevis.t_int_ms==vhi), 'linear');

nrate_hi = NaN(size(zenir.rate)); nrate_lo = nrate_hi;
nrate_hi(zevis.t_int_ms==vhi,nxl_) = zenir.rate(zevis.t_int_ms==vhi,nxl_);
nrate_hi(zevis.t_int_ms==vlo,nxl_) = interp1(zenir.time(zevis.t_int_ms==vhi),...
   zenir.rate(zevis.t_int_ms==vhi,nxl_), zenir.time(zevis.t_int_ms==vlo), 'linear');
nrate_lo(zevis.t_int_ms==vlo,nxl_) = zenir.rate(zevis.t_int_ms==vlo,nxl_);
nrate_lo(zevis.t_int_ms==vhi,nxl_) = interp1(zevis.time(zevis.t_int_ms==vlo),...
   zenir.rate(zevis.t_int_ms==vlo,nxl_), zenir.time(zevis.t_int_ms==vhi), 'linear');

% 
% wd_hi = NaN(size(zevis.wd));
% wd_hi(zevis.t_int_ms==vhi,vxl_) = zevis.wd(zevis.t_int_ms==vhi,vxl_);
% wd_hi(zevis.t_int_ms==vlo,vxl_) = interp1(zevis.time(zevis.t_int_ms==vhi),zevis.wd(zevis.t_int_ms==vhi,vxl_), zevis.time(zevis.t_int_ms==vlo),'linear');

% wd_ni = NaN(size(zenir.wd));
% wd_ni(zevis.t_int_ms==vhi,nxl_) = zenir.wd(zevis.t_int_ms==vhi,nxl_);
% wd_ni(zevis.t_int_ms==vlo,nxl_) = interp1(zevis.time(zevis.t_int_ms==vhi),zenir.wd(zevis.t_int_ms==vhi,nxl_), zevis.time(zevis.t_int_ms==vlo),'linear');

% Now interpolate to get corresponding vlo times
wd_v = NaN(size(zevis.wd));
wd_v(zevis.t_int_ms==vlo,vxl_) = zevis.wd(zevis.t_int_ms==vlo,vxl_);
wd_v(zevis.t_int_ms==vhi,vxl_) = interp1(zevis.time(zevis.t_int_ms==vlo),zevis.wd(zevis.t_int_ms==vlo,vxl_), zevis.time(zevis.t_int_ms==vhi),'linear');

wd_n = NaN(size(zenir.wd));
wd_n(zevis.t_int_ms==vlo,nxl_) = zenir.wd(zevis.t_int_ms==vlo,nxl_);
wd_n(zevis.t_int_ms==vhi,nxl_) = interp1(zevis.time(zevis.t_int_ms==vlo),zenir.wd(zevis.t_int_ms==vlo,nxl_), zevis.time(zevis.t_int_ms==vhi),'linear');

wd_v = NaN(size(zevis.wd));
wd_v(zevis.t_int_ms==vhi,vxl_) = zevis.wd(zevis.t_int_ms==vhi,vxl_);
wd_v(zevis.t_int_ms==vlo,vxl_) = interp1(zevis.time(zevis.t_int_ms==vhi),zevis.wd(zevis.t_int_ms==vhi,vxl_), zevis.time(zevis.t_int_ms==vlo),'linear');

wd_n = NaN(size(zenir.wd));
wd_n(zevis.t_int_ms==vhi,nxl_) = zenir.wd(zevis.t_int_ms==vhi,nxl_);
wd_n(zevis.t_int_ms==vlo,nxl_) = interp1(zevis.time(zevis.t_int_ms==vhi),zenir.wd(zevis.t_int_ms==vhi,nxl_), zevis.time(zevis.t_int_ms==vlo),'linear');

wdv = wd_v(:);
wdn = wd_n(:);


% wd_lo = NaN(size(zevis.wd));
% wd_no = NaN(size(zenir.wd));
% wd_lo(zevis.t_int_ms==vlo,vxl_) = zevis.wd(zevis.t_int_ms==vlo,vxl_);
% wd_no(zevis.t_int_ms==vhi,nxl_) = zenir.wd(zevis.t_int_ms==vlo,nxl_);

lite_(1:end-1) = lite_(1:end-1) & lite_(2:end); lite_(2:end) = lite_(1:end-1) & lite_(2:end);
lite_lo = lite_ & zevis.t_int_ms==vlo; 
lite_hi = lite_ & zevis.t_int_ms==vhi;

vsat_t = ones(size(zevis.spec)); vsat_t(any(zevis.spec>WD2,2),:) = NaN;

vrate_lo(~lite_,:) = NaN; vrate_hi(~lite_,:) = NaN; % zevis.spec==WD
vrate_hi = vrate_hi .* vsat_t;
vrate_lo(zevis.spec == WD) = NaN; 

nrate_lo(~lite_,:) = NaN; nrate_hi(~lite_,:) = NaN; % zevis.spec==WD
nrate_lo(zenir.spec == WD) = NaN; nrate_hi(zenir.spec == WD) = NaN;

figure; sp(1) = subplot(2,1,1); 
plot(zevis.time,vrate_lo(:,300),'*',zevis.time,vrate_hi(:,300).*vsat_t,'r.'); dynamicDateTicks; logy;
sp(2) = subplot(2,1,2);
 plot(zenir.time,nrate_lo(:,100),'*',zenir.time,nrate_hi(:,100),'r.'); dynamicDateTicks; logy;
linkaxes(sp,'x');

vrate_rat = vrate_lo(:)./vrate_hi(:);
figure; plot(wd_v(:),vrate_rat,'.'); logy
v = axis;
wd = [logspace(-4, -2, 10)   0.0125:.025:1]; wd(end) = wd(end) -.0005;wd(1) = wd(1);
clear vrat
for wd_i = length(wd):-1:2
    sub = wdv>wd(wd_i-1) & wdv<=wd(wd_i) & vrate_rat>(v(3))&vrate_rat<(v(4));
    vrat(wd_i) = nanmean(vrate_rat(sub));
end
wd(1) = []; vrat(1) = [];
figure; plot(wd, vrat,'o-r');
xlabel('Pixel Well Depth');
ylabel('Low Gain Rate / High Gain Rate')
if min(unique(zevis.t_int_ms))<4
   title({'HOU SASZe VIS Dual Rate Test ';[datestr(zenir.time(1),'yyyy-mm-dd'),' a couple hours spanning noon']})
else
   title({'SGP SASZe Dual Rate Test ';[datestr(zenir.time(1),'yyyy-mm-dd'),' a few hours spanning noon']})
end
figure; plot(zenir.time,nrate_hi(:,100),'.',zenir.time,nrate_lo(:,100),'.')
nrate_rat = nrate_lo(:)./nrate_hi(:);
figure; plot(wdn,nrate_rat,'.'); logy
v = axis;
clear nrat
wd = [0:.01:.09 .1:.05:1]; wd(end) = wd(end) -.005;wd(1) = wd(1) +.005; wd = sort(wd);
for wd_i = length(wd):-1:2
    sub = wdn>wd(wd_i-1) & wdn<=wd(wd_i) & nrate_rat>(v(3))&nrate_rat<(v(4));
    nrat(wd_i) = nanmean(nrate_rat(sub));
end
wd(1) = []; nrat(1) = [];
figure; plot(wd, nrat,'o-r');
xlabel('Pixel Well Depth');
ylabel('Low Gain Rate / High Gain Rate')
if min(unique(zevis.t_int_ms))<4
   title({'HOU SASZe NIR Dual Rate Test ';[datestr(zenir.time(1),'yyyy-mm-dd'),' a couple hours spanning noon']})
else
   title({'SGP SASZe NIR Dual Rate Test ';[datestr(zenir.time(1),'yyyy-mm-dd'),' a few hours spanning noon']})
end


return