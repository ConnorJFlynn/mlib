function radcal_sws_resp_all_ARC455_Apers_March2011
%% But moving on to look at values with the ARC 455 and 5 different
%% apertures at 6" distance from sphere.  
% This file is a continuation of processing started in ARC_2011_03.
% Trying a different approach than ARC_2011_03 file.
% Rather than load files for each sub-study individually and process them,
% we are loading and concat all spectra as fnt of intensity.
% Plot a time series and zoom into the desired time
% Process each time subset in sequence. 
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\vs_I_apers\';
files = dir([ames_path,'*.dat']);
%%

figure;

sws = read_sws_raw([ames_path, files(1).name]);
for f = 2:length(files)
sws = cat_sws_raw(sws,read_sws_raw([ames_path, files(f).name]));
end
sws = crop_sws_time(sws, sws.Si_ms==sws.Si_ms(1));
%%


figure; plot([1:length(sws.time)], max(sws.In_DN,[],1),'-o'); zoom('on');
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
sws_open_1 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_open_1.Si_dark = mean(sws_open_1.Si_DN(:,sws_open_1.shutter==1),2);
sws_open_1.Si_spec = (sws_open_1.Si_DN-sws_open_1.Si_dark*ones(size(sws_open_1.time)))...
   ./(ones(size(sws_open_1.Si_lambda))*sws_open_1.Si_ms);
sws_open_1.mean_Si_spec = mean(sws_open_1.Si_spec,2);
sws_open_1.In_dark = mean(sws_open_1.In_DN(:,sws_open_1.shutter==1),2);
sws_open_1.In_spec = (sws_open_1.In_DN-sws_open_1.In_dark*ones(size(sws_open_1.time)))...
   ./(ones(size(sws_open_1.In_lambda))*sws_open_1.In_ms);
sws_open_1.mean_In_spec = mean(sws_open_1.In_spec,2);

%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
%%
sws_open_2 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_open_2.Si_dark = mean(sws_open_2.Si_DN(:,sws_open_2.shutter==1),2);
sws_open_2.Si_spec = (sws_open_2.Si_DN-sws_open_2.Si_dark*ones(size(sws_open_2.time)))...
   ./(ones(size(sws_open_2.Si_lambda))*sws_open_2.Si_ms);
sws_open_2.mean_Si_spec = mean(sws_open_2.Si_spec,2);
sws_open_2.In_dark = mean(sws_open_2.In_DN(:,sws_open_2.shutter==1),2);
sws_open_2.In_spec = (sws_open_2.In_DN-sws_open_2.In_dark*ones(size(sws_open_2.time)))...
   ./(ones(size(sws_open_2.In_lambda))*sws_open_2.In_ms);
sws_open_2.mean_In_spec = mean(sws_open_2.In_spec,2);

%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
sws_A = crop_sws_time(sws,[xl(1):xl(2)]);
sws_A.Si_dark = mean(sws_A.Si_DN(:,sws_A.shutter==1),2);
sws_A.Si_spec = (sws_A.Si_DN-sws_A.Si_dark*ones(size(sws_A.time)))...
   ./(ones(size(sws_A.Si_lambda))*sws_A.Si_ms);
sws_A.mean_Si_spec = mean(sws_A.Si_spec,2);
sws_A.In_dark = mean(sws_A.In_DN(:,sws_A.shutter==1),2);
sws_A.In_spec = (sws_A.In_DN-sws_A.In_dark*ones(size(sws_A.time)))...
   ./(ones(size(sws_A.In_lambda))*sws_A.In_ms);
sws_A.mean_In_spec = mean(sws_A.In_spec,2);

%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
sws_B = crop_sws_time(sws,[xl(1):xl(2)]);
sws_B.Si_dark = mean(sws_B.Si_DN(:,sws_B.shutter==1),2);
sws_B.Si_spec = (sws_B.Si_DN-sws_B.Si_dark*ones(size(sws_B.time)))...
   ./(ones(size(sws_B.Si_lambda))*sws_B.Si_ms);
