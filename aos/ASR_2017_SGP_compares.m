function ASR_2017_SGP_compares
% Comparing SGP C1 and SGP E13
% MAO 2015 after NOAA provided dilution info for the broken unit.
% Compare March 2015 after NOAA provided new dilution info

% Processing change occurs on Feb 10 09UT.  

psap1m_C1 = anc_bundle_files;
[pname, fname,~] = fileparts(psap1m_C1.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '.mat'],'-struct','psap1m_C1')

psap1mE13 = anc_bundle_files;
[pname, fname,~] = fileparts(psap1mE13.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '.mat'],'-struct','psap1mE13')

C1_RGB = psap1m_C1.vdata.qc_Ba_R_raw==0 & psap1m_C1.vdata.qc_Ba_G_raw==0 & psap1m_C1.vdata.qc_Ba_B_raw==0;
C1_good = C1_RGB & ...
   psap1m_C1.vdata.qc_sample_flow_rate==0 & ...
   psap1m_C1.vdata.qc_sample_volume==0 & ...
   psap1m_C1.vdata.qc_transmittance_green==0;

C1_1um = anc_sift(psap1m_C1, C1_RGB & psap1m_C1.vdata.impactor_state==1);
C1_10um = anc_sift(psap1m_C1, C1_RGB & psap1m_C1.vdata.impactor_state==10);

E13_RGB = psap1mE13.vdata.qc_Ba_R_raw==0 & psap1mE13.vdata.qc_Ba_G_raw==0 & psap1mE13.vdata.qc_Ba_B_raw==0;
E13_good = E13_RGB & ...
   psap1mE13.vdata.qc_sample_flow_rate==0 & ...
   psap1mE13.vdata.qc_sample_volume==0 & ...
   psap1mE13.vdata.qc_transmittance_green==0;

E13_1um = anc_sift(psap1mE13, E13_good & psap1mE13.vdata.impactor_state==1);
E13_10um = anc_sift(psap1mE13, E13_good & psap1mE13.vdata.impactor_state==10);

[cine, einc] = nearest(C1_1um.time, E13_1um.time);
[CinE, EinC] = nearest(C1_10um.time, E13_10um.time);

figure; 

plot(C1_10um.time(CinE), C1_10um.vdata.Ba_G_Weiss(CinE), 'k*',...
   E13_10um.time(EinC), E13_10um.vdata.Ba_G_Weiss(EinC), 'o',...
   C1_1um.time(cine), C1_1um.vdata.Ba_G_Weiss(cine), 'x',...
   E13_1um.time(einc), E13_1um.vdata.Ba_G_Weiss(einc), 'g+'); dynamicDateTicks;
legend('C1 10um','E13 10um','C1 1um','E13 1um');
title({'PSAP "Green" Absorption from Co-deployed AOS suites at Southern Great Plains Nov 2016 - Mar 2017';'(Only coincident measurements passing all QC tests are shown)'})
xlabel('time'); ylabel('1/Mm')



xl = xlim;
xl_ = C1_1um.time(cine)>=xl(1) & C1_1um.time(cine)<=xl(2);
dates = C1_1um.time(cine(xl_)); dates = [min(dates), max(dates)];
dstr = datestr(dates(1),'mmm yyyy');
xr =  C1_1um.vdata.Ba_R_Weiss(cine(xl_)); yr = E13_1um.vdata.Ba_R_Weiss(einc(xl_));
xg =  C1_1um.vdata.Ba_G_Weiss(cine(xl_)); yg = E13_1um.vdata.Ba_G_Weiss(einc(xl_));
xb =  C1_1um.vdata.Ba_B_Weiss(cine(xl_)); yb = E13_1um.vdata.Ba_B_Weiss(einc(xl_));
biasr = mean(xr-yr);biasg = mean(xg-yg);biasb = mean(xb-yb);
maxd = 1.1.*max(max(xb), max(yb));
[Pr,Sr] = polyfit(xr, yr,1);[Pg,Sg] = polyfit(xg, yg,1);[Pb,Sb] = polyfit(xb, yb,1);
[Pr_,Sr_] = polyfit(yr, xr,1);[Pg_,Sg_] = polyfit(yg, xg,1);[Pb_,Sb_] = polyfit(yb, xb,1);
Pr_bar(1) = (Pr(1) + 1./Pr_(1))./2;Pr_bar(2) = (Pr(2) - Pr_(2))./2;
Pg_bar(1) = (Pg(1) + 1./Pg_(1))./2;Pg_bar(2) = (Pg(2) - Pg_(2))./2;
Pb_bar(1) = (Pb(1) + 1./Pb_(1))./2;Pb_bar(2) = (Pb(2) - Pb_(2))./2;
statsrr = fit_stat(xr, yr, Pr_bar,Sr);
statsrg = fit_stat(xg, yg, Pg_bar,Sg);
statsrb = fit_stat(xb, yb, Pb_bar,Sb);
figure; plot(xb, yb,'b*',xg, yg,'go',xr, yr,'rx',[0,maxd],[0,maxd],'k--',...
   [0,maxd],polyval(Pr_bar,[0,maxd]),'r-',[0,maxd],polyval(Pg_bar,[0,maxd]),'g-',...
   [0,maxd],polyval(Pb_bar,[0,maxd]),'b-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['B_a (Red) slope = ',sprintf('%1.4f',Pr_bar(1))], ...
    ['B_a (Grn) slope = ',sprintf('%1.4f',Pg_bar(1))], ...
    ['B_a (Blu) slope = ',sprintf('%1.4f',Pb_bar(1))], ...
    ['N pts= ', num2str(statsrr.N)],...
   };
