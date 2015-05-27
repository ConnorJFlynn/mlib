%compares AOD Data during Fall97 ARM SGP IOP
clear

%reads PSU data
AOD_PSU_all=[];
DOY_PSU_all=[];
for ifile=1:11
 read_PSU 
 AOD_PSU_all=[AOD_PSU_all AOD_PSU];
 DOY_PSU_all=[DOY_PSU_all DOY_PSU];
 clear AOD_PSU;
 clear DOY_PSU;
end 
AOD_PSU=AOD_PSU_all;
DOY_PSU=DOY_PSU_all;
clear AOD_PSU_all;
clear DOY_PSU_all;

% reads MFRSR data
AOD_MFRSR_all=[];
DOY_MFRSR_all=[];
for ifile=1:12
 read_MFRSR_Joe 
 AOD_MFRSR_all=[AOD_MFRSR_all AOD_MFRSR];
 DOY_MFRSR_all=[DOY_MFRSR_all DOY_MFRSR];
end 
AOD_MFRSR=AOD_MFRSR_all;
DOY_MFRSR=DOY_MFRSR_all;
clear AOD_MFRSR_all;
clear DOY_MFRSR_all;

%read RSS data
AOD_RSS380_all=[];
DOY_RSS380_all=[];
AOD_RSS451_all=[];
DOY_RSS451_all=[];
AOD_RSS525_all=[];
DOY_RSS525_all=[];
AOD_RSS864_all=[];
DOY_RSS864_all=[];
for ifile=1:3
  read_RSS 
  AOD_RSS380_all=[AOD_RSS380_all AOD_RSS];
  DOY_RSS380_all=[DOY_RSS380_all DOY_RSS];
end
for ifile=4:6
  read_RSS 
  AOD_RSS451_all=[AOD_RSS451_all AOD_RSS];
  DOY_RSS451_all=[DOY_RSS451_all DOY_RSS];
end
for ifile=7:9
  read_RSS 
  AOD_RSS525_all=[AOD_RSS525_all AOD_RSS];
  DOY_RSS525_all=[DOY_RSS525_all DOY_RSS];
end
for ifile=10:12
  read_RSS 
  AOD_RSS864_all=[AOD_RSS864_all AOD_RSS];
  DOY_RSS864_all=[DOY_RSS864_all DOY_RSS];
end
AOD_RSS380=AOD_RSS380_all;
DOY_RSS380=DOY_RSS380_all;
AOD_RSS451=AOD_RSS451_all;
DOY_RSS451=DOY_RSS451_all;
AOD_RSS525=AOD_RSS525_all;
DOY_RSS525=DOY_RSS525_all;
AOD_RSS864=AOD_RSS864_all;
DOY_RSS864=DOY_RSS864_all;

clear AOD_RSS380_all;
clear DOY_RSS380_all;
clear AOD_RSS451_all;
clear DOY_RSS451_all;
clear DOY_RSS451_all;
clear DOY_RSS525_all;
clear AOD_RSS864_all;
clear DOY_RSS864_all;

%read Cimel data
read_Cimel

% reads AATS-6 data
alpha_AATS6_all=[];
AOD_AATS6_all=[];
AOD_Error_AATS6_all=[];
IPWV_AATS6_all=[];
DOY_AATS6_all=[];
for ifile=1:15
 read_AATS6 
 alpha_AATS6_all=[alpha_AATS6_all alpha_AATS6];
 AOD_AATS6_all=[AOD_AATS6_all AOD_AATS6];
 AOD_Error_AATS6_all=[AOD_Error_AATS6_all AOD_Error_AATS6];
 IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
 DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
end 
alpha_AATS6=alpha_AATS6_all;
AOD_AATS6=AOD_AATS6_all;
AOD_Error_AATS6=AOD_Error_AATS6_all;
IPWV_AATS6=IPWV_AATS6_all;
DOY_AATS6=DOY_AATS6_all;
clear alpha_AATS6_all;
clear AOD_AATS6_all;
clear AOD_Error_AATS6_all;
clear IPWV_AATS6_all;
clear DOY_AATS6_all;

