% reads Misu data provided by E. Ostrom
%
%README
%
%The files tf15_run30.fin and tf20_run30.fin are 30 points running average
%files for the scattering coefficients as measured by the TSI nephelometer.
%The temperature and pressure and rh have not been changed from the original 
%data.
%
%The files contain the following data:
%
%Time (in seconds since midnight (pdms time).
%blue total scattering coefficient in m^-1
%green dito
%red dito
%blue backscattering coefficient
%green dito
%red dito
%pressure in hPa
%temperature in Kelvin
%relative humidity 

Neph_corr='ON'
lambda_Misu=[450,550,700]/1e3

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Misu\*.fin','Choose Misu data file', 0, 0);
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g %g %g %g %g %g %g',[10,inf]);
fclose(fid);
UT_Misu   = data(1,:)/60/60;
Scat_Misu_blue=data(2,:);
Scat_Misu_green=data(3,:);
Scat_Misu_red=data(4,:);
BackScat_Misu_blue=data(5,:);
BackScat_Misu_green=data(6,:);
BackScat_Misu_red=data(7,:);
Press_Misu=data(8,:);
Temp_Misu=data(9,:)-273.15;
RH_Misu=data(10,:);

%correct for negative offset
if min(Scat_Misu_blue)<0 Scat_Misu_blue=Scat_Misu_blue-min(Scat_Misu_blue); end;   
if min(Scat_Misu_green)<0 Scat_Misu_green=Scat_Misu_green-min(Scat_Misu_green);  end;  
if min(Scat_Misu_red)<0 Scat_Misu_red=Scat_Misu_red-min(Scat_Misu_red);   end; 
   
Scat_Misu=[Scat_Misu_blue',Scat_Misu_green',Scat_Misu_red']'*1e3;
BackScat_Misu=[BackScat_Misu_blue',BackScat_Misu_green',BackScat_Misu_red']'*1e3;

%make time monotonic
i_Misu=find(diff(UT_Misu)>0);
UT_Misu=UT_Misu(i_Misu);
Scat_Misu=Scat_Misu(:,i_Misu);
BackScat_Misu=BackScat_Misu(:,i_Misu);

clear Scat_Misu_blue;
clear Scat_Misu_green;
clear Scat_Misu_red;
clear BackScat_Misu_blue;
clear BackScat_Misu_green;
clear BackScat_Misu_red;


if strcmp(Neph_corr,'ON')
 read_Misu_corr % reads Misu corrections for inlet and truncation computed by Don Collins
 i_Misu_corr=find(UT_Misu<=max(UT_Misu_corr) & UT_Misu>=min(UT_Misu_corr));
 UT_Misu   =UT_Misu(i_Misu_corr);
 Press_Misu=Press_Misu(i_Misu_corr);
 Temp_Misu =Temp_Misu(i_Misu_corr);
 RH_Misu   =RH_Misu(i_Misu_corr);
 Scat_Misu=Scat_Misu(:,i_Misu_corr);
 BackScat_Misu=BackScat_Misu(:,i_Misu_corr);
 
 corr1_total_scat_Misu=interp1(UT_Misu_corr,corr1_total_scat_Misu',UT_Misu)';
 corr2_total_scat_Misu=interp1(UT_Misu_corr,corr2_total_scat_Misu',UT_Misu)';
 corr1_back_scat_Misu=interp1(UT_Misu_corr,corr1_back_scat_Misu',UT_Misu)';
 corr2_back_scat_Misu=interp1(UT_Misu_corr,corr2_back_scat_Misu',UT_Misu)';
 Scat_corr_err_Misu=(Scat_Misu.*corr2_total_scat_Misu-Scat_Misu)*0.3; %assumes 30% error in inlet, trunc, and light source corr
 Scat_Misu=Scat_Misu.*corr2_total_scat_Misu;
 BackScat_Misu=BackScat_Misu.*corr2_back_scat_Misu;
end

figure(2)
subplot(4,1,1)
plot(UT_Misu,Scat_Misu)
ylabel('Scat. Coeff [1/km]');
xlabel('UT');
title(filename)

subplot(4,1,2)
plot(UT_Misu,Press_Misu)
ylabel('Press[hPa]');
xlabel('UT');

subplot(4,1,3)
plot(UT_Misu,Temp_Misu)
ylabel('Temp [°C]');
xlabel('UT');

subplot(4,1,4)
plot(UT_Misu,RH_Misu)
ylabel('RH [%]');
xlabel('UT');

