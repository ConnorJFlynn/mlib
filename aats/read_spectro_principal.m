close all
clear all
pathnamedef='c:\beat\data\spectro\*skylight_principal.txt';
[filename,pathname]=uigetfile(pathnamedef,'Choose data file');
fid=fopen([pathname filename]);

month=str2num(filename(5:6));
day=str2num(filename(7:8));
year=str2num(filename(1:4));

%N  Time  Azim Angle  Azim Error  Elev Angle   Elev Error   Azim pos   Elev Pos   Count   Sigma  Pixel   Shutter	

fgetl(fid);
[data]=fscanf(fid,'%i %2d:%2d:%f %s %f %f %f %f %f %f %f %f %i %i\n',[16,inf]);
fclose(fid);

record=data(1,:);
time=data(2,:)+data(3,:)/60+data(4,:)/60/60;
ii=find(data(5,:)==80 & data(2,:)~=12);%80 is P for PM
time(ii)=time(ii)+12;

Azi=-data(7,:)+90; %Flag and Barrel are 90 deg apart, Azi is wired reversed comapred to usual convention

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
plot(time,record,'.-')
xlabel('time')
ylabel('record')
subplot(2,1,2)
plot(time(1:end-1),diff(time)*3600,'.')
xlabel('time')
ylabel('time diff (sec)')

figure(2)
subplot(4,1,1)
plot(time,Azi,'.-')
ylabel('Azi(°)')
grid on
subplot(4,1,2)
plot(time,Azi_Err,'.-')
set(gca,'ylim',[-10 10]);
ylabel('AziErr(°)')
grid on
subplot(4,1,3)
plot(time,Ele,'.-')
ylabel('Ele(°)')
set(gca,'ylim',[-1 181]);
grid on
subplot(4,1,4)
plot(time,Ele_Err,'.-')
set(gca,'ylim',[-10 10]);
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
semilogy(Ele,Count,'.-')
ylabel('Count')
xlabel('Elevation')
set(gca,'xlim',[-2 182]);

ii_dark=find(Shutter==0);
ii_dark_sun=ii_dark(1:9);
ii_dark_sky=ii_dark(11:19);
ii_sun=find(Shutter==-166);
ii_sky=find(Shutter==-332);

figure(5)
plot(record(ii_dark_sun),Count(ii_dark_sun),record(ii_dark_sky),Count(ii_dark_sky));
ylabel('Count')
xlabel('Record')
grid on
legend('dark sun','dark sky')

figure(6)
semilogy(Ele(ii_sun(1:10)),Count(ii_sun(1:10)),'b.-',...
         Ele(ii_sun(11:31)),Count(ii_sun(11:31)),'g.-',...
         Ele(ii_sun(32:41)),Count(ii_sun(32:41)),'r.-',...
         Ele(ii_sky),Count(ii_sky),'m.',...
         Ele(ii_dark_sun),Count(ii_dark_sun),'b.',...
         Ele(ii_dark_sky),Count(ii_dark_sky),'m.')
ylabel('Count')
xlabel('Elevation')
set(gca,'xlim',[-inf inf]);
set(gca,'ylim',[200 inf]);

figure(7)
%dark subtraction
Count(ii_sun)=Count(ii_sun)-mean(Count(ii_dark_sun));
Count(ii_sky)=Count(ii_sky)-mean(Count(ii_dark_sky));
ZA=90-Ele;
semilogy(ZA(ii_sun(1:10)),Count(ii_sun(1:10)),'b.-',...
         ZA(ii_sun(11:31)),Count(ii_sun(11:31)),'g.-',...
         ZA(ii_sun(32:41)),Count(ii_sun(32:41)),'r.-',...
         ZA(ii_sky),Count(ii_sky),'m.')
ylabel('Count')
xlabel('Zenith Angle')
set(gca,'xlim',[-inf inf]);
set(gca,'ylim',[1 inf]);

figure(8)
%scattering angle
%find solar elevation
SZA1=mean(ZA(ii_sun(1:10)))
SZA2=mean(ZA(ii_dark_sun))
SZA3=mean(ZA(ii_sun(32:41)))
SZA4=mean(ZA(ii_dark_sky))
SZA=mean([SZA1,SZA2,SZA3,SZA4]);

ZA=ZA(ii_sky);
Count=Count(ii_sky);
ii_below=find(ZA>=SZA);
ii_above=find(ZA<SZA);

SA_below=ZA(ii_below)-SZA;
Count_below=Count(ii_below)
SA_above=SZA-ZA(ii_above);
Count_above=Count(ii_above);
semilogy(SA_below,Count_below,'.-',SA_above,Count_above,'.-')
text(10,1800,sprintf('wvl=%4.1f nm',Lambda(1)),'FontSize',12);
text(10,1200,sprintf('SZA=%4.1f deg',SZA),'FontSize',12);
ylabel('Counts')
xlabel('Scattering Angle')
set(gca,'xlim',[0 inf]);
set(gca,'ylim',[1 inf]);
grid on