% Do overall time series
figure(1)
plot(DOY_AATS6,AOD_AATS6,'.',...
     DOY_RSS380,AOD_RSS380,'.',DOY_RSS451,AOD_RSS451,'.',DOY_RSS525,AOD_RSS525,'.',DOY_RSS864,AOD_RSS864,'.',...
     DOY_Cimel,AOD_Cimel,'.-',...
     DOY_MFRSR,AOD_MFRSR,'.',...
     DOY_PSU,AOD_PSU,'x')
ylabel('Aerosol Optical Depth')
xlabel('Day of Year 1997')
%legend('AATS-6 380nm','AATS-6 451nm','AATS-6 525nm','AATS-6 862nm','AATS-6 1024nm',...
%       'RSS 380nm','RSS 451nm','RSS 525nm','RSS 862nm',...
%       'Cimel 1019 nm','Cimel 870 nm','Cimel 673 nm','Cimel 440 nm','Cimel 500 nm','Cimel 380 nm','Cimel 340 nm',...
%       'MFRSR 414 nm','MFRSR 499','MFRSR 608 nm','MFRSR 665 nm','MFRSR 860 nm',1)
%    axis([-inf inf 0 0.3])
grid on

%Compare AATS-6 with RSS as time series
figure(2)
orient landscape
plot(DOY_AATS6,AOD_AATS6([1:4],:),'-',DOY_RSS380,AOD_RSS380,'b.',DOY_RSS451,AOD_RSS451,'g.',...
     DOY_RSS525,AOD_RSS525,'r.',DOY_RSS864,AOD_RSS864,'c.')
ylabel('Aerosol Optical Depth nm')
xlabel('Day of Year 1997')
legend('AATS-6 380nm','AATS-6 451nm','AATS-6 525nm','AATS-6 862nm','RSS 380nm','RSS 451nm','RSS 525nm','RSS 862nm')
axis([270.5 271 0 0.2])
grid on

figure(3)
orient landscape
plot(DOY_AATS6,AOD_AATS6([1:4],:),'-',DOY_RSS380,AOD_RSS380,'b.',DOY_RSS451,AOD_RSS451,'g.',...
     DOY_RSS525,AOD_RSS525,'r.',DOY_RSS864,AOD_RSS864,'c.')
ylabel('Aerosol Optical Depth')
xlabel('Day of Year 1997')
legend('AATS-6 380nm','AATS-6 451nm','AATS-6 525nm','AATS-6 862nm','RSS 380nm','RSS 451nm','RSS 525nm','RSS 862nm')
axis([272.5 273 0 0.2])
grid on

figure(4)
orient landscape
plot(DOY_AATS6,AOD_AATS6([1:4],:),'-',DOY_RSS380,AOD_RSS380,'b.',DOY_RSS451,AOD_RSS451,'g.',...  
DOY_RSS525,AOD_RSS525,'r.',DOY_RSS864,AOD_RSS864,'c.')
ylabel('Aerosol Optical Depth')
xlabel('Day of Year 1997')
legend('AATS-6 380nm','AATS-6 451nm','AATS-6 525nm','AATS-6 862nm','RSS 380nm','RSS 451nm','RSS 525nm','RSS 862nm')
axis([274.5 275 0 0.4])
grid on

%Compare 860 nm of Cimel, AATS-6,MFRSR, RSS and PSU as time series
figure(5)
orient landscape
plot(DOY_MFRSR,AOD_MFRSR([5],:),'.',...
     DOY_AATS6,AOD_AATS6([4],:),'.',...
     DOY_RSS864,AOD_RSS864,'.',...
     DOY_Cimel,AOD_Cimel([2],:),'o',...
     DOY_PSU,AOD_PSU([7],:),'.')
