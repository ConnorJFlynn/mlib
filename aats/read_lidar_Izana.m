fid=fopen('d:\beat\data\ACE-2\Lidar\Lidar170797.Izana.asc');
fgetl(fid);
Lidar=fscanf(fid,'%f',[3,inf]);
fclose(fid);
Lidar_Altitude_Izana=Lidar(1,:);
Lidar_Ext_Izana=Lidar(2,:);
Lidar_AOD_Izana=Lidar(3,:);

Lidar_AOD2_Izana=cumtrapz(-Lidar_Altitude_Izana,Lidar_Ext_Izana);
Lidar_AOD2_Izana=Lidar_AOD2_Izana-min(Lidar_AOD2_Izana);


figure(1)
subplot(1,2,1)
plot(Lidar_Ext_Izana, Lidar_Altitude_Izana,'.-')
ylabel('Altitude [km]')
xlabel('Extinction at 523 nm')
text(0.06,5.2,'Izana MPL, July 17, 1997, 18:45 UT')
grid on

subplot(1,2,2)
plot(Lidar_AOD_Izana, Lidar_Altitude_Izana,'.-',Lidar_AOD2_Izana, Lidar_Altitude_Izana,'.-')
legend('Judd','Computed')
ylabel('Altitude [km]')
xlabel('AOD at 523 nm')
grid on
