read_ARM_IPWV
close all

%Plot overall IPWV
figure(1)
plot(DOY_etl1,IPWV_etl1,'k.',...
     DOY_etl2,IPWV_etl2,'r.',...
     DOY_CART_MWR,IPWV_CART_MWR,'g.',...
     DOY_mfrsr,IPWV_mfrsr,'y.',...
     DOY_mfrsr_Joe,IPWV_mfrsr_Joe,'m.',... 
     DOY_Cimel,IPWV_Cimel,'c*',...
     DOY_bbss,IPWV_bbss,'ko',...
     DOY_gps_cf,IPWV_gps_cf,'g',...
     DOY_gps_lamont,IPWV_gps_lamont,'m',...
     DOY_AATS6,IPWV_AATS6,'b.',...
     DOY_GSFC_lidar,IPWV_GSFC_lidar,'r^',...
     DOY_CART_lidar,IPWV_CART_lidar,'mv')  
  axis([270.5 271 0 3])
  orient landscape
set(gca,'FontSize',14)
ylabel('Columnar Water Vapor [cm]','FontSize',14)
xlabel('Day of Year 1997','FontSize',14)
legend('ETL1','ETL2','CART MWR','MFRSR Jim','MFRSR Joe','Cimel','BBSS','GPS CF','GPS Lamont','AATS-6','GSFC Lidar','CART Lidar')
grid on

stop

% Do averaging

range=[0:6];
DOY_start=257;
DOY_end=279;
DOY_delta=0.5/24;

pause
ii=1;

for DOY_i=DOY_start:DOY_delta:DOY_end
   DOY_i
   
   DOY_etl1_ave(ii)=DOY_i;
   IPWV_etl1_ave(ii)=mean(IPWV_etl1(DOY_etl1>=DOY_i & DOY_etl1<DOY_i+DOY_delta));
   ILW_etl1_ave(ii)=mean(ILW_etl1(DOY_etl1>=DOY_i & DOY_etl1<DOY_i+DOY_delta));
   N_etl1_ave(ii)=size(IPWV_etl1(DOY_etl1>=DOY_i & DOY_etl1<DOY_i+DOY_delta),2);
   
   DOY_etl2_ave(ii)=DOY_i;
   IPWV_etl2_ave(ii)=mean(IPWV_etl2(DOY_etl2>=DOY_i & DOY_etl2<DOY_i+DOY_delta));
   ILW_etl2_ave(ii)=mean(ILW_etl2(DOY_etl2>=DOY_i & DOY_etl2<DOY_i+DOY_delta));
   N_etl2_ave(ii)=size(IPWV_etl2(DOY_etl2>=DOY_i & DOY_etl2<DOY_i+DOY_delta),2);
   
   DOY_CART_MWR_ave(ii)=DOY_i;
   IPWV_CART_MWR_ave(ii)=mean(IPWV_CART_MWR(DOY_CART_MWR>=DOY_i & DOY_CART_MWR<DOY_i+DOY_delta));
   ILW_CART_MWR_ave(ii)=mean(ILW_CART_MWR(DOY_CART_MWR>=DOY_i & DOY_CART_MWR<DOY_i+DOY_delta));
   N_CART_MWR_ave(ii)=size(IPWV_CART_MWR(DOY_CART_MWR>=DOY_i & DOY_CART_MWR<DOY_i+DOY_delta),2);
   
   DOY_mfrsr_ave(ii)=DOY_i;
   IPWV_mfrsr_ave(ii)=mean(IPWV_mfrsr(DOY_mfrsr>=DOY_i & DOY_mfrsr<DOY_i+DOY_delta));
   N_mfrsr_ave(ii)=size(IPWV_mfrsr(DOY_mfrsr>=DOY_i & DOY_mfrsr<DOY_i+DOY_delta),2);
   
   DOY_Cimel_ave(ii)=DOY_i;
   IPWV_Cimel_ave(ii)=mean(IPWV_Cimel(DOY_Cimel>=DOY_i & DOY_Cimel<DOY_i+DOY_delta));
   N_Cimel_ave(ii)=size(IPWV_Cimel(DOY_Cimel>=DOY_i & DOY_Cimel<DOY_i+DOY_delta),2);
 
   DOY_AATS6_ave(ii)=DOY_i;
   IPWV_AATS6_ave(ii)=mean(IPWV_AATS6(DOY_AATS6>=DOY_i & DOY_AATS6<DOY_i+DOY_delta));
   N_AATS6_ave(ii)=size(IPWV_AATS6(DOY_AATS6>=DOY_i & DOY_AATS6<DOY_i+DOY_delta),2);
   
   DOY_GSFC_lidar_ave(ii)=DOY_i;
   IPWV_GSFC_lidar_ave(ii)=mean(IPWV_GSFC_lidar(DOY_GSFC_lidar>=DOY_i & DOY_GSFC_lidar<DOY_i+DOY_delta));
   N_GSFC_lidar_ave(ii)=size(IPWV_GSFC_lidar(DOY_GSFC_lidar>=DOY_i & DOY_GSFC_lidar<DOY_i+DOY_delta),2);
   
   DOY_CART_lidar_ave(ii)=DOY_i;
   IPWV_CART_lidar_ave(ii)=mean(IPWV_CART_lidar(DOY_CART_lidar>=DOY_i & DOY_CART_lidar<DOY_i+DOY_delta));
   N_CART_lidar_ave(ii)=size(IPWV_CART_lidar(DOY_CART_lidar>=DOY_i & DOY_CART_lidar<DOY_i+DOY_delta),2);

   ii=ii+1;   
