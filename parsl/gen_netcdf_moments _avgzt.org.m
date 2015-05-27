% 
%
% Jim use these!!!
% directory='H:/RadarData/' 
% directory='c:/Radar/Data/' 
% directory='c:/data/mpace/radar/'
%desired_date='20041010'
%[times,power,mean_velocity,mean_width,all_data_time]=gen_netcdf_moments(directory,desired_date);
%
function [times,power,mean_velocity,mean_width,all_data_time]=gen_netcdf_moments_avgzt(directory,desired_date)

%alt=10000;  % maximum altitude shown on plots
%alt = 1600;

time_start = 21.5; % start time on plots  -- 21.5
time_stop = 22.0;  % end time on plots   -- 22.75
time_lapse = time_stop-time_stop;
nhours = 1; % Length of time to be plotted - normally 24


% select average down interval (in hours)
% dt=1/60;  % one-minute averaging interval
dt = 1/240; % 15-second averaging interval

binht = 6; % Range bin height in meters
dz = 30;  % Altitude averaging interval in meters 

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
        n_gates_raw = length(mean_I(:,1));
        n_gates= fix(length(n_gates_raw*binht/dz));
        
        mean_mean_I=zeros(n_gates,n_times);
        mean_mean_Q=zeros(n_gates,n_times);
        
        mean_mean_I2=zeros(n_gates,n_times);
        mean_mean_Q2=zeros(n_gates,n_times);
        
%        mean_velocity=zeros(n_gates,n_times);
%        mean_width=zeros(n_gates,n_times);
        
        power=1E-30*ones(size(mean_mean_I2));
        power2=zeros(size(power));
        
        all_data_time=power_time;
    else
        all_data_time=[all_data_time power_time];
    end    
   
 % Average times  
    for j=1:n_times;
     
 %       a=find(power_time>(j-1)*dt & power_time<j*dt);
        a=find(power_time>((j-1)*dt+time_start) & power_time<(j*dt+time_start));
           
        if(~isempty(a))
            mean_mean_I(:,j)=mean(mean_I(:,a),2);        
            mean_mean_Q(:,j)=mean(mean_Q(:,a),2);
          
            mean_mean_I2(:,j)=mean(mean_I2(:,a),2);        
            mean_mean_Q2(:,j)=mean(mean_Q2(:,a),2);
            
            % mean_velocity(:,j)=mean(velocity(:,a),2); 
            %mean_velocity(:,j)=velocity(:,a(1));
            % mean_width(:,j)=mean(width(:,a),2);
            %mean_width(:,j)=width(:,a(1));
       end
       
    end
    
    mean_I = mean_mean_I;
    mean_Q = mean_mean_Q;
    mean_I2 = mean_mean_I2;
    mean_Q2 = mean_mean_Q2;

 % Now average heights
 
    raw_alt = ((1:n_gates_raw)-20)*binht+1;
    for j=1:n_gates;
     
 %       a=find(power_time>(j-1)*dt & power_time<j*dt);
        a=find(raw_alt>(j-1)*dz & raw_alt<j*dz);
           
        if(~isempty(a))
            mean_mean_I(j,:)=mean(mean_I(a,:),1);        
            mean_mean_Q(j,:)=mean(mean_Q(a,:),1);
          
            mean_mean_I2(j,:)=mean(mean_I2(a,:),1);        
            mean_mean_Q2(j,:)=mean(mean_Q2(a,:),1);
            
            % mean_velocity(:,j)=mean(velocity(:,a),2); 
            %mean_velocity(j,:)=velocity(a(1),:);
            % mean_width(:,j)=mean(width(:,a),2);
            %mean_width(j,:)=width(a(1),:);
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
    
 


% Write data to NetCDF file

% Create file
nc = netcdf('radar_moments.cdf', 'clobber');

% Define dimensions
nc('time') = 0;
nc('range') = length(range);  % was 4096

% Define variables
nc{'time'} = ncfloat('time');
nc{'range'} = ncfloat('range');
nc{'Calibrated_Power'} = ncfloat('time', 'range');
%nc{'Doppler_Velocity'} = ncfloat('time', 'range');
%nc{'Doppler_Width'} = ncfloat('time', 'range');

% Define attributes

nc{'time'}.Units = 'Hours (UTC)';
nc{'range'}.Units = 'meters';
nc{'Calibrated_Power'}.Units = 'dBZe)';
%nc{'Doppler_Velocity'}.Units = 'meters/second';
%nc{'Doppler_Width'}.Units = 'meters/second';

close(nc);

% Write data

nc = netcdf('radar_moments.cdf', 'write');

%u = nc('time');
%u(:) = length(power_time);

%    imagesc(times,range,10*log10(power2*magic_constant))
%    imagesc(times,range,mean_velocity)
%    imagesc(times,range,mean_width)  

nc{'range'}(:) = range;
for i = 1:length(times);
  nc{'time'}(i) = times(i);
  nc{'Calibrated_Power'}(i,:) = 10*log10(power2(:,i)*magic_constant);
%  nc{'Doppler_Velocity'}(i,:) = mean_velocity(:,i);
%  nc{'Doppler_Width'}(i,:) = mean_width(:,i);
end
close(nc);
