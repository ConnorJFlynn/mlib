read_AATS14_ext

figure(1)
errorbar(Altitude_AATS14,AOD_AATS14(5,:),-AOD_err_AATS14(5,:),AOD_err_AATS14(5,:))
hold on

read_lidar_Izana

plot(Lidar_Altitude,Lidar_AOD,'r');

read_lidar_Galletas
errorbar(lidar_range,(lidar_AOD(1)-lidar_AOD),-lidar_AOD_std,lidar_AOD_std,'g')
hold off
title('ACE-2 June 17, 1997')
legend('AATS-14 15.4-16.1 UT','Lidar Izana 18.5 UT','Lidar Las Galletas 21 UT')
xlabel('Altitude [km]')
ylabel('AOD at 523 nm')
axis([0 6 -inf inf])
grid on