% reads AATS-6 data
IPWV_AATS6_all=[];
DOY_AATS6_all=[];
for ifile=1:15
 read_AATS6 
 IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
 DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
end 
IPWV_AATS6=IPWV_AATS6_all;
DOY_AATS6=DOY_AATS6_all;
clear IPWV_AATS6_all;
clear DOY_AATS6_all;

% reads corrected gps and mwr data
filename=filelist(ifile,:); 
fid=fopen('d:\beat\data\oklahoma\cart_mwr\version_981205\wviop97_gps_mwr.dat');
fgetl(fid);
data=fscanf(fid,'%f',[4,inf]);
fclose(fid)
DOY_GPS=data(1,:);
IPWV_CART_MWR=data(2,:);
IPWV_GPS=data(4,:);

IPWV_CART_MWR(IPWV_CART_MWR==-999.00)=NaN;
IPWV_GPS(IPWV_GPS==-999.00)=NaN;


%compare GPS and CART MWR
figure(2)
subplot(2,1,1)
range=[0:6];
y=IPWV_CART_MWR(isnan(IPWV_CART_MWR)==0 & isnan(IPWV_GPS)==0);
x=IPWV_GPS(isnan(IPWV_CART_MWR)==0 & isnan(IPWV_GPS)==0);
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
xlabel('IPWV(cm) GPS')
ylabel('IPWV(cm) CART MWR')
axis([0 6 0 6])

subplot(2,1,2)
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_GPS(isnan(IPWV_CART_MWR)==0 & isnan(IPWV_GPS)==0),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

% Do averaging. Time is end of 30 min average
range=[0:6];
[m,n]=size(DOY_GPS)
DOY_delta=0.5/24;

for ii=1:n 
   DOY_i=DOY_GPS(ii);
   IPWV_AATS6_ave(ii)=mean(IPWV_AATS6(DOY_AATS6>DOY_i-DOY_delta & DOY_AATS6<=DOY_i));
   N_AATS6_ave(ii)=size(IPWV_AATS6(DOY_AATS6>DOY_i-DOY_delta & DOY_AATS6<=DOY_i),2);
end   

figure(1)
plot(DOY_GPS,IPWV_GPS,'.',DOY_GPS,IPWV_CART_MWR,'.',DOY_GPS,IPWV_AATS6_ave,'.')


%compare AATS-6 and GPS
figure(3)
subplot(2,1,1)
range=[0:5];
y=IPWV_AATS6_ave(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_GPS)==0);
x=IPWV_GPS(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_GPS)==0);
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
xlabel('IPWV(cm) GPS')
ylabel('IPWV(cm) AATS-6')
axis([0 5 0 5])

subplot(2,1,2)
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_GPS(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_GPS)==0),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

%compare AATS-6 and MWR at GPS times
figure(4)
subplot(2,1,1)
range=[0:5];
y=IPWV_AATS6_ave(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_CART_MWR)==0);
x=IPWV_CART_MWR(isnan(IPWV_AATS6_ave)==0& isnan(IPWV_CART_MWR)==0);
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
xlabel('IPWV(cm) CART MWR')
ylabel('IPWV(cm) AATS-6')
axis([0 5 0 5])

subplot(2,1,2)
rmse=(sum((y-x).^2)/(n-2))^0.5;
plot(DOY_GPS(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_CART_MWR)==0),y-x,'.')
ylabel('Difference in cm')
xlabel('Day of Year 1997')
text(256,0.8,sprintf('RMSE= %5.3f cm',rmse))
text(256,0.7,sprintf('mean = %5.3f cm',mean(y-x)))
text(256,0.6,sprintf('stdev= %5.3f cm',std(y-x)))
axis([255 280 -0.5 1])
grid on

%compare AATS-6 and MWR at GPS times and plot nice figure
figure(5)
range=[0:5];
y=IPWV_AATS6_ave(isnan(IPWV_AATS6_ave)==0 & isnan(IPWV_CART_MWR)==0);
x=IPWV_CART_MWR(isnan(IPWV_AATS6_ave)==0& isnan(IPWV_CART_MWR)==0);
[p,S]=polyfit(x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
r=corrcoef(x,y);
r=r(1,2);
rmse=(sum((y-x).^2)/(n-2))^0.5;
bias=mean(y-x);
stdev=std(y-x);
plot(x,y,'o',x,y_fit,range,range)
text(3.1,1.2,sprintf('y = %5.3f x + %5.3f',p),'FontSize',12)
text(3.1,1.0,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.8,sprintf('n = %5i',n),'FontSize',12)
text(3.1,0.6,sprintf('RMS= %5.3f cm',rmse),'FontSize',12)
text(3.1,0.4,[sprintf('Bias = %5.3f',bias) '\pm' sprintf('%5.3f cm',stdev)],'FontSize',12)
xlabel('CWV(cm)  CART MWR','FontSize',14)
ylabel('CWV(cm)  AATS-6','FontSize',14)
set(gca,'FontSize',14)
set(gca,'xtick',[0 1 2 3 4 5])
set(gca,'ytick',[0 1 2 3 4 5])
axis([0 5 0 5])
axis square
title('Validation of AATS-6 H_2O Retrieval with DOE ARM/CART MWR, Sep/Oct 1997')
