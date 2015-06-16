function mag_zenith_compares
% Magic SASZe, SSFR, Cimel comparisons

% Read all Cimel sky rads
cim_dir = ['D:\data\dmf\mag\magcsphotM1.SKY2\'];
if exist([cim_dir, '..',filesep,'magcsphotM1.catall.mat'],'file')
    cimel = load([cim_dir, '..',filesep,'magcsphotM1.catall.mat']);
else
cims = dir([cim_dir,'*.SKY2']);
c = 1;
disp(['Reading ',num2str(c), ' of ',num2str(length(cims))])
cimel = read_chiu_cloudrad_raw([cim_dir, cims(c).name]);
for c = 2:length(cims)
    disp(['Reading ',num2str(c), ' of ',num2str(length(cims))])
    try
    cim = read_chiu_cloudrad_raw([cim_dir, cims(c).name]);
    cimel = cat_timeseries(cimel, cim);
    catch
        disp(['Problem reading ',cims(c).name, ': ',num2str(c), ' of ',num2str(length(cims))])
    end
end
save([cim_dir, '..',filesep,'magcsphotM1.catall.mat'],'-struct','cimel');
end

ssfr = anc_load(getfullname('*spectra.nc','ssfr','Select ssfr file'));
[~,fname] = fileparts(ssfr.fname);
wrapped = ssfr.vdata.hours<ssfr.vdata.hours(1);
ssfr.vdata.hours(wrapped) = ssfr.vdata.hours(wrapped) + 24;
ssfr.time = datenum(fname(1:8),'yyyymmdd')+ssfr.vdata.hours./24;
vdata = ssfr.vdata;
vdata.time = ssfr.time;
vdata = cat_timeseries(vdata, vdata);
ssfr.time = vdata.time; vdata = rmfield(vdata,'time');vdata = rmfield(vdata,'test');
ssfr.vdata = vdata;
ssfr.vdata.lon = ssfr.vdata.lon';
ssfr.vdata.lat = ssfr.vdata.lat';
ssfr.vdata.hours = ssfr.vdata.hours';

ssfr.ncdef.dims.hours.isunlim=1;
ssfr.ncdef.recdim.name = 'hours';
ssfr.ncdef.recdim.id = 0;
ssfr.ncdef.recdim.length = ssfr.ncdef.dims.hours.length;

sasfilt = anc_load(getfullname(['magsaszefilt*.',fname(1:8),'*.cdf'],'sasf_mag'));
sasnir = anc_load(getfullname(['magsaszenir*.',fname(1:8),'*.cdf'],'sasze_mag'));
sasvis = anc_load(getfullname(['magsaszevis*.',fname(1:8),'*.cdf'],'sasze_mag'));

[cins, sinc] = nearest(cimel.time, ssfr.time);
[sinn, nins] = nearest(ssfr.time, sasnir.time);
[sinv, vins] = nearest(ssfr.time, sasvis.time);
[sinf, fins] = nearest(ssfr.time, sasvis.time);

sin = intersect(sinc, sinn); 
sin = intersect(sin, sinv);
sin = intersect(sin,sinf);

ssfr = sift_ssfr(ssfr, sin);

[sinc, cins] = nearest(ssfr.time, cimel.time);
[sinn, nins] = nearest(ssfr.time, sasnir.time);
[sinv, vins] = nearest(ssfr.time, sasvis.time);
[sinf, fins] = nearest(ssfr.time, sasfilt.time);

sin = intersect(sinc, sinn); 
sin = intersect(sin, sinv);
sin = intersect(sin,sinf);
ssfr = sift_ssfr(ssfr, sin);
[sinc, cins] = nearest(ssfr.time, cimel.time);
[sinn, nins] = nearest(ssfr.time, sasnir.time);
[sinv, vins] = nearest(ssfr.time, sasvis.time);
[sinf, fins] = nearest(ssfr.time, sasfilt.time);

cimel.time = cimel.time(cins);
cimel.head_temp_C = cimel.head_temp_C(cins);
cimel.skyzen = cimel.skyzen(cins,:);
cimel.sunzen = cimel.sunzen(cins,:);
cimel.skyrad = cimel.skyrad(cins,:);
cimel.sunrad = cimel.sunrad(cins,:);
cimel.skyTr = cimel.skyTr(cins,:)./1000;
cimel.sunTr = cimel.sunTr(cins,:)./1000;
wi = interp1(ssfr.vdata.wls, [1:length(ssfr.vdata.wls)],cimel.wavelength,'nearest');

sasfilt = anc_sift(sasfilt, fins);
sasnir = anc_sift(sasnir, nins);
sasvis = anc_sift(sasvis, vins);

win = interp1(sasnir.vdata.wavelength, [1:length(sasnir.vdata.wavelength)],cimel.wavelength,'nearest');
win(isNaN(win)) = 1; sasnir.vdata.zenith_radiance(1,:) = NaN;
wiv = interp1(sasvis.vdata.wavelength, [1:length(sasvis.vdata.wavelength)],cimel.wavelength,'nearest');
wiv(isNaN(wiv)) = 1;sasvis.vdata.zenith_radiance(1,:) = NaN;


ssfr.vdata.sza = interp1(sasnir.time, sasnir.vdata.solar_zenith,ssfr.time,'nearest');
csza = cosd(ssfr.vdata.sza);

% cimel.skyTr = cimel.skyTr./csza;
% cimel.sunTr = cimel.sunTr./csza;

figure; plot(cimel.time, cimel.skyrad./(csza*ones([1,6])),'o',ssfr.time, 1000.*ssfr.vdata.spectra(wi,:)'./(csza*ones([1,6])),'.');dynamicDateTicks
zoom('on');
menu('Zoom in to desired time window and click OK','OK')
xl = xlim;
xl_ = cimel.time>=xl(1) & cimel.time<=xl(2);
mean_cims = mean(cimel.skyrad(xl_,:)./(csza(xl_)*ones([1,6])));
mean_ssfrs = mean(1000.*ssfr.vdata.spectra(:,xl_)'./(csza(xl_)*ones([1,324])));

xlz_ = sasnir.time>=xl(1) & sasnir.time<=xl(2);
mean_nir = mean(sasnir.vdata.zenith_radiance(:,xlz_)'./(cosd(sasnir.vdata.solar_zenith(xlz_)')*ones([1,256])));
mean_nir(mean_nir<=0) = NaN;

mean_vis = mean(sasvis.vdata.zenith_radiance(:,xlz_)'./(cosd(sasvis.vdata.solar_zenith(xlz_)')*ones(size(sasvis.vdata.wavelength'))));
mean_vis(mean_vis<=0) = NaN;
mean_vis(sasvis.vdata.wavelength>1005) = NaN;

sol_ssfr = interp1(sasfilt.vdata.wavelength, sasfilt.vdata.solar_spectrum,ssfr.vdata.wls,'nearest')'.*1000;
sol_cimel = interp1(sasfilt.vdata.wavelength, sasfilt.vdata.solar_spectrum,cimel.wavelength,'nearest').*1000;
sol_vis = interp1(sasfilt.vdata.wavelength, sasfilt.vdata.solar_spectrum, sasvis.vdata.wavelength,'nearest')'.*1000;
sol_nir = interp1(sasfilt.vdata.wavelength, sasfilt.vdata.solar_spectrum, sasnir.vdata.wavelength,'nearest')'.*1000;

% cimel.skyTr = cimel.skyrad ./ (csza * sol_cimel);
% cimel.sunTr = cimel.sunrad ./ (csza * sol_cimel);

ssfr.vdata.Tr = 1000.*ssfr.vdata.spectra./(csza*sol_ssfr)';
sasvis.vdata.Tr = 1.2.*sasvis.vdata.zenith_radiance./(csza*sol_vis)';
sasnir.vdata.Tr = 1.2.*sasnir.vdata.zenith_radiance./(csza*sol_nir)';

% Now make a 2-panel plot for each cimel wavelength showing the Tr and then
% the deviation from the mean. 

for ww = 1:length(wi)
    figure(900+ww);
    subs(2*ww-1) = subplot(2,1,1);
    plot(cimel.time, cimel.skyTr(:,ww), '-',ssfr.time, ssfr.vdata.Tr(wi(ww),:), '-', ...
        sasvis.time, sasvis.vdata.Tr(wiv(ww),:),'-',sasnir.time, sasnir.vdata.Tr(win(ww),:),'-');
    dynamicDateTicks;
    title(['Atmos transmittance at ',num2str(cimel.wavelength(ww)),' nm']);
    legend('Cimel','SSFR','SAS vis', 'SAS nir');
    subs(2*ww) = subplot(2,1,2);
    Y = [cimel.skyTr(:,ww),ssfr.vdata.Tr(wi(ww),:)', sasvis.vdata.Tr(wiv(ww),:)', sasnir.vdata.Tr(win(ww),:)'];
    Y_bar = meannonan(Y')';
    plot(cimel.time, Y - (Y_bar*ones([1,size(Y,2)])),'-');dynamicDateTicks;
    legend('Cimel','SSFR','SAS vis', 'SAS nir');    
end
linkaxes(subs,'x');



figure; 
plot(sasvis.vdata.wavelength, 1.2.*mean_vis,'k-',sasnir.vdata.wavelength, 1.2*mean_nir,'m-',ssfr.vdata.wls, mean_ssfrs,'-');
title('Zenith spectral radiance during MAGIC');
xlabel('wavelength[nm]')
ylabel('radiance/csza')
hold('on')
plot(cimel.wavelength,mean_cims,'bo',ssfr.vdata.wls(wi), mean_ssfrs(wi),'rx')
legend('SASZe NIR','SASZE VIS','SSFR','Cimel')

figure; 
plot(sasvis.vdata.wavelength, 1.2.*mean_vis./sol_vis,'k-',sasnir.vdata.wavelength, 1.2*mean_nir./sol_nir,'m-',ssfr.vdata.wls, mean_ssfrs./sol_ssfr,'-');
title('Zenith spectral transmittance during MAGIC');
xlabel('wavelength[nm]')
ylabel('Tr')
hold('on')
plot(cimel.wavelength,mean_cims./sol_cimel,'bo',ssfr.vdata.wls(wi), mean_ssfrs(wi)./sol_cimel,'rx')
legend('SASZe NIR','SASZE VIS','SSFR','Cimel')
