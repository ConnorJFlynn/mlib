clear

%read CART MWR
[DOY_CART_MWR,CWV_CART_MWR]=read_CART_MWR;

% reads AATS-6 data
[DOY_AATS6,CWV_AATS6]=read_AATS6;

%read Cimel data
%[DOY_Cimel,CWV_Cimel]=read_Cimel;
[DOY_Cimel,CWV_Cimel,SZA_Cimel]=read_Cimel_H2O;

%read Jim Barnard's new MFRSR data
[DOY_MFRSR,CWV_MFRSR,m_H2O_MFRSR]=read_MFRSR_h2o;

%read Joe Michalsky's MFRSR data (relative method)
[DOY_MFRSR_joe,CWV_MFRSR_joe,m_H2O_MFRSR_joe]=read_MFRSR_Joe_H2O;

%read RSS data
[DOY_RSS,CWV_RSS]=read_RSS_h2o;
%[DOY_RSS,CWV_RSS]=read_RSS_h2o_old;

%plot everything
figure(1)
subplot(2,1,1)
plot(DOY_AATS6,CWV_AATS6,DOY_Cimel,CWV_Cimel,'.-',DOY_RSS,CWV_RSS,DOY_MFRSR_joe,CWV_MFRSR_joe,...
     DOY_MFRSR,CWV_MFRSR,DOY_CART_MWR,CWV_CART_MWR)
legend('AATS-6 (A)','Cimel (A)','RSS (B)','MFRSR (B)','MFRSR (C)','CART MWR' )
subplot(2,1,2)
plot(DOY_MFRSR,m_H2O_MFRSR.*CWV_MFRSR,'c',DOY_MFRSR_joe,m_H2O_MFRSR_joe.*CWV_MFRSR_joe,'m')
for iday=1:22
 subplot(2,1,1)
 axis([257.5+iday 258+iday 0 6])
 subplot(2,1,2)
 axis([257.5+iday 258+iday -inf inf])
 pause
end


% nice plot
figure(2)

DOY_start=261;

plot( (DOY_AATS6-DOY_start)*24-5,CWV_AATS6,...
      (DOY_Cimel-DOY_start)*24-5,CWV_Cimel,'o-',...
      (DOY_RSS-DOY_start)*24-5,CWV_RSS,...
      (DOY_MFRSR_joe-DOY_start)*24-5,CWV_MFRSR_joe,...
      (DOY_MFRSR-DOY_start)*24-5,CWV_MFRSR,...
       (DOY_CART_MWR-DOY_start)*24-5,CWV_CART_MWR)

legend('AATS-6 (A)','Cimel (A)','RSS (B)','MFRSR (B)','MFRSR (C)','CART MWR' )
axis([ 11 13 3.2 5.2])
%axis([ 8 19 3.2 5.2])
grid on
xlabel('Local Time [h]','FontSize',14)
ylabel('CWV [cm]','FontSize',14)
text(11.1,3.5,'18 September 1997','FontSize',14)
set(gca,'FontSize',14)

%Compare CART_MWR with AATS-6
figure(3)
range=[0:0.01:5];
ii=find(DOY_CART_MWR>=min(DOY_AATS6) & DOY_CART_MWR<=max(DOY_AATS6));
DOY_CART_MWR=DOY_CART_MWR(ii);
CWV_CART_MWR=CWV_CART_MWR(ii);

y=interp1(DOY_AATS6,DOY_AATS6,DOY_CART_MWR,'nearest');
delta_t=(DOY_CART_MWR-y)*24*60*60;
i=find(abs(delta_t)<=12);

