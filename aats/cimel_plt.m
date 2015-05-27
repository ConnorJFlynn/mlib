%plots Cimel_AATS14 intercomparison
clear all
close all
lambda_Cimel= [340  380   440   500   670  870  1020 1640]/1e3;
AOD_Cimel_err=[0.02 0.015 0.015 0.015 0.01 0.01 0.01 0.01];
lambda_fit=[0.325:0.025:2.2];
lambda_AATS14=[0.3535 0.3800 0.4526 0.4994 0.5194 0.6044 0.6751 0.7784 0.8645 1.0191 1.2413 1.5578 2.1393]; %for SOLVE-2 and A-IOP

[A, B]= xlsread('c:\beat\data\aerosol iop\aeronet\cimel_aats14.xls','cimel_aats14 Tsay (2)') ;

UT_start=A(2:end,1);
UT_end=A(2:end,2);
DOY_Cimel=A(2:end,3);
Delta_t=A(2:end,4);
target_dist=A(2:end,5);
target_alt=A(2:end,6);
GPS_Altitude=A(2:end,7);
Pressure_Altitude=A(2:end,8);
AOD_Cimel=A(2:end,9:16);
AOD_fit_Cimel=A(2:end,17:24);
AOD_AATS14=A(2:end,25:37);
AOD_err_AATS14=A(2:end,38:50);
AOD_fit_all=A(2:end,51:126);
CWV_Cimel=A(2:end,127);
CWV_AATS14=A(2:end,128);
CWV_Err_AATS14=A(2:end,129);
lambda_Cimel=A(2,130:end);
%lambda_Cimel(8)=NaN

%correct for gaseous absorption according to Smirnov
AOD_Cimel(:,7)=AOD_Cimel(:,7)              -(0.0023*CWV_Cimel+0.0002); %H2O
AOD_Cimel(:,8)=AOD_Cimel(:,8)-0.0036-0.0089-(0.0014*CWV_Cimel-0.0003); %CO2&CH4&H2O

%creat multframe plot of spectra
figure(1)
for i=1:length(UT_start)
    subplot(6,3,i)    
    loglog(lambda_fit,AOD_fit_all(i,:),'k')
    hold on
    yerrorbar('loglog',0.3,2.2,0.01,1,lambda_AATS14,AOD_AATS14(i,:),AOD_err_AATS14(i,:),'ko')
    yerrorbar('loglog',0.3,2.2,0.01,1,lambda_Cimel,AOD_Cimel(i,:),AOD_Cimel_err,'ro')
    loglog(lambda_AATS14,AOD_AATS14(i,:),'ko','MarkerFaceColor','k')
    loglog(lambda_Cimel,AOD_Cimel(i,:),'ro','MarkerFaceColor','r')
    hold off
    set(gca,'ylim',[0.02 0.6]);
    set(gca,'ytick',[0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6]);
    set(gca,'yticklabel',['0.02';'    ';'0.04';'    ';'0.06';'    ';'    ';'    ';'0.10';'0.20';'    ';'0.40';'    ';'0.60']);
    set(gca,'xlim',[.30 2.2]);
    set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2]);
    set(gca,'xticklabel',[' .3';' .4';' .5';' .6';' .7';' .8';'   ';'1  ';'1.2';'1.4';'   ';'1.8';'   ';'2.2']);

    %xlabel('Wavelength [\mum]');
    %ylabel('AOD');
    grid on
end
%legend('AERONET','AATS-14')

%do statistics

figure(2)
orient landscape
subplot(2,4,1)
%compare 340 nm
x=AOD_fit_Cimel(:,1);
y=AOD_Cimel(:,1);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.6];

plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.6 0 0.6])
set(gca,'xtick',[0:0.1:0.6])
set(gca,'ytick',[0:0.1:0.6])
axis square
text(0.25,0.18 ,sprintf('340 nm'))
text(0.25,0.13 ,sprintf('n= %i ',n))
text(0.25,0.08 ,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.25,0.03 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,2)
%compare 380 nm
x=AOD_AATS14(:,2);
y=AOD_Cimel(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.5];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.5 0 0.5])
set(gca,'xtick',[0:0.1:0.5])
set(gca,'ytick',[0:0.1:0.5])
axis square
text(0.2,0.15 ,sprintf('380 nm'))
text(0.2,0.11 ,sprintf('n= %i ',n))
text(0.2,0.07,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.2,0.03 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,3)
%compare 440 nm
x=AOD_fit_Cimel(:,3);
y=AOD_Cimel(:,3);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.5];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.5 0 0.5])
set(gca,'xtick',[0:0.1:0.5])
set(gca,'ytick',[0:0.1:0.5])
axis square
text(0.2,0.15 ,sprintf('440 nm'))
text(0.2,0.11 ,sprintf('n= %i ',n))
text(0.2,0.07,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.2,0.03 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,4)
%compare 500 nm
x=AOD_AATS14(:,4);
y=AOD_Cimel(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.4];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.4 0 0.4])
set(gca,'xtick',[0:0.1:0.4])
set(gca,'ytick',[0:0.1:0.4])
axis square
text(0.16,0.11 ,sprintf('500 nm'))
text(0.16,0.08 ,sprintf('n= %i ',n))
text(0.16,0.05,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.16,0.02 ,sprintf('r^2= %5.3f',r^2))

%compare 675 nm
subplot(2,4,5)
x=AOD_AATS14(:,7);
y=AOD_Cimel(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.4];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.4 0 0.4])
set(gca,'xtick',[0:0.1:0.4])
set(gca,'ytick',[0:0.1:0.4])
axis square
text(0.16,0.11 ,sprintf('675 nm'))
text(0.16,0.08 ,sprintf('n= %i ',n))
text(0.16,0.05,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.16,0.02 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,6)
%compare 870 nm
x=AOD_fit_Cimel(:,6);
y=AOD_Cimel(:,6);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.3];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.3 0 0.3])
set(gca,'xtick',[0:0.1:0.3])
set(gca,'ytick',[0:0.1:0.3])
axis square
text(0.12,0.08 ,sprintf('870 nm'))
text(0.12,0.06 ,sprintf('n= %i ',n))
text(0.12,0.04, sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.12,0.02 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,7)
%compare 1020 nm
x=AOD_AATS14(:,10);
y=AOD_Cimel(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.3];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
hold off
axis([0 0.3 0 0.3])
set(gca,'xtick',[0:0.1:0.3])
set(gca,'ytick',[0:0.1:0.3])
axis square
text(0.12,0.08 ,sprintf('1020 nm'))
text(0.12,0.06 ,sprintf('n= %i ',n))
text(0.12,0.04, sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.12,0.02 ,sprintf('r^2= %5.3f',r^2))

subplot(2,4,8)
%compare 1640 nm
x=AOD_fit_Cimel(:,8);
y=AOD_Cimel(:,8);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
mean_x=mean(x)
mean_y=mean(y)
rmsd=(sum((x-y).^2)/(n-1))^0.5
rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
bias=mean(y-x)
rel_bias=bias/mean(x)
range=[0 0.2];
plot(x,y,'k*',range,range,'k')
hold on
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')
axis([0 0.2 0 0.2])
set(gca,'xtick',[0:0.05:0.2])
set(gca,'ytick',[0:0.05:0.2])
axis square
text(0.1,0.046,sprintf('1640 nm'))
text(0.08,0.034,sprintf('n= %i ',n))
text(0.08,0.022,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.08,0.010,sprintf('r^2= %5.3f',r^2))


