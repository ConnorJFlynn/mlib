%plots Cadenza vs Neph+PSAP comparison
uiimport

%plot 

date=comparison(:,1);
UT=comparison(:,2);

x=comparison(:,3);
y=comparison(:,4);

range=[-0.01:.01:.25];


ii=find(x<0.3);
x=x(ii);
y=y(ii);

figure(1)
plot(x,y,'.');
hold on

%use new Matlab scripts by Edward T. Peltzer

%standard model 1
[my,by,ry,smy,sby]=lsqfity(x,y); 
disp([my,by,ry,smy,sby])
[y_fit] = polyval([my,by],range);
plot(range,y_fit,'b-')

% inverted or reversed model 1
[mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
disp([mxi,bxi,rxi,smxi,sbxi])
[y_fit] = polyval([mxi,bxi],range);
plot(range,y_fit,'g-')

%model 2 major axis or first PC
[m,b,r,sm,sb]=lsqfitma(x,y);
disp([m,b,r,sm,sb])

% geometric mean, reduce major axis or standard major axis
[m,b,r,sm,sb] = lsqfitgm(x,y);
disp([m,b,r,sm,sb])

% least squares bisector
[m,b,r,sm,sb]=lsqbisec(x,y);
disp([m,b,r,sm,sb])
[y_fit] = polyval([m,b],range);
plot(range,y_fit,'r-')

axis([min(range) max(range) min(range) max(range)])
axis square
hold off
grid on
set(gca,'FontSize',14)
xlabel('Extinction @ 675nm [1/km]: Neph+PSAP')
ylabel('Extinction @ 675nm [1/km]: Cadenza II')

n=length(x);
rmsd=(sum((x-y).^2)/(n-1))^0.5;
r=corrcoef(x,y);
r=r(1,2);
text(0.002,0.24 ,sprintf('n= %i ',n),'FontSize',14)
text(0.002,0.23,sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
text(0.002,0.22,sprintf('y = %5.3f(%5.3f) x + %5.3f(%5.3f) (least squares bisector)',m,sm,b,sb),'FontSize',14)
text(0.002,0.21 ,sprintf('rms= %5.3f km^{-1}',rmsd),'FontSize',14)
title('ARM Aerosol IOP May 2003, all flights')


figure(2)
plot(date,UT)