function charts_rad = read_charts_radiance(rad_file);
%%
if ~exist('rad_file','var')||~exist(rad_file,'file')
   disp('Select radiance file.')
   rad_file = getfullname('*.dat','charts')
end
%
fid1 = fopen(rad_file);

dmp = textscan(fid1,'%f %f \n','HeaderLines','2');
fclose(fid1);
charts_rad.wn = dmp{1};
charts_rad.nm = (1000*10000)./dmp{1};
charts_rad.zen_rad_wn = dmp{2};
charts_rad.zen_rad_cm = charts_rad.zen_rad_wn.*(charts_rad.wn.^2);
charts_rad.zen_rad_nm = charts_rad.zen_rad_cm/1e7;
charts_rad.units_wn = '(W/(m2-sr-cm^-1)';
charts_rad.units_cm = '(W/(m2-sr-cm)';
charts_rad.units_nm = '(W/(m2-sr-nm)';


% radiance_per_nm *1e7 = radiance_per_cm;
% radiance_per_cm ./ (1/wl_cm^2) =  radiance_per_wn

h = 6.626e-34;
c = 3e8;
Eperphoton = 6.626e-34 * 3e8 ./ (charts_rad.nm *1e-9); 
charts_rad.Eperphoton = Eperphoton;

%%

% charts_irrad = read_charts_irradiance;
% %%
% if ~exist('irad_file','var')||~exist(irad_file,'file')
%    infile2 = getfullname('*.dat','charts')
% end
% fid2 = fopen(infile2);
% 
% dmp = textscan(fid2,'%f %f %f %f \n','HeaderLines','2');
% fclose(fid2);
% charts_irrad.wn = dmp{1};
% charts_irrad.nm = (1000*10000)./dmp{1};
% charts_irrad.dir_irrad_wn = dmp{2};
% charts_irrad.dir_irrad_cm = dmp{2}.*(dmp{1}.^2);
% %%
% nm = (charts_irrad.nm>400) & (charts_irrad.nm<2200);
% %%
% figure;
% ax2(1) =subplot(2,1,1);
%  plot(charts_irrad.nm(nm), charts_irrad.dir_irrad_nm(nm),'b-');
%  logy
% title('CHARTS direct irradiance and zenith radiance versus wavelength');
% ylabel(charts_irrad.units_irrad_nm)
% xlabel('wavelength (nm)')
% legend('direct irradiance')
% ax2(2) =subplot(2,1,2);
% plot(charts_rad.nm(nm), charts_rad.zen_rad_nm(nm), 'r-')
% legend('zenith radiance')
% logy
% ylabel(charts_rad.units_nm)
% xlabel('wavelength (nm)')
% linkaxes(ax2,'x');zoom('on')
% %% 
% v = axis;
% % figure; 
% %  plot(charts_irrad.nm(nm), 2000.*charts_irrad.dir_irrad_cm(nm)./charts_rad.zen_rad_cm(nm),'g-');
% %  title('Ratio of direct irradiance to zenith radiance over SWS FOV')
% %  ylabel('unitless ratio')
% % xlabel('wavelength (nm)')
% % logy
% % axis(v);
% % 
% % %%
% % figure;
% % ax1(1) =subplot(2,1,1);
% %  plot(charts_irrad.wn(nm), charts_irrad.dir_irrad_wn(nm),'b-');
% %  logy
% % title('CHARTS direct irradiance and zenith radiance versus wavenumber');
% % ylabel('W/(m^2 wn)')
% % xlabel('wavenumbers')
% % legend('direct irradiance')
% % ax1(2) =subplot(2,1,2);
% % plot(charts_rad.wn(nm), charts_rad.zen_rad_wn(nm), 'r-')
% % legend('zenith radiance')
% % logy
% % ylabel('W/(m^2 wn sr)')
% % xlabel('wavenumbers')
% % linkaxes(ax1,'x');zoom('on')
% % %%
% % figure; 
% %  plot(charts_irrad.wn(nm), charts_irrad.dir_irrad_wn(nm)./charts_rad.zen_rad_wn(nm),'g-');
% %  title('Ratio of direct irradiance to zenith radiance')
% % xlabel('wavenumbers (1/cm)')
