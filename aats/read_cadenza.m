function [time_690,VS_690,N_690,time_1550,N_1550,SigE_690,SigE_1550]=read_cadenza();

%reads in cadenza data
[filename,pathname]=uigetfile('c:\beat\data\Strawa\*.txt','Choose file', 0, 0);
fid=fopen([pathname filename]);
fgetl(fid);

%time_690	VS_690	N_690	Time_1550	N_1550	SigE_690	SigE_1550
data=fscanf(fid,'%g',[7,inf]);
fclose(fid);

time_690=data(1,:)/60/60;   
VS_690=data(2,:); 
N_690=data(3,:); 
time_1550=data(4,:)/60/60; 
N_1550=data(5,:); 
SigE_690=data(6,:); 
SigE_1550=data(7,:); 



