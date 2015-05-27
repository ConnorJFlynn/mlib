% Reads MODTRAN3.7 v1.0 tape7 output file for transmittance mode and plots
% created 19.3.1996 by Beat Schmid
% changed 7.2.1997 by Beat Schmid
% changed 2.10.1998 to MODTRAN 3.7 v1.0
% changed 4.6.1999 added CO2
% changed 3.9.2000 added Total
% works also for MODTRAN 4.1
% March 2003 works for MODTRAN 4.3

fid=fopen('c:\beat\mod4_3\TEST\aats14.tp7','r');
%fid=fopen('c:\beat\mod4_1\TEST\TAPE5.tp7','r');
%fid=fopen('c:\beat\mod3_7\results\TAPE7','r');
for iangle=1:1
 model=fscanf(fid,'%s',[1,1]);
 if (model=='M' | model=='T') model='MODTRAN' ,end
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
 col_head=fscanf(fid,'%2c',1);
 col_head=fscanf(fid,'%c',[7,22+13]);
 col_head=col_head(:,2:22+13)';
 line=fgetl(fid);
 line=fgetl(fid);
 nwvl=(range(2)-range(1))/range(3)+1;
 data=fscanf(fid,'%f',[22+13,nwvl]);
 line=fgetl(fid);
 line=fgetl(fid);
%====PLOT=================================================
wvl=1e7./data(1,:);
 Total=data(2,:);
 Rayleigh=data(9,:);
 Aero=data(10,:);
 H2O=data(3,:).*data(8,:);
 Ozone=data(5,:);

% CO2    CO   CH4   N2O    O2   NH3    NO   NO2   SO2
 CO2=data(14,:);
 CO=data(15,:);
 CH4=data(16,:);
 N2O=data(17,:);
 O2=data(18,:);
 NH3=data(19,:);
 N0=data(20,:);
 NO2=data(21,:);
 SO2=data(22,:);
 clear data
 
end
fclose(fid);

 wvl=wvl/1000;
 figure(1)
 subplot(2,1,2)
 plot(wvl,Total,wvl,Aero,wvl,Rayleigh,wvl,H2O,wvl,Ozone,wvl,CO2,wvl,CO,wvl,CH4,wvl,N2O,wvl,O2,wvl,NH3,wvl,N0,wvl,NO2,wvl,SO2)
 xlabel('Wavelength (\mum)');
 ylabel('Transmittance, T'); 
 set(gca,'FontSize',14)
 set(gca,'xlim',[0.30 2.2])
 set(gca,'ylim',[0 1])
 set(gca,'xtick',[0.3:0.1:2.2]);
 legend(col_head(1,:),col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(13,:),col_head(14,:),col_head(15,:),col_head(16,:),col_head(17,:),col_head(18,:),col_head(19,:),col_head(20,:),col_head(21,:));
 hold on
 
% fid=fopen('c:\beat\data\xsect\Ames14#1_safari_wvl.asc');
 fid=fopen('c:\beat\data\xsect\Ames14#1_solve2_wvl.asc');
% fid=fopen('c:\beat\data\xsect\VIIRS_wvl.asc');
 fgetl(fid);
 fgetl(fid);
 data=fscanf(fid,'%f',[2,inf]);
 fclose(fid);
 lambda_AATS14=data(1,:)/1000;
 bw_AATS14=data(2,:)/1000;
 for ichan=1:14
 %for ichan=1:11
    wvl_AATS14(3*ichan-2)=lambda_AATS14(ichan)-bw_AATS14(ichan)/200;
    wvl_AATS14(3*ichan-1)=lambda_AATS14(ichan);
    wvl_AATS14(3*ichan)=lambda_AATS14(ichan)+bw_AATS14(ichan)/200;
    response(3*ichan-2)=1e-10;
    response(3*ichan-1)=10;
    response(3*ichan)=1e-10;
 end   
 plot(wvl_AATS14,response,'k','LineWidth',1);
 %hold off
  title('AATS-14 Wavelengths and Atmospheric Transmittance')
 set(gca,'FontSize',14)
 
 
 Tau_Total=log(1./Total);
 Tau_Aero=log(1./Aero);
 Tau_Rayleigh=log(1./Rayleigh);
 Tau_H2O=log(1./H2O);
 Tau_Ozone =log(1./Ozone);
 Tau_CO=log(1./CO);
 Tau_CO2=log(1./CO2);
 Tau_CH4=log(1./CH4);
 Tau_N2O=log(1./N2O);
 Tau_O2=log(1./O2);
 Tau_NH3=log(1./NH3);
 Tau_N0=log(1./N0);
 Tau_NO2=log(1./NO2);
 Tau_SO2=log(1./SO2);
 
 
 %Tau_CO2(Tau_CO2==0)=1e-10; %set to non zero value so lines show up on plot
 %Tau_O2(Tau_O2==0)=1e-10;

 
 
 figure(2)
 subplot(2,1,2)
 loglog(wvl,Tau_Total,wvl,Tau_Aero,wvl,Tau_Rayleigh,wvl,Tau_H2O,wvl,Tau_Ozone,wvl,Tau_CO2,wvl,Tau_CO,wvl,Tau_CH4,wvl,Tau_N2O,wvl,Tau_O2,wvl,Tau_NH3,wvl,Tau_N0,wvl,Tau_NO2,wvl,Tau_SO2)
 xlabel('Wavelength (\mum)','FontSize',14);
 ylabel('ln(1/T), "Optical Depth"','FontSize',14);
 legend(col_head(1,:),col_head(9,:),col_head(8,:),col_head(2,:),col_head(4,:),col_head(13,:),col_head(14,:),col_head(15,:),col_head(16,:),col_head(17,:),col_head(18,:),col_head(19,:),col_head(20,:),col_head(21,:));
 set(gca,'ylim',[1e-4 2])
 set(gca,'xlim',[0.30 2.3])
 set(gca,'xtick',[0.30:0.1:2.3]);
 hold on
 loglog(wvl_AATS14,response,'k','LineWidth',1);
% hold off
 set(gca,'FontSize',14)
 grid off
 



