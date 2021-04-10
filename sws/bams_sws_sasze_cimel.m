

sasvis = anc_load(getfullname('sgpsaszevis*.*','bams')); %W/(m^2 um sr) divide by 1e3 to get SWS unjts
sasnir = anc_load(getfullname('sgpsaszenir*.*','bams'));
sws = anc_load(getfullname('sgpsws*.*','bams'));      % W/m^2/nm/sr
cimel = read_cimel_cloudrad(getfullname('*.asc','bams')); %µW/cm^2/sr/nm, divide by 1e2 to get SWS units
cimel.wl = [339.7, 380.1, 439.4, 498.9, 672.7, 867.6, 935.2, 1020.7, 1639.4];
cimel.fwhm = [2,4,10,10,10,10,10,10,25];
sws.wl_ii = interp1(sws.vdata.wavelength, [1:length(sws.vdata.wavelength)],cimel.wl,'nearest'); 
sasvis.wl_ii = interp1(sasvis.vdata.wavelength, [1:length(sasvis.vdata.wavelength)],cimel.wl,'nearest'); 
sasnir.wl_ii = interp1(sasnir.vdata.wavelength, [1:length(sasnir.vdata.wavelength)],cimel.wl,'nearest'); 
% Cimel:
%  340/2,0.339700, 
%  380/4,0.380100, 
%  440/10,0.439400, 
%  500/10,0.498900, 
%  675/10,0.672700, 
%  870/10,0.867600, 
%  937/10 ,0.935200, 
%  1020/10,,1.020700 
%  1640/25 nm,1.639400

cim.wl_1 = [cimel.wl(1)-cimel.fwhm(1):cimel.fwhm(1)/10:cimel.wl(1)+cimel.fwhm(1)];
cim.gaus_1 = gaussian_fwhm(cim.wl_1,cimel.wl(1),cimel.fwhm(1));
cim.wl_2 = [cimel.wl(2)-cimel.fwhm(2):cimel.fwhm(2)/10:cimel.wl(2)+cimel.fwhm(2)];
cim.gaus_2 = gaussian_fwhm(cim.wl_2,cimel.wl(2),cimel.fwhm(2));
cim.wl_3 = [cimel.wl(3)-cimel.fwhm(3):cimel.fwhm(3)/10:cimel.wl(3)+cimel.fwhm(3)];
cim.gaus_3 = gaussian_fwhm(cim.wl_3,cimel.wl(3),cimel.fwhm(3));
cim.wl_4 = [cimel.wl(4)-cimel.fwhm(4):cimel.fwhm(4)/10:cimel.wl(4)+cimel.fwhm(4)];
cim.gaus_4 = gaussian_fwhm(cim.wl_4,cimel.wl(4),cimel.fwhm(4));
cim.wl_5 = [cimel.wl(5)-cimel.fwhm(5):cimel.fwhm(5)/10:cimel.wl(5)+cimel.fwhm(5)];
cim.gaus_5 = gaussian_fwhm(cim.wl_5,cimel.wl(5),cimel.fwhm(5));
cim.wl_6 = [cimel.wl(6)-cimel.fwhm(6):cimel.fwhm(6)/10:cimel.wl(6)+cimel.fwhm(6)];
cim.gaus_6 = gaussian_fwhm(cim.wl_6,cimel.wl(6),cimel.fwhm(6));
cim.wl_7 = [cimel.wl(7)-cimel.fwhm(7):cimel.fwhm(7)/10:cimel.wl(7)+cimel.fwhm(7)];
cim.gaus_7 = gaussian_fwhm(cim.wl_7,cimel.wl(7),cimel.fwhm(7));
cim.wl_8 = [cimel.wl(8)-cimel.fwhm(8):cimel.fwhm(8)/10:cimel.wl(8)+cimel.fwhm(8)];
cim.gaus_8 = gaussian_fwhm(cim.wl_8,cimel.wl(8),cimel.fwhm(8));
cim.wl_9 = [cimel.wl(9)-cimel.fwhm(9):cimel.fwhm(9)/10:cimel.wl(9)+cimel.fwhm(9)];
cim.gaus_9 = gaussian_fwhm(cim.wl_9,cimel.wl(9),cimel.fwhm(9));

