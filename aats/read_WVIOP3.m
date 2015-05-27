clear all
[DOY_AATS6,IPWV_AATS6,AOD_flag,AOD_AATS6,AOD_Error_AATS6,alpha_AATS6,lambda_AATS6]=read_AATS6(2);
[DOY_AATS6_2,IPWV_AATS6_2,AOD_flag_2,AOD_AATS6_2,AOD_Error_AATS6_2,alpha_AATS6_2,lambda_AATS6_2]=read_AATS6(3);


figure(1)
subplot(7,1,1)
plot(DOY_AATS6,IPWV_AATS6,'.',DOY_AATS6_2,IPWV_AATS6_2,'.')
subplot(7,1,2)
plot(DOY_AATS6,alpha_AATS6,'.',DOY_AATS6_2(AOD_flag_2==1),alpha_AATS6_2(AOD_flag_2==1),'.')
subplot(7,1,3)
plot(DOY_AATS6,AOD_AATS6(1,:),'.',DOY_AATS6_2(AOD_flag_2==1),AOD_AATS6_2(1,AOD_flag_2==1),'.')
subplot(7,1,4)
plot(DOY_AATS6,AOD_AATS6(2,:),'.',DOY_AATS6_2(AOD_flag_2==1),AOD_AATS6_2(2,AOD_flag_2==1),'.')
subplot(7,1,5)
plot(DOY_AATS6,AOD_AATS6(3,:),'.',DOY_AATS6_2(AOD_flag_2==1),AOD_AATS6_2(3,AOD_flag_2==1),'.')
subplot(7,1,6)
plot(DOY_AATS6,AOD_AATS6(4,:),'.',DOY_AATS6_2(AOD_flag_2==1),AOD_AATS6_2(4,AOD_flag_2==1),'.')
subplot(7,1,7)
plot(DOY_AATS6,AOD_AATS6(5,:),'.',DOY_AATS6_2(AOD_flag_2==1),AOD_AATS6_2(5,AOD_flag_2==1),'.')

for iday=0:100
 subplot(7,1,1)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 5])
 subplot(7,1,2)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 inf])
 subplot(7,1,3)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 .5])
 subplot(7,1,4)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 .5])
 subplot(7,1,5)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 .5])
 subplot(7,1,6)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 .5])
 subplot(7,1,7)
 grid on
 axis([floor(min(DOY_AATS6))+iday floor(min(DOY_AATS6))+iday+1 0 .5])
 pause
end
