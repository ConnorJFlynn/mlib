%% Fixed distance from sphere with different integration times  
% Contents of this file are abridged from ARC_2011_03.m
% Loading and concat all spectra.
% Plot a time series and zoom into the desired time
% Process each time subset in sequence. 
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\vs_tint\';
files = dir([ames_path,'*.dat']);
%%

figure;

sws = read_sws_raw([ames_path, files(1).name]);
for f = 2:length(files)
sws = cat_sws_raw(sws,read_sws_raw([ames_path, files(f).name]));
end
%%
figure; s(1) = subplot(2,1,1);
plot([1:length(sws.time)], max(sws.Si_DN,[],1),'-o'); zoom('on');
s(2) = subplot(2,1,2);
plot([1:length(sws.time)], [sws.Si_ms;sws.In_ms],'-o'); zoom('on');
linkaxes(s,'x')
%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_60 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_60.Si_dark = mean(sws_tint_60.Si_DN(:,sws_tint_60.shutter==1),2);
sws_tint_60.Si_spec = (sws_tint_60.Si_DN-sws_tint_60.Si_dark*ones(size(sws_tint_60.time)))...
   ./(ones(size(sws_tint_60.Si_lambda))*sws_tint_60.Si_ms);
sws_tint_60.mean_Si_spec = mean(sws_tint_60.Si_spec,2);
sws_tint_60.In_dark = mean(sws_tint_60.In_DN(:,sws_tint_60.shutter==1),2);
sws_tint_60.In_spec = (sws_tint_60.In_DN-sws_tint_60.In_dark*ones(size(sws_tint_60.time)))...
   ./(ones(size(sws_tint_60.In_lambda))*sws_tint_60.In_ms);
sws_tint_60.mean_In_spec = mean(sws_tint_60.In_spec,2);

%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_90 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_90.Si_dark = mean(sws_tint_90.Si_DN(:,sws_tint_90.shutter==1),2);
sws_tint_90.Si_spec = (sws_tint_90.Si_DN-sws_tint_90.Si_dark*ones(size(sws_tint_90.time)))...
   ./(ones(size(sws_tint_90.Si_lambda))*sws_tint_90.Si_ms);
sws_tint_90.mean_Si_spec = mean(sws_tint_90.Si_spec,2);
sws_tint_90.In_dark = mean(sws_tint_90.In_DN(:,sws_tint_90.shutter==1),2);
sws_tint_90.In_spec = (sws_tint_90.In_DN-sws_tint_90.In_dark*ones(size(sws_tint_90.time)))...
   ./(ones(size(sws_tint_90.In_lambda))*sws_tint_90.In_ms);
sws_tint_90.mean_In_spec = mean(sws_tint_90.In_spec,2);

%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_150 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_150.Si_dark = mean(sws_tint_150.Si_DN(:,sws_tint_150.shutter==1),2);
sws_tint_150.Si_spec = (sws_tint_150.Si_DN-sws_tint_150.Si_dark*ones(size(sws_tint_150.time)))...
   ./(ones(size(sws_tint_150.Si_lambda))*sws_tint_150.Si_ms);
sws_tint_150.mean_Si_spec = mean(sws_tint_150.Si_spec,2);
sws_tint_150.In_dark = mean(sws_tint_150.In_DN(:,sws_tint_150.shutter==1),2);
sws_tint_150.In_spec = (sws_tint_150.In_DN-sws_tint_150.In_dark*ones(size(sws_tint_150.time)))...
   ./(ones(size(sws_tint_150.In_lambda))*sws_tint_150.In_ms);
sws_tint_150.mean_In_spec = mean(sws_tint_150.In_spec,2);

%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_220 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_220.Si_dark = mean(sws_tint_220.Si_DN(:,sws_tint_220.shutter==1),2);
sws_tint_220.Si_spec = (sws_tint_220.Si_DN-sws_tint_220.Si_dark*ones(size(sws_tint_220.time)))...
   ./(ones(size(sws_tint_220.Si_lambda))*sws_tint_220.Si_ms);
sws_tint_220.mean_Si_spec = mean(sws_tint_220.Si_spec,2);
sws_tint_220.In_dark = mean(sws_tint_220.In_DN(:,sws_tint_220.shutter==1),2);
sws_tint_220.In_spec = (sws_tint_220.In_DN-sws_tint_220.In_dark*ones(size(sws_tint_220.time)))...
   ./(ones(size(sws_tint_220.In_lambda))*sws_tint_220.In_ms);
sws_tint_220.mean_In_spec = mean(sws_tint_220.In_spec,2);
%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_330 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_330.Si_dark = mean(sws_tint_330.Si_DN(:,sws_tint_330.shutter==1),2);
sws_tint_330.Si_spec = (sws_tint_330.Si_DN-sws_tint_330.Si_dark*ones(size(sws_tint_330.time)))...
   ./(ones(size(sws_tint_330.Si_lambda))*sws_tint_330.Si_ms);
sws_tint_330.mean_Si_spec = mean(sws_tint_330.Si_spec,2);
sws_tint_330.In_dark = mean(sws_tint_330.In_DN(:,sws_tint_330.shutter==1),2);
sws_tint_330.In_spec = (sws_tint_330.In_DN-sws_tint_330.In_dark*ones(size(sws_tint_330.time)))...
   ./(ones(size(sws_tint_330.In_lambda))*sws_tint_330.In_ms);