ylabel('Aerosol Optical Depth')
xlabel('Day of Year 1997')
legend('MFRSR 860nm','AATS-6 864nm','RSS 864nm','Cimel 870nm','PSU 872nm')
axis([276.5 277 0 0.8])
grid on

%Compare 860 nm of MFRSR and AATS-6
range=[0:0.01:0.2];
figure(6)
orient landscape
y=interp1(DOY_AATS6,DOY_AATS6,DOY_MFRSR,'nearest');
delta_t=(DOY_MFRSR-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_MFRSR,'nearest');
i=find(abs(delta_t)<=0.2 & alpha>=0.75);

subplot(2,2,1)
plot(DOY_MFRSR(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_MFRSR(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(4,:),DOY_MFRSR(i),'nearest');
y=AOD_MFRSR(5,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.05,0.04,sprintf('y = %5.3f x + %5.3f',p))
text(0.05,0.03,sprintf('r²= %5.3f',r.^2))
text(0.05,0.02,sprintf('RMSE = %5.3f',rmse))
text(0.05,0.01,sprintf('n = %5i',n))
xlabel('AOD 864 nm AATS-6')
ylabel('AOD 860 nm MFRSR')

subplot(2,2,2)
plot(DOY_MFRSR(i),x-y,'.')
ylabel('AOD 860 nm  AATS-6 - MFRSR')
xlabel('Day of Year 1997')
text(271,-0.00,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.004,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.008,sprintf('rms= %5.3f ',rmsd))
grid on



%Compare 380 nm of Cimel, AATS-6 RSS PSU
figure(7)
orient landscape
plot(DOY_AATS6,AOD_AATS6([1],:),'.',DOY_RSS380,AOD_RSS380,'.',DOY_Cimel,AOD_Cimel([6],:),'o',DOY_PSU,AOD_PSU([1],:),'.')
ylabel('Aerosol Optical Depth 380 nm')
xlabel('Day of Year 1997')
legend('AATS-6','RSS','Cimel','PSU')
axis([270.5 271 0 0.2])
grid on

%Compare 380 nm of Cimel with AATS-6
range=[0:0.1:0.5];
figure(8)
orient landscape
y=interp1(DOY_AATS6,DOY_AATS6,DOY_Cimel,'nearest');
delta_t=(DOY_Cimel-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_Cimel,'nearest');
i=find(abs(delta_t)<=0.5 & alpha>=0.75);

subplot(2,2,1)
plot(DOY_Cimel(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_Cimel(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(1,:),DOY_Cimel(i),'nearest');
y=AOD_Cimel(6,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.3,0.25,sprintf('y = %5.3f x + %5.3f',p))
text(0.3,0.20,sprintf('r²= %5.3f',r.^2))
text(0.3,0.15,sprintf('RMSE = %5.3f',rmse))
text(0.3,0.10,sprintf('n = %5i',n))
xlabel('AOD 380 nm AATS-6')
ylabel('AOD 380 nm Cimel')

subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 380 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.05,sprintf('mean = %5.3f ',mean(x-y)))
text(256,-0.06,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.07,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 1020 nm of Cimel with AATS-6
range=[0:0.02:0.14];
figure(9)
subplot(2,2,4)
plot(DOY_Cimel(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,1)
y=interp1(DOY_AATS6,alpha_AATS6,DOY_Cimel(i),'nearest');
plot(DOY_Cimel(i),y,'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(5,:),DOY_Cimel(i),'nearest');
y=AOD_Cimel(1,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.08,0.04,sprintf('y = %5.3f x + %5.3f',p))
text(0.08,0.03,sprintf('r²= %5.3f',r.^2))
text(0.08,0.02,sprintf('RMSE = %5.3f',rmse))
text(0.08,0.01,sprintf('n = %5i',n))
xlabel('AOD 1021 nm AATS-6')
ylabel('AOD 1019 nm Cimel')
subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 1020 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.03,sprintf('mean = %5.3f ',mean(x-y)))
text(256,-0.04,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.05,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 380 nm of AATS-6 and RSS
range=[0:0.05:0.35];
figure(10)
y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS380,'nearest');
delta_t=(DOY_RSS380-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_RSS380,'nearest');
i=find(abs(delta_t)<=0.2 & alpha>=0.0);

subplot(2,2,1)
plot(DOY_RSS380(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS380(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(1,:),DOY_RSS380(i),'nearest');
y=AOD_RSS380(i);
j=find((x-y)>-0.05);
x=x(j);
y=y(j);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.1,0.09,sprintf('y = %5.3f x + %5.3f',p))
text(0.1,0.06,sprintf('r²= %5.3f',r.^2))
text(0.1,0.03,sprintf('RMSE = %5.3f',rmse))
text(0.1,0.01,sprintf('n = %5i',n))
xlabel('AOD 380 nm AATS-6')
ylabel('AOD 380 nm RSS')

subplot(2,2,2)
t=DOY_RSS380(i);
plot(t(j),x-y,'.')
ylabel('AOD 380 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,0.050,sprintf('mean = %5.3f ',mean(x-y)))
text(271,0.045,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.040,sprintf('rms= %5.3f ',rmsd))
axis([-inf inf -inf inf])
grid on

%Compare 451 nm of AATS-6 and RSS
range=[0:0.1:0.3];
figure(11)
y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS451,'nearest');
delta_t=(DOY_RSS525-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_RSS451,'nearest');
i=find(abs(delta_t)<=0.2 & alpha>=0.0);

subplot(2,2,1)
plot(DOY_RSS451(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS451(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(2,:),DOY_RSS451(i),'nearest');
y=AOD_RSS451(i);
j=find((x-y)>-0.05);
x=x(j);
y=y(j);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.1,0.09,sprintf('y = %5.3f x + %5.3f',p))
text(0.1,0.06,sprintf('r²= %5.3f',r.^2))
text(0.1,0.03,sprintf('RMSE = %5.3f',rmse))
text(0.1,0.01,sprintf('n = %5i',n))
xlabel('AOD 451 nm AATS-6')
ylabel('AOD 451 nm RSS')

subplot(2,2,2)
t=DOY_RSS451(i);
plot(t(j),x-y,'.')
ylabel('AOD 451 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,-0.000,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.005,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.010,sprintf('rms= %5.3f ',rmsd))
axis([-inf inf -inf inf])
grid on

%Compare 525 nm of AATS-6 and RSS
range=[0:0.05:0.2];
figure(12)
y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS525,'nearest');
delta_t=(DOY_RSS525-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_RSS525,'nearest');
i=find(abs(delta_t)<=0.2 & alpha>=0.0);

subplot(2,2,1)
plot(DOY_RSS525(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS525(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(3,:),DOY_RSS525(i),'nearest');
y=AOD_RSS525(i);
j=find((x-y)>-0.05);
x=x(j);
y=y(j);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.1,0.09,sprintf('y = %5.3f x + %5.3f',p))
text(0.1,0.06,sprintf('r²= %5.3f',r.^2))
text(0.1,0.03,sprintf('RMSE = %5.3f',rmse))
text(0.1,0.01,sprintf('n = %5i',n))
xlabel('AOD 525 nm AATS-6')
ylabel('AOD 525 nm RSS')

subplot(2,2,2)
t=DOY_RSS451(i);
plot(t(j),x-y,'.')
ylabel('AOD 525 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,-0.00,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.005,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.01,sprintf('rms= %5.3f ',rmsd))

axis([-inf inf -inf inf])
grid on

%Compare 864 nm of AATS-6 and RSS
range=[0:0.02:0.1];
figure(13)
y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS864,'nearest');
delta_t=(DOY_RSS864-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_RSS864,'nearest');
i=find(abs(delta_t)<=0.2 & alpha>=0.0);

subplot(2,2,1)
plot(DOY_RSS864(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS864(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=interp1(DOY_AATS6,AOD_AATS6(4,:),DOY_RSS864(i),'nearest');
y=AOD_RSS864(i);
j=find((x-y)>-0.05);
x=x(j);
y=y(j);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.05,0.04,sprintf('y = %5.3f x + %5.3f',p))
text(0.05,0.03,sprintf('r²= %5.3f',r.^2))
text(0.05,0.02,sprintf('RMSE = %5.3f',rmse))
text(0.05,0.01,sprintf('n = %5i',n))
xlabel('AOD 864 nm AATS-6')
ylabel('AOD 864 nm RSS')

subplot(2,2,2)
t=DOY_RSS864(i);
plot(t(j),x-y,'.')
ylabel('AOD 864 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,-0.010,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.012,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.015,sprintf('rms= %5.3f ',rmsd))
axis([-inf inf -inf inf])
grid on

% Do log-log plots
figure(14)
DOY_start=272.775;
DOY_end=272.8;
%filename='aod_spectra_noon.970927' %270.775-270.800
filename='aod_spectra_noon.970929' %272.775-272.800
%filename='aod_spectra_noon.971001'  %274.750-274.800
pathname='d:\Beat\Data\Oklahoma\RSS\';
fid=fopen(deblank([pathname filename]));
fgetl(fid);
data=fscanf(fid,'%f',[2 inf]);
fclose(fid);
lambda_RSS_spectra=data(1,:)/1e3;
AOD_RSS_spectra=data(2,:);

AOD_PSU_mean  =mean(AOD_PSU  (:,DOY_PSU  >=DOY_start & DOY_PSU  <=DOY_end)');
AOD_MFRSR_mean=mean(AOD_MFRSR(:,DOY_MFRSR>=DOY_start & DOY_MFRSR<=DOY_end)');
AOD_AATS6_mean=mean(AOD_AATS6(:,DOY_AATS6>=DOY_start & DOY_AATS6<=DOY_end)');
AOD_Cimel_mean=mean(AOD_Cimel(:,DOY_Cimel>=DOY_start & DOY_Cimel<=DOY_end)');
AOD_Error_AATS6_mean=mean(AOD_Error_AATS6(:,DOY_AATS6>=DOY_start & DOY_AATS6<=DOY_end)');

AOD_RSS_mean(1)=mean(AOD_RSS380(DOY_RSS380>=DOY_start & DOY_RSS380<=DOY_end));
AOD_RSS_mean(2)=mean(AOD_RSS451(DOY_RSS451>=DOY_start & DOY_RSS451<=DOY_end));
AOD_RSS_mean(3)=mean(AOD_RSS525(DOY_RSS525>=DOY_start & DOY_RSS525<=DOY_end));
AOD_RSS_mean(4)=mean(AOD_RSS864(DOY_RSS864>=DOY_start & DOY_RSS864<=DOY_end));
loglog(lambda_RSS_spectra,AOD_RSS_spectra,'k-',...
       lambda_AATS6,AOD_AATS6_mean,'mo',...
       lambda_Cimel,AOD_Cimel_mean,'bx',...
       lambda_MFRSR,AOD_MFRSR_mean,'gv',...
       lambda_PSU,AOD_PSU_mean,'c*')
%    lambda_RSS,  AOD_RSS_mean,'r*',...
hold on
errorbar(lambda_AATS6,AOD_AATS6_mean,AOD_Error_AATS6_mean,AOD_Error_AATS6_mean,'mo')
set(gca,'ylim',[.01 0.1]);
set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05,0.06,0.07,0.08,0.09,0.1]);
set(gca,'xlim',[.30 1.10]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1]);
xlabel('Wavelength [µm]');
ylabel('Aerosol Optical Depth');
title(sprintf('%s %g-%g ','Time',DOY_start,DOY_end));
hold off
legend('RSS','AATS-6','Cimel','MFRSR','PSU')
grid on

