function resp = sws_cal_Nov2011
% function resp = sws_cal_Nov2011

% Check ARS cals
%%
in = '*ars*.txt';
[ars455_1] = get_ars455_Nov2011(getfullname(in,'radcals','Select a calibrated radiance file'));
[ars455_2] = get_ars455_Nov2011(getfullname(in,'radcals','Select a calibrated radiance file'));
%%
[ainb, bina] = nearest(ars455_1.nm, ars455_2.nm);
figure; plot(ars455_1.nm(ainb), [ars455_1.Aper_A(ainb)./ars455_2.Aper_A(bina),...
    ars455_1.Aper_B(ainb)./ars455_2.Aper_B(bina),ars455_1.Aper_C(ainb)./ars455_2.Aper_C(bina),...
    ars455_1.Aper_D(ainb)./ars455_2.Aper_D(bina),ars455_1.Aper_O(ainb)./ars455_2.Aper_O(bina)],'-'); 
lg = legend('Aper_A','Aper_B','Aper_C','Aper_D','Aper_O'); set(lg,'interp','none');

%% 
% Now get the SWS data for the last calibration
% C:\case_studies\radiation_cals\2011_Nov_ARC\2011_Nov_09_NASA_Ames
pname = 'C:\case_studies\radiation_cals\2011_Nov_ARC\2011_Nov_09_NASA_Ames\';
files = dir([pname, 'sgpsws*.dat']);
sws = read_sws_raw_2([pname, files(1).name]);
for f = 2:length(files)
    sws = cat_sws_raw_2(sws,read_sws_raw_2([pname, files(f).name]));
end
resp = [];
%%
[~,peak] = max(sws.Si_spec(:,50))
figure; plot(serial2Hh(sws.time), sws.Si_DN(peak,:),'o')
%%