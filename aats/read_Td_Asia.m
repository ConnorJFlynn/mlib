%This reads the Dewpoint files from CIRPAS Twin Otter in ACE-Asia
%GPS time (s), UTC Time, Alt (m), Ps (mb), Palt (m), T (C), Td (C), Tdvaisala

function [UTC_time,GPS_Alt,h2o_EdgeTech,h2o_Vaisala]=read_Td_Asia(flt_no);

pathname='c:\beat\data\ACE-Asia\dewpoint\';
direc=dir(fullfile(pathname,[flt_no '*.txt']));
filename=direc.name;

data= DLMREAD([pathname filename],',',1,0);
data(data==-9999)=NaN;

ii=~isnan(data(:,2));
data=data(ii,:);

GPS_time=data(:,1);
UTC_time=data(:,2);
GPS_Alt =data(:,3)/1e3;
Press   =data(:,4);
Press_Alt=data(:,5)/1e3;
T        =data(:,6);
Td_EdgeTech=data(:,7);
Td_Vaisala=data(:,8);

UT_hh=fix(UTC_time/1e4);
UTC_time=UTC_time-UT_hh.*1e4;
UT_mm=fix(UTC_time/1e2);
UT_ss=UTC_time-UT_mm.*1e2;
UTC_time=UT_hh+UT_mm/60+UT_ss/60/60;

%check and fix day rollover
ii=find(diff(UTC_time)<-1);
UTC_time(ii+1:end)=UTC_time(ii+1:end)+24;

%calculate absolute humidity or mass concentration
[h2o_EdgeTech]=rho_from_Td(Td_EdgeTech,T,Press);
[h2o_Vaisala]=rho_from_Td(Td_Vaisala,T,Press);

figure(11)
subplot(4,1,1)
plot(UTC_time,GPS_Alt,UTC_time,Press_Alt)
legend('GPS','p')
ylabel('Altitude (km)')
subplot(4,1,2)
plot(UTC_time,Press)
ylabel('p (hPa)')
subplot(4,1,3)
plot(UTC_time,Td_EdgeTech,UTC_time,Td_Vaisala,UTC_time,T)
ylabel('T (\circC)')
legend('Td EdgeTech','Td Vaisala','T')
xlabel('UT')
subplot(4,1,4)
plot(UTC_time,h2o_EdgeTech,UTC_time,h2o_Vaisala)
ylabel('H2O dens [g/m^3]')
legend('EdgeTech','Vaisala')
xlabel('UT')