[c_in_sws, sws_in_c] = nearest(cimel.time, sws.time);
[c_in_sas, sas_in_c] = nearest(cimel.time, sasvis.time);

figure; plot(sasvis.time, sasvis.vdata.zenith_radiance(sasvis.wl_ii(4),:), 'o',sws.time, 1e3.*sws.vdata.zen_spec_calib(sws.wl_ii(4),:), 'x',cimel.time, 1e1.*cimel.A500nm,'*');
dynamicDateTicks; ylabel('mW/m^2/nm/sr'); legend('SASZe','SWS','Cimel');
menu('Zoom to define time domain to compute average and pin','OK, done');tl = xlim; tl_str = datestr(tl);
cim_tl = find(cimel.time>tl(1) & cimel.time<tl(2));
sws_tl = find(sws.time>tl(1)&sws.time<tl(2)&max(sws.vdata.zen_spec_calib)>0);
sas_tl = find(sasvis.time>tl(1)&sasvis.time<tl(2));

cim_1020 = mean(cimel.A1020nm(cim_tl))./100;
sasvis_1020 = mean(sasvis.vdata.zenith_radiance(sasvis.wl_ii(8),sas_tl))./1000;
sasnir_1020 = mean(sasnir.vdata.zenith_radiance(sasnir.wl_ii(8),sas_tl))./1000;
sws_1020 = mean(sws.vdata.zen_spec_calib(sws.wl_ii(8),sws_tl));

vis_wl = sasvis.vdata.wavelength<1022; nir_wl = sasnir.vdata.wavelength<1360 | sasnir.vdata.wavelength>1430;
figure_(7); plot(sasvis.vdata.wavelength(vis_wl), 1e-3*mean(sasvis.vdata.zenith_radiance(vis_wl,sas_tl),2)*(cim_1020/sasvis_1020),'b-',...
 sasnir.vdata.wavelength(nir_wl)+10, 1e-3*mean(sasnir.vdata.zenith_radiance(nir_wl,sas_tl),2)*(cim_1020/sasnir_1020),'r-',...
 sws.vdata.wavelength, mean(sws.vdata.zen_spec_calib(:,sws_tl),2)*cim_1020/sws_1020,'k-',...
 cimel.wl([3:6 8 9]), 1e-2.*mean([cimel.A440nm(cim_tl),cimel.A500nm(cim_tl),cimel.A675nm(cim_tl),cimel.A870nm(cim_tl),cimel.A1020nm(cim_tl),cimel.A1640nm(cim_tl)]),'c*')
logy; logx
hold('on'); plot(cim.wl_2,1e-2.*cim.gaus_2,'m-',cim.wl_3,1e-2.*cim.gaus_3,'m-',cim.wl_4,1e-2.*cim.gaus_4,'m-',cim.wl_5,1e-2.*cim.gaus_5,'m-')
plot(cim.wl_6,1e-2.*cim.gaus_6,'m-',cim.wl_7,1e-2.*cim.gaus_7,'m-',cim.wl_8,1e-2.*cim.gaus_8,'m-',cim.wl_9,1e-2.*cim.gaus_9,'m-')
legend('SASZe VIS','SASZe NIR','SWS','Cimel radiance','Cimel filters bands')
title(['February 28, 2014 (16:16 UT) - Southern Great Plains Facility']);
ylab = ylabel('spectral zenith radiance [W/m^2/nm/sr]'); set(ylab,'interp','tex');
xlabel('wavelength [nm]');
axis(v);
sws_w = sws.vdata.wavelength>=995&sws.vdata.wavelength<=1015;
vis_w = sasvis.vdata.wavelength>=995 & sasvis.vdata.wavelength<=1015;
nir_w = sasnir.vdata.wavelength>=995 & sasnir.vdata.wavelength<=1015;

sws_means = mean(sws.vdata.zen_spec_calib(sws_w,sws_tl));
nir_means = mean(sasnir.vdata.zenith_radiance(nir_w,sas_tl));

