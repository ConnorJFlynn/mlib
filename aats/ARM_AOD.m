%compares AOD Data during Fall97 ARM SGP IOP
clear

%reads PSU data
%AOD_PSU_all=[];
%DOY_PSU_all=[];
%for ifile=1:11
% read_PSU 
% AOD_PSU_all=[AOD_PSU_all AOD_PSU];
% DOY_PSU_all=[DOY_PSU_all DOY_PSU];
% clear AOD_PSU;
% clear DOY_PSU;
%end 
%AOD_PSU=AOD_PSU_all;
%DOY_PSU=DOY_PSU_all;
%clear AOD_PSU_all;
%clear DOY_PSU_all;

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
AOD_RSS_all=[];
DOY_RSS_all=[];
for ifile=1:10
  read_RSS 
  AOD_RSS_all=[AOD_RSS_all AOD_RSS];
  DOY_RSS_all=[DOY_RSS_all DOY_RSS];
end
AOD_RSS=AOD_RSS_all;
DOY_RSS=DOY_RSS_all;

i_wvl=find(lambda_RSS>=0.37 & lambda_RSS<=1.1);
lambda_RSS=lambda_RSS(i_wvl);
AOD_RSS=AOD_RSS(i_wvl,:);


clear AOD_RSS_all;
clear DOY_RSS_all;

%read Cimel data
[DOY_Cimel,IPWV_Cimel,AOD_Cimel,lambda_Cimel]=read_Cimel;

% reads AATS-6 data
[DOY_AATS6,IPWV_AATS6,AOD_flag,AOD_AATS6,AOD_Error_AATS6,alpha_AATS6,lambda_AATS6]=read_AATS6(1);

% Interpolate to AATS-6 wavlengths
AOD_RSS_AATS6=interp1(lambda_RSS,AOD_RSS,lambda_AATS6);
AOD_MFRSR_AATS6=exp(interp1(log(lambda_MFRSR),log(AOD_MFRSR),log(lambda_AATS6(2:4))));
AOD_Cimel_AATS6=exp(interp1(log(lambda_Cimel),log(AOD_Cimel),log(lambda_AATS6(1:4))));


%*****************************************************
%DOY_start=261.5; %Sept 18
%DOY_end=262;
%DOY_start=268.5; %Sept 25
%DOY_end=269;

%DOY_start=269.5; %Sept 26
%DOY_end=269.7;

DOY_start=270.55; %Sept 27
DOY_end=271.0;

%DOY_start=271.75; %Sept 28
%DOY_end=272.0;

%DOY_start=272.75; %Sept 29
%DOY_end=272.89;

%DOY_start=272.5; %Sept 29
%DOY_end=273;

%DOY_start=273.5; %Sept 30
%DOY_end=274.0;

%DOY_start=274.5; % Oct 1
%DOY_end=275.0;

DOY_start=275.675; % Oct 2
DOY_end=275.9;

%DOY_start=276.5; % Oct 3
%DOY_end=277.0;

%DOY_start=277.5; % Oct 4
%DOY_end=278.0;


% Do overall time series
figure(1)
plot(DOY_AATS6,AOD_AATS6,'.',...
     DOY_RSS,AOD_RSS_AATS6,'.',...
     DOY_Cimel,AOD_Cimel,'.-',...
     DOY_MFRSR,AOD_MFRSR,'.')
  
%DOY_PSU,AOD_PSU,'x'
  
ylabel('Aerosol Optical Depth')
xlabel('Day of Year 1997')
%legend('AATS-6 380nm','AATS-6 451nm','AATS-6 525nm','AATS-6 862nm','AATS-6 1024nm',...
%       'RSS 380nm','RSS 451nm','RSS 525nm','RSS 862nm',...
%       'Cimel 340 nm','Cimel 380 nm','Cimel 440 nm','Cimel 500 nm','Cimel 673 nm','Cimel 870 nm','Cimel 1019 nm',...
%       'MFRSR 414 nm','MFRSR 499','MFRSR 608 nm','MFRSR 665 nm','MFRSR 860 nm',1)
axis([DOY_start DOY_end 0 1])
grid on

%Compare AATS-6 with RSS as time series
figure(2)
DOY_start=270.542; %Sept 27
DOY_end=271.0;

