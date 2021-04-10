function ASR_2017_MAO_compares
% MAO 2015 after NOAA provided dilution info for the broken unit.
% Compare March 2015 after NOAA provided new dilution info

% First year, 2014

maopsap1mM1_orig = anc_bundle_files;
[pname, fname,~] = fileparts(maopsap1mM1_orig.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '.mat'],'-struct','maopsap1mM1_orig')

maopsap1mM1_dmf = anc_bundle_files;
[pname, fname,~] = fileparts(maopsap1mM1_dmf.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '.mat'],'-struct','maopsap1mM1_dmf')

maopsap1mM1 = anc_bundle_files;
[pname, fname,~] = fileparts(maopsap1mM1.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '2014.mat'],'-struct','maopsap1mM1')

maopsap1mS1 = anc_bundle_files;
[pname, fname,~] = fileparts(maopsap1mS1.fname); pname= [pname, filesep]; fname = strtok(fname,'.');
save([pname, fname, '2014.mat'],'-struct','maopsap1mS1')

M1_RGB = maopsap1mM1.vdata.qc_Ba_R_raw==0 & maopsap1mM1.vdata.qc_Ba_G_raw==0 & maopsap1mM1.vdata.qc_Ba_B_raw==0;
M1_RGB = M1_RGB & maopsap1mM1.vdata.Ba_R_raw<200 & maopsap1mM1.vdata.Ba_G_raw<200 & maopsap1mM1.vdata.Ba_B_raw<200;
M1_RGB = M1_RGB & maopsap1mM1.vdata.Ba_R_raw>-100 & maopsap1mM1.vdata.Ba_G_raw>-100 & maopsap1mM1.vdata.Ba_B_raw>-100;
M1_good = M1_RGB & ...
   maopsap1mM1.vdata.qc_sample_flow_rate==0 & ...
   maopsap1mM1.vdata.qc_sample_volume==0 & ...
   maopsap1mM1.vdata.qc_transmittance_green==0;
M1_1um = anc_sift(maopsap1mM1, M1_good & maopsap1mM1.vdata.impactor_state==1);
M1_10um = anc_sift(maopsap1mM1, M1_good & maopsap1mM1.vdata.impactor_state==10);

S1_RGB = maopsap1mS1.vdata.qc_Ba_R_raw==0 & maopsap1mS1.vdata.qc_Ba_G_raw==0 & maopsap1mS1.vdata.qc_Ba_B_raw==0;
S1_RGB = S1_RGB & maopsap1mS1.vdata.Ba_R_raw<200 & maopsap1mS1.vdata.Ba_G_raw<200 & maopsap1mS1.vdata.Ba_B_raw<200;
S1_RGB = S1_RGB & maopsap1mS1.vdata.Ba_R_raw>-100 & maopsap1mS1.vdata.Ba_G_raw>-100 & maopsap1mS1.vdata.Ba_B_raw>-100;
S1_good = S1_RGB & ...
   maopsap1mS1.vdata.qc_sample_flow_rate==0 & ...
   maopsap1mS1.vdata.qc_sample_volume==0 & ...
   maopsap1mS1.vdata.qc_transmittance_green==0;

S1_1um = anc_sift(maopsap1mS1, S1_good & maopsap1mS1.vdata.impactor_state==1);
S1_10um = anc_sift(maopsap1mS1, S1_good & maopsap1mS1.vdata.impactor_state==10);

[mins, sinm] = nearest(M1_1um.time, S1_1um.time);
[MinS, SinM] = nearest(M1_10um.time, S1_10um.time);

figure; plot(M1_1um.vdata.Ba_G_raw(mins), S1_1um.vdata.Ba_G_raw(sinm),'o'); v = axis;
hold('on'); plot( [0 max(v)], [0 max(v)],'r--');

