lambda_Cimel= [1020  870  670   500   440   380  340]/1e3;
AOD_Cimel_err=[0.01 0.01 0.01 0.015 0.015 0.015 0.02];
lambda_fit=[0.325:0.025:1.6];
lambda_AATS14=[0.3535 0.3800 0.4490 0.4994 0.5246 0.6057 0.6751 0.7784 0.8645 1.0191 1.2413 1.5574]; %for SAFARI-2000
    
load c:\beat\data\safari-2000\cimel\cimel_aats14.mat

UT_start=data(:,1);
UT_end=data(:,2);
target_dist=data(:,3);
target_alt=data(:,4);
GPS_Altitude=data(:,5);
Pressure_Altitude=data(:,6);
AOD_Cimel=data(:,7:13);
AOD_fit_Cimel=data(:,14:20);
AOD_AATS14=data(:,21:32);
AOD_err_AATS14=data(:,33:44);
AOD_fit_all=data(:,45:96);


%creat multframe plot of spectra
figure(1)
for i=1:length(UT_start)
    subplot(4,3,i)    
    loglog(lambda_fit,AOD_fit_all(i,:),'k')
    hold on
    yerrorbar('loglog',0.3,1.6,0.01,3,lambda_AATS14,AOD_AATS14(i,:),AOD_err_AATS14(i,:),'ko')
    yerrorbar('loglog',0.3,1.6,0.01,3,lambda_Cimel,AOD_Cimel(i,:),AOD_Cimel_err,'ro')
    loglog(lambda_AATS14,AOD_AATS14(i,:),'ko','MarkerFaceColor','k')
    loglog(lambda_Cimel,AOD_Cimel(i,:),'ro','MarkerFaceColor','r')
    hold off
    set(gca,'ylim',[-inf inf]);
    %set(gca,'ytick',);
    %set(gca,'yticklabel',['0.01';'0.1 ';'1   ';'2   ']);
    set(gca,'xlim',[.30 1.6]);
    set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6]);
    set(gca,'xticklabel',[' .3';' .4';' .5';' .6';' .7';' .8';'   ';'1  ';'   ';'   ';'1.3';'   ';'   ';'1.6']);

    %xlabel('Wavelength [\mum]');
    %ylabel('AOD');
    grid on
end
legend('AERONET','AATS-14')

%do statistics

figure(2)
orient landscape
subplot(2,4,1)
%compare 340 nm
x=AOD_Cimel(:,7);
y=AOD_fit_Cimel(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 2.5];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
axis([0 2.5 0 2.5])
set(gca,'xtick',[0:0.5:2.5])
set(gca,'ytick',[0:0.5:2.5])
axis square
text(1.1,0.7 ,sprintf('340 nm'))
text(1.1,0.5 ,sprintf('n= %i ',n))
text(1.1,0.3,sprintf('y = %5.3f x + %5.3f',p))
text(1.1,0.1 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))

subplot(2,4,2)
%compare 380 nm
x=AOD_Cimel(:,6);
y=AOD_AATS14(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 2.5];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
axis([0 2.5 0 2.5])
set(gca,'xtick',[0:0.5:2.5])
set(gca,'ytick',[0:0.5:2.5])
axis square
text(1.1,0.7 ,sprintf('380 nm'))
text(1.1,0.5 ,sprintf('n= %i ',n))
text(1.1,0.3,sprintf('y = %5.3f x + %5.3f',p))
text(1.1,0.1 ,sprintf('rms= %5.3f ',rmsd))

subplot(2,4,3)
%compare 440 nm
x=AOD_Cimel(:,5);
y=AOD_fit_Cimel(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 2];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
axis([0 2 0 2])
set(gca,'xtick',[0:0.5:2])
set(gca,'ytick',[0:0.5:2])
axis square
text(.8,0.55 ,sprintf('440 nm'))
text(.8,0.4 ,sprintf('n= %i ',n))
text(.8,0.25,sprintf('y = %5.3f x + %5.3f',p))
text(.8,0.1 ,sprintf('rms= %5.3f ',rmsd))

subplot(2,4,4)
%compare 500 nm
x=AOD_Cimel(:,4);
y=AOD_AATS14(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 1.5];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
axis([0 1.5 0 1.5])
set(gca,'xtick',[0:0.5:1.5])
set(gca,'ytick',[0:0.5:1.5])
axis square
text(.6,0.4 ,sprintf('500 nm'))
text(.6,0.3 ,sprintf('n= %i ',n))
text(.6,0.2,sprintf('y = %5.3f x + %5.3f',p))
text(.6,0.1 ,sprintf('rms= %5.3f ',rmsd))