sws_tint_330.mean_In_spec = mean(sws_tint_330.In_spec,2);
%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_450 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_450.Si_dark = mean(sws_tint_450.Si_DN(:,sws_tint_450.shutter==1),2);
sws_tint_450.Si_spec = (sws_tint_450.Si_DN-sws_tint_450.Si_dark*ones(size(sws_tint_450.time)))...
   ./(ones(size(sws_tint_450.Si_lambda))*sws_tint_450.Si_ms);
sws_tint_450.mean_Si_spec = mean(sws_tint_450.Si_spec,2);
sws_tint_450.In_dark = mean(sws_tint_450.In_DN(:,sws_tint_450.shutter==1),2);
sws_tint_450.In_spec = (sws_tint_450.In_DN-sws_tint_450.In_dark*ones(size(sws_tint_450.time)))...
   ./(ones(size(sws_tint_450.In_lambda))*sws_tint_450.In_ms);
sws_tint_450.mean_In_spec = mean(sws_tint_450.In_spec,2);
%%
xl = round(xlim); xl(1) = max([xl(1),1]);xl(2) = min([length(sws.time),xl(2)]);
sws_tint_500 = crop_sws_time(sws,[xl(1):xl(2)]);
sws_tint_500.Si_dark = mean(sws_tint_500.Si_DN(:,sws_tint_500.shutter==1),2);
sws_tint_500.Si_spec = (sws_tint_500.Si_DN-sws_tint_500.Si_dark*ones(size(sws_tint_500.time)))...
   ./(ones(size(sws_tint_500.Si_lambda))*sws_tint_500.Si_ms);
sws_tint_500.mean_Si_spec = mean(sws_tint_500.Si_spec,2);
sws_tint_500.In_dark = mean(sws_tint_500.In_DN(:,sws_tint_500.shutter==1),2);
sws_tint_500.In_spec = (sws_tint_500.In_DN-sws_tint_500.In_dark*ones(size(sws_tint_500.time)))...
   ./(ones(size(sws_tint_500.In_lambda))*sws_tint_500.In_ms);
sws_tint_500.mean_In_spec = mean(sws_tint_500.In_spec,2);
%%

rad = ARC455_20100921;
% I think we're using aperture C but it doesn't really matter since we're
% really examining linearity with respect to t_int.
Si_rad = interp1(rad.nm, rad.C, sws_tint_60.Si_lambda,'pchip');
In_rad = interp1(rad.nm, rad.C, sws_tint_60.In_lambda,'pchip');
sws_tint_60.Si_resp = sws_tint_60.mean_Si_spec./Si_rad;
sws_tint_60.In_resp = sws_tint_60.mean_In_spec./In_rad;

sws_tint_90.Si_resp = sws_tint_90.mean_Si_spec./Si_rad;
sws_tint_90.In_resp = sws_tint_90.mean_In_spec./In_rad;

sws_tint_150.Si_resp = sws_tint_150.mean_Si_spec./Si_rad;
sws_tint_150.In_resp = sws_tint_150.mean_In_spec./In_rad;

sws_tint_220.Si_resp = sws_tint_220.mean_Si_spec./Si_rad;
sws_tint_220.In_resp = sws_tint_220.mean_In_spec./In_rad;

sws_tint_330.Si_resp = sws_tint_330.mean_Si_spec./Si_rad;
sws_tint_330.In_resp = sws_tint_330.mean_In_spec./In_rad;

sws_tint_450.Si_resp = sws_tint_450.mean_Si_spec./Si_rad;
sws_tint_450.In_resp = sws_tint_450.mean_In_spec./In_rad;

sws_tint_500.Si_resp = sws_tint_500.mean_Si_spec./Si_rad;
sws_tint_500.In_resp = sws_tint_500.mean_In_spec./In_rad;
%%
figure; plot(sws_tint_60.Si_lambda, [sws_tint_60.Si_resp,sws_tint_90.Si_resp,sws_tint_150.Si_resp,...
   sws_tint_220.Si_resp,sws_tint_330.Si_resp,sws_tint_450.Si_resp,sws_tint_500.Si_resp], '-');
legend('60 ms','90 ms','150 ms','220 ms','330 ms','450 ms', '500 ms');
figure; plot(sws_tint_60.In_lambda, [sws_tint_60.In_resp,sws_tint_90.In_resp,sws_tint_150.In_resp,...
   sws_tint_220.In_resp,sws_tint_330.In_resp,sws_tint_450.In_resp,sws_tint_500.In_resp], '-');
legend('60 ms','90 ms','150 ms','220 ms','330 ms','450 ms', '500 ms');

%%
figure; plot(serial2Hh([sws_tint_60.time,sws_tint_90.time,sws_tint_150.time,sws_tint_220.time,...
   sws_tint_330.time,sws_tint_450.time,sws_tint_500.time]), [sws_tint_60.zen_In_temp,sws_tint_90.zen_In_temp,...
   sws_tint_150.zen_In_temp,sws_tint_220.zen_In_temp,sws_tint_330.zen_In_temp,...
   sws_tint_450.zen_In_temp,sws_tint_500.zen_In_temp],'.');
% Looks like there is a significant but not predictable difference between
% calibrations with different integration times
% Tentative conclusion: must calibrate at integration time used in normal
% ops even if reduced cal signals must be used. 
