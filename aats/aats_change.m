%fid2=fopen('d:\beat\matlab\dev.dat','w');
for i=1:2
 wl=[.380:0.001:1.000];  
 [filename,path]=uigetfile('d:\beat\data\lamps\f*.*', 'Choose a Lamp File', 0, 0);
 fid=fopen([path filename]);
 a=fscanf(fid, '%g', [8,1]);
 fclose(fid);

 pn=POLYVAL(a(3:8),wl);
 FEL1= exp(a(1)+a(2)./wl).*wl.^(-5).*pn;

 [filename,path]=uigetfile('d:\beat\data\lamps\f*.*', 'Choose a Lamp File', 0, 0);
 fid=fopen([path filename]);
 a=fscanf(fid, '%g', [8,1]);
 fclose(fid);

 pn=POLYVAL(a(3:8),wl);
 FEL2= exp(a(1)+a(2)./wl).*wl.^(-5).*pn;

 plot(wl*1000,(FEL2-FEL1)./FEL2*100)
 xlabel ('Wavelength (nm)')
 ylabel ('% Change from Initial Calibration')
 grid on
 axis([300 1100 -1 6])
 hold on
 %fprintf(fid2,'%7.3f  %g\n',[wl ;((FEL2-FEL1)./FEL2)]);
end

lambda=[412.78	441.79	488.03	550.29]; %Stu's Si radiometer
deviation=[5.04	4.66	4.15	3.28];   %Deviation to F330 measured on 1. Dec. 1995
plot(lambda,deviation,'o')

legend('F296/F269','F297/F269','F296/F330')
%fclose(fid2)
