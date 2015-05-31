

% directory='../../../Test_data/';
directory='../../../Lab_data/LNA_v1.59_5MHz_60dB/';

% get list of files
a=dir([directory 'parsl.IQ.*.dat*']);
files=char(a(:).name);
[Y,I]=sortrows(files);
file_name=[directory a(I(1)).name]

[I,Q,time_hour,time_year,elevation,azimuth]=read_IQ_data_file(file_name);
[power,mean_I,mean_Q,mean_I2,mean_Q2,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_IQ_data(I,Q);


% get power & I and Q channel charateristics
[power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_IQ_data(I,Q);

% rebalance I and Q values 
I=I-DC_I;
Q=(Q-DC_Q)*I_to_Q_balance;


%
% load power data
%
% directory='/natasha_disk4/roj/LNA_v2.04_5MHz_60dB/';
% directory='/natasha_disk4/roj/LNA_v1.59_5MHz_60dB_vL10/';
% directory='/natasha_disk4/roj/LNA_v0.99_5MHz_80dB/';
% directory='/natasha_disk4/roj/LNA_v1.59_5MHz_80dB/';
directory='/natasha_disk2/roj/LNA_v1.59_5MHz_80dB_vL10_2amp/';
directory='/natasha_disk2/roj/LNA_v0.99_MHz_80dB_vL10/';
directory='/natasha_disk5/roj/LNA_v2.04_5MHz_90dB/';
directory='/natasha_disk5/roj/LNA_v1.60_5MHz_80dB/'
a=dir([directory 'parsl.radar_power.*.dat*'])
disp('Be careful to get the correct power file ... take the first one ?')
file_name=[directory a(1).name];
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,elevation,azimuth,n_gates,start_date]=read_radar_power_file(file_name);


directory='/natasha_disk3/roj/PARSL/IMPROVE_2/moments_n_logs/';
a=dir([directory 'parsl.radar_power.*.dat*']);

file_name=[directory a(25).name];
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,n_gates]=read_old_radar_power_file(file_name);


%
% Calculate power
%
[power,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2);


figure
% plot(10*log10(power(:,pick)))
hold on
plot(10*log10(p3),'r--')

% get moments data
a=dir([directory 'parsl.moments.*.dat*']);
file_name=[directory a(end).name];
[power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name);


% get list of spectra files
a=dir([directory 'parsl.spectra.*.dat*']);
files=char(a(:).name);
[Y,index]=sortrows(files);

file=[directory a(index(pick)).name]
[spectra,spectra_velocity,time_hour,time_year,wavelength,IPP]=read_spectra_data_file(file);


figure
imagesc(spectra_velocity,1:512,10*log10(spectra))
axis('xy')


for i=2:length(a(:))

file_name=[ '/natasha_disk3/roj/PARSL/lab_data2/day2b/' a(i).name]);
[I,Q,time_hour,time_year,elevation,azimuth]=read_IQ_data_file(file_name);

DC_I=mean(mean(I(end-100:end,:)));
DC_Q=mean(mean(Q(end-100:end,:)));


		for k=1:length(I(:,1))  % for each height bin
            
			[ave_power_spectra,n_spectra_averaged, ...
			 mean_power(k),mean_Doppler_velocity(k),spectral_width(k)]= ...
				matlab_Get_Radar_Spectra(...
					-(I(k,:)-DC_I), ...
					 (Q(k,:)-DC_Q), ...
					n_pts_in_fft,IPP,wavelength); 

			ave_power_spectra_image(:,k)=fftshift(ave_power_spectra);
		end
        
        
		for k=1:length(I(:,1))  % for each height bin
            
			[ave_power_spectra,n_spectra_averaged, ...
			 mean_power(k),mean_Doppler_velocity(k),spectral_width(k)]= ...
				matlab2_Get_Radar_Spectra(...
					-I(k,:), ...
					-Q(k,:), ...
					n_pts_in_fft,IPP,wavelength); 

			ave_power_spectra_image(:,k)=fftshift(ave_power_spectra);
		end
end




[I,Q,time_hour,time_year,elevation,azimuth]=read_IQ_data_file(file_name);
[power,mean_I,mean_Q,mean_I2,mean_Q2,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_IQ_data(I,Q);

wavelength= 3E8/94E9   
IPP=1/(5.0E3)
n_pts_in_fft=512;
dummy=0.5*wavelength/(n_pts_in_fft*IPP);

for k=1:512
	spectra_velocity(k)=(k - 0.5*n_pts_in_fft -1)*dummy;
end

  
		for k=1:length(I(:,1))  % for each height bin
      
			[ave_power_spectra,n_spectra_averaged, ...
			 mean_power(k),mean_Doppler_velocity(k),spectral_width(k)]= ...
				matlab2_Get_Radar_Spectra(...
					-(I(k,:)-DC_I), ...
					-(Q(k,:)-DC_Q)*(I_to_Q_balance^0.5), ...
					n_pts_in_fft,IPP,wavelength); 

			ave_power_spectra_image(:,k)=fftshift(ave_power_spectra);
              
		end

            
     for p=1:200
         
        tat=p/200
        tit=1-tat;
        
			[ave_power_spectra,n_spectra_averaged, ...
			 mean_power(k),mean_Doppler_velocity(k),spectral_width(k)]= ...
				matlab2_Get_Radar_Spectra(...
					-(I(k,:)-DC_I)*tat-tit*(Q(k,:)-DC_Q)*(I_to_Q_balance^0.5), ...
					-(Q(k,:)-DC_Q)*(I_to_Q_balance^0.5), ...
					n_pts_in_fft,IPP,wavelength); 

			ave_power_spectra_image(:,p)=fftshift(ave_power_spectra);
              
		end


range=((1:4096)-20)*6+1;
a=find(range>=0 & range<=10000);
figure
imagesc(spectra_velocity,range(a),10*log10(ave_power_spectra_image(:,a)'))
axis('xy')
xlabel('Velocity, m/s')
ylabel('Altitude, m AGL')

b=find(range>3000);
figure
plot(spectra_velocity,10*log10(ave_power_spectra_image(:,b(1))),'r')
hold on

figure
plot(width(:,end),range)
hold on
plot(spectral_width,range,'r--')

figure
plot(velocity(:,end),range)
hold on
plot(mean_Doppler_velocity,range,'r--')
