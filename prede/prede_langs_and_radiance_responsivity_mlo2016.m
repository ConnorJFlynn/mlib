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
files = getfullname('*.SUN','prede')
for f = 1:length(files)
    prede = read_prede(files{f});
    prede.LatN = prede.header.lat;% MLO is 19.5365;
    prede.LonE = prede.header.lon; % MLO is -155.5761;
    [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
        sunae(prede.LatN, prede.LonE, prede.time);
    amm = sort(prede.airmass); amm([1 end])
    good = prede.airmass>2 & prede.airmass<10;
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
    pause(1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_3(good)./Tr_ray(3,good),3.0,1,1);
    pause(1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_2(good)./Tr_ray(2,good),3.0,1,1);
    pause(1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),(prede.soldst(good).^2).*prede.filter_7(good)./Tr_ray(7,good),3.0,1,1);
    % (airmass,V,stdev_mult,steps,show)
    %%
    pause(1);
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
        menu('Press OK to continue','OK')
    end
    % disp('Done!')
    Langley.wl = prede.header.wl;
    Langley.Vo = Vo';
    Langley.tau = tau';
    Langley.Vo_ = Vo_';
    Langley.tau_ = tau_';
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
good_days =IQ(Langleys.Vo(3,:));
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
save([prede.pname, '..',filesep, 'all','.refined_Vos.mat'],'Langleys');
figure(101); plot(Langleys.wl, 100.*std(Langleys.Vo')./mean(Langleys.Vo'),'o-'); title('percent stddev(Vo)')
figure(102); plot(Langleys.wl, 100.*std(Langleys.Vo_')./mean(Langleys.Vo_'),'rx-');title('percent stddev(Vo_U_W)')
figure(103); plot(Langleys.wl, 100.*(mean(Langleys.Vo')-mean(Langleys.Vo_'))./mean([Langleys.Vo,Langleys.Vo_]'),'-k+')
title('percent([Vo - Vo_U_W])/mean([Vo, Vo_U_W])')
figure(104); plot(Langleys.wl, 100.*(std([Langleys.Vo, Langleys.Vo_]'))./mean([Langleys.Vo,Langleys.Vo_]'),'-g+')
title('percent stddev([Vo Vo_U_W])')
figure(105); plot(Langleys.wl, [Langleys.Vo,Langleys.Vo_]' - ones([12,1])*mean([Langleys.Vo,Langleys.Vo_]'),'-s')
% Observed variability in Prede Vo values for MLO 2016 Jan is < 0.2% except
% for 1020 nm 0.22% and 940  nm < 3%
%% 
% Checking data from Jan 15 by hand: corrected to 1 AU
soldst = mean(prede.soldst);
% Current solar_distance, Jan 15 = 0.9836
% So, compared to a distance of 1 AU, our intensity will be higher
% So, we need to multiply our sun measurements by R^2 to put them on the
% same scale as the Io

Io = 1e-6.*[0 132.3223  319.9116  397.2279  236.9746  218.2916  201.9398];

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
% 16-01-15,21:41:05,16-01-15,11:41:05,M,MLO
% 21:41:11,11:41:11,162.00,-47.00,4.5776E-13,7.8659E-10,1.3824E-09,1.2240E-09,6.5567E-10,5.0728E-10,5.4405E-10
% 21:41:18,11:41:18,162.00,-32.00,6.2561E-12,8.3916E-09,2.4597E-08,3.3028E-08,2.0212E-08,1.7659E-08,1.7608E-08 near
% 21:41:25,11:41:25,162.00,-47.00,3.0518E-13,6.9817E-10,1.2625E-09,1.1324E-09,6.3004E-10,4.9835E-10,5.2200E-10
% 21:41:31,11:41:31,162.00,-32.00,3.0518E-13,7.2022E-10,1.3731E-09,1.3133E-09,7.3181E-10,6.0036E-10,6.2325E-10 shade
% 21:41:37,11:41:37,162.00,-47.00,4.5776E-13,7.2105E-10,1.3065E-09,1.1567E-09,6.2309E-10,5.0484E-10,5.2383E-10
% 21:41:43,11:41:43,162.00,-32.00,6.1035E-12,8.3611E-09,2.4513E-08,3.3035E-08,2.0216E-08,1.7614E-08,1.7583E-08 near
% 21:41:49,11:41:49,162.00,-47.00,3.0518E-13,7.4982E-10,1.3477E-09,1.1920E-09,6.4713E-10,5.2689E-10,5.3711E-10
suns = read_prede;
man = read_prede;
eles = man.ele; azis = man.azi;
SA = scat_ang_degs(90-eles,azis, ones(size(eles)).*(90-suns.ele(656)) ,ones(size(eles)).*suns.azi(656))
round(abs(SA-180))
% 16-01-14,21:43:55,16-01-14,11:43:55,M,Akiruno
% 21:44:02,11:44:02,163.00,-47.45,1.4496E-12,8.6983E-10,1.5690E-09,1.3726E-09,7.6973E-10,6.2042E-10,6.1134E-10
% 21:44:09,11:44:09,163.00,-32.45,7.0953E-12,8.4541E-09,2.4597E-08,3.3134E-08,2.0405E-08,1.7816E-08,1.7752E-08 near
% 21:44:15,11:44:15,163.00,-47.45,1.3733E-12,8.2527E-10,1.5198E-09,1.3372E-09,8.0521E-10,6.6071E-10,6.6155E-10


% 21:44:22,11:44:22,163.00,-32.45,1.2207E-12,8.6487E-10,1.7089E-09,1.6816E-09,1.0115E-09,8.1284E-10,8.2657E-10 shade
% 21:44:28,11:44:28,163.00,-47.45,1.3733E-12,8.4541E-10,1.5585E-09,1.3672E-09,7.8255E-10,6.3309E-10,6.2988E-10
% 21:44:34,11:44:34,163.00,-32.45,6.7902E-12,8.4625E-09,2.4704E-08,3.3203E-08,2.0412E-08,1.7679E-08,1.7697E-08 near
% 21:44:41,11:44:41,163.00,-47.45,1.2970E-12,8.8333E-10,1.5839E-09,1.3792E-09,7.1182E-10,5.5687E-10,5.4855E-10
% 
% 21:47:22,11:47:22,164.50,-47.70,1.7548E-12,8.7120E-10,1.5618E-09,1.3617E-09,7.4829E-10,5.9898E-10,6.0181E-10
% 21:47:29,11:47:29,164.50,-32.70,6.8665E-12,8.4206E-09,2.4590E-08,3.3180E-08,2.0403E-08,1.7768E-08,1.7711E-08 near
% 21:47:35,11:47:35,164.50,-47.70,1.2970E-12,7.9132E-10,1.4555E-09,1.3054E-09,7.4410E-10,6.0005E-10,6.0265E-10
% 21:47:42,11:47:42,164.50,-32.70,1.2970E-12,8.5442E-10,1.7059E-09,1.6871E-09,9.7580E-10,7.8995E-10,7.9254E-10 shade
% 21:47:48,11:47:48,164.50,-47.70,1.1444E-12,7.9300E-10,1.4586E-09,1.3078E-09,7.4402E-10,6.0074E-10,6.0394E-10
% 21:47:55,11:47:55,164.50,-32.70,6.8665E-12,8.4175E-09,2.4582E-08,3.3134E-08,2.0374E-08,1.7699E-08,1.7765E-08 near
% 21:48:01,11:48:01,164.50,-47.70,1.5259E-12,8.6670E-10,1.5492E-09,1.3515E-09,6.9771E-10,5.5923E-10,5.5161E-10
% 
% 21:52:42,11:52:42,165.50,-47.90,1.5259E-12,8.9249E-10,1.5896E-09,1.3843E-09,7.8293E-10,6.2431E-10,6.2630E-10
% 21:52:49,11:52:49,165.50,-32.90,6.8665E-12,8.5014E-09,2.4681E-08,3.3218E-08,2.0447E-08,1.7699E-08,1.7819E-08 near
% 21:52:55,11:52:55,165.50,-47.90,1.1444E-12,8.3962E-10,1.5192E-09,1.3426E-09,8.0658E-10,6.5193E-10,6.5559E-10
% 21:53:02,11:53:02,165.50,-32.90,1.3733E-12,8.8600E-10,1.7474E-09,1.7331E-09,1.0483E-09,8.5144E-10,8.5335E-10 shade
% 21:53:08,11:53:08,165.50,-47.90,1.2970E-12,8.6693E-10,1.5674E-09,1.3776E-09,7.9781E-10,6.4461E-10,6.4430E-10
% 21:53:15,11:53:15,165.50,-32.90,6.7902E-12,8.5052E-09,2.4712E-08,3.3226E-08,2.0324E-08,1.7693E-08,1.7663E-08 near
% 21:53:21,11:53:21,165.50,-47.90,9.9182E-13,5.8655E-10,1.1746E-09,2.0378E-10,8.9035E-11,6.0196E-11,5.7526E-11
% 
% 22:00:32,12:00:32,169.00,-48.35,8.3923E-13,8.2077E-10,1.5427E-09,1.4200E-09,9.2026E-10,7.0374E-10,7.1327E-10
% 22:00:40,12:00:40,169.00,-33.35,6.3324E-12,8.4740E-09,2.4506E-08,3.3127E-08,2.0367E-08,1.7667E-08,1.7794E-08 near
% 22:00:46,12:00:46,169.00,-48.35,6.8665E-13,8.1078E-10,1.4616E-09,1.3010E-09,7.8712E-10,6.3560E-10,6.4247E-10
% 22:00:53,12:00:53,169.00,-33.35,9.9182E-13,8.7608E-10,1.7336E-09,1.7199E-09,1.0292E-09,8.3519E-10,8.3946E-10 shade
% 22:00:59,12:00:59,169.00,-48.35,9.1553E-13,8.2008E-10,1.4790E-09,1.3103E-09,7.8171E-10,6.3049E-10,6.3767E-10
% 22:01:05,12:01:05,169.00,-33.35,6.2561E-12,8.4373E-09,2.4544E-08,3.3096E-08,2.0384E-08,1.7682E-08,1.7764E-08 near
% 22:01:12,12:01:12,169.00,-48.35,7.6294E-13,8.1978E-10,1.4765E-09,1.3070E-09,7.8041E-10,6.2881E-10,6.3652E-10
% 
% 00:30:40,14:30:40,143.30,-40.00,0.0000E+00,9.1232E-10,3.4882E-09,5.4932E-09,3.1975E-09,2.2347E-09,2.4811E-09
% 00:30:47,14:30:47,143.30,-25.00,0.0000E+00,1.0098E-09,3.6613E-09,5.6908E-09,3.2494E-09,2.2598E-09,2.5124E-09 near
% 00:30:54,14:30:54,143.30,-40.00,0.0000E+00,9.6420E-10,3.5545E-09,5.5931E-09,3.1837E-09,2.1942E-09,2.4742E-09
% 00:31:02,14:31:02,143.30,-25.00,0.0000E+00,9.9976E-10,3.6354E-09,5.6870E-09,3.2379E-09,2.2095E-09,2.5024E-09 shade
% 00:31:08,14:31:08,143.30,-40.00,0.0000E+00,9.5352E-10,3.5278E-09,5.5641E-09,3.1830E-09,2.1881E-09,2.4704E-09
% 00:31:15,14:31:15,143.30,-25.00,7.6294E-14,1.0064E-09,3.6606E-09,5.6969E-09,3.2524E-09,2.2552E-09,2.5032E-09 near
% 00:31:21,14:31:21,143.30,-40.00,0.0000E+00,9.6359E-10,3.5576E-09,5.6046E-09,3.1822E-09,2.2354E-09,2.0383E-04
% 
% 
% 00:40:49,14:40:49,219.00,-38.50,0.0000E+00,1.8036E-10,3.2257E-10,2.1362E-10,7.3471E-11,4.2267E-11,4.3640E-11
% 00:40:56,14:40:56,219.00,-23.00,5.3406E-13,1.1915E-09,4.4022E-09,6.9237E-09,3.8628E-09,2.7100E-09,2.9419E-09 near
% 00:41:02,14:41:02,219.00,-38.50,0.0000E+00,1.7921E-10,3.1960E-10,2.1042E-10,7.2098E-11,4.6692E-11,5.0049E-11
% 00:41:09,14:41:09,219.00,-23.00,2.2888E-13,1.1908E-09,4.4167E-09,6.9267E-09,3.8597E-09,2.7107E-09,2.9488E-09 shade
% 00:41:15,14:41:15,219.00,-38.50,7.6294E-14,1.8105E-10,3.2234E-10,2.1050E-10,6.5231E-11,3.6316E-11,3.7079E-11
% 00:41:21,14:41:21,219.00,-23.00,2.2888E-13,1.1939E-09,4.4098E-09,6.9222E-09,3.8551E-09,2.7031E-09,2.9388E-09 near
% 00:41:28,14:41:28,219.00,-38.50,0.0000E+00,1.8127E-10,3.2204E-10,2.0973E-10,6.4621E-11,3.6240E-11,3.7003E-11
% 
% 01:07:20,15:07:20,225.00,-34.00,5.3406E-13,7.3776E-10,1.4488E-09,1.3618E-09,8.1985E-10,4.3869E-10,4.9561E-10
% 01:07:26,15:07:26,225.00,-19.00,4.5776E-12,7.2083E-09,2.2682E-08,3.1830E-08,2.0109E-08,1.4605E-08,1.7467E-08 near
% 01:07:33,15:07:33,225.00,-34.00,6.8665E-13,7.1426E-10,1.4129E-09,1.2736E-09,7.3059E-10,4.9652E-10,5.8563E-10
% 01:07:39,15:07:39,225.00,-19.00,2.2888E-13,7.8453E-10,1.6769E-09,1.6680E-09,9.7229E-10,6.7719E-10,7.8812E-10 shade
% 01:07:45,15:07:45,225.00,-34.00,4.5776E-13,7.4013E-10,1.4436E-09,1.2921E-09,6.9473E-10,4.7348E-10,5.4993E-10
% 01:07:52,15:07:52,225.00,-19.00,4.1962E-12,7.3433E-09,2.3026E-08,3.2051E-08,2.0097E-08,1.5237E-08,1.7480E-08 near
% 01:07:58,15:07:58,225.00,-34.00,5.3406E-13,7.3318E-10,1.4382E-09,1.2856E-09,7.1693E-10,4.9782E-10,5.6854E-10
% 
% 01:09:22,15:09:22,225.00,-34.00,5.3406E-13,7.4844E-10,1.4417E-09,1.2667E-09,6.1676E-10,4.4281E-10,5.2589E-10
% 01:09:28,15:09:28,225.00,-19.00,4.3488E-12,7.3875E-09,2.3170E-08,3.2242E-08,2.0129E-08,1.5852E-08,1.7564E-08 near
% 01:09:34,15:09:34,225.00,-34.00,4.5776E-13,7.1480E-10,1.3935E-09,1.2508E-09,6.8291E-10,4.9080E-10,5.4199E-10
% 01:09:41,15:09:41,225.00,-19.00,4.1199E-12,7.4043E-09,2.3186E-08,3.2341E-08,2.0189E-08,1.5877E-08,1.7543E-08 shade
% 01:09:47,15:09:47,225.00,-34.00,1.5259E-13,7.2144E-10,1.4094E-09,1.2629E-09,6.9962E-10,4.9896E-10,5.5786E-10
% 01:09:53,15:09:53,225.00,-19.00,4.1962E-12,7.3624E-09,2.3048E-08,3.2372E-08,2.0126E-08,1.5578E-08,1.7581E-08 near
% 01:10:00,15:10:00,225.00,-34.00,3.0518E-13,7.1861E-10,1.4011E-09,1.2572E-09,6.9511E-10,4.9263E-10,5.4008E-10


% 16-01-15,21:41:05,16-01-15,11:41:05,M,MLO
% 21:41:11,11:41:11,162.00,-47.00,4.5776E-13,7.8659E-10,1.3824E-09,1.2240E-09,6.5567E-10,5.0728E-10,5.4405E-10
% 21:41:18,11:41:18,162.00,-32.00,6.2561E-12,8.3916E-09,2.4597E-08,3.3028E-08,2.0212E-08,1.7659E-08,1.7608E-08 near
% 21:41:25,11:41:25,162.00,-47.00,3.0518E-13,6.9817E-10,1.2625E-09,1.1324E-09,6.3004E-10,4.9835E-10,5.2200E-10
% 21:41:31,11:41:31,162.00,-32.00,3.0518E-13,7.2022E-10,1.3731E-09,1.3133E-09,7.3181E-10,6.0036E-10,6.2325E-10 shade
% 21:41:37,11:41:37,162.00,-47.00,4.5776E-13,7.2105E-10,1.3065E-09,1.1567E-09,6.2309E-10,5.0484E-10,5.2383E-10
% 21:41:43,11:41:43,162.00,-32.00,6.1035E-12,8.3611E-09,2.4513E-08,3.3035E-08,2.0216E-08,1.7614E-08,1.7583E-08 near
% 21:41:49,11:41:49,162.00,-47.00,3.0518E-13,7.4982E-10,1.3477E-09,1.1920E-09,6.4713E-10,5.2689E-10,5.3711E-10
% 
% 21:46:33,11:46:33,164.00,-48.00,9.9182E-13,7.9979E-10,1.4138E-09,1.2133E-09,6.5147E-10,5.0186E-10,5.0400E-10
% 21:46:40,11:46:40,164.00,-33.00,6.1798E-12,8.3801E-09,2.4582E-08,3.3096E-08,2.0262E-08,1.7726E-08,1.7644E-08 near
% 21:46:46,11:46:46,164.00,-48.00,3.8147E-13,7.1106E-10,1.2944E-09,1.1678E-09,6.4995E-10,5.3177E-10,5.4733E-10
% 21:46:52,11:46:52,164.00,-33.00,3.0518E-13,7.9124E-10,1.5533E-09,1.5292E-09,8.5304E-10,6.9908E-10,7.1365E-10 shade
% 21:46:58,11:46:58,164.00,-48.00,6.1035E-13,7.5668E-10,1.3591E-09,1.1881E-09,6.2943E-10,4.9889E-10,4.9866E-10
% 21:47:04,11:47:04,164.00,-33.00,6.4087E-12,8.4785E-09,2.4742E-08,3.3119E-08,2.0274E-08,1.7707E-08,1.7629E-08 near
% 21:47:11,11:47:11,164.00,-48.00,7.6294E-13,8.0208E-10,1.4326E-09,1.2320E-09,6.1989E-10,4.9660E-10,4.9995E-10


% 16-01-16,20:53:23,16-01-16,10:53:23,M,MLO
% 20:53:29,10:53:29,147.00,-43.00,9.1553E-13,8.4198E-10,1.5371E-09,1.3580E-09,7.4799E-10,6.4255E-10,6.1470E-10
% 20:53:36,10:53:36,147.00,-28.00,6.2561E-12,8.2695E-09,2.4536E-08,3.3112E-08,2.0365E-08,1.8670E-08,1.7733E-08 near
% 20:53:43,10:53:43,147.00,-43.00,6.8665E-13,8.3389E-10,1.5312E-09,1.3350E-09,7.4333E-10,6.5117E-10,6.2889E-10
% 20:53:49,10:53:49,147.00,-28.00,1.0681E-12,8.7273E-10,1.7467E-09,1.7296E-09,9.9037E-10,8.5754E-10,8.3092E-10 shade 
% 20:53:55,10:53:55,147.00,-43.00,8.3923E-13,8.3221E-10,1.5241E-09,1.3540E-09,7.4005E-10,6.3065E-10,6.0104E-10
% 20:54:01,10:54:01,147.00,-28.00,6.2561E-12,8.2603E-09,2.4513E-08,3.3089E-08,2.0349E-08,1.8598E-08,1.7715E-08 near
% 20:54:07,10:54:07,147.00,-43.00,7.6294E-13,8.5686E-10,1.5410E-09,1.3514E-09,7.4852E-10,6.3591E-10,6.0432E-10
% 20:57:52,10:57:52,149.00,-43.00,9.1553E-13,8.6525E-10,1.5578E-09,1.3610E-09,7.2884E-10,6.2172E-10,5.8937E-10
% 20:57:59,10:57:59,149.00,-28.00,5.9509E-12,8.2886E-09,2.4483E-08,3.2982E-08,2.0313E-08,1.8669E-08,1.7734E-08 near
% 20:58:05,10:58:05,149.00,-43.00,6.8665E-13,8.6769E-10,1.5504E-09,1.3487E-09,7.4471E-10,6.4430E-10,6.1081E-10
% 20:58:12,10:58:12,149.00,-28.00,8.3923E-13,8.5693E-10,1.6998E-09,1.6731E-09,9.5528E-10,8.0925E-10,7.9369E-10 shade
% 20:58:18,10:58:18,149.00,-43.00,8.3923E-13,8.7128E-10,1.5694E-09,1.3679E-09,7.4059E-10,6.1615E-10,5.7724E-10
% 20:58:24,10:58:24,149.00,-28.00,6.1798E-12,8.3130E-09,2.4529E-08,3.3058E-08,2.0369E-08,1.8552E-08,1.7668E-08 near
% 20:58:30,10:58:30,149.00,-43.00,5.3406E-13,8.6647E-10,1.5255E-09,1.3689E-09,9.0340E-10,8.2527E-10,8.5945E-10


% 16-01-17,21:37:39,16-01-17,11:37:39,M,MLO
% 21:37:53,11:37:53,159.00,-32.50,6.3324E-12,8.4892E-09,2.4796E-08,3.3226E-08,2.0309E-08,1.6400E-08,1.7686E-08 near
% 21:38:06,11:38:06,159.00,-32.50,6.8665E-13,8.6761E-10,1.7275E-09,1.7181E-09,9.7740E-10,7.3318E-10,8.1024E-10 shade
% 21:38:19,11:38:19,159.00,-32.50,6.4087E-12,8.5129E-09,2.4765E-08,3.3119E-08,2.0356E-08,1.6412E-08,1.7736E-08 near

% 16-01-18,20:41:37,16-01-18,10:41:37,M,MLO
% 20:41:51,10:41:51,144.00,-25.50,5.2643E-12,8.1245E-09,2.4254E-08,3.2921E-08,2.0209E-08,1.6219E-08,1.7593E-08 near-shade
% 20:42:04,10:42:04,144.00,-25.50,6.1035E-13,8.6243E-10,1.7679E-09,1.7726E-09,1.0104E-09,7.5195E-10,8.2611E-10 shaded
% 20:42:16,10:42:16,144.00,-25.50,5.2643E-12,8.1192E-09,2.4208E-08,3.2837E-08,2.0249E-08,1.6188E-08,1.7627E-08 near-shade



% So, next would be to use these Io values and the reported voltages just
% before the panel measurements (or as part of the panel measurements) to
% compute the transmittances, and thus the direct normal irradiance, and
% thus the radiance from the panel, and thus the responsivity, and then see
% how stable this responsivity is.
return