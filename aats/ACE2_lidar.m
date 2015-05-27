%compares Galletas, Izana MPL with AATS-14 extinction
read_lidar_Galletas
read_lidar_IZO
read_AATS14_ext

figure(3)
subplot(1,2,1)
plot(lidar_ext_18GMT, lidar_altitude,Lidar_Ext_Izana, Lidar_Altitude_Izana)
grid on
ylabel('Altitude [km]')
xlabel('Extinction at 523 nm')
subplot(1,2,2)
plot(lidar_AOD_18GMT, lidar_altitude,Lidar_AOD2_Izana, Lidar_Altitude_Izana)
legend('MPL Las Galletas 18 UT','MPL Izana 18:45 UT')
ylabel('Altitude [km]')
xlabel('AOD at 523 nm')
grid on

figure(4)
subplot(1,2,1)
plot(lidar_ext_16GMT, lidar_altitude,ext_AATS14(5,:),Altitude_AATS14)
grid on
ylabel('Altitude [km]')
xlabel('Extinction at 523 nm')
subplot(1,2,2)
plot(lidar_AOD_16GMT, lidar_altitude,AOD_AATS14(5,:),Altitude_AATS14)
ylabel('Altitude [km]')
xlabel('AOD at 523 nm')
legend('MPL Las Galletas 16 UT','AATS-14 15:25-16:06 UT')
grid on
