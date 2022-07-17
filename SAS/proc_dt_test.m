function proc_dt_test 
zenir = rd_SAS_raw(getfullname('*sasze*nir*.csv'));
zevis = rd_SAS_raw(getfullname('*sasze*vis*.csv'));
% This is for SGP.  HOU didn't work quite right bcuz nir tint hi was 450 ms
% which was longer than the 0.4 sec period, so filled with -9999
vlo = 5; vhi = 30;
dark_ = zevis.Shutter_open_TF==0; 
dark_(1:end-1) = dark_(1:end-1)&dark_(2:end); dark_(2:end) = dark_(1:end-1)&dark_(2:end);
dark_lo = dark_ & zevis.t_int_ms==vlo; 
dark_hi = dark_ & zevis.t_int_ms==vhi;
lite_ = zevis.Shutter_open_TF==1; 
lite_(1:end-1) = lite_(1:end-1) & lite_(2:end); lite_(2:end) = lite_(1:end-1) & lite_(2:end);
lite_lo = lite_ & zevis.t_int_ms==vlo; 
lite_hi = lite_ & zevis.t_int_ms==vhi;

lo_darks = sum(dark_lo(1:end-1)&~dark_lo(2:end)); 
lo_darks_i = find(dark_lo);
lo_dark.time = zeros([lo_darks,1]);
lo_dark.vspec = zeros([lo_darks,length(zevis.wl)]);
lo_dark.nspec = zeros([lo_darks,length(zenir.wl)]);
m = lo_darks_i(1); q = 0;p = 1;n = 1;
dtime = zenir.time(lo_darks_i(n));
vdark = zevis.spec(lo_darks_i(n),:);
ndark = zenir.spec(lo_darks_i(n),:);
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
WD = 2.^16;
zevis.wd = zevis.spec./WD; zevis.sig = zevis.spec - zevis.darks; 
zevis.rate(zevis.t_int_ms==vlo,:) = zevis.sig(zevis.t_int_ms==vlo,:)./unique(zevis.t_int_ms(zevis.t_int_ms==vlo));
zevis.rate(zevis.t_int_ms==vhi,:) = zevis.sig(zevis.t_int_ms==vhi,:)./unique(zevis.t_int_ms(zevis.t_int_ms==vhi));

zenir.wd = zenir.spec./WD; zenir.sig = zenir.spec - zenir.darks; 
zenir.rate(zevis.t_int_ms==vlo,:) = zenir.sig(zevis.t_int_ms==vlo,:)./unique(zenir.t_int_ms(zevis.t_int_ms==vlo));
zenir.rate(zevis.t_int_ms==vhi,:) = zenir.sig(zevis.t_int_ms==vhi,:)./unique(zenir.t_int_ms(zevis.t_int_ms==vhi));

nrate_hi = zenir.rate(zevis.t_int_ms==vhi,:);
nrate_lo = zenir.rate(zevis.t_int_ms==vlo,:);

vrate_hi = zevis.rate(zevis.t_int_ms==vhi,:);
vrate_lo = zevis.rate(zevis.t_int_ms==vlo,:);

shut_ = zevis.Shutter_open_TF==0; 
shut_(1:end-1) = shut_(1:end-1)|shut_(2:end); shut_(2:end) = shut_(1:end-1)|shut_(2:end);
zenir.rate(shut_,:) = NaN;
zevis.rate(shut_,:) = NaN;


figure; plot(vrate_lo(:)./vrate_hi(:),'.')

figure; plot(zevis.wl, max(vrate_lo),'r-')

% Then we interpolate to the lite_lo times, and subtract darks.
% Then we repeat for dark_hi.  
% Then interpolate one light to the other.
% Then convert both to WD and start nonlinearity assessment

figure; these = plot(zevis.wl, zevis.spec(dark_lo,:),'-k'); logy
figure; these = plot(zevis.wl, zevis.spec(dark_lo,:),'-k'); logy; recolor(these,serial2Hh(zevis.time(dark_lo)));
figure; these = plot(zevis.wl, zevis.spec(dark_hi,:),'-k'); logy; recolor(these,serial2Hh(zevis.time(dark_hi)));
figure; these = plot(zevis.wl, zevis.spec(lite_lo,:),'-k'); logy; 
figure; these = plot(zevis.wl, zevis.spec(lite_hi,:),'-k'); logy;

return