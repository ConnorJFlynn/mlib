function proc_dt_test_nc 
%Best so far is 2022-11-23
znirapath = getfilepath('zenir','zenir')
znirbpath =getfilepath('zenirb','zenirb')
zvisapath = getfilepath('zevis','zevis')
zvisbpath = getfilepath('zevisb','zevisb')


WD = 2.^16;
% Idea is to load one set of matching netcdf files (ostensibly one day) 
zenira = anc_bundle_files(getfullname('*.nc','zenir'));
anc_dstr = datestr(zenira.time(1),'.yyyymmdd.');
zenirb = anc_bundle_files(getfullname(['*',anc_dstr,'*.nc'],'zenirb'));
zevisa = anc_bundle_files(getfullname(['*',anc_dstr,'*.nc'],'zevis'));
zevisb = anc_bundle_files(getfullname(['*',anc_dstr,'*.nc'],'zevisb'));

[vinn, ninv] = nearest(zevisa.time, zenira.time);
if length(vinn)<length(zevisa.time)
   zevisa = anc_sift(zevisa, vinn); 
   zenira = anc_sift(zenira, ninv);
end
[vinn, ninv] = nearest(zevisb.time, zenirb.time);
if length(vinn)<length(zevisb.time)
   zevisb = anc_sift(zevisb, vinn); 
   zenirb = anc_sift(zenirb, ninv);
end


if length(zevisa.time)<length(zevisb.time)
   bina = interp1(zevisb.time, [1:length(zevisb.time)],zevisa.time,'nearest','extrap');
   zevisb = anc_sift(zevisb, bina);
   zenirb = anc_sift(zenirb, bina);
elseif length(zevisb.time)<length(zevisa.time)
   ainb = interp1(zevisa.time, [1:length(zevisa.time)],zevisb.time,'nearest','extrap');
   zevisa = anc_sift(zevisa, ainb);
   zenira = anc_sift(zenira, ainb);
end


darka_ = zevisa.vdata.shutter_state==0; 
darka_(1:end-1) = darka_(1:end-1)&darka_(2:end); darka_(2:end) = darka_(1:end-1)&darka_(2:end);
darkb_ = zevisb.vdata.shutter_state==0; 
darkb_(1:end-1) = darkb_(1:end-1)&darkb_(2:end); darkb_(2:end) = darkb_(1:end-1)&darkb_(2:end);

litea_ = zevisa.vdata.shutter_state==1; 
litea_(1:end-1) = litea_(1:end-1) & litea_(2:end); litea_(2:end) = litea_(1:end-1) & litea_(2:end);
liteb_ = zevisb.vdata.shutter_state==1; 
liteb_(1:end-1) = liteb_(1:end-1) & liteb_(2:end); liteb_(2:end) = liteb_(1:end-1) & liteb_(2:end);

% Now compute averaged darks.  Then interpolate to subtract from lights
ndarka = 1+ sum(~darka_(1:end-1)&darka_(2:end)); % Counts initial dark set plus transition from light to dark
dark_i = find(darka_);
q = 0;p = 1;n = 1;m = dark_i(n);
dtime = zenira.time(dark_i(n));
vdark = zevisa.vdata.spectra(:,dark_i(n));
ndark = zenira.vdata.spectra(:,dark_i(n));
for n = 2:length(dark_i)
   if dark_i(n)-m == 1
      dtime = dtime + zenira.time(dark_i(n));
      vdark = vdark + zevisa.vdata.spectra(:,dark_i(n));
      ndark = ndark + zenira.vdata.spectra(:,dark_i(n));
      p = p +1;
   else
      q = q+1;
      darka.time(q) = dtime./p;
      darka.nspec(:,q) = ndark./p;
      darka.vspec(:,q) = vdark./p;
      p = 1;
      dtime = zenira.time(dark_i(n));
      vdark = zevisa.vdata.spectra(:,dark_i(n));
      ndark = zenira.vdata.spectra(:,dark_i(n));
   end
   m = dark_i(n);
end
q = q+1;
darka.time(q) = dtime./p;
darka.nspec(:,q) = ndark./p;
darka.vspec(:,q) = vdark./p;
% check whether ndarka == q

