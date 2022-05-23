function oriel = irad_oriel_5115
% irad in [mw/(m2 nm)]
% divide by 10 to get uw/(cm^2 nm)
% rad in irad/sr
% Model No. 63355 Quartz Tungsten Halogen lamp
% 
% Lamp Serial No.: 5115
% Spectral Range: 250-2400nm
% Lamp Current: 6.50 Amps
% Voltage (ref. Only) = 32 V
% Room Temperature: 25 C
% 
% Fitting equation for non-NIST wavelengths :
%  Or read in the *.S10 file?
% Irradiance (mW/m2 nm) = ?  -5 * exp(A + B/?) * (C + D/? + E/?2   + F/?3 + G/?4  + H/?5)
% (divide values by 10 to obtain results in ?W/cm2 nm)
nm = [250:2400];
% Where:
A= 42.8576801694148;
B=-4469.83666243075;
C=0.873067238930609;
D=332.894125987114;
E=-284164.563827635;
F=98047094.074996;
G=-12725581693.8496;
H=0;
irad = (nm.^-5) .* exp(A + B./nm) .* (C + D./nm + E./nm.^2 + F./nm.^3 + G./nm.^4  + H./nm.^5);

spec_panel = srt_sn_2784;
Refl = interp1(spec_panel.nm, spec_panel.Refl, nm,'linear');
rad = irad .* Refl ./pi;
oriel.nm = nm;
oriel.irad = irad;
oriel.rad = rad;
% oriel.plank_fit = planck_tungsten_fit(nm, irad,nm);
% 
% tmp = load(['D:\case_studies\radiation_cals\cal_sources_references_xsec\Spectralon_panels\Schmidt.12x12_spectralon.txt']);
% spec_panel.nm = tmp(:,1);
% spec_panel.Refl = tmp(:,2);
% figure; plot(spec_panel.nm, spec_panel.Refl,'o-');
% spec_panel.oriel_lamp.nm = nm;
% spec_panel.oriel_lamp.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, nm,'linear');
% ext = isNaN(spec_panel.SWS_refl);
% spec_panel.SWS_refl(ext) = interp1(spec_panel.nm, spec_panel.Refl, nm(ext),'nearest','extrap');
% figure; plot(spec_panel.nm, spec_panel.Refl,'o',spec_panel.SWS_nm, spec_panel.SWS_refl,'.');
% 
% rad = irad * .99 ./pi;
% These lines from S Schmidt SWS lamp+spectralon calibration
% radiance = (1e4.*rad_577.Irad(1:256).*spec_panel.SWS_refl(1:256)./pi);
% rad_506 = planck_fit(lamp_506.wl_nm, lamp_506.I,[sws.Si_lambda;sws.In_lambda]);

return