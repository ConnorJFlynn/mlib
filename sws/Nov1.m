%%
Optronics = loadinto;
sws_raw = read_sws_raw;
sws_nc = ancload;
fields = fieldnames(sws_raw);
[dmp,inds] = sort(sws_raw.time);
for f = 2:(length(fields)-2)
 if findstr(fields{f},'_DN')
    sws_raw.(fields{f})= sws_raw.(fields{f})(:,inds);
 else
        sws_raw.(fields{f})= sws_raw.(fields{f})(inds);
 end
end


i = 0;j = 0;
while i < length(sws_raw.shutter)
   i = i+1;
   if sws_raw.shutter(i)==1
      j = j+1;
      disp(num2str(j))
      n_dark(j) = 1;
      dark_time(j) = sws_raw.time(i);
      Si_dark(:,j) = sws_raw.Si_DN(:,i);
      In_dark(:,j) = sws_raw.In_DN(:,i);
      i = i+1;
   end
   while (sws_raw.shutter(i)==1) && (i <= length(sws_raw.shutter))
      n_dark(j) = n_dark(j)+1;
      dark_time(j) = dark_time(j) + sws_raw.time(i);
      Si_dark(:,j) = Si_dark(:,j) + sws_raw.Si_DN(:,i);
      In_dark(:,j) = In_dark(:,j) + sws_raw.In_DN(:,i);
      i = i+1;
   end
   if (i>1)
      if (sws_raw.shutter(i-1)==1)
   dark_time(j) = dark_time(j)./n_dark(j);
   Si_dark(:,j) = Si_dark(:,j)./n_dark(j);
   In_dark(:,j) = In_dark(:,j)./n_dark(j);
      end
   end
end
disp('done')
%%
new_Si_dark = (interp1(dark_time, Si_dark', sws_raw.time,'linear','extrap'))';
new_In_dark = (interp1(dark_time, In_dark', sws_raw.time,'linear','extrap'))';
sws_raw.Si_spec = sws_raw.Si_DN - new_Si_dark;
sws_raw.Si_spec = sws_raw.Si_spec ./ (ones(size(sws_raw.Si_lambda))*sws_raw.Si_ms);
sws_raw.In_spec = sws_raw.In_DN - new_In_dark;
sws_raw.In_spec = sws_raw.In_spec ./ (ones(size(sws_raw.In_lambda))*sws_raw.In_ms);
sws_raw.Si_rad = sws_raw.Si_spec ./ ( Optronics.Aper_A.Si_resp* ones(size(sws_raw.Si_ms)));
sws_raw.In_rad = sws_raw.In_spec ./ ( Optronics.Aper_A.In_resp* ones(size(sws_raw.In_ms)));
figure; semilogy(sws_raw.Si_lambda, mean(sws_raw.Si_rad(:,sws_raw.shutter==0),2), '-b.',...
   sws_raw.In_lambda, mean(sws_raw.In_rad(:,sws_raw.shutter==0),2), '-r.',...
   sws_nc.vars.wavelength.data, mean(sws_nc.vars.zen_spec_calib.data(:,sws_nc.vars.shutter_closed.data==0),2),'k-');
xlabel('wavelength(nm)');
ylabel(Optronics.radiance_units);
title('SWS calibrated zenith radiance Nov 01, 17-18 UTC');

%%
 % to convert W/(m^2.sr.nm) to W/(m2.sr.cm) simply multiply by 1e7.  Then
 % convert to B(wn) by multiplying by wl_cm.^2; 
% nc units: W/m^2/nm/sr
figure;
sws_B_wl = mean(sws_nc.vars.zen_spec_calib.data(:,sws_nc.vars.shutter_closed.data==0),2);
sws_B_wl = 1e7.*sws_B_wl;
wl_cm = sws_nc.vars.wavelength.data ./ 1e7;
sws_B_wn = sws_B_wl .* (wl_cm.^2);
wn = 1./wl_cm;
subplot(2,1,1);
semilogy(sws_nc.vars.wavelength.data, sws_B_wl./1e7,'-g.');
title(['SWS zenith radiance, Nov 01, 17-18 UTC']);
ylabel('mW/(m2.sr.nm)');
xlabel('wavelength (nm)');
subplot(2,1,2);
semilogy(wn,sws_B_wn,'-b.');
ylabel('mW/(m2.sr.cm-1)');
xlabel('wavenumber (1/cm)');
%%
% wl = [300:100:2000]*1e-9;
% wl_cm = wl*100;
% % wn = [10:50:10000];
% wn = 1./wl_cm;
% subplot(2,1,1);
% loglog(wl*1e9,planck_in_wl(wl,5800),'g',wl*1e9,(wn.^2).*planck_in_wn(wn,5800),'b.');
% title(['B(wl,5800 K)'])
% ylabel('mW/(m2.sr.cm)')
% xlabel('wavelength (nm)')
% subplot(2,1,2);
% loglog(wn,(planck_in_wn(wn,5800)),'bo',wn,(wl_cm.^2).*planck_in_wl(wl,5800),'g');
% title(['B(wn,5800 K)'])
% ylabel('mW/(m2.sr.cm-1)')
% xlabel('wavenumber (1/cm)')

