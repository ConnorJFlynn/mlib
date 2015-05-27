function mono = SAS_temp_test_prelim(indir)
indir ='C:\case_studies\ARRA\SAS\data_tests\temp_tests\20100211prelimThermoEval\';
if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

%% SAS temp tests
% Reading Albert's data files from 20100211prelimThermoEval
% No background counts for the moment.  
% Two Ava units put in freezer.
% No mounts
% Two Al plates for thermal mass.
% Standard lamps w/Blue I sphere.
% Background data is invalid. No control over shutter at this time.
% Lamp current 2.0A
% Lamp Voltage 5.52V
% Freezer set at 1/3 cold
% Spectra from both VIS and NIR spectra in same file with following cols:
% vis_nm, vis_DN, nir_nm, nir_DN
% last non-zero _DN value is temperature from AvaSpec IO board. 
%    %
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

   end
   %%
% 
 figure; 
 lines1 = plot(mono.nm_vis, mono.raw_vis,'-');
 title('Vis detector temperature response');
 xlabel('wavelength [nm]');
 recolor(lines1,mono.vis_deg_C); colorbar;
 zoom('on');

 %% 
 figure; 
 lines2 = plot(mono.nm_nir, mono.raw_nir,'-');
 recolor(lines2,mono.nir_deg_C); colorbar;
 xlabel('wavelength [nm]');
 title('NIR detector temperature response');
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


return
     