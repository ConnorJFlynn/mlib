%performs Langley plots for atmospheric window and UV/ozone wavelenths (preliminary).
%play with 1) time interval in prepare.m
%          2) airmass range: min_m_aero, max_m_aero
%          3) standard deviation multiplier for Thompson-tau method: stdev_mult
%          4) Iteratively change the value of O3_col_start in prepare.m until aerosol optical depth spectrum 
%             looks smooth in the 610 nm region. O3 value does not have to be very accurate (try increments of 10 DU)
%             it's just for properly weighting the airmasses 

prepare;
tau_NO2=NO2_clima*a_NO2;
tau_O3=O3_col_start*a_O3;
[m,n]=size(m_ray);

min_m_aero=1;
max_m_aero=inf;
stdev_mult=4;

%Langley-Plot
channels=1:length(V0');
%Window wavelengths
for ichan=channels(wvl_aero==1);
 x=m_aero;
 y=data(ichan,:)'.*exp(m_ray'.*tau_ray(ichan,:)'+...
                       m_O3'.*ones(n,m)*tau_O3(ichan)+...
                       m_NO2'.*ones(n,m)*tau_NO2(ichan)+...
                       m_ray'.*tau_O4(ichan)); 

 y=log(y');

 %Airmass restriction 
 i=find(m_aero<=max_m_aero & m_aero>=min_m_aero);
 x=x(i);
 y=y(i);
 
 %Altitude restriction for airborne Langley
 %i=find(r>4);
 %x=x(i);
 %y=y(i); 
 
 %Fit
 [p,S] = polyfit (x,y,1)
 [y_fit,delta] = polyval(p,x,S);
 a=y-y_fit;

 figure
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm',site,day,month,year,lambda(ichan)));
 xlabel('m_a')
 ylabel('lnV*')
 subplot(2,1,2);
 xlabel('m_a')
 ylabel('Residuals')
 plot(x,a,'g+'); 
 pause

 %Thompson-tau
 while max(abs(a))>stdev_mult*std(a) 
  i=find(abs(a)<max (abs(a)));
  x=x(i);
  y=y(i);
  [p,S] = polyfit (x,y,1)
  [y_fit,delta] = polyval(p,x,S);
  a=y-y_fit;
end

 subplot(2,1,1)
 plot(x,y,'.',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm',site,day,month,year,lambda(ichan)));
 xlabel('m_a')
 ylabel('lnV*')
 subplot(2,1,2);
 plot(x,a,'.'); 
 xlabel('m_a')
 ylabel('Residuals')
 pause

 V0(ichan)=exp(p(2))/SunDist(day,month,year)
 tau(ichan)=-p(1)
 RSD(ichan)=std(a)
end

%plot aerosol optical depths resulting from slope of Langley plot
figure
loglog(lambda(wvl_aero==1),tau(wvl_aero==1),'g*')
axis([0.3 2.2 1e-3 1e-1])
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2,2.2]);
title(sprintf('%s %2i.%2i.%2i',site,day,month,year));
xlabel('Wavelength [µm]');
ylabel('Aerosol Optical Depth');
grid on;


%write results from Langley-plot to file
fid=fopen('c:\beat\matlab\langley.txt','a')
fprintf(fid,'%2i.%2i.%4i',day,month,year);
fprintf(fid,'%5.1f',min_m_aero,max_m_aero,stdev_mult)
fprintf(fid,'%9.4f',V0,tau,RSD);
fprintf(fid,'\r\n');
fclose(fid);