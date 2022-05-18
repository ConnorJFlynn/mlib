

co2_nadir =  rd_lblrtm_tape12_od;
ch4_nadir =  rd_lblrtm_tape12_od;
h2o_nadir =  rd_lblrtm_tape12_od;

% Compute Rayleigh, scale to match ch4
ray = rayleigh_ht(ch4_nadir.nm./1000, 1013.25);
r_ = ch4_nadir.v>6310 & ch4_nadir.v<6335;
ray_f = 0.9999.*mean(ch4_nadir.od(r_)./ray(r_));
figure; plot(h2o_nadir.v, h2o_nadir.od, '-' ,co2_nadir.v, co2_nadir.od, '-',ch4_nadir.v, ch4_nadir.od, 'm-',ch4_nadir.v, ray_f.*ray,'r-'); logy; legend('h_2o','co_2','ch_4','ray')
co2_nadir.agod = co2_nadir.od-ray_f.*ray;
ch4_nadir.agod = ch4_nadir.od-ray_f.*ray;
h2o_nadir.agod = h2o_nadir.od-ray_f.*ray;
figure; plot(h2o_nadir.nm, h2o_nadir.agod, '-' ,co2_nadir.nm, co2_nadir.agod, '-',ch4_nadir.nm, ch4_nadir.agod, 'm-'); logy; legend('h_2o','co_2','ch_4','ray')

intora = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_a.mat'])
figure; plot(1e7./intora.nm , intora.filts(:,1),'k-');
intorb = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_b.mat'])
figure; plot(1e7./intorb.nm , intorb.filts,'k-');
intorb.v = 1e7./intorb.nm;

intorc = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_c.mat'])
figure; plot(1e7./intorc.nm , intorc.filts,'k-');
intorc.v = 1e7./intorc.nm;

intord = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_d.mat'])
figure; plot(1e7./intord.nm , intord.filts,'k-');
intord.v = 1e7./intord.nm;


figure; plot(co2_nadir.nm, co2_nadir.agod,'r-')

v_mfr = ch4_nadir.v>6050 & ch4_nadir.v<6300;

    fa = 4;  fb = 10; fc = 6; fd = 12;
    cm = 1;
    ch4_agod = []; co2_agod = []; h2o_agod = []; h2o_agod_cm = [];
    for am = [10:-1:1]
        for f = [fd:-1:1]
            filt = interp1(intord.v, intord.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa+fb+fc + f,am) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa+fb+fc + f,am) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa+fb+fc + f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa+fb+fc + f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f = 1:fc
            filt = interp1(intorc.v, intorc.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa + fb + f,am) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa + fb + f,am) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa + fb + f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa + fb + f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f =  1:fb
            filt = interp1(intorb.v, intorb.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(fa +f,am) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(fa +f,am) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(fa +f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(fa +f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
        for f = 1:fa
            filt = interp1(intora.v, intora.filts(:,f), ch4_nadir.v,'linear');
            filt(isnan(filt)) = 0;
            filt = filt ./ trapz(ch4_nadir.v(v_mfr), filt(v_mfr));
            ch4_agod(f,am) = -log(trapz(ch4_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*ch4_nadir.agod(v_mfr))))./am;
            co2_agod(f,am) = -log(trapz(co2_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*co2_nadir.agod(v_mfr))))./am;
            h2o_agod(f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*h2o_nadir.agod(v_mfr))))./am;
            h2o_agod_cm(f,am) = -log(trapz(h2o_nadir.v(v_mfr), filt(v_mfr).*exp(-am.*(cm./5).*h2o_nadir.agod(v_mfr))))./am;
        end
    end



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

filt_a1_joe = interp1(intora.v, intora.filts(:,1), ch4(:,1),'linear');
filt_a1_joe(isnan(filt_a1_joe)) = 0;
filt_a1_joe = filt_a1_joe ./ trapz(ch4(v_,1), filt_a1_joe(v_));
trapz(ch4(v_,1), filt_a1_joe(v_))
trapz(co2(v_,1), co2(v_,2).*filt_a1_joe(v_))

filt = interp1(intora.v, intora.filts(:,1), ch4_nadir.v,'linear');
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