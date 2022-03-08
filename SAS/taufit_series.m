function [ttau_fit,ttau] = taufit_series(ttau,quiet)
% compose a time series of tau from multiple potential sources and compose
% tau fit over intervals of airmass/temporal

% The ANET files are one long file, but the ARM netcdf files are daily and
% more robust so that it is necessary to load just some at a time.
% Little challenging handling these independent daily streams.
% Make contiguous list of all reported tau, one tau per row with time and airmass
% Filter NaNs and missings out.  Sort by time.
% Attach a source tag
lang_legs.mt = []; lang_legs = rmfield(lang_legs, 'mt');
if ~isavar('ttau')||isempty(ttau)
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
        mfr_files(end+1) = {getfullname('*aod1mich*','aod1mich')};
    end
    mfr_files(end) = [];
    for m = 1:length(mfr_files)
        src= cims + m;
        mfr = anc_bundle_files({mfr_files{m}{1:next}});
        mfr_files{m}(1:next) = [];
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
            good = qs==0;
            tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
            ttau.aod = [ttau.aod; tmp_aod];
        end
    end

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
if ~isavar('quiet')
    quiet = false;;
end

% ttau.time_LST = ttau.time - 6.5/24;
src_color = colororder;src_color;
day = floor(ttau.time_LST);
dates = unique(day);
dd = 1;
all_MT = isempty(mfr_files{end}); m = length(mfr_files)-1;
while all_MT && m > 0
    all_MT = all_MT && isempty(mfr_files{m}); m = m -1;
end
wl_out = [300:20:1740];
ttau_fit.wl = wl_out;
% PM_leg.wl = wl_out;
mad_factor = 4;

while ~all_MT
    day = floor(ttau.time_LST);
    dates = unique(day);
    all_MT = isempty(mfr_files{end}); m = length(mfr_files)-1;
    while all_MT && m > 0
        all_MT = all_MT && isempty(mfr_files{m}); m = m -1;
    end
    if ~quiet fig22 = figure_(22); end
    Day_str = ['SolarDay_',datestr(dates(dd),'yyyymmdd')];
    fprintf('%s%s... ','Starting ',Day_str);
    this_day = day==dates(dd);
    this_i = find(this_day,1);
    %     src_str{unique(ttau.srctag(this_day))}
    ttau_fit.airmass = []; ttau_fit.aod_fit = []; ttau_fit.time_LST = []; ttau_fit.nm = []; ttau_fit.src = [];
    if ~quiet figure_(22);end
    while  ~isempty(this_i)&&(this_i < find(this_day,1,'last'))%
        etime_mins = (ttau.time-ttau.time(this_i)).*24.*60;
        etime_mins(etime_mins<0) = NaN;
        these_m = day==dates(dd) & abs(ttau.airmass-ttau.airmass(this_i))<.1 & etime_mins>=0& etime_mins<5;
        srcs = unique(ttau.srctag(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
        % Loop over all unique sources, taking mean of each source by wl
        % Plotting each in a different color.
        clear this_am src
        this_am.src = []; this_am.nm = []; this_am.aod = [];
        this_am.time_LST = mean(ttau.time_LST(these_m));
        if ~quiet
            clf; cla; hold('on');
            title({['Solar day: ',datestr(mean(ttau.time_LST(these_m)),'yyyy-mm-dd HH:MM'), ...
                sprintf(', airmass = %2.1f',mean(ttau.airmass(these_m)))];...
                ['Sources: ',srcs_str]});
        end
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
            if ~quiet
                figure_(22);
                plot(src(s_i).nm, src(s_i).aod,'o', 'MarkerSize',4,'MarkerEdgeColor',src_color(srcs(s_i),:));
                logx; logy; hold('on');
            end
        end
        % Fit best AOD and plot in black dots every 20 nm for this am and time.
        % Save best fit AOD
        if max(this_am.nm) < 1200
            sub_ = this_am.nm>600 & this_am.nm<1000;
            P = polyfit(log(1e-3.*this_am.nm(sub_)),log(this_am.aod(sub_)),1); tau_1p6 = exp(polyval(P,1.6));
            [aod_fit, good_wl_] = rfit_aod_basis([this_am.nm; 1600], [this_am.aod; mean(1.5.*[tau_1p6])], wl_out, mad_factor);
            if ~quiet
                figure_(22);
                plot(wl_out, aod_fit, 'r--',this_am.nm(~good_wl_(1:end-1)),this_am.aod(~good_wl_(1:end-1)),'rx','markersize',10);
                pause(.1);
            end
        else
            [aod_fit, good_wl_] = rfit_aod_basis(this_am.nm, this_am.aod, wl_out, mad_factor);
            if ~quiet
                figure_(22);
                plot(wl_out, aod_fit, 'r--',this_am.nm(~good_wl_),this_am.aod(~good_wl_),'rx','markersize',10);
                pause(.1)
            end
        end
        if ~quiet
            lg = legend([src(:).str,'fit']); set(lg,'interp','none');pause(.1)
        end
        ttau_fit.time_LST = [ttau_fit.time_LST; this_am.time_LST];
        ttau_fit.aod_fit = [ttau_fit.aod_fit; aod_fit];
        ttau_fit.airmass = [ttau_fit.airmass; mean(ttau.airmass(these_m))];
        ttau_fit.nm = unique([ttau_fit.nm; this_am.nm]);
        ttau_fit.src = unique([ttau_fit.src; this_am.src]);
        this_i = find(these_m, 1,'last')+1;
    end
    fprintf('%s \n','Done. ');
    dd = dd +1;
    %check if more mfr data needed...
    for m = 1:length(mfr_files)
        src = cims + m;
        m_days = length(unique(floor(ttau.time((ttau.time>ttau.time(this_i)) & (ttau.srctag==src)))));
        if m_days<3 % load files
            next = min([30,length(mfr_files{m})]);
            mfr = anc_bundle_files({mfr_files{m}{1:next}});
            mfr_files{m}(1:next) = [];
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
                good = qs==0;
                tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
                ttau.aod = [ttau.aod; tmp_aod];
            end
        end
    end
    [ttau.time, ij] = sort(ttau.time);
    ttau.airmass = ttau.airmass(ij);
    ttau.nm = ttau.nm(ij);
    ttau.srctag = ttau.srctag(ij);
    ttau.aod = ttau.aod(ij);
    bad = ttau.time<0 | ttau.airmass<0 | ttau.aod <0| isnan(ttau.time)|isnan(ttau.airmass)|isnan(ttau.aod);
    ttau.time(bad) = [];ttau.airmass(bad) = [];
    ttau.nm(bad) = [];ttau.srctag(bad) = []; ttau.aod(bad) = [];
    ttau.time_LST = ttau.time + double(mfr.vdata.lon/15)./24;
end

end
