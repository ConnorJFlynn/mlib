%%
nim_c1 = ancload;
mfr_c1 = ancload;
%
%%
gn = (nim_c1.vars.airmass.data > 0)&(nim_c1.vars.airmass.data < 5);
gm = (mfr_c1.vars.airmass.data > 0)&(mfr_c1.vars.airmass.data < 5);

fig = figure;
%
for f = 1:5

   fstr = ['direct_normal_narrowband_filter',num2str(f)];
   dirnor = nim_c1.vars.([fstr,'_raw']).data - nim_c1.vars.(['offset_filter',num2str(f)]).data;
   TOA_filter = sscanf(nim_c1.vars.(fstr).atts.(['Gueymard_TOA_filter',num2str(f)]).data,'%f');
   Io_filter = nim_c1.vars.(['Io_filter',num2str(f)]).data;
   TOA_factor = TOA_filter ./ Io_filter;
%    TOA_factor - nim_c1.vars.(['TOA_calibration_factor_filter',num2str(f)]).data;
   dirnor = dirnor ./ nim_c1.vars.(['nominal_calibration_factor_filter',num2str(f)]).data;
   dirnor = dirnor .* TOA_factor;

%    plot(serial2doy(nim_c1.time(good)), dirnor(good), 'r.', ...
%       serial2doy(nim_c1.time(good)), nim_c1.vars.(fstr).data(good), 'go')
%    title('direct nor, computed and in file')
%    k =   menu('ok','ok');
%    plot(serial2doy(nim_c1.time(good)), dirnor(good)-nim_c1.vars.(fstr).data(good), 'b.')
%    title('computed - in file')
%    k =   menu('ok','ok');
   tod = log(TOA_filter./(dirnor .* (nim_c1.vars.sun_to_earth_distance.data .^2)))./nim_c1.vars.airmass.data;

   mfr_dirnor = mfr_c1.vars.([fstr]).data ;
   mfr_TOA_filter = sscanf(mfr_c1.vars.(fstr).atts.(['Gueymard_TOA_filter',num2str(f)]).data,'%f');

   mfr_tod = log(mfr_TOA_filter./(mfr_dirnor .* (mfr_c1.vars.sun_to_earth_distance.data .^2)))./mfr_c1.vars.airmass.data;
   
   plot(serial2doy(nim_c1.time(gn)),(nim_c1.vars.(['total_optical_depth_filter',num2str(f)]).data(gn) - tod(gn)),'b.',...
      serial2doy(mfr_c1.time(gm)),(mfr_c1.vars.(['total_optical_depth_filter',num2str(f)]).data(gm) - mfr_tod(gm)),'m.')
   title('diff in tod, computed - in file')
   legend('nimfr','mfrsr')
   %figure; plot(serial2doy(nim_c1.time(good)),nim_c1.vars.(['total_optical_depth_filter',num2str(f)]).data(good),'go',...
   %serial2doy(nim_c1.time(good)), tod(good),'r.')
  
% title(fstr,'interpreter','none')
k =   menu('ok','ok');
   plot(serial2doy(nim_c1.time(gn)),tod(gn),'b.',...
      serial2doy(mfr_c1.time(gm)),mfr_tod(gm),'m.')
   title('tod')
   legend('nimfr','mfrsr')
k = menu('ok','ok');
end
close(fig)
%%
   gm = (mfr_c1.vars.airmass.data > 0)&(mfr_c1.vars.airmass.data < 5);
   gn = (nim_c1.vars.airmass.data > 0)&(nim_c1.vars.airmass.data < 5);
   
fig = figure; 
%%
for f = 1:5

   fstr = ['direct_normal_narrowband_filter',num2str(f)];
   plot(serial2doy(mfr_c1.time(gm)), mfr_c1.vars.(fstr).data(gm), 'go', ...
      serial2doy(nim_c1.time(gn)), nim_c1.vars.(fstr).data(gn), 'r.');
   title(fstr, 'interpreter', 'none');
   k =   menu('ok','ok');
end
%%
for f = 1:5
   fstr = ['total_optical_depth_filter',num2str(f)];
   plot(serial2doy(mfr_c1.time(gm)), mfr_c1.vars.(fstr).data(gm), 'go', ...
      serial2doy(nim_c1.time(gn)), nim_c1.vars.(fstr).data(gn), 'r.');
   title(fstr, 'interpreter', 'none');
   k =   menu('ok','ok');
