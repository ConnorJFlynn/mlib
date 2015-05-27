clear
response=[0   1 0];
dlambda= [-5  0 5];
step       =1
start_wvl  =290
end_wvl_1  =349.5-5  % Cebula 
end_wvl_2  =410.5-5  % Woods
end_wvl_3  =876.68-5 % Thuillier
end_wvl_4  =1100-5   % Wehrli, MODTRAN
end_wvl_5  = 880.43-5  % Thuillier v9b

x_1=[start_wvl:step:end_wvl_1];
x_2=[start_wvl:step:end_wvl_2];
x_3=[start_wvl:step:end_wvl_3];
x_4=[start_wvl:step:end_wvl_4];
x_5=[start_wvl:step:end_wvl_5];

%********* Reads 29 March 1992 Solar Spectrum of ATLAS1 SOLSPEC/SSBUV/SUSIM***************
fid=fopen('d:\beat\data\sun\A_290392.dat')
for i=1:21
 line=fgetl(fid);
end
data=fscanf(fid, '%g %g', [2,inf]);
lambda_sun5=data(1,:);
sun5       =data(2,:)/1e3;
fclose(fid);
for ilambda=x_1
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun5<=max(lambda_SPM) & lambda_sun5 >= min(lambda_SPM));

 response2= interp1(lambda_SPM,response,lambda_sun5(i));
 A_290392((ilambda-start_wvl)/step+1) = trapz(lambda_sun5(i),response2.*sun5(i))/trapz(lambda_sun5(i),response2');
 
 %A_290392((ilambda-start_wvl)/step+1)=mean(sun5(i));
end

%=====================================
fid=fopen('d:\beat\data\sun\U_150493.dat')
 line=fgetl(fid);
 line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun3=data(1,:);
 sun3       =data(2,:)/1e3;
fclose(fid);

for ilambda=x_2
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun3<=max(lambda_SPM) & lambda_sun3 >= min(lambda_SPM));
 
 response2= interp1(lambda_SPM,response,lambda_sun3(i));
 U_150493((ilambda-start_wvl)/step+1) = trapz(lambda_sun3(i),response2.*sun3(i))/trapz(lambda_sun3(i),response2');
 % U_150493((ilambda-start_wvl)/step+1)=mean(sun3(i));

end

%=====================================
fid=fopen('d:\beat\data\sun\U_290392.dat')
 line=fgetl(fid);
 line=fgetl(fid);
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun4=data(1,:);
 sun4       =data(2,:)/1e3;
fclose(fid);

for ilambda=x_2
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun4<=max(lambda_SPM) & lambda_sun4 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun4(i));
 U_290392((ilambda-start_wvl)/step+1) = trapz(lambda_sun4(i),response2.*sun4(i))/trapz(lambda_sun4(i),response2');
 %U_290392((ilambda-start_wvl)/step+1)=mean(sun4(i));
end

%********* Reads Thuillier ATLAS-1 Solar Spectrum***************
fid=fopen('d:\beat\data\sun\solspec.92')
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun6=data(1,:);
 sun6       =data(2,:)/1000;
fclose(fid);

for ilambda=x_3
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun6<=max(lambda_SPM) & lambda_sun6 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun6(i));
 SOLSPEC((ilambda-start_wvl)/step+1) = trapz(lambda_sun6(i),response2.*sun6(i))/trapz(lambda_sun6(i),response2');
 %SOLSPEC((ilambda-start_wvl)/step+1) = mean(sun6(i));
end
%********* Reads Thuillier v9b ATLAS-1 Solar Spectrum***************
fid=fopen('d:\beat\data\sun\uvvi_v9_b.dat')
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun6=data(1,:);
 sun6       =data(2,:)/1000;
fclose(fid);

for ilambda=x_5
 lambda_SPM=ilambda+dlambda;
 i=find(lambda_sun6<=max(lambda_SPM) & lambda_sun6 >= min(lambda_SPM));
 response2= interp1(lambda_SPM,response,lambda_sun6(i));
 SOLSPECv9((ilambda-start_wvl)/step+1) = trapz(lambda_sun6(i),response2.*sun6(i))/trapz(lambda_sun6(i),response2');
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
fid=fopen('d:\beat\data\sun\sun_kur.dat')
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
 Kurucz((ilambda-start_wvl)/step+1) = trapz(lambda_sun2(i),response2.*sun2(i))/trapz(lambda_sun2(i),response2');
 %Kurucz((ilambda-start_wvl)/step+1) =mean(sun2(i));
end
%======================================
fid=fopen('d:\beat\data\sun\sun3.dat')
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
 %Kurucz((ilambda-start_wvl)/step+1) =mean(sun2(i));
end
%======================================
figure(1)
plot(x_1, A_290392./WRC((x_1-start_wvl)/step+1),x_2,SOLSPEC((x_2-start_wvl)/step+1)./WRC((x_2-start_wvl)/step+1),x_2,U_290392./WRC((x_2-start_wvl)/step+1),x_2,U_150493./WRC((x_2-start_wvl)/step+1),x_4,Kurucz_corr./WRC)
legend('SOLSPEC/SSBUV/SUSIM (ATLAS-1)','SOLSPEC (ATLAS-1)','UARS SUSIM/SOLSTICE (29.03.92)','UARS SUSIM/SOLSTICE (15.04.93)','MODTRAN3.5 v1.2')
axis([290 410 0.9 1.1])
xlabel('Wavelength (nm)')
ylabel('Ratio to WRC Spectrum')

figure(2)
plot(x_2,U_150493./U_290392,'-.',x_1, A_290392./U_290392((x_1-start_wvl)/step+1),'.',x_2,SOLSPEC((x_2-start_wvl)/step+1)./U_290392((x_2-start_wvl)/step+1),':',x_2,WRC((x_2-start_wvl)/step+1)./U_290392((x_2-start_wvl)/step+1),'^-',x_2,Kurucz_corr((x_2-start_wvl)/step+1)./U_290392((x_2-start_wvl)/step+1),'-')
legend('UARS SUSIM/SOLSTICE (29.03.92)','SOLSPEC/SSBUV/SUSIM (ATLAS-1)','SOLSPEC (ATLAS-1)','WRC','MODTRAN3.5 v1.2')
axis([290 410 0.9 1.1])
xlabel('Wavelength (nm)')
ylabel('Ratio to UARS: SUSIM/SOLSTICE 15.04.93')

figure(3)
plot(x_5,SOLSPECv9./WRC((x_5-start_wvl)/step+1),x_3,SOLSPEC./WRC((x_3-start_wvl)/step+1),x_4,Kurucz_corr./WRC)
legend('SOLSPEC v9b (ATLAS-1)','SOLSPEC (ATLAS-1)','MODTRAN3.5 v1.2')
axis([350 1050 0.9 1.1])
xlabel('Wavelength (nm)','FontSize',14)
ylabel('Ratio to WRC Spectrum','FontSize',14)
set(gca,'FontSize',14)