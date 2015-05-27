% PCASP PSL calibrations before BNL visit of 2008-06-17

% Step 1. Compute pcasp_mie_cs for each PSL diam.
% Step 2. Delineate three gain regions based on observed bin positions
% Step 3. linear fit bin position vs pcasp_mie_cs for each region
% Step 4. compute intercepts, look for gaps, how about reporting thresholds
% in terms of cs^0.5 instead of physical dims?  
%%
clear
psl.diam = [2000 1300 900 800 600 450 350 269 240 220 150 125 100];
for d = 1:length(psl.diam)
  psl.cs(d) = pcasp_mie_cs(psl.diam(d)/1000);
end

sppA.bin_cjf = [10840 9653.1578 8989.6139 8834.9784 8459.6457 8370.7282 ...
8277.0992 6122.1549 5295.5513 4870.1505 4183.9232 842.9833 46.3616 ];
sppB.bin_cjf = [10675.4 9450.6011 8921.7403 8764.1828 8434.4216 8351.2781 ...
8270.2155 6525.6901 5515.5996 4996.8033 4183.4027 921.4853 24.82];

sppA.bin_mp = [ -9999 9581.19 8982.31 8852.3 8497.3 8415.66 8337.43 ...
6632.48 5542.41 4908.29 4199.4 1205.67 692 ]; 
sppA.bin_mp(1) = NaN;
sppB.bin_mp = [-9999 9430.35 8958.61 8712.23 8462.98 8387.07 ...
8336.6 6518.77 5674.29 5176.08 4189.67 1189.28 692 ];
sppB.bin_mp(1) = NaN;
%%

hi = sppA.bin_cjf>=8192;
hi_ii = find(hi);
med = sppA.bin_cjf<8192 & sppA.bin_cjf>=4096;
low = sppA.bin_cjf<4096;

sppA.cjf.P_cs_low = polyfit(psl.cs(low),sppA.bin_cjf(low),1);
sppA.cjf.P_cs_med = polyfit(psl.cs(med),sppA.bin_cjf(med),1);
sppA.cjf.P_cs.hi = polyfit(psl.cs(hi),sppA.bin_cjf(hi),1);
sppA.mp.P_cs_low = polyfit(psl.cs(low),sppA.bin_mp(low),1);
sppA.mp.P_cs_med = polyfit(psl.cs(med),sppA.bin_mp(med),1);
sppA.mp.P_cs.hi = polyfit(psl.cs(hi_ii(2:end)),sppA.bin_mp(hi_ii(2:end)),1);

sppA.cjf.P_bin_low = polyfit(sppA.bin_cjf(low),psl.cs(low),1);
sppA.cjf.P_bin_med = polyfit(sppA.bin_cjf(med),psl.cs(med),1);
sppA.cjf.P_bin_hi = polyfit(sppA.bin_cjf(hi),psl.cs(hi),1);
sppA.mp.P_bin_low = polyfit(sppA.bin_mp(low),psl.cs(low),1);
sppA.mp.P_bin_med = polyfit(sppA.bin_mp(med),psl.cs(med),1);
sppA.mp.P_bin_hi = polyfit(sppA.bin_mp(hi_ii(2:end)),psl.cs(hi_ii(2:end)),1);

sppB.cjf.P_cs_low = polyfit(psl.cs(low),sppB.bin_cjf(low),1);
sppB.cjf.P_cs_med = polyfit(psl.cs(med),sppB.bin_cjf(med),1);
sppB.cjf.P_cs.hi = polyfit(psl.cs(hi),sppB.bin_cjf(hi),1);
sppB.mp.P_cs_low = polyfit(psl.cs(low),sppB.bin_mp(low),1);
sppB.mp.P_cs_med = polyfit(psl.cs(med),sppB.bin_mp(med),1);
sppB.mp.P_cs.hi = polyfit(psl.cs(hi_ii(2:end)),sppB.bin_mp(hi_ii(2:end)),1);

sppB.cjf.P_bin_low = polyfit(sppB.bin_cjf(low),psl.cs(low),1);
sppB.cjf.P_bin_med = polyfit(sppB.bin_cjf(med),psl.cs(med),1);
sppB.cjf.P_bin_hi = polyfit(sppB.bin_cjf(hi),psl.cs(hi),1);
sppB.mp.P_bin_low = polyfit(sppB.bin_mp(low),psl.cs(low),1);
sppB.mp.P_bin_med = polyfit(sppB.bin_mp(med),psl.cs(med),1);
sppB.mp.P_bin_hi = polyfit(sppB.bin_mp(hi_ii(2:end)),psl.cs(hi_ii(2:end)),1);

%%
figure; 
plot(sppA.bin_cjf(low), psl.cs(low),'ro',sppA.bin_cjf(med), psl.cs(med),'go',sppA.bin_cjf(hi), psl.cs(hi),'bo', ...
sppA.bin_mp(low), psl.cs(low),'rx',sppA.bin_mp(med), psl.cs(med),'gx',sppA.bin_mp(hi), psl.cs(hi),'bx', ...
[0 4095], polyval(sppA.cjf.P_bin_low,[0 4095]), 'r-',4096+[0 4095], polyval(sppA.cjf.P_bin_med,4096+[0 4095] ), 'g-',...
2*4096+[0 4095], polyval(sppA.cjf.P_bin_hi,2*4096+[0 4095]), 'b-', ...
[0 4095], polyval(sppA.mp.P_bin_low,[0 4095]), 'r--',4096+[0 4095], polyval(sppA.mp.P_bin_med,4096+[0 4095] ), 'g--',...
2*4096+[0 4095], polyval(sppA.mp.P_bin_hi,2*4096+[0 4095]), 'b--')
ax(1) = gca;
title('PCASP A cals by Flynn and Pekour')
xlabel('SPP bin center of response')
ylabel('PCASP mie cross section')
figure; 
plot(sppB.bin_cjf(low), psl.cs(low),'ro',sppB.bin_cjf(med), psl.cs(med),'go',sppB.bin_cjf(hi), psl.cs(hi),'bo', ...
sppB.bin_mp(low), psl.cs(low),'rx',sppB.bin_mp(med), psl.cs(med),'gx',sppB.bin_mp(hi), psl.cs(hi),'bx', ...
[0 4095], polyval(sppB.cjf.P_bin_low,[0 4095]), 'r-',4096+[0 4095], polyval(sppB.cjf.P_bin_med,4096+[0 4095] ), 'g-',...
2*4096+[0 4095], polyval(sppB.cjf.P_bin_hi,2*4096+[0 4095]), 'b-', ...
[0 4095], polyval(sppB.mp.P_bin_low,[0 4095]), 'r--',4096+[0 4095], polyval(sppB.mp.P_bin_med,4096+[0 4095] ), 'g--',...
2*4096+[0 4095], polyval(sppB.mp.P_bin_hi,2*4096+[0 4095]), 'b--')
ax(2) = gca;
title('PCASP B cals by Flynn and Pekour')
xlabel('SPP bin center of response')
ylabel('PCASP mie cross section')

linkaxes(ax,'xy')
%%
%
