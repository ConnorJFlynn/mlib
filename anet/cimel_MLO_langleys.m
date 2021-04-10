function cimel_MLO_langleys
% unit number: T1370TP-UA4873
% filter, CWL, FWHM
% filter 340 nm: 343.8280288	4.531419558
% filter 380 nm: 379.3446179	3.603603604
% filter 440 nm: 440.2330156	10.45519968
% filter 500 nm: 499.731411	9.808709252
% filter 675 nm: 675.0574799	9.808706535
% filter 870 nm: 869.893258	9.60960961
% filter 937 nm: 937.073443	9.788324676
% filter 1020 nm: 1019.728679	9.534534535
% filter 1640 nm: 1639.174523	25.25525526

wl = [343.828,379.345,440.233,499.731,675.057, 869.893, 937.073, 1019.729,1019.729,1639.174  ]';
tau_ray = tau_std_ray_atm(wl./1000)*680./1013;
nsu.wl = [340,380,440,500,675,870,940,1019,1020,1640];
in_file =getfullname('*.nsu','cimel_MLO');
nsu = read_k8_nsu(in_file);
Lat = 19.5363;
Lon = -155.5759;
tz_offset = Lon./15;
local = (nsu.time+tz_offset./24);
Alt_m = 11141 * 12/(2.54 *100);
[zen, az, soldst, ha, dec, el, am] = sunae(Lat, Lon, nsu.time', Alt_m);
Tr_ray = exp(-tau_ray*am);

Langley.Lat = Lat; 
Langley.Lon = Lon;
Langley.Alt_m = Alt_m;
Langley.tz_offset = tz_offset;
Langley.wl = wl;
Langley.tau_ray = tau_ray;


tt = 1;
leg = 0;
while tt<= length(nsu.time)-1

    while (am(tt)<2 || am(tt)>15 && tt<= length(nsu.time)-1) || local(tt)<datenum(2016,11,9)
        tt = tt +1;
    end
    i_start = tt;
    AM = serial2Hh(local(tt))<12;
    while am(tt)<=15 && am(tt)>=2 && serial2Hh(local(tt))<12==AM ...
            && (nsu.time(tt)-nsu.time(i_start))<0.75 ...
            && tt<= length(nsu.time)-1
        tt = tt+1;
    end
    i_end = tt-1;
    datestr(nsu.time([i_start i_end]))
    good = false(size(nsu.time));
    if abs(am(i_end)-am(i_start))>2
        good(i_start:i_end) = true;
    end
    
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(am(good),(soldst(good).^2).*nsu.I(good,6)'./Tr_ray(6,good),2,1,1);
    pause(.1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(am(good),(soldst(good).^2).*nsu.I(good,4)'./Tr_ray(4,good),2.3,1,1);
    pause(.1);
    [Vo,tau,Vo_, tau_, good(good)] = dbl_lang(am(good),(soldst(good).^2).*nsu.I(good,8)'./Tr_ray(8,good),2.3,1,1);
    pause(.1);
    if sum(good)>10 & (max(am(good))- min(am(good)))>2
            leg = leg + 1;
    clear Vo tau Vo_ tau_
    for f = [10:-1:8 6:-1:1]
        %    disp(['wavelength = ',num2str(Lambda(L))])
        [Vo(f), tau(f), P,S,Mu,dVo(f)] = lang(am(good),(nsu.I(good,f)'.*soldst(good).^2)./(Tr_ray(f,good)));
        [Vo_(f),tau_(f), P_] = lang_uw(am(good),(nsu.I(good,f)'.*soldst(good).^2)./(Tr_ray(f,good)));
        disp(['Done with ',num2str(wl(f))])
        figure(1003);
%         subplot(2,1,1);
        semilogy(am(good),(nsu.I(good,f)'.*soldst(good).^2)./(Tr_ray(f,good)),'ok-',...
            am(good),exp(polyval(P,am(good),S,Mu)),'r');
        title(['Langley at ',num2str(wl(f)), ' Vo=',sprintf('%0.3g',Vo(f)), ' dVo=',sprintf('%0.3g',dVo(f)),' tau=',sprintf('%0.2g',tau(f)), ' sum(good)=',sprintf('%g',sum(good))]);
        % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
%         subplot(2,1,2);
%         semilogy(1./am(good), exp(real(log((nsu.I(good,f)'.*soldst(good).^2)./(Tr_ray(f,good))))...
%             ./am(good)),'g.');
%         title(['Langley at ',num2str(wl(f)),' Vo=',num2str(Vo_(f)),' tau=',num2str(tau_(f)), ' sum(good)=',num2str(sum(good))]);
%         %    title(['goods=',num2str(goods),' mad=',num2str(mad),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
%         hold('on');
%         plot( 1./am(good), exp(polyval(P_, 1./am(good))),'r');
%         hold('off');
%         menu('Press OK to continue','OK')
    end
    Vo(7) = NaN; Vo_(7) = NaN;
    % disp('Done!')
    Langley.time_mean(leg) = mean(nsu.time(good));
    Langley.time_local(leg) = mean(local(good));
    Langley.Vo(:,leg) = Vo';;
    Langley.tau(:,leg) = tau';
    Langley.Vo_(:,leg) = Vo_';
    Langley.tau_(:,leg) = tau_';
    Langley.AM(:,leg) = AM;
    Langley.soldst(:,leg) = mean(soldst(good));
    

    Tr = [nsu.I(good,1).*soldst(good)'.^2./Tr_ray(1,good)'./Langley.Vo(1), ...
        nsu.I(good,2).*soldst(good)'.^2./Tr_ray(2,good)'./Langley.Vo(2),nsu.I(good,3).*soldst(good)'.^2./Tr_ray(3,good)'./Langley.Vo(3),...
        nsu.I(good,4).*soldst(good)'.^2./Tr_ray(4,good)'./Langley.Vo(4),nsu.I(good,5).*soldst(good)'.^2./Tr_ray(5,good)'./Langley.Vo(5),...
        nsu.I(good,6).*soldst(good)'.^2./Tr_ray(6,good)'./Langley.Vo(6),nsu.I(good,7).*soldst(good)'.^2./Tr_ray(7,good)'./Langley.Vo(7),...
        nsu.I(good,8).*soldst(good)'.^2./Tr_ray(8,good)'./Langley.Vo(8),nsu.I(good,9).*soldst(good)'.^2./Tr_ray(9,good)'./Langley.Vo(9)];
    
    langplot(leg).time = nsu.time(good);
    langplot(leg).AM = AM;
    langplot(leg).am = am(good)';
    langplot(leg).Tr = Tr;
    langplot(leg).Tr_ray = Tr_ray(:,good)';
    langplot(leg).sunaz = az(good)';
    langplot(leg).sunel = el(good)';
    langplot(leg).Vo = Vo';
    langplot(leg).tau = tau';
    langplot(leg).Vo_ = Vo_';
    langplot(leg).tau_ = tau_';
    langplot(leg).AM = AM;
    langplot(leg).soldst = mean(soldst(good));
    langplot(leg).Lat = Lat; 
    langplot(leg).Lon = Lon;
    langplot(leg).Alt_m = Alt_m;
    langplot(leg).tz_offset = tz_offset;
    langplot(leg).wl = wl';
    langplot(leg).tau_ray = tau_ray';
%         nsu.I(good,10).*soldst(good)'.^2./Tr_ray(10,good)'./Langley.Vo(10)];
    
    figure; these = plot(am(good), (Tr(:,[1:6,8:9],:)),'-*'); recolor(these,wl([1:6,8:9])); logy;
    set(gca,'ytick',[0.8:.02:1])
    
    leg_str = {sprintf('%3.0f nm',wl(1))}; leg_str(end+1) = {sprintf('%3.0f nm',wl(2))};
    leg_str(end+1) = {sprintf('%3.0f nm',wl(3))};leg_str(end+1) = {sprintf('%3.0f nm',wl(4))};
    leg_str(end+1) = {sprintf('%3.0f nm',wl(5))};   leg_str(end+1) = {sprintf('%3.0f nm',wl(6))};
    leg_str(end+1) = {sprintf('%3.0f nm',wl(8))};  leg_str(end+1) = {sprintf('%3.0f nm',wl(9))};
%     leg_str(end+1) = {sprintf('%3.0f nm',wl(10))};
    legend(leg_str);
    pause(1)
    end
    
    close('all')
end

keep = IQ(Langley.Vo(4,:));
Langley.Vo(7,:) = NaN;
figure; these = plot(Langley.time_local(keep), Langley.Vo(1:8,keep)','-*'); recolor(these,Langley.wl(1:8))

100.*std(Langley.Vo(:,keep)')'./mean(Langley.Vo(:,keep),2)

[pname, fname] = fileparts(in_file);
save([pname, filesep,'Cimel_1370TP_Langley_Vos.MLO_Nov_2016.mat'],'-struct','Langley');
save([pname, filesep,'Cimel_1370TP_Langplot.MLO_Nov_2016.mat'],'langplot');

return