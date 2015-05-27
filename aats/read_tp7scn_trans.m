clear all
close all
%reads tape7.scn file from MODTRAN 3.7
wvl_start=330
wvl_step=0.1
wvl_end =1600

fid=fopen('d:\beat\mod3_7\Tape7.scn','r');

for iline=1:14
 fgetl(fid);
end
i=0;
for ii=wvl_start:wvl_step:wvl_end-wvl_step 
   i=i+1;
   data=fscanf(fid,'%f',[18,1]);
   wvl(i)       =data(1);
   T_tot(i)     =data(2);
   T_H2O_band(i)=data(3);
   T_CO2_plus(i)=data(4);
   T_O3(i)      =data(5);
   T_trace(i)   =data(6);
   T_N2_cont(i) =data(7);
   T_ray(i)     =data(8);
   T_aero_sc(i) =data(9);
   T_HNO3(i)    =data(10);
   T_CO(i)      =data(11);
   T_CH4(i)     =data(12);
   T_N2O(i)     =data(13);
   T_O2(i)      =data(14);
   T_NH3(i)     =data(15);
   T_NO(i)      =data(16);
   T_NO2(i)     =data(17);
   T_SO2(i)     =data(18);
   data=fscanf(fid,'%f',[4,1]);
   Tau_tot(i)    =data(1);
   T_H2O_cont(i) =data(2);
   T_CO2(i)      =data(3);
   T_aero_ab(i)  =data(4);
end


fclose(fid);
figure(1)
semilogy(wvl,-log(T_H2O_band.*T_H2O_cont),wvl,-log(T_O3),wvl,-log(T_O2),wvl,-log(T_NO2),wvl,-log(T_CO2));
legend('H2O','O3','O2','NO2','CO2')
set(gca,'ytick',[0.0001,0.0002,0.0003,0.0004, 0.0005,0.0006,0.0007,0.0008,0.0009,0.001,0.002,0.003,0.004,...
      0.005,0.006,0.007,0.008,0.009,0.010,0.020,0.030,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.2,0.3,0.40,0.5,...
      0.6,0.7,0.8,0.9,1,2]);
ylabel('Optical Depth')
xlabel('Wavelenght (nm)')
grid on
axis([330 400 0.01 0.2])