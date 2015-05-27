function [swp,tw,P]=lblrtm_coeff(method);

% lblrtm_coeff  reads Matlab files(+) generated with run_lblrtm(12)
%               and calculates water-vapor transmittance parameterization 
%               coefficients a,b,(and c)
%
%               (+) Matlab files contain slant gaseous absorber path (swp) and
%                   gaseous transmittance values (Tw)
%                   extracted from TAPE6 of a single LBLRTM simulation
%
%
%               Input determines parameterization method:
%               method   : 1 - polyfit (2 parameters): Tw=exp(-a(swp)^b)
%                          2 - fmins   (2 parameters): Tw=exp(-a(swp)^b)
%                          3 - fmins   (3 parameters): Tw=c*exp(-a(swp)^b)
%                          4 - polyfit (2 parameters); Tg=exp(-a(swp)+b) %Beer's law, b should be 0.
%
%
%
%               Additional Information: Set the correct path information inside this function.
%
%
% Call: lblrtm_coeff(method)
%
%
% Thomas Ingold, IAP, 12/1999
% Adapted to work for H2O and O3 Beat Schmid 1/2001

instrument='AATS14';
model='LBLRTM 6.01'
Result_File='OFF'
path_save='c:\beat\LBLRTM\mTAPE6';

% standard path 
pf='c:\beat\LBLRTM\mTAPE6';

