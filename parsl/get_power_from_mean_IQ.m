 
function [power,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2)

n_gates=length(mean_I(:,1))
n_rows=length(mean_I(1,:))

power=zeros(n_gates,n_rows);
for i=1:n_rows;

	% find region of minimum returned power 
	half_window=100;
	approx_mean_power=mean_I2(:,i)+mean_Q2(:,i);
	start_pt=0.5*length(approx_mean_power);
	[b,ind]=matlab_compute_running_mean(approx_mean_power(start_pt:end),half_window);
    ind=start_pt+ind; % note: c language uses 0 as first element, matlab uses 1 as first element

    if(i/50==fix(i/50))   
        disp(['processed ' num2str(i) ' of ' num2str(n_rows) ' records']); 
    end  

	% use this region to estimate DC offset 
	a=mean_I(ind-half_window:ind+half_window,i);
	DC_I(i)=mean(a(:));
	b=mean_Q(ind-half_window:ind+half_window,i);
	DC_Q(i)=mean(b(:));
    
    
	% calculate raw power removing DC offset in I and Q channels
	% for j=1:n_gates
		a= mean_I2(:,i) - 2*DC_I(i)*mean_I(:,i) + DC_I(i)*DC_I(i);
		b= mean_Q2(:,i) - 2*DC_Q(i)*mean_Q(:,i) + DC_Q(i)*DC_Q(i);
    % end   
      
	% estimate I/Q channel gain imbalances - assumes no signal in interval, noise has no fixed phase preference
	% I_to_Q_balance(i)=( mean(a(0.5*end:end))/mean(b(0.5*end:end)) )^0.5;
	I_to_Q_balance(i)=( mean(a(ind-half_window:ind+half_window))/mean(b(ind-half_window:ind+half_window)) )^0.5;

	% get power, noise power & remove noise floor from total power
	% power(:,i)=a(:)+(I_to_Q_balance(i)^2)*b(:);
    power(:,i)=a(:)+b(:);
	noise_floor(i)=mean(power(ind-half_window:ind+half_window,i));
	noise_power(i)=std(power(ind-half_window:ind+half_window,i));
	power(:,i)=power(:,i)-noise_floor(i);
	a=find(power(:,i)<0);
    power(a,i)=10^-30;  % set to low dummy value
    
end

return
