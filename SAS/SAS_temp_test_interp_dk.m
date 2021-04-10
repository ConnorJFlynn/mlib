function mono = SAS_temp_test_interp_dk(indir)
% This was very early work before developing more structured CVS files. The
% data files are flat ASCII files as described below
% indir = 'D:\case_studies\SAS\testing_and_characterization\temp_tests\20100211FullThermoEval\';
if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

%% SAS temp tests
% Reading Albert's data files of spectra and darkcounts from 20100211FullThermoEval
% Avantes & photodiode data: file save every 60 sec
% Ava bckgnd data after every 10th save
% 
% NIDAQ TC data saved every 60 sec
% For the NIDAQ T-RH data, the fields are  YY,MM,DD,HH,MM,SS   (year month day hour minute second), temp 1 (freezer), RH 1, Temp2 (room), RH 2, supply voltage
% The data is in raw values, volts from NIDAQ.
% 
% freezer plugged in after the first bckgnd files.
% freezer dial set at 1/3 full scale.
% Spectra still recorded with 1 file per interval, both spectrometers in
% same file with Avaspec temp as last non-zero DN value.

% VIS #37 and NIR #46 in freezer, darks for NIR only

   pname = indir;
   %%
   back_files = dir([pname,'*Back.csv']);
   for m = length(back_files):-1:1
      pmt = fliplr(back_files(m).name(1:end-9));
      [dmp,tmp] = strtok(pmt,'_');
      back.nir_sn = fliplr(dmp);
      [dmp,tmp] = strtok(tmp,'_');
      back.vis_sn = fliplr(dmp);     
      [dmp,tmp] = strtok(tmp,'_');[dmp,tmp] = strtok(tmp,'_');pmt = fliplr(tmp);
      time_str = pmt(1:(end-1));
      V(1) = sscanf(time_str(1:4),'%d');
      V(2) = sscanf(time_str(5:6),'%d');
      V(3) = sscanf(time_str(7:8),'%d');
      V(4) = sscanf(time_str(10:11),'%d');
      V(5) = sscanf(time_str(13:14),'%d');
      V(6) = sscanf(time_str(16:17),'%d');
      back.time(m) = datenum(V);
     light = load([pname,back_files(m).name]);
     % last value in file is actually a dummy row containing temperature in the second column
     back.vis_deg_C(m) = light(end,2); 
     nm_vis = light(:,1); nm_vis(end) = [];
     nm_nir = light(:,3); nm_nir(end) = [];
     spec_vis = light(:,2); spec_vis(end) = [];
     spec_nir = light(:,4); spec_nir(end) = [];
     zeds = (nm_nir==0);
     nm_nir(zeds) = [];nm_nir(end) = [];
     spec_nir(zeds) = [];
     back.nir_deg_C(m) = spec_nir(end);
     spec_nir(end) = [];
     back.nm_vis = nm_vis;
     back.nm_nir = nm_nir;
     back.spec_vis(:,m) = spec_vis;
     back.spec_nir(:,m) = spec_nir;
   end   
   %%
   mono_files = dir([pname,'*U1.csv']);
   for m = length(mono_files):-1:1
      pmt = fliplr(mono_files(m).name(1:end-4));
      [dmp,tmp] = strtok(pmt,'_');
      mono.nir_sn = fliplr(dmp);
      [dmp,tmp] = strtok(tmp,'_');
      mono.vis_sn = fliplr(dmp);     
      [dmp,tmp] = strtok(tmp,'_');[dmp,tmp] = strtok(tmp,'_');pmt = fliplr(tmp);
      time_str = pmt(1:(end-1));
      V(1) = sscanf(time_str(1:4),'%d');
      V(2) = sscanf(time_str(5:6),'%d');
      V(3) = sscanf(time_str(7:8),'%d');
      V(4) = sscanf(time_str(10:11),'%d');
      V(5) = sscanf(time_str(13:14),'%d');
      V(6) = sscanf(time_str(16:17),'%d');

      mono.time(m) = datenum(V);
     light = load([pname,mono_files(m).name]);
     mono.vis_deg_C(m) = light(end,2);
     nm_vis = light(:,1); nm_vis(end) = [];
     nm_nir = light(:,3); nm_nir(end) = [];
     spec_vis = light(:,2); spec_vis(end) = [];
     spec_nir = light(:,4); spec_nir(end) = [];
     zeds = (nm_nir==0);
     nm_nir(zeds) = [];nm_nir(end) = [];
     spec_nir(zeds) = [];
     mono.nir_deg_C(m) = spec_nir(end);
     spec_nir(end) = [];
     mono.nm_vis = nm_vis;
     mono.nm_nir = nm_nir;
     mono.raw_vis(:,m) = spec_vis;
     mono.raw_nir(:,m) = spec_nir;
     for ii = length(back.nm_vis):-1:1
             back_vis(ii) = interp1(back.time-back.time(1), back.spec_vis(ii,:),mono.time(m)-back.time(1),'linear','extrap'); 
     end
     for ii = length(back.nm_nir):-1:1
             back_nir(ii) = interp1(back.time-back.time(1), back.spec_nir(ii,:),mono.time(m)-back.time(1),'linear','extrap'); 
     end
     tind = interp1(back.time, [1:length(back.time)],mono.time(m),'linear','extrap');
     mono.spec_vis(:,m) = mono.raw_vis(:,m) - back_vis';
     mono.spec_nir(:,m) = mono.raw_nir(:,m) - back_nir';
   end
   %%
