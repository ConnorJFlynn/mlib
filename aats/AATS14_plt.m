%plots raw AATS-14 data
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%
UT_start=0;
UT_end=24;
disp(sprintf('%g-%g UT',UT_start,UT_end))
source='Can';
disp(source)
%%%%%%%%%%%%%%%%%%%%%%%%%%

switch source
  case 'Can', 
     [day,month,year,UT,Mean_volts,Sd_volts,press,Press_Alt,Latitude,Longitude,Heading...
      Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site]=Ames14_raw('d:\beat\data\','none');,
     %Apply time boundaries
     L=(UT>=UT_start & UT<=UT_end);,
     UT=UT(L);,
     Mean_volts=Mean_volts(:,L);,
     Sd_volts=Sd_volts(:,L);,
     press=press(:,L);,
     Press_Alt=Press_Alt(L);,
     Latitude=Latitude(L);,
     Longitude=Longitude(L);,
     Temperature=Temperature(:,L);,
     Az_err=Az_err(L);,
     Az_pos=Az_pos(L);,
     Elev_err=Elev_err(L);,
     Elev_pos=Elev_pos(L);,  
  case 'Laptop',
     [day,month,year,UT_Laptop,UT_Can,airmass,Temperature,Latitude,Longitude,...
     Press_Alt,press,Heading,Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
     ScanFreq,AvePeriod,RecInterval,site,path,filename]=Ames14_Laptop('d:\beat\data\');,
     UT=UT_Laptop;,
     clear UT_Laptop;,
     %Apply time boundaries
     L=(UT>=UT_start & UT<=UT_end);,
     UT=UT(L);,
     UT_Can=UT_Can(L);
     airmass=airmass(L);
     Mean_volts=Mean_volts(:,L);,
     Sd_volts=Sd_volts(:,L);,
     press=press(:,L);,
     Press_Alt=Press_Alt(L);,
     Latitude=Latitude(L);,
     Longitude=Longitude(L);,
     Temperature=Temperature(:,L);,
     Az_err=Az_err(L);,
     Az_pos=Az_pos(L);,
     Elev_err=Elev_err(L);,
     Elev_pos=Elev_pos(L);,
     Heading=Heading(L);,
     ScanFreq=ScanFreq(L);,
     AvePeriod=AvePeriod(L);
     RecInterval=RecInterval(L);,
  end
  
[m,n]=size(UT);
temp=ones(n,1)*282.0;

Altitude=Press_Alt;

%replace navigation data by normal NOVA GPS data
%read_Nova_or_tv;
%Longitude=Nova_long;
%Latitude=Nova_lat;
%Altitude=Nova_alt/1000;
  
% if  press data need to be replaced
%UW_read_new
%press=UW_press1'+14;

%Press_Alt=288.15/6.5*(1-((press')/1013.25).^(1/5.255876114));%Pressure Altitude according to J. Livingston as long as Press_Alt <=11km
%Altitude=Press_Alt;

%replace pressure data by those in the met files (less noisy)
%read_met
%press=Met_press';
%temp=Met_temp'+273.15;
%Press_Alt=288.15/6.5*(1-((press')/1013.25).^(1/5.255876114));%Pressure Altitude according to J. Livingston as long as Press_Alt <=11km
%Altitude=Press_Alt;

% replace navigation data by differentially corrected NOVA GPS data
%Nova_GPScorr_read;
%Longitude=Nova_long;
%Latitude=Nova_lat;
%Altitude=Nova_alt/1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the solar position is optional here
[Az_Sun, Elev_Sun]=sun(Longitude,Latitude,day, month, year, UT,temp',press);

figure(1)
title(sprintf('%s %2i.%2i.%2i',site,day,month,year));
subplot(6,1,1)
plot(UT,Mean_volts)
axis([-inf inf 0.00 7.5])
ylabel('Signals(V)')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year));

subplot(6,1,2)
plot(UT,Sd_volts./Mean_volts*100)
axis([-inf inf 0 10])
ylabel('Stdev(%)')

subplot(6,1,3)
plot(UT,Altitude)
axis([-inf inf 0 4])
ylabel('Altitude(km)')

subplot(6,1,4)
plot(UT,Temperature(1,:))
axis([-inf inf 44 48])
ylabel('Hot T(\circC)')

subplot(6,1,5)
plot(UT,Temperature(2,:))
axis([-inf inf -inf inf])
ylabel('Cold1 T(\circC)')

subplot(6,1,6)
plot(UT,Temperature(3,:))
axis([-inf inf -inf inf])
ylabel('Cold2 T(\circC)')
xlabel('UT')

figure(2)
subplot(6,1,1)
plot(UT,Az_pos)
axis([-inf inf 0 360])
ylabel('Azimuth(\circ)')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year));

subplot(6,1,2)
plot(UT,Elev_pos)
axis([-inf inf -inf inf])
ylabel('Elevation (\circ)')

subplot(6,1,3)
plot(UT,Az_err)
axis([-inf inf -0.5 0.5])
ylabel('Az Err (\circ)')

subplot(6,1,4)
plot(UT,Elev_err)
axis([-inf inf -1 1])
ylabel('Ele Err (\circ)')

subplot(6,1,5)
plot(UT,Latitude)
axis([-inf inf -inf inf])
ylabel('Latitude (\circ)')

subplot(6,1,6)
plot(UT,Longitude)
axis([-inf inf -inf inf])
ylabel('Longitude(\circ)')
xlabel('UT')

figure(3)
subplot(1,2,1)
plot3(Longitude,Latitude,Altitude)
xlabel('Longitude (\circE)','FontSize',12)
ylabel('Latitude (\circN)','FontSize',12)
zlabel('Altitude (km)','FontSize',12)
if strcmp(site,'ACE-2')
   hold on
%   map3d
   map
%   plot([-11.874 -11.883 ],[29.314 29.324],'r*-') %ship position on July 10 Pelican fly-by
end  
hold off
axis([-17 -15.5 27.5 29 0 4])
grid on
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',12);
set(gca,'FontSize',12)
%axis square
view([-55 15])

subplot(1,2,2)
%plot([-11.874 -11.883 ],[29.314 29.324],'r*-') %ship position on July 10 Pelican fly-by
plot(Longitude,Latitude)
xlabel('Longitude (\circE)','FontSize',12)
ylabel('Latitude (\circN)','FontSize',12)
%axis square
grid on
axis([-17 -15 27 29])
set(gca,'FontSize',12)
%title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',12);
if strcmp(site,'ACE-2')
   hold on
   map
   map3d
   plot(Longitude,Latitude)
   %   plot([-11.874 -11.883 ],[29.314 29.324],'r*-') %ship position on July 10 Pelican fly-by
   hold off
end  


figure(5)
orient landscape
subplot(1,2,1)
plot(Temperature(1,:),Mean_volts(1:7,:),'.')
xlabel('Temperature','FontSize',14)
ylabel('Dark Signals[V]','FontSize',14)
grid on
legend('380.3','448.25','452.97','499.4','524.7','605.4','666.8')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',14);
%set(gca,'FontSize',12,'ylim',[0.0 0.05],'xlim',[43.5 47.5])

subplot(1,2,2)
plot(Temperature(1,:),Mean_volts(8:14,:),'.')
xlabel('Temperature','FontSize',14)
ylabel('Dark Signals[V]','FontSize',14)
grid on
legend('711.8','778.5','864.4','939.5','1018.7','1059','1557.5')	
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',14);
set(gca,'FontSize',12,'ylim',[0.0 0.05])
%,'xlim',[43.5 47.5])

figure(6)
orient landscape
subplot(1,2,1)
plot(UT,Mean_volts(1:7,:))
xlabel('UT','FontSize',14)
ylabel('Signal [V]','FontSize',14')
grid on
legend('380.3','448.25','452.97','499.4','524.7','605.4','666.8')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',14);
%set(gca,'FontSize',12,'ylim',[0.00 0.05])

subplot(1,2,2)
plot(UT,Mean_volts(8:14,:))
grid on
xlabel('UT','FontSize',14)
ylabel('Signal [V]','FontSize',14)
legend('711.8','778.5','864.4','939.5','1018.7','1059','1557.5')	
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',14);
set(gca,'FontSize',12,'ylim',[0.00 0.05])

figure(7)
orient landscape
plot(UT,Temperature(1,:))
ylabel('Hot T(\circC)','FontSize',14)
xlabel('UT','FontSize',14)
title(sprintf('%s %2i.%2i.%2i',site,day,month,year),'FontSize',14);
%set(gca,'FontSize',12,'ylim',[43 48])
grid on

switch source
case 'Laptop'
 figure(7)
 plot(UT,3600*(UT_Can-UT))
 xlabel('UT from Laptop')
 ylabel('Delta T (sec)')
end

figure(8)
orient landscape
subplot(3,1,1)
plot(UT,Elev_err,'go-','MarkerSize',4)
set(gca,'xlim',[18.55 18.7])
set(gca,'ylim',[-0.5 .5])
set(gca,'ytick',[-0.5:0.25:0.5]);
grid on
ylabel('Elev Err (\circ)')
title(sprintf('%s %2i/%2i/%2i' ,site,month,day,year));

subplot(3,1,2)
plot(UT,Az_err,'bo-','MarkerSize',4)
set(gca,'xlim',[18.55 18.7])
set(gca,'ylim',[-0.5 0.5])
set(gca,'ytick',[-.5:.1:.5]);
grid on
ylabel('Azi Err (\circ)')

subplot(3,1,3)
plot(UT,Heading,'ko-','MarkerSize',4)
set(gca,'xlim',[18.55 18.7])
set(gca,'ylim',[0 360])
grid on
ylabel('Aircraft Heading (\circ)')

%subplot(5,1,4)
%Data_Rate=diff(UT*3600);
%Turn_Rate=diff(Heading)./Data_Rate;
%ii=find(Turn_Rate>20);
%jj=find(Turn_Rate<-20);
%Turn_Rate(ii)=Turn_Rate(ii)-(360./Data_Rate(ii)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over
%Turn_Rate(jj)=Turn_Rate(jj)+(360./Data_Rate(jj)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over
%plot(UT(1:end-1),Turn_Rate,'k-o','MarkerSize',4)
%set(gca,'xlim',[18.55 18.77])
%set(gca,'ytick',[-3:1:3]);
%grid on
%ylabel('Turning Rate \circ/sec')

%subplot(6,1,5)
%Elev_Rate=diff(Elev_pos)./Data_Rate;
%plot(UT(1:end-1),Elev_Rate,'k-o','MarkerSize',4)
%set(gca,'xlim',[23.43 23.45])
%set(gca,'xlim',[22.2 22.4])
%set(gca,'xlim',[-inf 22.3])
%set(gca,'ylim',[-10 10])
%set(gca,'ytick',[-10:2:10]);
%grid on
%ylabel('Elev. Change \circ/sec')
%xlabel('UTC(hrs)')

%subplot(5,1,5)
%Az_Rate=diff(Az_pos)./Data_Rate;
%plot(UT(1:end-1),Az_Rate,'k-o','MarkerSize',4)
%set(gca,'xlim',[18.55 18.77])
%set(gca,'xlim',[-inf inf])
%set(gca,'ylim',[-15 15])
%set(gca,'ytick',[-15:5:15]);
%grid on
%ylabel('Az. Change \circ/sec')
%xlabel('UTC(hrs)')


%set(gca,'FontSize',12,'ylim',1e3*[0.032 0.042])

%This is a file written to correct flux data
%L=find(abs(Elev_err)<0.5 & abs(Az_err)<0.5);

%fid=fopen('d:\beat\data\ace-2\flux\az_ele.txt','w')
%fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f \n',...
%   [UT(L)',Altitude(L)',Az_pos(L)',Az_err(L)',Elev_pos(L)',Elev_err(L)',Az_Sun(L)', Elev_Sun(L)']');
%fclose(fid)


figure(9)
subplot(2,1,1)
plot(UT(L),Elev_pos(L),UT(L),Elev_Sun(L))
set(gca,'ylim',[0 90])
grid on
xlabel('UT')
ylabel('Elevation [\circ]')
axis([-inf inf -inf inf])
subplot(2,1,2)
plot(UT(L),Elev_Sun(L)-Elev_pos(L))
set(gca,'ylim',[-20 20])
grid on
xlabel('UT')
ylabel('Difference [\circ]')
axis([-inf inf -inf inf])

figure(10)
subplot(2,1,1)
plot(UT(L),Az_pos(L),UT(L),Az_Sun(L))
grid on
xlabel('UT')
ylabel('Azimuth [\circ]')
axis([-inf inf -inf inf])
subplot(2,1,2)
plot(UT(L),Az_Sun(L)-Az_pos(L))
grid on
xlabel('UT')
ylabel('Difference [\circ]')
axis([-inf inf -inf inf])


