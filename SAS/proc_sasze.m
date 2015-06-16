function proc_sasze(infile)
% sasze = proc_sasze(sasze)
% identify darks
% subtract darks
% normalize by integration time
% divide by responsivity
% Modify this to match SASZe a1 processing
% Grid darks on to 10-minute grid
% Subtract nearest dark from all measurements
% Normalize by integration time
% Divide by responsivity
if ~exist('infile','var');
   infile = getfullname('*.cdf','sasze');
end
display(['Loading file: ',infile]);
try
   [ncid] = netcdf.open(infile,'write');
catch ME
   status = status -1;
   disp(ME.message)
   return;
end
varid = netcdf.inqVarID(ncid,'spectra');
units = netcdf.getAtt(ncid,varid,'units');
if ~strcmp(units,'mW/m2.sr.nm')
   netcdf.reDef(ncid);
   netcdf.putAtt(ncid,varid,'units','mW/m2.sr.nm');
   % Create appropriate responsivity fields...
   % Include responsivity, datestr, integration time
   netcdf.endDef(ncid);
   netcdf.close(ncid);
   sasze_ = ancloadcoords(infile);
   % sasze_i.recdim = sasze.recdim;
   % sasze_i.dims = sasze.dims;
   maxmem = 60*60*2048;
   recs = round(maxmem./sasze_.dims.wavelength.length);
   for r = 1:recs:sasze_.dims.time.length
      display(['Processing ',num2str(r),' of ', num2str(sasze_.dims.time.length), ' by ', num2str(recs)]);
      sasze = ancloadpart(sasze_, r, recs);
      % figure; plot(serial2Hh(sasze.time), 90-sasze.vars.solar_zenith.data,'-o');
      %%
      all_darks = sasze.vars.spectra.data(:,sasze.vars.shutter_state.data==0);
      darks = NaN(size(sasze.vars.spectra.data));
      for pix = length(sasze.vars.wavelength.data):-1:1
         darks(pix,:) = interp1(find(sasze.vars.shutter_state.data==0),all_darks(pix,:), [1:length(sasze.time)],'nearest','extrap');
      end
      %%
      sasze.vars.spectra.data = (sasze.vars.spectra.data - darks)./(ones(size(sasze.vars.wavelength.data))*sasze.vars.spectrometer_integration_time.data);
      clear darks
      resp_func = rd_sasze_resp_file;
      if length(sasze.vars.wavelength.data)<1000
         resp = sgpsasze_InGaAs_resp_20110307';
      else
         resp = sgpsasze_Si_resp_20110307';
      end
      
      sasze.vars.spectra.data = sasze.vars.spectra.data./(resp(:,2)*ones(size(sasze.time)));
      status = ancputrecslab(sasze, 'spectra',r, recs);
   end
else
    disp('already calibrated in mW/(m2.sr.nm), readjusting to W/(m^2.sr.um)')
          resp_func = rd_sasze_resp_file;
      if length(sasze.vars.wavelength.data)<1000
         resp = sgpsasze_InGaAs_resp_20110307';
      else
         resp = sgpsasze_Si_resp_20110307';
      end
      
      sasze.vars.spectra.data = sasze.vars.spectra.data.*(resp(:,2)*ones(size(sasze.time)));
      sasze.vars.spectra.data = sasze.vars.spectra.data./(resp_func.resp*ones(size(sasze.time)));
   netcdf.close(ncid);
end
%%
sasze = ancload(infile);
figure(23);
plot(serial2doy(sasze.time), [sasze.vars.solar_azimuth.data],'ro',...
    serial2doy(sasze.time), mod((90+sasze.vars.band_azimuth.data),360), 'gx');
legend('solar azimuth','band axis tracking');
xlabel('day of year');
ylabel('degrees')
%%
% nfov2 = ancload(getfullname('*.cdf','nfov2'));
% %%
% figure(22)
%       if length(sasze.vars.wavelength.data)>1000
% wl = [673,870];
%       else
% wl = [1000:20:1300 1500:20:1600];
%       end
% 
% pix = interp1(sasze.vars.wavelength.data,[1:length(sasze.vars.wavelength.data)],wl,'nearest');
% sasze.vars.spectra.data(:,sasze.vars.shutter_state.data==0) = NaN(size(sasze.vars.spectra.data(:,sasze.vars.shutter_state.data==0)));
% lines = plot(serial2Hh(sasze.time), ...
%     sasze.vars.spectra.data(pix,:), '-');
% recolor(lines,wl); 
% for li = 1:length(lines)
%     set(lines(li),'linewidth',1);
% end
% cb = colorbar;
% set(get(cb,'title'),'string','nm','fontsize',10);
% set(cb,'fontsize',10);
% hold('on');
% plot(serial2Hh(nfov2.time), 1000.*nfov2.vars.radiance_673nm.data, '.g-', serial2Hh(nfov2.time), 1000.*nfov2.vars.radiance_870nm.data, '.r-') 
% 
% xlabel('time (UTC)');
% ylabel('sky radiance [W/m2-um-sr]');
% title('Thousands of zenith radiance spectra per day');
% %%
% % Aeronet radiance in µW/cm^2/sr/nm
% % NFOV radiance in W/m^2/nm/sr
% % SASze radiance in [W/(m2.um.sr)] == [mW/(m2.nm.sr)]

return