end   
%%
for f = 1:5
   fstr = ['aerosol_optical_depth_filter',num2str(f)];
   plot(serial2doy(mfr_c1.time(gm)), mfr_c1.vars.(fstr).data(gm), 'go', ...
      serial2doy(nim_c1.time(gn)), nim_c1.vars.(fstr).data(gn), 'r.');
   title(fstr, 'interpreter', 'none');
   k =   menu('ok','ok');
end   

%%
nom = [415, 500, 615, 673, 870, 940];
for f = 1:5
   
   fstr = ['aerosol_optical_depth_filter',num2str(f)'];
   gstr = ['Gueymard_TOA_filter',num2str(f)];
   wstr = ['wavelength_filter',num2str(f)];
   tstr = ['normalized_transmittance_filter',num2str(f)];
   gm = mfr_c1.vars.(wstr).data>0; 
   gn = nim_c1.vars.(wstr).data>0; 
   disp(['Filter ',num2str(f),': '])
   disp(['Nominal wavelength: ',num2str(nom(f))]);
disp(['mfrsr: ',mfr_c1.vars.(fstr).atts.actual_wavelength.data, ' nimfr: ', num2str(nim_c1.vars.(fstr).atts.actual_wavelength.data)])
disp(['delta nm: ', num2str(sscanf(mfr_c1.vars.(fstr).atts.actual_wavelength.data,'%g') - sscanf(nim_c1.vars.(fstr).atts.actual_wavelength.data, '%g'))])
disp(['TOA in mfrsr file: ',num2str(mfr_c1.vars.(fstr).atts.(gstr).data), '  TOA in nimfr file: ',num2str(nim_c1.vars.(fstr).atts.(gstr).data)])
disp(['Computed TOA MFRSR: ', num2str(compute_toa(mfr_c1.vars.(wstr).data(gm), mfr_c1.vars.(tstr).data(gm))), ...
   '  NIMFR: ',num2str(compute_toa(nim_c1.vars.(wstr).data(gm), nim_c1.vars.(tstr).data(gm)))])

disp(['Delta mfsrs to nimfr TOA: ',num2str((sscanf(mfr_c1.vars.(fstr).atts.(gstr).data,'%g')-sscanf(nim_c1.vars.(fstr).atts.(gstr).data,'%g'))./sscanf(mfr_c1.vars.(fstr).atts.(gstr).data,'%g'))]);
disp(['Delta mfrsr to nimfr computed: ', num2str((compute_toa(mfr_c1.vars.(wstr).data(gm), mfr_c1.vars.(tstr).data(gm))...
   - compute_toa(nim_c1.vars.(wstr).data(gm), nim_c1.vars.(tstr).data(gm)))./compute_toa(mfr_c1.vars.(wstr).data(gm), mfr_c1.vars.(tstr).data(gm)))]);
disp(['Delta mfsrs in file to computed: ',num2str((sscanf(mfr_c1.vars.(fstr).atts.(gstr).data,'%g')-compute_toa(mfr_c1.vars.(wstr).data(gm),mfr_c1.vars.(tstr).data(gm)))./compute_toa(mfr_c1.vars.(wstr).data(gm), mfr_c1.vars.(tstr).data(gm)))]);
disp(['Delta nimfr in file to computed: ',num2str((sscanf(nim_c1.vars.(fstr).atts.(gstr).data,'%g')-compute_toa(nim_c1.vars.(wstr).data(gn),nim_c1.vars.(tstr).data(gn)))./compute_toa(nim_c1.vars.(wstr).data(gn), nim_c1.vars.(tstr).data(gn)))]);

disp(' ')
k =   menu('ok','ok');
end
%%
[nim_aero, nim_eps] = eps_screen(nim_c1.time, nim_c1.vars.total_optical_depth_filter2.data);
[mfr_aero, mfr_eps] = eps_screen(mfr_c1.time, mfr_c1.vars.total_optical_depth_filter2.data);
%%

figure; semilogy(mfr_c1.time, mfr_c1.vars.variability_flag.data, 'm.', ...
   mfr_c1.time, mfr_eps, 'b.')

figure; semilogy(nim_c1.time, nim_c1.vars.variability_flag.data, 'm.', ...
   nim_c1.time, nim_eps, 'b.')

%%
nim_aero = (nim_c1.vars.variability_flag.data>0)&(nim_c1.vars.variability_flag.data<5e-5);
figure; plot(nim_c1.time(nim_aero), nim_c1.vars.total_optical_depth_filter2.data(nim_aero), 'b.')
%    mfr_c1.time(mfr_c1.vars.variability_flag.data>0), mfr_c1.vars.total_optical_depth_filter2.data(mfr_c1.vars.variability_flag.data>0), 'm.')

%%
plot_all_qc(mfr_c1)
%%


