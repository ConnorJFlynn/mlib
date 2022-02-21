function ttau = lang_tau_series
% compose a time series of tau from multiple potential sources for use in
% tau-weighted langley retreival for SAS

% Each data source
% Make contiguous list of all reported tau, one tau per row with time and airmass
% Filter NaNs and missings out.  Sort by time.
% Attach a source tag

ttau.time = [];
ttau.airmass = [];
ttau.nm = [];
ttau.aod = [];
ttau.src = [];
src = 0;
src_color = colororder;src_color;

cimfile = getfullname('*.*','anet_aod_v3');
while ~isempty(cimfile)&&isafile(cimfile)
    
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
        ttau.src = [ttau.src; src.*ones(size(cim1.time))];
        ttau.aod = [ttau.aod; cim1.(aods{f})];        
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
        ttau.src = [ttau.src; src.*ones([length(mfr.time),1])];
        qs = anc_qc_impacts(mfr.vdata.(flds{qc_ii(qc)}), mfr.vatts.(flds{qc_ii(qc)}));
        good = qs==0; sus = qs == 1;
        tmp_aod = mfr.vdata.(flds{qc_ii(qc)-1})'; tmp_aod(~good) = NaN;
        ttau.aod = [ttau.aod; tmp_aod];
    end
    mfr_files = getfullname('*aod1mich*','aod1mich');
end

bad = ttau.time<0 | ttau.airmass<0 | ttau.aod <0| isnan(ttau.time)|isnan(ttau.airmass)|isnan(ttau.aod);
ttau.time(bad) = [];ttau.airmass(bad) = [];
ttau.nm(bad) = [];ttau.src(bad) = []; ttau.aod(bad) = [];

[ttau.time, ij] = sort(ttau.time);
ttau.airmass = ttau.airmass(ij);
ttau.nm = ttau.nm(ij);
ttau.src = ttau.src(ij);
ttau.aod = ttau.aod(ij);
day = floor(ttau.time);
dates = unique(floor(ttau.time)); 
srcs = unique(ttau.src);

dd = 0;

dd = dd +1;
this_day = day==dates(dd); this_i = find(this_day,1); src_str{unique(ttau.src(this_day))}
these_m = day==dates(dd) & abs(ttau.airmass-ttau.airmass(this_i))<.1; 
srcs = unique(ttau.src(these_m)); srcs_str = [sprintf('%s, ',src_str{srcs(1:end-1)}),sprintf('%s',src_str{srcs(end)})];
% Loop over all unique sources, taking mean of each source by wl
% Plotting each in a different color.


% Fit best AOD and plot in black dots every 10 nm.
% Save best fit AOD
plot(ttau.nm(these_m), ttau.aod(these_m),'*'); logx; logy; 
title({datestr(ttau.time(this_i),'yyyy-mm-dd HH:MM');[sprintf('airmass = %2.2f',mean(ttau.airmass(these_m))),': ',srcs_str]});
this_i = find(these_m, 1,'last')+1;




end