function sws_cal_2009_July
%Load an existing response function for the wavelength scale
%%
resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
tmp = load([resp_dir, 'sgpswsC1.resp_func.200707200000.si.100ms.dat']);
sws_resp.Si_lambda = tmp(:,1);
sws_resp.Si_base = tmp(:,2);
tmp = load([resp_dir, 'sgpswsC1.resp_func.200707200000.ir.250ms.dat']);
sws_resp.In_lambda = tmp(:,1);
sws_resp.In_base = tmp(:,2);

%%
% Load the March 14 ARCHI file
Archi_30 = loadinto('C:\mlib\sws\ARCHI_30_20080314.mat');
%%
Archi_30.radiance_units = ['W/(m^2.sr.nm)'];
sws_resp.radiance_units = ['W/(m^2.sr.nm)'];
% Archi_30.lamps_12.rad = Archi_30.lamps_12.rad./1000;
% Archi_30.lamps_9.rad = Archi_30.lamps_9.rad./1000;
% Archi_30.lamps_6.rad = Archi_30.lamps_6.rad./1000;
% Archi_30.lamps_3.rad = Archi_30.lamps_3.rad./1000;

sws_resp.Archi_30.lamps_12.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_12.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_9.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_9.rad, sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_6.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_6.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_3.Si_rad = interp1(Archi_30.nm,Archi_30.lamps_3.rad,sws_resp.Si_lambda, 'linear');
sws_resp.Archi_30.lamps_12.In_rad = interp1(Archi_30.nm,Archi_30.lamps_12.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_9.In_rad = interp1(Archi_30.nm,Archi_30.lamps_9.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_6.In_rad = interp1(Archi_30.nm,Archi_30.lamps_6.rad,sws_resp.In_lambda, 'linear');
sws_resp.Archi_30.lamps_3.In_rad = interp1(Archi_30.nm,Archi_30.lamps_3.rad,sws_resp.In_lambda, 'linear');
save('C:\mlib\sws\ARCHI_30_20080314.mat','Archi_30')

%%

%%
pname = ['C:\case_studies\SWS\calibration\NASA_ARC_2009_07_01\'];
f1 = 'sgpswscf.00.20090701.200413.raw.dat';
f2 = 'sgpswscf.00.20090701.200742.raw.dat';
f3 = 'sgpswscf.00.20090701.200917.raw.dat';
sws_ = read_sws_raw([pname, f1]);
sws_ = cat_sws_raw(sws_,read_sws_raw([pname, f2]));
sws_ = cat_sws_raw(sws_,read_sws_raw([pname, f3]));
sws_.shutter = mean(sws_.Si_DN,1)<150;
lights_A = make_sws_cal_pair(sws_);
%%
% sgpswscf.00.20090909.010740.raw.dat 12-lamps, Si_ms = 80, In_ms = 220
% sws_raw = read_sws_raw('C:\case_studies\SWS\calibration\NASA_ARC_2009_09_08\ARCI_30in_sphere_radiance_cal\12_lamps\sgpswscf.00.20090909.010740.raw.dat');

%Archi Radiance is in units W(m^2.sr.um)

% ARM netcdf radiance is in W/(m^2 nm sr)
%%

nm_max = 1040;
% cm_max = nm_max / 1e7;
% T = 0.28978./cm_max;
T = 2850 ;
p_T = planck_in_wl(Archi_30.nm./1e9,T); 
cm_max = 0.28978./T;
nm_max = 1e7*cm_max;
nm_ind = round(interp1(Archi_30.nm,[1:length(Archi_30.nm)],nm_max));
%%
sws_resp.Archi_30.lamps_12.Si_avg_cps = lights_A.avg_Si_per_ms;
sws_resp.Archi_30.lamps_12.Si_resp = sws_resp.Archi_30.lamps_12.Si_avg_cps ./ sws_resp.Archi_30.lamps_12.Si_rad;
sws_resp.Archi_30.lamps_12.In_avg_cps = lights_A.avg_In_per_ms;
sws_resp.Archi_30.lamps_12.In_resp = sws_resp.Archi_30.lamps_12.In_avg_cps ./ sws_resp.Archi_30.lamps_12.In_rad;
sws_resp.Archi_30.lamps_12.Si_avg_SNR = lights_A.avg_Si_SNR;
sws_resp.Archi_30.lamps_12.In_avg_SNR = lights_A.avg_In_SNR;

figure; 
hold('on');
plot(sws_resp.Si_lambda, sws_resp.Archi_30.lamps_12.Si_resp, 'bx',...
   sws_resp.In_lambda, sws_resp.Archi_30.lamps_12.In_resp, 'rx')
title('Responsivity of SWS Si and InGaAs detectors')
xlabel('wavelength')
ylabel(['DN/',sws_resp.radiance_units]);
hold('off');
%%
resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
si_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.si.',num2str(lights_A.Si_ms(1)),'ms.dat'];
ir_stem = ['sgpswsC1.resp_func.',datestr(lights_A.time(1),'yyyymmdd0000'),'.ir.',num2str(lights_A.In_ms(1)),'ms.dat'];
si_out = [sws_resp.Si_lambda, sws_resp.Archi_30.lamps_12.Si_resp]';
In_out = [sws_resp.In_lambda, sws_resp.Archi_30.lamps_12.In_resp]';
si_fid = fopen([resp_dir,si_stem],'w');
fprintf(si_fid,'   %5.3f    %5.3f \n',si_out);
fclose(si_fid);
In_fid = fopen([resp_dir,ir_stem],'w');
fprintf(In_fid,'   %5.3f    %5.3f \n',In_out);
fclose(In_fid);

