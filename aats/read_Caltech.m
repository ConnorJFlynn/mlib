% reads Caltech data provided by Don Collins
% Format of rev 2
% Avg Time, 380.3,448.25,452.97,499.4,524.7,605.4,666.8,711.8,778.5,864.4,939.5,1018.7,1059,1557.5
% For each wavelength there is Bext, Bscat, and Babs therefore there are time (3 columns) plus 42 columns.

lambda_Caltech=[380.3,448.25,452.97,499.4,524.7,605.4,666.8,711.8,778.5,864.4,939.5,1018.7,1059,1557.5]/1e3;

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\*.*','Choose Caltech data file', 0, 0);
fid=fopen([pathname filename]);
for i=1:4,
   fgetl(fid);
end
   
data=fscanf(fid,'%2d:%2d:%2d  %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[45,inf]);
UT_Caltech   = data(1,:)+data(2,:)/60+data(3,:)/3600;
Ext_Caltech  =(data([4:3:45],:))';
Scat_Caltech =(data(1+[4:3:45],:))';
Abs_Caltech  =(data(2+[4:3:45],:))';

fclose(fid);
figure(1)
plot(UT_Caltech,Scat_Caltech,UT_Caltech,Abs_Caltech)

figure(2)
plot(UT_Caltech,Scat_Caltech./Ext_Caltech)
legend('380.3','448.25','452.97','499.4','524.7','605.4','666.8','711.8','778.5','864.4','939.5','1018.7','1059','1557.5')



