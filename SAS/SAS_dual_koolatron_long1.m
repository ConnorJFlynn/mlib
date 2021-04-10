% Dual Kooltron long test

%%
if exist('SAS_dualkool.mat')
   load('SAS_dualkool.mat');
else

%%
SN29 = SAS_read_Albert_csv('D:\case_studies\SAS\testing_and_characterization\temp_tests\20100423DualKooltrons\2010_4days_0911129U1.csv');
SN46 = SAS_read_Albert_csv('D:\case_studies\SAS\testing_and_characterization\temp_tests\20100423DualKooltrons\2010_4days_0911146U1.csv');
save('SAS_dualkool.mat');
%%
end
%%
close(1); close(2);
figure(1); 
plot(24.*(SN29.time-SN29.time(1)), [SN29.Temp1,SN46.Temp1],'.',24.*(SN46.time-SN46.time(1)), [SN29.Temp2,SN46.Temp2],'o');
legend('CMOS Temp1','NIR Temp1','CMOS Temp2','NIR Temp2');
xlabel('hours since start')
ylabel('temp (deg C)')
ax(1) = gca;
figure(2); 
ax(2) = subplot(2,1,1); plot(24.*(SN29.time-SN29.time(1)), mean(SN29.spec,2),'.');
title('CMOS Darks');
xlabel('hours since start')
ylabel('darks)')
ax(3) = subplot(2,1,2); plot(24.*(SN46.time-SN46.time(1)), mean(SN46.spec,2),'.');
title('NIR Darks');
xlabel('hours since start')
ylabel('darks)')
linkaxes(ax,'x')
%%


