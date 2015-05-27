function radcal_sws_resp_ARC455_ARCHI_Nov2011
% During this series it was noted that the SWS exhibited a sensitivity to light 
% reflecting off my hand well outside the FOV during calibration with
% ARCS455.  So I followed this calibration sequence with another on the
% ARCHI (I think it was ARCHI).  But I can't find the notes indicating the lamp settings, so now
% I'll try to compare responsivities from the ARCS455 measurement with
% responsivities assuming different HISS settings.
% See the ppt file: "SWS Nov 2011 calibration series.pptx" for details
% Rather than load files for each sub-study individually and process them,

% we load and concat all spectra as fnt of intensity.
% Plot a time series and zoom into the desired time
% Process each time subset in sequence. 

% ARCHI returns radiance in W/m^2/sr/um
% SWS reports radiance in W/m^2/sr/nm, so 1/1000 of ARCHI units
% ARCHI is likely better than ARCS455, was collected after realizing poor FOV with SWS and
% ARCS455.

ames_path = 'C:\case_studies\radiation_cals\2011_Nov_ARC\SWS_on_ARCHI_20111110\archi\';
files = dir([ames_path,'*.dat']);

%%

figure;

sws = read_sws_raw_2([ames_path, files(1).name]);
for f = 2:length(files)
sws = cat_sws_raw(sws,read_sws_raw_2([ames_path, files(f).name]));
end
%%

figure; s(1) = subplot(2,1,1);
plot(serial2doy(sws.time(sws.shutter==0)), max(sws.Si_DN(:,sws.shutter==0),[],1),'-o',...
serial2doy(sws.time(sws.shutter==1)), max(sws.Si_DN(:,sws.shutter==1),[],1),'x'); zoom('on');
s(2) = subplot(2,1,2);
plot(serial2doy(sws.time(sws.shutter==0)), max(sws.In_DN(:,sws.shutter==0),[],1),'-o',...
    serial2doy(sws.time(sws.shutter==1)), max(sws.In_DN(:,sws.shutter==1),[],1),'x'); zoom('on');
linkaxes(s,'x')
%%

sws = crop_sws_time(sws, sws.Si_ms==sws.Si_ms(1));
%%


% figure; plot(serial2Hh(sws.time), max(sws.In_DN,[],1),'-o'); zoom('on');
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = xlim;
xl_ = serial2doy(sws.time)>=xl(1)&serial2doy(sws.time)<=xl(2);
sws_1 = crop_sws_time(sws,xl_);
sws_1.Si_dark = mean(sws_1.Si_DN(:,sws_1.shutter==1),2);
sws_1.Si_spec = (sws_1.Si_DN-sws_1.Si_dark*ones(size(sws_1.time)))...
   ./(ones(size(sws_1.Si_lambda))*sws_1.Si_ms);
sws_1.mean_Si_spec = mean(sws_1.Si_spec,2);
sws_1.In_dark = mean(sws_1.In_DN(:,sws_1.shutter==1),2);
sws_1.In_spec = (sws_1.In_DN-sws_1.In_dark*ones(size(sws_1.time)))...
   ./(ones(size(sws_1.In_lambda))*sws_1.In_ms);
sws_1.mean_In_spec = mean(sws_1.In_spec,2);
%%
rad = get_archi_Nov2011;
sws_1.Si_rad = interp1(rad.nm, rad.lamps_12, sws_1.Si_lambda,'pchip')./1000;
sws_1.Si_rad_units = 'W/(m^2 sr nm)';
sws_1.Si_resp = sws_1.mean_Si_spec./sws_1.Si_rad;
sws_1.In_rad = interp1(rad.nm, rad.lamps_12, sws_1.In_lambda,'pchip')./1000;
sws_1.In_rad_units = 'W/(m^2 sr nm)';
sws_1.In_resp = sws_1.mean_In_spec./sws_1.In_rad;
%%
figure; plot(sws.Si_lambda, [sws_1.Si_resp], '-',sws.In_lambda, [sws_1.In_resp], '-');
title('SWS Si responsivity from ARC455 calibration, ARCHI 12-lamp')
legend('Si','InGaAs');
ylabel('resp [cpms / W)/(m^2 ster um)]')
xlabel('wavelength [nm]')
%%
savefig;
%%
sws_20111111_Si_resp = [sws_1.Si_lambda,sws_1.Si_resp];
sws_20111111_In_resp = [sws_1.In_lambda,sws_1.In_resp];

%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_Si_resp,sws_1.time(1),sws_1.Si_ms(1));
%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_In_resp,sws_1.time(1),sws_1.In_ms(1));

%%
% si_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.si.',num2str(lights_A.Si_ms(1)),'ms.dat'];
% ir_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.ir.',num2str(lights_A.In_ms(1)),'ms.dat'];
% Should use names like the above...
% And should likewise generate two-column .dat files for the ARM process.

% saveasp(sws_20110307_Si_resp, 'sws_20110307_Si_resp.m');

%%
% resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
% si_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.si.',num2str(lights_A.Si_ms(1)),'ms.dat'];
% ir_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.ir.',num2str(lights_A.In_ms(1)),'ms.dat'];
% si_out = [sws_resp.Si_lambda, sws_resp.Archi_30.lamps_12.Si_resp]';
% In_out = [sws_resp.In_lambda, sws_resp.Archi_30.lamps_12.In_resp]';
% si_fid = fopen([resp_dir,si_stem],'w');
% fprintf(si_fid,'   %5.3f    %5.3f \n',si_out);
% fclose(si_fid);
% In_fid = fopen([resp_dir,ir_stem],'w');
% fprintf(In_fid,'   %5.3f    %5.3f \n',In_out);
% fclose(In_fid);
%%