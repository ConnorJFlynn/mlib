%%
mpl4 = mpl004_alive;

mpl102 = mpl102_alive;
%%
xl = xlim; 
tt = find((serial2Hh(mpl102.time)>xl(1))&(serial2Hh(mpl102.time)<xl(2)));
tr = find((serial2Hh(mpl4.time)>xl(1))&(serial2Hh(mpl4.time)<xl(2)));

figure;semilogy(mpl102.range(mpl102.r.lte_20),mpl102.prof(mpl102.r.lte_20,tt),'m',...
    mpl4.range(mpl4.r.lte_20),mpl4.prof(mpl4.r.lte_20,tr),'g');
%
figure;  
semilogy(mpl102.range(mpl102.r.lte_30),mean(mpl102.prof(mpl102.r.lte_30,tt),2),'m',...
    mpl4.range(mpl4.r.lte_30),mean(mpl4.prof(mpl4.r.lte_30,tr),2),'g');

%%
mean102 = interp1(mpl102.range(mpl102.r.lte_30), mean(mpl102.prof(mpl102.r.lte_30,tt),2),mpl4.range(mpl4.r.lte_30));
mean4 = interp1(mpl4.range(mpl4.r.lte_30),mean(mpl4.prof(mpl4.r.lte_30,tr),2),mpl4.range(mpl4.r.lte_30));
%%
rat = mean102./mean4;
lograt = real(log10(mean102./mean4));
P = polyfit(mpl4.range(mpl4.r.lte_30(floor(end/2):end)),lograt(floor(end/2):end),1)
fitlograt = polyval(P,mpl4.range(mpl4.r.lte_30(floor(end/2):end)));
prof_len = length(fitlograt);
rad = (pi/2)*[0:1:(prof_len-1)]'/prof_len;
w_S = cos(rad).^2;
% w = [length(fitlograt):-1:1]'./length(fitlograt);
merge_lograt = merge_profs(lograt(floor(end/2):end),fitlograt,w_S.^3);
merge_lograt = [lograt(1:(floor(end/2)-1)); merge_lograt];
figure; plot(mpl4.range(mpl4.r.lte_30),lograt, 'r.',mpl4.range(mpl4.r.lte_30),polyval(P,mpl4.range(mpl4.r.lte_30)),'g',mpl4.range(mpl4.r.lte_30),merge_lograt,'b')
merge_rat = 10.^merge_lograt;
merge_rat(1:6) = merge_rat(7);
%%
figure; 
semilogy(mpl102.range(mpl102.r.lte_30),mean(mpl102.prof(mpl102.r.lte_30,tt),2),'m',...
    mpl4.range(mpl4.r.lte_30),merge_rat.*mean(mpl4.prof(mpl4.r.lte_30,tr),2),'g');
%%
mpl4_to_102.range = mpl4.range(mpl4.r.lte_30);
mpl4_to_102.factor = merge_rat;
save mpl4_to_102.mat mpl4_to_102