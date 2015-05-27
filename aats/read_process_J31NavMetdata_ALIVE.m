%read_process_J31NavMetdata_ALIVE
clear all
close all

% HEADER (AMES)
% checksum
% date
% time
% latitude (deg)
% longitude (deg)
% pitch (deg)
% roll (deg)
% heading (deg)
% altitude (m)
% static pressure (adjusted) (hPa)
% static temperature (adjusted) (deg C)
% relative humidity (%)  RH is incorrect in the ALIVE files as it was not corrected
% track (deg)
% speed (km/hr)
% pressure2 (wing) (total p, hPa)
% pressure1 (stat port) (Faulty original calibration, do not use)
% temperature (total temperature deg C)
% TAIL (Ames)

pathnamedef='c:\beat\data\ALIVE\NavMet\20050910\*concat*.txt';
[filename,pathname]=uigetfile(pathnamedef,'Choose navmet data file');
fid=fopen([pathname filename]);

month=str2num(filename(5:6));
day=str2num(filename(7:8));
year=str2num(filename(1:4));

[datain,count]=fscanf(fid,'AMES %d %2d/%2d/%2d %2d:%2d:%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f AMES\r\n',[21,inf]);

iadj24=0;
UT=datain(5,:)+datain(6,:)/60.+datain(7,:)/3600.;
for i=1:length(UT)-1,
    if UT(i+1)<1 & UT(i)>23
        iadj24=1;
        isav=i+1;
        break
    end
end
if iadj24==1
    for i=isav:length(UT),
        UT(i)=UT(i)+24;
    end
end
lat=datain(8,:);
lon=datain(9,:);
pitch=datain(10,:);
roll=datain(11,:);
heading=datain(12,:);
GPSkm=datain(13,:)/1000;
Pstat=datain(14,:);
TempCstat=datain(15,:);
%RHpercent_meas_corrected=datain(16,:); %this would be in files starting with MILAGRO/INTEX-B
RH=datain(16,:); %uncorrected RH
track=datain(17,:);
speed=datain(18,:);
Ptot=datain(19,:); %total
Pstat_wrong=datain(20,:); %measured static pressure before Pilewskie correction
TempCtot=datain(21,:);
%RH=datain(22,:); %uncorrected RH, this would be in files starting with MILAGRO/INTEX-B

fclose(fid);

%calculate corrected pressure even though already in file
coeff=[3.58026e-12  -1.56561e-08  2.74849e-05  -0.0244111  12.1086 -2109.13]; % to correct pressure 2 from Warren Gore 1/13/05
Pstat_calc=polyval(coeff,Pstat_wrong);
figure(1)

%calculate Tstat even though already in file
spec_heat_ratio=1.4;
gamma=(spec_heat_ratio-1.)/spec_heat_ratio;
tempCstat_calc_correct=(TempCtot+273.15).*(Pstat./Ptot).^gamma - 273.15;

figure(1)
subplot(2,1,1)
plot(UT,TempCstat-tempCstat_calc_correct,'.')
ylabel('Tstat in file - Tstat calc')
xlabel('UT')
subplot(2,1,2)
plot(UT,Pstat-Pstat_calc,'.')
ylabel('Pstat in file - Pstat in file')
xlabel('UT')

%calculate vapor pressure 3 ways
vp_Boegel=vappres_Boegel(tempCstat_calc_correct+273.15);
vp_Smithonian=vappres(tempCstat_calc_correct+273.15);
vp_Vaisala=vappres_Vaisala(tempCstat_calc_correct+273.15);

figure(2)
subplot(2,1,1)
plot(UT,vp_Vaisala, UT,vp_Smithonian,UT,vp_Boegel)
legend('Vaisala','Smithonian','Boegel')
ylabel('Saturation Pressure')
xlabel('UT')
subplot(2,1,2)
plot(UT,vp_Vaisala-vp_Boegel,UT,vp_Smithonian-vp_Boegel)
legend('Vaisala-Boegel','Smithonian-Boegel');
ylabel('Differences')
xlabel('UT')

%calculate corrected RH 3 ways
RH_correct_Boegel=RH.*vappres_Boegel(TempCtot+273.15)./vappres_Boegel(tempCstat_calc_correct+273.15);
RH_correct_Smithonian=RH.*vappres(TempCtot+273.15)./vappres(tempCstat_calc_correct+273.15);
RH_correct_Vaisala=RH.*vappres_Vaisala(TempCtot+273.15)./vappres_Vaisala(tempCstat_calc_correct+273.15);

figure(3)
subplot(2,1,1)
plot(UT,RH_correct_Vaisala, UT,RH_correct_Smithonian,UT,RH_correct_Boegel)
legend('Vaisala','Smithonian','Boegel')
ylabel('RH')
xlabel('UT')
subplot(2,1,2)
plot(UT,RH_correct_Vaisala-RH_correct_Boegel,UT,RH_correct_Smithonian-RH_correct_Boegel)
legend('Vaisala-Boegel','Smithonian-Boegel');
ylabel('Differences')
xlabel('UT')

