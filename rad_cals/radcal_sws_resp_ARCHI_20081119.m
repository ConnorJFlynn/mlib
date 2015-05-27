function radcal_sws_resp_ARCHI_20081119
% Working though the SWS NASA Ames calibration series of Nov 19-20 2008.

% ARCHI returns radiance in W/m^2/sr/um
% SWS reports radiance in W/m^2/sr/nm, so 1/1000 of ARCHI units
% ARCHI is likely better than ARCS455, was collected after realizing poor FOV with SWS and
% ARCS455.

ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\optronics\20081120.211930\';

files = dir([ames_path,'*.dat']);
rad = get_ars455_20080204;
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
% First set with Si ms = 250 and In ms = 150 was with Aperture B
sws_resp.Si.time = sws_1.time(1);
sws_resp.Si.nm = sws_1.Si_lambda;
sws_resp.Si.ms = sws_1.Si_ms(1);
sws_resp.Si.mean_spec = sws_1.mean_Si_spec;
sws_resp.Si.rad = interp1(rad.nm, rad.Aper_B, sws_resp.Si.nm,'pchip')./1000;
sws_resp.Si.rad_units = 'W/(m^2 sr nm)';
sws_resp.Si.resp = sws_resp.Si.mean_spec./sws_resp.Si.rad;
sws_resp.In.mean_spec = sws_1.mean_In_spec;
sws_resp.In.time = sws_1.time(1);
sws_resp.In.nm = sws_1.In_lambda;
sws_resp.In.ms = sws_1.In_ms(1);
sws_resp.In.rad = interp1(rad.nm, rad.Aper_B, sws_resp.In.nm,'pchip')./1000;
sws_resp.In.rad_units = 'W/(m^2 sr nm)';
sws_resp.In.resp = sws_resp.In.mean_spec./sws_resp.In.rad;

%    sws.time(f) = datenum(ds,'yyyymmddHHMM');
%    sws.tint(f) = sscanf(tint,'%d');
%    sws.Si_nm = tmp(:,1);
%    sws.Si_resp(:,f) = tmp(:,2);
%    sws.Si_resp_max(f) = max(sws.InGaAs_resp(:,f));
%    sws.InGaAs_nm = tmp(:,1);
%    sws.InGaAs_resp(:,f) = tmp(:,2);
%    sws.InGaAs_resp_max(f) = max(sws.InGaAs_resp(:,f));
%%

figure; plot(sws_resp.Si.nm, [sws_resp.Si.resp], '-',sws_resp.In.nm, [sws_resp.In.resp], '-');
title('SWS responsivity from radiance calibration')
legend('Si','InGaAs');
ylabel('resp [cpms / W)/(m^2 ster um)]')
xlabel('wavelength [nm]')
%%
savefig;
%%
!! Make corresponding changes to subsequent cals for this date
sws_20111111_Si_resp = [sws_resp.Si.nm,sws_resp.Si.resp];
sws_20111111_In_resp = [sws_resp.In.nm,sws_resp.In.resp];

%%
[pn, ~, ext] = fileparts(sws.filename);
resp_stem = ['sgpswsC1.resp_func.',datestr(sws_resp.Si.time,'yyyymmdd_HHMMSS'),'.mat'];
save([pn,filesep,resp_stem], 'sws_resp');

% resp_stem = ['sgpswsC1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms.dat'];
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_Si_resp,sws_1.time(1),sws_1.Si_ms(1));
%%
[resp_stem, resp_dir] = gen_sws_resp_files(sws_20111111_In_resp,sws_1.time(1),sws_1.In_ms(1));

return