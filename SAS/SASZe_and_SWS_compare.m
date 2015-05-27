% Compare SAS-Ze and SWS for June30
% Notes from Apr 5 2012 call with Eli and Matt:
% 1. Get new/correct SSA and g for July 23, 2011
% 2. Resolve SWS Si to InGaAs
% 3. Run SWS wtih new responsivities.


% Determine new SWS responsivity from ARCHI cals of Nov 2011. 
%       Also examine difference between ARCHI and Optronics cals, same day
%       Also compare to previous March 2011 cals with Optronics
% Determine transfer function from SWS to SASZe from PNNL (when?)
% 
% sws = loadinto(['C:\case_studies\SGP\June30\sws_raw\sgpswsC1.00.20110630.000002.raw.20110630.000002.radiance.mat']);
sws = loadinto(['C:\case_studies\SGP\July23\sws_raw\sgpswsC1.00.20110723.110132.raw.20110723.110132.radiance.mat']);

%%
figure; lines = plot([sws.Si_lambda;sws.In_lambda], [sws.Si_spec(:,1:100:end); sws.In_spec(:,1:100:end)],'-'); recolor(lines, serial2Hh(sws.time(1:100:end)));colorbar

%%
% sasze = ancload(['C:\case_studies\SGP\June30\sgpsaszevisC1.a0.20110630.000000.cdf']);
% sasnir = ancload(['C:\case_studies\SGP\June30\sgpsaszenirC1.a0.20110630.000000.cdf']);
%%
sasnir = ancload('C:\case_studies\SGP\July23\sgpsaszenirC1.a0.20110723.000001.cdf');
%%
pname = 'C:\case_studies\SGP\July23\';
vis = dir([pname,'sgpsaszevisC1.a0.*.cdf']);
if ~isempty(vis)
    sasze = ancload([pname,vis(1).name]);
end
for f = 2:length(vis)
    sasze = anccat(sasze, ancload([pname, vis(f).name]));
end
%%

sws_ii = find(sws.shutter~=1);
sas_ii = find(sasze.vars.shutter_state.data~=0);

[ainb, bina] = nearest(sws.time(sws_ii), sasze.time(sas_ii));
[ainc, cina] = nearest(sws.time(sws_ii), sasnir.time(sas_ii));

%%
sws500nm = interp1(sws.Si_lambda, [1:length(sws.Si_lambda)],[400:50:980],'nearest');
sas500nm = interp1(sasze.vars.wavelength.data, [1:length(sasze.vars.wavelength.data)],[400:50:980],'nearest');
figure; 
sb(1) = subplot(2,1,1);
plot(serial2Hh(sws.time(sws_ii(ainb))), sws.Si_spec(sws500nm, sws_ii(ainb)), 'b-', ...
    serial2Hh(sws.time(sws_ii(ainb))), sasze.vars.spectra.data(sas500nm, sas_ii(bina)), 'r-');
sb(2) = subplot(2,1,2);
lines = plot(serial2Hh(sws.time(sws_ii(ainb))), sasze.vars.spectra.data(sas500nm, sas_ii(bina))./sws.Si_spec(sws500nm, sws_ii(ainb)) , '-');
recolor(lines, sws.Si_lambda(sws500nm)');
linkaxes(sb,'x')

%%
sws_noon = sws.shutter~=1 & serial2Hh(sws.time)>18& serial2Hh(sws.time)<18.5;
sas_noon = sasze.vars.shutter_state.data~=0 & serial2Hh(sasze.time)>18& serial2Hh(sasze.time)<18.5;
figure; plot(sws.Si_lambda(sws500nm), mean(sasze.vars.spectra.data(sas500nm,sas_noon),2)...
    ./mean(sws.Si_spec(sws500nm, sws_noon),2),'o-');
xlabel('wavelength')
ylabel('sas/sws')
%%

%%
swsnir = interp1(sws.In_lambda, [1:length(sws.In_lambda)],[925:10:1700],'nearest');
sasnir_nm = interp1(sasnir.vars.wavelength.data, [1:length(sasnir.vars.wavelength.data)],[925:10:1700],'nearest');
figure; 
sb(1) = subplot(2,1,1);
plot(serial2doy(sws.time(sws_ii(ainc))), sws.In_spec(swsnir, sws_ii(ainc)), 'b-', ...
    serial2doy(sws.time(sws_ii(ainc))), sasnir.vars.spectra.data(sasnir_nm, sas_ii(cina)), 'r-');
sb(2) = subplot(2,1,2);
lines = plot(serial2doy(sws.time(sws_ii(ainc))), sasnir.vars.spectra.data(sasnir_nm, sas_ii(cina))./sws.In_spec(swsnir, sws_ii(ainc)) , '-');
recolor(lines, sws.In_lambda(swsnir)');
linkaxes(sb,'x')

%%
sws_noon = sws.shutter~=1 & serial2Hh(sws.time)>18& serial2Hh(sws.time)<18.5;
sas_nir_noon = sasnir.vars.shutter_state.data~=0 & serial2Hh(sasnir.time)>18& serial2Hh(sasnir.time)<18.5;
figure; plot(sws.Si_lambda(sws500nm), mean(sasze.vars.spectra.data(sas500nm,sas_noon),2)...
    ./mean(sws.Si_spec(sws500nm, sws_noon),2),'o-',sws.In_lambda(swsnir), 1.5.*mean(sasnir.vars.spectra.data(sasnir_nm,sas_nir_noon),2)...
    ./mean(sws.In_spec(swsnir, sws_noon),2),'o-');
xlabel('wavelength')
ylabel('sas/sws')