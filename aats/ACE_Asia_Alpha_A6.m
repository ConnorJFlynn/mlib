%plot frequency distributions of alpha for ACE-Asia AATS-6 data.
close all
clear all

plot_phil='OFF';


alpha_all=[];
gamma_all=[];
a0_all=[];
GPS_Altitude_all =[];
AOD_all=[];
pathname='c:\beat\data\ACE-Asia\results\';
direc=dir(fullfile(pathname,'RF*r.asc')); 
[filelist{1:length(direc),1}] = deal(direc.name);

for i=1:length(filelist)
    disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    
    fgetl(fid);
    site=fscanf(fid,'%25c',[1 1]);
    
    for i=1:14
       fgetl(fid);
    end   
    data=fscanf(fid,'%f',[17,inf]);
    fclose(fid);
    UT=data(1,:);
    GPS_Alt=data(4,:);
    AOD_flag=data(8,:);
    Latitude=data(2,:);
    Longitude=data(3,:);
    GPS_Alt=data(4,:);
    Pressure=data(5,:);
    H2O=data(6,:);
    H2O_Error=data(7,:);
    AOD_flag=data(8,:);
    alpha=data(9,:);
    AOD=data(10:13,:);
    AOD_err=data(14:17,:);
    AOD_all=[AOD_all AOD(:,AOD_flag==1)];
    alpha_all=[alpha_all alpha(AOD_flag==1)];
    GPS_Altitude_all=[GPS_Altitude_all GPS_Alt(AOD_flag==1)];
end


real_alpha=alpha_all;

figure(3)
hist(real_alpha,300)
title('AATS-6 \alpha for all z')
xlabel('\alpha')

[N,X]=hist(real_alpha,300);
cum_sum=cumsum(N)/sum(N);

if strcmp(plot_phil,'ON')
   fid=fopen('c:\jens\data\ace-asia\AATS6_results\Alpha_dist_A6.txt','w');
   fprintf(fid,'%s  %s \n','Alpha(i)', 'N(i)');

   for i=1:300
     %fprintf(fid,'%s %s %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f\n', AATS6_filename(1:4), AATS6_filename(17:20), delta_AOD_UW_3, delta_AOD_AATS6_3,alpha_whole,delta_AOD_UW_free,delta_AOD_AATS6_free,alpha_free,delta_AOD_UW_pbl,delta_AOD_AATS6_pbl,alpha_pbl);
     %fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
      fprintf(fid,'%8.3f  %8.3f %9.4f \n',X(i), N(i), cum_sum(i));
      disp(sprintf('%8.3f  %8.3f ',X(i), N(i), cum_sum(i)))
    
   end


fclose(fid);   
end




figure(4)
plot(X,cumsum (N)/sum(N))
grid on
title('AATS-6 \alpha for all z')
xlabel('\alpha')
ylabel('Fraction')

%find low altitudes )(below 80m to be consistent with Jens' plots)
ii_low=find(GPS_Altitude_all<=0.080);

figure(5)
hist(real_alpha(ii_low),100)
title('AATS-6 \alpha for z<=80m')
xlabel('\alpha')

[N,X]=hist(real_alpha(ii_low),100);

cum_sum=cumsum(N)/sum(N);

if strcmp(plot_phil,'ON')
   fid=fopen('c:\jens\data\ace-asia\AATS6_results\Alpha_dist_A6_below80.txt','w');
   fprintf(fid,'%s  %s \n','Alpha(i)', 'N(i)');

   for i=1:100
     %fprintf(fid,'%s %s %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f\n', AATS6_filename(1:4), AATS6_filename(17:20), delta_AOD_UW_3, delta_AOD_AATS6_3,alpha_whole,delta_AOD_UW_free,delta_AOD_AATS6_free,alpha_free,delta_AOD_UW_pbl,delta_AOD_AATS6_pbl,alpha_pbl);
     %fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
      fprintf(fid,'%8.3f  %8.3f %9.4f \n',X(i), N(i), cum_sum(i));
      disp(sprintf('%8.3f  %8.3f ',X(i), N(i), cum_sum(i)))
    
   end
fclose(fid);   
end


figure(6)
plot(X,cumsum (N)/sum(N))
grid on
title('AATS-6 \alpha for z<=80m')
xlabel('\alpha')
ylabel('Fraction')


figure(7)
hist(AOD_all(1:4,:)',40)

figure(9)
plot(AOD_all(4,:),real_alpha,'.')
grid on