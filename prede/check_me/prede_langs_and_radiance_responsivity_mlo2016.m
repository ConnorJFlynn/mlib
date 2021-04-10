function Langleys = prede_langs_and_radiance_responsivity_mlo2016
% read in prede sun...
% in_dir = 'C:\case_studies\4STAR\data\2012_MLO_May_June\prede\';
% if ~exist([in_dir,'Vo'],'dir')
%     mkdir([in_dir,'Vo']);
% end
% met = MLO_met_data(['C:\case_studies\4STAR\data\2012_MLO_May_June\MET',filesep]);
%
% Important files: *.SUN for direct beam
%                  *.dat for sky scans
%                  *.MAN for manual shading files with spectralon panel
% Seems like the ".RDM" files aren't useful in this context.

% files = dir([in_dir,'*.SUN']);
files = getfullname('*.SUN','prede'); if ~iscell(files) files = {files}; end
for f = 1:length(files)
    prede = read_prede(files{f});
    prede.LatN = prede.header.lat;% MLO is 19.5365;
    prede.LonE = prede.header.lon; % MLO is -155.5761;
    [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
        sunae(prede.LatN, prede.LonE, prede.time);
    amm = sort(prede.airmass); amm([1 end])
    good = prede.airmass>2.5 & prede.airmass<10;
    %%
    
%     prede.pres_mb = interp1(met.time, met.atm_pres1,prede.time,'linear','extrap');
    %%
    %tau_ray=rayleighez(prede.wl./1000,prede.pres_mb,mean(prede.time),prede.LatN);
    tau_ray = tau_std_ray_atm(prede.wl./1000)*680./1013;
    Tr_ray = exp(-tau_ray*prede.airmass);
    prede.tau_ray = tau_ray;
    
    
    %%
    % tic
    %These test points determined by looking at lowest error in Vo vs Lambda
    % test_ii = [338, 392,278,741,812,833,1020 ];
    % 315, 400, 500, 675, 870, 940, 1020
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_5(good)./Tr_ray(5,good),2.3,1,1);
    pause(.1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_3(good)./Tr_ray(3,good),3.0,1,1);
    pause(.1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_2(good)./Tr_ray(2,good),3.0,1,1);
    pause(.1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_7(good)./Tr_ray(7,good),2.75,1,1);
    % (airmass,V,stdev_mult,steps,show)
    [min(prede.airmass(good)), max(prede.airmass(good))]
    %%
    pause(.1);
    clear Vo tau Vo_ tau_
    for f = [7:-1:2]
        %    disp(['wavelength = ',num2str(Lambda(L))])
        [Vo(f), tau(f), P,S,Mu,dVo(f)] = lang(prede.airmass(good),(prede.(['filter_',num2str(f)])(good).*prede.soldst(good).^2)./(Tr_ray(f,good)));
        [Vo_(f),tau_(f), P_] = lang_uw(prede.airmass(good),(prede.(['filter_',num2str(f)])(good).*prede.soldst(good).^2)./(Tr_ray(f,good)));
        disp(['Done with ',num2str(prede.header.wl(f))])
        figure(1003);
        subplot(2,1,1);
        semilogy(prede.airmass(good), (prede.(['filter_',num2str(f)])(good).*prede.soldst(good).^2)./(Tr_ray(f,good)),'g.',...
            prede.airmass(good),exp(polyval(P,prede.airmass(good),S,Mu)),'r');
        title(['Langley at ',num2str(prede.header.wl(f)), ' Vo=',sprintf('%0.3g',Vo(f)), ' dVo=',sprintf('%0.3g',dVo(f)),' tau=',sprintf('%0.2g',tau(f)), ' sum(good)=',sprintf('%g',sum(good))]);
        % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
        subplot(2,1,2);
        semilogy(1./prede.airmass(good), exp(real(log((prede.(['filter_',num2str(f)])(good)./Tr_ray(f,good)).*prede.soldst(good).^2))...
            ./(prede.airmass(good))),'g.');
        title(['Langley at ',num2str(prede.header.wl(f)),' Vo=',num2str(Vo_(f)),' tau=',num2str(tau_(f)), ' sum(good)=',num2str(sum(good))]);
        %    title(['goods=',num2str(goods),' mad=',num2str(mad),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
        hold('on');
        plot( 1./prede.airmass(good), exp(polyval(P_, 1./prede.airmass(good))),'r');
        hold('off');
%         menu('Press OK to continue','OK')
    end
    % disp('Done!')
    Langley.wl = prede.header.wl;
    Langley.Vo = Vo';
    Langley.tau = tau';
    Langley.Vo_ = Vo_';
    Langley.tau_ = tau_';
    
        Tr = [prede.filter_1.*prede.soldst.^2./Tr_ray(1,:)./Langley.Vo(1); ...
            prede.filter_2.*prede.soldst.^2./Tr_ray(2,:)./Langley.Vo(2);prede.filter_3.*prede.soldst.^2./Tr_ray(3,:)./Langley.Vo(3);...
        prede.filter_4.*prede.soldst.^2./Tr_ray(4,:)./Langley.Vo(4);prede.filter_5.*prede.soldst.^2./Tr_ray(5,:)./Langley.Vo(5);...
        prede.filter_6.*prede.soldst.^2./Tr_ray(6,:)./Langley.Vo(6);prede.filter_7.*prede.soldst.^2./Tr_ray(7,:)./Langley.Vo(7)];
    
    figure; these = plot(prede.airmass, (Tr([2:5,7],:)),'.'); recolor(these,prede.wl([1:4,6])); logy;
    set(gca,'ytick',[0.8:.02:1])

    leg_str = {sprintf('%3d nm',prede.wl(2))}; leg_str(end+1) = {sprintf('%3d nm',prede.wl(3))};
    leg_str(end+1) = {sprintf('%3d nm',prede.wl(4))};leg_str(end+1) = {sprintf('%3d nm',prede.wl(5))};
    leg_str(end+1) = {sprintf('%3d nm',prede.wl(7))};
    legend(leg_str);
    
    
    amm = sort(prede.airmass(good));
    good_times = prede.time(good);
    Langley.time = mean(good_times([1 end]));
    Langley.end_times = good_times([1 end])';
    Langley.airmass = amm([1 end])';
    filts = [2:5 7];
    figure(1); plot(prede.header.wl(filts), 100*[abs(Langley.Vo(filts) - Langley.Vo_(filts))./Langley.Vo(filts)], '-')
    figure(2); plot(prede.header.wl(filts), [Langley.Vo(filts),Langley.Vo_(filts)], '-');
    [pth,fname,ext] = fileparts(prede.header.fname);
    save([prede.pname, '..',filesep, fname,'.refined_Vo.mat'],'Langley');
    if ~exist('Langleys','var')
        Langleys = Langley;
    else
        [Langleys.time, inds] = unique([Langley.time, Langleys.time]);
        tmp = [Langley.Vo, Langleys.Vo]; Langleys.Vo = tmp(:,inds);
        tmp = [Langley.Vo_, Langleys.Vo_]; Langleys.Vo_ = tmp(:,inds);
        tmp = [Langley.tau, Langleys.tau]; Langleys.tau = tmp(:,inds);
        tmp = [Langley.tau_, Langleys.tau_]; Langleys.tau_ = tmp(:,inds);
        tmp = [Langley.end_times, Langleys.end_times]; Langleys.end_times = tmp(:,inds);
        tmp = [Langley.airmass, Langleys.airmass]; Langleys.airmass = tmp(:,inds);
    end
end
%%
good_days =IQ(Langleys.Vo(5,:));
%%
figure; plot(serial2doy(Langleys.time(good_days)), Langleys.Vo(:,good_days),'o-');
legend('315 nm','400 nm','500 nm','675 nm','870 nm', '940 nm','1020 nm');
%%
mean_Vo = mean(Langleys.Vo(:,good_days),2); std_Vo =std(Langleys.Vo(:,good_days),[],2);
rel_var_Vo = std_Vo./mean_Vo;
mean_Vo_ = mean(Langleys.Vo_(:,good_days),2); std_Vo_ =std(Langleys.Vo_(:,good_days),[],2);
rel_var_Vo_ = std_Vo_./mean_Vo_;
figure; plot(Langleys.wl, 100.*[rel_var_Vo,rel_var_Vo_], '-o')

Langleys.good_days = good_days;
Langleys.mean_Vo = mean_Vo;
Langleys.std_Vo = std_Vo;
Langleys.rel_var_Vo = rel_var_Vo;
save([prede.pname, '..',filesep, 'all','.refined_Vos.mat'],'-struct','Langleys');
figure(101); plot(Langleys.wl([2:5 7]), 100.*std(Langleys.Vo([2:5 7],good_days)')./mean(Langleys.Vo([2:5 7],good_days)'),'o-'); title('percent stddev(Vo)')
figure(102); plot(Langleys.wl([2:5 7]), 100.*std(Langleys.Vo_([2:5 7],good_days)')./mean(Langleys.Vo_([2:5 7],good_days)'),'rx-');title('percent stddev(Vo_U_W)')
figure(103); plot(Langleys.wl([2:5 7]), 100.*(mean(Langleys.Vo([2:5 7],good_days)')-mean(Langleys.Vo_([2:5 7],good_days)'))./mean([Langleys.Vo([2:5 7],good_days),Langleys.Vo_([2:5 7],good_days)]'),'-k+')
title('percent([Vo - Vo_U_W])/mean([Vo, Vo_U_W])')
figure(104); plot(Langleys.wl([2:5 7]), 100.*(std([Langleys.Vo([2:5 7],good_days), Langleys.Vo_([2:5 7],good_days)]'))./mean([Langleys.Vo([2:5 7],good_days),Langleys.Vo_([2:5 7],good_days)]'),'-g+')
title('percent stddev([Vo Vo_U_W])')
figure(105); plot(Langleys.wl([2:5 7]), 100.*[Langleys.Vo([2:5 7],good_days), ...
    Langleys.Vo_([2:5 7],good_days)]' ./ (ones([2*sum(good_days),1])* ...
    mean([Langleys.Vo([2:5 7],good_days),Langleys.Vo_([2:5 7],good_days)]'))-100,'-s');
xlabel('wavelength [nm]');ylabel('% deviation in Vo'); title('Prede Vo calibration, MLO Nov 2016')
figure(106); plot(Langleys.wl([2:5 7]),Langleys.Vo([2:5 7],good_days)' ./ ...
    (ones([sum(good_days),1])*mean(Langleys.Vo([2:5 7],good_days)')),'-s')

% Observed variability in Prede Vo values for MLO 2016 Jan is < 0.3% except
% for below 500 nm and 940 nm < 3%
%% 
% Checking data from Jan 15 by hand: corrected to 1 AU
soldst = mean(prede.soldst);
% Current solar_distance, Jan 15 = 0.9836
% So, compared to a distance of 1 AU, our intensity will be higher
% So, we need to multiply our sun measurements by R^2 to put them on the
% same scale as the Io

Io = 1e-6.*[0 132.3223  319.9116  397.2279  236.9746  218.2916  201.9398];
% MLO Nov 2016 Io below from mean_Vo
Io = 1e-6.*[0  129.8826  321.3173  395.3019  239.6672  224.5578  202.2356];

% The idea is to 



sun_panel_1 = 1e-7 *[0.0001    0.0767    0.2322    0.3171    0.1948    0.1706    0.1698]

% direct_sun:
% 21:38:45,11:38:45,-018.47,047.70,7.2899E-08,9.7031E-05,2.8458E-04,3.8818E-04,2.4040E-04,2.0627E-04,2.0589E-04
% 21:42:44,11:42:44,-017.27,048.06,7.3143E-08,9.6764E-05,2.8511E-04,3.8834E-04,2.4010E-04,2.0556E-04,2.0623E-04

sun1 = [7.2899E-08,9.7031E-05,2.8458E-04,3.8818E-04,2.4040E-04,2.0627E-04,2.0589E-04];
sun2 = [7.3143E-08,9.6764E-05,2.8511E-04,3.8834E-04,2.4010E-04,2.0556E-04,2.0623E-04];

Tr1 = soldst.^2 .* sun1./Io;
Tr2 = soldst.^2 .* sun2./Io;
wl = [315         400         500         675         870         940        1020]

near_1 = [6.2561E-12,8.3916E-09,2.4597E-08,3.3028E-08,2.0212E-08,1.7659E-08,1.7608E-08];
shaded = [3.0518E-13,7.2022E-10,1.3731E-09,1.3133E-09,7.3181E-10,6.0036E-10,6.2325E-10] ;
near_2 = [6.1035E-12,8.3611E-09,2.4513E-08,3.3035E-08,2.0216E-08,1.7614E-08,1.7583E-08];

sun_panel_1 = near_1 - shaded;
sun_panel_2 = near_2 - shaded;
Do_1 = soldst.^2 .* sun_panel_1 * (2*pi / .99) ./ Tr1;
 %Wrong!!  DifTr1 = soldst.^2 .* sun_panel_1 ./ Do_1;
 sky_alm_15 = [2.8992E-12,1.7078E-09,2.1843E-09,1.1008E-09,3.1563E-10,2.1820E-10,1.8204E-10]; 
DifTr1 = soldst.^2 .* sky_alm_15 ./ Do_1;

suns = read_prede;
man = read_prede;
eles = man.ele; azis = man.azi;
SA = scat_ang_degs(90-eles,azis, ones(size(eles)).*(90-suns.ele(656)) ,ones(size(eles)).*suns.azi(656))
round(abs(SA-180))

return