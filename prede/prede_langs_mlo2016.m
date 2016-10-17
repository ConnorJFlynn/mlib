function prede_langs_mlo2016(atm_pres,airmass_limit,prompt);
if ~exist('atm_pres','var')
    atm_pres = 680; % default pressure at MLO
end

if ~exist('airmass_limit','var')||isempty(airmass_limit)
    airmass_limit = [2,15];    
end

if ~exist('prompt','var')||isempty(prompt)
    prompt = true;
end

min_N = 100;
airmass_span = 3;
% read in prede sun...
% in_dir = 'D:\case_studies\Prede_MLO_2016_01_08\Skyradiometer\Data\';
% files = dir([in_dir,'*.SUN']);
files = getfullname('*.SUN','prede')
if ischar(files)
    files = {files};
end
for f = 1:length(files)
%     try        
        infile =files{f};
        [pname, fname] = fileparts(infile);
        prede = read_prede(files{f});
        prede.LatN = prede.header.lat;% MLO is 19.5365;
        prede.LonE = prede.header.lon; % MLO is -155.5761;
        [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
            sunae(prede.LatN, prede.LonE, prede.time);
        AM_all = prede.azi_sun>0 & prede.azi_sun<180;
        AM = prede.azi_sun>0 & prede.azi_sun<180 & prede.airmass>min(airmass_limit) & prede.airmass<max(airmass_limit);
        PM_all = prede.azi_sun>180 & prede.azi_sun<360;
        PM = prede.azi_sun>180 & prede.azi_sun<360& prede.airmass>min(airmass_limit) & prede.airmass<max(airmass_limit);        
        if sum(AM)>min_N && (max(prede.airmass(AM))-min(prede.airmass(AM))>airmass_span)
            
            amm = sort(prede.airmass); amm([1 end]);
            
            if prompt
                figure(10); plot(prede.airmass(AM_all), log10(prede.filter_3(AM_all)), 'k.',prede.airmass(AM), log10(prede.filter_3(AM)), 'x');xl_ = xlim;
                OK = menu('Click OK when done zooming or skip','OK', 'Skip');  xl = xlim;
            else
                OK = 1;
            end
            if all(xl_==xl)
                xl = airmass_limit;
            end
            
            if OK==1 % then try to get a good Langley
                good_AM = prede.azi_sun>0 & prede.azi_sun<180 &prede.airmass>xl(1) & prede.airmass<xl(2);
                %%
                
                %     prede.pres_mb = interp1(met.time, met.atm_pres1,prede.time,'linear','extrap');
                %%
                %tau_ray=rayleighez(prede.wl./1000,prede.pres_mb,mean(prede.time),prede.LatN);
                tau_ray = tau_std_ray_atm(prede.wl./1000)*atm_pres./1013;
                Tr_ray = exp(-tau_ray*prede.airmass);
                prede.tau_ray = tau_ray;
                
                
                %%
                % tic
                %These test points determined by looking at lowest error in Vo vs Lambda
                % test_ii = [338, 392,278,741,812,833,1020 ];
                % 315, 400, 500, 675, 870, 940, 1020
                [Vo,tau,Vo_, tau_, good_AM(good_AM)] = dbl_lang(prede.airmass(good_AM),(prede.soldst(good_AM).^2).*prede.filter_5(good_AM)./Tr_ray(5,good_AM),2.7,1,1);
                pause(.1);
                [Vo,tau,Vo_, tau_, good_AM(good_AM)] = dbl_lang(prede.airmass(good_AM),(prede.soldst(good_AM).^2).*prede.filter_3(good_AM)./Tr_ray(3,good_AM),2.6,1,1);
                %%
                pause(.1);
                clear Vo tau Vo_ tau_
                for f = [7:-1:2]
                    %    disp(['wavelength = ',num2str(Lambda(L))])
                    [Vo_AM(f), tau(f), P,S,Mu,dVo(f)] = lang(prede.airmass(good_AM),(prede.(['filter_',num2str(f)])(good_AM).*prede.soldst(good_AM).^2)./(Tr_ray(f,good_AM)));
                    [Vo__AM(f),tau_(f), P_] = lang_uw(prede.airmass(good_AM),(prede.(['filter_',num2str(f)])(good_AM).*prede.soldst(good_AM).^2)./(Tr_ray(f,good_AM)));
                    %             disp(['Done with ',num2str(prede.wl(f))])
                    prede.Vo_AM(f) = Vo_AM(f);
                    prede.Vo__AM(f) = Vo__AM(f);
                    figure(1003);
                    subplot(2,1,1);
                    semilogy(prede.airmass(good_AM), (prede.(['filter_',num2str(f)])(good_AM).*prede.soldst(good_AM).^2)./(Tr_ray(f,good_AM)),'g.',...
                        prede.airmass(good_AM),exp(polyval(P,prede.airmass(good_AM),S,Mu)),'r');
                    title(['Langley at ',num2str(prede.wl(f)), ' Vo=',sprintf('%0.3g',Vo_AM(f)), ' dVo=',sprintf('%0.3g',dVo(f)),' tau=',sprintf('%0.2g',tau(f)), ' sum(good)=',sprintf('%g',sum(good_AM))]);
                    % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
                    subplot(2,1,2);
                    semilogy(1./prede.airmass(good_AM), exp(real(log((prede.(['filter_',num2str(f)])(good_AM)./Tr_ray(f,good_AM)).*prede.soldst(good_AM).^2))...
                        ./(prede.airmass(good_AM))),'g.');
                    title(['Langley at ',num2str(prede.wl(f)),' Vo=',num2str(Vo__AM(f)),' tau=',num2str(tau_(f)), ' sum(good)=',num2str(sum(good_AM))]);
                    %    title(['goods=',num2str(goods),' mad=',num2str(mad),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
                    hold('on');
                    plot( 1./prede.airmass(good_AM), exp(polyval(P_, 1./prede.airmass(good_AM))),'r');
                    hold('off');
                    
                    %         menu('Press OK to continue','OK')
                end
                % disp('Done!')
                Langley.wl = prede.wl;
                Langley.Vo_AM = Vo_AM';
                Langley.tau_AM = tau';
                Langley.Vo__AM = Vo__AM';
                Langley.tau__AM = tau_';
                amm = sort(prede.airmass(good_AM));
                good_times = prede.time(good_AM);
                prede.good_AM = good_AM;
                %     Langley.time = good_times([1 end]);
                Langley.time_AM = mean(good_times([1 end]));
                Langley.end_times_AM = good_times([1 end])';
                Langley.airmass_AM = amm([1 end])';
                filts = [2:5 7];
                figure(1); plot(prede.wl(filts), 100*[abs(Langley.Vo_AM(filts) - Langley.Vo__AM(filts))./Langley.Vo_AM(filts)], '-')
                figure(2); plot(prede.wl(filts), [Langley.Vo_AM(filts),Langley.Vo__AM(filts)], '-');
                tl = title(['Prede Vo values: ',fname]);
                set(tl,'interp','none');
                [pth,fname,ext] = fileparts(prede.fname);
%                 save([prede.pname, 'prede_',datestr(Langley.time,'yyyymmdd_HH'),'.refined_Vo_AM.mat'],'-struct','Langley');
%                 save([prede.pname, 'prede_',datestr(Langley.time,'yyyymmdd_HH'),'.SUN.mat'],'-struct','prede');
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
            end % End of if ~OK
        end
        if sum(PM)>min_N && (max(prede.airmass(PM))-min(prede.airmass(PM))>airmass_span)            
            amm = sort(prede.airmass); amm([1 end]);
            if prompt
                figure(10); plot(prede.airmass(PM_all), log10(prede.filter_3(PM_all)), 'k.',prede.airmass(PM), log10(prede.filter_3(PM)), 'x'); xl_ = xlim;
                OK = menu('Click OK when done zooming or skip','OK', 'Skip');  xl = xlim;
            else
                OK = 1;
            end
            if all(xl_==xl)
                xl = airmass_limit;
            end
            
            if OK==1 % then try to get a good Langley
                % Might need to use absolute value, or maybe arccos(cos) to
                % get proper values
                good_PM = prede.azi_sun>180 & prede.azi_sun<360 &prede.airmass>xl(1) & prede.airmass<xl(2);
                %%
                %tau_ray=rayleighez(prede.wl./1000,prede.pres_mb,mean(prede.time),prede.LatN);
                tau_ray = tau_std_ray_atm(prede.wl./1000)*atm_pres./1013;
                Tr_ray = exp(-tau_ray*prede.airmass);
                prede.tau_ray = tau_ray;
                
                
                %%
                % tic
                %These test points determined by looking at lowest error in Vo vs Lambda
                % test_ii = [338, 392,278,741,812,833,1020 ];
                % 315, 400, 500, 675, 870, 940, 1020
                [Vo,tau,Vo_, tau_, good_AM(good_PM)] = dbl_lang(prede.airmass(good_PM),(prede.soldst(good_PM).^2).*prede.filter_5(good_PM)./Tr_ray(5,good_PM),2.75,1,1);
                pause(.1);
                [Vo,tau,Vo_, tau_, good_PM(good_PM)] = dbl_lang(prede.airmass(good_PM),(prede.soldst(good_PM).^2).*prede.filter_3(good_PM)./Tr_ray(3,good_PM),2.7,1,1);
                %%
                pause(.1);
                clear Vo tau Vo_ tau_
                for f = [7:-1:2]
                    %    disp(['wavelength = ',num2str(Lambda(L))])
                    [Vo_PM(f), tau(f), P,S,Mu,dVo(f)] = lang(prede.airmass(good_PM),(prede.(['filter_',num2str(f)])(good_PM).*prede.soldst(good_PM).^2)./(Tr_ray(f,good_PM)));
                    [Vo__PM(f),tau_(f), P_] = lang_uw(prede.airmass(good_PM),(prede.(['filter_',num2str(f)])(good_PM).*prede.soldst(good_PM).^2)./(Tr_ray(f,good_PM)));
                    %             disp(['Done with ',num2str(prede.wl(f))])
                    prede.Vo_PM(f) = Vo_PM(f);
                    prede.Vo__PM(f) = Vo__PM(f);
                    figure(1003);
                    subplot(2,1,1);
                    semilogy(prede.airmass(good_PM), (prede.(['filter_',num2str(f)])(good_PM).*prede.soldst(good_PM).^2)./(Tr_ray(f,good_PM)),'g.',...
                        prede.airmass(good_PM),exp(polyval(P,prede.airmass(good_PM),S,Mu)),'r');
                    title(['Langley at ',num2str(prede.wl(f)), ' Vo=',sprintf('%0.3g',Vo_PM(f)), ' dVo=',sprintf('%0.3g',dVo(f)),' tau=',sprintf('%0.2g',tau(f)), ' sum(good)=',sprintf('%g',sum(good_PM))]);
                    % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
                    subplot(2,1,2);
                    semilogy(1./prede.airmass(good_PM), exp(real(log((prede.(['filter_',num2str(f)])(good_PM)./Tr_ray(f,good_PM)).*prede.soldst(good_PM).^2))...
                        ./(prede.airmass(good_PM))),'g.');
                    title(['Langley at ',num2str(prede.wl(f)),' Vo=',num2str(Vo__PM(f)),' tau=',num2str(tau_(f)), ' sum(good)=',num2str(sum(good_PM))]);
                    %    title(['goods=',num2str(goods),' mad=',num2str(mad),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
                    hold('on');
                    plot( 1./prede.airmass(good_PM), exp(polyval(P_, 1./prede.airmass(good_PM))),'r');
                    hold('off');
                    
                    %         menu('Press OK to continue','OK')
                end
                % disp('Done!')
                Langley.wl = prede.wl;
                Langley.Vo_PM = Vo_PM';
                Langley.tau_PM = tau';
                Langley.Vo__PM = Vo__PM';
                Langley.tau__PM = tau_';
                amm = sort(prede.airmass(good_PM));
                good_times = prede.time(good_PM);
                prede.good_PM = good_PM;
                %     Langley.time = good_times([1 end]);
                Langley.time_PM = mean(good_times([1 end]));
                Langley.end_times_PM = good_times([1 end])';
                Langley.airmass_PM = amm([1 end])';
                filts = [2:5 7];
                figure(1); plot(prede.wl(filts), 100*[abs(Langley.Vo_PM(filts) - Langley.Vo__PM(filts))./Langley.Vo_PM(filts)], '-')
                figure(2); plot(prede.wl(filts), [Langley.Vo_PM(filts),Langley.Vo__PM(filts)], '-');
                tl = title(['Prede Vo values: ',fname]);
                set(tl,'interp','none');
                [pth,fname,ext] = fileparts(prede.fname);
%                 save([prede.pname, 'prede_',datestr(Langley.time,'yyyymmdd_HH'),'.refined_Vo_PM.mat'],'-struct','Langley');
%                 save([prede.pname, 'prede_',datestr(Langley.time,'yyyymmdd_HH'),'.SUN.mat'],'-struct','prede');
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
            end % End of if ~OK
        end
%     catch
%         disp(['problem reading Prede file:',fname,'?'])
%     end
end
    
    
    %%
%     good_days =IQ(Langleys.Vo(3,:));
%     %%
%     figure; plot(serial2doys(Langleys.time(good_days)), Langleys.Vo(:,good_days),'o-');
%     legend('315 nm','400 nm','500 nm','675 nm','870 nm', '940 nm','1020 nm');
%     %%
%     mean_Vo = mean(Langleys.Vo(:,good_days),2); std_Vo =std(Langleys.Vo(:,good_days),[],2);
%     rel_var_Vo = std_Vo./mean_Vo;
%     mean_Vo_ = mean(Langleys.Vo_(:,good_days),2); std_Vo_ =std(Langleys.Vo_(:,good_days),[],2);
%     rel_var_Vo_ = std_Vo_./mean_Vo_;
%     figure; plot(Langleys.wl, 100.*[rel_var_Vo,rel_var_Vo_], '-o')
%     
%     Langleys.good_days = good_days;
%     Langleys.mean_Vo = mean_Vo;
%     Langleys.std_Vo = std_Vo;
%     Langleys.rel_var_Vo = rel_var_Vo;
%     save([prede.pname, filesep, 'all','.refined_Vos.mat'],'Langleys');
%     figure(101); plot(Langleys.wl, 100.*std(Langleys.Vo')./mean(Langleys.Vo'),'o-'); title('percent stddev(Vo)')
%     figure(102); plot(Langleys.wl, 100.*std(Langleys.Vo_')./mean(Langleys.Vo_'),'rx-');title('percent stddev(Vo_U_W)')
%     figure(103); plot(Langleys.wl, 100.*(mean(Langleys.Vo')-mean(Langleys.Vo_'))./mean([Langleys.Vo,Langleys.Vo_]'),'-k+')
%     title('percent([Vo - Vo_U_W])/mean([Vo, Vo_U_W])')
%     figure(104); plot(Langleys.wl, 100.*(std([Langleys.Vo, Langleys.Vo_]'))./mean([Langleys.Vo,Langleys.Vo_]'),'-g+')
%     title('percent stddev([Vo Vo_U_W])')
%     figure(105); plot(Langleys.wl, [Langleys.Vo,Langleys.Vo_]' - ones([12,1])*mean([Langleys.Vo,Langleys.Vo_]'),'-s')
    % Observed variability in Prede Vo values for MLO 2016 Jan is < 0.2% except
    % for 1020 nm 0.22% and 940  nm < 3%
    
    return