% Implementation of Zong stray light correction method using numerous laser
% line measurements with SAS VIS spectrometer SN '0911137U1'
% I have not attempted to smooth the wavelength response to account for
% wavelength dependence. I just use the nearest measured wavelength 

% First, read all the laser tests and compute normalized signal nsig

% 405 nm
stray_405_vis = SAS_read_Albert_csv;
stray_405_vis.nsig = stray_405_vis.sig./max(stray_405_vis.sig);

    figure; plot(stray_405_vis.nm, stray_405_vis.sig./max(stray_405_vis.sig),'-k');legend('405 nm')
    title('405 stray vis')
stray_405_nir = SAS_read_Albert_csv;

close(gcf)
stray_450_vis = SAS_read_Albert_csv;
    title('450 stray vis')
    stray_450_vis.nsig = stray_450_vis.sig./max(stray_450_vis.sig);
stray_450_nir = SAS_read_Albert_csv;
figure; plot(stray_450_vis.nm, stray_450_vis.sig./max(stray_450_vis.sig),'-k');legend('450 nm')
    title('450 stray vis')

close(gcf)
stray_520_vis = SAS_read_Albert_csv;
stray_520_vis.nsig = stray_520_vis.sig./max(stray_520_vis.sig);
figure; plot(stray_520_vis.nm, stray_520_vis.sig./max(stray_520_vis.sig),'-k');legend('520 nm')
    title('520 stray vis')
stray_520_nir = SAS_read_Albert_csv;


close(gcf)
stray_635_vis = SAS_read_Albert_csv;
stray_635_vis.nsig = stray_635_vis.sig./max(stray_635_vis.sig);    
figure; plot(stray_635_vis.nm, stray_635_vis.nsig,'-k');legend('635 nm')
title('635 stray vis')
stray_635_nir = SAS_read_Albert_csv;


close(gcf)
stray_650_vis = SAS_read_Albert_csv;
stray_650_vis.nsig = stray_650_vis.sig./max(stray_650_vis.sig);
figure; plot(stray_650_vis.nm, stray_650_vis.nsig,'-k');legend('650 nm')
    title('650 stray vis')
stray_650_nir = SAS_read_Albert_csv;


close(gcf)
stray_778_vis = SAS_read_Albert_csv;
stray_778_vis.nsig = stray_778_vis.sig./max(stray_778_vis.sig);
figure; plot(stray_778_vis.nm, stray_778_vis.nsig,'-k');legend('778 nm')
    title('778 stray vis')
stray_778_nir = SAS_read_Albert_csv;


close(gcf)
stray_850_vis = SAS_read_Albert_csv;
stray_850_vis.nsig = stray_850_vis.sig./max(stray_850_vis.sig);
figure; plot(stray_850_vis.nm, stray_850_vis.nsig,'-k');legend('850 nm')
    title('850 stray vis')
    title('850 stray vis')
stray_850_nir = SAS_read_Albert_csv;


close(gcf)
stray_980_vis = SAS_read_Albert_csv;
stray_980_vis.nsig = stray_980_vis.sig./max(stray_980_vis.sig);
figure; plot(stray_980_vis.nm, stray_980_vis.nsig,'-k');legend('980 nm');
    title('980 stray vis');
    
stray_980_nir = SAS_read_Albert_csv;
stray_980_nir.nsig = stray_980_nir.sig./max(stray_980_nir.sig);
figure; plot(stray_980_nir.nm, stray_980_nir.nsig,'x-k');legend('980 nm');
    title('980 stray nir');

% Next, compute CWL of each laser  line in the reported spectrometer pixel space 
%     ij = [1:2048];
%     trapz(ij(nm_), stray_405_vis.nsig(nm_).*ij(nm_))./trapz(ij(nm_), stray_405_vis.nsig(nm_));
    stray_vis.nm = stray_405_vis.nm;
nm_ = stray_405_vis.nsig>= 0.1;    
    stray_vis.cwl(1) = trapz(stray_405_vis.nm(nm_), stray_405_vis.nsig(nm_).*stray_405_vis.nm(nm_))./trapz(stray_405_vis.nm(nm_), stray_405_vis.nsig(nm_));
nm_ = stray_450_vis.nsig>= 0.1;
    stray_vis.cwl(2) = trapz(stray_450_vis.nm(nm_), stray_450_vis.nsig(nm_).*stray_450_vis.nm(nm_))./trapz(stray_450_vis.nm(nm_), stray_450_vis.nsig(nm_));
nm_ = stray_520_vis.nsig>= 0.1;
    stray_vis.cwl(3) = trapz(stray_520_vis.nm(nm_), stray_520_vis.nsig(nm_).*stray_520_vis.nm(nm_))./trapz(stray_520_vis.nm(nm_), stray_520_vis.nsig(nm_));
