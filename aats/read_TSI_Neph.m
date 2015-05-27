function [dec_h,scat,bscat]=read_TSI_Neph();

%reads in TSI Neph Data

[filename,pathname]=uigetfile('c:\beat\data\Strawa\*.dat','Choose file', 0, 0);
fid=fopen([pathname filename]);
ii=1;
while feof(fid)==0
dataT(:,ii)=fscanf(fid,'T,%g,%g,%g,%g,%g,%g\n',[6,1]);
dataB(:,ii)=fscanf(fid,'B,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',[10,1]);
dataG(:,ii)=fscanf(fid,'G,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',[10,1]);
dataR(:,ii)=fscanf(fid,'R,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',[10,1]);
dataD(:,ii)=fscanf(fid,'D,NBXX,%g,%g,%g,%g,%g,%g,%g\n',[7,1]);
dataY(:,ii)=fscanf(fid,'Y,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',[9,1]);
ii=ii+1;
end

% Record T
year =dataT(1,:);
month=dataT(2,:);
day  =dataT(3,:);
hour =dataT(4,:);
min  =dataT(5,:);
sec  =dataT(6,:);
dec_h=hour+min/60+sec/60/60;

%Records B G and R

%Record D

scat(1,:)=dataD(2,:);
scat(2,:)=dataD(3,:);
scat(3,:)=dataD(4,:);
bscat(1,:)=dataD(2,:);
bscat(2,:)=dataD(3,:);
bscat(3,:)=dataD(4,:);

fclose(fid);
