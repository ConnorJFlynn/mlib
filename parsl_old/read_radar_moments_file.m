
function [power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name)

% get time from file name
	
	[k]=findstr(file_name,'parsl.moments.');
	T=file_name(k+14:end);

	year=str2num(T(1:4));
	month=str2num(T(5:6));
	day=str2num(T(7:8));

	hour=str2num(T(10:11));
	min=str2num(T(12:13));
	sec=str2num(T(14:15));
 	msec=str2num(T(17:19));
	
% start_date=time_to_year_fraction(year,month,day,hour,min,sec+1E-3*msec) ;
start_date=time_to_year_fraction(year,month,day,0,0,0) ;
	
% if gzip ... then copy to unzipped version ... temporarily
if( strcmp(file_name(end-2:end),'.gz') )
	test=unix(['gzip -d -c ' file_name ' >temp.dat' ])
	fid=fopen('temp.dat','r','l');
    file_name='temp.dat';
else
	fid=fopen([file_name],'r','l');
end

N_time_samples=fread(fid,[1 1],'int')  % number of radar pulse acquire per moment
n_gates=fread(fid,[1 1],'int')

size_of_record=4*(6*n_gates+6);
a=dir(file_name);
n_rows=(a(1).bytes-8)/size_of_record  % number of profiles for each moment

if(n_rows~=floor(n_rows))  % ignore last partial record
    n_rows=floor(n_rows)-1
end

mean_I=zeros(n_gates,n_rows);
mean_Q=zeros(n_gates,n_rows);
mean_I2=zeros(n_gates,n_rows);
mean_Q2=zeros(n_gates,n_rows);
velocity=zeros(n_gates,n_rows);
width=zeros(n_gates,n_rows);
power_time=zeros(1,n_rows);
elevation=zeros(1,n_rows);
azimuth=zeros(1,n_rows);


data=1;
count=0;
while(~isempty(data) & count < (n_rows+1))

	% read time header data
	data=fread(fid,[4 1],'int');
	
	if(~isempty(data))

		count=count+1;
		power_time(count)=data(1)+data(2)/60+(data(3)+0.001*data(4))/3600;

		% get pointing angles
		data=fread(fid,[2 1],'float');
		elevation(count)=data(1);
		azimuth(count)=data(2);

		%
		% files contain -1 * summed value of I and Q ... see collect_data software
		%
	        mean_I(1:n_gates,count)=-1*fread(fid,[n_gates 1],'float') / N_time_samples ;
        	mean_Q(1:n_gates,count)=-1*fread(fid,[n_gates 1],'float') / N_time_samples ;
        
	        mean_I2(1:n_gates,count)=fread(fid,[n_gates 1],'float') / N_time_samples;
        	mean_Q2(1:n_gates,count)=fread(fid,[n_gates 1],'float') / N_time_samples;      
	
		data=fread(fid,[n_gates 1],'float');
		velocity(1:n_gates,count)=data;

		data=fread(fid,[n_gates 1],'float');
		width(1:n_gates,count)=data;
	end
end

fclose(fid);

return
