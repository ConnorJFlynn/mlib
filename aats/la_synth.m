% Langley plot
clear
load

load c:\beat\data\xsect\xsect2.v3

% cross sections
lambda=xsect2(:,3)/1000;
tau_ray=xsect2(:,4);
a_O3 =xsect2(:,5);
a_NO2=xsect2(:,6);
a_SO2=xsect2(:,7);
a_H2O=xsect2(:,8);
b_H2O=xsect2(:,9);

%i=find (lambda>0.300 & lambda<0.323);
%a_O3(i)=1.4729e19.*exp(-139.5265*lambda(i));      %ozone x-sect

SZA=angle;
m_ray=1./(cos(SZA*pi/180)+0.50572*(96.07995-SZA).^(-1.6364)); %Kasten and Young (1989)
r=2.7; h=21;R=6371.229;
m_O3=(R+h)./((R+h)^2-(R+r)^2*(sin(SZA*pi/180)).^2).^0.5;      %Komhyr (1989)
m_H2O=1./(cos(SZA*pi/180)+0.0548*(92.65-SZA).^(-1.452));      %Kasten (1965)
m_aero=m_H2O;
m_SO2=m_ray;    % nicht sehr gut
m_NO2=m_O3;     % OK

% Mid Winter
%press=721.437
%NO2_clima=1.9315E-04;
%tau_NO2=NO2_clima*a_NO2;
%tau_O3=3.7012E-01*a_O3;
%tau_SO2=5.1539E-05*a_SO2;
% 300 nm
%f_O3(1,:) =exp(POLYVAL([-0.0671, -0.3590, -0.0009],log(m_O3)));
%f_ray(1,:)=POLYVAL([-0.0029, 1.0026],m_ray);

% 313 nm
%f_O3(2,:) =exp(POLYVAL([-0.0935, -0.2138, -0.0016],log(m_O3)));
%f_ray(2,:)=POLYVAL([-0.0025, 1.0022],m_ray);

% 305 nm
%f_O3 (3,:)=POLYVAL([-0.0096, 1.0093],m_O3);
%f_ray(3,:)=ones(size(m_ray));

% 310 nm
%f_O3 (4,:)=POLYVAL([-0.0069, 1.0065],m_O3);
%f_ray(4,:)=ones(size(m_ray));

% 320 nm
%f_O3 (5,:)=POLYVAL([-0.0072, 1.0071],m_O3);
%f_ray(5,:)=ones(size(m_ray));


% Mid Summer
press=736.617
NO2_clima=2.1322E-04;
tau_NO2=NO2_clima*a_NO2;
tau_O3=3.2413E-01 *a_O3;
tau_SO2=5.1430E-05*a_SO2;

% 300 nm
f_O3(1,:) =exp(POLYVAL([-0.0693, -0.3484, -0.001],log(m_O3)));
f_ray(1,:)=POLYVAL([-0.0033, 1.0031],m_ray);

% 313 nm
f_O3(2,:) =exp(POLYVAL([-0.0944, -0.2020, -0.0017],log(m_O3)));
f_ray(2,:)=POLYVAL([-0.0029, 1.0027],m_ray);

% 305 nm
f_O3 (3,:)=POLYVAL([-0.0092, 1.009],m_O3);
f_ray(3,:)=ones(size(m_ray));

% 310 nm
f_O3 (4,:)=POLYVAL([-0.0073, 1.0072],m_O3);
f_ray(4,:)=ones(size(m_ray));

% 320 nm
f_O3 (5,:)=POLYVAL([-0.0072, 1.0074],m_O3);
f_ray(5,:)=ones(size(m_ray));




%%%%%%%%%  300   313   305     310     320     340      368    412     450     500      610    675     719      778     817      862      946      1024
wvl_aero= [0     0     0       0       0       1        1      1       1       1        1      1       0        1       0        1        0        1     ]; 
wvl_chapp=[0     0     0       0       0       0        1      1       1       1        1      1       0        1       0        1        0        1     ]; 
wvl_water=[0     0     0       0       0       0        0      0       0       0        0      0       1        0       1        0        1        0     ];
wvl_o3=   [1     1     1       1       1       0        0      0       0       0        0      0       0        0       0        0        0        0     ];



