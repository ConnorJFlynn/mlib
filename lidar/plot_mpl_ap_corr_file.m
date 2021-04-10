function plot_mpl_ap_corr_file
ap_file = getfullname('*afterpulse','ap_path','Select MPL afterpulse file');
fid = fopen(ap_file,'r');
if fid>0
    [~, ap_file] = fileparts(ap_file);
    [ap.site, date_str] = strtok(ap_file,'_'); ap.date_str = date_str(2:end);
    ap.time = datenum(ap.date_str,'yyyymmdd');
    [~] = fgetl(fid);
    N = 0;
    while ~feof(fid)
        N = N+1;
        [~] = fgetl(fid);
    end       
    fseek(fid,0,-1);
    [~] = fgetl(fid);
    ap.range = NaN(size(N,1));
    ap.cop = ap.range; ap.crs = ap.range;
    M = 0;
    while ~feof(fid)
        C = textscan(fgetl(fid),'%f %f %f %*[^\n]');
        M = M+1;
        ap.range(M) = C{1};
        ap.cop(M) = C{2};
        ap.crs(M) = C{3};
    end
    fclose(fid);

%     ap.range = C{1}; ap.cop = C{2}; ap.crs = C{3};
    figure; plot(ap.range, ap.cop, '-', ap.range, ap.crs, '-');
    logy; legend('copol ap','crspol ap');
    xlabel('range [km]'); ylabel('MHz');
    tl = title({ap.site; datestr(ap.time, 'yyyy-mm-dd')});set(tl,'interp','none')
end
return