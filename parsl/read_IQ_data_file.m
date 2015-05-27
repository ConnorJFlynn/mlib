
function [I,Q,time_hour,time_year,elevation,azimuth]=read_IQ_data_file(file_name)

% get time from file name	
	[k]=findstr(file_name,'parsl.IQ.');
	T=file_name(k+9:end);

	year=str2num(T(1:4));
	month=str2num(T(5:6));
	day=str2num(T(7:8));

	hour=str2num(T(10:11));
	min=str2num(T(12:13));
	sec=str2num(T(14:15));
	msec=str2num(T(17:19));

time_hour=hour+min/60+(sec+msec/1000)/3600 ;
time_year=time_to_year_fraction(year,month,day,hour,min,sec+1E-3*msec) ;
	
% if gzip ... then copy to unzipped version ... temporarily
if( strcmp(file_name(end-2:end),'.gz') )
	test=unix(['gzip -d -c ' file_name ' >temp.dat' ])
	fid=fopen('temp.dat','r','l');
else
	fid=fopen([file_name],'r','l');
end

n_samples=fread(fid,[1 1],'int');
n_gates=fread(fid,[1 1],'int');

% get pointing angles
data=fread(fid,[2 1],'float');
elevation=data(1);
azimuth=data(2);

gates_selected=fread(fid,[1 n_gates],'short');
a=find(gates_selected==1);
n=length(a);

I=zeros([n_gates n_samples]);
Q=zeros([n_gates n_samples]);
for j=1:n_samples
	I(a,j)=-1*(fread(fid,[n 1],'short'));
end

for j=1:n_samples
	Q(a,j)=-1*(fread(fid,[n 1],'short'));
end


fclose(fid);

return
