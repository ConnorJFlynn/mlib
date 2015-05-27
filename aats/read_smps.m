function [r_raw,dNdr,r_low,r_high,filename]=read_SMPS();
%read in smps data
N_bins=110;     % Number of bins in SMPS file
[filename,pathname]=uigetfile('c:\beat\data\Strawa\*.txt','Choose file', 0, 0);
fid=fopen([pathname filename]);
for i=1:17
    fgetl(fid);
end
data=fscanf(fid,'%g',[2,N_bins]);
fclose(fid);
D_raw=data(1,:);     %Diameter in nm (midpoint of bin)
conc_raw=data(2,:);  %Concentration #/cm3

r_raw=D_raw/2/1e3; % convert to radius in microns

dr=diff(r_raw);
dr(N_bins)=dr(end);
r_low=r_raw(1)-dr(1)/2;
r_high=r_raw(end)+dr(end)/2;

dNdr=conc_raw./dr; %unit # cm-3 nm-1