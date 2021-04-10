function  mplpol = assess_ap(mplpol, inarg);
% mplpol = assess_ap(mplpol);

% Query whether to assess AP or not.
% If yes, then zoom into a regions assumed to be blocked.
% Compute the averaged afterpulse
% Compare to existing or selected AP
% Choose whether to use the existing or new AP profile.
pos_range = mod(mplpol.range,mplpol.statics.max_alt);
r.bg = (pos_range>=40)&(pos_range<58);
cop_bg = mean(mplpol.rawcts_copol(r.bg,:));
ap_fig = figure_(18);
cop_minus_bg = mplpol.rawcts_copol-ones(size(mplpol.range))*cop_bg;
imagegap(serial2hs(mplpol.time), mplpol.range(mplpol.r.lte_15), real(log10(cop_minus_bg(mplpol.r.lte_15,:))));
colorbar
yes = logical(menu('Assess afterpulse from blocked beam?','No','Yes')-1); pause(0.1);
if yes
    menu({['Zoom into a region deemed blocked by cloud.'];['When finished, select DONE.']},'DONE');
    xl = xlim; yl = ylim;
    xl_ = serial2hs(mplpol.time)>=xl(1)&serial2hs(mplpol.time)<=xl(2);
    yl_ = mplpol.range>yl(1)&mplpol.range<yl(2);
    ap.range = mplpol.range;
    
    
    ap_sum = sum(cop_minus_bg(yl_,xl_));
    figure; plot(serial2hs(mplpol.time(xl_)), ap_sum,'-o')
    xl_ij = find(xl_);
    [ap_sum_, ij] = sort(ap_sum);
    figure_(19);
    plot([1:length(xl_ij)],ap_sum(ij),'o');
    menu('Zoom in or pan to exclude indices from afterpulse computation','OK, done');
    xl = xlim; ij_i =max([1,ceil(xl(1))]); ij_j = min([length(xl_ij),floor(xl(2))]);
    new_ap = mean(cop_minus_bg(:,xl_ij(ij_i:ij_j)),2);
    % new_ap = new_ap + abs(min(new_ap));
    done = false;
    fit_xl = [2.5,15];
    
    while ~done
        fit_range = mplpol.range>=fit_xl(1)&mplpol.range<=fit_xl(2)&new_ap>0;
        lte_fit = pos_range>0 & pos_range<=fit_xl(1);
        
        x_range = pos_range>1&pos_range<mplpol.statics.max_alt;
        log_r = log10(mplpol.range(fit_range));
        log_new_cop = log10(new_ap(fit_range));
        %    log_crs = log10(mplpol.ap.crosspol(fit_range));
        [P,S] = polyfit(log_r, log_new_cop,1);
        cop_fit = 10.^(polyval(P,log10(pos_range),S));
        %    [Px,Sx] = polyfit(log_r, log_crs,1);
        %    crs_fit = 10.^(polyval(Px,log10(pos_range),Sx));
        
        new_ap_copol = cop_fit;
        new_ap_copol(lte_fit) = interp1(mplpol.range, new_ap,pos_range(lte_fit),'linear');
        
        crs_bg = mean(mplpol.rawcts_crosspol(r.bg,:));
        crs_minus_bg = mplpol.rawcts_crosspol-ones(size(mplpol.range))*crs_bg;
        new_crs =mean(crs_minus_bg(:,xl_ij(ij_i:ij_j)),2);
        fit_range = mplpol.range>=fit_xl(1)&mplpol.range<=fit_xl(2)&new_crs>0;
        lte_fit = pos_range>0 & pos_range<=fit_xl(1);
        x_range = pos_range>1&pos_range<mplpol.statics.max_alt;
        log_r = log10(mplpol.range(fit_range));
        log_new_crs = log10(new_crs(fit_range));
        %    log_crs = log10(mplpol.ap.crosspol(fit_range));
        [Px,Sx] = polyfit(log_r, log_new_crs,1);
        crs_fit = 10.^(polyval(Px,log10(pos_range),Sx));
        %    [Px,Sx] = polyfit(log_r, log_crs,1);
        %    crs_fit = 10.^(polyval(Px,log10(pos_range),Sx));
        
        new_ap_crosspol = crs_fit;
        new_ap_crosspol(lte_fit) = interp1(mplpol.range, new_crs,pos_range(lte_fit),'linear');
        
        figure_;
        plot( mplpol.range, new_ap,'-',mplpol.range, new_crs,'-',...
            mplpol.range, new_ap_copol,'-',mplpol.range, new_ap_crosspol,'-',...
            mplpol.range(fit_range),new_ap(fit_range),'.',mplpol.range(fit_range),new_crs(fit_range),'.'); logy;
        legend('copol ap in file','crspol ap in file','fitted copol','fitted crspol');
        adjust_fit = menu('Adjust fit range?','No','Yes');
        if adjust_fit>1
            menu('Zoom into x-axis to define lower and upper limit of fit range','OK, done');
            fit_xl = xlim;
        else
            done = true;
        end
    end
    if logical(menu('Use these afterpulse values?','No', 'Yes')-1); pause(0.1);
        % pass these values out in this MPLPOL struct, and also save to a mat
        % file for later selection.
        ap.time = mean(mplpol.time(xl_ij(ij(1:floor(length(xl_ij)./4)))));
        ap.range = mplpol.range;
        ap.cop_ap = new_ap;
        ap.crs_ap = new_crs;
        ap.cop_ap_fit = new_ap_copol;
        ap.crs_ap_fit = new_ap_crosspol;
        mplpol.r.ap_copol = ap.cop_ap_fit;
        mplpol.r.ap_crosspol = ap.crs_ap_fit;
        pname = [fileparts(which('assess_ap')),filesep];
        fname = [inarg.tla, '.', datestr(ap.time(1),'yyyymmdd.HHMMSS'),'.ap.mat'];
        %       fname = ['nsaC1.', datestr(ap.time(1),'yyyymmdd.HHMMSS'),'.ap.mat'];
        save([pname, fname],'-struct','ap');
        
        
    end;
    
else
    close(ap_fig);
end

return



