%reads UW neph files corrected for truncation and inlet
%Time   expected dry scat, corr1_dry, corr2_dry  expected wet scat, corr1_wet, corr2_wet  
% UT(hours), 1/m, unitless, unitless, 1/m, unitless, unitless
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\uw*.txt','Choose UW Neph correction data', 0, 0);
fid=fopen([pathname filename]);
data=fscanf(fid,'%g',[7,inf]);

UT_UW_corr = data(1,:);
Dry_scat_UW_comp=data(2,:)*1e3;
corr1_dry=data(3,:);
corr2_dry=data(4,:);
Wet_scat_UW_comp=data(5,:)*1e3;
corr1_wet=data(6,:);
corr2_wet=data(7,:);

fclose(fid);

figure(3)
subplot(2,1,1)
plot(UT_UW_corr,Dry_scat_UW_comp,UT_UW_corr,Wet_scat_UW_comp);
subplot(2,1,2)
plot(UT_UW_corr,corr1_dry,UT_UW_corr,corr2_dry,UT_UW_corr,corr1_wet,UT_UW_corr,corr2_wet);