channels=1:size(wvl_o3');

for ichan=channels(wvl_o3);
 figure(1)
 x=1./cos(SZA*pi/180);
 x=m_aero;
 y=direct(ichan,:).*exp(tau_ray(ichan)*f_ray(ichan,:).*m_ray+tau_O3(ichan)*f_O3(ichan,:).*m_O3+tau_NO2(ichan)*m_NO2+tau_SO2(ichan)*m_SO2); 
 y=log(y);
 i=find(x<=5);
 x=x(i);
 y=y(i);

 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 subplot(2,1,2);
 plot(x,a,'g+');
 title(filename(ichan,:));

 pause
 E0(ichan)=exp(p(2))
 tau(ichan)=-p(1)
 RSD(ichan)=std(a); 

 Err(ichan)=1-E0(ichan)/E0_true(ichan)
% write to file
 fid=fopen('c:\beat\matlab\la_synth.txt','a');
 fprintf(fid,'%s',filename(ichan,:));
 fprintf(fid,'%14.5e',E0_true(ichan),Err(ichan),E0(ichan),tau(ichan),RSD(ichan));
 fprintf(fid,'\n');
 close(1);
 fclose(fid);
end

for ichan=channels(wvl_aero);
 figure(1)
 x=m_aero;
 y=direct(ichan,:).*exp(tau_ray(ichan).*m_ray+tau_O3(ichan)*m_O3+tau_NO2(ichan)*m_NO2+tau_SO2(ichan)*m_SO2); 
 y=log(y);

 i=find(x<=7);
 x=x(i);
 y=y(i);

 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 subplot(2,1,2);
 plot(x,a,'g+');
 title(filename(ichan,:));

 E0(ichan)=exp(p(2))
 tau(ichan)=-p(1)
 RSD(ichan)=std(a); 
 Err(ichan)=1-E0(ichan)/E0_true(ichan)

 pause
 % write to file
 fid=fopen('c:\beat\matlab\la_synth.txt','a');
 fprintf(fid,'%s',filename(ichan,:));
 fprintf(fid,'%14.5e',E0_true(ichan),Err(ichan),E0(ichan),tau(ichan),RSD(ichan));
 fprintf(fid,'\n');
 close(1);
 fclose(fid);
end

% Compute total optical depth
clear tau_NO2

n=size(direct');
tau=(log(direct'./(ones(n(1),1)*E0)))'./(ones(n(2),1)*(-m_aero));

for i=1:n(1)
 [i,n(1)]
 [tau_a,tau_2,tau_3,O3_col,p]=ozone2('Mid Winter 2.7 km',1,1,1900,lambda,a_O3,a_NO2,NO2_clima,m_aero(i),m_ray(i),m_NO2(i),m_O3(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray,0.350,2);
 tau_aero(i,:) =tau_a';
 tau_NO2(i,:)  =tau_2';
 tau_ozone(i,:)=tau_3';
 ozone(i)=O3_col;
 if (O3_col > 0 & O3_col<.400)
  O3_col_start=O3_col;
 else
  O3_col_start=0.300;
 end
end

clear tau_a
clear tau_2
clear tau_3

tau_aero =tau_aero';
tau_NO2  =tau_NO2';
tau_ozone=tau_ozone';

% START MODIFIED LANGLEY PLOT

[m,n]=size(m_ray);

%Water Vapor
channels=1:size(wvl_water');
for ichan=channels(wvl_water);
 x=m_H2O.^b_H2O(channels(ichan));
 y=direct(ichan,:)'.*exp(m_aero'.*ones(n,m)*tau_aero(ichan)+m_ray'.*ones(n,m)*tau_ray(ichan)+m_O3'.*ones(n,m)*tau_ozone(ichan)+m_NO2'.*ones(n,m)*tau_NO2(ichan)); 
 y=log(y');

 %Airmass restriction 
 i=find(x<=10);
 x=x(i);
 y=y(i);

 [p,S] = POLYFIT (x,y,1)
 [y_fit,delta] = POLYVAL(p,x,S);
 a=y-y_fit;
 
 figure(1)
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm','Mid Winter 2.7 km',1,1,1900,lambda(ichan)));
 subplot(2,1,2);
 plot(x,a,'g+'); 
 pause

 while max(abs(a))>2.3*std(a) 
  i=find(abs(a)<max(abs(a)));
  x=x(i);
  y=y(i);
  [p,S] = POLYFIT (x,y,1)
  [y_fit,delta] = POLYVAL(p,x,S);
  a=y-y_fit;
 end
 
 figure(1)
 subplot(2,1,1)
 plot(x,y,'g+',x,y_fit);
 title(sprintf('%s %2i.%2i.%2i %8.3f µm','Mid Winter 2.7 km',1,1,1900,lambda(ichan)));
 subplot(2,1,2);
 plot(x,a,'g+');  

 E0(ichan)=exp(p(2))
 tau(ichan)=-p(1)
 RSD(ichan)=std(a); 
 Err(ichan)=1-E0(ichan)/E0_true(ichan)
  
 % write to file
 fid=fopen('c:\beat\matlab\la_synth.txt','a');
 fprintf(fid,'%s',filename(ichan,:));
 fprintf(fid,'%14.5e',E0_true(ichan),Err(ichan),E0(ichan),tau(ichan),RSD(ichan));
 fprintf(fid,'\n');
 close(1);
 fclose(fid);
end


