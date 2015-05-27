% 
%
%
function [times,power,mean_velocity,mean_width,all_data_time]=display_moments_all(directory,desired_date)

%alt=10000;  % maximum altitude shown on plots
alt = 1600;

time_start = 21.5; % start time on plots  -- 21.5
time_stop = 22.0;  % end time on plots   -- 22.75
time_lapse = time_stop-time_stop;
nhours = 1; % Length of time to be plotted - normally 24

%power_min = -70;   % Range for Reflectivity plot
%power_max =  20;
power_min = -70;
power_max =   0;

%velocity_min = -2; % Range for Doppler velocity plot 
%velocity_max = 2;
velocity_min = -1.5;  
velocity_max = 2.5;

width_min = 0;  % Range for Doppler width plot
width_max = 1.2;
%width_min = .2;
%width_max = .8;

% select average down interval (in hours)
% dt=1/60;  % one-minute averaging interval
dt = 1/240; % 15-second averaging interval

desired_year=str2num( desired_date(1:4) )
desired_month=str2num( desired_date(5:6) )
desired_day=str2num( desired_date(7:8) )

desired_datenum=datenum(desired_year,desired_month,desired_day);

file_type=[directory 'parsl.moments.*'];
possible_files=dir(file_type);

if(isempty(possible_files))
    disp(['No parsl.moments files in directory ' directory ]);
    return
end

list=char(possible_files(:).name);
possible_file_list=sortrows(list);

% check date on each file for match ...
for i=1:length(possible_files)

    % get date
    T=findstr(possible_file_list(i,:),'.moments.');
    date_str=possible_file_list(i,T+9:T+16);
    year=str2num(date_str(1:4));
    month=str2num(date_str(5:6) );
    day=str2num(date_str(7:8) );
    
    file_datenum(i)=datenum(year,month,day);
end    

diff=(file_datenum-desired_datenum);

previous_day=find(diff==-1)
if(~isempty(previous_day))
    files_to_read=previous_day(end);
else
    files_to_read=[];
end

this_day=find(diff==0);
if(~isempty(this_day))
    if(~isempty(files_to_read))
        files_to_read=[files_to_read this_day];
    else
        files_to_read=this_day;    
    end
end

if(isempty(files_to_read))
    disp(['No file(s) found for the desired date (or the day before) ' desired_date])
    return    
end

magic_constant = 10^-13.0687; 

h_power   =figure('PaperPosition',[0.75 4 7 6])
h_velocity=figure('PaperPosition',[0.75 4 7 6])
h_width   =figure('PaperPosition',[0.75 4 7 6])

time_min=99;
time_max=0;

% select average down interval (in hours)
% dt=1/60;  % one-minute averaging interval
    
for i=1:length(files_to_read) 
    
    file_name=[directory possible_file_list(files_to_read(i),:)]

    disp(['loading moments data ...' file_name]);
    [power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name);

    % adjust for cases where we wrap around midnight
    a=find(power_time<power_time(1));
    if(~isempty(a))
        power_time(a)=power_time(a)+24;
    end
    
    if(diff(files_to_read(i))==-1)
        power_time=power_time-24;
    end
    
    if(i==1)
 %       n_times=fix( 24/dt);
        n_times = fix(nhours/dt)
        n_gates=length(mean_I(:,1));
        
        mean_mean_I=zeros(n_gates,n_times);
        mean_mean_Q=zeros(n_gates,n_times);
        
        mean_mean_I2=zeros(n_gates,n_times);
        mean_mean_Q2=zeros(n_gates,n_times);
        
        mean_velocity=zeros(n_gates,n_times);
        mean_width=zeros(n_gates,n_times);
        
        power=1E-30*ones(size(mean_mean_I2));
        power2=zeros(size(power));
        
        all_data_time=power_time;
    else
        all_data_time=[all_data_time power_time];
    end    
   
   
    for j=1:n_times;
     
 %       a=find(power_time>(j-1)*dt & power_time<j*dt);
        a=find(power_time>((j-1)*dt+time_start) & power_time<(j*dt+time_start));
           
        if(~isempty(a))
            mean_mean_I(:,j)=mean(mean_I(:,a),2);        
            mean_mean_Q(:,j)=mean(mean_Q(:,a),2);
          
            mean_mean_I2(:,j)=mean(mean_I2(:,a),2);        
            mean_mean_Q2(:,j)=mean(mean_Q2(:,a),2);
            
            % mean_velocity(:,j)=mean(velocity(:,a),2); 
            mean_velocity(:,j)=velocity(:,a(1));
            % mean_width(:,j)=mean(width(:,a),2);
            mean_width(:,j)=width(:,a(1));
       end
       
    end
    
    % free memory used to store variables for this last file
    clear mean_I mean_Q mean_I2 mean_Q2 velocity width
