% This program reads SPM data files and plots raw data
% Written 14.7.1995 by B. Schmid
% 20. 7.1995 UT from function FLUKE_RD
%  9.10.1995 Format identifier from function FLUKE_RD
%  9.10.1995 solar azimuth and elevation from function FLUKE_RD
% 12. 3.1996 prints site and legends on plots

clear
[day,month,year,LT,UT,data,format,azi,ele]=FLUKE_RD('g:\spm\9*.001');

if (format=='100' | format=='101' ) 
 site='Bern ';
 figure(1)
 
 subplot(2,2,1)
 plot(LT,data(1:6,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[5 22])
 legend('368','412','450','500','610','675')
 subplot(2,2,2)
 
 plot(LT,data(7:12,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[5 22])
 legend('719','778','817','862','946','1024')
 
 subplot(2,2,3)
 plot(LT,data(13:16,:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('Detector T [°C]')
 set(gca,'ylim',[39 45])
 set(gca,'xlim',[5 22])
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 legend('SPM15','SPM20','SPM28','SPM29')
end

if format=='006'
site='Bern ';
figure(1)
subplot(2,2,1)
plot(LT,data(1:3,:))
xlabel('Local Time');
ylabel('Signal [V]')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
set(gca,'ylim',[0 3])
set(gca,'xlim',[5 22])
legend('310','320','340')

subplot(2,2,2)
plot(LT,data(4:9,:))
xlabel('Local Time');
ylabel('Signal [V]')
%title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
set(gca,'ylim',[0 7])
set(gca,'xlim',[5 22])
legend('368','412','450','500','610','675')

subplot(2,2,3)
plot(LT,data(10:15,:))
xlabel('Local Time');
ylabel('Signal [V]')
%title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
set(gca,'ylim',[0 7])
set(gca,'xlim',[5 22])
legend('719','778','817','862','946','1024')

subplot(2,2,4)
plot(LT,data(16:20,:)/0.013-273.15)
xlabel('Local Time');
ylabel('Detector T [°C]')
set(gca,'ylim',[39 45])
set(gca,'xlim',[5 22])
%title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
legend('SPM15','SPM20','SPM28','SPM29','SPM32')

end

if (format=='007' | format=='008')
 site='Bern or Zugspitze';
 
 figure(1)
 subplot(2,3,1) 
 plot(LT,data(1:6,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 %set(gca,'ylim',[-0.005 0.005])
 %set(gca,'xlim',[22 24])
 legend('300', '305','313', '310' ,'320', '340')
 
 subplot(2,3,2)
 plot(LT,data(7:12,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
% title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 %set(gca,'ylim',[-0.001 0.001])
 %set(gca,'xlim',[22 24])
 legend('368','412','450','500','610','675')

 subplot(2,3,3)
 plot(LT,data(13:18,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 %set(gca,'ylim',[-0.0005 0.0005])
 %set(gca,'xlim',[22 24])
 legend('719','778','817','862','946','1024')
 
 subplot(2,3,4)
 plot(LT,data(19:24,:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('T [°C]')
 %set(gca,'ylim',[39 45])
 %set(gca,'xlim',[22 24])
% title(sprintf('%s %2i.%2i.%2i',site, day,month,year))
 legend('SPM30','SPM32','SPM28','SPM29','SPM15','SPM20')

 subplot(2,3,5)
 plot(LT,data(25:30,:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('T [°C]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 %set(gca,'xlim',[22 24])
 %set(gca,'ylim',[10 20])
 legend('SPM30','SPM32','SPM28','SPM29','SPM15','SPM20')
end


if (format=='001' | format=='002') 
site='Jungfraujoch ';
figure(1)
plot(LT,data(1:6,:))
xlabel('Local Time');
ylabel('Signal [V]')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
set(gca,'ylim',[0 7])
set(gca,'xlim',[5 20])
legend('368','412','450','500','610','675')

figure(2)
plot(LT,data(7:12,:))
xlabel('Local Time');
ylabel('Signal [V]')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
set(gca,'ylim',[0 7])
set(gca,'xlim',[5 20])
legend('719','778','817','862','946','1024')

figure(3)
plot(LT,data(13:16,:)/0.013-273.15)
xlabel('Local Time');
ylabel('Detector T [°C]')
title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
legend('SPM15','SPM20','SPM28','SPM29')

figure(4)
plot(LT,data([17 19 20],:)/0.013-273.15)
xlabel('Local Time');
ylabel('Electronics T [°C]')
title(sprintf('%s %2i.%2i.%2i',site, day,month,year))
end

if (format=='003'| format=='004' | format=='005' )
 site='Arizona'
 figure(1)
 subplot(2,3,1)
 plot(LT,data(2:3,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[6 18])
 legend('300','313')
 
 subplot(2,3,2)
 plot(LT,data(4:9,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[6 18])
 legend('368','412','450','500','610','675')

 subplot(2,3,3)
 plot(LT,data(10:15,:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[6 18])
 legend('719','778','817','862','946','1024')
 
 subplot(2,3,4)
 plot(LT,data(16:20,:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('T [°C]')
 title(sprintf('%2i.%2i.%2i',day,month,year))
 set(gca,'xlim',[6 18])
end

if (format=='004'| format=='005')
 subplot(2,3,5)
 plot(LT,data(21,:)*100+600)
 xlabel('Local Time');
 ylabel('Pressure')
 title(sprintf('%2i.%2i.%2i',day,month,year))
 set(gca,'xlim',[6 18])
 %set(gca,'ylim',[700 800])
end 

if (format=='009')
 site='Jungfraujoch';
 orient landscape
 figure(1)
 subplot(2,3,1) 
 plot(LT,data([1:3,6:8],:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 %axis([-inf inf -inf inf])
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[6 20])
 legend('300', '305','313', '310' ,'320', '340')
 grid on
 
 subplot(2,3,2)
 plot(LT,data([11:13, 16:18],:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 
 set(gca,'ylim',[0 7])
 set(gca,'xlim',[6 20])
 %axis([-inf inf -inf inf])
 legend('412','719','817','368','450','778')
 grid on

 subplot(2,3,3)
 plot(LT,data([21:23, 26:28],:))
 xlabel('Local Time');
 ylabel('Signal [V]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
  set(gca,'ylim',[0 7.2])
 set(gca,'xlim',[6 20])
 %axis([-inf inf -inf inf])
 legend('500','862','946','610','675','1024')
  grid on 

 subplot(2,3,4)
 plot(LT,data([4,9,14,19,24,29],:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('T [°C]')
 set(gca,'ylim',[39 45])
 set(gca,'xlim',[6 20])
 %axis([-inf inf -inf inf])
% title(sprintf('%s %2i.%2i.%2i',site, day,month,year))
 legend('SPM30','SPM32','SPM29','SPM28','SPM15','SPM20')
 grid on

 subplot(2,3,5)
 plot(LT,data([5,10,15,20,25,30],:)/0.013-273.15)
 xlabel('Local Time');
 ylabel('T [°C]')
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year))
 set(gca,'xlim',[6 20])
 set(gca,'ylim',[-20 20])
 %axis([-inf inf -inf inf]) 
 legend('SPM30','SPM32','SPM29','SPM28','SPM15','SPM20')
 grid on
end


