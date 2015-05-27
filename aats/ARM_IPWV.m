read_ARM_IPWV

%Plot overall IPWV
figure(1)
orient landscape
plot(DOY_etl1(IPWV_etl1~=-9.99),IPWV_etl1(IPWV_etl1~=-9.99),'k.',...
     DOY_etl2(IPWV_etl2~=-9.99),IPWV_etl2(IPWV_etl2~=-9.99),'r.',...
     DOY_CART_MWR,IPWV_CART_MWR,'g.',...
     DOY_mfrsr(IPWV_mfrsr~=-999.9),IPWV_mfrsr(IPWV_mfrsr~=-999.9),'y.',...
     DOY_Cimel,IPWV_Cimel,'c.-',...
     DOY_bbss,IPWV_bbss,'ko',...
     DOY_gps_cf,IPWV_gps_cf,'g',...
     DOY_gps_lamont,IPWV_gps_lamont,'m',...
     DOY_AATS6,IPWV_AATS6,'b.')
axis([-inf inf 0 5])
ylabel('Columnar Water Vapor [cm]')
xlabel('Day of Year 1997')
legend('ETL1','ETL2','CART MWR','MFRSR','Cimel','BBSS','GPS CF','GPS Lamont','AATS-6')

%Plot overall IPWV without MWRs
figure(2)
orient landscape
plot(DOY_mfrsr(IPWV_mfrsr~=-999.9),IPWV_mfrsr(IPWV_mfrsr~=-999.9),'y.',...
     DOY_Cimel,IPWV_Cimel,'c.',...
     DOY_bbss,IPWV_bbss,'ko',...
     DOY_gps_cf,IPWV_gps_cf,'g',...
     DOY_gps_lamont,IPWV_gps_lamont,'m',...
     DOY_AATS6,IPWV_AATS6,'b.')
axis([-inf inf 0 5])
ylabel('Columnar Water Vapor [cm]')
xlabel('Day of Year 1997')

%Compare both GPS the times in both files match exactly. Data rate is every half hour for both GPS
range=[0:6];
figure(3)
orient landscape
subplot(2,2,1)
y=interp1(DOY_gps_lamont,IPWV_gps_lamont,DOY_gps_cf,'nearest');
x=IPWV_gps_cf;
[p,S] = polyfit(x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) GPS@Lamont')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf,x-y,'.')
ylabel('IPWV(cm) GPS@CF - GPS@Lamont')
xlabel('Day of Year 1997')
text(256,-0.5,sprintf('mean = %5.3f cm',mean(x-y)))
text(256,-0.6,sprintf('stdev= %5.3f cm',std(x-y)))
y=interp1(DOY_gps_lamont,DOY_gps_lamont,DOY_gps_cf,'nearest');
subplot(2,2,3)
plot(DOY_gps_cf,(DOY_gps_cf-y)*24*60,'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare BBSS with GPS_CF. Data rate is every half hour for GPS, every 3 hours for BBSS
figure(4)
orient landscape
subplot(2,2,1)
x=interp1(DOY_gps_cf,IPWV_gps_cf,DOY_bbss,'nearest');
y=IPWV_bbss;
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) BBSS')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_bbss,x-y,'.')
ylabel('IPWV(cm) GPS@CF - BBSS ')
xlabel('Day of Year 1997')
text(270,-0.4,sprintf('mean = %5.3f cm',mean(x-y)))
text(270,-0.5,sprintf('stdev= %5.3f cm',std(x-y)))
y=interp1(DOY_gps_cf,DOY_gps_cf,DOY_bbss,'nearest');
subplot(2,2,3)
plot(DOY_bbss,(DOY_bbss-y)*24*60,'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare  AATS-6 with GPS_CF. Data rate is every half hour for GPS, every 12 sec for AATS-6
figure(5)
orient landscape
y=interp1(DOY_AATS6,DOY_AATS6,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.2);
subplot(2,2,1)
y=interp1(DOY_AATS6,IPWV_AATS6,DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) AATS-6')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - AATS6 ')
xlabel('Day of Year 1997')
text(265,-0.4,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.5,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare Cimel with GPS_CF. Data rate is every half hour for GPS, every 15 min for Cimel
figure(6)
orient landscape
i=find(diff(DOY_Cimel)~=0);
DOY_Cimel=DOY_Cimel(i);
IPWV_Cimel=IPWV_Cimel(i);
y=interp1(DOY_Cimel,DOY_Cimel,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=10);
subplot(2,2,1)
y=interp1(DOY_Cimel,IPWV_Cimel,DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) Cimel')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - Cimel')
xlabel('Day of Year 1997')
text(265,-0.7,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.8,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare MFRSR with GPS_CF. Data rate is every half hour for GPS, every minute for MFRSR
figure(7)
orient landscape
y=interp1(DOY_mfrsr(IPWV_mfrsr~=-999.9),DOY_mfrsr(IPWV_mfrsr~=-999.9),DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.9);
subplot(2,2,1)
y=interp1(DOY_mfrsr(IPWV_mfrsr~=-999.9),IPWV_mfrsr(IPWV_mfrsr~=-999.9),DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) MFRSR')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - MFRSR')
xlabel('Day of Year 1997')
text(265,-0.7,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.8,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare CART_MWR with GPS_CF. Data rate is every half hour for GPS, every 20 seconds for CART_MWR
figure(8)
orient landscape
ILW=interp1(DOY_CART_MWR(IPWV_CART_MWR~=-9999),ILW_CART_MWR(IPWV_CART_MWR~=-9999),DOY_gps_cf,'nearest');
y=interp1(DOY_CART_MWR(IPWV_CART_MWR~=-9999),DOY_CART_MWR(IPWV_CART_MWR~=-9999),DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.3 & abs(ILW)<=0.2);
subplot(2,2,1)
y=interp1(DOY_CART_MWR(IPWV_CART_MWR~=-9999),IPWV_CART_MWR(IPWV_CART_MWR~=-9999),DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) CART MWR')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - CART MWR')
xlabel('Day of Year 1997')
text(265,-0.7,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.8,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),ILW(i),'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on

