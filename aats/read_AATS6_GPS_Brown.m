pathname='C:\Beat\Data\Oklahoma\WVIOP3\GPS\';
fid=fopen([pathname 'aats6_gps_pw.asc']);
fgetl(fid);

data=fscanf(fid,'%f %f %f %f',[4,inf]);
fclose(fid);
MJD_gps=data(1,:);
SP_PW=data(2,:)/10;
LMNO_PW=data(3,:)/10;
OKC2_PW=data(4,:)/10;
n=1;
ave_SP_PW=[];
sum_SP_PW=SP_PW(1);
ave_LMNO_PW=[];
sum_LMNO_PW=LMNO_PW(1);
ave_OKC2_PW=[];
sum_OKC2_PW=OKC2_PW(1);
for i=2:size(data,2);
  if LMNO_PW(i) == LMNO_PW(i-1);
    sum_SP_PW=sum_SP_PW+SP_PW(i);
    sum_LMNO_PW=sum_LMNO_PW+LMNO_PW(i);
    sum_OKC2_PW=sum_OKC2_PW+OKC2_PW(i);
    n=n+1;
  else;
   ave_SP_PW=[ave_SP_PW sum_SP_PW/n];
   ave_LMNO_PW=[ave_LMNO_PW sum_LMNO_PW/n];
   ave_OKC2_PW=[ave_OKC2_PW sum_OKC2_PW/n];
   n=1;
   sum_SP_PW=SP_PW(i);
   sum_LMNO_PW=LMNO_PW(i);
   sum_OKC2_PW=OKC2_PW(i);
 end
end
figure(1)
plot(MJD_gps,SP_PW,'.',MJD_gps,LMNO_PW,'.',MJD_gps,OKC2_PW,'.')
figure(2)
plot(LMNO_PW,OKC2_PW,'o')
axis square
axis ([0 5 0 5])
figure(3)
range=[0:0.5:5];
x=ave_LMNO_PW;
y=ave_OKC2_PW;
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
rmsd=(sum((y-x).^2)/(n-1))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'o',range,y_fit_range,'--',range,range)
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12)
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12)
text(3.1,0.4,sprintf('rms diff = %5.3f cm',rmsd),'FontSize',12)
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12)
set (gca, 'FontSize',14)
xlabel('PW (cm) GPS LMNO','FontSize',14)
ylabel('PW (cm) GPS OKC2','FontSize',14)
axis square
axis ([0 5 0 5])
figure(4)
range=[0:0.5:5];
x=ave_SP_PW;
y=ave_OKC2_PW;
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
rmsd=(sum((y-x).^2)/(n-1))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'bo',range,y_fit_range,'b--',range,range,'k')
text(0.3,4.8,'GPS CF','FontSize',14,'color','b')
text(0.3,4.6,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12,'color','b')
text(0.3,4.4,sprintf('r²= %5.3f',r.^2),'FontSize',12,'color','b')
text(0.3,4.2,sprintf('rms diff = %5.3f cm',rmsd),'FontSize',12,'color','b')
text(0.3,4.0,sprintf('n = %5i',n),'FontSize',12,'color','b')
set (gca, 'FontSize',14)
%xlabel('PW (cm) AATS-6','FontSize',14)
%ylabel('PW (cm) GPS OKC2','FontSize',14)
axis square
axis ([0 5 0 5])
hold on
range=[0:0.5:5];
x=ave_SP_PW;
y=ave_LMNO_PW;
[p,S] = polyfit (x,y,1);
[y_fit,delta] = polyval(p,x,S);
[y_fit_range,delta] = polyval(p,range,S);
[m,n]=size(x);
rmse=(sum((y-y_fit).^2)/(n-2))^0.5;
rmsd=(sum((y-x).^2)/(n-1))^0.5;
r=corrcoef(x,y);
r=r(1,2);
plot(x,y,'go',range,y_fit_range,'g--',range,range,'k')
text(3.1,1.0,'GPS Lamont','FontSize',14,'color','g')
text(3.1,0.8,sprintf('y = %5.3f x %+5.3f',p),'FontSize',12,'color','g')
text(3.1,0.6,sprintf('r²= %5.3f',r.^2),'FontSize',12,'color','g')
text(3.1,0.4,sprintf('rms diff = %5.3f cm',rmsd),'FontSize',12,'color','g')
text(3.1,0.2,sprintf('n = %5i',n),'FontSize',12,'color','g')
xlabel('CWV (cm) AATS-6','FontSize',14)
%ylabel('PW (cm) GPS LMNO','FontSize',14)
ylabel('CWV (cm) GPS','FontSize',14)
axis square
axis ([0 5 0 5])
set (gca,'xtick',[0:5])
set (gca,'ytick',[0:5])
set (gca, 'FontSize',14)
hold off