a=0;
b=0;
ii=find(DOY_AATS6>=DOY_start & DOY_AATS6<=DOY_end);
plot((DOY_AATS6(ii)-270)*24-5,AOD_AATS6(:,ii),'-',...
     a,b,'.',...
     a,b,'.',...
    (DOY_RSS-270)*24-5,AOD_RSS_AATS6,'.');
ylabel('Aerosol Optical Depth','FontSize',14)
xlabel('Local Time [hours]','FontSize',14)
%legend('380nm','451nm','525nm','864nm','1021nm')
text(8.1,0.110,'380 nm','color',[0 0 1],'FontSize',14)
text(8.1,0.082,'451 nm','color',[0 0.5 0],'FontSize',14)
text(8.1,0.063,'525 nm','color',[1 0 0],'FontSize',14)
text(8.13,0.033,'1021 nm','color',[0.75 0 0.75],'FontSize',14)
text(8.1,0.017,'864 nm','color',[0 0.75 0.75],'FontSize',14)
axis([7 19 0.01 .13])
grid on
set(gca,'FontSize',14)


%Compare 380 nm of Cimel, AATS-6, RSS,  and PSU as time series
figure(3)
plot(DOY_AATS6,AOD_AATS6([1],:),'g.',...
   DOY_Cimel,AOD_Cimel([2],:),'bo',...
   DOY_RSS,AOD_RSS_AATS6([1],:),'c.');

%DOY_PSU,AOD_PSU([1],:),'r.',...

ylabel('Aerosol Optical Depth 380 nm')
xlabel('Day of Year 1997')
legend('AATS-6','Cimel','RSS')
%legend('PSU','AATS-6','Cimel','RSS')
axis([DOY_start DOY_end 0 .5])
grid on

%Compare 860 nm of Cimel, AATS-6,MFRSR, RSS and PSU as time series
figure(4)
plot(  (DOY_AATS6-272)*24-5,AOD_AATS6([4],:),'c.',...
       (DOY_MFRSR-272)*24-5,AOD_MFRSR([5],:),'m.',...
       (DOY_RSS-272)*24-5,AOD_RSS_AATS6([4],:),'g.',...
       (DOY_Cimel-272)*24-5,AOD_Cimel([6],:),'bo')
%   DOY_PSU,AOD_PSU([7],:),'r.',...
 
ylabel('Aerosol Optical Depth','FontSize',14)
%xlabel('Day of Year 1997','FontSize',14)
xlabel('Local Time [hours]','FontSize',14)
%legend('AATS-6 864nm','MFRSR 860nm','PSU 872nm','RSS 864nm','Cimel 870nm')
%legend('AATS-6 864nm','MFRSR 860nm','RSS 864nm','Cimel 870nm')
axis([7 19 0 .04])
grid on
text(9.5,0.021,'Cimel','color','b','FontSize',14)
text(7.5,0.013,'AATS-6','color','c','FontSize',14)
text(12.3,0.032,'MFRSR','color','m','FontSize',14)
text(14,0.017,'RSS','color','g','FontSize',14)
set(gca,'FontSize',14)

