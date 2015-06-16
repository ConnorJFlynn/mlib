function abe = abe_old_ql(abe_new, abe_old)

if ~exist('abe_new','var')
    infile = getfullname('sgpaerosol*.cdf','abe_new');
end
abe_new = ancload(infile);

%%
plot_qcs(abe_new)

%%


[pname, fname, ext] = fileparts(infile);
if ~exist('abe_old','var')
    infile = getfullname([fname,ext],'abe_old');
end
abe_old = ancload(infile);


%Start plotting aod fields
%%
miss = abe_new.vars.be_aod_500.data<=0;
abe_new.vars.be_aod_500.data(miss) = NaN;
miss = abe_new.vars.mean_aod_mfrsr_filter2.data<=0;
abe_new.vars.mean_aod_mfrsr_filter2.data(miss) = NaN;
miss = abe_new.vars.mean_aod_nimfr_filter2.data<=0;
abe_new.vars.mean_aod_nimfr_filter2.data(miss) = NaN;
miss = abe_new.vars.predicted_aod.data<=0;
abe_new.vars.predicted_aod.data(miss) = NaN;
 miss = abe_new.vars.mean_aod_aos.data <=0;
 abe_new.vars.mean_aod_aos.data(miss) = NaN;
 %%
% figure;
% %%
% s(1) = subplot(2,1,1);
% plot(serial2doy(abe_new.time), abe_new.vars.be_aod_500.data,'.');
% s(2) = subplot(2,1,2);
% plot(serial2doy(abe_new.time), [abe_new.vars.mean_aod_mfrsr_filter2.data;...
%     abe_new.vars.mean_aod_nimfr_filter2.data] ,'.',...
%     serial2doy(abe_new.time), abe_new.vars.predicted_aod.data, 'o');
% legend('mfrsr','nimfr','predicted')
% linkaxes(s,'xy');
% 
% %%
% plots_default;
% figure;
% plot(serial2doy(abe_old.time), abe_old.vars.mean_aod_mfrsr_filter2.data, 'rx',...
%     serial2doy(abe_new.time), [abe_new.vars.mean_aod_mfrsr_filter2.data],'ko');
% lg = legend('mfrsr_new','mfrsr_old'); set(lg,'interp','none');
% title('New MFRSR values were badly filtered but are now acceptable with some limited outliers remaining.')

%%


miss = abe_old.vars.be_aod_500.data<=0;
abe_old.vars.be_aod_500.data(miss) = NaN;
miss = abe_old.vars.mean_aod_mfrsr_filter2.data<=0;
abe_old.vars.mean_aod_mfrsr_filter2.data(miss) = NaN;
miss = abe_old.vars.mean_aod_nimfr_filter2.data<=0;
abe_old.vars.mean_aod_nimfr_filter2.data(miss) = NaN;
miss = abe_old.vars.predicted_aod.data<=0;
abe_old.vars.predicted_aod.data(miss) = NaN;
 miss = abe_old.vars.mean_aod_aos.data <=0;
 abe_old.vars.mean_aod_aos.data(miss) = NaN;
 miss = abe_old.vars.mean_aod_rl.data<=0;
 abe_old.vars.mean_aod_rl.data(miss) = NaN;
 %%
 figure; 
r(1) = subplot(2,1,1);
plot(serial2doy(abe_new.time), abe_new.vars.mean_aod_mfrsr_filter2.data,'o', serial2doy(abe_old.time), abe_old.vars.mean_aod_mfrsr_filter2.data,'.');
legend('new abe','old abe');
title('Best-estimate AOD');
grid('on');
r(2) = subplot(2,1,2);
plot(serial2doy(abe_old.time), abe_new.vars.be_aod_500.data, 'k+',...
    serial2doy(abe_old.time), abe_new.vars.predicted_aod.data ,'k.',...
    serial2doy(abe_new.time), abe_old.vars.be_aod_500.data, 'rx',...
    serial2doy(abe_new.time), abe_old.vars.predicted_aod.data, 'ro');
grid('on');
lg = legend('new be','new predicted','old be','old predicted'); 
set(lg, 'interp','none')
xlabel('day of year (2006)')
linkaxes(r,'x');
%%
return    
    