sws_B.mean_Si_spec = mean(sws_B.Si_spec,2);
sws_B.In_dark = mean(sws_B.In_DN(:,sws_B.shutter==1),2);
sws_B.In_spec = (sws_B.In_DN-sws_B.In_dark*ones(size(sws_B.time)))...
   ./(ones(size(sws_B.In_lambda))*sws_B.In_ms);
sws_B.mean_In_spec = mean(sws_B.In_spec,2);
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
sws_C = crop_sws_time(sws,[xl(1):xl(2)]);
sws_C.Si_dark = mean(sws_C.Si_DN(:,sws_C.shutter==1),2);
sws_C.Si_spec = (sws_C.Si_DN-sws_C.Si_dark*ones(size(sws_C.time)))...
   ./(ones(size(sws_C.Si_lambda))*sws_C.Si_ms);
sws_C.mean_Si_spec = mean(sws_C.Si_spec,2);
sws_C.In_dark = mean(sws_C.In_DN(:,sws_C.shutter==1),2);
sws_C.In_spec = (sws_C.In_DN-sws_C.In_dark*ones(size(sws_C.time)))...
   ./(ones(size(sws_C.In_lambda))*sws_C.In_ms);
sws_C.mean_In_spec = mean(sws_C.In_spec,2);
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
sws_D = crop_sws_time(sws,[xl(1):xl(2)]);
sws_D.Si_dark = mean(sws_D.Si_DN(:,sws_D.shutter==1),2);
sws_D.Si_spec = (sws_D.Si_DN-sws_D.Si_dark*ones(size(sws_D.time)))...
   ./(ones(size(sws_D.Si_lambda))*sws_D.Si_ms);
sws_D.mean_Si_spec = mean(sws_D.Si_spec,2);
sws_D.In_dark = mean(sws_D.In_DN(:,sws_D.shutter==1),2);
sws_D.In_spec = (sws_D.In_DN-sws_D.In_dark*ones(size(sws_D.time)))...
   ./(ones(size(sws_D.In_lambda))*sws_D.In_ms);
sws_D.mean_In_spec = mean(sws_D.In_spec,2);
%%

rad = ARC455_20100921;
sws_open_1.Si_rad = interp1(rad.nm, rad.open, sws_open_1.Si_lambda,'pchip')./1000;
sws_open_1.Si_resp = sws_open_1.mean_Si_spec./sws_open_1.Si_rad;
sws_open_1.In_rad = interp1(rad.nm, rad.open, sws_open_1.In_lambda,'pchip')./1000;
sws_open_1.In_resp = sws_open_1.mean_In_spec./sws_open_1.In_rad;

sws_open_2.Si_rad = interp1(rad.nm, rad.open, sws_open_2.Si_lambda,'pchip')./1000;
sws_open_2.Si_resp = sws_open_2.mean_Si_spec./sws_open_2.Si_rad;
sws_open_2.In_rad = interp1(rad.nm, rad.open, sws_open_2.In_lambda,'pchip')./1000;
sws_open_2.In_resp = sws_open_2.mean_In_spec./sws_open_2.In_rad;

sws_A.Si_rad = interp1(rad.nm, rad.A, sws_A.Si_lambda,'pchip')./1000;
sws_A.Si_resp = sws_A.mean_Si_spec./sws_A.Si_rad;
sws_A.In_rad = interp1(rad.nm, rad.A, sws_A.In_lambda,'pchip')./1000;
sws_A.In_resp = sws_A.mean_In_spec./sws_A.In_rad;

sws_B.Si_rad = interp1(rad.nm, rad.B, sws_B.Si_lambda,'pchip')./1000;
sws_B.Si_resp = sws_B.mean_Si_spec./sws_B.Si_rad;
sws_B.In_rad = interp1(rad.nm, rad.B, sws_B.In_lambda,'pchip')./1000;
sws_B.In_resp = sws_B.mean_In_spec./sws_B.In_rad;

sws_C.Si_rad = interp1(rad.nm, rad.C, sws_C.Si_lambda,'pchip')./1000;
sws_C.Si_resp = sws_C.mean_Si_spec./sws_C.Si_rad;
sws_C.In_rad = interp1(rad.nm, rad.C, sws_C.In_lambda,'pchip')./1000;
sws_C.In_resp = sws_C.mean_In_spec./sws_C.In_rad;

