function ma = amicec_ma_auto;
ma = rd_ma;

% zoom into a time window of Tr_ to select a period to normalize against or...
% Possibly implement a fixed temporal window since we expect to run purge air at the 
% beginning of each run
%Or something else such as screened values during some initial start-up period
% or a test for stability, especially during purge air?
ma_name = fliplr(strtok(fliplr(strrep(ma.pname{1},'_','')),filesep));
ma_name = ['ma',ma_name(end-1:end)];
% P_LPM = get_flowcal(ma_name);
% ma.P_LPM = P_LPM;
% ma.flow1_LPM = polyval(P_LPM, ma.flow1);
ma.flow1_LPM = ma.flow1;

dt = abs(dtime(datevec(ma.time(end-1)), datevec(ma.time(end))));
ma.flow1_LPMsm = smooth(ma.flow1_LPM,300);
ma.Bap1_raw = Bap_ss(ma.time, ma.flow1_LPMsm, ma.Tr1, 300,7);

for t = length(ma.time):-1:1
   P_aae = polyfit(log(ma.nm), log(ma.Bap1_raw(t,:)),2);
   P_aae = polyder(P_aae);
   ma.AAE1(t,:) = -real(polyval(P_aae,log(ma.nm)));
   P_aae = polyfit(log(ma.nm), log(ma.Bap1_raw(t,:)),1);
   P_aae = polyder(P_aae);
   ma.AAE1_(t) = -(P_aae);
end

return

function P_LPM = get_flowcal(xap_name);
flowcal_path = getfilepath('AMICE_flowcals');
if  strcmpi(xap_name, 'ma92')
   flowcal = load([flowcal_path,'ma92.mat']);
elseif strcmpi(xap_name, 'ma94')
   flowcal = load([flowcal_path,'ma94.mat']);
end
P_LPM = flowcal.P_LPM;
return