% Load 1/cm spectra provided to Joe
co2_410ppm_rod = load(getfullname(['lbl_od*co2*.nadir']));
ch4_1860ppb_rod = load(getfullname(['lbl_od*ch4*.nadir']));
h2o_5cm_rod = load(getfullname(['lbl_od*h2o*.nadir']));
nu = ch4_1860ppb_rod(:,1);
nm = 1e7./nu;
% Compute Rayleigh, scale to that in CH4
rod = rayleigh_ht(nm./1000, 1013.25);
rod_ = nu>6310 & nu<6325;
rod_f = 0.9999.*mean(ch4_1860ppb_rod(rod_,2)./rod(rod_)); % Just a touch less to avoid 0
% figure; plot(nu, ch4_1860ppb_rod(:,2), '-', nu, rod_f.*rod,'r--' ); logy
ch4_sgod = ch4_1860ppb_rod(:,2)-rod_f.*rod; % spectral gas od
co2_sgod = co2_410ppm_rod(:,2)-rod_f.*rod;
h2o_sgod = h2o_5cm_rod(:,2)-rod_f.*rod;

% Load 1e-3/cm spectra from TAPE12 files from Karen
co2_nadir =  rd_lblrtm_tape12_od('TAPE12.co2_nadir');
% A = [co2_nadir.v'; co2_nadir.nm'; co2_nadir.od'];
% fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AER_LNFL_LBLRTM\tape12_files\TAPE12.co2_410ppm_nadir.csv'],'w');
% fprintf(fid,'%s \n','nu,   nm,   CO2_410ppm_OD');
% fprintf(fid,'%5.3f,    %5.5f,   %2.6f \n', A);
% fclose(fid)

ch4_nadir =  rd_lblrtm_tape12_od('TAPE12.ch4_nadir');
% A = [ch4_nadir.v'; ch4_nadir.nm'; ch4_nadir.od'];
% fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AER_LNFL_LBLRTM\tape12_files\TAPE12.ch4_1860ppb_nadir.csv'],'w');
% fprintf(fid,'%s \n','nu,   nm,   CH4_1860ppb_OD');
% fprintf(fid,'%5.3f,    %5.5f,   %2.6f \n', A);
% fclose(fid)

h2o_nadir =  rd_lblrtm_tape12_od('TAPE12.h2o_nadir');
% A = [h2o_nadir.v'; h2o_nadir.nm'; h2o_nadir.od'];
% fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AER_LNFL_LBLRTM\tape12_files\TAPE12.h2o_5cm_nadir.csv'],'w');
% fprintf(fid,'%s \n','nu,   nm,   H2O_5cm_OD');
% fprintf(fid,'%5.3f,    %5.5f,   %2.6f \n', A);
% fclose(fid)
% Compute Rayleigh, scale to match ch4
ray = rayleigh_ht(ch4_nadir.nm./1000, 1013.25);
r_ = ch4_nadir.v>6310 & ch4_nadir.v<6335;
ray_f = 0.9999.*mean(ch4_nadir.od(r_)./ray(r_));
% figure; plot(h2o_nadir.v, h2o_nadir.od, '-' ,co2_nadir.v, co2_nadir.od, '-',ch4_nadir.v, ch4_nadir.od, 'm-',ch4_nadir.v, ray_f.*ray,'r--'); logy; legend('h_2o','co_2','ch_4','ray')
co2_nadir.agod = co2_nadir.od-ray_f.*ray;
ch4_nadir.agod = ch4_nadir.od-ray_f.*ray;
h2o_nadir.agod = h2o_nadir.od-ray_f.*ray;
% figure; plot(h2o_nadir.nm, h2o_nadir.agod, '-' ,co2_nadir.nm, co2_nadir.agod, '-',ch4_nadir.nm, ch4_nadir.agod, 'm-'); logy; legend('h_2o','co_2','ch_4','ray')

intor_a = load(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_a.mat']);
% figure; plot(1e7./intor_a.nm , intor_a.filts,'k-');
intor_a.nu = 1e7./intor_a.nm;

intor_b = load(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_b.mat']);
% figure; plot(1e7./intor_b.nm , intor_b.filts,'k-');
intor_b.nu = 1e7./intor_b.nm;

intor_c = load(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_c.mat']);
% figure; plot(1e7./intor_c.nm , intor_c.filts,'k-');
intor_c.nu = 1e7./intor_c.nm;

intor_d = load(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_d.mat']);
% figure; plot(1e7./intor_d.nm , intor_d.filts,'k-');
intor_d.nu = 1e7./intor_d.nm;

% The two spectral datasets have mismatched ranges, so define subsets of
% each to compare
s1_ = nm>1590 & nm<1630;
s2_ = co2_nadir.nm>1590 & co2_nadir.nm<1630;

trapz(nm(s1_),co2_sgod(s1_))
trapz(co2_nadir.nm(s2_), co2_nadir.agod(s2_))
% They look fine to the 3rd decimal point.
% Define a subset that encompasses all the Intor filter ranges
nu_mfr = nu>6050 & nu<6300;
v_mfr = ch4_nadir.v>6050 & ch4_nadir.v<6300;

    fa = 4;  fb = 10; fc = 6; fd = 12;
    cm = 1;
    ch4_agod = []; co2_agod = []; h2o_agod = []; h2o_agod_cm = [];
    for am = [6:-.5:1]
        for f = [fd:-1:1]
           % First, integrate low-res spectra in tau
            filt = interp1(intor_d.nu, intor_d.filts(:,f), nu,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(nu(nu_mfr), filt(nu_mfr));
            ch4_tau(fa+fb+fc + f) = trapz(nu(nu_mfr), ch4_sgod(nu_mfr).*filt(nu_mfr));
            co2_tau(fa+fb+fc + f) = trapz(nu(nu_mfr), co2_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau(fa+fb+fc + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau_cm(fa+fb+fc + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr)./5);
            % And now low-res in Tr
            ch4_trod(fa+fb+fc + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*ch4_sgod(nu_mfr))))./am;
            co2_trod(fa+fb+fc + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*co2_sgod(nu_mfr))))./am;
            h2o_trod(fa+fb+fc + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr))))./am;
            h2o_trod_cm(fa+fb+fc + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr)./5)))./am;
            % And now the hi-res in Tr

            filt = interp1(intor_d.nu, intor_d.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa+fb+fc + f,2.*am -1) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa+fb+fc + f,2.*am -1) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa+fb+fc + f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa+fb+fc + f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f = 1:fc
           % First, integrate low-res spectra in tau
            filt = interp1(intor_c.nu, intor_c.filts(:,f), nu,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(nu(nu_mfr), filt(nu_mfr));
            ch4_tau(fa+fb + f) = trapz(nu(nu_mfr), ch4_sgod(nu_mfr).*filt(nu_mfr));
            co2_tau(fa+fb + f) = trapz(nu(nu_mfr), co2_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau(fa+fb + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau_cm(fa+fb + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr)./5);
            % And now low-res in Tr
            ch4_trod(fa+fb + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*ch4_sgod(nu_mfr))))./am;
            co2_trod(fa+fb + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*co2_sgod(nu_mfr))))./am;
            h2o_trod(fa+fb + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr))))./am;
            h2o_trod_cm(fa+fb + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr)./5)))./am;
            % And now the hi-res in Tr

            filt = interp1(intor_c.nu, intor_c.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa + fb + f,2.*am -1) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa + fb + f,2.*am -1) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa + fb + f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa + fb + f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f =  1:fb
           % First, integrate low-res spectra in tau
            filt = interp1(intor_b.nu, intor_b.filts(:,f), nu,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(nu(nu_mfr), filt(nu_mfr));
            ch4_tau(fa + f) = trapz(nu(nu_mfr), ch4_sgod(nu_mfr).*filt(nu_mfr));
            co2_tau(fa + f) = trapz(nu(nu_mfr), co2_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau(fa + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau_cm(fa + f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr)./5);
            % And now low-res in Tr
            ch4_trod(fa + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*ch4_sgod(nu_mfr))))./am;
            co2_trod(fa + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*co2_sgod(nu_mfr))))./am;
            h2o_trod(fa + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr))))./am;
            h2o_trod_cm(fa + f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr)./5)))./am;
            % And now the hi-res in Tr

            filt = interp1(intor_b.nu, intor_b.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa +f,2.*am -1) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa +f,2.*am -1) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa +f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa +f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f = 1:fa
           % First, integrate low-res spectra in tau
            filt = interp1(intor_a.nu, intor_a.filts(:,f), nu,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(nu(nu_mfr), filt(nu_mfr));
            ch4_tau( f) = trapz(nu(nu_mfr), ch4_sgod(nu_mfr).*filt(nu_mfr));
            co2_tau( f) = trapz(nu(nu_mfr), co2_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau( f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr));
            h2o_tau_cm( f) = trapz(nu(nu_mfr), h2o_sgod(nu_mfr).*filt(nu_mfr)./5);
            % And now low-res in Tr
            ch4_trod( f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*ch4_sgod(nu_mfr))))./am;
            co2_trod(f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*co2_sgod(nu_mfr))))./am;
            h2o_trod( f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr))))./am;
            h2o_trod_cm( f) = -log(trapz(nu(nu_mfr),filt(nu_mfr).*exp(-am.*h2o_sgod(nu_mfr)./5)))./am;
            % And now the hi-res in Tr

            filt = interp1(intor_a.nu, intor_a.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(f,2.*am -1) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(f,2.*am -1) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(f,2.*am -1) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
    end

% Code below this hasn't been modified for consistency with code above.  
% Might work, but no promises.



ch4_agod_avga = mean(ch4_agod(1:4,:)); ch4_agod_stda = std(ch4_agod(1:4,:));
ch4_agod_avgb = mean(ch4_agod(5:14,:)); ch4_agod_stdb = std(ch4_agod(5:14,:));
ch4_agod_avgc = mean(ch4_agod(15:20,:)); ch4_agod_stdc = std(ch4_agod(15:20,:));
ch4_agod_avgd = mean(ch4_agod(21:32,:)); ch4_agod_stdd = std(ch4_agod(21:32,:));
    
figure;
errorbar([1:10]-.1, ch4_agod_avga, ch4_agod_stda,'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, ch4_agod_avgb, ch4_agod_stdb,'-', 'linewidth',2);
errorbar([1:10]+.05, ch4_agod_avgc, ch4_agod_stdc,'-', 'linewidth',2);
errorbar([1:10]+.1, ch4_agod_avgd, ch4_agod_stdd,'-', 'linewidth',2);
legend('batch a','batch b','batch c','batch d');hold('off')
xlabel('airmass'); ylabel('OD subtr.');
yl = ylim; ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, CH_4 (1860 ppb)','interp','tex')

figure;
errorbar([1:10]-.1, ch4_agod_avga-ch4_agod_avga(1), ch4_agod_stda,'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, ch4_agod_avgb-ch4_agod_avgb(1), ch4_agod_stdb,'-', 'linewidth',2);
errorbar([1:10]+.05, ch4_agod_avgc-ch4_agod_avgc(1), ch4_agod_stdc,'-', 'linewidth',2);
errorbar([1:10]+.1, ch4_agod_avgd-ch4_agod_avgd(1), ch4_agod_stdd,'-', 'linewidth',2);hold('off')
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('minus am=1');
yl = ylim; %ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, CH_4 (1860 ppb)','interp','tex')

figure;
errorbar([1:10]-.1, 100.*(ch4_agod_avga./ch4_agod_avga(1)-1), 100.*ch4_agod_stda./ch4_agod_avga(1),'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, 100.*(ch4_agod_avgb./ch4_agod_avgb(1)-1), 100.*ch4_agod_stdb./ch4_agod_avgb(1),'-', 'linewidth',2);
errorbar([1:10]+.05, 100.*(ch4_agod_avgc./ch4_agod_avgc(1)-1), 100.*ch4_agod_stdc./ch4_agod_avgc(1),'-', 'linewidth',2);
errorbar([1:10]+.1, 100.*(ch4_agod_avgd./ch4_agod_avgd(1)-1), 100.*ch4_agod_stdd./ch4_agod_avgd(1),'-', 'linewidth',2);hold('off')
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('% rel am=1');
yl = ylim; %ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, CH_4 (1860 ppb)','interp','tex')


co2_agod_avga = mean(co2_agod(1:4,:)); co2_agod_stda = std(co2_agod(1:4,:));
co2_agod_avgb = mean(co2_agod(5:14,:)); co2_agod_stdb = std(co2_agod(5:14,:));
co2_agod_avgc = mean(co2_agod(15:20,:)); co2_agod_stdc = std(co2_agod(15:20,:));
co2_agod_avgd = mean(co2_agod(21:32,:)); co2_agod_stdd = std(co2_agod(21:32,:));
figure;
errorbar([1:10]-.1, co2_agod_avga, co2_agod_stda,'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, co2_agod_avgb, co2_agod_stdb,'-', 'linewidth',2);
errorbar([1:10]+.05, co2_agod_avgc, co2_agod_stdc,'-', 'linewidth',2);
errorbar([1:10]+.1, co2_agod_avgd, co2_agod_stdd,'-', 'linewidth',2);
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('OD subtr.');
yl = ylim; ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, CO_2 (410 ppm)','interp','tex')

figure;
errorbar([1:10]-.1, co2_agod_avga-co2_agod_avga(1), co2_agod_stda,'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, co2_agod_avgb-co2_agod_avgb(1), co2_agod_stdb,'-', 'linewidth',2);
errorbar([1:10]+.05, co2_agod_avgc-co2_agod_avgc(1), co2_agod_stdc,'-', 'linewidth',2);
errorbar([1:10]+.1, co2_agod_avgd-co2_agod_avgd(1), co2_agod_stdd,'-', 'linewidth',2);
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('minus am=1');
yl = ylim; 
title('Intor 1625 nm gas corrections, CO_2 (410 ppm)','interp','tex')

figure;
errorbar([1:10]-.1, 100.*(co2_agod_avga./co2_agod_avga(1)-1), co2_agod_stda./co2_agod_avga(1),'-', 'linewidth',2); hold('on');
 errorbar([1:10]-.05, 100.*(co2_agod_avgb./co2_agod_avgb(1)-1), co2_agod_stdb./co2_agod_avgb(1),'-', 'linewidth',2);
errorbar([1:10]+.05, 100.*(co2_agod_avgc./co2_agod_avgc(1)-1), co2_agod_stdc./co2_agod_avgc(1),'-', 'linewidth',2);
errorbar([1:10]+.1, 100.*(co2_agod_avgd./co2_agod_avgd(1)-1), co2_agod_stdd./co2_agod_avgd(1),'-', 'linewidth',2);
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('% rel am=1');
yl = ylim; 
title('Intor 1625 nm gas corrections, CO_2 (410 ppm)','interp','tex')


h2o_agod_avga = mean(h2o_agod(1:4,:)); h2o_agod_stda = std(h2o_agod(1:4,:));
h2o_agod_avgb = mean(h2o_agod(5:14,:)); h2o_agod_stdb = std(h2o_agod(5:14,:));
h2o_agod_avgc = mean(h2o_agod(15:20,:)); h2o_agod_stdc = std(h2o_agod(15:20,:));
h2o_agod_avgd = mean(h2o_agod(21:32,:)); h2o_agod_stdd = std(h2o_agod(21:32,:));
figure;
errorbar([1:10]-.1, h2o_agod_avga, h2o_agod_stda,'-o'); hold('on');
 errorbar([1:10]-.05, h2o_agod_avgb, h2o_agod_stdb,'-x');
errorbar([1:10]+.05, h2o_agod_avgc, h2o_agod_stdc,'-+');
errorbar([1:10]+.1, h2o_agod_avgd, h2o_agod_stdd,'-*');
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('OD subtr.');
yl = ylim; ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, H2O (5 cm)','interp','tex')

figure;
errorbar([1:10]-.1, 100.*(h2o_agod_avga-h2o_agod_avga(1))./h2o_agod_avga(1), h2o_agod_stda./h2o_agod_avga(1),'-o'); hold('on');
 errorbar([1:10]-.05, 100.*(h2o_agod_avgb-h2o_agod_avgb(1))./h2o_agod_avgb(1), h2o_agod_stdb./h2o_agod_avgb(1),'-x');
errorbar([1:10]+.05, 100.*(h2o_agod_avgc-h2o_agod_avgc(1))./h2o_agod_avgc(1), h2o_agod_stdc./h2o_agod_avgc(1),'-+');
errorbar([1:10]+.1, 100.*(h2o_agod_avgd-h2o_agod_avgd(1))./h2o_agod_avgd(1), h2o_agod_stdd./h2o_agod_avgd(1),'-*');
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('minus am=1');
yl = ylim; ;
title('Intor 1625 nm gas corrections, H2O (1 cm)','interp','tex')

h2o_agod_cm_avga = mean(h2o_agod_cm(1:4,:)); h2o_agod_cm_stda = std(h2o_agod_cm(1:4,:));
h2o_agod_cm_avgb = mean(h2o_agod_cm(5:14,:)); h2o_agod_cm_stdb = std(h2o_agod_cm(5:14,:));
h2o_agod_cm_avgc = mean(h2o_agod_cm(15:20,:)); h2o_agod_cm_stdc = std(h2o_agod_cm(15:20,:));
h2o_agod_cm_avgd = mean(h2o_agod_cm(21:32,:)); h2o_agod_cm_stdd = std(h2o_agod_cm(21:32,:));
figure;
errorbar([1:10]-.1, h2o_agod_cm_avga, h2o_agod_cm_stda,'-o'); hold('on');
 errorbar([1:10]-.05, h2o_agod_cm_avgb, h2o_agod_cm_stdb,'-x');
errorbar([1:10]+.05, h2o_agod_cm_avgc, h2o_agod_cm_stdc,'-+');
errorbar([1:10]+.1, h2o_agod_cm_avgd, h2o_agod_cm_stdd,'-*');
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('OD subtr.');
yl = ylim; ylim([0,yl(2)]);
title('Intor 1625 nm gas corrections, H2O (1 cm)','interp','tex')

figure;
errorbar([1:10]-.1, (h2o_agod_cm_avga-h2o_agod_cm_avga(1)), h2o_agod_cm_stda,'-o'); hold('on');
 errorbar([1:10]-.05, (h2o_agod_cm_avgb-h2o_agod_cm_avgb(1)), h2o_agod_cm_stdb,'-x');
errorbar([1:10]+.05, (h2o_agod_cm_avgc-h2o_agod_cm_avgc(1)), h2o_agod_cm_stdc,'-+');
errorbar([1:10]+.1, (h2o_agod_cm_avgd-h2o_agod_cm_avgd(1)), h2o_agod_cm_stdd,'-*');
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('minus am=1');
yl = ylim; ;
title('Intor 1625 nm gas corrections, H2O (1 cm)','interp','tex')



figure;
errorbar([1:10]-.1, 100.*(h2o_agod_cm_avga-h2o_agod_cm_avga(1))./h2o_agod_cm_avga(1), h2o_agod_cm_stda./h2o_agod_cm_avga(1),'-o'); hold('on');
 errorbar([1:10]-.05, 100.*(h2o_agod_cm_avgb-h2o_agod_cm_avgb(1))./h2o_agod_cm_avgb(1), h2o_agod_cm_stdb./h2o_agod_cm_avgb(1),'-x');
errorbar([1:10]+.05, 100.*(h2o_agod_cm_avgc-h2o_agod_cm_avgc(1))./h2o_agod_cm_avgc(1), h2o_agod_cm_stdc./h2o_agod_cm_avgc(1),'-+');
errorbar([1:10]+.1, 100.*(h2o_agod_cm_avgd-h2o_agod_cm_avgd(1))./h2o_agod_cm_avgd(1), h2o_agod_cm_stdd./h2o_agod_cm_avgd(1),'-*');
legend('batch a','batch b','batch c','batch d');
xlabel('airmass'); ylabel('% rel am=1');
yl = ylim; ;
title('Intor 1625 nm gas corrections, H2O (5 cm)','interp','tex')








cim = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\cimel_1640_filter_funtion.txt']);
cim_v = 1e7./cim(:,1);
figure; plot(ch4_nadir.v, ch4_nadir.agod,'-', cim_v, cim(:,2),'c-')
v_cim = ch4_nadir.v>6030 & ch4_nadir.v<6170;
cfilt = interp1(cim_v, cim(:,2), ch4_nadir.v,'linear');
cfilt(isnan(cfilt)) = 0;
cfilt = cfilt ./ trapz(ch4_nadir.v(v_cim), cfilt(v_cim));

for am = [10:-1:1];
    cim_ch4_agod(am) = -log(trapz(ch4_nadir.v(v_cim), cfilt(v_cim).*exp(-am.*ch4_nadir.agod(v_cim))))./am;
    cim_co2_agod(am) = -log(trapz(ch4_nadir.v(v_cim), cfilt(v_cim).*exp(-am.*co2_nadir.agod(v_cim))))./am;
    cim_h2o_agod(am) = -log(trapz(ch4_nadir.v(v_cim), cfilt(v_cim).*exp(-am.*h2o_nadir.agod(v_cim))))./am;
end
cim_ch4_agod;
cim_co2_agod;
cim_h2o_agod;
figure;
sb(1) = subplot(2,1,1);
plot([1:10], [cim_ch4_agod;cim_co2_agod;cim_h2o_agod./12.5],'-'); legend('CH_4','CO_2','H_2O');
title('Cimel gas subtraction with airmass')
sb(2) = subplot(2,1,2);
plot([1:10], [cim_ch4_agod./cim_ch4_agod(1);cim_co2_agod./cim_co2_agod(1);cim_h2o_agod./cim_h2o_agod(1)],'-'); legend('CH_4','CO_2','H_2O');
title('Fractional change with airmass');
xlabel('airmass')
linkaxes(sb,'x')

% Now CO2
figure; plot(co2(:,1), co2(:,2), 'c-');
v_nad = co2_nadir.v>6050 & co2_nadir.v<6300;
v_ = co2(:,1)>6050&co2(:,1)<6300;

filt_a1_joe = interp1(intor_a.v, intor_a.filts(:,1), ch4(:,1),'linear');
filt_a1_joe(isnan(filt_a1_joe)) = 0;
filt_a1_joe = filt_a1_joe ./ trapz(ch4(v_,1), filt_a1_joe(v_));
trapz(ch4(v_,1), filt_a1_joe(v_))
trapz(co2(v_,1), co2(v_,2).*filt_a1_joe(v_))

filt = interp1(intor_a.v, intor_a.filts(:,1), ch4_nadir.v,'linear');
filt(isnan(filt)) = 0;
filt = filt ./ trapz(ch4_nadir.v(v_nad), filt(v_nad));
trapz(ch4_nadir.v(v_nad), filt(v_nad))
trapz(co2_nadir.v(v_nad), co2_nadir.od(v_nad).*filt(v_nad))

%now H2O
trapz(h2o(v_,1), h2o(v_,2).*filt_a1_joe(v_))
trapz(h2o_nadir.v(v_nad), h2o_nadir.od(v_nad).*filt(v_nad))

% Now cimel, and especially cimel with CH4, and airmass dependence


v_ = ch4(:,1)>6030&ch4(:,1)<6300;


figure; plot(ch4_nadir.v, ch4_nadir.agod, '-',ch4_nadir.v, cim_lbl, 'r-'); logy;
cim_lbl = interp1(cim_v, cim(:,2), ch4_nadir.v,'linear');
cim_lbl(isnan(cim_lbl)) = 0;
cim_lbl = cim_lbl ./ trapz(ch4_nadir.v(v_nad), cim_lbl(v_nad));
trapz(ch4_nadir.v(v_nad), cim_lbl(v_nad))
trapz(ch4_nadir.v(v_nad), ch4_nadir.agod(v_nad).*cim_lbl(v_nad))

% Now, represent in Tr, airmass = 1

for am = [10:-1:1]
    cim_ch4(am) = -log(trapz(ch4_nadir.v(v_nad), cim_lbl(v_nad).*exp(-am.*ch4_nadir.agod(v_nad))))./am;
    cim_co2(am) = -log(trapz(co2_nadir.v(v_nad), cim_lbl(v_nad).*exp(-am.*co2_nadir.agod(v_nad))))./am;
    cim_h2o(am) = -log(trapz(h2o_nadir.v(v_nad), cim_lbl(v_nad).*exp(-am.*h2o_nadir.agod(v_nad))))./am;
    cim_h2o_cm(am) = -log(trapz(h2o_nadir.v(v_nad), cim_lbl(v_nad).*exp(-am.*(cm./5).*h2o_nadir.agod(v_nad))))./am;
end

cim_ch4 = cim_ch4./cim_ch4(1); cim_co2 = cim_co2./cim_co2(1); cim_h2o = cim_h2o./cim_h2o(1);cim_h2o_cm;
mean(cim_ch4(1:4))