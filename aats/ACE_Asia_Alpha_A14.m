%plot frequency distributions of alpha*, gamma and alpha, AOD for ACE-Asia AATS-14 data.
alpha_all=[];
gamma_all=[];
a0_all=[];
AOD_all=[];
GPS_Altitude_all =[];
%pathname='c:\beat\data\ACE-Asia\results\ver3\';
pathname='c:\beat\data\ACE-Asia\results\';
direc=dir(fullfile(pathname,'CIR*r.asc')); 
[filelist{1:length(direc),1}] = deal(direc.name);

for i=1:length(filelist)
    disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    fgetl(fid);
    title1=fgetl(fid);
    for i=1:10
        fgetl(fid);
    end
    lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
    data=fscanf(fid,'%g',[38,inf]);
    fclose(fid);
    UT=data(1,:);
    Latitude=data(2,:);
    Longitude=data(3,:);
    GPS_Altitude=data(4,:);
    Pressure_Altitude=data(5,:);
    Pressure=data(6,:);
    H2O=data(7,:);
    H2O_Error=data(8,:);
    AOD_flag=data(9,:);
    AOD=data(10:22,:);
    AOD_Error=data(23:35,:);
    gamma=-data(36,:);
    alpha=-data(37,:);
    a0=data(38,:);  
    AOD_all=[AOD_all AOD(:,AOD_flag==1)];
    alpha_all=[alpha_all alpha(AOD_flag==1)];
    gamma_all=[gamma_all gamma(AOD_flag==1)];
    a0_all   =[a0_all    a0(AOD_flag==1)];
    GPS_Altitude_all=[GPS_Altitude_all GPS_Altitude(AOD_flag==1)];
end

%calculate alpha for lambda range

% lambda_1=[.380];
% lambda_2=[1.020];

lambda_1=[1.020];
lambda_2=[1.558];

x=log(lambda_1);
AOD_1=exp(-gamma_all*x^2-alpha_all*x+a0_all);

x=log(lambda_2);
AOD_2=exp(-gamma_all*x^2-alpha_all*x+a0_all);

real_alpha=log(AOD_1./AOD_2)./log(lambda_2/lambda_1);

figure(1)
hist(alpha_all,300)
title('alpha*')

figure(2)
hist(gamma_all,300)
title('AATS-14 gamma*')

figure(3)
hist(real_alpha,300)
title('AATS-14 \alpha for all z')
xlabel('\alpha')

[N,X]=hist(real_alpha,300);
figure(4)
plot(X,cumsum (N)/sum(N))
grid on
title('AATS-14 \alpha for all z')
xlabel('\alpha')
ylabel('Fraction')

%find low altitudes )(below 80m to be consistent with Jens' plots)
ii_low=find(GPS_Altitude_all<=0.080);

figure(5)
hist(real_alpha(ii_low),300)
title('AATS-14 \alpha for z<=80m')
xlabel('\alpha')

[N_low,X_low]=hist(real_alpha(ii_low),300);
figure(6)
plot(X_low,cumsum (N_low)/sum(N_low))
grid on
title('AATS-14 \alpha for z<=80m')
xlabel('\alpha')
ylabel('Fraction')



figure(7)

a_coeff=0.0651; % 354 nm
b_coeff=-1.6021;% 354 nm
runc_slope=-0.0294;
runc_intercept=0.2110;


diff_corr=a_coeff.*exp(b_coeff.*real_alpha);

err_diff_corr=(runc_slope*real_alpha+runc_intercept).*diff_corr;

subplot(2,1,1)
plot(real_alpha)
grid on
subplot(2,1,2)
plot(diff_corr)
hold on
plot(diff_corr+err_diff_corr,'r')
plot(diff_corr-err_diff_corr,'r')
hold off
grid on


figure(8)
hist(diff_corr,100)

figure(9)
[N,X]=hist(diff_corr,300);
plot(X,cumsum (N)/sum(N))
grid on
title('AATS-14 diff corr')
xlabel('\alpha 1020-1558 nm')
ylabel('Fraction')




figure(10)
plot(AOD_all(10,:),real_alpha,'.')
grid on
