close all

%opens Nova data file
[filename_NOVA,path_NOVA]=uigetfile('d:\beat\data\ACE-2\Nova\*.pos.vel.txt','Choose NOVA File', 0, 0);
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

%opens Transvector data file
[filename_tv,path_tv]=uigetfile('d:\beat\data\ACE-2\TransVector\*.pos.vel.txt','Choose TransVector File', 0, 0);
fid_tv=fopen([path_tv filename_tv]);
for i=1:2
  fgetl(fid_tv);
end
tv_data=fscanf(fid_tv,'%g',[7,inf]);
fclose(fid_tv);
 
%remove double lines so X will be monotonic for interpolation
%L=find(diff(Nova_data(2,:))~=0);
%Nova_data=Nova_data(:,L);

tv_UT  =mod(tv_data(1,:),86400)/60/60;
tv_lat =tv_data(2,:);
tv_long=tv_data(3,:);
tv_alt =tv_data(4,:);

figure(1)
subplot(3,1,1)
plot(tv_UT,tv_long,Nova_UT,Nova_long)
ylabel('Longitude')
grid on
subplot(3,1,2)
plot(tv_UT,tv_lat,Nova_UT,Nova_lat)
ylabel('Latitude')
grid on
subplot(3,1,3)
plot(tv_UT,tv_alt,Nova_UT,Nova_alt)
ylabel('Altitude [m]')
grid on

i=find(tv_UT<=max(Nova_UT) & tv_UT>=min(Nova_UT));
Nova_lat= interp1(Nova_UT,Nova_lat,tv_UT(i));
Nova_long= interp1(Nova_UT,Nova_long,tv_UT(i));
Nova_alt= interp1(Nova_UT,Nova_alt,tv_UT(i));

figure(2)
subplot(3,1,1)
plot(tv_UT(i),tv_long(i)-Nova_long)
ylabel('Longitude')
axis([-inf inf -inf inf])
grid on
subplot(3,1,2)
plot(tv_UT(i),tv_lat(i)-Nova_lat)
ylabel('Latitude')
axis([-inf inf -inf inf])
grid on
subplot(3,1,3)
plot(tv_UT(i),tv_alt(i)-Nova_alt)
ylabel('Altitude [m]')
axis([-inf inf -inf inf])
grid on