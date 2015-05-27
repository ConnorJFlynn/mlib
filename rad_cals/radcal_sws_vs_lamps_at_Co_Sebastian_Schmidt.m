function [Si_resp, In_resp] = radcal_sws_vs_lamps_at_Co_Sebastian_Schmidt
% SWS_Co_cal
% This routine computes the spectral radiance calibration of the SWS based
% on measurements conducted at Co by Sebastian Schmid with two different
% FEL lamps.  It then compares the results of my calculations with
% Sebastians as read in from a text file he provided.  The comparison is
% solid.
% This routine does NOT generate SWS-type responsivity files based on these
% computations.  See the related functions _lamp_506_ and _lamp_577_ for
% these. 
%%
sws = [];
done = false;
while ~done
    sws = cat_sws_raw_2(sws,read_sws_raw_2);
    ok = menu('Select another file?','Yes','No');
    if ok==2
        done = true;
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
lamp_506.I = tmp{2};
figure; plot(lamp_506.wl_nm, lamp_506.I,'o-');
rad_506 = planck_fit(lamp_506.wl_nm, lamp_506.I,[sws.Si_lambda;sws.In_lambda]);
figure; plot(lamp_506.wl_nm, lamp_506.I, 'o',rad_506.nm, rad_506.Irad, '-r.');
title('Based on irradiance of lamp 506 in units F[uW/(cm^2*nm)]','interp','none');
%% lamp 577 Irradiance [W/(cm^2 nm)]  These numbers should be smaller than lamp 506 by about 1e6.
fid_577 = fopen(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\F577N0.STD']);
tmp = textscan(fid_577, '%f %f','headerlines',1,'delimiter',','); fclose(fid_577);
lamp_577.wl_nm = tmp{1};
lamp_577.I = tmp{2};
rad_577 = planck_fit(lamp_577.wl_nm, lamp_577.I,[sws.Si_lambda;sws.In_lambda]);
figure; plot(lamp_577.wl_nm, lamp_577.I, 'o',rad_577.nm, rad_577.Irad, '-r.');
title('Based on irradiance of lamp 577 in units F[W/(cm^2*nm)]','interp','none');
%%
tmp = loadit(['D:\case_studies\radiation_cals\2012_12_12.SWS_NOAA_Schmidt\12x12_spectralon.txt']);
spec_panel.nm = tmp(:,1);
spec_panel.Refl = tmp(:,2);
figure; plot(spec_panel.nm, spec_panel.Refl,'o-');
spec_panel.SWS_nm = [sws.Si_lambda;sws.In_lambda];
spec_panel.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, spec_panel.SWS_nm,'linear');
ext = isNaN(spec_panel.SWS_refl);
spec_panel.SWS_refl(ext) = interp1(spec_panel.nm, spec_panel.Refl, spec_panel.SWS_nm(ext),'nearest','extrap');
figure; plot(spec_panel.nm, spec_panel.Refl,'o',spec_panel.SWS_nm, spec_panel.SWS_refl,'.');
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
%%

sws.Si_resp = sws.Si_sig./(1e4.*rad_577.Irad(1:256).*spec_panel.SWS_refl(1:256)./pi);
figure; plot(sws.Si_lambda, Si_resp.fel577_80ms1,'rx-',sws.Si_lambda, sws.Si_resp(1:256),'o-' );
title('Responsivity from FEL 577, Si 80 ms');
ylabel('resp [(counts/ms)/(W/m2/nm/sr)]')
xlabel('wavelength [nm]')
legend('S Schmidt','Mine/2');
%%

figure; plot(Si_resp.nm, [Si_resp.fel506_240ms,Si_resp.fel506_80ms1,Si_resp.fel506_80ms2,Si_resp.fel577_240ms,Si_resp.fel577_80ms1,...
    Si_resp.fel577_80ms2],'-');
title('Sebastian''s responsivities for both lamps: (counts/ms)/(W/m2/nm/sr)','interp','none')