end   

%eliminate segments with no measurements
DOY_etl1_ave=DOY_etl1_ave(N_etl1_ave~=0);
IPWV_etl1_ave=IPWV_etl1_ave(N_etl1_ave~=0);
ILW_etl1_ave=ILW_etl1_ave(N_etl1_ave~=0);
N_etl1_ave=N_etl1_ave(N_etl1_ave~=0);

DOY_etl2_ave=DOY_etl2_ave(N_etl2_ave~=0);
IPWV_etl2_ave=IPWV_etl2_ave(N_etl2_ave~=0);
ILW_etl2_ave=ILW_etl2_ave(N_etl2_ave~=0);
N_etl2_ave=N_etl2_ave(N_etl2_ave~=0);

DOY_CART_MWR_ave=DOY_CART_MWR_ave(N_CART_MWR_ave~=0);
IPWV_CART_MWR_ave=IPWV_CART_MWR_ave(N_CART_MWR_ave~=0);
ILW_CART_MWR_ave=ILW_CART_MWR_ave(N_CART_MWR_ave~=0);
N_CART_MWR_ave=N_CART_MWR_ave(N_CART_MWR_ave~=0);

DOY_mfrsr_ave=DOY_mfrsr_ave(N_mfrsr_ave~=0);
IPWV_mfrsr_ave=IPWV_mfrsr_ave(N_mfrsr_ave~=0);
N_mfrsr_ave=N_mfrsr_ave(N_mfrsr_ave~=0);

DOY_Cimel_ave=DOY_Cimel_ave(N_Cimel_ave~=0);
IPWV_Cimel_ave=IPWV_Cimel_ave(N_Cimel_ave~=0);
N_Cimel_ave=N_Cimel_ave(N_Cimel_ave~=0);

DOY_AATS6_ave=DOY_AATS6_ave(N_AATS6_ave~=0);
IPWV_AATS6_ave=IPWV_AATS6_ave(N_AATS6_ave~=0);
N_AATS6_ave=N_AATS6_ave(N_AATS6_ave~=0);

