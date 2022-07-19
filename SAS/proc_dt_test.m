function proc_dt_test 
zenir = rd_SAS_raw(getfullname('*sasze*nir*.csv'));
zevis = rd_SAS_raw(getfullname('*sasze*vis*.csv'));
% This is for SGP.  
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





figure; plot(zevis.wl, max(zevis.rate(zevis.t_int_ms==vlo,:)),'r-')
xl = xlim; 
xl_ = zevis.wl>xl(1) & zevis.wl<xl(2);

shut_ = zevis.Shutter_open_TF==0; 
shut_(1:end-1) = shut_(1:end-1)|shut_(2:end); shut_(2:end) = shut_(1:end-1)|shut_(2:end);
zenir.rate(shut_,:) = NaN;
zevis.rate(shut_,:) = NaN; zevis.rate(:,~xl_) = NaN;
zevis.rate(zevis.spec==2.^16) = NaN;
% nrate_hi = zenir.rate(zevis.t_int_ms==vhi,xl_);
% nrate_lo = zenir.rate(zevis.t_int_ms==vlo,xl_);
% wd_ni = zenir.wd(zevis.t_int_ms==vhi,xl_);
% wd_ni = wd_hi(:);
% wd_no = zenir.wd(zevis.t_int_ms==vlo,xl_);
% wd_no = wd_lo(:);



vrate_hi = zevis.rate(zevis.t_int_ms==vhi,xl_);
vrate_lo = zevis.rate(zevis.t_int_ms==vlo,xl_);
wd_hi = zevis.wd(zevis.t_int_ms==vhi,xl_);
wd_hi = wd_hi(:);
wd_lo = zevis.wd(zevis.t_int_ms==vlo,xl_);
wd_lo = wd_lo(:);
figure; plot(zevis.time(zevis.t_int_ms==vhi),vrate_hi(:,300),'.',zevis.time(zevis.t_int_ms==vlo),vrate_lo(:,300),'.');
vrate_rat = vrate_lo(:)./vrate_hi(:); vrate_lo(end-1:end,:) = [];
figure; plot(wd_hi(:),vrate_rat,'.'); logy
v = axis;
wd = [0:.05:1]; wd(end) = wd(end) -.01;wd(1) = wd(1) +.01;
for wd_i = length(wd):-1:2
    sub = wd_hi>wd(wd_i-1) & wd_hi<=wd(wd_i) & vrate_rat>(v(3))&vrate_rat<(v(4));
    vrat(wd_i) = nanmean(vrate_rat(sub));
end
wd(1) = []; vrat(1) = [];
figure; plot(wd, vrat,'o-r');
xlabel('Pixel Well Depth');
ylabel('Low Gain Rate / High Gain Rate')
title({'SGP SASZe VIS Dual Rate Test (5 ms / 30 ms)';[datestr(zenir.time(1),'yyyy-mm-dd'),' ~4 hours spanning noon']})
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