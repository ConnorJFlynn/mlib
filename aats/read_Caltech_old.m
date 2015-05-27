% reads Caltech data provided by Don Collins
% Format
% Avg Time  375,630,778,860,
% 380.3,448.25,452.97,499.4,524.7,605.4,666.8,711.8,778.5,864.4,939.5,1018.7,1059,1557.5
% 450,550,700
% For each wavelength there is Bext, Bscat, and Babs therefore there are time (3 columns) plus 63 columns.

lambda_Caltech=[380.3,448.25,452.97,499.4,524.7,605.4,666.8,711.8,778.5,864.4,939.5,1018.7,1059,1557.5]/1e3;

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\*.*','Choose Caltech data file', 0, 0);
fid=fopen([pathname filename]);
for i=1:4,
   fgetl(fid);
end
   
data=fscanf(fid,'%2d:%2d:%2d %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[66,inf]);
UT_Caltech   = data(1,:)+data(2,:)/60+data(3,:)/3600;
Ext_Caltech    =(data([16,19,22,25,28,31,34,37,40,43,46,49,52,55],:))';
Scat_Caltech =(data(1+[16,19,22,25,28,31,34,37,40,43,46,49,52,55],:))';
Abs_Caltech  =(data(2+[16,19,22,25,28,31,34,37,40,43,46,49,52,55],:))';

Ext_Caltech_Neph=(data([58,61,64],:))';
Scat_Caltech_Neph=(data(1+[58,61,64],:))';
Abs_Caltech_Neph=(data(2+[58,61,64],:))';


fclose(fid);
figure(1)
plot(UT_Caltech,Scat_Caltech,UT_Caltech,Abs_Caltech)

figure(2)
plot(UT_Caltech,Scat_Caltech./Ext_Caltech)
legend('380.3','448.25','452.97','499.4','524.7','605.4','666.8','711.8','778.5','864.4','939.5','1018.7','1059','1557.5')

figure(3)
plot(UT_Caltech,Scat_Caltech_Neph,UT_Caltech,Abs_Caltech_Neph)
legend('450','550','700')

figure(4)
plot(UT_Caltech,Scat_Caltech_Neph./Ext_Caltech_Neph)
legend('450','550','700')


i_Caltech=find(UT<=max(UT_Caltech) & UT>=min(UT_Caltech));
Ext_Caltech= interp1(UT_Caltech,Ext_Caltech,UT(i_Caltech));
