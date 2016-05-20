function prede = prede_aod_osan(prede);
% prede = prede_aod_osan(prede)
% Computed AOD for a supplied or selected Prede "*.SUN" file during KorusAQ
% This initial version only includes calibrations for KORUS AQ from 
% MLO Jan 2016.  It assumes a Rayleigh OD for an atmospheric pressure of 
% 1005.5 kPa based on local meteorology during May 4-11 for Osan.

if ~exist('prede','var')
    prede = read_prede(getfullname('*.SUN','prede'));
end
if ~isstruct(prede)&&exist(prede,'file')
    prede = read_prede(prede);
end

cals = get_prede_cals(prede.time(1));
prede.mean_Ios = cals.mean_Ios';
prede.Tr = [prede.filter_1;prede.filter_2;prede.filter_3;prede.filter_4;...
    prede.filter_5;prede.filter_6;prede.filter_7]./(prede.mean_Ios*ones(size(prede.time)));
prede.Tr = prede.Tr.*(ones(size(prede.header.wl))*(prede.soldst.^2));
prede.tau = -log(prede.Tr)./(ones(size(prede.wl))*prede.airmass);
tau_ray = tau_std_ray_atm(prede.wl./1000).*(cals.atm_press./1013);
prede.tau_ray = tau_ray;
prede.aod = prede.tau - tau_ray*ones([1,length(prede.time)]);
%%

[aero, eps] = aod_screen(prede.time, prede.tau(3,:), 0, 1, 10,4,1.3e-3,[],[],.2);
%  aero_ = aero;
%  [aero(aero_),eps(aero_)] = aod_screen(prede.time(aero_), prede.tau(3,aero_), 0, 1, 10,3,5e-4,[],[],.2);
prede.aero = aero; prede.eps = eps;
NaNrow = NaN(7,1); %Insert a column of NaNs at the front of both plots below 
% to avoid case when either is empty which would lead to an error.
fff=figure(123); plot([prede.time(1),prede.time(aero)], [NaNrow([2,3,4,5,7]),prede.aod([2,3,4,5,7],aero)],'.',[prede.time(1),prede.time(~aero)],...
   [NaNrow([2,3,4,5,7]) prede.aod([2,3,4,5,7],~aero)],'k.'); dynamicDateTicks;
legend(sprintf('%4d nm',prede.wl(2)),sprintf('%4d nm',prede.wl(3)), ...
    sprintf('%4d nm',prede.wl(4)), sprintf('%4d nm',prede.wl(5)), sprintf('%4d nm',prede.wl(7)))
xlabel(['time UT']);
ylabel('AOD');
title({'Aerosol optical depths from Prede sun photometer';['Osan South Korea, KORUS-AQ on ',datestr(mean(prede.time),'yyyy-mm-dd')]});
% tr_7 = (prede_sun.filter_7(before)./Io_prede.Langleys.mean_Vo(7)).*(prede_sun.soldst(before).^2);
zoom('on')
ok = menu('Zoom in and arrange figure.  When done click SAVE or SKIP.','SAVE','SKIP');
if ok==1
    saveas(fff,[prede.pname,'prede_aod.',datestr(mean(prede.time),'yyyymmdd'),'.fig']);
    saveas(fff,[prede.pname,'prede_aod.',datestr(mean(prede.time),'yyyymmdd'),'.png']);    
end

return
function cals = get_prede_cals(in_time);

if ~exist('in_time','var') || in_time > datenum(2013,1,1)
    
    cals.mean_Ios = 1.0e-03 .* [ 0    0.1324    0.3200    0.3969    0.2370    0.2123    0.2018];
    cals.mean_Ios = 1e-6.*[0 132.3223  319.9116  397.2279  236.9746  218.2916  201.9398];
    cals.atm_press = get_prede_atm_press(in_time);
end
return

function atm_press = get_prede_atm_press(in_time)

if ~exist('in_time','var') || in_time > datenum(2013,1,1)
    
    % Mean surface pressure in Osan for week of May 4-11 (Weather underground)
    % 29.7" * 25.4 mm/in * 1013 /760 = 1005.5 hPa
    % 29.7.*25.4.*1013./760
    atm_press = 1005.5;
end


return