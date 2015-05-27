function radcal_sws_resp_ARCHI_20090701

% Both Si and In seem fairly low for this calibration series.  
% It should be noted that the InGaAs temperature was not stable
% However, the darks don't seem to vary that much even though the
% InGaAs detector temp does, so not sure why In cals would be so low.
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2009_09_08\ARCI_30in_sphere_radiance_cal\12_lamps\';
% 12-lamp
% Si_ms In_ms sws_file(HHMMSS)
%  220 225 005058
%  500 500 005618
%  160 220 010219
%   80 220 010740
%  220 220 011302
%  

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
sws_Si_resp = [sws_1.Si_lambda,sws_1.Si_resp];
sws_In_resp = [sws_1.In_lambda,sws_1.In_resp];

%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_Si_resp,sws_1.time(1),sws_1.Si_ms(1));
%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_In_resp,sws_1.time(1),sws_1.In_ms(1));

%%
[pn, ~, ext] = fileparts(sws.filename);
resp_stem = ['sgpswsC1.resp_func.',datestr(sws_resp.Si.time,'yyyymmdd_HHMMSS'),'.mat'];
save([pn,filesep,resp_stem], 'sws_1');

% resp_stem = ['sgpswsC1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms.dat'];
% [resp_stem, resp_dir] = gen_sws_resp_files(sws_Si_resp,sws_1.time(1),sws_1.Si_ms(1));
% %%
% [resp_stem, resp_dir] = gen_sws_resp_files(sws_In_resp,sws_1.time(1),sws_1.In_ms(1));

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
dark = (max(sws_2.Si_DN,[],1)<1000)|(sws_2.shutter==1);light = ~dark;
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

sws_2.Si_rad = interp1(rad.nm, rad.lamps_12, sws_2.Si_lambda,'pchip')./1000;
sws_2.Si_rad_units = 'W/(m^2 sr nm)';
sws_2.Si_resp = sws_2.mean_Si_spec./sws_2.Si_rad;
sws_2.In_rad = interp1(rad.nm, rad.lamps_12, sws_2.In_lambda,'pchip')./1000;
sws_2.In_rad_units = 'W/(m^2 sr nm)';
sws_2.In_resp = sws_2.mean_In_spec./sws_2.In_rad;

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

sws_3.Si_rad = interp1(rad.nm, rad.lamps_12, sws_3.Si_lambda,'pchip')./1000;
sws_3.Si_rad_units = 'W/(m^2 sr nm)';
sws_3.Si_resp = sws_3.mean_Si_spec./sws_3.Si_rad;
sws_3.In_rad = interp1(rad.nm, rad.lamps_12, sws_3.In_lambda,'pchip')./1000;
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

%%

% Now we calibrate our sphere radiance based on these responsivities.