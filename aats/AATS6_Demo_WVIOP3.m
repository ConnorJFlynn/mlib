%This program creates a demonstration plot for the AATS-6 WIOP3 data
clear all
[DOY_AATS6,IPWV_AATS6,AOD_flag,AOD_AATS6,AOD_Error_AATS6,alpha_AATS6,lambda_AATS6]=read_AATS6(2);
[DOY_AATS6_2,IPWV_AATS6_2,AOD_flag_2,AOD_AATS6_2,AOD_Error_AATS6_2,alpha_AATS6_2,lambda_AATS6_2]=read_AATS6(3);
[DOY_AATS6_3,IPWV_AATS6_3,AOD_flag_3,AOD_AATS6_3,AOD_Error_AATS6_3,alpha_AATS6_3,lambda_AATS6_3]=read_AATS6(4);

figure(1)
subplot(3,1,1)
plot(DOY_AATS6,IPWV_AATS6,'.')
ylabel('H_2O Column (cm)')
subplot(3,1,2)
plot(DOY_AATS6(AOD_flag==1),AOD_AATS6(:,(AOD_flag==1)),'.')
ylabel('Aerosol Optical Depth')
subplot(3,1,3)
plot(DOY_AATS6(AOD_flag==1),alpha_AATS6(AOD_flag==1),'.')
xlabel('Day of Year 2000')
ylabel('Angstroem \alpha')

for i_day=floor(min(DOY_AATS6)):floor(max(DOY_AATS6))
 figure(2)
 plot(DOY_AATS6,IPWV_AATS6,'.',DOY_AATS6_2,IPWV_AATS6_2,'.',DOY_AATS6_3,IPWV_AATS6_3,'.')
 set(gca,'xlim',[i_day,i_day+1])
 set(gca,'ylim',[0 5])
 grid on
 pause
end    

figure(3)
range=[0:0.1:5];
y=interp1(DOY_AATS6,DOY_AATS6,DOY_AATS6_2,'nearest');
delta_t=(DOY_AATS6_2-y)*24*60;
i=find(abs(delta_t)<=0.1);

subplot(2,2,4)
plot(DOY_AATS6_2(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 2000')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,IPWV_AATS6,DOY_AATS6_2(i),'nearest');
y=IPWV_AATS6_2(i);
[p,S] = polyfit (x,y,1);

[y_fit,delta] = polyval(p,x,S);

[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.2,0.8,sprintf('y = %5.3f x + %5.3f',p))
text(0.2,0.6,sprintf('r²= %5.3f',r.^2))

text(0.2,0.4,sprintf('RMSE = %5.3f',rmse))

text(0.2,0.2,sprintf('n = %5i',n))

axis([0 5 0 5])

subplot(2,2,2)
plot(DOY_AATS6_2(i),x-y,'.')
xlabel('Day of Year 1997')
text(271,0.03,sprintf('mean = %5.3f ',mean(x-y)))

text(271,0.05,sprintf('stdev= %5.3f ',std(x-y)))

rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.08,sprintf('rms= %5.3f ',rmsd))

grid on
%axis([-inf inf -0.1 0.1])