% Load sws file, determine darks, subtract them from entire time series.
% Plot spectra vs time to observe shading. 
% Create "shaded" logical
% Plot unshaded vs shaded. 

% Shading times GMT, 2008-12-11
% 1530-1532
% 1628-1630
% 1730-1732
% 1830-1832

% File #1: shading
%%
clear
shading_dir = 'C:\case_studies\SWS\data\sgpswsC1.00\cleaning_at_sgp\subset\';
files = dir([shading_dir, '*.dat']);
sws_1 = read_sws_raw([shading_dir, files(1).name]);% 1530-1532
for f = 2:length(files)
   
sws_1 = cat_sws_raw(read_sws_raw([shading_dir, files(f).name]),sws_1);
end
%%
sws_1.Si_dark = (mean(sws_1.Si_DN(:,sws_1.shutter==1),2));
sws_1.In_dark = (mean(sws_1.In_DN(:,sws_1.shutter==1),2));
figure; lines_Si = plot(sws_1.Si_lambda, sws_1.Si_DN(:,sws_1.shutter==0)-sws_1.Si_dark*ones([1,sum(sws_1.shutter==0)]),'-');
V = datevec(sws_1.time);
lines_Si = recolor(lines_Si, V(:,5)'); colorbar
figure; lines_In = plot(sws_1.In_lambda, sws_1.In_DN(:,sws_1.shutter==0)-sws_1.In_dark*ones([1,sum(sws_1.shutter==0)]),'-');
lines_In = recolor(lines_In, V(:,5)'); colorbar
%%
dk_i = 1;
ii = 0;
sws.Si_lambda=sws_1.Si_lambda;
sws.In_lambda=sws_1.In_lambda;



for t = 2:length(sws_1.time)
   if sws_1.shutter(t-1)~=sws_1.shutter(t)
      ii = ii+1
      dk_j = t-1;
      sws.time(ii) = mean(sws_1.time(dk_i:dk_j));
      sws.N_samples(ii) = dk_j - dk_i+1;
      sws.dark(ii) = sws_1.shutter(dk_i)==1;
      sws.zen_Si_temp(ii) = mean(sws_1.zen_Si_temp(dk_i:dk_j));
      sws.zen_In_temp(ii) = mean(sws_1.zen_In_temp(dk_i:dk_j));
      sws.internal_temp(ii) = mean(sws_1.internal_temp(dk_i:dk_j));
      sws.Si_DN(:,ii) = mean(sws_1.Si_DN(:,dk_i:dk_j),2);
      sws.Si_std(:,ii) = std(sws_1.Si_DN(:,dk_i:dk_j)')';
      sws.In_DN(:,ii) = mean(sws_1.In_DN(:,dk_i:dk_j),2);
      sws.In_std(:,ii) = std(sws_1.In_DN(:,dk_i:dk_j)')';
      dk_i = t;
   end
end
sky_ii = find(~sws.dark);
for ii = 1:length(sky_ii)
      sws_sky.time(ii) = sws.time(sky_ii(ii));
      sws_sky.N_samples(ii) = sws.N_samples(sky_ii(ii));
      sws_sky.zen_Si_temp(ii) = sws.zen_Si_temp(sky_ii(ii));
      sws_sky.zen_In_temp(ii) = sws.zen_In_temp(sky_ii(ii));
      sws_sky.internal_temp(ii) = sws.internal_temp(sky_ii(ii));
      sws_sky.Si_dark(:,ii) = mean(sws.Si_DN(:,[sky_ii(ii)-1,sky_ii(ii)+1]),2);
      sws_sky.Si_spec(:,ii) = sws.Si_DN(:,sky_ii(ii)) - sws_sky.Si_dark(:,ii);
      sws_sky.Si_std(:,ii) = sws.Si_std(:,sky_ii(ii));
      sws_sky.In_dark(:,ii) = mean(sws.In_DN(:,[sky_ii(ii)-1,sky_ii(ii)+1]),2);
      sws_sky.In_spec(:,ii) = sws.In_DN(:,sky_ii(ii)) - sws_sky.In_dark(:,ii);
      sws_sky.In_std(:,ii) = sws.In_std(:,sky_ii(ii));
end
sws_sky.shaded = false(size(sws_sky.time));
sws_sky.shaded(7:2:21) = true; 
sws_sky.shaded_ii = find(sws_sky.shaded);
      
figure; lines = plot(sws.In_lambda, sws_sky.In_spec(:,sws_sky.shaded_ii-1)-sws_sky.In_spec(:,sws_sky.shaded_ii),'-');
figure; lines = plot(sws.In_lambda, sws_sky.In_spec(:,sws_sky.shaded_ii+1)-sws_sky.In_spec(:,sws_sky.shaded_ii),'-');
figure; lines = plot(sws.In_lambda,mean(sws_sky.In_spec(:,sws_sky.shaded_ii),2),'k-',sws.In_lambda, (sws_sky.In_spec(:,sws_sky.shaded_ii+1)./2+sws_sky.In_spec(:,sws_sky.shaded_ii-1)./2)-sws_sky.In_spec(:,sws_sky.shaded_ii),'-');
xlabel('wavelength(nm)')
ylabel('counts - darks')
legend('shaded mean','unshaded-shaded tests')
title('SWS InGaAs shading test, post-renovation')
