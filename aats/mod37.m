function []=mod37(wvl_SPM,response,file)
% Reads MODTRAN3.7 v1.0 tape7 output file for transmittance mode
% created 19.3.1996 by Beat Schmid
% changed 7.2.1997 by Beat Schmid
% changed 2.10.1998 to MODTRAN 3.7 v1.0

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

fid=fopen('d:\beat\mod3_7\results\tape7_4km.uss','r');

for iangle=1:14

 model=fscanf(fid,'%s',[1,1]);
 if (model=='M' | model=='T') model='MODTRAN 3.7' ,end
 if (model=='L' | model=='F') model='LOWTRAN7' ,end
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
 wvl=1e7./data(1,:);
 Rayleigh=data(9,:);
 Aero=data(10,:);
 H2O=data(3,:).*data(8,:);
 Ozone=data(5,:);
 O2=data(18,:);
 NO2=data(21,:);
 SO2=data(22,:);

 clear data
 
 file
 angle

%figure(1)
%plot(wvl,Aero,wvl,Rayleigh,wvl,H2O,wvl,Ozone,wvl,O2,wvl,NO2)
%xlabel('Wavelength (nm)');
%ylabel('Transmittance');
%legend(col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(17,:),col_head(20,:),1000);
%set(gca,'xlim',[360 1570])
%figure(2)
%loglog(wvl,log(1./Aero),wvl,log(1./Rayleigh),wvl,log(1./H2O),wvl,log(1./Ozone),wvl,log(1./O2),wvl,log(1./NO2),wvl,log(1./SO2))
%xlabel('Wavelength[nm]');
%ylabel('ln(1/T), "Optical Depth"');
%legend(col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(17,:),col_head(20,:),col_head(21,:),1000);
%set(gca,'xlim',[360 1570])


% This was used to fit an equation through UV O3 cross-sections.

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

%write MODTRAN 3.7 x-sections
fid2=fopen('d:\beat\mod3_7\results\trans.txt','a');
fprintf(fid2,'%s',file);
fprintf(fid2,'%7.3f', angle);
fprintf(fid2,'%13.5e',Ray_T,H2O_T,O3_T,O2_T,NO2_T,SO2_T);
fprintf(fid2,'\n');
fclose(fid2);
 
end



fclose(fid);
fix(clock)
