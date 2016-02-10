start_time = now;
end_time = start_time +1;
day = [start_time:(1/(60*60)):end_time]';
[zen, az, soldst, ha, dec, el, am] = sunae(0, 0, day);
figure; plot(serial2hs(day), am,'.')
menu('Zoom into desired range and click OK when done.','OK');
xl = xlim;
day_ = serial2hs(day)>=xl(1) & serial2hs(day)<=xl(2) & am>2 & am<11;;
day = day(day_);
[zen, az, soldst, ha, dec, el, am] = sunae(0, 0, day);

[m_ray, m_aero]=airmasses(zen, 0); % airmass for O3
    [tau_ray]=rayleighez(.5,1013.*ones(size(day)),day,0.*ones(size(day))); % Rayleigh
%     [cross_sections, s.tau_O3, s.tau_NO2, s.tau_O4, s.tau_CO2_CH4_N2O, s.tau_O3_err, s.tau_NO2_err, s.tau_O4_err, s.tau_CO2_CH4_N2O_abserr]=taugases(s.t, 'SUN', s.Alt, s.Lat, s.Lon, s.O3col, s.NO2col); % gases

    figure; plot(serial2doys(day), tau_ray,'x');
    tau_aero = linspace(tau_ray(1), 2.*tau_ray(1), length(tau_ray))';
    tau_1 = tau_aero;
    % We suppose these are the "actual" total optical depths.
    tau_2 = 3.*tau_ray-tau_aero + [zeros([150,1]); linspace(0,.2,length(day)-150)'];
    Ia2 = exp(-m_ray .* (tau_2));
    % So this is the observed intensity based on that actual tau_2
    
    
%     figure; plot(serial2doys(day), Iray,'-')
    figure; plot(m_ray, Ia2, 'k.'); logy
%     [P] = polyfit(1./airmass, real(log(V))./airmass, 1);
    figure; plot(1./m_ray, log(Ia2)./m_ray, 'k.'); 
    [Vo_2, tau, P] = lang(m_ray, Ia2);[Vo_2_uw] = lang_uw(m_ray, Ia2);
    
    figure; plot(m_ray.*(tau_2), Ia2, 'k'); logy

    %Introduce a +/- 20% error in measured tau representing calibration
    %error/uncertainty of the instrument
        Ia2_r = Ia2 .* exp(m_ray .* (tau_ray));
    f = [0.8:0.01:1.2];
    for fi = 1:length(f)
        in_tau = tau_2 + (1-f(fi))./m_ray;
        in_tau_r = in_tau - tau_ray;
        [Vo_w(fi)] = lang(m_ray.*in_tau, Ia2);
        [Vo_uw(fi)] = lang_uw(m_ray.*in_tau, Ia2);
        [Vo_wr(fi)] = lang(m_ray.*in_tau_r, Ia2_r);
        [Vo_uwr(fi)] = lang_uw(m_ray.*in_tau_r, Ia2_r);

    end
    figure; plot(f, Vo_w, 'ro', f, Vo_uw, 'bx',f, Vo_wr, 'g.',f,Vo_uwr,'k+'); legend('Weighted','Unweighted')
    
    Ia2_tau = Ia2 .* exp(m_ray .* tau_ray);
        Ia2_tau_ = exp(-m_ray .* tau_2);
    for fi = 1:length(f)
    [Vo_rw(fi)] = lang(m_ray.*f(fi).*tau_2, Ia2_tau);
    [Vo_ruw(fi)] = lang_uw(m_ray.*f(fi).*tau_2, Ia2_tau);    
    end
figure; plot(m_ray, log(Ia2_tau),'o')
        figure; plot(f, Vo_rw, 'ro', f, Vo_ruw, 'bx'); legend('RWeighted','RUnweighted')

    


    
    
    % double Lang Aug doesn't really work.  Seems like iterative solution
    % not optimal.  Will try merely "cloud-screening" tau from an
    % initial Io.  Might try iterative solution for Vo using 
    [Vo,tau,Vo_, tau_, good] = dbl_lang_aug(m_ray.*(tau_ray+.95*tau_2), Ia2,1.5,1,1);
    
    
     [Vo_,tau_,P_] = lang_uw(m_ray, Iray);
    
     mfr = anc_bundle_files;

     ARM_display(mfr);
     
     figure; plot(serial2doys(mfr.time), mfr.vdata.variability_flag,'k.')
     