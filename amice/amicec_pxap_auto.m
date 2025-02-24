function pxap = amicec_pxap_auto;
[resets] = rd_pxapo_;
pxapr = rd_pxapr_;

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
pxap.wl = [470,522,660];
P_LPM = get_flowcal(pxap.pxap_name);
pxap.flow_lpm = pxapr.flow_LPM;
pxap.P_LPM = P_LPM;
pxap.flow_LPM = polyval(P_LPM, pxap.flow_lpm);
pxap.flow_LPMsm = smooth(pxap.flow_LPM,300);

pxap.Bap_raw = NaN(size(pxap.Tr));
[time, ij] = unique(pxap.time);

tmp = Bap_ss(time, pxap.flow_LPMsm(ij), pxap.Tr(ij,:), 300);
pxap.Bap_raw(ij,:) = tmp;
[~,K_WBOF,Kk] = WeissBondOgrenFlynn(pxap.Tr);
figure; plot(pxap.time, pxap.Bap_raw,'.', pxap.time, K_WBOF.*pxap.Bap_raw,'-'); sgtitle(pxap.pxap_name); dynamicDateTicks
xxl = xlim; xxl_ = pxap.time>xxl(1)&pxap.time<xxl(2); 
xxl_i = find(xxl_,1,'first'); %better is to find and divide y-intercept
X = -log(pxap.Tr(xxl_,:)); Y = pxap.Bap_raw(xxl_,:);
Pxy(3,:) = polyfit(X(:,3),Y(:,3),1);
Pxy(2,:) = polyfit(X(:,2),Y(:,2),1);
Pxy(1,:) = polyfit(X(:,1),Y(:,1),1);

figure; plot(-log(pxap.Tr(xxl_,:)), pxap.Bap_raw(xxl_i,:)./pxap.Bap_raw(xxl_,:),'o')
figure; plot(-log(pxap.Tr(xxl_,:)), Pxy(:,2)'./pxap.Bap_raw(xxl_,:),'.')



for t = length(pxap.time):-1:1
   P_aae = polyfit(log(pxap.wl), log(pxap.Bap_raw(t,:)),2);
   P_aae = polyder(P_aae);
   pxap.AAE(t,:) = -real(polyval(P_aae,log(pxap.wl)));
   pxap.AAE_500(t) = -real(polyval(P_aae,log(500)));
end
% figure; plot(pxap.time, pxap.AAE,'.', pxap.time, pxap.AAE_500,'k.');dynamicDateTicks



return

function P_LPM = get_flowcal(xap_name);
flowcal_path = getfilepath('AMICE_flowcals');
if  strcmpi(xap_name, 'psap77')
   flowcal = load([flowcal_path,'psap77.mat']);
elseif strcmpi(xap_name, 'psap110')
   flowcal = load([flowcal_path,'psap110.mat']);
elseif strcmpi(xap_name, 'psap123')
   flowcal = load([flowcal_path,'psap123.mat']);
end
P_LPM = flowcal.P_LPM;
return