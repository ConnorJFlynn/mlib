clear
response=[0   1 0];
dlambda= [-5  0 5];
step       =1
start_wvl  =290
end_wvl_1  =349.5-5  % Cebula 
end_wvl_2  =410.5-5  % Woods
end_wvl_3  =876.68-5 % Thuillier
end_wvl_4  =3000-5   % Wehrli, MODTRAN
x_1=[start_wvl:step:end_wvl_1];
x_2=[start_wvl:step:end_wvl_2];
x_3=[start_wvl:step:end_wvl_3];
x_4=[start_wvl:step:end_wvl_4];

%======================================
fid=fopen('d:\beat\data\sun\Newkur.dat')
line=fgetl(fid);
line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun2=data(1,:);
 sun2       =data(2,:);
fclose(fid);
sun2=sun2.*lambda_sun2.^2/1e3;
lambda_sun2=1e7./lambda_sun2;

for ilambda=x_4
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun2<=max(lambda_SPM) & lambda_sun2 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun2(i));
 Kurucz_corr((ilambda-start_wvl)/step+1) = trapz(lambda_sun2(i),response2.*sun2(i))/trapz(lambda_sun2(i),response2');
end
%========================================
%Wehrli Spectrum
fid=fopen('d:\beat\data\sun\atlas85.asc')
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun=data(1,:);
 sun       =data(2,:);
fclose(fid);

for ilambda=x_4
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun<=max(lambda_SPM) & lambda_sun >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun(i));
 WRC((ilambda-start_wvl)/step+1) = trapz(lambda_sun(i),response2.*sun(i))/trapz(lambda_sun(i),response2');
 %WRC((ilambda-start_wvl)/step+1) =mean(sun(i));

end
%======================================

%====================Reads Thuillier as in MODTRAN3.7 v1.0 ==================
fid=fopen('d:\beat\data\sun\Thkur.dat')
line=fgetl(fid);
line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun2=data(1,:);
 sun2       =data(2,:);
fclose(fid);
sun2=sun2.*lambda_sun2.^2/1e3;
lambda_sun2=1e7./lambda_sun2;

for ilambda=x_4
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun2<=max(lambda_SPM) & lambda_sun2 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun2(i));
 Thuillier((ilambda-start_wvl)/step+1) = trapz(lambda_sun2(i),response2.*sun2(i))/trapz(lambda_sun2(i),response2');
end

%********* Reads Thuillier v9b ATLAS-1 Solar Spectrum***************
fid=fopen('d:\beat\data\sun\uvvi_v9_b.dat')
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun6=data(1,:);
 sun6       =data(2,:)/1000;
fclose(fid);

for ilambda=x_3
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun6<=max(lambda_SPM) & lambda_sun6 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun6(i));
 SOLSPECv9((ilambda-start_wvl)/step+1) = trapz(lambda_sun6(i),response2.*sun6(i))/trapz(lambda_sun6(i),response2');
end
%========================================
fid=fopen('d:\beat\data\sun\Chkur.dat')
line=fgetl(fid);
line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun2=data(1,:);
 sun2       =data(2,:);
fclose(fid);
sun2=sun2.*lambda_sun2.^2/1e3;
lambda_sun2=1e7./lambda_sun2;

for ilambda=x_4
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun2<=max(lambda_SPM) & lambda_sun2 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun2(i));
 Chance((ilambda-start_wvl)/step+1) = trapz(lambda_sun2(i),response2.*sun2(i))/trapz(lambda_sun2(i),response2');
end
%======================================

figure(3)
plot(x_3,SOLSPECv9./Kurucz_corr((x_3-start_wvl)/step+1),'m',...
   x_4,Thuillier./Kurucz_corr,'c',...  
   x_4,Chance./Kurucz_corr,'g',...     
   x_4,WRC./Kurucz_corr,'k' )

legend('Thuillier ver. 9b','Thuillier as in MOD3.7 ver. 1.0','Chance as in MOD3.7 ver. 1.0','Wehrli')
axis([290 1600 0.85 1.15])
xlabel('Wavelength (nm)','Fontsize',14)
ylabel('Ratio to Kurucz corr.','Fontsize',14)
set (gca,'Fontsize',14)
orient landscape
title('Solar Irradiance Databases','Fontsize',14)
grid on