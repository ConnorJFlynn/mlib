pathname='d:\Beat\Data\ACE2\';
filelist=str2mat('R18Jun97.aa1');
filelist=str2mat(filelist,...
'R21Jun97.ab1',...
'R22Jun97.ac1',...
'R22Jun97.ad1',...
'R23Jun97.ab1',...
'R27Jun97.zd1',...
'R30Jun97.ac1',...
'R01Jul97.ac1',...
'R04Jul97.aa1',...
'R05Jul97.aa2',...   
'R06Jul97.aa2',...
'R07Jul97.aa1',...
'R08Jul97.aa2',...
'R09Jul97.aa1',...
'R10Jul97.aa2',...
'R11Jul97.aa1',...
'R14Jul97.aa1',...
'R15Jul97.aa1',...
'R17Jul97.ab1',...
'R18Jul97.aa3');

DOY_all=[];
Mean_volts_all=[];
Temp_HotDet_all=[];

for ifile=1:20
 close all  
 filename=filelist(ifile,:); 
 [day,month,year,UT,Mean_volts,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
  Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_Raw('d:\beat\data\ACE-2\',filename);
 DOY=julian(day,month,year,UT)-julian(31,12,1996,0);
 i=find(Elev_pos<-50);
 DOY=DOY(i);
 Temp_HotDet=Temperature(1,i);
 Mean_volts=Mean_volts(:,i);
 y_fit=[]; 
 
 for ichan=1:14
  x=Temp_HotDet;
  y=Mean_volts(ichan,:);
  [p,S] = polyfit (x,y,1);
  m(ichan)=p(1);
  b(ichan)=p(2);
  [y_fit,delta] = polyval(p,x,S);
  a=y-y_fit;
  
  %Thompson-tau
  stdev_mult=2.6;
  while max(abs(a))>stdev_mult*std(a) 
  i=find(abs(a)<max (abs(a)));
  x=x(i);
  y=y(i);
  [p,S] = polyfit (x,y,1);
  m(ichan)=p(1);
  b(ichan)=p(2);
  [y_fit,delta] = polyval(p,x,S);
  a=y-y_fit;
  end
  
  figure(1)
  plot(x,y,'.',x,y_fit)
  hold on
  axis([-inf inf -inf inf])
  grid on
  pause(0.001)
 end
 DOY_all=[DOY_all DOY];
 Mean_volts_all=[Mean_volts_all Mean_volts];
 Temp_HotDet_all=[Temp_HotDet_all Temp_HotDet];
  pause

 close all
 fid=fopen('d:\beat\data\ace-2\results\T_coeff.txt','a');
   fprintf(fid,'%4i %3i %5i %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f \n',...
   [day,month,year,1e3*m,1e3*b]');
 fclose(fid);
 
end

figure(1)
plot(Temp_HotDet_all,Mean_volts_all(1:2,:),'.')

figure(2)
plot(DOY_all,figure(1)
plot(Temp_HotDet_all,Mean_volts_all(1:2,:),'.')

figure(2)
plot(DOY_all,Mean_volts_all(1:14,:),'.')
figure(3)
plot(Mean_volts_all(1,:),'.')
hold on
plot(Mean_volts_all(2,:),'g.')
grid on