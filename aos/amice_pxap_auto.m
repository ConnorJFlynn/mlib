function pxap = amice_pxap_auto;
[resets] = rd_pxapo;
pxapr = rd_pxapr;

% zoom into a time window of Tr_ to select a period to normalize against or...
% Possibly implement a fixed temporal window since we expect to run purge air at the 
% beginning of each run
%Or something else such as screened values during some initial start-up period
% or a test for stability, especially during purge air?
for it = 1:length(resets.itime)
   its = pxapr.itime>=resets.itime(it);
   pxap.Tr(its,:) = pxapr.rel_BGR(its,:)./[resets.Bo(it),resets.Go(it), resets.Ro(it)];
end
pxap.pxap_name = fliplr(strtok(fliplr(strrep(pxapr.pname{1},'_','')),filesep));
pxap.time = pxapr.time;
P_LPM = get_flowcal(pxap.pxap_name);
pxap.flow_lpm = pxapr.flow_LPM;
pxap.P_LPM = P_LPM;
pxap.flow_LPM = polyval(P_LPM, pxap.flow_lpm);
pxap.flow_LPMsm = smooth(pxap.flow_LPM,300);
pxap.Bap_raw = Bap_ss(pxap.time, pxap.flow_LPMsm, pxap.Tr, 300);
% figure; plot(pxap.time, pxap.Bap_raw,'-'); sgtitle(pxap.pxap_name); dynamicDateTicks



return

function P_LPM = get_flowcal(xap_name);
flowcal_path = getnamedpath('AMICE_flowcals');
if  strcmpi(xap_name, 'psap77')
   flowcal = load([flowcal_path,'psap77.mat']);
elseif strcmpi(xap_name, 'psap110')
   flowcal = load([flowcal_path,'psap110.mat']);
elseif strcmpi(xap_name, 'psap123')
   flowcal = load([flowcal_path,'psap123.mat']);
end
P_LPM = flowcal.P_LPM;
return