end

    disp('esitmating noise floor ...');
    good_times=find(mean_mean_I2(10,:)>0);
    [power(:,good_times),noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_mean_I(:,good_times),mean_mean_Q(:,good_times),mean_mean_I2(:,good_times),mean_mean_Q2(:,good_times));

    % need to fix this one day
    range=((1:n_gates)-20)*6+1;
%    times=0.5*dt:dt:24;
    times = (0.5*dt + time_start):dt:time_stop;

    % /* put range factor in dBZ */
    disp('applying range correction ...')  
    for i=1:length(range) 
        a=find(power(i,:)>0);
        power2(i,a)=power(i,a)*(range(i)^2); 
    end    
    
    % add power from this file to power figure
    figure(h_power)
 
    imagesc(times,range,10*log10(power2*magic_constant))
    % surf(power_time,range,10*log10(power2*magic_constant))
    % view(2)
    % shading flat
   
    axis('xy')
    caxis([power_min power_max]);

    axis([time_start time_stop 0 alt])

    g_main=gca;
    g_bar=colorbar;
    axes(g_bar);
    ylabel('Reflectivity, dBZe (mm^6/m^3)','Fontsize',12);
    axes(g_main);
    
    % title('Approx. Reflectivity, dBZe (mm^6/m^3)','Fontsize',14);

    d=desired_date;
    xlabel(['Time ' d ', UTC'],'Fontsize',12)
    ylabel('Range, m','Fontsize',12)
   
   
    figure(h_velocity)
    imagesc(times,range,mean_velocity)
    axis('xy')
    axis([time_start time_stop 0 alt])
    caxis([velocity_min velocity_max])
    g_main=gca;
    g_bar=colorbar;
    axes(g_bar);
    ylabel('Mean Doppler Velocity, m/s','Fontsize',12);
    axes(g_main);
    xlabel(['Time ' d ', UTC'],'Fontsize',12)
    ylabel('Range, m','Fontsize',12)


    figure(h_width)
    imagesc(times,range,mean_width)  
    axis('xy')
    axis([time_start time_stop 0 alt])
    caxis([width_min width_max])
    g_main=gca;
    g_bar=colorbar;
    axes(g_bar);
    ylabel('Doppler Width, m/s','Fontsize',12);
    axes(g_main);
    xlabel(['Time ' d ', UTC'],'Fontsize',12)
    ylabel('Range, m','Fontsize',12)
    
end

return

clear all
close all

% Jim use these!!!
% directory='H:/RadarData/' 
% directory='c:/Radar/Data/' 
% directory='c:/data/mpace/radar/'
desired_date='20041010'
[times,power,mean_velocity,mean_width,all_data_time]=display_moments_all(directory,desired_date);

figure(1)
%print('-djpeg',['PARSL_94GHz_Radar_Reflectivity_1min_average.' desired_date '.jpg']);
print('-dpng',['PARSL_94GHz_Radar_Reflectivity_1min_average.' desired_date '.png']);

figure(2)
print('-dpng',['PARSL_94GHz_Radar_Mean_Velocity_1min_sample.' desired_date '.png']);

figure(3)
print('-dpng',['PARSL_94GHz_Radar_Spectral_Width_1min_sample.' desired_date '.png']);



m=mean(power,1);
a=find(10*log10(m)>-70);
t_start=times(a(1))
t_end=times(a(end))

figure(1)
a=axis;
axis([t_start t_end a(3) a(4)])
print('-dpng',['PARSL_94GHz_Radar_Reflectivity_1min_average_IQ_period_only.' desired_date '.png']);

figure(2)
a=axis;
axis([t_start t_end a(3) a(4)])
print('-dpng',['PARSL_94GHz_Radar_Mean_Velocity_1min_sample_IQ_period_only.' desired_date '.png']);

figure(3)
a=axis;
axis([t_start t_end a(3) a(4)])
print('-dpng',['PARSL_94GHz_Radar_Spectral_Width_1min_sample_IQ_period_only.' desired_date '.png']);