% 
 figure; 
 lines1 = plot(mono.nm_vis, mono.spec_vis,'-');
 title(['Vis detector ',mono.vis_sn,' temperature response']);
 xlabel('wavelength [nm]');
 ylabel('raw DN')
 recolor(lines1,mono.vis_deg_C); colorbar;
 zoom('on');
%%

 figure; 
 lines1 = plot(mono.nm_vis, mono.spec_vis,'-');
 title(['Vis detector ',mono.vis_sn,' temperature response']);
 xlabel('wavelength [nm]');
 ylabel('rate')
 recolor(lines1,mono.vis_deg_C); colorbar;
 zoom('on');
%%

 figure; 
 lines3 = plot(back.nm_nir, back.spec_nir,'-');
 recolor(lines3,back.nir_deg_C); colorbar;
 xlabel('wavelength [nm]');
 ylabel('darks')
 title(['NIR detector ',mono.nir_sn,' dark counts temperature response']);
 zoom('on');
 %% 
 figure; 
 lines2 = plot(mono.nm_nir, mono.spec_nir,'-');
 recolor(lines2,mono.nir_deg_C); colorbar;
 xlabel('wavelength [nm]');
  ylabel('DN - darks')
 title(['NIR detector ',mono.nir_sn,' temperature response']);
 zoom('on');
% axis('xy'); caxis([-5,0]); colorbar
% title(pmt, 'interp','none');
% ylabel('scan nm')
% xlabel('pixel')
%%
figure;
plot(60.*serial2Hh(mono.time), [mono.vis_deg_C; mono.nir_deg_C],'o-');
legend('vis','nir')
xlabel('time [minutes]');
ylabel('deg C')


%%
mono.dif_spec = diff(mono.spec_nir,[],2);
%
mono.normdif_spec = mono.dif_spec./mono.spec_nir(:,2:end);
figure; lines3 = semilogy(mono.nm_nir, abs(mono.normdif_spec), '-');
lines3 = recolor(lines3,mono.nir_deg_C(2:end),[-5,10]);
colorbar
title(['Pixel-by-pixel temporal stability of NIR ',mono.nir_sn, ' under changing temperature'])

%%
figure; plot(mono.nir_deg_C, sum(abs(diff(mono.spec_nir,[],1)),1),'o');
title({['Pixel-to-pixel variability of NIR under changing temperature'],mono.nir_sn})
xlabel('Temperature [deg C]');
ylabel('sum(abs(diff(mono.spec_nir)))','interp','none')
%%
figure; subplot(2,1,1);plot(back.nir_deg_C, mean(back.spec_nir ,1),'o')
title('Sum of dark counts vs Temp')
ylabel('NIR darks');
subplot(2,1,2); plot(back.vis_deg_C, mean(back.spec_vis ,1),'x')
ylabel('VIS darks');

xlabel('Temperature [deg C]');

%%

return
     