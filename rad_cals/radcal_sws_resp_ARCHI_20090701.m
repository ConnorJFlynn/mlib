function radcal_sws_resp_ARCHI_20090701
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2009_07_01\';
% This was during "SPEX"
% The comparison between SWS, Avantes, and 4STAR spectrometers
%  sgpswscf.00.20090701.200413.raw  sphere radiance, 12 lamps.
%  This experiment was designed to assess the SNR of the spectrometers so
%  all were operated bare-fiber staring into the sphere. 
% This is NOT a radiance calibration.
files = dir([ames_path,'*.dat']);
rad = get_archi_20080314;
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
plot(serial2doy(sws.time(sws.shutter==0)), max(sws.In_DN(:,sws.shutter==0),[],1),'-o'); zoom('on');
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
dark = (max(sws_1.Si_DN,[],1)<1000)|(sws_1.shutter==1);
light = ~dark;
%%
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
figure;
s(1) = subplot(2,1,1);
plot(serial2doy(sws_1.time(light)), max(sws_1.Si_DN(:,light),[],1),'-o',...
    serial2doy(sws_1.time(dark)), max(sws_1.Si_DN(:,dark),[],1),'x'); zoom('on');
s(2) = subplot(2,1,2);
plot(serial2doy(sws_1.time(light)), max(sws_1.In_DN(:,light),[],1),'-o',...
    serial2doy(sws_1.time(dark)), max(sws_1.In_DN(:,dark),[],1),'x'); zoom('on');
% linkaxes(s,'x')
%%
sws_1.Si_dark = mean(sws_1.Si_DN(:,dark),2);
sws_1.Si_spec = (sws_1.Si_DN(:,light)-sws_1.Si_dark*ones(size(sws_1.time(light))))...
   ./(ones(size(sws_1.Si_lambda))*sws_1.Si_ms(light));
sws_1.mean_Si_spec = mean(sws_1.Si_spec,2);
sws_1.In_dark = mean(sws_1.In_DN(:,dark),2);
sws_1.In_spec = (sws_1.In_DN(:,light)-sws_1.In_dark*ones(size(sws_1.time(light))))...
   ./(ones(size(sws_1.In_lambda))*sws_1.In_ms(light));
sws_1.mean_In_spec = mean(sws_1.In_spec,2);

%%

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
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = xlim;
xl_ = serial2doy(sws.time)>=xl(1)&serial2doy(sws.time)<=xl(2);
sws_2 = crop_sws_time(sws,xl_);
% dark = max(sws_2.Si_DN(:,sws_2.shutter==0),[],1)<1000;
dark = (max(sws_2.Si_DN,[],1)<1000)|(sws_2.shutter==1);
light = ~dark;
%%
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
figure;
s(1) = subplot(2,1,1);
plot(serial2doy(sws_2.time(light)), max(sws_2.Si_DN(:,light),[],1),'-o',...
    serial2doy(sws_2.time(dark)), max(sws_2.Si_DN(:,dark),[],1),'x'); zoom('on');
s(2) = subplot(2,1,2);
plot(serial2doy(sws_2.time(light)), max(sws_2.In_DN(:,light),[],1),'-o',...
    serial2doy(sws_2.time(dark)), max(sws_2.In_DN(:,dark),[],1),'x'); zoom('on');
% linkaxes(s,'x')
%%
sws_2.Si_dark = mean(sws_2.Si_DN(:,dark),2);
sws_2.Si_spec = (sws_2.Si_DN(:,light)-sws_2.Si_dark*ones(size(sws_2.time(light))))...
   ./(ones(size(sws_2.Si_lambda))*sws_2.Si_ms(light));
sws_2.mean_Si_spec = mean(sws_2.Si_spec,2);
sws_2.In_dark = mean(sws_2.In_DN(:,dark),2);
sws_2.In_spec = (sws_2.In_DN(:,light)-sws_2.In_dark*ones(size(sws_2.time(light))))...
   ./(ones(size(sws_2.In_lambda))*sws_2.In_ms(light));
sws_2.mean_In_spec = mean(sws_2.In_spec,2);

%%