subplot(2,4,5)
%compare 670 nm
x=AOD_Cimel(:,3);
y=AOD_AATS14(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 1];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
axis([0 1 0 1])
set(gca,'xtick',[0:0.2:1])
set(gca,'ytick',[0:0.2:1])
axis square
text(.4,0.26 ,sprintf('670 nm'))
text(.4,0.19 ,sprintf('n= %i ',n))
text(.4,0.12,sprintf('y = %5.3f x + %5.3f',p))
text(.4,0.05 ,sprintf('rms= %5.3f ',rmsd))

subplot(2,4,6)
%compare 870 nm
x=AOD_Cimel(:,2);
y=AOD_AATS14(:,9);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 .5];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'*k',range,y_fit,'k--',range,range,'k')
axis([0 .5 0 .5])
set(gca,'xtick',[0:0.1:.5])
set(gca,'ytick',[0:0.1:.5])
axis square
text(.2,0.14 ,sprintf('870 nm'))
text(.2,0.1 ,sprintf('n= %i ',n))
text(.2,0.06,sprintf('y = %5.3f x + %5.3f',p))
text(.2,0.02 ,sprintf('rms= %5.3f ',rmsd))

subplot(2,4,7)
%compare 1020 nm
x=AOD_Cimel(:,1);
y=AOD_AATS14(:,10);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
range=[0 .4];
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,range,S);
plot(x,y,'k*',range,y_fit,'k--',range,range,'k')
set(gca,'xtick',[0:0.1:.4])
set(gca,'ytick',[0:0.1:.4])
axis([0 0.4 0 0.4])
axis square
text(.15,0.11 ,sprintf('1020 nm'))
text(.15,0.08 ,sprintf('n= %i ',n))
text(.15,0.05,sprintf('y = %5.3f x + %5.3f',p))
text(.15,0.02 ,sprintf('rms= %5.3f ',rmsd))


figure(3)
subplot(2,4,1)
%compare 340 nm
x=AOD_Cimel(:,7);
y=AOD_fit_Cimel(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('340 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on


subplot(2,4,2)
%compare 380 nm
x=AOD_Cimel(:,6);
y=AOD_AATS14(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('380 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,3)
%compare 440 nm
x=AOD_Cimel(:,5);
y=AOD_fit_Cimel(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('440 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,4)
%compare 500 nm
x=AOD_Cimel(:,4);
y=AOD_AATS14(:,4);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('500 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on


subplot(2,4,5)
%compare 670 nm
x=AOD_Cimel(:,3);
y=AOD_AATS14(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('670 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,6)
%compare 870 nm
x=AOD_Cimel(:,2);
y=AOD_AATS14(:,9);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('870 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,7)
%compare 1020 nm
x=AOD_Cimel(:,1);
y=AOD_AATS14(:,10);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
plot(x-y,'*')
axis([0 11 -0.2 0.2])
text(1.1,-0.09 ,sprintf('1020 nm'))
text(1.1,-0.12 ,sprintf('rms= %3.1f %%',100*rmsd/mean(x)))
text(1.1,-0.15 ,sprintf('mean AOD= %3.2f',mean(x)))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

figure(4)
subplot(2,4,1)
%compare 340 nm
x=AOD_Cimel(:,7);
y=AOD_fit_Cimel(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('340 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on


subplot(2,4,2)
%compare 380 nm
x=AOD_Cimel(:,6);
y=AOD_AATS14(:,2);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('380 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,3)
%compare 440 nm
x=AOD_Cimel(:,5);
y=AOD_fit_Cimel(:,5);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('440 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
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
text(1.1,-0.15 ,sprintf('500 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on


subplot(2,4,5)
%compare 670 nm
x=AOD_Cimel(:,3);
y=AOD_AATS14(:,7);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('670 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,6)
%compare 870 nm
x=AOD_Cimel(:,2);
y=AOD_AATS14(:,9);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('870 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on

subplot(2,4,7)
%compare 1020 nm
x=AOD_Cimel(:,1);
y=AOD_AATS14(:,10);
ii=~isnan(x);
x=x(ii);
y=y(ii);
n=length(x);
plot(x,x-y,'*')
axis([0 inf -0.2 0.2])
text(1.1,-0.15 ,sprintf('1020 nm'))
text(1.1,-0.18 ,sprintf('n= %i ',n))
grid on


