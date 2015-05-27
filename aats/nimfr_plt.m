%plots NIMFR_AATS14 intercomparison
clear all
close all
AOD_nimfr_err=[0.01 0.01 0.01 0.01 0.01];
lambda_fit=[0.325:0.025:2.2];
lambda_AATS14=[0.3535 0.3800 0.4526 0.4994 0.5194 0.6044 0.6751 0.7784 0.8645 1.0191 1.2413 1.5578 2.1393]; %for SOLVE-2 and A-IOP

[A, B]= xlsread('c:\beat\data\aerosol iop\nimfr\nimfr_aats14.xls','nimfr_aats14 (2)') ;

UT_start=A(2:end,1);
UT_end=A(2:end,2);
UT_nimfr=A(2:end,3);
Delta_t=A(2:end,4);
target_dist=A(2:end,5);
target_alt=A(2:end,6);
GPS_Altitude=A(2:end,7);
Pressure_Altitude=A(2:end,8);
AOD_nimfr=A(2:end,9:13);
AOD_fit_nimfr=A(2:end,14:18);
AOD_AATS14=A(2:end,19:31);
AOD_err_AATS14=A(2:end,32:44);
AOD_fit_all=A(2:end,45:120);
lambda_nimfr=A(2,121:125);


%creat multframe plot of spectra
figure(1)
for i=1:length(UT_start)
    subplot(4,3,i)    
    loglog(lambda_fit,AOD_fit_all(i,:),'k')
    hold on
    yerrorbar('loglog',0.3,2.2,0.01,1,lambda_AATS14,AOD_AATS14(i,:),AOD_err_AATS14(i,:),'ko')
    yerrorbar('loglog',0.3,2.2,0.01,1,lambda_nimfr,AOD_nimfr(i,:),AOD_nimfr_err,'ro')
    loglog(lambda_AATS14,AOD_AATS14(i,:),'ko','MarkerFaceColor','k')
    loglog(lambda_nimfr,AOD_nimfr(i,:),'ro','MarkerFaceColor','r')
    hold off
    set(gca,'ylim',[0.02 0.6]);
    set(gca,'ytick',[0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6]);
    set(gca,'yticklabel',['0.02';'    ';'0.04';'    ';'0.06';'    ';'    ';'    ';'0.10';'0.20';'    ';'0.40';'    ';'0.60']);
    set(gca,'xlim',[.30 2.2]);
    set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2]);
    set(gca,'xticklabel',[' .3';' .4';' .5';' .6';' .7';' .8';'   ';'1  ';'1.2';'1.4';'   ';'1.8';'   ';'2.2']);
    grid on
end

%do statistics

figure(2)
orient landscape
subplot(2,3,1)
%compare 415 nm
x=AOD_fit_nimfr(:,1);
y=AOD_nimfr(:,1);
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
hold on

plot(x,y,'k*',range,range,'k')

[my,by,ry,smy,sby]=lsqfity(x,y);
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([0 0.5 0 0.5])
set(gca,'xtick',[0:0.1:0.5])
set(gca,'ytick',[0:0.1:0.5])
axis square
text(0.25,0.18 ,sprintf('415 nm'))
text(0.25,0.13 ,sprintf('n= %i ',n))
text(0.25,0.08,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.25,0.03 ,sprintf('r^2= %5.3f',r^2))
hold off

subplot(2,3,2)
%compare 500 nm
x=AOD_AATS14(:,4);
y=AOD_nimfr(:,2);
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
hold on

plot(x,y,'k*',range,range,'k')

[my,by,ry,smy,sby]=lsqfity(x,y);
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([0 0.4 0 0.4])
set(gca,'xtick',[0:0.1:0.4])
set(gca,'ytick',[0:0.1:0.4])
axis square
text(0.2,0.15 ,sprintf('500 nm'))
text(0.2,0.11 ,sprintf('n= %i ',n))
text(0.2,0.07,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.2,0.03 ,sprintf('r^2= %5.3f',r^2))
hold off

subplot(2,3,3)
%compare 615 nm
x=AOD_fit_nimfr(:,3);
y=AOD_nimfr(:,3);
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

hold on

