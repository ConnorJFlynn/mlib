function [tau_O4,p]=O4(lambda_SPM,response_SPM,cwvl);

%computes weighted O4 optical depth as a function of altitude and provides numerical expression

z_max=12;%max Altitude in km

% reads Greenblatt O4 
load c:\beat\data\xsect\O4_only.asc

wvl=O4_only(:,1);
Absorptance=O4_only(:,2);

L=0.895  % m
O2_press=55 % atm
Loschmidt=2.686763e25 % molec/m3
O4_xsect=Absorptance/(L*(O2_press*273.15/296*Loschmidt)^2);

O4_xsect= INTERP1(wvl,O4_xsect,lambda_SPM);
O4_xsect = trapz(lambda_SPM,O4_xsect.*response_SPM)/trapz(lambda_SPM,response_SPM);

%read in Mid Summer Atmosphere 50 layers
pathname='c:\Beat\Data\Diverse\';
filename='MidSum.asc' 
fid=fopen(deblank([pathname filename]));
fgetl(fid);

data=fscanf(fid,'%f',[4 inf]);
Altitude=data(1,:)*1000;
Press=data(2,:);
Temp=data(3,:);
Dens=data(4,:);
clear data

%compute optical depth
Fine_Altitude=[0:10:max(Altitude)];
Layer_Thick=diff(Fine_Altitude);
MidLayer_Alt=Fine_Altitude(1:end-1)+Layer_Thick/2;
MidLayer_Dens=interp1(Altitude,Dens,MidLayer_Alt);
O2_dens=0.21*MidLayer_Dens;

n_wvl=size(O4_xsect,1);
n_lay=size(Layer_Thick,2);

tau_Layer=-log(1-(ones(n_wvl,1)*Layer_Thick).*(ones(n_lay,1)*O4_xsect')'.*(ones(n_wvl,1)*O2_dens.^2));
tau_O4=sum(tau_Layer');

y=cumsum(fliplr(tau_Layer));
x=fliplr(Fine_Altitude(1:end-1))/1000;

i=find(x<=z_max);
x=x(i); y=y(i);

% %fit a quadratic
% [p,S] = polyfit (x,y,2);
% sprintf('%12.3e',p)
% 
% [y_fit,delta] = polyval(p,x,S);
% a=y-y_fit;
% 
% figure(5)
% subplot(1,2,1)
% plot(y,x,'g.',y_fit,x);
% text(0.1, 0.15, num2str(cwvl),'units','normalized')
% ylabel('Altitude [km]','FontSize',14)
% xlabel('tau O4','FontSize',14)
% set(gca,'FontSize',14)
% grid on
% 
% subplot(1,2,2);
% plot(a,x,'g.'); 
% ylabel('Altitude [km]','FontSize',14)
% xlabel('\Delta tau O4','FontSize',14)
% grid on
% set(gca,'FontSize',14)
% 

%fit an exponential
[p,S] = polyfit (x,log(y),2);

fit=sprintf('tau_O_2=%12.3e*exp (%12.3e*z+%12.3e*z^2)',exp(p(3)),p(2),p(1))
[y_fit,delta] = polyval(p,x,S);
tau_fit=exp(y_fit);
resid=y-tau_fit;

figure(6)
subplot(1,2,1)
plot(y,x,'g.',tau_fit,x);
ylabel('Altitude [km]','FontSize',14)
xlabel('tau O4','FontSize',14)
set(gca,'FontSize',14)
grid on
text(0.1, 0.15, num2str(cwvl),'units','normalized')
text(0.2, 0.9, fit,'units','normalized')

subplot(1,2,2);
plot(resid,x,'g.'); 
ylabel('Altitude [km]','FontSize',14)
xlabel('\Delta tau O4','FontSize',14)
grid on
set(gca,'FontSize',14)

pause