% nice figure with only 4 scatter plots
figure(21)
orient landscape
subplot(2,2,1)
%compare 340 nm
y=AOD_Cimel(:,1);
x=AOD_fit_Cimel(:,1);
n=length(x);
x_err=AOD_err_AATS14(:,1);
y_err=repmat(AOD_Cimel_err(1),1,n);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 0.6];
[m,b,r,sm,sb]=lsqbisec(x,y); %least square bisector
[y_fit] = polyval([m,b],range);
plot(x,y,'mo','MarkerSize',9,'MarkerFaceColor','m')
hold on
errorbar(x,y,y_err,-y_err,'m.')
xerrorbar('linlin',0,0.6,0,0.6,x,y,x_err,-x_err,'m.')
plot(range,y_fit,'k--',range,range,'k')
hold off
axis([0 0.6 0 0.6])
set(gca,'xtick',[0:0.1:0.6])
set(gca,'ytick',[0:0.1:0.6])
xlabel('AATS-14 AOD','FontSize',14)
ylabel('AERONET AOD','FontSize',14)
title('340 nm','FontSize',14);
text(0.25,0.13 ,sprintf('n= %i ',n),'FontSize',14)
text(0.25,0.08,sprintf('y = %5.3f x + %5.3f',[m b]),'FontSize',14)
text(0.25,0.03 ,sprintf('rms= %5.3f, %3.1f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',14)
set(gca,'FontSize',14)

subplot(2,2,2)
%compare 500 nm
y=AOD_Cimel(:,4);
x=AOD_AATS14(:,4);
n=length(x);
x_err=AOD_err_AATS14(:,4);
y_err=repmat(AOD_Cimel_err(4),1,n);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 0.5];
[m,b,r,sm,sb]=lsqbisec(x,y); %least square bisector
[y_fit] = polyval([m,b],range);
plot(x,y,'go','MarkerSize',9,'MarkerFaceColor','g')
hold on
errorbar(x,y,y_err,-y_err,'g.')
xerrorbar('linlin',0,0.5,0,0.5,x,y,x_err,-x_err,'g.')
plot(range,y_fit,'k--',range,range,'k')
hold off
axis([0 0.5 0 0.5])
set(gca,'xtick',[0:0.1:0.5])
set(gca,'ytick',[0:0.1:0.5])
xlabel('AATS-14 AOD','FontSize',14)
ylabel('AERONET AOD','FontSize',14)
title('500 nm','FontSize',14);
text(0.2,0.11 ,sprintf('n= %i ',n),'FontSize',14)
text(0.2,0.07,sprintf('y = %5.3f x + %5.3f',[m b]),'FontSize',14)
text(0.2,0.03 ,sprintf('rms= %5.3f, %3.1f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',14)
set(gca,'FontSize',14)


subplot(2,2,3)
%compare 870 nm
y=AOD_Cimel(:,6);
x=AOD_fit_Cimel(:,6);
n=length(x);
x_err=AOD_err_AATS14(:,9);
y_err=repmat(AOD_Cimel_err(6),1,n);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 0.3];
[m,b,r,sm,sb]=lsqbisec(x,y); %least square bisector
[y_fit] = polyval([m,b],range);
plot(x,y,'ro','MarkerSize',9,'MarkerFaceColor','r')
hold on
errorbar(x,y,y_err,-y_err,'r.')
xerrorbar('linlin',0,0.3,0,0.3,x,y,x_err,-x_err,'r.')
plot(range,y_fit,'k--',range,range,'k')
hold off
axis([0 0.3 0 0.3])
set(gca,'xtick',[0:0.1:0.3])
set(gca,'ytick',[0:0.1:0.3])
xlabel('AATS-14 AOD','FontSize',14)
ylabel('AERONET AOD','FontSize',14)
title('870 nm','FontSize',14);
text(0.12,0.06 ,sprintf('n= %i ',n),'FontSize',14)
text(0.12,0.04,sprintf('y = %5.3f x + %5.3f',[m b]),'FontSize',14)
text(0.12,0.02 ,sprintf('rms= %5.3f, %3.1f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',14)
set(gca,'FontSize',14)

subplot(2,2,4)
%compare 1020 nm
y=AOD_Cimel(:,7);
x=AOD_AATS14(:,10);
n=length(x);
x_err=AOD_err_AATS14(:,10);
y_err=repmat(AOD_Cimel_err(7),1,n);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 0.3];
[m,b,r,sm,sb]=lsqbisec(x,y); %least square bisector
[y_fit] = polyval([m,b],range);
plot(x,y,'ko','MarkerSize',9,'MarkerFaceColor','k')
hold on
errorbar(x,y,y_err,-y_err,'k.')
xerrorbar('linlin',0,0.25,0,0.25,x,y,x_err,-x_err,'k.')
plot(range,y_fit,'k--',range,range,'k')
hold off
axis([0 0.25 0 0.25])
set(gca,'xtick',[0:0.05:0.25])
set(gca,'ytick',[0:0.05:0.25])
xlabel('AATS-14 AOD','FontSize',14)
ylabel('AERONET AOD','FontSize',14)
title('1020 nm','FontSize',14);
text(0.13,0.054,sprintf('n= %i ',n),'FontSize',14)
text(0.13,0.037,sprintf('y = %5.3f x + %5.3f',[m b]),'FontSize',14)
text(0.13,0.02,sprintf('rms= %5.3f, %3.1f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',14)
set(gca,'FontSize',14)


%plot differences

figure(3)
subplot(2,4,1)
%compare 340 nm
x=AOD_Cimel(:,1);
y=AOD_fit_Cimel(:,1);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(1)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,2)
%compare 380 nm
x=AOD_Cimel(:,2);
y=AOD_AATS14(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(2)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,3)
%compare 440 nm
x=AOD_Cimel(:,3);
y=AOD_fit_Cimel(:,3);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(3)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,4)
%compare 500 nm
x=AOD_Cimel(:,4);
y=AOD_AATS14(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(4)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,5)
%compare 670 nm
x=AOD_Cimel(:,5);
y=AOD_AATS14(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(5)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,6)
%compare 870 nm
x=AOD_Cimel(:,6);
y=AOD_fit_Cimel(:,6);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(6)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,7)
%compare 1020 nm
x=AOD_Cimel(:,7);
y=AOD_AATS14(:,10);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(7)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,4,8)
%compare 1640 nm
x=AOD_Cimel(:,8);
y=AOD_fit_Cimel(:,8);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(x-y);
bias=repmat(bias,1,n+2);
plot(1:n,x-y,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_Cimel(8)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',mean(x-y), 100*mean(x-y)/mean(y)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
% text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
% text(1.1,-0.18 ,sprintf('n= %i ',n))
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')



figure(4)
subplot(2,4,1)
%compare 340 nm
x=AOD_Cimel(:,1);
y=AOD_fit_Cimel(:,1);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('340 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on


subplot(2,4,2)
%compare 380 nm
x=AOD_Cimel(:,2);
y=AOD_AATS14(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('380 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,3)
%compare 440 nm
x=AOD_Cimel(:,3);
y=AOD_fit_Cimel(:,3);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('440 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,4)
%compare 500 nm
x=AOD_Cimel(:,4);
y=AOD_AATS14(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('500 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,5)
%compare 670 nm
x=AOD_Cimel(:,5);
y=AOD_fit_Cimel(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('670 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,6)
%compare 870 nm
x=AOD_Cimel(:,6);
y=AOD_AATS14(:,9);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('870 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,7)
%compare 1020 nm
x=AOD_Cimel(:,7);
y=AOD_AATS14(:,10);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('1020 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,8)
%compare 1640 nm
x=AOD_Cimel(:,8);
y=AOD_fit_Cimel(:,8);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(0.1,-0.15 ,sprintf('1640 nm'))
text(0.1,-0.18 ,sprintf('n= %i ',n))
grid on