nm_ = stray_635_vis.nsig>= 0.1;
    stray_vis.cwl(4) = trapz(stray_635_vis.nm(nm_), stray_635_vis.nsig(nm_).*stray_635_vis.nm(nm_))./trapz(stray_635_vis.nm(nm_), stray_635_vis.nsig(nm_));
nm_ = stray_650_vis.nsig>= 0.1;
    stray_vis.cwl(5) = trapz(stray_650_vis.nm(nm_), stray_650_vis.nsig(nm_).*stray_650_vis.nm(nm_))./trapz(stray_650_vis.nm(nm_), stray_650_vis.nsig(nm_));
nm_ = stray_778_vis.nsig>= 0.1;
    stray_vis.cwl(6) = trapz(stray_778_vis.nm(nm_), stray_778_vis.nsig(nm_).*stray_778_vis.nm(nm_))./trapz(stray_778_vis.nm(nm_), stray_778_vis.nsig(nm_));
nm_ = stray_850_vis.nsig>= 0.1;
    stray_vis.cwl(7) = trapz(stray_850_vis.nm(nm_), stray_850_vis.nsig(nm_).*stray_850_vis.nm(nm_))./trapz(stray_850_vis.nm(nm_), stray_850_vis.nsig(nm_));
nm_ = stray_980_vis.nsig>= 0.1;
    stray_vis.cwl(8) = trapz(stray_980_vis.nm(nm_), stray_980_vis.nsig(nm_).*stray_980_vis.nm(nm_))./trapz(stray_980_vis.nm(nm_), stray_980_vis.nsig(nm_));

    stray_vis.cwl = stray_vis.cwl';
    
    stray_vis.f_meas(1,:) = stray_405_vis.nsig;
    stray_vis.f_meas(2,:) = stray_450_vis.nsig;
    stray_vis.f_meas(3,:) = stray_520_vis.nsig;
    stray_vis.f_meas(4,:) = stray_635_vis.nsig;
    stray_vis.f_meas(5,:) = stray_650_vis.nsig;
    stray_vis.f_meas(6,:) = stray_778_vis.nsig;
    stray_vis.f_meas(7,:) = stray_850_vis.nsig;
    stray_vis.f_meas(8,:) = stray_980_vis.nsig;
    
    % restrict to pixels within reasonable wavelength response
    stray_vis.dij = stray_vis.f_meas./(sum(stray_vis.f_meas,2)*ones(1,size(stray_vis.f_meas,2)));
    oor = stray_vis.nm<=300 | stray_vis.nm>=1100;
    stray_vis.dij(:,oor) = 0;

    % Mask out the peak including asymmetric thresholds
    % Not sure if it still makes sense to mask out points that are "far" away
    % I think the oor limit above is good enough
    for i = 1:8
         stray_vis.dij(i,stray_vis.f_meas(i,:)>1e-2 & stray_vis.nm>=stray_vis.cwl(i)) = 0;
         stray_vis.dij(i,stray_vis.f_meas(i,:)>3e-2 & stray_vis.nm<=stray_vis.cwl(i)) = 0;
%          far = (stray_vis.nm-stray_vis.cwl(i))>500;
%          stray_vis.dij(i,far) = 0;
        stray_vis.dnm(i,:) =  stray_vis.nm- stray_vis.cwl(i);
    end
    pixel_interval = round(interp1(stray_vis.nm, [1:2048], [300,1100],'linear'));
    nm = stray_vis.nm(pixel_interval(1):pixel_interval(2));
    pixels = [pixel_interval(1):pixel_interval(2)];
    
    % for each pixel find the laser line test nearest in wavelenth and 
    % use that line shape centered on the given pixel.
    stray_vis.d_ij_nearest = zeros([2048,1600]);
    for pix = 1:1600
        cwl_i = interp1(stray_vis.cwl, [1:8],stray_vis.nm(pix),'nearest','extrap');
        dnm = stray_vis.nm - stray_vis.nm(pix);
        stray_vis.d_ij_nearest(:,pix) = interp1(stray_vis.dnm(cwl_i,:),stray_vis.dij(cwl_i,:),dnm,'nearest','extrap');
    end
    stray_vis.SN = '0911137U1';
    stray_vis.pixels = pixels;
    
% Pick out the square subset, and compute the correction as C_stray
% Multiply this matrix by column-vectors of signal spectra to correct
D_stray = stray_vis.d_ij_nearest(pixels, pixels);
A_stray = (eye(size(D_stray))+D_stray);
C_stray = A_stray^(-1);
stray_vis.nm_box = stray_vis.nm(pixels);
stray_vis.D_stray = D_stray;
stray_vis.A_stray = A_stray;
stray_vis.C_stray = C_stray;
pname = ['E:\case_studies\SAS\testing_and_characterization\2016_10_SAS Internal Scatter Data\'];
save([pname, 'vis_Zong_stray_correction_0911137U1.mat'],'-struct','stray_vis')


vis_OG550 = rd_SAS_raw;
