% standard path 
pf='c:\beat\LBLRTM\mTAPE6';
[filename,filepath]=uigetfile([pf,filesep,'*.mat'],'Load Data');
eval(['load ',filepath,filename])
disp(filename)
disp('--------------------')
disp(info.channel)
disp(info.atmos)
disp(' ')
disp(' ')
 
s=findstr(filename,'_');
p=findstr(filename,'ff');
lambda=filename(s(1)+1:p-1)
filter=filename(p(1)+2:s(2)-1)
altitude=filename(s(2)+1:s(3)-1) 

altitude=[0:0.2:12];
tau=-log(tran);

[p,S] = polyfit (altitude,log(tau),2);
a=exp(p(2));
b=p(1);
fit=sprintf('tau_O_4=%12.3e*exp (%12.3e*z+%12.3e*z^2)',exp(p(3)),p(2),p(1))
[y_fit,delta] = polyval(p,altitude,S);
tau_fit=exp(y_fit);
resid=tau-tau_fit;

figure(1)
subplot(1,2,1)
plot(tau,altitude,'g.',tau_fit,altitude);

ylabel('Altitude [km]','FontSize',14)
xlabel('tau O4','FontSize',14)
set(gca,'FontSize',14)
grid on
text(0.1, 0.15, filter,'units','normalized')
text(0.2, 0.9, fit,'units','normalized')


subplot(1,2,2);
plot(resid,altitude,'g.'); 


ylabel('Altitude [km]','FontSize',14)
xlabel('\Delta tau O4','FontSize',14)
grid on
set(gca,'FontSize',14)