xlabel('B_a_b_s [1/Mm] SGP C1 (NOAA)'); ylabel('B_a_b_s [1/Mm] SGP E13 (DOE)'); 
title({'Absorption Coefficients, 1 um impactor';['SGP Central Facility: ',dstr]}); 
gt = gtext(txt); set(gt,'backgroundColor','w','units','norm');

% Now look at 10 um
XL_ = C1_10um.time(CinE)>=xl(1) & C1_10um.time(CinE)<=xl(2);

Xr =  C1_10um.vdata.Ba_R_Weiss(CinE(XL_)); Yr = E13_10um.vdata.Ba_R_Weiss(EinC(XL_));
Xg =  C1_10um.vdata.Ba_G_Weiss(CinE(XL_)); Yg = E13_10um.vdata.Ba_G_Weiss(EinC(XL_));
Xb =  C1_10um.vdata.Ba_B_Weiss(CinE(XL_)); Yb = E13_10um.vdata.Ba_B_Weiss(EinC(XL_));
biasr = mean(Xr-Yr);biasg = mean(Xg-Yg);biasb = mean(Xb-Yb);
maxd = 1.1.*max(max(Xb), max(Yb));
[Pr,Sr] = polyfit(Xr, Yr,1);[Pg,Sg] = polyfit(Xg, Yg,1);[Pb,Sb] = polyfit(Xb, Yb,1);
[Pr_,Sr_] = polyfit(Yr, Xr,1);[Pg_,Sg_] = polyfit(Yg, Xg,1);[Pb_,Sb_] = polyfit(Yb, Xb,1);
Pr_bar(1) = (Pr(1) + 1./Pr_(1))./2;Pr_bar(2) = (Pr(2) - Pr_(2))./2;
Pg_bar(1) = (Pg(1) + 1./Pg_(1))./2;Pg_bar(2) = (Pg(2) - Pg_(2))./2;
Pb_bar(1) = (Pb(1) + 1./Pb_(1))./2;Pb_bar(2) = (Pb(2) - Pb_(2))./2;
statsrr = fit_stat(Xr, Yr, Pr_bar,Sr);statsrg = fit_stat(Xg, Yg, Pg_bar,Sg);
statsrb = fit_stat(Xb, Yb, Pb_bar,Sb);
figure; plot(Xb, Yb,'*',Xg, Yg,'o',Xr, Yr,'x', [0,maxd],[0,maxd],'k--', ...
   [0,maxd],polyval(Pr_bar,[0,maxd]),'r-',[0,maxd],polyval(Pg_bar,[0,maxd]),'g-',...
   [0,maxd],polyval(Pb_bar,[0,maxd]),'b-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['B_a (Red) slope = ',sprintf('%1.4f',Pr_bar(1))], ...
   ['B_a (Grn) slope = ',sprintf('%1.4f',Pg_bar(1))], ...
   ['B_a (Blu) slope = ',sprintf('%1.4f',Pb_bar(1))], ...
    ['N pts= ', num2str(statsrr.N)],...
   };
xlabel('B_a_b_s [1/Mm] SGP C1 (NOAA)'); ylabel('B_a_b_s [1/Mm] SGP E13 (DOE)'); 
title({'Absorption Coefficients, 10 um impactor';['SGP Central Facility: ',dstr]}); 

gt = gtext(txt); set(gt,'backgroundColor','w','units','norm');

v = axis; axis(round(v));
return