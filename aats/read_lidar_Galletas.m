lambda_lidar=0.523;
fid=fopen('d:\beat\data\ACE-2\Lidar\Lidar170797.Galletas.asc');
for hls=1:2
  fgetl(fid);
end
lidar_data=fscanf(fid,'%g',[5,inf]);
fclose(fid);
lidar_data(lidar_data==-999)=NaN;
lidar_altitude  = lidar_data(1,:);
lidar_ext_16GMT = lidar_data(2,:);
lidar_AOD_16GMT = lidar_data(3,:);
lidar_ext_18GMT = lidar_data(4,:);
lidar_AOD_18GMT = lidar_data(5,:);

ii_G=find(lidar_altitude<5.5);

lidar_ext_16GMT = lidar_ext_16GMT(ii_G);
lidar_ext_18GMT = lidar_ext_18GMT(ii_G);
lidar_altitude  = lidar_altitude(ii_G);


lidar_AOD_16GMT=cumtrapz(-lidar_altitude,lidar_ext_16GMT);
lidar_AOD_18GMT=cumtrapz(-lidar_altitude,lidar_ext_18GMT);

lidar_AOD_16GMT=lidar_AOD_16GMT-min(lidar_AOD_16GMT);
lidar_AOD_18GMT=lidar_AOD_18GMT-min(lidar_AOD_18GMT);

figure(14)
subplot(1,2,1)
plot(lidar_ext_16GMT, lidar_altitude,'.-',lidar_ext_18GMT, lidar_altitude,'.-')
ylabel('Altitude [km]')
xlabel('Extinction at 523 nm')
grid on
legend('Las Galletas 16 UT','Las Galletas 18 UT')
subplot(1,2,2)
plot(lidar_AOD_16GMT, lidar_altitude,'.-',lidar_AOD_18GMT, lidar_altitude,'.-')
ylabel('Altitude [km]')
xlabel('AOD at 523 nm')
grid on
legend('16 UT','18 UT')
