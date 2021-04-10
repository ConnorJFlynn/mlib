
% Seems like a persistent discrepancy of about 20% at the peak between lamp
% cal and sun cal responsivities. 


% Need to diagnose whether the files collected on 5/28 and 5/29 include
% lamp and solar measurements despite all being named for solar
% I'll do so by opening some of the lamp and solar files from the previous
% measurements.
esr_smart = rd_allsmrt;
Oriel = load(getfullname('*.mat','Oriel_lamp','Select Oriel mat file')); Oriel = Oriel.oriel_5115;

anet = read_cimel_aod_v3;
anet_nm = [1640,1020,870,865, 779,675,667,620,560,555, 551, 532,531,510,500, 490,443,440, 412,400, 380,340,681,709];
anet.nm = sort(anet_nm);
anet.TOD = NaN(length(anet.time),length(anet.nm));
for n = 1:length(anet.nm)
   nm_str = ['AOD_',num2str(anet.nm(n)),'nm_Total'];
   anet.TOD(:,n) = anet.(nm_str);
end
miss = anet.TOD<0; anet.TOD(miss) = NaN;
allbad = all(isNaN(anet.TOD));
anet.nm = anet.nm(~allbad);
anet.TOD = anet.TOD(:,~allbad);

% Ok, now for simplicity's sake, let's restrict ourselves to the anet
% wavelengths.  We'll interpolate both ESR and 4STAR measurements to match
% the anet wavelengths. Then we'll interpolate anet times to the 4STAR
% times to estimate the wavelength-dependent Tr and dirn = esr * Tr.
anet.ESR = interp1(esr_smart.nm, esr_smart.CebChKur, anet.nm', 'pchip','extrap')';
anet.dirn = anet.Tr .*(ones(size(anet.time))*anet.ESR);

figure; these = plot(anet.nm, anet.TOD,'-o'); 
recolor(these, serial2doy(anet.time)-serial2doy(datenum('2019-05-00')));
colorbar; logy; logx;
xlabel('wavelength [nm]'); 
ylabel('Total OD')

figure; these = plot(anet.nm, anet.TOD.*(anet.Optical_Air_Mass*ones([1,8])),'-o'); 
recolor(these, serial2doy(anet.time)-serial2doy(datenum('2019-05-00')));
colorbar; logy; logx;
xlabel('wavelength [nm]'); 
ylabel('Tr')
 anet.Tr = exp(-anet.TOD.*(anet.Optical_Air_Mass*ones([1,8])));
figure; these = plot(anet.nm, anet.Tr,'-o'); 
recolor(these, serial2doy(anet.time)-serial2doy(datenum('2019-05-00')));
colorbar;  logx; logy
xlabel('wavelength [nm]'); 
ylabel('slant Tr')


% Load solar spectrum and also Aeronet TOD product. 
% Plot TOD vs WL, interpolate to solar spectrum. 
% Compute Tr(time,lambda) and then dirn(time,lambda)

% Interpolate dirn from Aeronet + sol to SASZe sol radiance cal
% Obtain resp for SASZe by dividing difference in sun-shade rates by dirn.

% Solar, near end of day, long airmass 
% May24a
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 

rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each
% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may24a_vis = Ze_vis;

Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 

rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each
% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may24a_nir = Ze_vis;

% May24b
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 

rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each
% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may24b_vis = Ze_vis;


% May25  Lamp measurement
 Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select lamp points','OK');
v = axis; lamp = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
lamp(2:end) = lamp(1:end-1)&lamp(2:end);
lamp(1:end-1) = lamp(1:end-1)&lamp(2:end);
hold('on'); plot(find(lamp), maxsig(lamp),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)),'g-')
Ze_vis.mean_time = mean(Ze_vis.time(lamp)); 
Ze_vis.mean_lamp_rate = (mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(lamp|shade));
Ze_vis.lamp_irad = interp1(Oriel.nm, Oriel.irrad_fit, Ze_vis.lambda,'linear')./1000; % convert to W/nm/m2
Ze_vis.lamp_resp = Ze_vis.mean_lamp_rate ./ Ze_vis.lamp_irad; 

figure; plot(Ze_vis.lambda,Ze_vis.lamp_resp,'-x'); 
legend('lamp resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')
may25a_vis = Ze_vis;

% NIR
Ze_nir = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_nir.Tag)]';
maxsig = max(Ze_nir.sig,[],2);
figure; plot([1:length(Ze_nir.Tag)],maxsig,'o-', ...
   find(Ze_nir.Tag==3),maxsig(Ze_nir.Tag==3),'r*',...
   find(Ze_nir.Tag==5), maxsig(Ze_nir.Tag==5),'gx');
menu('Select lamp points','OK');
v = axis; lamp = Ze_nir.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
lamp(2:end) = lamp(1:end-1)&lamp(2:end);
lamp(1:end-1) = lamp(1:end-1)&lamp(2:end);
hold('on'); plot(find(lamp), maxsig(lamp),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_nir.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')

figure; plot(Ze_nir.lambda, mean(Ze_nir.sig(lamp,:))-mean(Ze_nir.sig(shade,:)),'g-')
Ze_nir.mean_time = mean(Ze_nir.time(lamp)); 
Ze_nir.mean_lamp_rate = (mean(Ze_nir.sig(lamp,:))-mean(Ze_nir.sig(shade,:)))./unique(Ze_nir.t_int_ms(lamp|shade));
Ze_nir.lamp_irad = interp1(Oriel.nm, Oriel.irrad_fit, Ze_nir.lambda,'linear')./1000; % convert to W/nm/m2
Ze_nir.lamp_resp = Ze_nir.mean_lamp_rate ./ Ze_nir.lamp_irad; 

figure; plot(Ze_nir.lambda,Ze_nir.lamp_resp,'-x'); 
legend('lamp resp'); title(Ze_nir.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')
may25a_nir = Ze_nir;

% second lamp sequence on May25
 Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select lamp points','OK');
v = axis; lamp = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
lamp(2:end) = lamp(1:end-1)&lamp(2:end);
lamp(1:end-1) = lamp(1:end-1)&lamp(2:end);
hold('on'); plot(find(lamp), maxsig(lamp),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)),'g-')
Ze_vis.mean_time = mean(Ze_vis.time(lamp)); 
Ze_vis.mean_lamp_rate = (mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(lamp|shade));
Ze_vis.lamp_irad = interp1(Oriel.nm, Oriel.irrad_fit, Ze_vis.lambda,'linear')./1000; % convert to W/nm/m2
Ze_vis.lamp_resp = Ze_vis.mean_lamp_rate ./ Ze_vis.lamp_irad; 

