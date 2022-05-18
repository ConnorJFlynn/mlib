%%
clear;clc;
par0=load('par0.txt');
dat=load('testdata.txt');
%%
[parmin,resnom,res,exitflag]= fit2voigt(dat,par0);
%%
fit=voigt(dat(:,1),parmin);
%%
subplot(2,1,1);
plot(dat(:,1),dat(:,2),'b',dat(:,1),fit,'r');
legend('data','fit')
xlim([600,1700]);ylim([-0.01, 0.25]);
subplot(2,1,2);
plot(dat(:,1),res,'k'); 
legend('residual','location','north');
xlim([600,1700]);ylim([-7, 7]*1e-3);