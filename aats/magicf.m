function magic_factor=magicf(lambda_SPM,response);

%computes magic factor from Solar and Lamp Spectrum

%********* Reads Solar Spectrum***************
%fid=fopen('c:\beat\data\sun\atlas85.asc');
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun=data(1,:);
% sun       =data(2,:);
%fclose(fid);


%fid=fopen('c:\beat\data\sun\sun2.dat');
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun=data(1,:);
% sun       =data(2,:);
%fclose(fid);

%sun=sun.*lambda_sun.^2/1e3;
%lambda_sun=1e7./lambda_sun;


fid=fopen('c:\beat\data\sun\sun2.dat');
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun=data(1,:);
 sun       =data(2,:);
fclose(fid);

sun=sun.*lambda_sun.^2/1e3
lambda_sun=1e7./lambda_sun;



%figure(7)
%plot(lambda_sun,sun)
%xlabel('Wavelength [nm]');
%ylabel('Irradiance [W/m^2/nm]');
%set(gca,'xlim',[250 2500])
%title('WRC Solar Irradiance Spectrum');

sun= INTERP1(lambda_sun,sun,lambda_SPM);
sun_w_response=sun'.*response;
x = trapz(lambda_SPM,sun_w_response);

%********* Reads FEL Lamp-Spectrum***************

[filename,path]=uigetfile('c:\beat\data\lamps\f*.prn', 'Choose a Lamp File', 0, 0);
fid=fopen([path filename]);
data=fscanf(fid, '%g %g', [2,inf]);
lambda_FEL=data(1,:);
FEL       =data(2,:);
fclose(fid);

%figure(8)
%plot(lambda_FEL,FEL)
%xlabel('Wavelength [nm]');
%ylabel('Irradiance [W/m^2/nm]');
%title('FEL-Lamp Irradiance Spectrum');

FEL= INTERP1(lambda_FEL,FEL,lambda_SPM);
FEL_w_response=FEL'.*response;

y= trapz(lambda_SPM,FEL_w_response);

magic_factor=x/y;

end;
