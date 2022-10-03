function [lang_legs, ttau] = lang_tau_series(ttau)
% compose a time series of tau from one or more confident sources to produce aod-fit
% for use in tau-weighted langley regression. Use dbl_lang as a cloud screen for
% streams before tau_langley
% written by Connor Flynn mostly in 2022
% 2022-08-15: 1.6 micron AOD shows notable steps dependent on whether actual
% measurements exist at the time or are inferred. 
% Will attempt to improve this by interpolating 1.6 micron to all times.
% Also eliminate legs with insufficient points to comprise a valid Langley

% Use dbl_lang as a cloud-screen for MFRSR and SASHe nominal AODs.
% From the above anet aod time series, compute aod-fit to provide aod at non-anet
% wavelengths.  Interpolate *not extrapolate* over time within a given AM/PM airmass
% leg to provide AOD for use in tau_langley regressions for (all!) AOD sources. To
% apply tau_langley to original anet retrievals convert to Tr and see how different
% Trs vary from unity.  This should relate directly to how consistent the tau-langley
% retrieved calibration is to the anet calibration. (Hopefully it is close to unity
% but not identical to unity.)

% Then compute AOD from all sources, find aod-fit, repeat tau-Langley.  Do the AOD
% values converge?  


% Make contiguous list of all reported tau, one tau per row with time and airmass
% Filter NaNs and missings out.  Sort by time.
% Attach a source tag
% Then create a regular matrix with one measurement per WL per time,
% interpolating and extrapolating as necessary. 
% Consider creating "weight" matrix with 1 for measurements, 0.5 for
% interpolated values, and possibly other weights depending on MADS or RMS



% Other thought - apply dlb-lang as cloud screen before eps-screen.  See if this
% yields more AODs in challenging environments

