% Reads rad data  (Pelican Flux) tf*.rad.txt files 

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Flux\tf*.rad.txt','Choose rad File', 0, 0);
fid=fopen([pathname filename]);
for i=1:8
  fgetl(fid);
end

rad_data=fscanf(fid,'%g',[5,inf]);
fclose(fid);

%utc(sec) TSU(W/m2) FSU(W/m2) IRU(W/m2) TSD(W/m2)

Rad_UT = mod(rad_data(1,:),86400)/60/60;
TSU= rad_data(2,:);
FSU= rad_data(3,:);
IRU=rad_data(4,:);
TSD=rad_data(5,:);


clear rad_data

figure(1)
plot(Rad_UT,TSU,Rad_UT,FSU,Rad_UT,IRU,Rad_UT,TSD)
legend('Total Solar Flux (up looking)','Filtered Solar Flux (up looking)','IR Flux (up looking)','Total Solar Flux (down looking)')
grid on
xlabel('UT')
ylabel('Flux [W/m2]')