figure;scatter(M1_1um.vdata.Ba_G_Weiss(mins), S1_1um.vdata.Ba_G_Weiss(sinm),9,serial2doys(M1_1um.time(mins))); v = axis;
hold('on'); plot( [0 max(v)], [0 max(v)],'r--');
xlabel('AMF M1'); ylabel('MAO S1')



figure; plot(M1_1um.time(mins), M1_1um.vdata.Ba_B_Weiss(mins), 'k.',S1_1um.time(sinm), S1_1um.vdata.Ba_B_Weiss(sinm), 'go'); dynamicDateTicks;
legend('M1 1um','S1 1um');ss(1) = gca;
figure; plot(M1_10um.time(MinS), M1_10um.vdata.Ba_B_Weiss(MinS), 'k.',S1_10um.time(SinM), S1_10um.vdata.Ba_B_Weiss(SinM), 'go'); dynamicDateTicks;
legend('M1 10um','S1 10um');ss(2) = gca;
linkaxes(ss,'xy');

xl = xlim;
figure; 

plot(M1_10um.time(MinS), M1_10um.vdata.Ba_B_Weiss(MinS), 'k*',...
   S1_10um.time(SinM), S1_10um.vdata.Ba_B_Weiss(SinM), 'o',...
   M1_1um.time(mins), M1_1um.vdata.Ba_B_Weiss(mins), 'x',...
   S1_1um.time(sinm), S1_1um.vdata.Ba_B_Weiss(sinm), 'g+'); dynamicDateTicks;
legend('M1 10um','S1 10um','M1 1um','S1 1um');
title({'PSAP "Green" Absorption from Co-deployed AOS suites at Brazil AMF 2014';'(Only coincident measurements passing all QC tests are shown)'})
xlabel('time'); ylabel('1/Mm')



xl_ = M1_1um.time(mins)>=xl(1) & M1_1um.time(mins)<=xl(2);
Xl_ = M1_10um.time(MinS)>=xl(1) & M1_10um.time(MinS)<=xl(2);
dates = M1_1um.time(mins(xl_)); dates = [min(dates), max(dates)];
dstr = [datestr(dates(1),'mmm'),'-' datestr(dates(2),'mmm'),' 2014'];
xr =  M1_1um.vdata.Ba_R_Weiss(mins(xl_)); yr = S1_1um.vdata.Ba_R_Weiss(sinm(xl_));
xg =  M1_1um.vdata.Ba_G_Weiss(mins(xl_)); yg = S1_1um.vdata.Ba_G_Weiss(sinm(xl_));
xb =  M1_1um.vdata.Ba_B_Weiss(mins(xl_)); yb = S1_1um.vdata.Ba_B_Weiss(sinm(xl_));
biasr = mean(xr-yr);biasg = mean(xg-yg);biasb = mean(xb-yb);
maxd = 1.1.*max(max(xb), max(yb));
[Pr,Sr] = polyfit(xr, yr,1);[Pg,Sg] = polyfit(xg, yg,1);[Pb,Sb] = polyfit(xb, yb,1);
[Pr_,Sr_] = polyfit(yr, xr,1);[Pg_,Sg_] = polyfit(yg, xg,1);[Pb_,Sb_] = polyfit(yb, xb,1);
Pr_bar(1) = (Pr(1) + 1./Pr_(1))./2;Pr_bar(2) = (Pr(2) - Pr_(2))./2;
Pg_bar(1) = (Pg(1) + 1./Pg_(1))./2;Pg_bar(2) = (Pg(2) - Pg_(2))./2;
Pb_bar(1) = (Pb(1) + 1./Pb_(1))./2;Pb_bar(2) = (Pb(2) - Pb_(2))./2;
statsrr = fit_stat(xr, yr, Pr_bar,Sr);statsrg = fit_stat(xg, yg, Pg_bar,Sg);statsrb = fit_stat(xb, yb, Pb_bar,Sb);
figure; plot(xb, yb,'*',xg, yg,'o',xr, yr,'x', [0,maxd],[0,maxd],'k--', ...
   [0,maxd],polyval(Pr_bar,[0,maxd]),'r-',[0,maxd],polyval(Pg_bar,[0,maxd]),'g-',...
   [0,maxd],polyval(Pb_bar,[0,maxd]),'b-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['B_a (Red) slope = ',sprintf('%1.4f',Pr_bar(1))], ...
    ['B_a (Grn) slope = ',sprintf('%1.4f',Pg_bar(1))], ...
    ['B_a (Blu) slope = ',sprintf('%1.4f',Pb_bar(1))], ...
    ['N pts= ', num2str(statsrr.N)],...
   };
