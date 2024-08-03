if isafile('caps_lasic.mat')
    caps = load('caps_lasic.mat');
else
    
    [caps_num, caps_txt] = xlsread(['C:\case_studies\LASIC_CAPS-PMssa\20200529_LASIC_1min_CAPS_PMssa_data.xlsx']);
    caps.time = datenum(caps_txt(2:end,1), 'mm/dd/yyyy HH:MM:SS AM');
    caps.impactor = caps_num(:,1);
    caps.ext_alt_stp = caps_num(:,17);
    caps.sca_alt_stp = caps_num(:,18);
    caps.ssa_correction = caps_num(:,19);
    caps.sca_alt_stp_fixed = caps_num(:,20);
    caps.Ba_alt_stp_fixed = caps_num(:,21);
    caps_field = fieldnames(caps);
    for ff = 1:length(caps_field)
        caps.(caps_field{ff}) = caps.(caps_field{ff})';
    end
    save('caps_lasic.mat','-struct','caps');
end
cap_pm1 = caps.impactor==1; sum(cap_pm1)
cap_pm10 = caps.impactor==10; sum(cap_pm10)

cap_pm1(1:(end-1)) = cap_pm1(1:(end-1)) & cap_pm1(2:end); sum(cap_pm1)
cap_pm1(2:end) = cap_pm1(1:(end-1)) & cap_pm1(2:end); sum(cap_pm1)

cap_pm10(1:(end-1)) = cap_pm10(1:(end-1)) & cap_pm10(2:end); sum(cap_pm10)
cap_pm10(2:end) = cap_pm10(1:(end-1)) & cap_pm10(2:end); sum(cap_pm10)
figure; plot(serial2doys(caps.time(cap_pm1)), caps.ext_alt_stp(cap_pm1), 'gx',serial2doys(caps.time(cap_pm10)), caps.ext_alt_stp(cap_pm10), 'o'); 
legend('CAPS ext pm1','CAPS ext pm10'); 

% 

% Initially I was thinking to use the observation of supermicron SSA ~1 to
% infer that almost all of the CAPS supermicron extinction was due to
% scattering, so the CAPS ext measurement might yield a lower bound
% scattering to compare the neph against.  However, if memory serves the
% CAPS seems to miss a significant fraction of particles > 1 um so this may
% not be as useful a constraint as I'd hoped.  

% Instead how about we look at Ba_*_Bond, Ba_*_Virk, and then also compute
% Ba values using 1) compute_Virkkula_ext and 2) compute_Virkkula with
% CAPS-Neph, 3) Bond/Weiss with CAPS-Neph, 4) CAPS Ext - Scat

% See if any of these shed additional light

% caps from 2017-08-04 to 2017-09-22
if isafile('b1.mat')
    b1 = load('b1.mat');
else
    b1 = anc_bundle_files; save('b1.mat','-struct','b1');
end
if isafile('aopc1.mat')
    aopc1 = load('aopc1.mat');
else
    aopc1 = anc_bundle_files; save('aopc1.mat','-struct','aopc1');
end

if isafile('b2.mat')
    b2 = load('b2.mat');
else
    b2 = anc_bundle_files; save('b2.mat','-struct','b2');
end
if isafile('aopc2.mat')
    aopc2 = load('aopc2.mat');
else
    aopc2 = anc_bundle_files; save('aopc2.mat','-struct','aopc2');
end
[binc, cinb] = nearest(b1.time, aopc1.time);
b1 = anc_sift(b1, binc); aopc1 = anc_sift(aopc1, cinb);
[binc, cinb] = nearest(b2.time, aopc2.time);

b2 = anc_sift(b2, binc); aopc2 = anc_sift(aopc2, cinb);
[bin2, bin1] = nearest(b1.time, b2.time);
b1 = anc_sift(b1, bin2); b2 = anc_sift(b2, bin1);
aopc1 = anc_sift(aopc1, bin2); aopc2 = anc_sift(aopc2,bin1);

% At this point the b1 and b2 and aopc1 and aopc2 all have matched indices.
% Now sinc psap1m
if isafile('psap1m.mat')
    psap1m = load('psap1m.mat');
else
    psap1m = anc_bundle_files(getfullname('asiaospsap*.nc','psap1m'));
    save('psap1m.mat','-struct','psap1m');
