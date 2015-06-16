function [Si_resp, In_resp] = radcal_sws_vs_lamps_at_Co_Sebastian_Schmidt
% SWS_Co_cal
% So, I think I need to:
% 1. Read in SWS spectra: compute dark-subtracted count rates (counts/integration time)
% 2. Read in Sebastian's lamp irradiance
% 3. Multiply by spectralon reflectivity (interpolated to matching nm?)
% 4. Divide 1 by 3 to get responsivity.
%
% This is all good except Sebastian accidentally supplied the Si
% responsivity curve for both Si and In.  But our values for Si agree
% nicely so presumably the InGaAs values would as well.

%%
sws = [];
done = false;
sws_name = getfullname('*raw.dat','sws_raw');
sws = read_sws_raw_2(sws_name);
while ~isempty(sws_name)
    sws_name = getfullname('*raw.dat','sws_raw');
    if ~isempty(sws_name)
        sws = cat_sws_raw_2(sws,read_sws_raw_2(sws_name));
    end    
end
     
    
dark = mean(sws.Si_DN(:,sws.shutter~=0),2);
light = mean(sws.Si_DN(:,sws.shutter==0),2);
sws.Si_sig = (light-dark)./unique(sws.Si_ms);
sws.Si_dark = dark;
dark = mean(sws.In_DN(:,sws.shutter~=0),2);
light = mean(sws.In_DN(:,sws.shutter==0),2);
sws.In_sig = (light-dark)./unique(sws.In_ms);
sws.In_dark = dark;

[tmp, fname] = fileparts(sws.filename);
figure; plot(sws.Si_lambda, sws.Si_sig,'b-',sws.In_lambda, sws.In_sig,'c-')
title({fname;[ 'Si:',num2str(unique(sws.Si_ms)), ', InGaAs:',num2str(unique(sws.In_ms))]}, 'interp','none');



%%
clear lamp_506 % F[uW/(cm^2*nm)]
fid_506 = fopen(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\f506.txt']);
tmp = textscan(fid_506, '%f %f ','headerlines',1); fclose(fid_506);
lamp_506.wl_nm = tmp{1};
lamp_506.I = tmp{2}./1e6;
figure; plot(lamp_506.wl_nm, lamp_506.I,'o-');
rad_506 = planck_fit(lamp_506.wl_nm, lamp_506.I,[sws.Si_lambda;sws.In_lambda]);
% figure; plot(lamp_506.wl_nm, lamp_506.I, 'o',rad_506.nm, rad_506.Irad, '-r.');
% title('Based on irradiance of lamp 506 in units F[uW/(cm^2*nm)]','interp','none');
%% lamp 577 Irradiance [W/(cm^2 nm)]  These numbers should be smaller than lamp 506 by about 1e6.
% fid_577 = fopen(['C:\case_studies\radiation_cals\2012_12_12_SWS_NOAA_Schmidt\F577N0.STD']);
% tmp = textscan(fid_577, '%f %f','headerlines',1,'delimiter',','); fclose(fid_577);
% lamp_577.wl_nm = tmp{1};
% lamp_577.I = tmp{2};
% rad_577 = planck_fit(lamp_577.wl_nm, lamp_577.I,[sws.Si_lambda;sws.In_lambda]);
% figure; plot(lamp_577.wl_nm, lamp_577.I, 'o',rad_577.nm, rad_577.Irad, '-r.');
% title('Based on irradiance of lamp 577 in units F[W/(cm^2*nm)]','interp','none');
%%
tmp = loadit(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\12x12_spectralon.txt']);
spec_panel.nm = tmp(:,1);
spec_panel.Refl = tmp(:,2);
% figure; plot(spec_panel.nm, spec_panel.Refl,'o-');
spec_panel.SWS_nm = [sws.Si_lambda;sws.In_lambda];
% spec_panel.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, spec_panel.SWS_nm,'linear','extrap','nearest');
spec_panel.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, spec_panel.SWS_nm,'linear');
ext = isNaN(spec_panel.SWS_refl);
spec_panel.SWS_refl(ext) = interp1(spec_panel.nm, spec_panel.Refl, spec_panel.SWS_nm(ext),'nearest','extrap');
% figure; plot(spec_panel.nm, spec_panel.Refl,'o',spec_panel.SWS_nm, spec_panel.SWS_refl,'.');
%%

% Try to fix units to match Sebastian's
% rad_577 is in units Irradiance [W/(cm^2 nm)]
% SS responsivity is in units (counts/ms)/(W/m2/nm/sr)
% So to get rad_577_Irad in same units, we need to multiply it by a 1e4.




%%
% F[uW/(cm^2*nm)]  
%  (W/ (m^2 * nm) / sr)

fid_resp_Si = fopen(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\sws_si_resp.asc']);
tmp = textscan(fid_resp_Si, '%f %f %f %f %f %f %f','headerlines',1); fclose(fid_resp_Si);
Si_resp.nm = tmp{1};
Si_resp.fel506_240ms = tmp{2}; %     fel577_80ms2
Si_resp.fel506_80ms1  = tmp{3};
Si_resp.fel506_80ms2 = tmp{4};
Si_resp.fel577_240ms = tmp{5};
Si_resp.fel577_80ms1 = tmp{6};
Si_resp.fel577_80ms2 = tmp{7};
clear tmp
%%
fid_resp_In = fopen(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\sws_ingaas_resp.asc']);
tmp = textscan(fid_resp_In, '%f %f %f %f %f %f %f','headerlines',1); fclose(fid_resp_In);
In_resp.nm = tmp{1};
In_resp.fel506_100ms = tmp{2}; %     fel577_80ms2
In_resp.fel506_200ms  = tmp{3};
In_resp.fel506_240ms = tmp{4};
In_resp.fel577_100ms = tmp{5};
In_resp.fel577_200ms = tmp{6};
In_resp.fel577_240ms = tmp{7};
%%

sws.Si_resp = sws.Si_sig./(1e4.*rad_506.Irad(1:256).*spec_panel.SWS_refl(1:256)./pi);
sws.In_resp = sws.In_sig./(1e4.*rad_506.Irad(257:end).*spec_panel.SWS_refl(257:end)./pi);
figure; plot(sws.Si_lambda, Si_resp.fel506_240ms,'rx-',sws.Si_lambda, sws.Si_resp,'o-',...
    sws.In_lambda, In_resp.fel506_100ms, 'rx-',sws.In_lambda, sws.In_resp,'o-');
title('Responsivity from FEL 506, Si 80 ms');
ylabel('resp [(counts/ms)/(W/m2/nm/sr)]')
xlabel('wavelength [nm]')
legend('S Schmidt','Mine');
%%
resp_Si = [sws.Si_lambda, sws.Si_resp];
[resp_stem, resp_dir] = gen_sws_resp_files(resp_Si,floor(sws.time(1)), unique(sws.Si_ms),'D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\resp_files\');
%%
resp_InGaAs = [sws.In_lambda, sws.In_resp];
[resp_stem, resp_dir] = gen_sws_resp_files(resp_InGaAs,floor(sws.time(1)), unique(sws.In_ms),'D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\resp_files\');
%%
% Now let's also output the responsivity files in the newer "SASZe" style
% format, as a mat file, and a figure
%%

return
