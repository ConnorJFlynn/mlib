clear all
close all
pathnamedef='c:\beat\data\spectro\*tracking_data.txt';
[filename,pathname]=uigetfile(pathnamedef,'Choose data file');
fid=fopen([pathname filename]);

month=str2num(filename(5:6));
day=str2num(filename(7:8));
year=str2num(filename(1:4));

%N  Time        Azim Angle  Azim Error  Elev Angle  Elev Error  Azim pos        Elev Pos    Count       Sigma       Pixel	
%0	4:14:36 PM	-144.238154	0.057853	43.802585	0.088079	-40066.153846	6083.692308	236.615385	2.060620	0

fgetl(fid);
[data]=fscanf(fid,'%i %2d:%2d:%g %s %f %f %f %f %f %f %f %f %i %i\n',[16,inf]);
fclose(fid);

record=data(1,:);
time=data(2,:)+data(3,:)/60+data(4,:)/60/60;
ii=find(data(5,:)==80 & data(2,:)~=12);%80 is P for PM
time(ii)=time(ii)+12;

Azi=-data(7,:)+90; %Flag and Barrel are 90 deg apart, Azi is wired reversed compared to usual convention

Azi_Err=data(8,:);
Ele=data(9,:);
Ele_Err=data(10,:);
Count=data(13,:);
Count_std=data(14,:);
Pixel=data(15,:);
Shutter=data(16,:);

Lambda=206.412+0.799856.*Pixel-5.1811e-6.*Pixel.^2-1.41576e-8.*Pixel.^3;

% compute the solar position is optional here
% use for Ames if not in file
n=length(record);
temp=ones(1,n)*293;
press=ones(1,n)*1013;
Longitude=ones(1,n)*-122.057;
Latitude=ones(1,n)*37.42;
UT=time+7;
[Az_Sun, Elev_Sun]=sun(Longitude,Latitude,day, month, year, UT,temp,press);

figure(1)
subplot(2,1,1)
plot(record,time)
xlabel('record')
ylabel('time')
subplot(2,1,2)
plot(record(1:end-1),diff(time)*3600,'.')
xlabel('record')
ylabel('time diff (sec)')

figure(2)
subplot(4,1,1)
plot(time,Azi)
ylabel('Azi(°)')
grid on
subplot(4,1,2)
plot(time,Azi_Err)
set(gca,'ylim',[-0.1 0.1]);
ylabel('AziErr(°)')
grid on
subplot(4,1,3)
plot(time,Ele)
ylabel('Ele(°)')
grid on
subplot(4,1,4)
plot(time,Ele_Err)
set(gca,'ylim',[-0.1 0.1]);
xlabel('time')
ylabel('EleErr(°)')
grid on

figure(3)
subplot(4,1,1)
plot(time,Azi,time,Az_Sun)
ylabel('Azi(°)')
subplot(4,1,2)
plot(time,Azi-Az_Sun)
%set(gca,'ylim',[-0.1 0.1]);
ylabel('AziErr(°)')
subplot(4,1,3)
plot(time,Ele,time,Elev_Sun)
ylabel('Ele(°)')
subplot(4,1,4)
plot(time,Ele-Elev_Sun)
%set(gca,'ylim',[1 1.5]);
grid on
xlabel('time')
ylabel('EleErr(°)')

figure(4)
subplot(3,1,1)
plot(time,Count)
ylabel('Count')
subplot(3,1,2)
plot(time,Count_std)
set(gca,'ylim',[0 200]);
grid on
xlabel('time')
ylabel('Std')
subplot(3,1,3)
plot(time,Count_std./Count)
set(gca,'ylim',[0 0.015]);
grid on
xlabel('time')
ylabel('Rel Std')