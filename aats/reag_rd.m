clear

%Mt. Lemmon
geog_long=-110.7881
geog_lat=32.4421
lambda=[0.3689, 0.3991, 0.440, 0.5186, 0.6085, 0.669, 0.7797, 0.8698, 0.9383, 1.0272]

% read zero readings
[filename,path]=uigetfile('g:\beat\data\reagan\*.*', 'Choose a File', 0, 0);
fid=fopen([path filename]);

% reads time and signal
A=fscanf(fid,'%g %g %g',[3 inf]);
fclose(fid)

time_z=A(1,:);
signal_z=A(2,:);
Temp_Sens_z=A(3,:);


for iband=1:10

%reads in data file

[filename,path]=uigetfile('g:\beat\data\reagan\*.*', 'Choose a File', 0, 0);
fid=fopen([path filename]);

% reads date
date=fscanf(fid,'%2d - %2d - %4d')
day=date(2)
month=date(1)
year=date(3)

% reads site
 site=fscanf(fid,'%s /n')

% reads mode
 mode=fscanf(fid,'%s /n')

% reads band
band =fscanf(fid,'%d %*s %*s %*s /n')

% read header
header=fscanf(fid,'%s %s %s %s %s %s /n')

% reads time and signal
 A=fscanf(fid,'%g %g %g %g %g ',[5 inf]);
fclose(fid)

LT=A(1,:);
UT=LT+7;
signal=A(2,:);
Temp_Sens=A(3,:);
press=A(4,:);
temp =A(5,:);

% subtracts zeros

signal=signal- interp1(time_z,signal_z,LT)';



figure(1)
plot (LT,signal)
figure(2)
plot (LT,Temp_Sens,time_z,Temp_Sens_z)
figure(3)
plot (LT,press)
figure(4)
plot (LT,temp)

temp=temp+273.15*(ones(size(temp)));


[azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp,press);
SZA=90-altitude;
[minSZA,pos1]=min(SZA)
%i=find(SZA(1:pos1)>=84)
[max_i,pos2]=max(SZA)


%Thompson-tau


x=1./(cos(SZA(pos2:pos1)*pi/180)+0.50572*(96.08-SZA(pos2:pos1)).^(-1.6364)) %Kasten, 1989
%x=(1./(cos(SZA(pos2:pos1)*pi/180)));
 y=log(signal(pos2:pos1)) 


%Airmass restriction 
i=find(x>1.8);
x=x(i);
y=y(i);

[p,S] = POLYFIT (x,y,1)
[y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 figure(1)
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %g um',site,day,month,year,lambda(band)));
 subplot(2,1,2);
 plot(x,a,'g+'); 
 pause

 while max(abs(a))>3*std(a) 
  i=find(abs(a)<max (abs(a)));
  x=x(i);
  y=y(i);
  [p,S] = POLYFIT (x,y,1)
  [y_fit,delta] = POLYVAL(p,x,S);
  a=y-y_fit;
 end
 figure(1)
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %g um',site,day,month,year,lambda(band)));
 subplot(2,1,2);
 plot(x,a,'g+'); 
 print -dwinc
 
 V0(iband)=exp(p(2))/SunDist(day,month,year)
 tau(iband)=-p(1)
 RSD(iband)=std(a)
pause

end