figure; plot(Ze_vis.lambda,Ze_vis.lamp_resp,'-x'); 
legend('lamp resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')
may25b_vis = Ze_vis;

% May29a
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 

rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'b+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each
% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may29a_vis = Ze_vis;


%%!! may29b_vis;
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each

% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may29b_vis = Ze_vis;

%%!!
%%!! may29c_vis;
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each

% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may29c_vis = Ze_vis;
%%!!
%%!! may29d_vis;
Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each

% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may29d_vis = Ze_vis;

%%!! may29e

Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select sun points','OK');
v = axis; sun = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
sun(2:end) = sun(1:end-1)&sun(2:end);
sun(1:end-1) = sun(1:end-1)&sun(2:end);
hold('on'); plot(find(sun), maxsig(sun),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')
% Now we have robust "sun" and "shade" values selected.
% Simplest is to take the difference of the mean of each

% Statistics aren't bad.
% (100.*(sqrt(max(maxsig)*Ze_vis.spectra_avg)./Ze_vis.spectra_avg)./max(maxsig))
% For a single spectra: % ~0.0646%.  

% But maybe better would be to compute a polyfit vs time or record for each
% pixel yielding further reduction in statistical noise to ~0.015%
% suggesting < 1% statistical noise in calibration over full wavelength
% range 300-1100

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)),'k-')
Ze_vis.mean_time = mean(Ze_vis.time(sun)); 
Ze_vis.mean_sun_rate = (mean(Ze_vis.sig(sun,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(sun|shade));
vis_ii = interp1(Ze_vis.lambda, [1:length(Ze_vis.lambda)],anet.nm,'nearest'); 
Ze_vis.anet_nm = Ze_vis.lambda(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_sun_rate = Ze_vis.mean_sun_rate(vis_ii(~isnan(vis_ii)));
Ze_vis.anet_dirn = interp1(anet.time, anet.dirn, Ze_vis.mean_time,'linear');
Ze_vis.anet_resp = Ze_vis.anet_sun_rate ./ Ze_vis.anet_dirn(~isnan(vis_ii)); 

figure; plot(Ze_vis.anet_nm, Ze_vis.anet_resp,'-o'); 
legend('anet resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

may29e_vis = Ze_vis;
% Solar?  Actually says lamp...  And peak signal is much lower than May 24 
 % May 29 vis lamp
 Ze_vis = rd_SAS_raw(getfullname('*.csv','specrad')); 
rec = [1:length(Ze_vis.Tag)]';
maxsig = max(Ze_vis.sig,[],2);
figure; plot([1:length(Ze_vis.Tag)],maxsig,'o-', ...
   find(Ze_vis.Tag==3),maxsig(Ze_vis.Tag==3),'r*',...
   find(Ze_vis.Tag==5), maxsig(Ze_vis.Tag==5),'gx');
menu('Select lamp points','OK');
v = axis; lamp = Ze_vis.Tag==3&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
lamp(2:end) = lamp(1:end-1)&lamp(2:end);
lamp(1:end-1) = lamp(1:end-1)&lamp(2:end);
hold('on'); plot(find(lamp), maxsig(lamp),'c+')
menu('Select shade points','OK')
v = axis; shade = Ze_vis.Tag==5&rec>v(1)&rec<v(2)&maxsig>v(3)&maxsig<v(4);
shade(2:end) = shade(1:end-1)&shade(2:end);
shade(1:end-1) = shade(1:end-1)&shade(2:end);
hold('on'); plot(find(shade), maxsig(shade),'c+')

Oriel = load(getfullname('*.mat','Oriel_lamp','Select Oriel mat file'));
Oriel = Oriel.oriel_5115;

figure; plot(Ze_vis.lambda, mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)),'g-')
Ze_vis.mean_time = mean(Ze_vis.time(lamp)); 
Ze_vis.mean_lamp_rate = (mean(Ze_vis.sig(lamp,:))-mean(Ze_vis.sig(shade,:)))./unique(Ze_vis.t_int_ms(lamp|shade));
Ze_vis.lamp_irad = interp1(Oriel.nm, Oriel.irrad_fit, Ze_vis.lambda,'linear')./1000; % convert to W/nm/m2
Ze_vis.lamp_resp = Ze_vis.mean_lamp_rate ./ Ze_vis.lamp_irad; 

figure; plot(Ze_vis.lambda,Ze_vis.lamp_resp,'-x'); 
legend('lamp resp'); title(Ze_vis.fname,'interp','none');
xlabel('wavelength [nm]');
ylabel('resp [cts/ms/W/m^2/nm]')

% Looks like lamp-derived responsivity is about 20% higher than sun-derived
% Thus, for a given sky scene, the lamp cal would yield lower radiances
% than the sun cal. 

% Should also check May25 and May28 results. 

