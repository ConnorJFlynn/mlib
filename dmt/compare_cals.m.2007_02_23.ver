%%

dmt_psl.med.PSL_nm = [173, 222, 258];
dmt_psl.hi.PSL_nm = [451, 870, 2000];
dmt_psl.med.bin = [4295, 5045,6407]
dmt_psl.hi.bin = [8421,8987,10158];
for dd= 1:length(dmt_psl.med.PSL_nm)
     dmt_psl.med.mie_cs(dd) = pcasp_mie_cs(dmt_psl.med.PSL_nm(dd)*1e-3);
end
for dd= 1:length(dmt_psl.hi.PSL_nm)
     dmt_psl.hi.mie_cs(dd) = pcasp_mie_cs(dmt_psl.hi.PSL_nm(dd)*1e-3);
end
P_0_med = polyfit(dmt_psl.med.mie_cs,dmt_psl.med.bin,1);
P_0_hi = polyfit(dmt_psl.hi.mie_cs,dmt_psl.hi.bin,1);

    
%%
cal_20050613.lo.PSL_nm = [114,125];
cal_20050613.med.PSL_nm = [152,199,220,240,269];
cal_20050613.hi.PSL_nm = [350,450,596,799,1361,2013];
cal_20050613.lo.bin = [345,1025];
cal_20050613.med.bin = [4175,4500,4865,5295,5975];
cal_20050613.hi.bin = [8295,8385,8460,8845,9700,10000];
for dd = 1:length(cal_20050613.lo.PSL_nm)
     cal_20050613.lo.mie_cs(dd) = pcasp_mie_cs(cal_20050613.lo.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_20050613.med.PSL_nm)
     cal_20050613.med.mie_cs(dd) = pcasp_mie_cs(cal_20050613.med.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_20050613.hi.PSL_nm)
     cal_20050613.hi.mie_cs(dd) = pcasp_mie_cs(cal_20050613.hi.PSL_nm(dd)*1e-3);
end
P_1_lo = polyfit(cal_20050613.lo.mie_cs,cal_20050613.lo.bin,1);
P_1_med = polyfit(cal_20050613.med.mie_cs,cal_20050613.med.bin,1);
P_1_hi = polyfit(cal_20050613.hi.mie_cs,cal_20050613.hi.bin,1);

%%
cal_bnl_20060115.lo.PSL_nm = [102,114,125];
cal_bnl_20060115.med.PSL_nm = [152,199,220,240,269];
cal_bnl_20060115.hi.PSL_nm = [350,450,596,799,1361,2013];

cal_bnl_20060115.lo.bin = [250,370,880];
cal_bnl_20060115.med.bin = [4180,4550,4880,5300,6080];
cal_bnl_20060115.hi.bin = [8290,8370,8470,8800,9700,9875];

for dd = 1:length(cal_bnl_20060115.lo.PSL_nm)
     cal_bnl_20060115.lo.mie_cs(dd) = pcasp_mie_cs(cal_bnl_20060115.lo.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_bnl_20060115.med.PSL_nm)
     cal_bnl_20060115.med.mie_cs(dd) = pcasp_mie_cs(cal_bnl_20060115.med.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_bnl_20060115.hi.PSL_nm)
     cal_bnl_20060115.hi.mie_cs(dd) = pcasp_mie_cs(cal_bnl_20060115.hi.PSL_nm(dd)*1e-3);
end
P_2_lo = polyfit(cal_bnl_20060115.lo.mie_cs,cal_bnl_20060115.lo.bin,1);
P_2_med = polyfit(cal_bnl_20060115.med.mie_cs,cal_bnl_20060115.med.bin,1);
P_2_hi = polyfit(cal_bnl_20060115.hi.mie_cs,cal_bnl_20060115.hi.bin,1);
%%
%PNL cals...

PSL_nm.nominal = [100, 125, 150, 220, 240, 269, 350, 450, 600, 800, 900, 1300,2000];
PSL_nm.diam =[102, 125, 151, 220, 240, 269, 350, 453, 596, 799, 903, 1361, 1998];
cal_pnnl.lo.PSL_nm = [102,125];
cal_pnnl.med.PSL_nm = [151, 220, 240, 269];
cal_pnnl.hi.PSL_nm = [350, 453, 596, 799, 903, 1361, 1998];

cal_pnnl.lo.bin = [14.5,1.0352e+003];
% The 100 nm peak only appears in super blow-up mode
% as in the special table B(1,40) in a20070209_100nm_sonic_2.txt
cal_pnnl.med.bin = [4192,4962, 5.3756e+003,6.1707e+003 ];
%350 could be finer
cal_pnnl.hi.bin = [8.3005e+003,8.3998e+003 ,8.5019e+003 ,8.8878e+003 ,9.0692e+003 ,9.6835e+003 ,1.051e+004];
%maybe if second hump of 2000 is neglected: 1046, 1051

for dd = 1:length(cal_pnnl.lo.PSL_nm)
    cal_pnnl.lo.mie_cs(dd) = pcasp_mie_cs(cal_pnnl.lo.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_pnnl.med.PSL_nm)
    cal_pnnl.med.mie_cs(dd) = pcasp_mie_cs(cal_pnnl.med.PSL_nm(dd)*1e-3);
