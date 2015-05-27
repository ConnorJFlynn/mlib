function frh = test_frh_longtime;
% Assess long time series of frh datastream
%%

frh = ancload;
doy_2006 = frh.time - datenum(2006,1,1)+1;
 

%%

frh.vars.RH_NephVol_Dry_span = frh.vars.RH_NephVol_Dry_min;
frh.vars.RH_NephVol_Dry_span.data = frh.vars.RH_NephVol_Dry_max.data- frh.vars.RH_NephVol_Dry_min.data;

frh.vars.RH_NephVol_Dry_delta = frh.vars.RH_NephVol_Dry_min;
frh.vars.RH_NephVol_Dry_delta.data(2:end) = max(diff(frh.vars.RH_NephVol_Dry_max.data),diff(frh.vars.RH_NephVol_Dry_min.data));

frh.vars.RH_NephVol_Dry_span = frh.vars.RH_NephVol_Dry_min;
frh.vars.RH_NephVol_Dry_span.data = frh.vars.RH_NephVol_Dry_max.data- frh.vars.RH_NephVol_Dry_min.data;


frh.vars.RH_NephVol_Wet_span = frh.vars.RH_NephVol_Wet_min;
frh.vars.RH_NephVol_Wet_span.data = frh.vars.RH_NephVol_Wet_max.data- frh.vars.RH_NephVol_Wet_min.data;

frh.vars.RH_NephVol_Wet_delta = frh.vars.RH_NephVol_Wet_min;
frh.vars.RH_NephVol_Wet_delta.data(2:end) = max(diff(frh.vars.RH_NephVol_Wet_max.data),diff(frh.vars.RH_NephVol_Wet_min.data));

frh.vars.RH_NephVol_Wet_span = frh.vars.RH_NephVol_Wet_min;
frh.vars.RH_NephVol_Wet_span.data = frh.vars.RH_NephVol_Wet_max.data- frh.vars.RH_NephVol_Wet_min.data;


%%
% plot frh ratio G 1 um, 2p
figure; plot(doy_2006,frh.vars.ratio_85by40_Bs_G_1um_2p.data,'o');
ylim([0,10]); zoom('on');
xlabel('days since Jan 1 2006')
ylabel('frh 85/40 ratio')
title(['ratio_85by40_Bs_G_1um_2p'],'interp','none')
%plot dry RH min/max/delta/span
figure; plot(doy_2006, frh.vars.RH_NephVol_Dry_min.data, '-c.',...
   doy_2006, frh.vars.RH_NephVol_Dry_max.data, '-ko',...
   doy_2006, frh.vars.RH_NephVol_Dry_span.data, '-ro',...
   doy_2006, frh.vars.RH_NephVol_Dry_delta.data, 'bo')
xlabel('days since Jan 1 2006')
ylabel('RH %')
title('dry RH values')
lg = legend('min dryRH','max dryRH','maxRH-minRH','diff(RH)');
set(lg,'interp','none')

%plot dry RH min/max/delta/span
figure; plot(doy_2006, frh.vars.RH_NephVol_Wet_min.data, '-c.',...
   doy_2006, frh.vars.RH_NephVol_Wet_max.data, '-ko',...
   doy_2006, frh.vars.RH_NephVol_Wet_span.data, '-ro',...
   doy_2006, frh.vars.RH_NephVol_Wet_delta.data, 'bo')
xlabel('days since Jan 1 2006')
ylabel('RH %')
title('Wet RH values')
lg = legend('min wetRH','max wetRH','maxRH-minRH','diff(RH)');
set(lg,'interp','none')
%%