sws_2.Si_rad = interp1(rad.nm, rad.lamps_9, sws_2.Si_lambda,'pchip')./1000;
sws_2.Si_rad_units = 'W/(m^2 sr nm)';
sws_2.Si_resp = sws_2.mean_Si_spec./sws_2.Si_rad;
sws_2.In_rad = interp1(rad.nm, rad.lamps_9, sws_2.In_lambda,'pchip')./1000;
sws_2.In_rad_units = 'W/(m^2 sr nm)';
sws_2.In_resp = sws_2.mean_In_spec./sws_2.In_rad;
%%
figure; plot(sws.Si_lambda, [sws_2.Si_resp], '-',sws.In_lambda, [sws_2.In_resp], '-');
title('SWS Si responsivity from ARC455 calibration, ARCHI 12-lamp')
legend('Si','InGaAs');
ylabel('resp [cpms / W)/(m^2 ster um)]')
xlabel('wavelength [nm]')
%%
savefig;
%%
sws_20111111_Si_resp = [sws_2.Si_lambda,sws_2.Si_resp];
sws_20111111_In_resp = [sws_2.In_lambda,sws_2.In_resp];

%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_Si_resp,sws_2.time(1),sws_2.Si_ms(1));
%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_In_resp,sws_2.time(1),sws_2.In_ms(1));


%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = xlim;
xl_ = serial2doy(sws.time)>=xl(1)&serial2doy(sws.time)<=xl(2);
sws_3 = crop_sws_time(sws,xl_);
% dark = max(sws_3.Si_DN(:,sws_3.shutter==0),[],1)<1000;
dark = (max(sws_3.Si_DN,[],1)<1000)|(sws_3.shutter==1);
light = ~dark;
%%
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
figure;
s(1) = subplot(2,1,1);
plot(serial2doy(sws_3.time(light)), max(sws_3.Si_DN(:,light),[],1),'-o',...
    serial2doy(sws_3.time(dark)), max(sws_3.Si_DN(:,dark),[],1),'x'); zoom('on');
s(2) = subplot(2,1,2);
plot(serial2doy(sws_3.time(light)), max(sws_3.In_DN(:,light),[],1),'-o',...
    serial2doy(sws_3.time(dark)), max(sws_3.In_DN(:,dark),[],1),'x'); zoom('on');
% linkaxes(s,'x')
%%
sws_3.Si_dark = mean(sws_3.Si_DN(:,dark),2);
sws_3.Si_spec = (sws_3.Si_DN(:,light)-sws_3.Si_dark*ones(size(sws_3.time(light))))...
   ./(ones(size(sws_3.Si_lambda))*sws_3.Si_ms(light));
sws_3.mean_Si_spec = mean(sws_3.Si_spec,2);
sws_3.In_dark = mean(sws_3.In_DN(:,dark),2);
sws_3.In_spec = (sws_3.In_DN(:,light)-sws_3.In_dark*ones(size(sws_3.time(light))))...
   ./(ones(size(sws_3.In_lambda))*sws_3.In_ms(light));
sws_3.mean_In_spec = mean(sws_3.In_spec,2);

%%

sws_3.Si_rad = interp1(rad.nm, rad.lamps_6, sws_3.Si_lambda,'pchip')./1000;
sws_3.Si_rad_units = 'W/(m^2 sr nm)';
sws_3.Si_resp = sws_3.mean_Si_spec./sws_3.Si_rad;
sws_3.In_rad = interp1(rad.nm, rad.lamps_6, sws_3.In_lambda,'pchip')./1000;
sws_3.In_rad_units = 'W/(m^2 sr nm)';
sws_3.In_resp = sws_3.mean_In_spec./sws_3.In_rad;
%%
figure; plot(sws.Si_lambda, [sws_3.Si_resp], '-',sws.In_lambda, [sws_3.In_resp], '-');
title('SWS Si responsivity from ARC455 calibration, ARCHI 12-lamp')
legend('Si','InGaAs');
ylabel('resp [cpms / W)/(m^2 ster um)]')
xlabel('wavelength [nm]')
%%
savefig;
%%
sws_20111111_Si_resp = [sws_3.Si_lambda,sws_3.Si_resp];
sws_20111111_In_resp = [sws_3.In_lambda,sws_3.In_resp];

%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_Si_resp,sws_3.time(1),sws_3.Si_ms(1));

[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_In_resp,sws_3.time(1),sws_3.In_ms(1));
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = xlim;
xl_ = serial2doy(sws.time)>=xl(1)&serial2doy(sws.time)<=xl(2);
sws_4 = crop_sws_time(sws,xl_);
% dark = max(sws_4.Si_DN(:,sws_4.shutter==0),[],1)<1000;
dark = (max(sws_4.Si_DN,[],1)<1000)|(sws_4.shutter==1);
light = ~dark;
%%
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
light(1:end-1) = light(1:end-1)&light(2:end);
light(2:end) = light(1:end-1)&light(2:end);
figure;
s(1) = subplot(2,1,1);
plot(serial2doy(sws_4.time(light)), max(sws_4.Si_DN(:,light),[],1),'-o',...
    serial2doy(sws_4.time(dark)), max(sws_4.Si_DN(:,dark),[],1),'x'); zoom('on');
