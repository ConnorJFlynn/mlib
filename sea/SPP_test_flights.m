close('all')
%%

tag = 500;

ii = find(sea_080804a.data_acq.tag==tag); 
brd_500 = sea_080804a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
time_1 = floor(sea_080804a.(tag).time(1));
figure; 
flight_time = (sea_080804a.(tag).time-time_1)*24;
ax1(1) = subplot(3,1,1); 
plot(flight_time, sea_080804a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ',brd_500, ' = ',num2str(tag), datestr(sea_080804a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(2) = subplot(3,1,2); 
plot(flight_time, sum(sea_080804a.(tag).bins(2:end,:)),'.r-')
title('sum counts')
% plot(flight_time, (sea_080804a.(tag).electronicsTemp),'.r-')
% title('Electronics')
ax1(3) = subplot(3,1,3); 
plot(flight_time, sea_080804a.(tag).laserRefV,'.g-');
title('Laser Rev V')
% linkaxes(ax1,'x');
%%
figure; 
plot(cumsum(sea_080804a.(tag).bins(2:end,:),2),'-')
%
%%

tag = 700;
ii = find(sea_080804a.data_acq.tag==tag); 
brd_700 = sea_080804a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
figure; 
flight_time = (sea_080804a.(tag).time-time_1)*24;

ax1(4) = subplot(3,1,1); 
plot(flight_time, sea_080804a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ',brd_700, ' = ',num2str(tag), datestr(sea_080804a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(5) = subplot(3,1,2); 
plot(flight_time, sum(sea_080804a.(tag).bins(2:end,:)),'.r-')
title('sum counts')
ax1(6) = subplot(3,1,3); 
plot(flight_time, sea_080804a.(tag).laserRefV,'.g-');
title('Laser Rev V')
linkaxes(ax1,'x');
%%
figure; 
plot(cumsum(sea_080804a.(tag).bins(2:end,:),2),'-')
%
%%

tag = 500;
ii = find(sea_080805a.data_acq.tag==tag); 
brd_500 = sea_080805a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
flight_time = 24*60*(sea_080805a.(tag).time-sea_080805a.(tag).time(1));

figure; 
ax1(1) = subplot(3,1,1); 
plot(flight_time, sea_080805a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ',brd_500, ' = ',num2str(tag), datestr(sea_080805a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(2) = subplot(3,1,2); 
plot(flight_time, sum(sea_080805a.(tag).bins(2:end,:)),'.r-')
title('sum counts')
ax1(3) = subplot(3,1,3); 
plot(flight_time, sea_080805a.(tag).laserRefV,'.g-');
title('Laser Rev V')
linkaxes(ax1,'x');

tag = 700;
ii = find(sea_080805a.data_acq.tag==tag); 
brd_700 = sea_080805a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
flight_time = 24*60*(sea_080805a.(tag).time-sea_080805a.(tag).time(1));
figure; 
ax1(1) = subplot(3,1,1); 
plot(flight_time, sea_080805a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ',brd_700, ' = ',num2str(tag), datestr(sea_080805a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(2) = subplot(3,1,2); 
plot(flight_time, sum(sea_080805a.(tag).bins(2:end,:)),'.r-')
title('sum counts')
ax1(3) = subplot(3,1,3); 
plot(flight_time, sea_080805a.(tag).laserRefV,'.g-');
title('Laser Rev V')
linkaxes(ax1,'x');
%%

tag = 500;
ii = find(sea_080806a.data_acq.tag==tag); 
brd_500 = sea_080806a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
figure; 
flight_time = 24*60*(sea_080806a.(tag).time-sea_080806a.(tag).time(1));

ax1(1) = subplot(3,1,1); 
plot(flight_time, sea_080806a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ' brd_500  ' = ' num2str(tag)  datestr(sea_080806a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(2) = subplot(3,1,2); 
plot(flight_time(2:end), diff(flight_time),'.r-')
title('delta time')
ax1(3) = subplot(3,1,3); 
plot(flight_time, sea_080806a.(tag).laserRefV,'.g-');
title('Laser Rev V')
linkaxes(ax1,'x');
%

tag = 700;
ii = find(sea_080806a.data_acq.tag==tag); 
brd_700 = sea_080806a.data_acq.brd{ii};
tag = ['tag_',num2str(tag)];
flight_time = 24*60*(sea_080806a.(tag).time-sea_080806a.(tag).time(1));

figure; 

ax1(1) = subplot(3,1,1); 
plot(flight_time, sea_080806a.(tag).sampleFlow,'.b-')
title(['Sample Flow for ',brd_700, ' = ',num2str(tag), datestr(sea_080806a.(tag).time(1),' yyyy-mm-dd')],'interpreter','none')
ax1(2) = subplot(3,1,2); 
plot(flight_time(2:end), diff(flight_time),'.r-')
title('delta time')
ax1(3) = subplot(3,1,3); 
plot(flight_time, sea_080806a.(tag).laserRefV,'.g-');
title('Laser Rev V')
linkaxes(ax1,'x');
