
function []=display_radar_power(file)

% file='../../IMPROVE/*radar_power*'

    a=dir(file);

    if(isempty(a))
        disp(['No file(s) found with name : ' file])
        return    
    end
    
    files=char(a(:).name)

    if(length(a(:))>1)
        disp('More than one power file located ... ploting most recent');
        
        files=sortrows(files);
    end
    
    s=findstr(file,'/');
    directory=file(1:s(end))
    file_name=[directory files(end,:)]

	% load power data
	[power_time,mean_I,mean_Q,mean_I2,mean_Q2,n_gates]=read_radar_power_file(file_name);


	% remove DC noise offset
	noise_gates=500:512;
	%[power,DC_I,DC_Q]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2,noise_gates);
	[power,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2);
  

	% remove noise floor
% 	for i=1:length(power(1,:))
% 		noise_power(i)=mean( power(noise_gates,i) );
% 
% 		power(:,i)=power(:,i)-noise_power(i);
% 	end
	

	% apply range correction and callibration Coeff
	% NOTE must normalize by lekage signal  ... and remove negative values (?)
	Rc = 10^-19.0 * 10 ^18;
	lekage_bin=4;
 	dr = 30 ;
 
	path_loss = 1;
	power_n=zeros( size(power) );
	for j=lekage_bin+1:length(power(:,1))

		dist = (j-lekage_bin)*dr;
		C=dist^2 * Rc * path_loss^2;

		for i=1:length(power(1,:))
			if(power(j,i) > 0)
				power_n(j,i) = power(j,i) / power(lekage_bin,i) * C ; 
			end
		end
	end

	height =  ( (1:512) - lekage_bin ) * dr;

for i=1:length(height)
	a=find(power_n(j,:)>0);
	power_profile(i)=mean(power_n(i,a));
end
		

    power2=10*log10(power_n);
    
    figure
    imagesc(power_time,height,power2)
    axis('xy')    

    xlabel('Time, hours')
    ylabel('Height, m')
    k=findstr(files(end,:),'20')
    title(['Power in dB from ' files(end,k:k+14) ])
    
%    s_min=min(power(10:end,0.5*end))-1
%    s_max=max(power(10:end,0.5*end))+3
%    caxis([ (s_min )  (s_max )]);

    caxis([-60 50])	
    colorbar
   
    
return
    
        