nir_to_sws = 1e3.*interp1(sws.time(sws_tl), sws_means, sasnir.time(sas_tl), 'linear')./nir_means;
nir_to_sws(nir_to_sws<0) = NaN; %handles missings
nir_to_sws = meannonan(nir_to_sws);
vis_by_nir = mean(sasvis.vdata.zenith_radiance(vis_w,:))./ mean(sasnir.vdata.zenith_radiance(nir_w,:));

%Plot mean spectra together with Cimel radiances  

figure; plot(sasvis.vdata.wavelength, mean(sasvis.vdata.zenith_radiance(:,sas_tl),2),'b-',...
   sasnir.vdata.wavelength, mean(sasnir.vdata.zenith_radiance(:,sas_tl),2),'r-',...
   sws.vdata.wavelength, mean(sws.vdata.zen_spec_calib(:,sws_tl),2),'-k'); logy; 


figure; 
plot(sws.vdata.wavelength, 1e3.*mean(sws.vdata.zen_spec_calib(:,sws_tl),2),'-k',...
     1000.* cimel.Exact_Wavelength_380nm(cim_tl(1)), mean(10.*cimel.A380nm(cim_tl)),'go',...
   1000.* cimel.Exact_Wavelength_380nm(cim_tl(1)), mean(10.*cimel.K380nm(cim_tl)),'gx',...
   1000.* cimel.Exact_Wavelength_440nm(cim_tl(1)), mean(10.*cimel.A440nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_440nm(cim_tl(1)), mean(10.*cimel.K440nm(cim_tl)),'gx',...
   1000.*cimel.Exact_Wavelength_500nm(cim_tl(1)), mean(10.*cimel.A500nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_500nm(cim_tl(1)), mean(10.*cimel.K500nm(cim_tl)),'gx',...
   1000.*cimel.Exact_Wavelength_675nm(cim_tl(1)), mean(10.*cimel.A675nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_675nm(cim_tl(1)), mean(10.*cimel.K675nm(cim_tl)),'gx',...
   1000.*cimel.Exact_Wavelength_870nm(cim_tl(1)), mean(10.*cimel.A870nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_870nm(cim_tl(1)), mean(10.*cimel.K870nm(cim_tl)),'gx',...
   1000.*cimel.Exact_Wavelength_1020nm(cim_tl(1)), mean(10.*cimel.A1020nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_1020nm(cim_tl(1)), mean(10.*cimel.K1020nm(cim_tl)),'gx',...
   1000.*cimel.Exact_Wavelength_1640nm(cim_tl(1)), mean(10.*cimel.A1640nm(cim_tl)),'go',...
   1000.*cimel.Exact_Wavelength_1640nm(cim_tl(1)), mean(10.*cimel.K1640nm(cim_tl)),'gx' ); logy; 
hold('on'); plot(cim.wl_2,10.*cim.gaus_2,'r-',cim.wl_3,10.*cim.gaus_3,'r-',cim.wl_4,10.*cim.gaus_4,'r-',cim.wl_5,10.*cim.gaus_5,'r-')
plot(cim.wl_6,10.*cim.gaus_6,'r-',cim.wl_7,10.*cim.gaus_7,'r-',cim.wl_8,10.*cim.gaus_8,'r-',cim.wl_9,10.*cim.gaus_9,'r-')
logx

sws_w = sws.vdata.wavelength>=995&sws.vdata.wavelength<=1015;
vis_w = sasvis.vdata.wavelength>=995 & sasvis.vdata.wavelength<=1015;
nir_w = sasnir.vdata.wavelength>=995 & sasnir.vdata.wavelength<=1015;

sws_means = mean(sws.vdata.zen_spec_calib(sws_w,sws_tl));
nir_means = mean(sasnir.vdata.zenith_radiance(nir_w,sas_tl));

nir_to_sws = 1e3.*interp1(sws.time(sws_tl), sws_means, sasnir.time(sas_tl), 'linear')./nir_means;
nir_to_sws(nir_to_sws<0) = NaN; %handles missings
nir_to_sws = meannonan(nir_to_sws);
vis_by_nir = mean(sasvis.vdata.zenith_radiance(vis_w,:))./ mean(sasnir.vdata.zenith_radiance(nir_w,:));

% Is a significant problem with SASZe radiance cals, factor of 3 or more.  


