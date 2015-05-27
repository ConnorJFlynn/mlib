function status = check_mfrsr_b1_to_c1_files;
%%
b1 = ancload(getfullname_('*b1.*cdf','b1'));
[pname,fname,ext] = fileparts(b1.fname);
[~,stem] = strtok([fname,ext],'.');
[~,stem] = strtok(stem,'.');
c1.fname = getfullname_([pname,filesep,fname(1:8),'aod1mich*',stem],'c1');
c1 = ancload(c1.fname)

%%
for filt = [5:-1:1];
    Io(filt) =c1.vars.(['Io_filter',num2str(filt)]).data;
    TOA (filt) = sscanf(c1.atts.(['filter',num2str(filt),'_TOA_direct_normal']).data, '%g');
    nomcal(filt)=b1.vars.(['nominal_calibration_factor_filter',num2str(filt)]).data;
    b1toc1(filt) = nomcal(filt).*TOA(filt)./Io(filt);
end

%%
[pname,fname,ex] = fileparts(c1.fname);
for filt = [5:-1:1];
    dirh = ['direct_horizontal_narrowband_filter',num2str(filt)];
    toth = ['hemisp_narrowband_filter',num2str(filt)];
    dirn = ['direct_normal_narrowband_filter',num2str(filt)];
    difh = ['diffuse_hemisp_narrowband_filter',num2str(filt)];
    clear s
    if isfield(b1.vars,['diffuse_hemisp_narrowband_filter',num2str(filt)])
        miss = b1.vars.(['direct_horizontal_narrowband_filter',num2str(filt)]).data<-9990 ;
        
        figure(1);
        s(1) = subplot(4,1,1);
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(dirh).data(~miss),'go',...
            serial2doy(c1.time(~miss)), c1.vars.(dirh).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        title('');
        legend('b1','c1')
        tl = title({[fname ex];['comparing in ',dirh]});
        set(tl,'interp','none')
        s(2) = subplot(4,1,2);
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(dirn).data(~miss),'go',...
            serial2doy(c1.time(~miss)), c1.vars.(dirn).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        title(['difference in ',(dirn)],'interp','none')
        legend('b1','c1')
        s(3) = subplot(4,1,3);
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(difh).data(~miss),'go',...
            serial2doy(c1.time(~miss)), c1.vars.(difh).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        legend('b1','c1')
        tl = title({[fname ex];['difference in ', difh]});
        set(tl,'interp','none')
        
        s(4) = subplot(4,1,4);
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(toth).data(~miss), 'go',...
            serial2doy(c1.time(~miss)),c1.vars.(toth).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        title(['difference in ',(toth)],'interp','none')
        legend('b1','c1')
        % linkaxes(s,'x');
        
        figure(2);
        s(5) = subplot(4,1,1);
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(dirh).data(~miss)- c1.vars.(dirh).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title('');
        legend('b1','c1')
        tl = title({[fname ex];['difference in ',dirh]});
        set(tl,'interp','none')
        s(5) = subplot(4,1,2);
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(dirn).data(~miss)- c1.vars.(dirn).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title(['difference in ',(dirn)],'interp','none')
        legend('b1','c1')
        s(7) = subplot(4,1,3);
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(difh).data(~miss)- c1.vars.(difh).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title('');
        legend('b1','c1')
        tl = title({[fname ex];['difference in ', difh]});
        set(tl,'interp','none')
        s(8) = subplot(4,1,4);
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(toth).data(~miss)- c1.vars.(toth).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title(['difference in ',(toth)],'interp','none')
        legend('b1','c1')
        linkaxes(s,'x')
        
    else
        miss = b1.vars.direct_horizontal_narrowband_filter1.data<-9990 ;
        figure(1);
        [pname,fname,ex] = fileparts(c1.fname);
        s(1) = subplot(2,1,1);
        irad = 'direct_horizontal_narrowband_filter1';
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(dirh).data(~miss),'go',...
            serial2doy(c1.time(~miss)),c1.vars.(dirh).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        title('');
        legend('b1','c1')
        tl = title({[fname ex];['comparing in ',dirh]});
        set(tl,'interp','none')
        s(2) = subplot(2,1,2);
        plot(serial2doy(c1.time(~miss)), b1toc1(filt).*b1.vars.(dirn).data(~miss),'go',...
            serial2doy(c1.time(~miss)), c1.vars.(dirn).data(~miss),'rx')
        xlabel('time [day of year]');
        ylabel('irad')
        title(['comparing in ',(dirn)],'interp','none')
        legend('b1','c1')
        
        figure(2);
        s(3) = subplot(2,1,1);
        
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(dirh).data(~miss)- c1.vars.(dirh).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title('');
        legend('b1','c1')
        tl = title({[fname ex];['difference in ',dirh]});
        set(tl,'interp','none')
        s(4) = subplot(2,1,2);
        plot(serial2doy(c1.time(~miss)), [b1toc1(filt).*b1.vars.(dirn).data(~miss)- c1.vars.(dirn).data(~miss)],'o')
        xlabel('time [day of year]');
        ylabel('diff(b1-c1)')
        title(['difference in ',(dirn)],'interp','none')
        legend('b1','c1')
        linkaxes(s,'x')
        
    end
    
end
%%
for filt = [5:-1:1];
    dirn = ['direct_normal_narrowband_filter',num2str(filt)];
    tod = ['total_optical_depth_filter',num2str(filt)];
    % This block computes tau from the direct normal and Guey TOA in c1
    dirnor=   (c1.vars.(dirn).data).*(c1.vars.sun_to_earth_distance.data.^2);
    ned = min(length(b1.time),length(c1.time));
    dirnor = dirnor(1:ned);
    tim = c1.time(1:ned);
    
    amass = c1.vars.airmass.data;
    tau = log(TOA(filt) ./ dirnor)./amass(1:ned);
    figure(3);
    ax(1) = subplot(2,1,1);
    plot(serial2Hh(tim),[tau; c1.vars.(tod).data(1:ned)]);
    
    ylim('auto');
    
    title(tod,'interp','none')
    legend('computed','in file')
    ax(2) = subplot(2,1,2);
    plot(serial2Hh(tim),[tau-c1.vars.(tod).data(1:ned)]);
    legend('computed - in file')
    ylim('auto')
    linkaxes(ax,'x');
    xlim([5,18]);
end
%%
%%