plot(x,y,'k*',range,range,'k')

[my,by,ry,smy,sby]=lsqfity(x,y);
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([0 0.4 0 0.4])
set(gca,'xtick',[0:0.1:0.4])
set(gca,'ytick',[0:0.1:0.4])
axis square
text(0.2,0.15 ,sprintf('615 nm'))
text(0.2,0.11 ,sprintf('n= %i ',n))
text(0.2,0.07,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.2,0.03 ,sprintf('r^2= %5.3f',r^2))
hold off

subplot(2,3,4)
%compare 673 nm
x=AOD_AATS14(:,7);
y=AOD_nimfr(:,4);
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
hold on

plot(x,y,'k*',range,range,'k')

[my,by,ry,smy,sby]=lsqfity(x,y);
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([0 0.4 0 0.4])
set(gca,'xtick',[0:0.1:0.4])
set(gca,'ytick',[0:0.1:0.4])
axis square
text(0.16,0.11 ,sprintf('673 nm'))
text(0.16,0.08 ,sprintf('n= %i ',n))
text(0.16,0.05,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.16,0.02 ,sprintf('r^2= %5.3f',r^2))
hold off

subplot(2,3,5)
%compare 870 nm
x=AOD_fit_nimfr(:,5);
y=AOD_nimfr(:,5);
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
hold on

plot(x,y,'k*',range,range,'k')

[my,by,ry,smy,sby]=lsqfity(x,y);
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([0 0.3 0 0.3])
set(gca,'xtick',[0:0.1:0.3])
set(gca,'ytick',[0:0.1:0.3])
axis square
text(0.16,0.11,sprintf('870 nm'))
text(0.16,0.08,sprintf('n= %i ',n))
text(0.16,0.05,sprintf('y = %5.3f x %+4.3f',[m,b]))
text(0.16,0.02,sprintf('r^2= %5.3f',r^2))

%plot differences

figure(3)
subplot(2,3,1)
%compare 415 nm
x=AOD_fit_nimfr(:,1);
y=AOD_nimfr(:,1);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(y-x);
bias=repmat(bias,1,n+2);
plot(1:n,y-x,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_nimfr(1)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',bias(1), 100*bias(1)/mean(x)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,3,2)
%compare 500 nm
x=AOD_AATS14(:,4);
y=AOD_nimfr(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(y-x);
bias=repmat(bias,1,n+2);
plot(1:n,y-x,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_nimfr(2)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',bias(1), 100*bias(1)/mean(x)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,3,3)
%compare 615 nm
x=AOD_fit_nimfr(:,3);
y=AOD_nimfr(:,3);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(y-x);
bias=repmat(bias,1,n+2);
plot(1:n,y-x,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_nimfr(3)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',bias(1), 100*bias(1)/mean(x)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,3,4)
%compare 673 nm
x=AOD_AATS14(:,7);
y=AOD_nimfr(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(y-x);
bias=repmat(bias,1,n+2);
plot(1:n,y-x,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_nimfr(4)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',bias(1), 100*bias(1)/mean(x)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')

subplot(2,3,5)
%compare 870 nm
x=AOD_fit_nimfr(:,5);
y=AOD_nimfr(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
bias=mean(y-x);
bias=repmat(bias,1,n+2);
plot(1:n,y-x,'ko','MarkerSize',8,'MarkerFaceColor','k') %plots points and mean difference line
hold on
plot(0:n+1,bias,'r-','LineWidth',2)
hold off
axis([0 n+1 -0.1 0.1])
text(1.1,-0.06 ,sprintf('%3.0f nm',lambda_nimfr(5)*1e3),'FontSize',13,'Color','r')
text(1.1,-0.075 ,sprintf('bias= %5.3f, %3.0f%%',bias(1), 100*bias(1)/mean(x)),'FontSize',13,'Color','r')
text(1.1,-0.09 ,sprintf('rms= %5.3f, %3.0f%%',rmsd, 100*rmsd/(mean(x)+mean(y))*2),'FontSize',13,'Color','r')
set (gca,'xtick',[1,3:3:18])
set (gca,'FontSize',13)
set(gca,'YGrid','on')