visa.wl = zevisa.vdata.wavelength;
visa.time = zevisa.time(litea_);
visa.wd = zevisa.vdata.spectra(:,litea_)./WD; 
visa.rate = (zevisa.vdata.spectra(:,litea_) - interp1(darka.time, darka.vspec',visa.time,'linear','extrap')')./unique(zevisa.vdata.integration_time);

nira.wl = zenira.vdata.wavelength;
nira.time = zenira.time(litea_);
nira.wd = zenira.vdata.spectra(:,litea_)./WD; 
nira.rate = (zenira.vdata.spectra(:,litea_) - interp1(darka.time, darka.nspec',nira.time,'linear','extrap')')./unique(zenira.vdata.integration_time);

ndarkb = 1+ sum(~darkb_(1:end-1)&darkb_(2:end)); % Counts initial dark set plus transition from light to dark
dark_i = find(darkb_);
q = 0;p = 1;n = 1;  m = dark_i(n);
dtime = zenirb.time(dark_i(n));
vdark = zevisb.vdata.spectra(:,dark_i(n));
ndark = zenirb.vdata.spectra(:,dark_i(n));
for n = 2:length(dark_i)
   if dark_i(n)-m == 1
      dtime = dtime + zenirb.time(dark_i(n));
      vdark = vdark + zevisb.vdata.spectra(:,dark_i(n));
      ndark = ndark + zenirb.vdata.spectra(:,dark_i(n));
      p = p +1;
   else
      q = q+1;
      darkb.time(q) = dtime./p;
      darkb.nspec(:,q) = ndark./p;
      darkb.vspec(:,q) = vdark./p;
      p = 1;
      dtime = zenirb.time(dark_i(n));
      vdark = zevisb.vdata.spectra(:,dark_i(n));
      ndark = zenirb.vdata.spectra(:,dark_i(n));
   end
   m = dark_i(n);
end
q = q+1;
darkb.time(q) = dtime./p;
darkb.nspec(:,q) = ndark./p;
darkb.vspec(:,q) = vdark./p;
% check whether ndarkb == q
visb.wl = zevisb.vdata.wavelength;
visb.time = zevisb.time(liteb_);
visb.wd = zevisb.vdata.spectra(:,liteb_)./WD; 
visb.rate = (zevisb.vdata.spectra(:,liteb_) - interp1(darkb.time, darkb.vspec',visb.time,'linear','extrap')')./unique(zevisb.vdata.integration_time);

nirb.wl = zenirb.vdata.wavelength;
nirb.time = zevisb.time(liteb_);
nirb.wd = zenirb.vdata.spectra(:,liteb_)./WD; 
nirb.rate = (zenirb.vdata.spectra(:,liteb_) - interp1(darkb.time, darkb.nspec',nirb.time,'linear','extrap')')./unique(zenirb.vdata.integration_time);

% Now select spectral regions for analysis, plot wd vs rate, fit nlc effect

figure; plot(1:length(visa.wl), max(visa.rate')','g-'); % plot(nirb.wl, max(nirb.rate')','r-')
menu('Zoom to select wavelength range for analysis','OK')
xl = xlim; 
xl_ = visb.wl>xl(1) & visb.wl<xl(2);

vrate_hi = visb.rate(xl_,:);
vrate_lo = visa.rate(xl_,:);
vwd_hi = visb.wd(xl_,:);
vwd_hi = vwd_hi(:);
vwd_lo = visa.wd(xl_,:);
vwd_lo = vwd_lo(:);
figure; plot(serial2Hh(visa.time),vrate_lo(477,:),'.',serial2Hh(visb.time),vrate_hi(477,:),'r.'); legend('low gain','high gain') ; logy;liny
vrate_rat = vrate_lo(:)./vrate_hi(:); vrate_lo(end-1:end,:) = [];
figure; plot(vwd_hi(:),vrate_rat,'.'); logy
menu('Zoom into peak, hit OK when done','OK')
v = axis;
vwd = [0:.05:1]; vwd(end) = vwd(end) -.001;vwd(1) = vwd(1) +.01; 
vrat = NaN(size(vwd)); vdir = NaN(size(vwd));
for wd_i = length(vwd):-1:2
    sub = vwd_hi>vwd(wd_i-1) & vwd_hi<=vwd(wd_i) & vrate_rat>(v(3))&vrate_rat<(v(4));
    vrat(wd_i) = nanmean(vrate_rat(sub));
end
vwd(1) = []; vrat(1) = [];
figure; plot(vwd, vrat,'o-r');
xlabel('Pixel Well Depth');
ylabel('Low Gain Rate / High Gain Rate')
title({'SGP SASZe VIS Dual Rate Test (5 ms / 25 ms)';['Non-linear Response to Pixel Well-Depth:',datestr(nira.time(1),'yyyy-mm-dd')]});

% But this isn't really the non-linear correction.  It is the ratio g(x) = f(x+d)/f(x-d) 
% We want f(x). So we take the log(g(x)) = log(f(x)) - log(f(x+d)); 
% We really want f(x) but I accidentally called it gvrat in the numerical guess below
lvrat = log10(vrat);
gvrat = lvrat + interp1(vwd, lvrat, vwd./5,'linear','extrap');
gvrat(1:3) = gvrat(1:3) + [.001 .0005 0];
figure; plot(vwd, lvrat,'o-c', vwd, gvrat,'k-', vwd, gvrat - interp1(vwd, gvrat, vwd./5,'linear','extrap'),'ro')
figure; semilogy(vwd, 10.^lvrat,'o-c', vwd, 10.^gvrat,'k-', vwd, 10.^(gvrat - interp1(vwd, gvrat, vwd./5,'linear','extrap')),'ro')

nlc_hi =  interp1(vwd, 10.^gvrat, visb.wd(xl_,:),'linear','extrap');
nlc_lo =  interp1(vwd, 10.^gvrat, visa.wd(xl_,:),'linear','extrap');


figure; plot(serial2Hh(visa.time),vrate_lo(343,:).*nlc_lo(343,:),'-',serial2Hh(visb.time),vrate_hi(343,:).*nlc_hi(343,:),'-'); 
legend('short (low gain)','long (high gain)') ;
xlabel('time [UTC]'); yl = ylabel('W/(m^2/um sr)'); set(yl,'interp','tex')


figure; plot(serial2Hh(visa.time),vrate_lo(343,:).*nlc_lo(343,:),'-',serial2Hh(visb.time),vrate_hi(343,:).*nlc_hi(343,:),'-'); 
legend('short (low gain)','long (high gain)') ;
xlabel('time [UTC]'); yl = ylabel('W/(m^2/um sr)'); set(yl,'interp','tex')


% Now for NIR
figure; plot(nirb.wl, max(nirb.rate')','r-'); 
menu('Zoom to select wavelength range for analysis','OK')
xl = xlim; 
xl_ = nirb.wl>xl(1) & nirb.wl<xl(2);

nrate_hi = nirb.rate(xl_,:);
nrate_lo = nira.rate(xl_,:);
nwd_hi = nirb.wd(xl_,:);
nwd_hi = nwd_hi(:);
nwd_lo = nira.wd(xl_,:);
nwd_lo = nwd_lo(:);
figure; plot(nirb.time,nrate_hi(175,:),'.',nira.time,nrate_lo(175,:),'.');
nrate_rat = nrate_lo(:)./nrate_hi(:); nrate_lo(end-1:end,:) = [];
figure; plot(nwd_hi(:),nrate_rat,'r.'); logy
menu('Zoom into peak, hit OK when done','OK')
v = axis;
nwd = [0.015 0.05:.05:1]; nwd(end) = nwd(end) -.00;nwd(1) = nwd(1) +.00; nrat = NaN(size(nwd));
for wd_i = length(nwd):-1:2
    sub = nwd_hi>nwd(wd_i-1) & nwd_hi<=nwd(wd_i) & nrate_rat>(v(3))&nrate_rat<(v(4));
    nrat(wd_i) = nanmean(nrate_rat(sub));
end
nwd(1) = []; nrat(1) = [];
figure; plot(nwd, nrat,'o-k');
xlabel('Pixel Well Depth');
ylabel('Low Gain Rate / High Gain Rate')
title({'SGP SASZe NIR Dual Rate Test (110 ms / 440 ms)';['Non-linear Response to Pixel Well-Depth:',datestr(nira.time(1),'yyyy-mm-dd')]});

% NL correction should be two-stage
% 1A Interpolate nrat to WD
lnrat = log10(nrat);
gnrat =  lnrat + interp1(nwd, lnrat, nwd./4,'linear','extrap');
gnrat(6:8) = gnrat(6:8) + [.0005 .001 .0015];
figure; plot(nwd, 10.^lnrat,'o-c', nwd, 10.^gnrat,'k-', nwd, 10.^(gnrat - .4.* interp1(nwd, gnrat, nwd./4,'linear','extrap')),'ro')
figure; semilogy(nwd, 10.^lnrat,'o-c', nwd, 10.^gnrat,'k-', nwd, 10.^(gnrat - interp1(nwd, gnrat, nwd./4,'linear','extrap')),'ro')

nnlc_hi =  interp1(nwd, 10.^lnrat, nirb.wd(xl_,:),'linear','extrap');
nnlc_lo =  interp1(nwd, 10.^lnrat, nira.wd(xl_,:),'linear','extrap');



figure; plot(nirb.time,nrate_hi(175,:).*nnlc_hi(175,:),'-',nira.time,nrate_lo(175,:).*nnlc_lo(175,:),'-'); legend('nhi gain','nlow gain') ;dynamicDateTicks; logy;



end

function tons_of_plots
% Figures for poster
% Get responsivity so some plots can be in radiance
visa1 = anc_loadcoords; visres = visa1.vdata.responsivity(477)

% Figure with time series of low and hi gain at a pixel where hi saturates.
figure; plot(serial2Hh(visa.time),vrate_lo(477,:)./visres,'.',serial2Hh(visb.time),vrate_hi(477,:)./visres,'r.');
legend('low gain','high gain') ; 
xlabel('time [UTC]');
ylabel('W/(m^2 um sr)')
title({'Sky radiance at 556 nm'; 'SGP 2022-11-23'})
vv = axis;

plots_ppt
figure; plot(serial2Hh(visa.time),vrate_lo(343,:).*nlc_lo(343,:)./visres,'-',serial2Hh(visb.time),vrate_hi(343,:).*nlc_hi(343,:)./visres,'-'); 
legend('short (low gain)','long (high gain)') ;
xlabel('time [UTC]'); yl = ylabel('W/(m^2/um sr)'); set(yl,'interp','tex')
axis(nv)

figure; plot(serial2Hh(visa.time),vrate_lo(477,:).*nlc_lo(477,:)./visres,'-',serial2Hh(visb.time),vrate_hi(477,:).*nlc_hi(477,:)./visres,'-'); 
legend('short (low gain)','long (high gain)') ;
xlabel('time [UTC]'); yl = ylabel('W/(m^2/um sr)'); set(yl,'interp','tex')
title({'Sky radiance at 556 nm'; 'SGP 2022-11-23'})
axis(nv)

corr_hi_dwn = downsample(vrate_hi(477,:).*nlc_hi(477,:),60);
figure; plot(serial2Hh(downsample(visb.time,60)),corr_hi_dwn./visres,'r-');
legend('long (1-minute)')

% zevisa
zenir = rd_SAS_raw(getfullname('*sasze*nir*.csv'));
zevis = rd_SAS_raw(getfullname('*sasze*vis*.csv'));

shut = zenir.Shutter_open_TF==0;
shut_i = find(zenir.Shutter_open_TF==0);
figure; plot(shut_i(1:20), zenir.t_int_ms(shut_i(1:20)),'-ko', find(~shut(1:50)), zenir.t_int_ms(~shut(1:50)),'-b*'); 
legend('"darks" (shutter closed)','"lights" (shutter open)');
ylabel('gain'); yticks('manual');yticklabels({'low','high'})

 figure; plot(zevis.wl, zevis.spec(dark_hi(1),:), '-',zevis.wl, zevis.spec(dark_lo(1),:), '-'); 
legend('high gain','low gain'); xlabel('wavelength [nm]'); ylabel('raw counts')
title('UV/VIS Spectrometer')

figure; plot(zenir.wl, zenir.spec(dark_hi(1),:), 'r-',zenir.wl, zenir.spec(dark_lo(1),:), 'k-'); 
legend('high gain','low gain'); xlabel('wavelength [nm]'); ylabel('raw counts')
title('SWIR Spectrometer')

visa_cts = visa.rate .* unique(zevisa.vdata.integration_time);
visb_cts = visb.rate .* unique(zevisb.vdata.integration_time);

nira_cts = nira.rate .* unique(zenira.vdata.integration_time);
nirb_cts = nirb.rate .* unique(zenirb.vdata.integration_time);


figure; plot( visb.wl, visb_cts(:,10000),'-', visa.wl, visa_cts(:,10000),'-' )
xlabel('wavelength [nm]'); ylabel('raw cts - darks'); 
legend('high gain','low gain');
title('UV/VIS Lights Counts')

figure; plot( nirb.wl, nirb_cts(:,10000),'-', nira.wl, nira_cts(:,10000),'-' )
xlabel('wavelength [nm]'); ylabel('raw cts - darks'); 
legend('high gain','low gain');
title('UV/VIS Lights Counts')

figure; plot( visb.wl, visb.rate(:,10000),'-', visa.wl, visa.rate(:,10000),'-' )
xlabel('wavelength [nm]'); ylabel('count rate [1/ms]'); 
legend('high gain','low gain');
title('UV/VIS Lights Count Rate')

figure; plot( nirb.wl, nirb.rate(:,10000),'r-', nira.wl, nira.rate(:,10000),'k-' )
xlabel('wavelength [nm]'); ylabel('count rate [1/ms]');  
legend('high gain','low gain');
title('SWIR Lights Count Rate')

figure; plot( visb.wl, visb.rate(:,10000),'-', visa.wl, visa.rate(:,10000),'-' )
xlabel('wavelength [nm]'); ylabel('count rate [1/ms]'); 
legend('high gain','low gain');
title('UV/VIS Lights Count Rate')

figure; plot( nirb.wl, nirb.rate(:,10000),'r-', nira.wl, nira.rate(:,10000),'k-' )
xlabel('wavelength [nm]'); ylabel('count rate [1/ms]');  
legend('high gain','low gain');
title('SWIR Lights Count Rate')

a1_vis = anc_load(getfullname('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\dual_ops\*vis*.nc'));
a1_nir = anc_load(getfullname('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\dual_ops\*nir*.nc'));

pos = a1_vis.vdata.responsivity>0;
figure; plot( visb.wl(pos), a1_vis.vdata.responsivity(pos),'-')
xlabel('wavelength [nm]'); yl = ylabel('(count/ms)/(W/(m^2 um sr))'); set(yl,'interp','tex')
title('UV/VIS Spectral Responsivity')

figure; plot( visb.wl(pos), visb.rate(pos,10000)./a1_vis.vdata.responsivity(pos),'-')
xlabel('wavelength [nm]'); ylabel('W/(m^2 um sr)'); 
title('UV/VIS sky radiance');
xlim(vxl)


figure; plot( nirb.wl, nirb.rate(:,10000),'r-', nira.wl, nira.rate(:,10000),'k-' )
xlabel('wavelength [nm]'); ylabel('count rate [1/ms]');  
legend('high gain','low gain');
title('SWIR Lights Count Rate')

vtest = anc_load(getfullname('sgp*vis*.nc','vis','zevisb'));ntest = anc_load(getfullname('sgp*nir*.nc','nir','zenirb'))
figure; plot([1:length(vtest.time)], max(vtest.vdata.spectra)-min(vtest.vdata.spectra),'-'); title(datestr(mean(vtest.time),'yyyy-mm-dd'))
figure; plot([1:length(ntest.time)], max(ntest.vdata.spectra)-min(ntest.vdata.spectra),'-'); title(datestr(mean(ntest.time),'yyyy-mm-dd'))

nir_mins = min(ntest.vdata.spectra')';
figure; plot(vtest.vdata.wavelength, [vtest.vdata.spectra(:,10500),vtest.vdata.spectra(:,20000)],'-')

figure; plot(ntest.vdata.wavelength, [ntest.vdata.spectra(:,10500)-nir_mins,ntest.vdata.spectra(:,20000)-nir_mins],'-')

end