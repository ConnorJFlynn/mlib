pathname ='c:\beat_pnnl\sensitivity\Niamey\';
%read clear flux
%  Z      P         FLUX_up   FLUX_dn   FLUX_net    HEATING
filename='Niamey_clr.dat';
fid=fopen([pathname,filename]);
fgetl(fid);
data=fscanf(fid,'%g',[6 inf]); 
z=data(1,:);
P=data(2,:);
FLUX_up=data(3,:);
FLUX_dn=data(4,:);
FLUX_net=data(5,:);
HEATING=data(6,:);
fclose(fid)

filename='Niamey_aerosol.dat';
fid=fopen([pathname,filename]);
fgetl(fid);
data=fscanf(fid,'%g',[6 inf]); 
z_aer=data(1,:);
P_aer=data(2,:);
FLUX_up_aer=data(3,:);
FLUX_dn_aer=data(4,:);
FLUX_net_aer=data(5,:);
HEATING_aer=data(6,:);
fclose(fid)
Forcing=(FLUX_net_aer-FLUX_net);

filename='mcfarlane_scalepwv_clear.dat';
fid=fopen([pathname,filename]);
fgetl(fid);
fgetl(fid);
data=fscanf(fid,'%g',[4 inf]); 
z_mcf=data(1,:);
FLUX_up_mcf=data(2,:);
FLUX_dn_mcf=data(3,:);
HEATING_mcf=data(4,:);
fclose(fid)

filename='mcfarlane_scalepwv_aerosol.dat';
fid=fopen([pathname,filename]);
fgetl(fid);
fgetl(fid);
data=fscanf(fid,'%g',[4 inf]); 
z_mcf_aer=data(1,:);
FLUX_up_mcf_aer=data(2,:);
FLUX_dn_mcf_aer=data(3,:);
HEATING_mcf_aer=data(4,:);
fclose(fid)
Forcing_mcf=(FLUX_dn_mcf_aer-FLUX_up_mcf_aer)-(FLUX_dn_mcf-FLUX_up_mcf);

figure(1)
plot(FLUX_up,z,'k--',FLUX_up_aer,z_aer,'r--',FLUX_up_mcf,z_mcf,'k-',FLUX_up_mcf_aer,z_mcf_aer,'r-')
legend('up clear RRTM','up aerosol RRTM','up clear McFarlane','up aerosol McFarlane')
xlabel('Upwelling Flux W/m2')
ylabel('Altitude (km)')
figure(2)
plot(FLUX_dn,z,'k--',FLUX_dn_aer,z_aer,'r--',FLUX_dn_mcf,z_mcf,'k-',FLUX_dn_mcf_aer,z_mcf_aer,'r-')
legend('down clear RRTM','down aerosol RRTM','down clear McFarlane','down aerosol McFarlane')
xlabel('Downwelling Flux W/m2')
ylabel('Altitude (km)')
figure(3)
plot(HEATING,z,'k--',HEATING_aer,z_aer,'r--',HEATING_mcf,z_mcf,'k-',HEATING_mcf_aer,z_mcf_aer,'r-')
legend('clear RRTM','aerosol RRTM','clear McFarlane','aerosol McFarlane')
xlabel('Heating Rate (K/day)')
ylabel('Altitude (km)')
figure(4)
plot(HEATING,z,'k--',HEATING_aer,z_aer,'r--',HEATING_mcf,z_mcf,'k-',HEATING_mcf_aer,z_mcf_aer,'r-')
axis([0 4 0 10])
legend('clear RRTM','aerosol RRTM','clear McFarlane','aerosol McFarlane')
xlabel('Heating Rate (K/day)')
ylabel('Altitude (km)')
figure(5)
plot(HEATING_aer-HEATING,z,HEATING_mcf_aer-HEATING_mcf,z_mcf)
legend('RRTM','McFarlane')
axis([-1 3 0 10])
xlabel('Heating Rate Difference(K/day)')
ylabel('Altitude (km)')
figure(6)
plot(Forcing,z,Forcing_mcf,z_mcf)
legend('RRTM','McFarlane')
xlabel('Radiative Forcing W/m2')
ylabel('Altitude (km)')