sws_D.Si_rad = interp1(rad.nm, rad.D, sws_D.Si_lambda,'pchip')./1000;
sws_D.Si_resp = sws_D.mean_Si_spec./sws_D.Si_rad;
sws_D.In_rad = interp1(rad.nm, rad.D, sws_D.In_lambda,'pchip')./1000;
sws_D.In_resp = sws_D.mean_In_spec./sws_D.In_rad;
%%
figure; plot(sws_A.Si_lambda, [sws_open_1.Si_rad,sws_open_2.Si_rad,sws_A.Si_rad,...
   sws_B.Si_rad,sws_C.Si_rad,sws_D.Si_rad], '-');
title('Radiance from ARC455 during SWS calibration')
legend('open 1','open 2','A','B','C','D');
%%
figure; plot(sws_A.Si_lambda, [sws_open_1.Si_resp,sws_open_2.Si_resp,sws_A.Si_resp,...
   sws_B.Si_resp,sws_C.Si_resp,sws_D.Si_resp], '-');
legend('open 1','open 2','A','B','C','D');
title('SWS Si responsivity from ARC455 calibration')
figure; 
plot(sws_A.In_lambda, [sws_open_1.In_resp,sws_open_2.In_resp,sws_A.In_resp,...
   sws_B.In_resp,sws_C.In_resp,sws_D.In_resp], '-');
legend('open 1','open 2','A','B','C','D');
title('SWS InGaAS responsivity from ARC455 calibration')

%%
sws_resp.Si.time = sws_open_1.time(1);
sws_resp.Si.nm = sws_open_1.Si_lambda;
sws_resp.Si.ms = sws_open_1.Si_ms(1);
sws_resp.Si.specs = [sws_open_1.mean_Si_spec,sws_open_2.mean_Si_spec,sws_A.mean_Si_spec,...
   sws_B.mean_Si_spec,sws_C.mean_Si_spec,sws_D.mean_Si_spec];
sws_resp.Si.rads = [sws_open_1.Si_rad, sws_open_2.Si_rad, sws_A.Si_rad, ...
  sws_B.Si_rad,sws_C.Si_rad,sws_D.Si_rad];
sws_resp.Si.rad_units = 'W/(m^2 sr nm)';
sws_resp.Si.resp = sws_resp.Si.specs./sws_resp.Si.rads;
sws_resp.Si.mean_resp = mean(sws_resp.Si.resp,2);
sws_resp.In.time = sws_open_1.time(1);
sws_resp.In.nm = sws_open_1.In_lambda;
sws_resp.In.ms = sws_open_1.In_ms(1);
sws_resp.In.specs = [sws_open_1.mean_In_spec,sws_open_2.mean_In_spec,sws_A.mean_In_spec,...
   sws_B.mean_In_spec,sws_C.mean_In_spec,sws_D.mean_In_spec];
sws_resp.In.rads = [sws_open_1.In_rad, sws_open_2.In_rad, sws_A.In_rad, ...
  sws_B.In_rad,sws_C.In_rad,sws_D.In_rad];
sws_resp.In.rad_units = 'W/(m^2 sr nm)';
sws_resp.In.resp = sws_resp.In.specs./sws_resp.In.rads;
sws_resp.In.mean_resp = mean(sws_resp.In.resp,2);

sws_Si_resp = [sws_resp.Si.nm,sws_resp.Si.mean_resp];
sws_In_resp = [sws_resp.In.nm,sws_resp.In.mean_resp];

%%
[pn, ~, ext] = fileparts(sws.filename);
resp_stem = ['sgpswsC1.resp_func.',datestr(sws_resp.Si.time,'yyyymmdd_HHMMSS'),'.mat'];
save([pn,filesep,resp_stem], 'sws_resp');

% resp_stem = ['sgpswsC1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms.dat'];
[resp_stem, resp_dir] = gen_sws_resp_files(sws_Si_resp,sws_resp.Si.time,sws_resp.Si.ms);
%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_In_resp,sws_resp.In.time,sws_resp.In.ms);