% Do log-log plots
figure(5)
%AOD_PSU_mean  =mean(AOD_PSU  (:,DOY_PSU  >=DOY_start & DOY_PSU  <=DOY_end)');
AOD_MFRSR_mean=mean(AOD_MFRSR(:,DOY_MFRSR>=DOY_start & DOY_MFRSR<=DOY_end)');
AOD_AATS6_mean=mean(AOD_AATS6(:,DOY_AATS6>=DOY_start & DOY_AATS6<=DOY_end)');
AOD_Cimel_mean=mean(AOD_Cimel(:,DOY_Cimel>=DOY_start & DOY_Cimel<=DOY_end)');
AOD_Error_AATS6_mean=mean(AOD_Error_AATS6(:,DOY_AATS6>=DOY_start & DOY_AATS6<=DOY_end)');
AOD_RSS_mean=mean(AOD_RSS(:,DOY_RSS>=DOY_start & DOY_RSS<=DOY_end)');
loglog(lambda_RSS ,AOD_RSS_mean,'g-',...
       lambda_AATS6,AOD_AATS6_mean,'kx',...
       lambda_Cimel,AOD_Cimel_mean,'bo',...
       lambda_MFRSR,AOD_MFRSR_mean,'mv','MarkerSize',8)
    
%lambda_PSU,AOD_PSU_mean,'r*'    
hold on
errorbar(lambda_AATS6,AOD_AATS6_mean,AOD_Error_AATS6_mean,AOD_Error_AATS6_mean,'kx')
%set(gca,'ylim',[.01 0.1]);
%set(gca,'ylim',[.04 0.3]);
%set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07,0.08,0.09,0.1]);
%set(gca,'ytick',[0.04 0.05 0.06 0.07,0.08,0.09,0.1 0.2 0.3 0.4 0.5]);
set(gca,'xlim',[.30 1.10]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1]);
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Aerosol Optical Depth','FontSize',14);
title(sprintf('%s %g-%g ','Time',DOY_start,DOY_end));
hold off
%legend('RSS','AATS-6','Cimel','MFRSR','PSU')
legend('RSS','AATS-6','Cimel','MFRSR')
set(gca,'FontSize',14)
set(gca,'ylim',[.018 0.26]);
set(gca,'ytick',[0.02 0.03 0.04 0.05 0.06 0.07,0.08,0.09,0.1 0.14 0.18 0.22 0.26]);
grid on

%Compare with MFRSR *****************************************************************************
%Compare 450.7 nm of AATS-6 with MFRSR interpolated from 413.9 and 499.3
range=[0:0.01:0.4];
figure(6)
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
x=interp1(DOY_AATS6,AOD_AATS6(2,:),DOY_MFRSR(i),'nearest');
y=AOD_MFRSR_AATS6(1,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.2,0.08,sprintf('y = %5.3f x + %5.3f',p))
text(0.2,0.06,sprintf('r²= %5.3f',r.^2))
text(0.2,0.04,sprintf('RMSE = %5.3f',rmse))
text(0.2,0.02,sprintf('n = %5i',n))
xlabel('AOD 450.7 nm AATS-6')
ylabel('AOD 450.7 nm (interp) MFRSR')
axis([0 0.4 0 0.4])

subplot(2,2,2)
plot(DOY_MFRSR(i),x-y,'.')
ylabel('AOD 450.7 nm  AATS-6 - MFRSR')
xlabel('Day of Year 1997')
text(271,-0.03,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.05,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.08,sprintf('rms= %5.3f ',rmsd))
grid on
axis([-inf inf -0.1 0.1])

%Compare 525.3 nm of AATS-6 with MFRSR interpolated from 499.3 and 608.5
range=[0:0.01:0.4];
figure(7)
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
x=interp1(DOY_AATS6,AOD_AATS6(3,:),DOY_MFRSR(i),'nearest');
y=AOD_MFRSR_AATS6(2,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.2,0.08,sprintf('y = %5.3f x + %5.3f',p))
text(0.2,0.06,sprintf('r²= %5.3f',r.^2))
text(0.2,0.04,sprintf('RMSE = %5.3f',rmse))
text(0.2,0.02,sprintf('n = %5i',n))
xlabel('AOD 525.3 nm AATS-6')
ylabel('AOD 525.3 nm (interp) MFRSR')
axis([0 0.4 0 0.4])

subplot(2,2,2)
plot(DOY_MFRSR(i),x-y,'.')
ylabel('AOD 525.3 nm  AATS-6 - MFRSR')
xlabel('Day of Year 1997')
text(271,-0.03,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.05,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.08,sprintf('rms= %5.3f ',rmsd))
grid on
axis([-inf inf -0.1 0.1])

%Compare 863.9 of AATS-6 and  859.9 of MFRSR 
range=[0:0.01:0.2];
figure(8)
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
axis([0 0.2 0 0.2])

subplot(2,2,2)
plot(DOY_MFRSR(i),x-y,'.')
ylabel('AOD 860 nm  AATS-6 - MFRSR')
xlabel('Day of Year 1997')
text(271,-0.03,sprintf('mean = %5.3f ',mean(x-y)))
text(271,-0.05,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,-0.08,sprintf('rms= %5.3f ',rmsd))
grid on
axis([-inf inf -0.1 0.1])

%Compare with Cimel ********************************************************************

%Compare 380 nm of Cimel with AATS-6
range=[0:0.1:0.5];
figure(9)
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
AOD_AATS6_int=(interp1(DOY_AATS6,AOD_AATS6',DOY_Cimel(i),'nearest'))';
x=AOD_AATS6_int(1,:);
y=AOD_Cimel(2,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit2,delta] = polyval(p,range,S);

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
text(256,-0.04,sprintf('mean AOD= %5.3f ',mean(x)))
text(256,-0.05,sprintf('mean diff = %5.3f ',mean(x-y)))
text(256,-0.06,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.07,sprintf('rms= %5.3f ',rmsd))
grid on

%plot nice figure with 380 nm only
figure (91)
plot(x,y,'k.',range,y_fit2,'k--',range,range,'k')
axis([-inf inf -inf inf])
text(0.3,0.22,sprintf('y = %5.3f x + %5.3f',p))
text(0.3,0.19,sprintf('r²= %5.3f',r.^2))
text(0.3,0.16,sprintf('rms = %5.3f',rmsd))
text(0.3,0.13,sprintf('n = %5i',n))
xlabel('AOD 380 nm - AATS-6','FontSize',14)
ylabel('AOD 380 nm - Cimel','FontSize',14)
set(gca,'FontSize',14)
axis square


%Compare 450.7nm of AATS-6 with Cimel interpolated from 440 and 500 nm 
range=[0:0.1:0.4];
figure(10)

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
AOD_AATS6_int=(interp1(DOY_AATS6,AOD_AATS6',DOY_Cimel(i),'nearest'))';
x=AOD_AATS6_int(2,:);
y=AOD_Cimel_AATS6(2,i);
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
xlabel('AOD 450.7 nm AATS-6')
ylabel('AOD 450.7 nm (interp)Cimel')

subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 450.7 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.015,sprintf('mean AOD= %5.3f ',mean(x)))
text(256,-0.025,sprintf('mean diff= %5.3f ',mean(x-y)))
text(256,-0.035,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.045,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 525.3 nm of AATS-6 with Cimel interpolated from 500 and 670 nm 
range=[0:0.1:0.4];
figure(11)

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
AOD_AATS6_int=(interp1(DOY_AATS6,AOD_AATS6',DOY_Cimel(i),'nearest'))';
x=AOD_AATS6_int(3,:);
y=AOD_Cimel_AATS6(3,i);
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
xlabel('AOD 525.3 nm AATS-6')
ylabel('AOD 525.3 nm (interp)Cimel')

subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 525.3 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.015,sprintf('mean AOD= %5.3f ',mean(x)))
text(256,-0.025,sprintf('mean diff= %5.3f ',mean(x-y)))
text(256,-0.035,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.045,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 864 and 870 nm of AATS-6 and Cimel 
range=[0:0.02:0.15];
figure(12)
subplot(2,2,4)
plot(DOY_Cimel(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,1)
plot(DOY_Cimel(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(4,:);
y=AOD_Cimel(6,i);
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
xlabel('AOD 864 nm AATS-6')
ylabel('AOD 870 nm Cimel')
subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 870 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.015,sprintf('mean AOD= %5.3f ',mean(x)))
text(256,-0.025,sprintf('mean diff= %5.3f ',mean(x-y)))
text(256,-0.035,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.045,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 1020 nm of Cimel with AATS-6
range=[0:0.02:0.14];
figure(13)
subplot(2,2,4)
plot(DOY_Cimel(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on
subplot(2,2,1)
plot(DOY_Cimel(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(5,:);
y=AOD_Cimel(7,i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit2,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',x,y_fit,range,range)
axis([-inf inf -inf inf])
text(0.08,0.045,sprintf('y = %5.3f x + %5.3f',p))
text(0.08,0.035,sprintf('r²= %5.3f',r.^2))
text(0.08,0.025,sprintf('RMSE = %5.3f',rmse))
text(0.08,0.015,sprintf('n = %5i',n))
xlabel('AOD 1021 nm AATS-6')
ylabel('AOD 1019 nm Cimel')
subplot(2,2,2)
plot(DOY_Cimel(i),x-y,'.')
ylabel('AOD 1020 nm  AATS-6 - Cimel')
xlabel('Day of Year 1997')
text(256,-0.015,sprintf('mean AOD= %5.3f ',mean(x)))
text(256,-0.025,sprintf('mean diff= %5.3f ',mean(x-y)))
text(256,-0.035,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(256,-0.045,sprintf('rms= %5.3f ',rmsd))
grid on

%plot nice figure with 1020 nm only
figure (131)
plot(x,y,'k.',range,y_fit2,'k--',range,range,'k')
axis([-inf inf -inf inf])
text(0.1,0.07,sprintf('y = %5.3f x + %5.3f',p))
text(0.1,0.06,sprintf('r²= %5.3f',r.^2))
text(0.1,0.05,sprintf('rms = %5.3f',rmsd))
text(0.1,0.04,sprintf('n = %5i',n))
xlabel('AOD 1021 nm - AATS-6','FontSize',14)
ylabel('AOD 1019 nm - Cimel','FontSize',14)
set(gca,'FontSize',14)
axis square

%Compare with RSS ********************************************************************

%Compare 380 nm of AATS-6 and RSS
range=[0:0.05:0.5];
figure(14)
y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS,'nearest');
delta_t=(DOY_RSS-y)*24*60;
alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_RSS,'nearest');
i=find(abs(delta_t)<=0.5 & alpha>=0.75);

subplot(2,2,1)
plot(DOY_RSS(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
AOD_AATS6_int=(interp1(DOY_AATS6,AOD_AATS6',DOY_RSS(i),'nearest'))';
x=AOD_AATS6_int(1,:);
y=AOD_RSS_AATS6(1,i);
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
text(0.3,0.09,sprintf('y = %5.3f x + %5.3f',p))
text(0.3,0.06,sprintf('r²= %5.3f',r.^2))
text(0.3,0.03,sprintf('RMSE = %5.3f',rmse))
text(0.3,0.01,sprintf('n = %5i',n))
xlabel('AOD 380 nm AATS-6')
ylabel('AOD 380 nm RSS')

subplot(2,2,2)
t=DOY_RSS(i);
plot(t(j),x-y,'.')
ylabel('AOD 380 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(264,0.010,sprintf('mean = %5.3f ',mean(x-y)))
text(264,0.03,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(264,0.050,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 451 nm of AATS-6 and RSS
range=[0:0.1:0.4];
figure(15)

subplot(2,2,1)
plot(DOY_RSS(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(2,:);
y=AOD_RSS_AATS6(2,i);
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
t=DOY_RSS(i);
plot(t(j),x-y,'.')
ylabel('AOD 451 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,0.1,sprintf('mean = %5.3f ',mean(x-y)))
text(271,0.08,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.06,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 525 nm of AATS-6 and RSS
range=[0:0.1:0.3];
figure(16)

subplot(2,2,1)
plot(DOY_RSS(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(3,:);
y=AOD_RSS_AATS6(3,i);
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
t=DOY_RSS(i);
plot(t(j),x-y,'.')
ylabel('AOD 525 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,0.1,sprintf('mean = %5.3f ',mean(x-y)))
text(271,0.08,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.06,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 864 nm of AATS-6 and RSS
range=[0:0.05:0.25];
figure(17)
subplot(2,2,1)
plot(DOY_RSS(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(4,:);
y=AOD_RSS_AATS6(4,i);
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
xlabel('AOD 862 nm AATS-6')
ylabel('AOD 862 nm RSS')

subplot(2,2,2)
t=DOY_RSS(i);
plot(t(j),x-y,'.')
ylabel('AOD 862 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,0.1,sprintf('mean = %5.3f ',mean(x-y)))
text(271,0.08,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.06,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare 1020 nm of AATS-6 and RSS
range=[0:0.05:0.25];
figure(18)
subplot(2,2,1)
plot(DOY_RSS(i),alpha(i),'.');
ylabel('Alpha')
xlabel('Day of Year 1997')
grid on

subplot(2,2,4)
plot(DOY_RSS(i),delta_t(i),'.')
ylabel('Time Difference (min)')
xlabel('Day of Year 1997')
grid on

subplot(2,2,3)
x=AOD_AATS6_int(5,:);
y=AOD_RSS_AATS6(5,i);
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
xlabel('AOD 1020 nm AATS-6')
ylabel('AOD 1020 nm RSS')

subplot(2,2,2)
t=DOY_RSS(i);
plot(t(j),x-y,'.')
ylabel('AOD 1020 nm  AATS-6 - RSS')
xlabel('Day of Year 1997')
text(271,0.1,sprintf('mean = %5.3f ',mean(x-y)))
text(271,0.08,sprintf('stdev= %5.3f ',std(x-y)))
rmsd=(sum((x-y).^2)/(n-1))^0.5;
text(271,0.06,sprintf('rms= %5.3f ',rmsd))
grid on


%Compare with PSU *****************************************************************************
%Compare 380 nm of PSU and AATS-6
%range=[0:0.1:0.5];
%figure(15)
%y=interp1(DOY_AATS6,DOY_AATS6,DOY_PSU,'nearest');
%delta_t=(DOY_PSU-y)*24*60;
%alpha=interp1(DOY_AATS6,alpha_AATS6,DOY_PSU,'nearest');
%i=find(abs(delta_t)<=0.2 & alpha>=0.75);

%subplot(2,2,1)
%plot(DOY_PSU(i),alpha(i),'.');
%ylabel('Alpha')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,4)
%plot(DOY_PSU(i),delta_t(i),'.')
%ylabel('Time Difference (min)')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,3)
%x=interp1(DOY_AATS6,AOD_AATS6(1,:),DOY_PSU(i),'nearest');
%y=AOD_PSU(1,i);
%[p,S] = polyfit (x,y,1);
%[y_fit,delta] = polyval(p,x,S);
%[m,n]=size(x);
%rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
%r=corrcoef(x,y);
%r=r(1,2);
%plot(x,y,'.',x,y_fit,range,range)
%text(0.3,0.25,sprintf('y = %5.3f x + %5.3f',p))
%text(0.3,0.2,sprintf('r²= %5.3f',r.^2))
%text(0.3,0.15,sprintf('RMSE = %5.3f',rmse))
%text(0.3,0.1,sprintf('n = %5i',n))
%xlabel('AOD 380 nm AATS-6')
%ylabel('AOD 380 nm PSU')
%axis([0 0.5 0 0.5])

%subplot(2,2,2)
%plot(DOY_PSU(i),x-y,'.')
%ylabel('AOD 860 nm  AATS-6 - PSU')
%xlabel('Day of Year 1997')
%text(271,-0.03,sprintf('mean = %5.3f ',mean(x-y)))
%text(271,-0.05,sprintf('stdev= %5.3f ',std(x-y)))
%rmsd=(sum((x-y).^2)/(n-1))^0.5;
%text(271,-0.08,sprintf('rms= %5.3f ',rmsd))
%grid on
%axis([260 280 -0.15 0.15])

%Compare 519 and 525 nm of PSU and AATS-6
%figure(16)

%subplot(2,2,1)
%plot(DOY_PSU(i),alpha(i),'.');
%ylabel('Alpha')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,4)
%plot(DOY_PSU(i),delta_t(i),'.')
%ylabel('Time Difference (min)')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,3)
%x=interp1(DOY_AATS6,AOD_AATS6(3,:),DOY_PSU(i),'nearest');
%Y=AOD_PSU(4,i);
%[p,S] = polyfit (x,y,1);
%[y_fit,delta] = polyval(p,x,S);
%[m,n]=size(x);
%rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
%r=corrcoef(x,y);
%r=r(1,2);
%plot(x,y,'.',x,y_fit,range,range)
%text(0.3,0.25,sprintf('y = %5.3f x + %5.3f',p))
%text(0.3,0.2,sprintf('r²= %5.3f',r.^2))
%text(0.3,0.15,sprintf('RMSE = %5.3f',rmse))
%text(0.3,0.1,sprintf('n = %5i',n))
%xlabel('AOD 525 nm AATS-6')
%ylabel('AOD 519 nm PSU')
%axis([0 0.4 0 0.4])

%subplot(2,2,2)
%plot(DOY_PSU(i),x-y,'.')
%ylabel('AOD 525 nm  AATS-6 - PSU')
%xlabel('Day of Year 1997')
%text(271,-0.07,sprintf('mean = %5.3f ',mean(x-y)))
%text(271,-0.1,sprintf('stdev= %5.3f ',std(x-y)))
%rmsd=(sum((x-y).^2)/(n-1))^0.5;
%text(271,-0.13,sprintf('rms= %5.3f ',rmsd))
%grid on
%axis([260 280 -0.15 0.15])

%Compare 872 and 864 nm of PSU and AATS-6
%range=[0:0.1:0.2];
%figure(17)

%subplot(2,2,1)
%plot(DOY_PSU(i),alpha(i),'.');
%ylabel('Alpha')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,4)
%plot(DOY_PSU(i),delta_t(i),'.')
%ylabel('Time Difference (min)')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,3)
%x=interp1(DOY_AATS6,AOD_AATS6(4,:),DOY_PSU(i),'nearest');
%y=AOD_PSU(8,i);
%[p,S] = polyfit (x,y,1);
%[y_fit,delta] = polyval(p,x,S);
%[m,n]=size(x);
%rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
%r=corrcoef(x,y);
%r=r(1,2);
%plot(x,y,'.',x,y_fit,range,range)
%text(0.1,0.1,sprintf('y = %5.3f x + %5.3f',p))
%text(0.1,0.08,sprintf('r²= %5.3f',r.^2))
%text(0.1,0.06,sprintf('RMSE = %5.3f',rmse))
%text(0.1,0.04,sprintf('n = %5i',n))
%xlabel('AOD 864 nm AATS-6')
%ylabel('AOD 872 nm PSU')
%axis([0 0.2 0 0.2])

%subplot(2,2,2)
%plot(DOY_PSU(i),x-y,'.')
%ylabel('AOD 872 nm  AATS-6 - PSU')
%xlabel('Day of Year 1997')
%text(271,-0.07,sprintf('mean = %5.3f ',mean(x-y)))
%text(271,-0.1,sprintf('stdev= %5.3f ',std(x-y)))
%rmsd=(sum((x-y).^2)/(n-1))^0.5;
%text(271,-0.13,sprintf('rms= %5.3f ',rmsd))
%grid on
%axis([260 280 -0.15 0.15])

%Compare 1028 and 1021 nm of PSU and AATS-6
%range=[0:0.1:0.2];
%figure(18)

%subplot(2,2,1)
%plot(DOY_PSU(i),alpha(i),'.');
%ylabel('Alpha')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,4)
%plot(DOY_PSU(i),delta_t(i),'.')
%ylabel('Time Difference (min)')
%xlabel('Day of Year 1997')
%grid on

%subplot(2,2,3)
%x=interp1(DOY_AATS6,AOD_AATS6(5,:),DOY_PSU(i),'nearest');
%y=AOD_PSU(9,i);
%[p,S] = polyfit (x,y,1);
%[y_fit,delta] = polyval(p,x,S);
%[m,n]=size(x);
%rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
%r=corrcoef(x,y);
%r=r(1,2);
%plot(x,y,'.',x,y_fit,range,range)
%text(0.1,0.1,sprintf('y = %5.3f x + %5.3f',p))
%text(0.1,0.08,sprintf('r²= %5.3f',r.^2))
%text(0.1,0.06,sprintf('RMSE = %5.3f',rmse))
%text(0.1,0.04,sprintf('n = %5i',n))
%xlabel('AOD 1021 nm AATS-6')
%ylabel('AOD 1028 nm PSU')
%axis([0 0.2 0 0.2])

%subplot(2,2,2)
%plot(DOY_PSU(i),x-y,'.')
%ylabel('AOD 1021 nm  AATS-6 - PSU')
%xlabel('Day of Year 1997')
%text(271,-0.07,sprintf('mean = %5.3f ',mean(x-y)))
%text(271,-0.1,sprintf('stdev= %5.3f ',std(x-y)))
%rmsd=(sum((x-y).^2)/(n-1))^0.5;
%text(271,-0.13,sprintf('rms= %5.3f ',rmsd))
%grid on
%axis([260 280 -0.15 0.15])