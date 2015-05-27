
ccn_time = datenum('3/5/2015  00:00:00','mm/dd/yyyy HH:MM:SS') + ([1:1933]-1)./(24*60*2);
ccn.time = ccn_time';
ccn.N_CCN = ccn_py(:,1); 
ccn.ss = ccn_py(:,2);
ccn.dTEC = ccn_py(:,3);
ccn.T1 = ccn_py(:,5);
ccn.T2 = ccn_py(:,6);
ccn.T3 = ccn_py(:,7);
ccn.T_opc = ccn_py(:,9);
ccn.dOPC = ccn_py(:,10);
ccn.dtg = ccn_py(:,12);

ccn.secs(1) = 0;
seq = [];
seq(1) = 0;
for s = 2:length(ccn.time)
   ccn.secs(s) = double(ccn.ss(s)==ccn.ss(s-1)).*(ccn.secs(s-1) + 30);
   seq(s) = seq(s-1) + double(ccn.ss(s-1)< 0.8 & ccn.ss(s)>0.75);
end
ccn.secs = ccn.secs';seq = seq';
good_T = ccn.dOPC<2.6 & ccn.dOPC>2.25 & ccn.secs >= 300;
good_T = ccn.dOPC<2 & ccn.dOPC>1.5 & ccn.secs >= 300;
hs = unique(floor(serial2hs(ccn.time)));
figure(10);
for hr = hs(end):-1:hs(1)
   
   good_hr = floor(serial2hs(ccn.time))==hr;
   subplot(1,2,1);scatter(serial2hs(ccn.time(good_T&good_hr)), ccn.N_CCN(good_T&good_hr),64,ccn.ss(good_T&good_hr),'filled');colorbar; title(['hour = ',num2str(hr)])
   subplot(1,2,2);scatter(ccn.ss(good_T&good_hr), ccn.N_CCN(good_T&good_hr),64,ccn.ss(good_T&good_hr),'filled');colorbar; title(['hour = ',num2str(hr)])
   menu('OK','OK')
end

figure(11);
for q = 1:max(seq)
   
   good_q = (seq==q) | ((seq == q+1)&(ccn.ss>.75));
   subplot(1,2,1);scatter(serial2hs(ccn.time(good_T&good_q)), ccn.N_CCN(good_T&good_q),64,ccn.ss(good_T&good_q),'filled');colorbar; title(['sequence = ',num2str(q)])
   subplot(1,2,2);scatter(ccn.ss(good_T&good_q), ccn.N_CCN(good_T&good_q),64,serial2hs(ccn.time(good_T&good_q)),'filled');colorbar; title(['seq = ',num2str(q)])
   menu('OK','OK')
end
save(['D:\case_studies\aos_ccn_avg\20150305.mat'],'-struct','ccn')