s(2) = subplot(2,1,2);
plot(serial2doy(sws_4.time(light)), max(sws_4.In_DN(:,light),[],1),'-o',...
    serial2doy(sws_4.time(dark)), max(sws_4.In_DN(:,dark),[],1),'x'); zoom('on');
% linkaxes(s,'x')
%%
sws_4.Si_dark = mean(sws_4.Si_DN(:,dark),2);
sws_4.Si_spec = (sws_4.Si_DN(:,light)-sws_4.Si_dark*ones(size(sws_4.time(light))))...
   ./(ones(size(sws_4.Si_lambda))*sws_4.Si_ms(light));
sws_4.mean_Si_spec = mean(sws_4.Si_spec,2);
sws_4.In_dark = mean(sws_4.In_DN(:,dark),2);
sws_4.In_spec = (sws_4.In_DN(:,light)-sws_4.In_dark*ones(size(sws_4.time(light))))...
   ./(ones(size(sws_4.In_lambda))*sws_4.In_ms(light));
sws_4.mean_In_spec = mean(sws_4.In_spec,2);

%%

sws_4.Si_rad = interp1(rad.nm, rad.lamps_3, sws_4.Si_lambda,'pchip')./1000;
sws_4.Si_rad_units = 'W/(m^2 sr nm)';
sws_4.Si_resp = sws_4.mean_Si_spec./sws_4.Si_rad;
sws_4.In_rad = interp1(rad.nm, rad.lamps_3, sws_4.In_lambda,'pchip')./1000;
sws_4.In_rad_units = 'W/(m^2 sr nm)';
sws_4.In_resp = sws_4.mean_In_spec./sws_4.In_rad;
%%
figure; plot(sws.Si_lambda, [sws_4.Si_resp], '-',sws.In_lambda, [sws_4.In_resp], '-');
title('SWS Si responsivity from ARC455 calibration, ARCHI 12-lamp')
legend('Si','InGaAs');
ylabel('resp [cpms / W)/(m^2 ster um)]')
xlabel('wavelength [nm]')
%%
savefig;
%%
sws_20111111_Si_resp = [sws_4.Si_lambda,sws_4.Si_resp];
sws_20111111_In_resp = [sws_4.In_lambda,sws_4.In_resp];

%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_Si_resp,sws_4.time(1),sws_4.Si_ms(1));

[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_In_resp,sws_4.time(1),sws_4.In_ms(1));

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
sws_20110307_In_resp = [sws_A.In_lambda,mean([sws_1.In_resp,sws_open_2.In_resp,sws_A.In_resp,...
   sws_B.In_resp,sws_C.In_resp],2)];
smoothed_mean = smooth(sws_20110307_In_resp(:,2),4);
ri = relmax(smoothed_mean); ri = sort(ri);
ri([4,9,10,12,13])= [];
interp_peaks = interp1(sws_A.In_lambda([1:(ri(1)-1),ri',(ri(end)+1):end]), smoothed_mean([1:(ri(1)-1),ri',(ri(end)+1):end]), sws_A.In_lambda);
figure; 
plot(sws_A.In_lambda, [sws_1.In_resp,sws_open_2.In_resp,sws_A.In_resp,...
   sws_B.In_resp,sws_C.In_resp], '-', ...
   sws_20110307_In_resp(:,1),sws_20110307_In_resp(:,2),'b.',...
sws_20110307_In_resp(ri,1),sws_20110307_In_resp(ri,2),'ko',...
sws_A.In_lambda, interp_peaks, 'r.');
legend('open 1','open 2','A','B','C','mean');
title('SWS InGaAS responsivity from ARC455 calibration');
sws_20110307_In_resp(:,3) = interp_peaks;
%%
% si_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.si.',num2str(lights_A.Si_ms(1)),'ms.dat'];
% ir_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.ir.',num2str(lights_A.In_ms(1)),'ms.dat'];
% Should use names like the above...
% saveasp(sws_20110307_In_resp, 'sws_20110307_In_resp.m');
% Looks like these resp files were later renamed (manually in Windows
% Explorer) to "sws_Si_resp_201103.m" and "sws_In_resp_201103.m"
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

% Now we calibrate our sphere radiance based on these responsivities.