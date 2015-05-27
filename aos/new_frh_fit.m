
this = round(serial2Hh(aos.time))==2;
%

figure; subplot(2,1,1); 
[rh,ii] = sort(aos.vars.RH_NephVol_Wet.data(~missings&this));
X = 1./(1-rh./100);
XX = [1,X];
Y = aos.vars.Bs_B_Wet_1um_Neph3W_2.data(~missings&this) ./aos.vars.Bs_B_Dry_1um_Neph3W_1.data(~missings&this);
YY = [1,Y(ii)];
P = polyfit(XX,YY,1)
subplot(2,1,1); 
scatter(aos.vars.RH_NephVol_Wet.data(~missings&this), aos.vars.Bs_B_Wet_1um_Neph3W_2.data(~missings&this) ./aos.vars.Bs_B_Dry_1um_Neph3W_1.data(~missings&this) ,40,serial2Hh(aos.time(~missings&this)),'filled')
hold('on');
plot(rh, polyval(P,X),'-');
hold('off');
title('Hygroscopicity plots')
xlabel('wet neph vol RH [%]')
ylabel('Bs(wet) / Bs(dry)');
subplot(2,1,2)
scatter(1./(1-aos.vars.RH_NephVol_Wet.data(~missings&this)./100), aos.vars.Bs_B_Wet_1um_Neph3W_2.data(~missings&this) ./aos.vars.Bs_B_Dry_1um_Neph3W_1.data(~missings&this) ,40,serial2Hh(aos.time(~missings&this)),'filled');
hold('on');
plot(X, polyval(P,X),'-')
hold('off');
xlabel('X = 1./(1-RH/100)')
ylabel('Bs(wet) / Bs(dry)');


