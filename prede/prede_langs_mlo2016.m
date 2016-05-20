function prede_langs_mlo2016
% read in prede sun...
% in_dir = 'D:\case_studies\Prede_MLO_2016_01_08\Skyradiometer\Data\';
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
    save([prede.pname, '..',filesep, fname,'.refined_Vo.mat'],'-struct','Langley');
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

return