function prede = prede_aod(prede);
% Load prede sun data, adjust for soldst
% Load prede Vos
% Compute transmittances
% Load met data...
% Compute Rayleigh 
% s.tau_ray=rayleighez(s.w,s.Pst,s.t,s.Lat);
if ~exist('prede','var')||(~isstruct(prede)&&~exist(prede,'file'))
    prede = getfullname_('*.SUN','prede_sun');
end
if ~isstruct(prede)
    prede = read_prede(prede);
end
 %%
%  prede.LatN = prede.header.lat;% MLO is 19.5365;
%  prede.LonE = prede.header.lon; % MLO is -155.5761;
%  prede.wl = prede.header.wl;
%  [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
%     sunae(prede.LatN, prede.LonE, prede.time);

 %%
 langs = loadinto(['C:\case_studies\4STAR\data\2012_MLO_May_June\prede\Vo\12060300.all_Vos.mat']);
 %%
 prede.Vo = langs.mean_Vo;
 prede.Tr = [prede.filter_1;prede.filter_2;prede.filter_3;prede.filter_4;...
     prede.filter_5;prede.filter_6;prede.filter_7]./(langs.mean_Vo*ones(size(prede.time)));
 % Adjust 870 nm cal
 prede.Tr(5,:) = prede.Tr(5,:) .* 1.07;
 prede.Tr(7,:) = prede.Tr(7,:) .* .94;
 
 prede.Tr = prede.Tr.*(ones(size(prede.header.wl))*prede.soldst);
 prede.tau = -log(prede.Tr)./(ones(size(prede.wl))*prede.airmass);

 %%
 met = loadinto(['C:\case_studies\4STAR\data\2012\TCAP\hyannis_met.mat']);
 %%
 prede.pres_mb = interp1(met.time, met.pres_mb,prede.time,'linear','extrap');
 %%
 %tau_ray=rayleighez(prede.wl./1000,prede.pres_mb,mean(prede.time),prede.LatN);
 tau_ray = tau_std_ray_atm(prede.wl./1000)*prede.pres_mb./1013;
 prede.tau_ray = tau_ray;
 prede.aod = prede.tau - prede.tau_ray;
 %%
 
 [aero, eps] = aod_screen(prede.time, prede.tau(3,:), 0, 1, 10,4,1.3e-3,[],[],.2);
 aero_ = aero;
 [aero(aero_),eps(aero_)] = aod_screen(prede.time(aero), prede.tau(3,aero), 0, 1, 10,3,1e-4,[],[],.2);
 prede.aero = aero; prede.eps = eps;
 
 %%
 %This yields an angstrom exponent with the 0th element as alpha, the 1th element as beta (curvature of angstrom), 
 % and the 2nd (last, highest order) element equal to the AOD at 500.
 for t = 1:length(prede.time)
  prede.Ang_fit(t,:) = polyfit(log(prede.wl(2:4)./500),log(prede.aod(2:4,t)),2);
 end
 prede.alpha = prede.Ang_fit(:,1);
 prede.alpha = -prede.Ang_fit(:,end);
if length(prede.Ang_fit(1,:)>2) 
    prede.beta = prede.Ang_fit(:,2);
else
    prede.beta = zeros(size(prede.alpha));
end
 
 %%
 figure; ax(1) = subplot(2,1,1);
 plot(serial2doy(prede.time(aero)), prede.aod([2:5 7],aero),'o');
 legend(sprintf('%d nm',prede.wl(2)),sprintf('%d nm',prede.wl(3)),...
     sprintf('%d nm',prede.wl(4)),sprintf('%d nm',prede.wl(5)),sprintf('%d nm',prede.wl(7)));
 grid('on');
 hold('on')
 plot(serial2doy(prede.time(:)), prede.aod([2:5 7],:),'k.');
 hold('off')
 ylim([0,.25]);
 title(['Prede AOD for ',datestr(prede.time(1),'yyyy-mm-dd'), ' (Rayleigh subtracted)']);
 zoom('on');
 ylabel('aod')
 ax(2) = subplot(2,1,2);
 plot(serial2doy(prede.time), prede.alpha,'o');
 ylim([-.25 3]);
 ylabel('angstrom exp')
 xlabel('time [day of year]');
 linkaxes(ax,'x');
 ok = false
 while ~ok
     ok = ~isempty(menu('Zoom in and hit OK when finished.','OK'))
 end
 saveas(gcf,[prede.pname, 'Prede_aod.',datestr(mean(prede.time),'yyyy_mm_dd'), '.png']);
 saveas(gcf,[prede.pname, 'Prede_aod.',datestr(mean(prede.time),'yyyy_mm_dd'), '.fig']);
 %%
%  figure; semilogy(log(prede.wl(2:4)),prede.aod(2:4,250),'-x', log(prede.wl(2:4)), exp(polyval(prede.Ang_fit(250,:),log(prede.wl(2:4)./500))),'-o')
%  
%  %%
%  xl =xlim;
%  figure; semilogy(log10(prede.wl([2:5 7])),(mean(prede.aod([2:5,7],serial2doy(prede.time)>xl(1)&serial2doy(prede.time)<xl(2)),2)),'-o')
 %%
 
 save([prede.pname, 'Prede_aod.',datestr(mean(prede.time),'yyyy_mm_dd'), '.mat'],'prede');
 
  return