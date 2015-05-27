% reads UW Humidograph data
%Time   Bdry  Bwet  Pamb RHamb RHdry RHwet  Tamb   RHinlet   Zuw 
% secs  1/m   1/m    mb    %     %     %      C      %        m 

Neph_corr='ON'
lambda_UW=530/1e3;

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\UW\ft*.txt','Choose UW Humidograph Data', 0, 0);
fid=fopen([pathname filename]);
title_UW=fgetl(fid);
fgetl(fid);
fgetl(fid);
fgetl(fid);
data=fscanf(fid,'%g',[10,inf]);

UT_UW   = mod(data(1,:),86400)/60/60;
Dry_scat_UW=data(2,:)*1e3;
Wet_scat_UW=data(3,:)*1e3;
Press_UW=data(4,:);
RH_amb_UW=data(5,:);
RH_dry_UW=data(6,:);
RH_wet_UW=data(7,:);
T_amb_UW=data(8,:);
RH_inlet_UW=data(9,:);
Altitude_UW=data(10,:)/1e3;
fclose(fid);

if strcmp(Neph_corr,'ON')
 read_UW_neph_corr % reads UW neph corrections for inlet and truncation computed by Don Collins
 i_UW_corr=find(UT_UW<=max(UT_UW_corr) & UT_UW>=min(UT_UW_corr));
 UT_UW      =UT_UW(i_UW_corr);
 Dry_scat_UW=Dry_scat_UW(i_UW_corr);
 Wet_scat_UW=Wet_scat_UW(i_UW_corr);
 Press_UW   =Press_UW(i_UW_corr);
 RH_amb_UW  =RH_amb_UW(i_UW_corr);
 RH_dry_UW  =RH_dry_UW(i_UW_corr);
 RH_wet_UW  =RH_wet_UW(i_UW_corr);
 T_amb_UW   =T_amb_UW(i_UW_corr);
 RH_inlet_UW=RH_inlet_UW(i_UW_corr);
 Altitude_UW=Altitude_UW(i_UW_corr);
 corr1_dry= interp1(UT_UW_corr,corr1_dry,UT_UW); %corrects truncation only
 corr2_dry= interp1(UT_UW_corr,corr2_dry,UT_UW); %correct truncation and inlet cut-off
 corr1_wet= interp1(UT_UW_corr,corr1_wet,UT_UW);
 corr2_wet= interp1(UT_UW_corr,corr2_wet,UT_UW);
 Wet_scat_corr_UW=Wet_scat_UW.*corr2_wet-Wet_scat_UW;
 Dry_scat_corr_UW=Dry_scat_UW.*corr2_wet-Dry_scat_UW;
 Scat_corr_err_UW=(Wet_scat_corr_UW+Dry_scat_corr_UW)/2*0.3; %assumes 30% error in inlet, trunc, and light source corr
 Dry_scat_UW=Dry_scat_UW.*corr2_dry;
 Wet_scat_UW=Wet_scat_UW.*corr2_wet;
end

%%This computes scattering at RH ambient
%gamma=log(Wet_scat_UW./Dry_scat_UW)./log((1-RH_wet_UW/100)./(1-RH_dry_UW/100));
%pp  = csaps(UT_UW,gamma,0.9999);
%gamma_spline = fnval(pp,UT_UW);
%k=Wet_scat_UW./(1-RH_wet_UW/100).^gamma_spline;
%Amb_scat_UW=k.*(1-RH_amb_UW/100).^gamma_spline;

%This computes water vapor density according to Boegel, 1977, p.108
b=(8.082-T_amb_UW/556).*T_amb_UW./(256.1+T_amb_UW);
a=13.233*(1+1e-8.*Press_UW.*(570-T_amb_UW))./(T_amb_UW+273.15);
H2O_Dens_UW=RH_amb_UW.*a.*10.^b;

% This smoothes the Neph scat coeffs.
pp  = csaps(UT_UW,Dry_scat_UW,0.999999);
Dry_scat_UW_spline = fnval(pp,UT_UW);
pp  = csaps(UT_UW,Wet_scat_UW,0.999999);
Wet_scat_UW_spline = fnval(pp,UT_UW);

figure(4)
subplot(3,1,1)
plot(UT_UW,Press_UW)
ylabel('P [hPa]');
title(title_UW)
subplot(3,1,2)
plot(UT_UW,Altitude_UW)
ylabel('Altitude [km]');
subplot(3,1,3)
plot(UT_UW,Dry_scat_UW,UT_UW,Wet_scat_UW,UT_UW,Dry_scat_UW_spline,UT_UW,Wet_scat_UW_spline)
legend('dry','wet')
ylabel('Scatt. Coeff [1/km]');
set(gca,'ylim',[0 0.20])

figure(5)
subplot(2,1,1)
plot(UT_UW,RH_dry_UW,UT_UW,RH_wet_UW,UT_UW,RH_amb_UW,UT_UW,RH_inlet_UW)
legend('dry','wet','ambient','inlet')
set(gca,'ylim',[0 100])
ylabel('RH [%]');
xlabel('UT');
subplot(2,1,2)
plot(UT_UW,T_amb_UW)
ylabel('T amb. [°C]');
xlabel('UT');
%set(gca,'ylim',[0 100])

%figure(3)
%subplot(2,1,1)
%plot(UT_UW,gamma,UT_UW,gamma_spline)
%axis([-inf inf -2 1])
%subplot(2,1,2)
%plot(UT_UW,k)
%axis([-inf inf 0 0.15])

%figure(4)
%plot(UT_UW,Dry_scat_UW,UT_UW,Wet_scat_UW,UT_UW,Amb_scat_UW)
%legend('dry','wet','ambient')
%grid on
%ylabel('Scatt. Coeff [1/km]');
%xlabel('UT');

figure(6)
plot(UT_UW,H2O_Dens_UW)
ylabel('H2O Density g/cm3');
