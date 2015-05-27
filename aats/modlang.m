%performs modified Langley plots for water vapor channels.
%play with 1) time interval in prepare.m
%          2) airmass range: min_m_H2O, max_m_H2O
%          3) standard deviation multiplier for Thompson-tau method: stdev_mult
plot_re4


% START MODIFIED LANGLEY PLOT
min_m_H2O=1;
max_m_H2O=20;
stdev_mult=3.5;
n=size(data');

%Water Vapor
channels=1:size(wvl_water');

for ichan=channels(wvl_water==1);
 x=m_H2O.^b_H2O(channels(ichan));                  
 y=data.*exp(tau_aero.*(ones(n(2),1)*m_aero)+tau_ray.*(ones(n(2),1)*m_ray)+tau_NO2.*(ones(n(2),1)*m_NO2)+tau_ozone.*(ones(n(2),1)*m_O3));        
 y=log(y(ichan,:));

 %Airmass restriction 
 i=find(m_H2O<=max_m_H2O & m_H2O>=min_m_H2O);
 x=x(i);
 y=y(i);

 [p,S] = POLYFIT (x,y,1)
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;

 figure
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm',site,day,month,year,lambda(ichan)));
 subplot(2,1,2);
 plot(x,a,'g+'); 
 pause

 while max(abs(a))>stdev_mult*std(a) 
  i=find(abs(a)<max(abs(a)));
  x=x(i);
  y=y(i);
  [p,S] = polyfit (x,y,1)
  [y_fit,delta] = polyval(p,x,S);
  a=y-y_fit;
end

figure
 subplot(2,1,1)
 plot(x,y,'.',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm',site,day,month,year,lambda(ichan)));
 subplot(2,1,2);
 plot(x,a,'.'); 

 V0(ichan)=exp(p(2))/SunDist(day,month,year)
 U_modlang(ichan)=(-p(1)/a_H2O(channels(ichan)))^(1/b_H2O(channels(ichan)))/1244
 RSD(ichan)=std(a)
 pause
end

%write results from Langley-plot to file
fid=fopen('c:\beat\matlab\mlang.txt','a');
fprintf(fid,'%2i.%2i.%4i', day,month,year);
fprintf(fid,'%5.1f',min_m_H2O,max_m_H2O,stdev_mult);
fprintf(fid,'%9.4f',V0(wvl_water==1),U_modlang(wvl_water==1),RSD(wvl_water==1));
fprintf(fid,'\r\n');
fclose(fid);