end
[pinb, binp] = nearest(psap1m.time, b1.time);
psap1m = anc_sift(psap1m, pinb); 
b1 = anc_sift(b1, binp); b2 = anc_sift(b2, binp);
aopc1 = anc_sift(aopc1, binp); aopc2 = anc_sift(aopc2, binp);

% Now we match ALL to CAPS

[inC, Cin ] = nearest(psap1m.time, caps.time);
caps.Ba_V_ext = NaN(size(caps.time)); caps.ssa_V_ext = NaN(size(caps.time));
caps.Bs_V_ext = NaN(size(caps.time)); caps.ssa_V_ext = NaN(size(caps.time));
caps.Ba_V_sca = NaN(size(caps.time)); caps.ssa_V_sca = NaN(size(caps.time));
[caps.Ba_V_sca(Cin),~,~,~,~,~,~,caps.ssa_V_sca(Cin)] = Virk_wi_sca(psap1m.vdata.transmittance_green(inC),psap1m.vdata.Ba_G_raw(inC),caps.sca_alt_stp(Cin),2);
[caps.Ba_V_ext(Cin),~,~,~,~,~,~,caps.ssa_V_ext(Cin)] = Virk_wi_ext(psap1m.vdata.transmittance_green(inC),psap1m.vdata.Ba_G_raw(inC),caps.ext_alt_stp(Cin),2);
[caps.Ba_V_ssa(Cin),~,~,~,~,~,~,caps.ext_V_ssa(Cin)] = Virk_wi_ssa(psap1m.vdata.transmittance_green(inC),psap1m.vdata.Ba_G_raw(inC),caps.sca_alt_stp(Cin)./caps.ext_alt_stp(Cin),2);

caps.Bs_V_ext(Cin) = caps.ext_alt_stp(Cin).*(caps.ssa_V_ext(Cin));
caps.impactor = interp1(b1.time, double(b1.vdata.impactor_state), caps.time, 'nearest');

cap_pm1 = caps.impactor==1; sum(cap_pm1)
cap_pm10 = caps.impactor==10; sum(cap_pm10)

cap_pm1(1:(end-1)) = cap_pm1(1:(end-1)) & cap_pm1(2:end); sum(cap_pm1)
cap_pm1(2:end) = cap_pm1(1:(end-1)) & cap_pm1(2:end); sum(cap_pm1)

cap_pm10(1:(end-1)) = cap_pm10(1:(end-1)) & cap_pm10(2:end); sum(cap_pm10)
cap_pm10(2:end) = cap_pm10(1:(end-1)) & cap_pm10(2:end); sum(cap_pm10)

pm1 = zeros(size(caps.impactor)); pm1(~cap_pm1) = NaN;

% Now plot scat from b1, b2, Virk_ext, and caps_sca
miss = b1.vdata.Bs_G_Dry_Neph3W<0 | b2.vdata.Bs_G_Dry_Neph3W < 0 | b1.vdata.impactor_state~=1;
mis = zeros(size(miss)); mis(miss) = NaN;

figure; plot(serial2doys(b1.time(inC)), mis(inC)+b1.vdata.Bs_G_Dry_Neph3W(inC), 'o',serial2doys(b2.time(inC)), mis(inC)+b2.vdata.Bs_G_Dry_Neph3W(inC), 'x',...
serial2doys(caps.time(Cin)), pm1(Cin)+caps.sca_alt_stp(Cin), '+', serial2doys(caps.time(Cin)), pm1(Cin)+caps.Bs_V_ext(Cin),'.');
legend('b1','b2','caps neph','caps Bs from Virk Ext'); 

xxll = xlim;
pm1(serial2doys(caps.time)<xxll(1) | serial2doys(caps.time)>xxll(2)) = NaN;
mis(serial2doys(b1.time)<xxll(1) | serial2doys(b1.time)>xxll(2)) = NaN;
pm1(1:(end-1)) = pm1(1:(end-1)) + pm1(2:end); pm1(2:end) = pm1(1:(end-1)) + pm1(2:end);
mis(1:(end-1)) = mis(1:(end-1)) + mis(2:end); mis(2:end) = mis(1:(end-1)) + mis(2:end);


figure; scatter(mis(inC)+b1.vdata.Bs_G_Dry_Neph3W(inC),pm1(Cin)+caps.Bs_V_ext(Cin), 8);
title('b-level Bs vs CAPS Bs ');
xlabel('NephDry Bs G b1 and b2'); ylabel('CAPS Bs G from Virk SSA'); yl = ylim; yl(1) = 0;
axis('square'); hold('on'); plot(yl, yl, 'k--'); hold('off');
xlim(yl); ylim(yl); 

