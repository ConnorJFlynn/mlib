%Rotary stage
%%
slow_CCW = loadit(['C:\case_studies\ARRA\SAS\data_tests\rotary_stage\Rotary Stage Calibration\']);
CW = loadit(['C:\case_studies\ARRA\SAS\data_tests\rotary_stage\Rotary Stage Calibration\']);


CCW = loadit(['C:\case_studies\ARRA\SAS\data_tests\rotary_stage\Rotary Stage Calibration\']);
%%

plots_default
figure; 
ax(1) = subplot(3,1,1); 
plot(CW(:,1),CW(:,2),'o-');
title('Stepper: 256 microsteps/step, 200 steps/rev');
legend('CW rotation');
ylabel('microsteps');

ax(2) = subplot(3,1,2);
plot(CCW(:,1),CCW(:,2),'x-')
ylabel('microsteps');
xlabel('Rotation number')
legend('CCW rotation');

ax(3) = subplot(3,1,3);
plot(slow_CCW(:,1),slow_CCW(:,2),'x-')
ylabel('microsteps');
xlabel('Rotation number')
legend('CCW slow');


linkaxes(ax,'xy')


%%

[CW_steps, cw_i]= sort(CW(:,2));
[CCW_steps, ccw_i]= sort(CCW(:,2));
CW_revs = CW_steps./(256.*200);
figure; scatter(CW(:,1),CW_steps,10,cw_i);
hold('on')
scatter(CCW(:,1),CCW_steps,15,ccw_i,'filled');

%%
mean(CW(:,2))./360
std(CW(:,2))