DOY_GSFC_lidar_ave=DOY_GSFC_lidar_ave(N_GSFC_lidar_ave~=0);
IPWV_GSFC_lidar_ave=IPWV_GSFC_lidar_ave(N_GSFC_lidar_ave~=0);
N_GSFC_lidar_ave=N_GSFC_lidar_ave(N_GSFC_lidar_ave~=0);

DOY_CART_lidar_ave=DOY_CART_lidar_ave(N_CART_lidar_ave~=0);
IPWV_CART_lidar_ave=IPWV_CART_lidar_ave(N_CART_lidar_ave~=0);
N_CART_lidar_ave=N_CART_lidar_ave(N_CART_lidar_ave~=0);

%Plot smoothed IPWV
figure(2)
orient landscape
plot(DOY_etl1_ave,IPWV_etl1_ave,'k.-',...
     DOY_etl2_ave,IPWV_etl2_ave,'r.-',...
     DOY_CART_MWR_ave,IPWV_CART_MWR_ave,'g.-',...
     DOY_mfrsr_ave,IPWV_mfrsr_ave,'y.-',...
     DOY_Cimel_ave,IPWV_Cimel_ave,'c.:',...
     DOY_AATS6_ave,IPWV_AATS6_ave,'b.-',...   
     DOY_gps_cf,IPWV_gps_cf,'g.-',...
     DOY_gps_lamont,IPWV_gps_lamont,'m.-',...
     DOY_bbss,IPWV_bbss,'ko',...
     DOY_GSFC_lidar,IPWV_GSFC_lidar,'r^',...
     DOY_CART_lidar,IPWV_CART_lidar,'mv');  
axis([-inf inf 0 5])
ylabel('Columnar Water Vapor [cm]')
xlabel('Day of Year 1997')
legend('ETL1','ETL2','CART MWR','MFRSR','Cimel','AATS-6','GPS CF','GPS Lamont','BBSS','GSFC Lidar','CART Lidar')

figure(3)
plot(DOY_etl1_ave,N_etl1_ave,'k.-',...
     DOY_etl2_ave,N_etl2_ave,'r.-',...
     DOY_CART_MWR_ave,N_CART_MWR_ave,'g.-',...
     DOY_mfrsr_ave,N_mfrsr_ave,'y.-',...
     DOY_Cimel_ave,N_Cimel_ave,'c.:',...
     DOY_AATS6_ave,N_AATS6_ave,'b.-')
ylabel('Columnar Water Vapor [cm]')
xlabel('Day of Year 1997')
legend('ETL1','ETL2','CART MWR','MFRSR','Cimel','AATS-6','GSFC Lidar','CART Lidar')

%Compare both GPS the times in both files match exactly. Data rate is every half hour for both GPS
range=[0:6];
figure(4)
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf,y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_gps_cf,100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on