gas_add=[];
tran_add=[];
read=1;
while read==1
   [filename,filepath]=uigetfile([pf,filesep,'*.mat'],'Load Data');
   eval(['load ',filepath,filename])
   disp(filename)
   disp('--------------------')
   disp(info.channel)
   disp(info.atmos)
   disp(' ')
   disp(' ')
   
  % swp=gas/3.345e22;% h2o is in molec/cm^2, conversion to cm
   swp=gas/2.686763e19;% gas is in molec/cm^2, conversion to atm-cm
     
   
     s=findstr(filename,'_');
     p=findstr(filename,'ff');
 %    lambda=filename(s(1)+1:s(2)-3)
    lambda=filename(s(1)+1:p-1)
    filter=filename(p(1)+2:s(2)-1)
 %   pixel=filename(p(2)+1:s(2)-1)
 %    altitude=filename(s(3)+1:s(4)-1)
     altitude=filename(s(2)+1:s(3)-1)
  if strcmp(Result_File,'ON')
     savefile=['data_',instrument,'filter',filter,'_',altitude,'.dat']
     fid=fopen([path_save,filesep,savefile],'a');
     fprintf(fid,'%s %s %s %s %s %s %s\n','# Instrument: ',instrument,' Filter ',filter,'(',lambda,'nm)');
     fprintf(fid,'%s %s\n','# Model: ',model);
     fprintf(fid,'%s %s %s\n','# Altitude: ',altitude,'m asl.');
     fprintf(fid,'%s %s\n','# Atmosphere: ',info.atmos);
     fprintf(fid,'%s\n','# SWP,molec/cm^2 SWP,cm  Tw');
     fprintf(fid,'%12.3e %11.5f %8.6f\n',[gas',swp',tran']');
     fclose(fid)
   end
   
   gas_add=[gas_add,gas(1:end)];    % slant water vapor path (swp) in molec/cm^2
   tran_add=[tran_add,tran(1:end)]; % water vapor transmittance
   ld=menu('Load Additional File ?','Yes','No');
   if ld==1
      read=1;
   else
      read=0;
   end
end

[tw,index]=unique(tran_add);
gas_add=gas_add(index);
   
%swp=gas_add/3.345e22; % h2o is in molec/cm^2, conversion to cm
swp=gas_add/2.686763e19;% gas is in molec/cm^2, conversion to atm-cm

X=log(swp);
Y=log(-log(tw));

switch method
case 1
   [P,S] =polyfit(X,Y,1);
   YY=polyval(P,X);
   a=exp(P(2));
   b=P(1);
   % graphical representation of parameterization
   figure(1)
   orient landscape
   plot(swp,tw,'o'),hold on
   tw_fit=exp(-a*(swp).^b);
   swp_fit=(-log(tw)./a).^(1./b);
   plot(swp,exp(-a*(swp).^b),'r-'),hold off
   xlabel('Slant path H_2O [cm]','FontSize',14)
   ylabel('H_2O Transmittance','FontSize',14)
   legend(model,sprintf('Y=exp(- %5.3f *X^{%5.3f})',a,b))
    
   % data output
   m1=min(tw);
   m2=max(tw);
   swp1=min(swp);
   swp2=max(swp);

   text(min(swp)+1, m2+0.03,sprintf('Instrument= %s; Filter= %s; Altitude= %s m',instrument,filter,altitude),'FontSize',14);
   set(gca,'FontSize',14)
   text(min(swp)+1, m2,sprintf('T_w= %5.4f to %5.4f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f',m2,m1,min(swp),max(swp),a,b));

   disp(sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f',m2,m1,min(swp),max(swp),a,b));
   
   % graphical representation of parameterization error
   pro=(swp_fit./swp-1)*100;
   figure(2)
   subplot(2,1,1)
   plot(tw,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('T_w')
   grid on
   subplot(2,1,2)
   plot(swp,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('SWP [cm]')
   grid on
case 2
   eval(['save ',tempdir,filesep,'data.mat swp tw'])
   x0=[.5,.5];
   [x,options]=fminsearch('fit2',x0);
   %options
   eval(['delete ',tempdir,filesep,'data.mat'])	
   a=x(1);
   b=x(2);
   % graphical representation of parameterization
   figure
   plot(swp,tw,'o-'),hold on
   tw_fit=exp(-a*(swp).^b);
   swp_fit=(-log(tw)./a).^(1./b);
   xlabel('SWP [cm]')
   ylabel('T_w')
   plot(swp,exp(-a*(swp).^b),'r--'),hold off
   % data output
   m1=min(tw);
   m2=max(tw);
   disp(sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f',m2,m1,min(swp),max(swp),a,b));
   text(min(swp)+1, m2,sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f',m2,m1,min(swp),max(swp),a,b));
   
   % graphical representation of parameterization error
   pro=(swp_fit./swp-1)*100;
   figure(2)
   subplot(2,1,1)
   plot(tw,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('T_w')
   grid on
   subplot(2,1,2)
   plot(swp,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('SWP [cm]')
   grid on
case 3
   eval(['save ',tempdir,filesep,'data.mat swp tw'])
   x0=[1,.5,.5];
   [x,options]=fminsearch('fit3',x0);
   %options
   eval(['delete ',tempdir,filesep,'data.mat']) 
   c=x(1);
   a=x(2);
   b=x(3);
   % graphical representation of parameterization
   figure
   plot(swp,tw,'o-'),hold on
   xlabel('SWP [cm]')
   ylabel('T_w')
   tw_fit=c.*exp(-a*(swp).^b);
   swp_fit=(-log(tw./c)./a).^(1./b);
   plot(swp,c.*exp(-a*(swp).^b),'r--'),hold off
   % data output
   m1=min(tw);
   m2=max(tw);
   swp1=min(swp);
   swp2=max(swp);
   disp(sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f c=%6.4f',m2,m1,min(swp),max(swp),a,b,c));
   text(min(swp)+1, m2,sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f cm: a=%6.4f b=%6.4f c=%6.4f',m2,m1,min(swp),max(swp),a,b,c));
   % graphical representation of parameterization error
   pro=(swp_fit./swp-1)*100;
   figure(2)
   subplot(2,1,1)
   plot(tw,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('T_w')
   grid on
   subplot(2,1,2)
   plot(swp,pro,'-ro')
   ylabel('\Delta SWP [%]')
   xlabel('SWP [cm]')
   grid on
   
case 4   
   X=swp;
   Y=-log(tw);
   [P,S] =polyfit(X,Y,1);
   YY=polyval(P,X);
   % graphical representation of parameterization
   figure(1)
   orient landscape
   plot(X,tw,'o'),hold on
   tw_fit=exp(-YY);
   plot(swp,tw_fit,'r-'),hold off
   xlabel('Slant path [atm-cm]','FontSize',14)
   ylabel('Transmittance','FontSize',14)
   % data output
   m1=min(tw);
   m2=max(tw);
   swp1=min(swp);
   swp2=max(swp);
   text(min(swp)+1, 0.03,sprintf('Instrument= %s; Filter= %s; Altitude= %s m',instrument,filter,altitude),'FontSize',14);
   set(gca,'FontSize',14)
   %text(min(swp)+1, m2,sprintf('T_w= %5.4f to %5.4f; SWP= %6.2f to %6.2f atm-cm a2=%6.4e a1=%6.4e a0=%6.4e',m2,m1,min(swp),max(swp),P));
   disp(sprintf('Tw= %5.3f to %5.3f; SWP= %6.2f to %6.2f atm-cm: a2=%6.4e a1=%6.4e a0=%6.4e',m2,m1,min(swp),max(swp),P));
end

tw=tw';
swp=swp';