x=interp1(DOY_AATS6,CWV_AATS6,DOY_CART_MWR(i));
y=CWV_CART_MWR(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('RMSE = %5.3f',rmse),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
xlabel('CWV (cm) AATS-6','FontSize',14)
ylabel('CWV (cm) MWR CART','FontSize',14)
axis([0 5 0 5])
axis square
set(gca,'xtick',[0:1:5])
set(gca,'ytick',[0:1:5])
set(gca,'FontSize',14)

figure(4)
plot(DOY_CART_MWR(i),y-x,'.')
axis([257 277 -0.8 0.8])
ylabel('CART MWR - AATS-6 (cm)')
xlabel('Day of Year 1997')
text(263, 0.3,sprintf('mean y/x = %5.3f ',mean(y./x)))
text(263, 0.2,sprintf('stdev y/x = %5.3f ',std(y./x)))
text(263, 0.1,sprintf('mean AATS-6 = %5.3f ',mean(x)))
text(263,-0.1,sprintf('mean CART MWR = %5.3f ',mean(y)))
text(263,-0.3,sprintf('stdev= %5.3f ',std(y-x)))
rmsd=(sum((y-x).^2)/(n-1))^0.5;
text(263,-0.5,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare MFRSR with AATS-6
range=[0:0.01:5];
ii=find(DOY_MFRSR>=min(DOY_AATS6) & DOY_MFRSR<=max(DOY_AATS6));
DOY_MFRSR=DOY_MFRSR(ii);
CWV_MFRSR=CWV_MFRSR(ii);
y=interp1(DOY_AATS6,DOY_AATS6,DOY_MFRSR,'nearest');
delta_t=(DOY_MFRSR-y)*24*60*60;
i=find(abs(delta_t)<=12);

figure(5)
x=interp1(DOY_AATS6,CWV_AATS6,DOY_MFRSR(i));
y=CWV_MFRSR(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('RMSE = %5.3f',rmse),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
xlabel('CWV (cm) AATS-6','FontSize',14)
ylabel('CWV (cm) MFRSR (Method C)','FontSize',14)
axis([0 5 0 5])
axis square
set(gca,'xtick',[0:1:5])
set(gca,'ytick',[0:1:5])
set(gca,'FontSize',14)

figure(6)
plot(DOY_MFRSR(i),y-x,'.')
axis([257 277 -0.8 0.8])
ylabel('MFRSR(C) - AATS-6  (cm)')
xlabel('Day of Year 1997')
text(263, 0.3,sprintf('mean y/x = %5.3f ',mean(y./x)))
text(263, 0.2,sprintf('stdev y/x = %5.3f ',std(y./x)))
text(263, 0.1,sprintf('mean AATS-6 = %5.3f ',mean(x)))
text(263,-0.1,sprintf('mean MFRSR = %5.3f ',mean(y)))
text(263,-0.3,sprintf('stdev= %5.3f ',std(y-x)))
rmsd=(sum((y-x).^2)/(n-1))^0.5;
text(263,-0.5,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare RSS with AATS-6
range=[0:0.01:5];
ii=find(DOY_RSS>=min(DOY_AATS6) & DOY_RSS<=max(DOY_AATS6));
DOY_RSS=DOY_RSS(ii);
CWV_RSS=CWV_RSS(ii);

y=interp1(DOY_AATS6,DOY_AATS6,DOY_RSS,'nearest');
delta_t=(DOY_RSS-y)*24*60*60;
i=find(abs(delta_t)<=12);

x=interp1(DOY_AATS6,CWV_AATS6,DOY_RSS(i));
y=CWV_RSS(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
figure(7)
plot(x,y,'.',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('RMSE = %5.3f',rmse),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
xlabel('CWV (cm) AATS-6','FontSize',14)
ylabel('CWV (cm) RSS','FontSize',14)
axis([0 5 0 5])
axis square
set(gca,'xtick',[0:1:5])
set(gca,'ytick',[0:1:5])
set(gca,'FontSize',14)

figure(8)
plot(DOY_RSS(i),y-x,'.')
axis([257 277 -0.8 0.8])
ylabel('RSS - AATS-6  (cm)')
xlabel('Day of Year 1997')
text(263, 0.3,sprintf('mean y/x = %5.3f ',mean(y./x)))
text(263, 0.2,sprintf('stdev y/x = %5.3f ',std(y./x)))
text(263, 0.1,sprintf('mean AATS-6 = %5.3f ',mean(x)))
text(263,-0.1,sprintf('mean RSS = %5.3f ',mean(y)))
text(263,-0.3,sprintf('stdev diff= %5.3f ',std(y-x)))
rmsd=(sum((y-x).^2)/(n-1))^0.5;
text(263,-0.5,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare Cimel with AATS-6
figure(9)
range=[0:0.01:5];
ii=find(DOY_Cimel>=min(DOY_AATS6) & DOY_Cimel<=max(DOY_AATS6));
DOY_Cimel=DOY_Cimel(ii);
CWV_Cimel=CWV_Cimel(ii);

y=interp1(DOY_AATS6,DOY_AATS6,DOY_Cimel,'nearest');
delta_t=(DOY_Cimel-y)*24*60*60;
i=find(abs(delta_t)<=12);

x=interp1(DOY_AATS6,CWV_AATS6,DOY_Cimel(i));
y=CWV_Cimel(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'.',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('RMSE = %5.3f',rmse),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
xlabel('CWV (cm) AATS-6','FontSize',14)
ylabel('CWV (cm) Cimel','FontSize',14)
axis([0 5 0 5])
axis square
set(gca,'xtick',[0:1:5])
set(gca,'ytick',[0:1:5])
set(gca,'FontSize',14)

figure(10)
plot(DOY_Cimel(i),y-x,'.')
axis([257 277 -0.8 0.8])
ylabel('Cimel - AATS-6  (cm)')
xlabel('Day of Year 1997')
text(263, 0.3,sprintf('mean y/x = %5.3f ',mean(y./x)))
text(263, 0.2,sprintf('stdev y/x = %5.3f ',std(y./x)))
text(265.1, 0.1,sprintf('mean AATS-6 = %5.3f ',mean(x)))
text(265.1,-0.1,sprintf('mean Cimel = %5.3f ',mean(y)))
text(265.1,-0.3,sprintf('stdev= %5.3f ',std(y-x)))
rmsd=(sum((y-x).^2)/(n-1))^0.5;
text(265.1,-0.5,sprintf('rms= %5.3f ',rmsd))
grid on

%Compare MFRSR Joe with AATS-6
range=[0:0.01:5];
ii=find(DOY_MFRSR_joe>=min(DOY_AATS6) & DOY_MFRSR_joe<=max(DOY_AATS6));
DOY_MFRSR_joe=DOY_MFRSR_joe(ii);
CWV_MFRSR_joe=CWV_MFRSR_joe(ii);

y=interp1(DOY_AATS6,DOY_AATS6,DOY_MFRSR_joe,'nearest');
delta_t=(DOY_MFRSR_joe-y)*24*60*60;
i=find(abs(delta_t)<=12);

figure(11)
x=interp1(DOY_AATS6,CWV_AATS6,DOY_MFRSR_joe(i));
y=CWV_MFRSR_joe(i);
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
r=corrcoef(x,y);
r=r(1,2);

plot(x,y,'.',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('RMSE = %5.3f',rmse),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
xlabel('CWV (cm) AATS-6','FontSize',14)
ylabel('CWV (cm) MFRSR (Method B)','FontSize',14)
axis([0 5 0 5])
axis square
set(gca,'xtick',[0:1:5])
set(gca,'ytick',[0:1:5])
set(gca,'FontSize',14)

figure(12)
plot(DOY_MFRSR_joe(i),y-x,'.')
axis([257 277 -0.8 0.8])
ylabel('MFRSR(B) - AATS-6  (cm)')
xlabel('Day of Year 1997')
text(265, 0.3,sprintf('mean y/x = %5.3f ',mean(y./x)))
text(265, 0.2,sprintf('stdev y/x = %5.3f ',std(y./x)))
text(265.1, 0.1,sprintf('mean AATS-6 = %5.3f ',mean(x)))
text(265.1,-0.1,sprintf('mean MFRSR = %5.3f ',mean(y)))
text(265.1,-0.3,sprintf('stdev= %5.3f ',std(y-x)))
rmsd=(sum((y-x).^2)/(n-1))^0.5;
text(265.1,-0.5,sprintf('rms= %5.3f ',rmsd))
grid on