xlabel('B_a_b_s [1/Mm] MAO M1 (NOAA)'); ylabel('B_a_b_s [1/Mm] MAO S1 (DOE)'); 
title({'Absorption Coefficients, 1 um impactor';['Brazil, AMF1: ',dstr]}); 
gt = gtext(txt); set(gt,'backgroundColor','w','units','norm');

Xr =  M1_10um.vdata.Ba_R_Weiss(MinS(Xl_)); Yr = S1_10um.vdata.Ba_R_Weiss(SinM(Xl_));
Xg =  M1_10um.vdata.Ba_G_Weiss(MinS(Xl_)); Yg = S1_10um.vdata.Ba_G_Weiss(SinM(Xl_));
Xb =  M1_10um.vdata.Ba_B_Weiss(MinS(Xl_)); Yb = S1_10um.vdata.Ba_B_Weiss(SinM(Xl_));
biasr = mean(Xr-Yr);biasg = mean(Xg-Yg);biasb = mean(Xb-Yb);
maxd = 1.1.*max(max(Xb), max(Yb));
[Pr,Sr] = polyfit(Xr, Yr,1);[Pg,Sg] = polyfit(Xg, Yg,1);[Pb,Sb] = polyfit(Xb, Yb,1);
[Pr_,Sr_] = polyfit(Yr, Xr,1);[Pg_,Sg_] = polyfit(Yg, Xg,1);[Pb_,Sb_] = polyfit(Yb, Xb,1);
Pr_bar(1) = (Pr(1) + 1./Pr_(1))./2;Pr_bar(2) = (Pr(2) - Pr_(2))./2;
Pg_bar(1) = (Pg(1) + 1./Pg_(1))./2;Pg_bar(2) = (Pg(2) - Pg_(2))./2;
Pb_bar(1) = (Pb(1) + 1./Pb_(1))./2;Pb_bar(2) = (Pb(2) - Pb_(2))./2;
statsrr = fit_stat(Xr, Yr, Pr_bar,Sr);statsrg = fit_stat(Xg, Yg, Pg_bar,Sg);statsrb = fit_stat(Xb, Yb, Pb_bar,Sb);
figure; plot(Xb, Yb,'*',Xg, Yg,'o',Xr, Yr,'x', [0,maxd],[0,maxd],'k--', ...
   [0,maxd],polyval(Pr_bar,[0,maxd]),'r-',[0,maxd],polyval(Pg_bar,[0,maxd]),'g-',...
   [0,maxd],polyval(Pb_bar,[0,maxd]),'b-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['B_a (Red) slope = ',sprintf('%1.4f',Pr_bar(1))], ...
    ['B_a (Grn) slope = ',sprintf('%1.4f',Pg_bar(1))], ...
    ['B_a (Blu) slope = ',sprintf('%1.4f',Pb_bar(1))], ...
    ['N pts= ', num2str(statsrr.N)],...
   };
xlabel('B_a_b_s [1/Mm] MAO M1 (NOAA)'); ylabel('B_a_b_s [1/Mm] MAO S1 (DOE)'); 
title({'Absorption Coefficients, 10 um impactor';['Brazil, AMF1: ',dstr]}); 
gt = gtext(txt); set(gt,'backgroundColor','w','units','norm');

v = axis; axis(round(v));

return