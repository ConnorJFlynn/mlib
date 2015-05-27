%reads tape7.scn file from MODTRAN 3.7 for irradiance mode to compare solar spectra.

clear all
close all

fid=fopen('d:\beat\mod3_7\results\newkur.5nm.txt','r');
fgetl(fid);
data=fscanf(fid,'%f',[5,inf]);
wvl           =data(1,:);
NewKur_Irr    =data(4,:);
fclose(fid);

fid=fopen('d:\beat\mod3_7\results\oldkur.5nm.txt','r');
fgetl(fid);
data=fscanf(fid,'%f',[5,inf]);
wvl           =data(1,:);
OldKur_Irr    =data(4,:);
fclose(fid);

fid=fopen('d:\beat\mod3_7\results\chkur.5nm.txt','r');
fgetl(fid);
data=fscanf(fid,'%f',[5,inf]);
wvl           =data(1,:);
ChKur_Irr    =data(4,:);
fclose(fid);

fid=fopen('d:\beat\mod3_7\results\cebkur.5nm.txt','r');
fgetl(fid);
data=fscanf(fid,'%f',[5,inf]);
wvl           =data(1,:);
CebKur_Irr    =data(4,:);
fclose(fid);

fid=fopen('d:\beat\mod3_7\results\thkur.5nm.txt','r');
fgetl(fid);
data=fscanf(fid,'%f',[5,inf]);
wvl           =data(1,:);
ThKur_Irr    =data(4,:);
fclose(fid);

figure(1)
plot(wvl,OldKur_Irr./NewKur_Irr,wvl,ChKur_Irr./NewKur_Irr,wvl,CebKur_Irr./NewKur_Irr,wvl,ThKur_Irr./NewKur_Irr);
legend('Old Kurucz','Chance','Cebula','Thuillier')
ylabel('Ratio to New Kurucz')
xlabel('Wavelength [nm]')
grid on
axis([290 400 0.7 1.3])