subplot(2,2,3)
y=interp1(DOY_gps_cf,DOY_gps_cf,DOY_gps_cf,'nearest');
plot(DOY_gps_cf,(DOY_gps_cf-y)*24*60,'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare BBSS with gps_cf. Data rate is every half hour for GPS, every 3 hours for BBSS
figure(5)
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_bbss,y-x,'.')
ylabel('IPWV(cm) GPS@CF - BBSS ')
xlabel('Day of Year 1997')
text(270, 0.9,sprintf('RMSE = %5.3f cm',rmse))
text(270, 0.8,sprintf('mean = %5.3f cm',mean(y-x)))
text(270, 0.7,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_bbss,100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,45,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
y=interp1(DOY_gps_cf,DOY_gps_cf,DOY_bbss,'nearest');
plot(DOY_bbss,(DOY_bbss-y)*24*60,'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare  AATS-6 with gps_cf. Data rate is every half hour for GPS, every 12 sec for AATS-6
figure(6)
orient landscape
y=interp1(DOY_AATS6_ave,DOY_AATS6_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<0.1);
subplot(2,2,1)
y=interp1(DOY_AATS6_ave,IPWV_AATS6_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare Cimel with gps_cf. Data rate is every half hour for GPS, every 15 min for Cimel
figure(7)
orient landscape
y=interp1(DOY_Cimel_ave,DOY_Cimel_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
y=interp1(DOY_Cimel_ave,IPWV_Cimel_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare MFRSR with gps_cf. Data rate is every half hour for GPS, every minute for MFRSR
figure(8)
orient landscape
y=interp1(DOY_mfrsr_ave,DOY_mfrsr_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
y=interp1(DOY_mfrsr_ave,IPWV_mfrsr_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare CART_MWR with gps_cf. Data rate is every half hour for GPS, every 20 seconds for CART_MWR
figure(9)
orient landscape
y=interp1(DOY_CART_MWR_ave,DOY_CART_MWR_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
ILW=interp1(DOY_CART_MWR_ave,ILW_CART_MWR_ave,DOY_gps_cf(i),'nearest');
y=interp1(DOY_CART_MWR_ave,IPWV_CART_MWR_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on

subplot(2,2,3)
plot(DOY_gps_cf(i),ILW,'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on

%Compare NOAA_ETL1 with gps_cf. Data rate is every half hour for GPS, every 90 seconds for NOAA_ETL1
figure(10)
orient landscape
y=interp1(DOY_etl1_ave,DOY_etl1_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
ILW=interp1(DOY_etl1_ave,ILW_etl1_ave,DOY_gps_cf(i),'nearest');
y=interp1(DOY_etl1_ave,IPWV_etl1_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on

subplot(2,2,3)
plot(DOY_gps_cf(i),ILW,'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on

%Compare NOAA_ETL2 with gps_cf. Data rate is every half hour for GPS, every 90 seconds for NOAA_ETL1
figure(11)
orient landscape
y=interp1(DOY_etl2_ave,DOY_etl2_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
ILW=interp1(DOY_etl2_ave,ILW_etl2_ave,DOY_gps_cf(i),'nearest');
y=interp1(DOY_etl2_ave,IPWV_etl2_ave,DOY_gps_cf(i),'nearest');
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
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on

subplot(2,2,3)
plot(DOY_gps_cf(i),ILW,'.')
ylabel('ILW (cm)')
xlabel('Day of Year 1997')
grid on

%Compare  GSFC lidar with gps_cf. Data rate is every half hour for GPS, every minute for MFRSR
figure(12)
orient landscape
y=interp1(DOY_GSFC_lidar_ave,DOY_GSFC_lidar_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
y=interp1(DOY_GSFC_lidar_ave,IPWV_GSFC_lidar_ave,DOY_gps_cf(i),'nearest');
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
ylabel('IPWV(cm) GSFC Lidar')
axis([0 6 0 6])
subplot(2,2,2)
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

%Compare  CART lidar with gps_cf. Data rate is every half hour for GPS, every minute for MFRSR
figure(13)
orient landscape
y=interp1(DOY_CART_lidar_ave,DOY_CART_lidar_ave,DOY_gps_cf,'nearest');
delta_t=(DOY_gps_cf-y)*24*60;
i=find(abs(delta_t)<=0.1);
subplot(2,2,1)
y=interp1(DOY_CART_lidar_ave,IPWV_CART_lidar_ave,DOY_gps_cf(i),'nearest');
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
ylabel('IPWV(cm) CART Lidar')
axis([0 6 0 6])
subplot(2,2,2)
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_gps_cf(i),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on
subplot(2,2,4)
plot(DOY_gps_cf(i),100*(y-x)./x,'.')
ylabel('Difference in %')
xlabel('Day of Year 1997')
text(256,55,sprintf('mean= %5.1f %',mean(100*(y-x)./x)))
text(256,44,sprintf('stdev= %5.1f %',std(100*(y-x)./x)))
axis([255 280 -20 60])
grid on
subplot(2,2,3)
plot(DOY_gps_cf(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on