end
for dd = 1:length(cal_pnnl.hi.PSL_nm)
    cal_pnnl.hi.mie_cs(dd) = pcasp_mie_cs(cal_pnnl.hi.PSL_nm(dd)*1e-3);
end
P_3_lo = polyfit(cal_pnnl.lo.mie_cs,cal_pnnl.lo.bin,1);
P_3_med = polyfit(cal_pnnl.med.mie_cs,cal_pnnl.med.bin,1);
P_3_hi = polyfit(cal_pnnl.hi.mie_cs,cal_pnnl.hi.bin,1);
%%

figure; plot(cal_20050613.lo.mie_cs,cal_20050613.lo.bin,'ro',...
    cal_20050613.lo.mie_cs, polyval(P_1_lo,cal_20050613.lo.mie_cs),'r',...
    cal_bnl_20060115.lo.mie_cs, cal_bnl_20060115.lo.bin,'bx',...
    cal_bnl_20060115.lo.mie_cs, polyval(P_2_lo,cal_bnl_20060115.lo.mie_cs),'b',...
        cal_pnnl.lo.mie_cs, cal_pnnl.lo.bin,'g*',...
    cal_pnnl.lo.mie_cs, polyval(P_3_lo,cal_pnnl.lo.mie_cs),'g');
title('Calibration of PCASP A low gain region');
legend('pre-MASE data', 'pre-MASE fit', 'BNL data', 'BNL fit', 'PNNL data', 'PNNL fit')
xlabel('PCASP cross-section (um^2)')
ylabel('PCASP A/D bin')
%%
figure; plot(cal_20050613.med.mie_cs,cal_20050613.med.bin,'ro',...
    cal_20050613.med.mie_cs, polyval(P_1_med,cal_20050613.med.mie_cs),'r',...
    cal_bnl_20060115.med.mie_cs, cal_bnl_20060115.med.bin,'bx',...
    cal_bnl_20060115.med.mie_cs, polyval(P_2_med,cal_bnl_20060115.med.mie_cs),'b', ...
            cal_pnnl.med.mie_cs, cal_pnnl.med.bin,'g*',...
    cal_pnnl.med.mie_cs, polyval(P_3_med,cal_pnnl.med.mie_cs),'g');
title('Calibration of PCASP A medium gain region');
legend('pre-MASE data', 'pre-MASE fit', 'BNL data', 'BNL fit', 'PNNL data', 'PNNL fit')
xlabel('PCASP cross-section (um^2)')
ylabel('PCASP A/D bin')
%%
figure; plot(cal_20050613.hi.mie_cs,cal_20050613.hi.bin,'ro',...
    cal_20050613.hi.mie_cs, polyval(P_1_hi,cal_20050613.hi.mie_cs),'r',...
    cal_bnl_20060115.hi.mie_cs, cal_bnl_20060115.hi.bin,'bx',...
    cal_bnl_20060115.hi.mie_cs, polyval(P_2_hi,cal_bnl_20060115.hi.mie_cs),'b',...
            cal_pnnl.hi.mie_cs, cal_pnnl.hi.bin,'g*',...
    cal_pnnl.hi.mie_cs, polyval(P_3_hi,cal_pnnl.hi.mie_cs),'g');
title('Calibration of PCASP A high gain region');
legend('pre-MASE data', 'pre-MASE fit', 'BNL data', 'BNL fit', 'PNNL data', 'PNNL fit')
xlabel('PCASP cross-section (um^2)')
ylabel('PCASP A/D bin')

%%

%%
figure; plot(d_125_8.adjThreshold, d_125_8.adjAvg,'r', d_125_11.adjThreshold, 2*d_125_11.adjAvg,'b')
title('125 nm PSL overlay with Table A(0,30) and Table A(1,10)');
xlabel('adjusted bin thresholds');
ylabel('cts/(bin width)');
%%
figure; 
plot(pnl150_1.adjThreshold, 0.5*pnl150_1.adjAvg, ...
    pnl150_2.adjThreshold, pnl150_2.adjAvg);
title('150 nm PSL overlay');
xlabel('adjusted bin thresholds');
ylabel('cts/(bin width)');
legend('Table A(2,40)','Table A(0,30)'); 

%%
figure; 
plot(pnl800_0.adjThreshold, pnl800_0.adjAvg, ...
    pnl800_1.adjThreshold, pnl800_1.adjAvg);
title('800 nm PSL overlay');
xlabel('adjusted bin thresholds');
ylabel('cts/(bin width)');
legend('Table A(3,40)','Table A(0,40)'); 
%%
figure; plot(d_3_40_pre.adjThreshold, d_3_40_pre.adjAvg, ...
    d_3_40_post.adjThreshold, d_3_40_post.adjAvg);
title('1300 nm PSL before and after sonication');
xlabel('adjusted bin thresholds');
ylabel('cts/(bin width)');
legend('Before','After'); 
%%
figure; plot(d_2000_pre.adjThreshold, d_2000_pre.adjAvg, ...
    d_2000_post.adjThreshold, d_2000_post.adjAvg);
title('2000 nm PSL before and after sonication');
xlabel('adjusted bin thresholds');
ylabel('cts/(bin width)');
legend('Before','After'); 
%%

