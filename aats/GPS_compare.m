%opens data file
[filename_NOVA,path_NOVA]=uigetfile('d:\beat\data\ACE-2\Nova\*.pos.vel.txt','Choose NOVA GPS File', 0, 0);
fid_NOVA=fopen([path_NOVA filename_NOVA]);
for i=1:2
  fgetl(fid_NOVA);
end
Nova_data=fscanf(fid_NOVA,'%g',[7,inf]);
fclose(fid_NOVA);
 
%remove double lines so X will be monotonic for interpolation
%L=find(diff(Nova_data(2,:))~=0);
%Nova_data=Nova_data(:,L);

Nova_UT  =mod(Nova_data(1,:),86400)/60/60;
Nova_lat =Nova_data(2,:);
Nova_long=Nova_data(3,:);
Nova_alt =Nova_data(4,:);

%opens data file
[filename_NOVA,path_NOVA]=uigetfile('d:\beat\data\ACE-2\Diff_GPS\','Choose NOVA differential GPS File', 0, 0);
fid_NOVA=fopen([path_NOVA filename_NOVA]);
for i=1:2
  fgetl(fid_NOVA);
end
Nova_data=fscanf(fid_NOVA,'%g',[4,inf]);
fclose(fid_NOVA);
 
%remove double lines so X will be monotonic for interpolation
%L=find(diff(Nova_data(1,:))~=0);
%Nova_data=Nova_data(:,L);

Nova_UT_d=(Nova_data(1,:)-12)/60/60; % In the Diff GPS files time is GPS time not UT
Nova_lat_d =Nova_data(2,:);
Nova_long_d=Nova_data(3,:);
Nova_alt_d =Nova_data(4,:);

figure(9)
subplot(3,1,1)
plot(Nova_UT,Nova_long,Nova_UT_d,Nova_long_d)
ylabel('Longitude')
grid on
subplot(3,1,2)
plot(Nova_UT,Nova_lat,Nova_UT_d,Nova_lat_d)
ylabel('Latitude')
grid on
subplot(3,1,3)
plot(Nova_UT,Nova_alt,Nova_UT_d,Nova_alt_d)
ylabel('Altitude [m]')
grid on

i=find(Nova_UT_d<=max(Nova_UT) & Nova_UT_d>=min(Nova_UT));
Nova_lat= interp1(Nova_UT,Nova_lat,Nova_UT_d(i));
Nova_long= interp1(Nova_UT,Nova_long,Nova_UT_d(i));
Nova_alt= interp1(Nova_UT,Nova_alt,Nova_UT_d(i));

figure(10)
subplot(3,1,1)
plot(Nova_UT_d(i),Nova_long_d(i)-Nova_long)
ylabel('Longitude')
axis([-inf inf -0.001 0.001])
grid on
subplot(3,1,2)
plot(Nova_UT_d(i),Nova_lat_d(i)-Nova_lat)
ylabel('Latitude')
axis([-inf inf -0.001 0.001])
grid on
subplot(3,1,3)
plot(Nova_UT_d(i),Nova_alt_d(i)-Nova_alt)
ylabel('Altitude')
grid on