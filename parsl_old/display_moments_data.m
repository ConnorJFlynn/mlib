
function []=display_moments_data(file)

disp('loading moments data ...');
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file);

disp('esitmating noise floor ...');
[power,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2);

% need to fix this one day
range=((1:4096)-20)*6+1;

disp('applying range correction ...')
% /* put range factor in dBZ */
power2=zeros(size(power));
for i=1:length(range) 
   power2(i,:)=power(i,:)*(range(i)^2); 
end    

magic_constant = 10^-13.0687; 

% get date
T=findstr(file,'.moments.');
d=file(T+9:T+16);

figure
imagesc(power_time,range,10*log10(power2*magic_constant))
c=caxis;
axis('xy')
caxis([-60 20]);
a=axis;
axis([a(1) a(2) 0 5000])
colorbar
title('Approx. Reflectivity, dBZe (mm^6/m^3)','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)

% axis([power_time(1) power_time(0.5*end) 0 10000])

figure
imagesc(power_time,range,velocity)
axis('xy')
axis([a(1) a(2) 0 5000])
caxis([-1 1])
colorbar
title('Mean Doppler Velocity, m/s','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)

figure
imagesc(power_time,range,width)
axis('xy')
axis([a(1) a(2) 0 5000])
caxis([0 0.75])
colorbar
title('Doppler Width, m/s','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)

return

write_figs(1,'Parsl_radar_example2.dBZe','./')
write_figs(2,'Parsl_radar_example2.velocity','./')
write_figs(3,'Parsl_radar_example2.width','./')

