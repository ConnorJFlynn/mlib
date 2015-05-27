%plot2004180.m
%PNNL Annex Skyrad stand Lat,Lon=46.341,-119.279
xbl=('time (h GMT)')
for d=[180]
for j=1:240
    t(j)=j/10;
   %[ra,dec,lmst,ha,az,el,refrac,w,w2]=sunae(year,jday,hour,lat,long);
   %[ra,dec,lmst,ha,az,el,refrac,al,aha,alk]=sunae2(year,jday,hour,lat,long);
  [rann(j),dnn(j),lmst,hann(j),aznn(j),elnn(j),rf,al(j),ahnn(j),azk(j),ahk(j)]=sunaerband2(2004,d,t(j),46.341,-0);
end
r=al>0;
figure(6);plot(t(r),(ahnn(r)-hann(r))*180/pi);xlabel(xbl);ylabel('w-ha');hold on
%figure(7);plot(aznn(r),hann(r),'b');xlabel('az');ylabel('ha(blue),hk(red)');
%hold on;plot(aznn(r),ahnn(r),'r');
figure(7);plot(t(r),hann(r)*180/pi,'b');xlabel(xbl);ylabel('ha(blue),hk(red)');
hold on;plot(t(r),ahnn(r)*180/pi,'r');
figure(8);plot(t(r),(ahnn(r)-hann(r))*180/pi);xlabel(xbl);ylabel('aha-ha');hold on
figure(9);plot(aznn(r),hann(r),'b');xlabel('az');ylabel('ha(blue),aha(red)');
hold on;plot(aznn(r),ahnn(r),'r');
figure(10);plot(t(r),al(r)-elnn(r),'b');xlabel('az');ylabel('al-el');
figure(11);plot(aznn(r),aznn(r)-azk(r),'b');xlabel('az');ylabel('az-azk');
end
axis tight
%figure(1);plot(rann);xlabel(xbl);ylabel('rann');axis tight
%figure(2);plot(dnn);xlabel(xbl); ylabel('dnn');axis tight
figure(3);plot(t,hann);xlabel(xbl);ylabel('hann');axis tight
figure(4);plot(t,aznn);xlabel(xbl);ylabel('aznn');axis tight
figure(5);plot(t(r),elnn(r));xlabel(xbl);ylabel('elnn');axis tight
%figure(6);plot(t,wnn-hann);xlabel(xbl);ylabel('w-ha');axis tight
%figure(7);plot(t,ah-hann);xlabel(xbl);ylabel('ah-ha');axis tight
%axis([0 24 -.000000000001 .000000000001]);