% Reads MODTRAN3.5 v1.1 tape7 output file for transmittance mode
% created 19.3.1996 by Beat Schmid
% changed 7.2.1997 by Beat Schmid

clear

pathname='c:\beat\data\filter\';
filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_2.prn','368_3.prn','368_4.prn');
filename=str2mat(filename,'412_2.prn','412_3.prn','412_4.prn','450_2.prn','450_3.prn','450_4.prn');
filename=str2mat(filename,'500_1.prn','500_2.prn','500_3.prn','500_4.prn','610_1.prn','610_2.prn','610_3.prn','610_4.prn');
filename=str2mat(filename,'675_1.prn','675_2.prn','675_3.prn','675_4.prn','719_2.prn','719_3.prn','719_4.prn');
filename=str2mat(filename,'778_2.prn','778_3.prn','778_4.prn','817_2.prn','817_3.prn','817_4.prn');
filename=str2mat(filename,'862_1.prn','862_2.prn','862_3.prn','862_4.prn','946_1.prn','946_2.prn','946_3.prn','946_4.prn');
filename=str2mat(filename,'1024_1.prn','1024_2.prn','1024_3.prn','1024_4.prn')

%nominal_cwvl=[300 313 305 310 320 340 368 412 450 500 610 675 719 778 817 862 946 1024];


fid=fopen('c:\beat\data\sun\sun0005.dat');
 line=fgetl(fid);
 line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun2=data(1,:);
 sun2      =data(2,:);
fclose(fid);


fid2=fopen('c:\beat\modtran\tau_eq.txt','a');
fid=fopen('c:\beat\modtran\tp7_tran.ms','r');

for iangle=1:9

 model=fscanf(fid,'%s',[1,1]);
 if (model=='t' | model=='T') model='MODTRAN3' ,end
 if (model=='f' | model=='F') model='LOWTRAN7' ,end
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 dummy=fscanf(fid,'%2d',[1,1]);
 atmosphere=fgetl(fid);
 geom=fscanf(fid,'%f',[7 1]);
 angle=geom(3);
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 range=fscanf(fid,'%i',[4 1]);
 line=fgetl(fid);
 line=fgetl(fid);
 col_head=fscanf(fid,'%c',[6,22]);
 col_head=col_head(:,2:22)';
 line=fgetl(fid);
 line=fgetl(fid);
 nwvl=(range(2)-range(1))/range(3)+1;
 data=fscanf(fid,'%f',[22,nwvl]);
 line=fgetl(fid);
 line=fgetl(fid);
 