%This computes water vapor density according to Boegel, 1977, p.108
b=(8.082-tempCstat_calc_correct/556).*tempCstat_calc_correct./(256.1+tempCstat_calc_correct);
a=13.233*(1+1e-8.*Pstat.*(570-tempCstat_calc_correct))./(tempCstat_calc_correct+273.15);

watvap_density_gm3_Boegel=RH_correct_Boegel.*a.*10.^b;
watvap_density_gm3_Smithonian=RH_correct_Smithonian.*a.*10.^b;
watvap_density_gm3_Vaisala=RH_correct_Vaisala.*a.*10.^b;

figure(4)
subplot(2,1,1)
plot(UT,watvap_density_gm3_Vaisala, UT,watvap_density_gm3_Smithonian,UT,watvap_density_gm3_Boegel)
legend('Vaisala','Smithonian','Boegel')
ylabel('Density (g/m3)')
xlabel('UT')
subplot(2,1,2)
plot(UT,watvap_density_gm3_Vaisala-watvap_density_gm3_Boegel,UT,watvap_density_gm3_Smithonian-watvap_density_gm3_Boegel)
legend('Vaisala-Boegel','Smithonian-Boegel');
ylabel('Differences')
xlabel('UT')

tempClim=[-20 40];
zkmlim=[0 8];
RHlim=[0 110];
pmblim=[400 1100];
UTlim=[-inf inf];

figure(5)
subplot(4,1,1)
plot(UT,lat,'b-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
grid on
ylabel('Latitude (deg)','fontsize',14)
title(sprintf('J31 flight date: %2d/%2d/%4d',month,day,year),'fontsize',14)
subplot(4,1,2)
plot(UT,lon,'r-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
grid on
ylabel('Longitude (deg)','fontsize',14)
subplot(4,1,3)
plot(UT,GPSkm,'k-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
set(gca,'ylim',[0 8])
grid on
ylabel('GPS altitude (km)','fontsize',14)
subplot(4,1,4)
%plot(UT,RH_meas_corrected,'r-') %this would be in MILAGRO files
plot(UT,RH,'b-',UT,RH_correct_Boegel,'r-')
legend('RH meas','RH corrected');
ylabel('RH (%)','fontsize',14)
xlabel('UT (hr)','fontsize',14)
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
set(gca,'ylim',RHlim)
grid on

figure(6)
subplot(4,1,1)
plot(UT,GPSkm,'k-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',zkmlim)
ylabel('GPS altitude (km)','fontsize',14)
title(sprintf('J31 flight date: %2d/%2d/%4d',month,day,year),'fontsize',14)
subplot(4,1,2)
plot(UT,speed,'m','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',[0 inf])
ylabel('GPS speed (km/h)','fontsize',14)
xlabel('UT (hr)','fontsize',14)
subplot(4,1,3)
plot(UT,Ptot,'r','linewidth',2)
hold on
plot(UT,Pstat,'b-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',pmblim,'ytick',[pmblim(1):200:pmblim(2)])
ylabel('Pressure (mb)','fontsize',14)
hleg2=legend('Ptotal','Pstatic (calc)');
set(hleg2,'fontsize',12)
subplot(4,1,4)
plot(UT,TempCtot,'r-','linewidth',2)
hold on
plot(UT,TempCstat,'b-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',tempClim)
hleg3=legend('Total Temp','Static Temp');
set(hleg3,'fontsize',12)
ylabel('Temp (deg C)','fontsize',14)

figure(7)
subplot(3,1,1)
plot(UT,heading,UT,track)
legend('heading','track')
xlabel('UT')
ylabel('deg')
subplot(3,1,2)
plot(UT,roll)
xlabel('UT')
ylabel('roll (deg)')
subplot(3,1,3)
plot(UT,pitch)
xlabel('UT')
ylabel('pitch (deg)')

%Rewrite file
% HEADER (AMES)
% checksum
% date
% time
% latitude (deg)
% longitude (deg)
% pitch (deg)
% roll (deg)
% heading (deg)
% altitude (m)
% static pressure (adjusted) (hPa)
% static temperature (adjusted) (deg C)
% relative humidity (%) (adjusted)
% track (deg)
% speed (km/hr)
% pressure2 (wing) (total p, hPa)
% water vapor density (g/m3)
% temperature (total temperature deg C)
% TAIL (Ames)

dataout=datain;
dataout(16,:)=RH_correct_Boegel; %replace RH
dataout(20,:)=watvap_density_gm3_Boegel; %replace faulty pressure with water vapor density

filewrite='Navmet_rewrite.txt';  
fidwrite=fopen([pathname filewrite],'w');
fprintf(fidwrite,'AMES %d %02d/%02d/%02d %02d:%02d:%04.1f %9.5f %10.5f %7.2f %7.2f %7.2f %7.2f %7.2f %6.1f %6.1f %7.1f %6.1f %7.2f %9.5f %6.1f AMES\r\n',dataout);
fclose(fidwrite);