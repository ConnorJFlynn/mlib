%% 
% open SWS

sws = ancload(getfullname_('sgpsws*.cdf','sws'));
%%
sasze = ancload(getfullname_('sgpsasze*.cdf','sasze'));
% sasze = anccat(sasze, ancload(getfullname_('sgpsasze*.cdf','sasze')));
%%


%%
sws_light= sws.vars.shutter_closed.data==0;
sws_light_ii = find(sws_light);
sas_light = sasze.vars.shutter_state.data==1;
sas_light_ii = find(sas_light);
sas_dark = mean(sasze.vars.spectra.data(:,~sas_light),2);
sas_spec = sasze.vars.spectra.data - sas_dark*ones(size(sasze.time));
%%
[ainb,bina] = nearest(sws.time(sws_light), sasze.time(sas_light));
%%
sas_nm = interp1([sasze.vars.wavelength.data],[1:length(sasze.vars.wavelength.data)],[1000:100:1600],'nearest');
sws_nm = interp1([sws.vars.wavelength.data],[1:length(sws.vars.wavelength.data)],[1000:100:1600],'nearest');
%%
%figure; plot(serial2Hh(sws.time(sws_light_ii(ainb))), sws.vars.zen_spec_calib.data(sws_nm500,sws_light_ii(ainb)),'.');
figure; plot(serial2Hh(sasze.time(sas_light_ii(bina))), sas_spec(sas_nm,sas_light_ii(bina)),'.')
legend('1000','1100','1200','1300','1400','1500','1600','1700')
%%
figure; plot(serial2Hh(sws.time(sws_light_ii(ainb))), sws.vars.zen_spec_calib.data(sws_nm,sws_light_ii(ainb)),'.')
legend('1000','1100','1200','1300','1400','1500','1600','1700')

%%
figure; plot(serial2Hh(sasze.time(sas_light_ii(bina))), sas_spec(sas_nm([1:4 6 7]),sas_light_ii(bina))./sws.vars.zen_spec_calib.data(sws_nm([1:4 6 7]),sws_light_ii(ainb)),'.')
legend('1000','1100','1200','1300','1400','1500','1600','1700')
%%
%%
sas_nm = interp1([sasze.vars.wavelength.data],[1:length(sasze.vars.wavelength.data)],[400:100:1000],'nearest');
sws_nm = interp1([sws.vars.wavelength.data],[1:length(sws.vars.wavelength.data)],[400:100:1000],'nearest');
%%
%figure; plot(serial2Hh(sws.time(sws_light_ii(ainb))), sws.vars.zen_spec_calib.data(sws_nm500,sws_light_ii(ainb)),'.');
figure; plot(serial2Hh(sasze.time(sas_light_ii(bina))), sas_spec(sas_nm,sas_light_ii(bina)),'.');
s(1)= gca;
figure;  plot(serial2Hh(sasze.time(sas_light_ii(bina))), sas_spec(sas_nm([1:4 6 7]),sas_light_ii(bina))./sws.vars.zen_spec_calib.data(sws_nm([1:4 6 7]),sws_light_ii(ainb)),'.')
s(2) = gca;
legend('400','500','600','700','800','1000')
linkaxes(s,'x')
%%
figure; plot(serial2Hh(sasze.time(sas_light_ii(bina))), [mean(sas_spec([378:385],sas_light_ii(bina)));3.2e5.*sws.vars.zen_spec_calib.data(sws_nm(2),sws_light_ii(ainb))],'.')


