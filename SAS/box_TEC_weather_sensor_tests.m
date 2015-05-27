%%
pname = 'C:\case_studies\ARRA\SAS\TempStableEICTEC\';
fname = 'chambertemptest.txt';
tmp = load([pname,fname]);
%%
%labels:
% Humidity,Temp F (TempSenor),Temp C (PressureSensor),Temp F (PressureSensor),Pressure Pascal,Relative Light,Battery,Record #
temp_ctrl.rec = tmp(:,8);
temp_ctrl.rh = tmp(:,1);
temp_ctrl.temp_F1 = tmp(:,2);
temp_ctrl.temp_C1 = tmp(:,3);
temp_ctrl.temp_F2 = tmp(:,4);
temp_ctrl.atm_pres_Pa = tmp(:,5);

%%
figure; plot([1:length(temp_ctrl.rec)], temp_ctrl.temp_F1, 'b.',[1:length(temp_ctrl.rec)], temp_ctrl.temp_F2,'r.');
title('TEC inside cardboard box with Weather Sensor');
legend('Temp C (from SHT)','Temp C (from pressure)');
xlabel('record number (1 per second)')
ylabel('temp inside box [C]')
ax(1) = gca;
zoom('on');
figure; plot([1:length(temp_ctrl.rec)],temp_ctrl.atm_pres_Pa,'g.');
title('TEC inside cardboard box with Weather Sensor');
xlabel('record number (1 per second)')
ylabel('pressure inside box [Pa]')

zoom('on');
ax(2) = gca;

%%
figure; plot([1:length(temp_ctrl.rec)],temp_ctrl.rh,'g.');
title('TEC inside cardboard box with Weather Sensor');
xlabel('record number (1 per second)')
ylabel('RH%')

zoom('on');
ax(3) = gca;


% linkaxes(ax,'x');%
%%
dp = calc_dp(temp_ctrl.temp_C1+273.17,temp_ctrl.rh);
figure; plot([1:length(temp_ctrl.rec)],dp-273.17,'k.');
title('TEC inside cardboard box with Weather Sensor');
xlabel('record number (1 per second)')
ylabel('dewpoint [C]')

zoom('on');
ax(4) = gca;


linkaxes(ax,'x');
% calc_dp(T,rh)