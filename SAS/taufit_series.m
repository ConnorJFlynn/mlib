function [ttau, ttau_fit] = taufit_series(ttau)
% compose a time series of tau from multiple potential sources and compose
% tau fit over intervals of airmass/temporal 

% Each data source
% Make contiguous list of all reported tau, one tau per row with time and airmass
% Filter NaNs and missings out.  Sort by time.
% Attach a source tag
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
        [~,fname,ext] =fileparts(cimfile);[fname,ext]
        src = src + 1;
        src_str(src) = {input('Enter a label for this source: ','s')};
        cim1 = read_cimel_aod_v3(cimfile);
        aods = fields(cim1);
        aod_ = foundstr(aods, 'AOD');
        aods = aods(aod_);
        for f = 1:length(aods)
            wl = sscanf(aods{f},'AOD_%f');
            ttau.time = [ttau.time; cim1.time];
            ttau.airmass = [ttau.airmass; cim1.Optical_Air_Mass];
            ttau.nm = [ttau.nm; wl.*ones(size(cim1.time))];
            ttau.srctag = [ttau.srctag; src.*ones(size(cim1.time))];
            ttau.aod = [ttau.aod; cim1.(aods{f})];
        end
        cimfile = getfullname('*.*','anet_aod_v3');
    end
    cims = src;
    mfr_day = [];
    mfr_files(1) = {getfullname('*aod1mich*','aod1mich')};
    while ~isempty(mfr_files{end})

        [~,fname,ext] =fileparts(mfr_files{end}{1});[fname,ext]
        src = src + 1;
        src_str(src) = {input('Enter a label for this source: ','s')};
        next = min([30,length(mfr_files{end})]);
        if ~isavar('mfr')
            mfr(1) = anc_bundle_files({mfr_files{end}{1:next}});
        else
            mfr(end) = anc_bundle_files({mfr_files{end}{1:next}});
        end; mfr_files{end}(1:next) = [];
        flds = fields(mfr.vdata); 
        mfr_day = min([mfr_day, ceil(mfr.time(end))]); %read more files on this day
        qc_aod_ = foundstr(flds, 'qc_aerosol_optical_depth');
        qc_ii = find(qc_aod_);
        for qc = 1:sum(qc_aod_)
            wl = sscanf(mfr.gatts.(['filter',num2str(qc),'_CWL_measured']),'%f');
            ttau.time = [ttau.time; mfr.time'];
            ttau.airmass = [ttau.airmass; mfr.vdata.airmass'];
            ttau.nm = [ttau.nm; wl.*ones([length(mfr.time),1])];
            ttau.srctag = [ttau.srctag; src.*ones([length(mfr.time),1])];
            qs = anc_qc_impacts(mfr.vdata.(flds{qc_ii(qc)}), mfr.vatts.(flds{qc_ii(qc)}));
            good = qs==0; sus = qs == 1; good = qs<=2;
            tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
            ttau.aod = [ttau.aod; tmp_aod];
        end
        mfr_files(end+1) = {getfullname('*aod1mich*','aod1mich')};
    end
    mfr_files(end) = [];
    % By here we've read all Cimels files and one of each xmfrx file to
    % determine start date for entire series.  

    [ttau.time, ij] = sort(ttau.time);
    ttau.airmass = ttau.airmass(ij);
    ttau.nm = ttau.nm(ij);
    ttau.srctag = ttau.srctag(ij);
    ttau.aod = ttau.aod(ij);
    bad = ttau.time<0 | ttau.airmass<0 | ttau.aod <0| isnan(ttau.time)|isnan(ttau.airmass)|isnan(ttau.aod);
    ttau.time(bad) = [];ttau.airmass(bad) = [];
    ttau.nm(bad) = [];ttau.srctag(bad) = []; ttau.aod(bad) = [];
    ttau.time_LST = ttau.time + double(mfr.vdata.lon/15)./24;
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
noon = 12;
src_color = colororder;src_color;
day = floor(ttau.time_LST);
dates = unique(floor(ttau.time_LST));
dd = 1;
all_MT = isempty(mfr_files{end}); m = length(mfr_files)-1;
while all_MT && m > 0
    all_MT = all_MT && isempty(mfr_files{m}); m = m -1;
end
wl_out = [300:20:1740];
AM_leg.wl = wl_out;
PM_leg.wl = wl_out;
mad_factor = 2.5;

while ~all_MT

    if dates(1)>=mfr_day
        %get more mfr data...
        for m = 1:length(mfr_file)
            src = cims + m;
            next = min([30,length(mfr_files{m})]);
            mfr(m) = anc_bundle_files({mfr_files{end}{1:next}});
            mfr_files{m}(1:next) = [];
            flds = fields(mfr.vdata);
            mfr_day = min([mfr_day, ceil(mfr.time(end))]); %read more files on this day
            qc_aod_ = foundstr(flds, 'qc_aerosol_optical_depth');
            qc_ii = find(qc_aod_);
            for qc = 1:sum(qc_aod_)
                wl = sscanf(mfr.gatts.(['filter',num2str(qc),'_CWL_measured']),'%f');
                ttau.time = [ttau.time; mfr.time'];
                ttau.airmass = [ttau.airmass; mfr.vdata.airmass'];
                ttau.nm = [ttau.nm; wl.*ones([length(mfr.time),1])];
                ttau.srctag = [ttau.srctag; src.*ones([length(mfr.time),1])];
                qs = anc_qc_impacts(mfr.vdata.(flds{qc_ii(qc)}), mfr.vatts.(flds{qc_ii(qc)}));
                good = qs==0; sus = qs == 1; good = qs<=2;
                tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
                ttau.aod = [ttau.aod; tmp_aod];
            end
            mfr_files(end+1) = {getfullname('*aod1mich*','aod1mich')};
        end
    end
    all_MT = isempty(mfr_files{end}); m = length(mfr_files)-1;
    while all_MT && m > 0
        all_MT = all_MT && isempty(mfr_files{m}); m = m -1;
    end
    fig22 = figure_(22);
    AM_str = ['AM_',datestr(dates(dd),'yyyymmdd')];
    PM_str = ['PM_',datestr(dates(dd),'yyyymmdd')];
    this_day = day==dates(dd);
    this_i = find(this_day,1);
%     src_str{unique(ttau.srctag(this_day))}
    AM_leg.airmass = []; AM_leg.aod_fit = []; AM_leg.time_LST = []; AM_leg.nm = []; AM_leg.src = [];
    PM_leg.airmass = []; PM_leg.aod_fit = []; PM_leg.time_LST = []; PM_leg.nm = []; PM_leg.src = [];
    %% AM leg
    while serial2Hh(ttau.time_LST(this_i)) < (noon-.5) && this_i < find(this_day,1,'last')%
        try % Not sure why but serial2Hh is balking when time is Mx1, so use a try-catch
            these_m = day==dates(dd) & (serial2Hh(ttau.time_LST) < (noon-.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
        catch
            these_m = day==dates(dd) & (serial2Hh(ttau.time_LST')' < (noon-.5)) & abs(ttau.airmass-ttau.airmass(this_i))<.1;
        end
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
        end
        % Fit best AOD and plot in black dots every 20 nm for this am and time.
        % Save best fit AOD
        if max(this_am.nm) < 1200
            sub_ = this_am.nm>600 & this_am.nm<1000;
            P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
           [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; 1.5.*tau_1p6], wl_out, mad_factor);
        else
            [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        end
        figure_(22);plot(wl_out, aod_fit,'k--');
        lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.1)
        AM_leg.time_LST = [AM_leg.time_LST; this_am.time_LST];
        AM_leg.aod_fit = [AM_leg.aod_fit; aod_fit];
        AM_leg.airmass = [AM_leg.airmass; mean(ttau.airmass(these_m))];
        AM_leg.nm = unique([AM_leg.nm; this_am.nm]);
        AM_leg.src = unique([AM_leg.src; this_am.src]);
        this_i = find(these_m, 1,'last')+1;
    end % of AM leg
    if ~isfield(lang_legs,AM_str)
        lang_legs.(AM_str)=AM_leg;
    end
    % By this time, we should have points for AM Langley if conditions permit
    if length(AM_leg.airmass)>3 && (max(AM_leg.airmass)-min(AM_leg.airmass))>3
        figure_(24);
        xx(1) = subplot(2,1,1);
        plot(AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([-0.25, xl(2)])
        title([datestr(mean(AM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', AM Leg']);
        ylabel('Tr')
        xx(2) = subplot(2,1,2);
        plot(AM_leg.aod_fit(:,11).*AM_leg.airmass, exp(-AM_leg.airmass.*AM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([0, xl(2)])
        xlabel('airmass*aod');
        ylabel('Tr');
        linkaxes(xx,'y');
        pause(1)
    end
%     this_i = find(these_m, 1,'last')+1;
    figure_(22);
    % Start PM leg
    this_i = find(this_day & (serial2Hh(ttau.time_LST)>(noon+.5)),1,'first');
    while  ~isempty(this_i)&&(this_i < find(this_day,1,'last'))%         
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
            figure_(22);plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:)); logx; logy; hold('on');
        end
        % Fit best AOD and plot in black dots every 20 nm for this am and time.
        % Save best fit AOD
        if max(this_am.nm) < 1200
            sub_ = this_am.nm>600 & this_am.nm<1000;
            P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
           [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; mean(1.5.*[tau_1p6])], wl_out, mad_factor);
        else
            [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
        end
        figure_(22);plot(wl_out, aod_fit, 'r--');pause(.1)
        lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.1)
        PM_leg.time_LST = [PM_leg.time_LST; this_am.time_LST];
        PM_leg.aod_fit = [PM_leg.aod_fit; aod_fit];
        PM_leg.airmass = [PM_leg.airmass; mean(ttau.airmass(these_m))];
        PM_leg.nm = unique([PM_leg.nm; this_am.nm]);
        PM_leg.src = unique([PM_leg.src; this_am.src]);
        this_i = find(these_m, 1,'last')+1;
    end % of PM leg
    if ~isfield(lang_legs,PM_str)
        lang_legs.(PM_str)=PM_leg;
    end
    if length(PM_leg.airmass)>3 && (max(PM_leg.airmass)-min(PM_leg.airmass))>3
        figure_(24);
        xx(1) = subplot(2,1,1);
        plot(PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([-0.25, xl(2)])
        title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
        ylabel('Tr')
        xx(2) = subplot(2,1,2);
        plot(PM_leg.aod_fit(:,11).*PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([0, xl(2)])
        xlabel('airmass*tau');
        ylabel('Tr');
        linkaxes(xx,'y');
        pause(1)
    end
    dd = dd +1;
end

end