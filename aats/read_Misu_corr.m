%reads MISU neph corrections for truncation and inlet
%Time
%       expected total scat 450 , corr1 total scat , corr2 total scat
%        expected back scat 450 , corr1 back scat , corr2 back scat
%       expected total scat 550 , corr1 total scat , corr2 total scat
%        expected back scat 550 , corr1 back scat , corr2 back scat
%       expected total scat 700 , corr1 total scat , corr2 total scat
%        expected back scat 700 , corr1 back scat , corr2 back scat
% Units
% UT(hours), 1/m, unitless, unitless, ....

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\tsi*.txt','Choose MISU corrrection data', 0, 0);
fid=fopen([pathname filename]);
data=fscanf(fid,'%g',[19,inf]);
fclose(fid);

UT_Misu_corr = data(1,:);
total_scat_comp_450 = data(2,:);
corr1_total_scat_450 = data(3,:);
corr2_total_scat_450 = data(4,:);

back_scat_comp_450 = data(5,:);
corr1_back_scat_450 = data(6,:);
corr2_back_scat_450 = data(7,:);

total_scat_comp_550 = data(8,:);
corr1_total_scat_550 = data(9,:);
corr2_total_scat_550 = data(10,:);

back_scat_comp_550 = data(11,:);
corr1_back_scat_550 = data(12,:);
corr2_back_scat_550 = data(13,:);

total_scat_comp_700 = data(14,:);
corr1_total_scat_700 = data(15,:);
corr2_total_scat_700 = data(16,:);

back_scat_comp_700 = data(17,:);
corr1_back_scat_700 = data(18,:);
corr2_back_scat_700 = data(19,:);

total_scat_Misu_comp=[total_scat_comp_450',total_scat_comp_550',total_scat_comp_700']'*1e3;
corr1_total_scat_Misu=[corr1_total_scat_450',corr1_total_scat_550',corr1_total_scat_700']';
corr2_total_scat_Misu=[corr2_total_scat_450',corr2_total_scat_550',corr2_total_scat_700']';
back_scat_Misu_comp =[back_scat_comp_450' ,back_scat_comp_550' ,back_scat_comp_700']'*1e3;
corr1_back_scat_Misu=[corr1_back_scat_450',corr1_back_scat_550',corr1_back_scat_700']';
corr2_back_scat_Misu=[corr2_back_scat_450',corr2_back_scat_550',corr2_back_scat_700']';

figure(1)
subplot(4,1,1)
plot(UT_Misu_corr,total_scat_Misu_comp);
subplot(4,1,2)
plot(UT_Misu_corr,back_scat_Misu_comp);
subplot(4,1,3)
plot(UT_Misu_corr,corr1_total_scat_Misu)
hold on
plot(UT_Misu_corr,corr2_total_scat_Misu);
hold off
subplot(4,1,4)
plot(UT_Misu_corr,corr1_back_scat_Misu);
hold on
plot(UT_Misu_corr,corr2_back_scat_Misu);
hold off



