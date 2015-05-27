%this routine humidifies Neph acattering coefficients based on  2 UW and Misu neph RH amb from UW
close all
read_Misu
read_UW_scat

figure(7)
subplot(2,1,1)
plot(UT_Misu,Temp_Misu,UT_UW,T_amb_UW)
ylabel('T [°C]');
xlabel('UT');
legend('MISU','Ambient')
subplot(2,1,2)
plot(UT_Misu,RH_Misu,UT_UW,RH_dry_UW,UT_UW,RH_amb_UW,UT_UW,RH_wet_UW)
ylabel('RH [%]');
xlabel('UT');
legend('MISU dry','UW dry','UW amb','UW wet')

ii=find(UT_Misu<=max(UT_UW) & UT_Misu>=min(UT_UW));
UT_Misu=UT_Misu(ii);
RH_Misu=RH_Misu(ii);
Scat_Misu=Scat_Misu(:,ii);
Scat_corr_err_Misu=Scat_corr_err_Misu(:,ii);

Wet_scat_UW=interp1(UT_UW,Wet_scat_UW_spline,UT_Misu);
Scat_corr_err_UW=interp1(UT_UW,Scat_corr_err_UW,UT_Misu);
Dry_scat_UW=interp1(UT_UW,Dry_scat_UW_spline,UT_Misu);

RH_dry_UW=interp1(UT_UW,RH_dry_UW,UT_Misu);
RH_wet_UW=interp1(UT_UW,RH_wet_UW,UT_Misu);
RH_amb_UW=interp1(UT_UW,RH_amb_UW,UT_Misu);

[m,n]=size(UT_Misu);
x=log(1-[RH_Misu',RH_dry_UW',RH_wet_UW']/100);
y=log([Scat_Misu(2,:)',Dry_scat_UW',Wet_scat_UW']);
x2=log(1-RH_amb_UW/100);
x3=log(1-[1:99]/100);
for i=1:n
  [p,S] = polyfit(x(i,:),y(i,:),1);
  [y_amb,delta] = polyval(p,x2(i),S);
%  figure(8)
%  [y_fit,delta] = polyval(p,x3,S);
%  plot((1-exp(x(i,:)))*100,exp(y(i,:)),'*',(1-exp(x3))*100,exp(y_fit),(1-exp(x2(i)))*100,exp(y_amb),'o')
%  axis([0 100 0 0.2])
%  xlabel('RH [%]');
%  ylabel('Scattering [1/km]');
%  grid on
%  pause(0.01);
  gamma(i)=p(1);
  Amb_scat_UW(i)=exp(y_amb);
end

figure(8)
subplot(2,1,1)
plot(UT_Misu,Scat_Misu(2,:),UT_Misu,Dry_scat_UW,UT_Misu,Amb_scat_UW,UT_Misu,Wet_scat_UW)
ylabel('Scatt. Coeff [1/km]');
xlabel('UT');
legend('MISU dry','UW dry','Ambient','UW wet')
subplot(2,1,2)
plot(UT_Misu,RH_Misu,UT_Misu,RH_dry_UW,UT_Misu,RH_amb_UW,UT_Misu,RH_wet_UW)
ylabel('RH [%]');
xlabel('UT');
legend('MISU dry','UW dry','UW amb','UW wet')

figure(9)
pp  = csaps(UT_Misu,gamma,0.9999);
gamma_spline = fnval(pp,UT_Misu);
plot(UT_Misu,gamma,UT_Misu,gamma_spline)
axis([-inf inf -2 0.4])


k=Scat_Misu./(1-(ones(3,1)*RH_Misu/100)).^(ones(3,1)*gamma);
Amb_scat_Misu=k.*(1-(ones(3,1)*RH_amb_UW/100)).^(ones(3,1)*gamma);

figure(11)
plot(UT_Misu,Amb_scat_Misu,UT_Misu,Amb_scat_UW)