%Compare NOAA_ETL1 with GPS_CF. Data rate is every half hour for GPS, every 90 seconds for NOAA_ETL1
figure(9)
orient landscape
ILW=interp1(DOY_etl1(IPWV_etl1~=-9.99),ILW_etl1(IPWV_etl1~=-9.99),DOY_gps_cf,'nearest');
y=interp1(DOY_etl1(IPWV_etl1~=-9.99),DOY_etl1(IPWV_etl1~=-9.99),DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1 & abs(ILW)<=0.2);
subplot(2,2,1)
y=interp1(DOY_etl1(IPWV_etl1~=-9.99),IPWV_etl1(IPWV_etl1~=-9.99),DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) ETL1 MWR')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - ETL1 MWR')
xlabel('Day of Year 1997')
text(265,-0.5,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.6,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),ILW(i),'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on

%Compare NOAA_ETL2 with GPS_CF. Data rate is every half hour for GPS, every 90 seconds for NOAA_ETL1
figure(10)
orient landscape
ILW=interp1(DOY_etl2(IPWV_etl2~=-9.99),ILW_etl2(IPWV_etl2~=-9.99),DOY_gps_cf,'nearest');
y=interp1(DOY_etl2(IPWV_etl2~=-9.99),DOY_etl2(IPWV_etl2~=-9.99),DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1 & ILW<=0.2);
subplot(2,2,1)
y=interp1(DOY_etl2(IPWV_etl2~=-9.99),IPWV_etl2(IPWV_etl2~=-9.99),DOY_gps_cf(i),'nearest');
x=IPWV_gps_cf(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
text(3.1,2.1,sprintf('y = %5.3f x + %5.3f',p))
text(3.1,1.7,sprintf('r²= %5.3f',r.^2))
text(3.1,1.3,sprintf('RMSE = %5.3f',rmse))
text(3.1,1.0,sprintf('n = %5i',n))
xlabel('IPWV(cm) GPS@CF')
ylabel('IPWV(cm) ETL2 MWR')
axis([0 6 0 6])
subplot(2,2,2)
plot(DOY_gps_cf(i),x-y,'.')
ylabel('IPWV(cm) GPS@CF - ETL2 MWR')
xlabel('Day of Year 1997')
text(265,-0.4,sprintf('mean = %5.3f cm',mean(x-y)))
text(265,-0.5,sprintf('stdev= %5.3f cm',std(x-y)))
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),ILW(i),'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on
