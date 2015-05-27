
function [file_name]=display_moments_data(file,alt)
close all;
a=dir(file);

if(isempty(a))
    disp(['No file(s) found with name : ' file])
    return    
end

files=char(a(:).name)

if(length(a(:))>1)
    disp('More than one moment file located ... plotting most recent');
    
    files=sortrows(files);
end

s=findstr(file,'/');
directory=file(1:s(end))
file_name=[directory files(end,:)]

disp('loading moments data ...');
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name);

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
axis([a(1) a(2) 0 alt])
colorbar
title('Approx. Reflectivity, dBZe (mm^6/m^3)','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)
gfile=datestr(now);
gfile=strrep(gfile,' ','-');
gfile=strrep(gfile,':','-');
gfile=['parslradar-',gfile,'.png'];
% cd r:\;
% print('-dpng', gfile);
% axis([power_time(1) power_time(0.5*end) 0 10000])

figure
imagesc(power_time,range,velocity)
axis('xy')
axis([a(1) a(2) 0 alt])
caxis([-2 2])
colorbar
title('Mean Doppler Velocity, m/s','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)


figure
imagesc(power_time,range,width)
axis('xy')
axis([a(1) a(2) 0 alt])
caxis([0 2])
colorbar
title('Doppler Width, m/s','Fontsize',14);
xlabel(['Time ' d ', UTC'],'Fontsize',14)
ylabel('Appoximate Range, m','Fontsize',14)

cd C:/roj/matlab_codes;

return




