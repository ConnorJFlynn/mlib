% Reads MODTRAN3.5 v1.1 tape7 output file for transmittance mode
% created 19.3.1996 by Beat Schmid
% changed 7.2.1997 by Beat Schmid

clear

pathname='c:\beat\filter\';
%filename=str2mat('Ames6_940.asc')
filename=str2mat('Ames14#1_940.asc')

%filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_2.prn','368_3.prn','368_4.prn');
%filename=str2mat(filename,'412_2.prn','412_3.prn','412_4.prn','450_2.prn','450_3.prn','450_4.prn');
%filename=str2mat(filename,'500_1.prn','500_2.prn','500_3.prn','500_4.prn','610_1.prn','610_2.prn','610_3.prn','610_4.prn');
%filename=str2mat(filename,'675_1.prn','675_2.prn','675_3.prn','675_4.prn','719_2.prn','719_3.prn','719_4.prn');
%filename=str2mat(filename,'778_2.prn','778_3.prn','778_4.prn','817_2.prn','817_3.prn','817_4.prn');
%filename=str2mat(filename,'862_1.prn','862_2.prn','862_3.prn','862_4.prn','946_1.prn','946_2.prn','946_3.prn','946_4.prn');
%filename=str2mat(filename,'1024_1.prn','1024_2.prn','1024_3.prn','1024_4.prn')

%nominal_cwvl=[300 313 305 310 320 340 368 412 450 500 610 675 719 778 817 862 946 1024];

%fid=fopen('c:\beat\data\sun\sun0005.dat');
% line=fgetl(fid);
% line=fgetl(fid);
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun2=data(1,:);
% sun2      =data(2,:);
%fclose(fid);
%sun2=sun2.*lambda_sun2.^2/1e3;
%lambda_sun2=1e4./lambda_sun2;

fid2=fopen('c:\beat\modtran\trans.txt','a');
fid=fopen('c:\beat\modtran\tape7.mlw','r');

for iangle=1:14

 model=fscanf(fid,'%s',[1,1]);
 if (model=='t' | model=='T') model='MODTRAN35' ,end
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

%figure(1)
%plot(wvl,Aero,wvl,Rayleigh,wvl,H2O,wvl,Ozone,wvl,O2,wvl,NO2)
%xlabel('Wavelength (µm)');
%ylabel('Transmittance');
%legend(col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(17,:),col_head(20,:),1000);
%set(gca,'xlim',[0.270 1.05])

%figure(2)
%loglog(wvl,log(1./Aero),wvl,log(1./Rayleigh),wvl,log(1./H2O),wvl,log(1./Ozone),wvl,log(1./O2),wvl,log(1./NO2),wvl,log(1./SO2))
%xlabel('Wavelength[µm]');
%ylabel('ln(1/T), "Optical Depth"');
%legend(col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(17,:),col_head(20,:),col_head(21,:),1000);
%set(gca,'xlim',[0.280 1.05])


%x=wvl(wvl>0.320 & wvl<0.343);
%y=log(-log(Ozone(wvl>0.320 & wvl<0.343))/.33172);
%[p,S]=polyfit(x,y,1);
%[y_fit,delta] = POLYVAL(p,x,S);


%figure(3)
%subplot(2,1,1)
%plot(x,exp(y),x,exp(y_fit))
%subplot(2,1,2)
%plot(x,(exp(y)-exp(y_fit))./exp(y))
%grid on

 for ifilt=1:1
  [ifilt angle]
  fid3=fopen([pathname filename(ifilt,:)]);
  data=fscanf(fid3, '%f', [2,inf]);
  fclose(fid3);
  wvl_SPM=1e7./data(1,:);
  response=data(2,:)/max(data(2,:));

  %x0=nominal_cwvl(ifilt)
  %wvl_SPM=[x0-2:0.01:x0+2];
  %sigma=0.215;
  %response=gauss(wvl_SPM,x0,sigma);
  %response=response/max(response);
  %wvl_SPM=1e7./wvl_SPM;

  i=find(wvl<=max(wvl_SPM) & wvl >= min(wvl_SPM));
%% ii=find(lambda_sun2 <= max(wvl_SPM) & lambda_sun2 >= min(wvl_SPM));

  response2= interp1(wvl_SPM,response,wvl(i));

% y=trapz(wvl(i),sun2(ii).*response2');
% Ray_T = trapz(wvl(i),sun2(ii).*response2'.*Rayleigh(i))/y;
% H2O_T = trapz(wvl(i),sun2(ii).*response2'.*H2O(i))     /y;
% O3_T  = trapz(wvl(i),sun2(ii).*response2'.*Ozone(i))   /y;
% O2_T  = trapz(wvl(i),sun2(ii).*response2'.*O2(i))      /y;
% NO2_T = trapz(wvl(i),sun2(ii).*response2'.*NO2(i))     /y;
% SO2_T = trapz(wvl(i),sun2(ii).*response2'.*SO2(i))     /y;


% if iangle==1
%   cwvl(ifilt)=round(cwl(wvl_SPM,response,1));
%  end;

 y=trapz(wvl(i),response2');
 Ray_T = trapz(wvl(i),response2.*Rayleigh(i))/y;
 H2O_T = trapz(wvl(i),response2.*H2O(i))     /y;
 O3_T  = trapz(wvl(i),response2.*Ozone(i))   /y;
 O2_T  = trapz(wvl(i),response2.*O2(i))      /y;
 NO2_T = trapz(wvl(i),response2.*NO2(i))     /y;
 SO2_T = trapz(wvl(i),response2.*SO2(i))     /y;

%Ray_T = Rayleigh(wvl==cwvl(ifilt));
%H2O_T = H2O(wvl==cwvl(ifilt));
%O3_T  = Ozone(wvl==cwvl(ifilt));
%O2_T  = O2(wvl==cwvl(ifilt));
%NO2_T = NO2(wvl==cwvl(ifilt));
%SO2_T = SO2(wvl==cwvl(ifilt));


 % write to file
  fprintf(fid2,'%s',filename(ifilt,:));
  fprintf(fid2,'%7.3f', angle);
  fprintf(fid2,'%13.5e',Ray_T,H2O_T,O3_T,O2_T,NO2_T,SO2_T);
  fprintf(fid2,'\n');
 
 end

end

fclose(fid2);
fclose(fid);
fix(clock)