xl = xlim; 

[binc, cinb] = nearest(aopc1.time, caps.time); 

good = aopc1.vdata.Bs_G(binc)>0 & ~isnan(aopc1.vdata.Bs_G(binc)) & ~isnan(caps.sca_alt_stp(cinb));
good_ii = find(good);
good_1um = good & aopc1.vdata.impactor_state==1;
good_1um(2:end) = good_1um(2:end)&good_1um(1:(end-1));
good_1um(1:end-1) = good_1um(2:end)&good_1um(1:(end-1));
sum(good_1um);
good_10um = good & aopc1.vdata.impactor_state==10;
good_10um(2:end) = good_10um(2:end)&good_10um(1:(end-1));
good_10um(1:end-1) = good_10um(2:end)&good_10um(1:(end-1));
clear good

figure; plot(serial2doy(aopc1.time(binc(good_10um))), aopc1.vdata.Bs_G(binc(good_10um)), '.', ...
serial2doy(aopc2.time(binc(good_10um))), aopc2.vdata.Bs_G(binc(good_10um)), '.', ...
serial2doy(caps.time(cinb(good_10um))), caps.sca_alt_stp(cinb(good_10um)), '.');  zoom('on')
legend('Bs c1','Bs c2','caps sca');

figure; plot(serial2doy(aopc1.time(binc(good_1um))), aopc1.vdata.Bs_G(binc(good_1um)), '.', ...
serial2doy(aopc2.time(binc(good_1um))), aopc2.vdata.Bs_G(binc(good_1um)), '.', ...
serial2doy(caps.time(cinb(good_1um))), caps.sca_alt_stp(cinb(good_1um)), '.');  zoom('on')
legend('Bs c1','Bs c2','caps sca');



xl = xlim; 
xl_ = serial2doy(caps.time(cinb))>xl(1) & serial2doy(caps.time(cinb))<xl(2) ;
[P_bar_c1_1um, c1_stats_1um] = bifit(caps.Bs_V_ext(cinb(xl_&good_1um)),aopc1.vdata.Bs_G(binc(xl_&good_1um)));
[P_bar_c2_1um, c2_stats_1um] = bifit(caps.sca_alt_stp(cinb(xl_&good_1um)),caps.Bs_V_ext(cinb(xl_&good_1um)));

figure; plot(caps.Bs_V_ext(cinb(xl_&good_1um)),aopc1.vdata.Bs_G(binc(xl_&good_1um)), 'o')

figure; plot(serial2doy(aopc1.time(binc(good_10um))), aopc1.vdata.Bs_G(binc(good_10um)), '.', ...
serial2doy(aopc2.time(binc(good_10um))), aopc2.vdata.Bs_G(binc(good_10um)), '.', ...
serial2doy(caps.time(cinb(good_10um))), caps.sca_alt_stp(cinb(good_10um)), '.');  zoom('on')
legend('Bs c1','Bs c2','caps sca 10um');

XY_regression_of_timeseries(gcf)


[P_bar_c1_10um, c1_stats_10um] = bifit(caps.sca_alt_stp(cinb(good_10um)),aopc1.vdata.Bs_G(binc(good_10um)));
[P_bar_c2_10um, c2_stats_10um] = bifit(caps.sca_alt_stp(cinb(good_10um)),aopc2.vdata.Bs_G(binc(good_10um)));


xl = xlim;
xl_ = serial2doy(aopc1.time(binc))> xl(1) & serial2doy(aopc1.time(binc))< xl(2);
xl_ii = find(xl_);

figure; plot(caps.sca_alt_stp(cinb(good_1um&xl_)),aopc1.vdata.Bs_G(binc(good_1um&xl_)),'.',caps.sca_alt_stp(cinb(good_1um&xl_)),aopc2.vdata.Bs_G(binc(good_1um&xl_)),'r.'); 
axis('square'); legend('c1','c2');

yl = ylim; yl(1) = 0; ylim(yl); xlim(yl); 
hold('on'); plot(yl, yl,'k--'); 


% met = anc_bundle_files;
% figure; nomiss = find(met.vdata.pwd_mean_vis_10min>0); plot(serial2doys(met.time(nomiss)), 1e6./double(met.vdata.pwd_mean_vis_10min(nomiss)), '*');
% 

