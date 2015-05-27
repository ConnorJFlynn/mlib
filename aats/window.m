% computes theoretical window transmittance over filter scans
 
clear
%********************************reads filter scans*******************************
 [filename, pathname] = uigetfile('c:\beat\data\filter\*.*', 'Filter', 0, 0);
 fid=fopen([pathname filename]);
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda_SPM=data(1,:);
 data(2,:) =data(2,:)/max(data(2,:));
 response=data(2,:);

%************************computes refractive index (real part)**********************
%Schott BK7

B1=1.03961212
B2=2.31792344e-1
B3=1.01046945
C1=6.00069867e-3
C2=2.00179144e-2
C3=1.03560653e2

y=sellmeier(lambda_SPM./1000,B1,B2,B3,C1,C2,C3);
n=sqrt(y+1)
P=2*n./(y+2)

%********************************reads window internal transmittance*******************************
 [filename, pathname] = uigetfile('c:\beat\data\glass\*.*', 'Internal Transmittance', 0, 0);
 fid=fopen([pathname filename]);
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda=data(1,:);
 transmittance=data(2,:);
 d1=5 % [mm]
 d2=5 % [mm]
 transmittance=exp(log(transmittance).*d2/d1);


%interpolate to filter scan wavelengths
transmittance = INTERP1(lambda,transmittance,lambda_SPM)'
transmittance=transmittance.*P


%*******************************Integrate********************************************************

x=trapz(response.*transmittance)
y=trapz(response)

T=x./y
