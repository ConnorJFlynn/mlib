%plots AATS-14 MPL comparison
%uiimport

%plot AOD

x=comparison(:,2);
y=comparison(:,3);

range=[0:.05:.35];

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

axis([0 0.35 0 0.35])
axis square
hold off



% plot Extinction

x=comparison(:,4);
y=comparison(:,5);

range=[0:.05:.3];

figure(2)
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

axis([0 0.3 0 0.3])
axis square
hold off