%====PLOT=================================================
 wvl=data(1,:);
 Rayleigh=data(9,:);
 Aero=data(10,:);
 H2O=data(3,:).*data(8,:);
 Ozone=data(5,:);
 O2=data(18,:);
 NO2=data(21,:);
 SO2=data(22,:);

 clear data


 SZA=angle;
 m_ray(iangle)=1./(cos(SZA*pi/180)+0.50572*(96.07995-SZA).^(-1.6364)); %Kasten and Young (1989)
 r=2.7; h=21;R=6371.229;
 m_O3(iangle)=(R+h)./((R+h)^2-(R+r)^2*(sin(SZA*pi/180)).^2).^0.5;      %Komhyr (1989)
 m_H2O(iangle)=1./(cos(SZA*pi/180)+0.0548*(92.65-SZA).^(-1.452));      %Kasten (1965)
 m_aero(iangle)=m_H2O(iangle);
 m_SO2(iangle)=m_ray(iangle);    % nicht sehr gut
 m_NO2(iangle)=m_O3(iangle);     % OK

 for ifilt=1:5
  'ifilt ', ifilt,'angle ', angle

  fid3=fopen([pathname filename(ifilt,:)]);
  data=fscanf(fid3, '%f', [2,inf]);
  fclose(fid3);
  wvl_SPM=1e7./data(1,:);
  response=data(2,:)/max(data(2,:));

 % x0=nominal_cwvl(ifilt)
 % wvl_SPM=[x0-2:0.01:x0+2];
 % sigma=0.43;

 % response=gauss(wvl_SPM,x0,sigma);
 % response=response/max(response);
 % wvl_SPM=1e7./wvl_SPM;

  i=find(wvl<=max(wvl_SPM) & wvl >= min(wvl_SPM));
  ii=find(lambda_sun2 <= max(wvl_SPM) & lambda_sun2 >= min(wvl_SPM));

  response2= INTERP1(wvl_SPM,response,wvl(i));


 tau_O3(iangle,ifilt)= -log( trapz(wvl(i),sun2(ii).*response2'.*Ozone(i).*Rayleigh(i).*Aero(i).*NO2(i).*SO2(i)) /...
                             trapz(wvl(i),sun2(ii).*response2'          .*Rayleigh(i).*Aero(i).*NO2(i).*SO2(i)))/m_O3(iangle)

 tau_ray(iangle,ifilt)= -log( trapz(wvl(i),sun2(ii).*response2'.*Rayleigh(i).*Aero(i).*NO2(i).*SO2(i)) /... 
                              trapz(wvl(i),sun2(ii).*response2'             .*Aero(i).*NO2(i).*SO2(i)) )/m_ray(iangle)

 tau_aero(iangle,ifilt)= -log( trapz(wvl(i),sun2(ii).*response2'.*Aero(i).*NO2(i).*SO2(i)) /... 
                               trapz(wvl(i),sun2(ii).*response2'         .*NO2(i).*SO2(i)) )/m_aero(iangle)

 tau_NO2(iangle,ifilt)= -log( trapz(wvl(i),sun2(ii).*response2'.*NO2(i).*SO2(i)) /... 
                              trapz(wvl(i),sun2(ii).*response2'        .*SO2(i)) )/m_NO2(iangle)

 tau_SO2(iangle,ifilt)= -log( trapz(wvl(i),sun2(ii).*response2'.*SO2(i)) /... 
                              trapz(wvl(i),sun2(ii).*response2'        ) )/m_SO2(iangle)


% write to file
  fprintf(fid2,'%s',filename(ifilt,:));
 
% fprintf(fid2,'%6i',nominal_cwvl(ifilt), angle);
  fprintf(fid2,'%13.5e',tau_O3(iangle,ifilt),tau_ray(iangle,ifilt),tau_aero(iangle,ifilt),tau_NO2(iangle,ifilt),tau_SO2(iangle,ifilt));
  fprintf(fid2,'\n');
 
 end

end

fclose(fid2);
fclose(fid);
fix(clock)


figure(1)

for ifilt=1:2
 x=log(m_O3([1:9]))';
 y=log(tau_O3([1:9],ifilt)/tau_O3(1,ifilt));
 [p,S]=polyfit(x,y,2)
 [y_fit,delta] = POLYVAL(p,x,S);
 a=exp(y)-exp(y_fit);
 subplot(2,1,1)
 plot(exp(x),exp(y),'g+',exp(x),exp(y_fit));
 subplot(2,1,2);
 plot(exp(x),a,'g+');
 pause
end

for ifilt=1:2
 x=m_ray([1:9])';
 y=tau_ray([1:9],ifilt)/tau_ray(1,ifilt);
 [p,S]=polyfit(x,y,1)
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 subplot(2,1,2);
 plot(x,a,'g+');
 pause
end

figure(1)

for ifilt=3:6
 x=m_O3([1:9])';
 y=tau_O3([1:9],ifilt)/tau_O3(1,ifilt);
 [p,S]=polyfit(x,y,1)
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 subplot(2,1,2);
 plot(x,a,'g+');
 pause
end



for ifilt=1:9
 figure(1)
 subplot(3,3,ifilt)
 plot(m_O3,tau_O3(:,ifilt)/tau_O3(1,ifilt));
% plot(m_O3,tau_O3(:,ifilt));
 title(filename(ifilt,:)) 
%xlabel('Airmass')
%ylabel('tau_O3/tau_O3(m=1)')
 grid on;
 set(gca,'xlim',[1 5])
end  

halt


 
for ifilt=1:9
 figure(2)
 subplot(3,3,ifilt)
 plot(m_ray,tau_ray(:,ifilt)/tau_ray(1,ifilt));
% plot(m_ray,tau_ray(:,ifilt));
 title(filename(ifilt,:))
%xlabel('Airmass') 
%ylabel('tau_ray/tau_ray(m=1)')
 grid on;
 set(gca,'xlim',[1 5])
end

for ifilt=1:9
 figure(3)
 subplot(3,3,ifilt)
 plot(m_aero,tau_aero(:,ifilt)/tau_aero(1,ifilt));
% plot(m_aero,tau_aero(:,ifilt));
 title(filename(ifilt,:))
%ylabel('tau_aero/tau_aero(m=1)')
%xlabel('Airmass') 
 grid on;
 set(gca,'xlim',[1 5])
end

for ifilt=1:9
 figure(4)
 subplot(3,3,ifilt)
 plot(m_NO2,tau_NO2(:,ifilt)/tau_NO2(1,ifilt));
% plot(m_NO2,tau_NO2(:,ifilt));
 title(filename(ifilt,:))
% ylabel('tau_NO2/tau_NO2(m=1)')
% xlabel('Airmass') 
 grid on;
 set(gca,'xlim',[1 5])
end

for ifilt=1:9
 figure(5)
 subplot(3,3,ifilt)
 plot(m_SO2,tau_SO2(:,ifilt)/tau_SO2(1,ifilt));
 %plot(m_SO2,tau_SO2(:,ifilt));
 title(filename(ifilt,:))
% ylabel('tau_SO2/tau_SO2(m=1)')
% xlabel('Airmass') 
 grid on;
 set(gca,'xlim',[1 5])
end