lang_legs.mt = []; lang_legs = rmfield(lang_legs, 'mt');
if ~isavar('ttau')
    ttau.time = [];
    ttau.time_LST = [];
    ttau.airmass = [];
    ttau.nm = [];
    ttau.aod = [];
    ttau.srctag = [];

    src = 0;

    cimfile = getfullname('*.*','anet_aod_v3');
    while ~isempty(cimfile)&&isafile(cimfile)

        src = src + 1;
        src_str(src) = {input('Enter a label for this source: ','s')};
        cim1 = read_cimel_aod_v3(cimfile);
        aods = fields(cim1);
        aod_ = foundstr(aods, 'AOD');
        aods = aods(aod_);
        for f = 1:length(aods)
           good = cim1.(aods{f})>0 ;
            wl = sscanf(aods{f},'AOD_%f'); 
            %Maybe only add records with aod>0
            ttau.time = [ttau.time; cim1.time(good)];
            ttau.airmass = [ttau.airmass; cim1.Optical_Air_Mass(good)];
            ttau.nm = [ttau.nm; wl.*ones(size(cim1.time(good)))];
            ttau.srctag = [ttau.srctag; src.*ones(size(cim1.time(good)))];
            ttau.aod = [ttau.aod; cim1.(aods{f})(good)];
            if isfield(cim1,'Site_Latitude_Degrees_'), 
                ttau.Lat = unique(cim1.Site_Latitude_Degrees_);
                ttau.Lat = ttau.Lat(1);
            end
            if isfield(cim1,'Site_Longitude_Degrees_'), 
                ttau.Lon = unique(cim1.Site_Longitude_Degrees_);
                ttau.Lon = ttau.Lon(1);
            end
        end
        cimfile = getfullname('*.*','anet_aod_v3');
    end

    mfr_files = getfullname('*aod1mich*','aod1mich');
    while ~isempty(mfr_files)

        src = src + 1;
        src_str(src) = {input('Enter a label for this source: ','s')};
        mfr = anc_bundle_files(mfr_files);
        flds = fields(mfr.vdata);
        qc_aod_ = foundstr(flds, 'qc_aerosol_optical_depth');
        qc_ii = find(qc_aod_);
        for qc = 1:sum(qc_aod_)
            wl = sscanf(mfr.gatts.(['filter',num2str(qc),'_CWL_measured']),'%f');
            ttau.time = [ttau.time; mfr.time'];
            ttau.airmass = [ttau.airmass; mfr.vdata.airmass'];
            ttau.nm = [ttau.nm; wl.*ones([length(mfr.time),1])];
            ttau.srctag = [ttau.srctag; src.*ones([length(mfr.time),1])];
            qs = anc_qc_impacts(mfr.vdata.(flds{qc_ii(qc)}), mfr.vatts.(flds{qc_ii(qc)}));
            good = qs==0; sus = qs == 1; 
            %good = qs<2; % To accept suspect, uncomment this line
            tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
            ttau.aod = [ttau.aod; tmp_aod];
            if isfield(mfr.vdata,'lat'),
                ttau.Lat = unique(mfr.vdata.lat);
                ttau.Lat = ttau.Lat(1);
            end
            if isfield(mfr.vdata,'lon'),
                ttau.Lat = unique(mfr.vdata.lon);
                ttau.Lon = ttau.Lon(1);
            end
        end
        mfr_files = getfullname('*aod1mich*','aod1mich');
    end
    [ttau.time, ij] = sort(ttau.time);
    ttau.airmass = ttau.airmass(ij);
    ttau.nm = ttau.nm(ij);
    ttau.srctag = ttau.srctag(ij);
    ttau.aod = ttau.aod(ij);
    bad = ttau.time<0 | ttau.airmass<0 | ttau.aod <0| isnan(ttau.time)|isnan(ttau.airmass)|isnan(ttau.aod);
    ttau.time(bad) = [];ttau.airmass(bad) = [];
    ttau.nm(bad) = [];ttau.srctag(bad) = []; ttau.aod(bad) = [];
    ttau.time_LST = ttau.time + double(ttau.Lon/15)./24;
    ttau.src_str = src_str;    
else
    if ~isfield(ttau,'time_LST')
        ttau.time_LST = ttau.time - 6.5/24; % Assume SGP
    end
    if ~isfield(ttau,'srctag')&&isfield(ttau,'src')
        ttau.srctag = ttau.src; ttau = rmfield(ttau,'src');
    end
    src_str = ttau.src_str;
end
% ttau.time_LST = ttau.time - 6.5/24;
[sza, saz, ~, ~, ~, sel, sun_am] = sunae(ttau.Lat, ttau.Lon, ttau.time);
noon = 12;
src_color = colororder;src_color;
day = floor(ttau.time_LST);
dates = unique(floor(ttau.time_LST));

% This is just a quasi-continuous series of 1.6 micron AOD since leaving it
% out or substituting an alternative has negative consequences on the 1.6
% um Langley

LW.time = ttau.time; 
wl_1p6 = ttau.nm > 1400;
LW.aod = interp1(ttau.time(wl_1p6), ttau.aod(wl_1p6), ttau.time,'linear');
bad = isnan(LW.aod); 
gtime = LW.time(~bad); gaod = LW.aod(~bad);
[gtime, ij] = unique(gtime); gaod = gaod(ij);
LW.aod(bad) =interp1(gtime, gaod, LW.time(bad), 'nearest','extrap');
ttau.aod_1p6 = LW.aod; clear LW

dd = 1;
wl_out = [300:20:1740];
AM_leg.wl = wl_out;
PM_leg.wl = wl_out;
mad_factor = 2.5;

% while dd <= length(dates)
% % trim dates with insufficient number of points and airmass range 
% % Identify all unique wavelengths at which valid AODs are reported
% % Interpolate these over all output time spacings.
% end

while dd <= length(dates)
    fig22 = figure_(22); set(fig22,'visible','off')
    AM_str = ['AM_',datestr(dates(dd),'yyyymmdd')];
    PM_str = ['PM_',datestr(dates(dd),'yyyymmdd')];
    this_day = day==dates(dd);
    this_i = find(this_day,1);
%     src_str{unique(ttau.srctag(this_day))}
    AM_leg.airmass = []; AM_leg.aod_fit = []; AM_leg.time_LST = []; AM_leg.nm = []; AM_leg.src = [];
    PM_leg.airmass = []; PM_leg.aod_fit = []; PM_leg.time_LST = []; PM_leg.nm = []; PM_leg.src = [];
    %% AM leg
    while serial2Hh(ttau.time_LST(this_i)) < (noon-.5) && this_i < find(this_day,1,'last')%
        these_m = day==dates(dd) & (serial2Hh(ttau.time_LST) < (noon-.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
        srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
        % Loop over all unique sources, taking mean of each source by wl
        % Plotting each in a different color.
        clear this_am src
        this_am.src = []; this_am.nm = []; this_am.aod = [];
        this_am.time_LST = mean(ttau.time_LST(these_m));
        figure_(22); clf; cla; hold('on');
        title({[datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', AM airmass = %2.1f',mean(ttau.airmass(these_m)))];...
            ['Sources: ',srcs_str]});
        for s_i = 1:length(srcs) % check that srcs is the right orientation
            src(s_i).str = src_str(srcs(s_i));
            s_ = ttau.srctag==srcs(s_i);
            wls = unique(ttau.nm(these_m & s_));
            src(s_i).nm = wls;
            for wl_i = 1:length(wls)
                wl_ = ttau.nm == wls(wl_i);
                src(s_i).aod(wl_i,1) = mean(ttau.aod(these_m & s_ & wl_));
            end
            this_am.aod = [this_am.aod; src(s_i).aod];
            this_am.nm = [this_am.nm; src(s_i).nm];
            this_am.src = [this_am.src ; srcs(s_i).*ones(size(src(s_i).aod))];
            figure_(22); plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:)); logx; logy; hold('on'); 
            pause(.025)
        end
        % Fit best AOD and plot in black dots every 20 nm for this am and time.
        % Save best fit AOD
        if max(this_am.nm) < 1200
            this_am.aod = [this_am.aod; mean(ttau.aod_1p6(these_m & s_ & wl_))];
            this_am.nm = [this_am.nm; 1640];
            this_am.src = [this_am.src ; srcs(1)];

%             sub_ = this_am.nm>600 & this_am.nm<1000;
%             P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
%            [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; 1.5.*tau_1p6], wl_out, mad_factor);
%         else
%             [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        end
        [aod_fit, good_wl_, fit_rms, fit_bias] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        figure_(22);plot(wl_out, aod_fit,'k--');pause(.025)
        lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
        AM_leg.time_LST = [AM_leg.time_LST; this_am.time_LST];
        AM_leg.aod_fit = [AM_leg.aod_fit; aod_fit];
        AM_leg.airmass = [AM_leg.airmass; mean(ttau.airmass(these_m))];
        AM_leg.nm = unique([AM_leg.nm; this_am.nm]);
        AM_leg.src = unique([AM_leg.src; this_am.src]);
        this_i = find(these_m, 1,'last')+1;
    end % of AM leg
    AM_range = max(AM_leg.airmass)-min(AM_leg.airmass);
    if ~isfield(lang_legs,AM_str)&&isavar('AM_leg')&&length(AM_leg.airmass)>10&&(AM_range>3)&&(min(AM_leg.airmass)<3.5)&&(max(AM_leg.airmass)>4.5)
        lang_legs.(AM_str)=AM_leg;
    end
    % By this time, we should have points for AM Langley if conditions permit
    if length(AM_leg.airmass)>3 && (max(AM_leg.airmass)-min(AM_leg.airmass))>3
        figure_(24); set(gcf,'visible','off')
        xx(1) = subplot(2,1,1);
        plot(AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');logy;
        xl = xlim; xlim([-0.25, xl(2)])
        title([datestr(mean(AM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', AM Leg']);
        ylabel('Tr')
        xx(2) = subplot(2,1,2);
        plot(AM_leg.aod_fit(:,11).*AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');logy;
        xl = xlim; xlim([0, xl(2)])
        xlabel('airmass*aod');
        ylabel('Tr');
        linkaxes(xx,'y');
        pause(0.01)
    end
%     this_i = find(these_m, 1,'last')+1;
    
    % Start PM leg
    these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==500;
    this_i = find(this_day & (serial2Hh(ttau.time_LST)>(noon+.5)),1,'first');
    this_j = find(this_day & (serial2Hh(ttau.time_LST)>(noon+.5)),1,'last');
    while  ~isempty(this_i)&&(this_i < find(this_day,1,'last'))%         
        figure_(22); set(gcf,'visible','off')
        these_m = day==dates(dd) & (serial2Hh(ttau.time_LST) > (noon+.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
        srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
        % Loop over all unique sources, taking mean of each source by wl
        % Plotting each in a different color.
        clear this_am src
        this_am.src = []; this_am.nm = []; this_am.aod = [];
        this_am.time_LST = mean(ttau.time_LST(these_m));
        clf; cla; hold('on')
                title({[datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), sprintf(', PM airmass = %2.1f',mean(ttau.airmass(these_m)))];...
            ['Sources: ',srcs_str]});
        for s_i = 1:length(srcs) % check that srcs is the right orientation
            src(s_i).str = src_str(srcs(s_i));
            s_ = ttau.srctag==srcs(s_i);
            wls = unique(ttau.nm(these_m & s_));
            src(s_i).nm = wls;
            for wl_i = 1:length(wls)
                wl_ = ttau.nm == wls(wl_i);
                src(s_i).aod(wl_i,1) = mean(ttau.aod(these_m & s_ & wl_));
            end
            this_am.aod = [this_am.aod; src(s_i).aod];
            this_am.nm = [this_am.nm; src(s_i).nm];
            this_am.src = [this_am.src ; srcs(s_i).*ones(size(src(s_i).aod))];
            figure_(22);plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:));set(gcf,'visible','off');
            logx; logy; hold('on');
             pause(.025);
        end
        % Fit best AOD and plot in black dots every 20 nm for this am and time.
        % Save best fit AOD
        if max(this_am.nm) < 1200
                        this_am.aod = [this_am.aod; mean(ttau.aod_1p6(these_m & s_ & wl_))];
            this_am.nm = [this_am.nm; 1640];
            this_am.src = [this_am.src ; srcs(1)];
%             sub_ = this_am.nm>600 & this_am.nm<1000;
%             P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
%            [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; mean(1.5.*[tau_1p6])], wl_out, mad_factor);
%         else
%             [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        end
        [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        figure_(22); plot(wl_out, aod_fit, 'r--');pause(.025); set(fig22,'visible','on')
        lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.01)
        PM_leg.time_LST = [PM_leg.time_LST; this_am.time_LST];
        PM_leg.aod_fit = [PM_leg.aod_fit; aod_fit];
        PM_leg.airmass = [PM_leg.airmass; mean(ttau.airmass(these_m))];
        PM_leg.nm = unique([PM_leg.nm; this_am.nm]);
        PM_leg.src = unique([PM_leg.src; this_am.src]);
        this_i = find(these_m, 1,'last')+1;
    end % of PM leg
    PM_range = max(PM_leg.airmass)-min(PM_leg.airmass);
    if ~isfield(lang_legs,PM_str)&&length(PM_leg.airmass)>10&&(PM_range>3)&&(min(PM_leg.airmass)<3.5)&&(max(PM_leg.airmass)>4.5)
        lang_legs.(PM_str)=PM_leg;
    end
    if length(PM_leg.airmass)>3 && (max(PM_leg.airmass)-min(PM_leg.airmass))>3
        figure_(24); set(gcf,'visible','on')
        xx(1) = subplot(3,1,1);
        plot(PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');logy;
        xl = xlim; xlim([0, xl(2)]); yl = ylim; ylim([yl(1),1]);
        P_11 = polyfit(PM_leg.airmass, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
        tau_bar = -P_11(1); Io = exp(P_11(2));
        title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
        ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
        hold('on'); plot([0,7], exp(polyval(P_11,[0,7])),'r--')
        
        xx(2) = subplot(3,1,2);
        plot(PM_leg.airmass.*tau_bar, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');logy;
        xl = xlim; xlim([0, xl(2)])
        P_11_bar = polyfit(PM_leg.airmass*tau_bar, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
        tau_bar_bar = -P_11_bar(1); Io_bar = exp(P_11_bar(2));
        title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
        ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
        hold('on'); plot([0,7], exp(polyval(P_11,[0,7])),'r--')

        xx(3) = subplot(3,1,3);
        plot(PM_leg.airmass.*PM_leg.aod_fit(:,11), exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');logy;
        xl = xlim; xlim([0, xl(2)])
        P_11_bar = polyfit(PM_leg.airmass*tau_bar, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);
        tau_bar_bar = -P_11_bar(1); Io_bar = exp(P_11_bar(2));
        title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
        ylab = ylabel('Tr_a_e_r_o'); set(ylab,'interp','tex');
        hold('on'); plot([0,7], exp(polyval(P_11,[0,7])),'r--')


        plot(PM_leg.aod_fit(:,11).*PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([0, xl(2)])
        xlabel('airmass*tau');
        ylabel('Tr');
        linkaxes(xx,'y');
        pause(.01)
    end
    dd = dd +1;
end
[fit_aod, good_wl_,fit_aod_rms, fit_aod_bias] = rfit_aod_basis(anet_nm, [these_340.aod(1),these_380.aod(1),these_440.aod(1),these_500.aod(1),...
    these_675.aod(1),these_870.aod(1),these_1020.aod(1),these_1640.aod(1)]');
[fit_tau, good_wl_,fit_tau_rms, fit_tau_bias] = rfit_aod_basis(anet_nm, [these_340.tau_I(1),these_380.tau_I(1),these_440.tau_I(1),these_500.tau_I(1),...
    these_675.tau_I(1),these_870.tau_I(1),these_1020.tau_I(1),these_1640.tau_I(1)]');
figure; 
nn(1) = subplot(2,1,1);
plot(anet_nm, [these_340.aod(1),these_380.aod(1),these_440.aod(1),these_500.aod(1),...
    these_675.aod(1),these_870.aod(1),these_1020.aod(1),these_1640.aod(1)],'o', ...
    anet_nm, fit_aod,'-o',...
    anet_nm, [these_340.tau_I(1),these_380.tau_I(1),these_440.tau_I(1),these_500.tau_I(1),...
    these_675.tau_I(1),these_870.tau_I(1),these_1020.tau_I(1),these_1640.tau_I(1)],'x',...
    anet_nm, fit_tau,'-+'); logy; logx;
title(['Airmass = ',num2str(these_340.airmass(1))]);
nn(2) = subplot(2,1,2);
plot(anet_nm, [these_340.aod(end),these_380.aod(end),these_440.aod(end),these_500.aod(end),...
    these_675.aod(end),these_870.aod(end),these_1020.aod(end),these_1640.aod(end)],'o', ...
    anet_nm, [these_340.tau_I(end),these_380.tau_I(end),these_440.tau_I(end),these_500.tau_I(end),...
    these_675.tau_I(end),these_870.tau_I(end),these_1020.tau_I(end),these_1640.tau_I(end)],'x'); logy; logx;
title(['Airmass = ',num2str(these_340.airmass(end))]);

end