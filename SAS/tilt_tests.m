% SAS accelerometer and tilt meter tests:
% Comparison of 3D accelerometer and 2D level.  
%%
%1a. Check stability of 3D signal (for a stationary platform) over several different acquisition speeds, 500 Hz, 100 Hz, 50 Hz, 10 Hz.  
pname = ['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1a_Stability'];
accel_500Hz = loadit(pname);
accel_100Hz = loadit(pname);
accel_50Hz = loadit(pname);
accel_10Hz = loadit(pname);
%%
figure; plot([1:length(accel_500Hz.accelX)],[accel_500Hz.accelX,accel_500Hz.accelY,accel_500Hz.accelZ],'.');legend('x','y','z')
%%
std([accel_500Hz.accelX,accel_500Hz.accelY,accel_500Hz.accelZ])
std([accel_100Hz.accelX,accel_100Hz.accelY,accel_100Hz.accelZ])
std([accel_50Hz.accelX,accel_50Hz.accelY,accel_50Hz.accelZ])
std([accel_10Hz.accelX,accel_10Hz.accelY,accel_10Hz.accelZ])
%%
accel_500Hz.down500.accelX = downsample(accel_500Hz.accelX,500);
accel_500Hz.down500.accelY = downsample(accel_500Hz.accelY,500);
accel_500Hz.down500.accelZ = downsample(accel_500Hz.accelZ,500);

figure; plot([1:length(accel_500Hz.down500.accelX)],[accel_500Hz.down500.accelX,accel_500Hz.down500.accelY,accel_500Hz.down500.accelZ],'-');
legend('x','y','z')
std(accel_500Hz.down500.accelX)
std(accel_500Hz.down500.accelY)
std(accel_500Hz.down500.accelZ)

%%

%1b. Check drift of 3D signal versus drift of 2D signal.  
drift_test = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1b_Drift\testAccelDrift.txt']);
figure; plot([1:length(drift_test.HH)],[drift_test.Col4_3D_x_deg,drift_test.Col5_3D_y_deg,drift_test.Col6_3D_z_deg,...
   drift_test.Col7_2D_x_deg,drift_test.Col8_2D_y_deg], '-');
legend('3Dx','3Dy','3Dz','2Dx','2Dy');
rel_3Dx = drift_test.Col4_3D_x_deg./mean(drift_test.Col4_3D_x_deg);
rel_3Dy = drift_test.Col5_3D_y_deg./mean(drift_test.Col5_3D_y_deg);
rel_3Dz = drift_test.Col6_3D_z_deg./mean(drift_test.Col6_3D_z_deg);
rel_2Dx = drift_test.Col7_2D_x_deg./mean(drift_test.Col7_2D_x_deg);
rel_2Dy = drift_test.Col8_2D_y_deg./mean(drift_test.Col8_2D_y_deg);
figure; plot([1:length(drift_test.HH)],[rel_3Dx,rel_3Dy,rel_3Dz,rel_2Dx,rel_2Dy,], '-'); 
legend('3Dx','3Dy','3Dz','2Dx','2Dy');
%%
%1c. Check agreement between the 2 sensors for various static changes to the leveling of the stationary platform over maybe 10 degrees or 
level = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1c_Tilt']);
side1 = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1c_Tilt']);
side1x = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1c_Tilt']);
%%
side2 = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1c_Tilt']);
side2x = loadit(['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\Accelerometer_1c_Tilt']);
%%
figure; 
v = datevec(now);ymd = ones(size(level.HH))*v(1,1:3);
level.time = datenum([ymd,level.HH,level.MM, level.SS]);
side1.time = datenum([ymd,side1.HH,side1.MM, side1.SS]);
side1x.time = datenum([ymd,side1x.HH,side1x.MM, side1x.SS]);
side2.time = datenum([ymd,side2.HH,side2.MM, side2.SS]);
side2x.time = datenum([ymd,side2x.HH,side2x.MM, side2x.SS]);
ax1 = subplot(2,1,1);
plot(serial2doy(level.time), [level.Col4_3D_x_deg,level.Col5_3D_y_deg,level.Col6_3D_z_deg,level.Col7_2D_x_deg,level.Col8_2D_y_deg], '-');legend('3dx','3dy','3dz','2dx','2dy'); 

hold('on')
plot(serial2doy(side1.time), [side1.Col4_3D_x_deg,side1.Col5_3D_y_deg,side1.Col6_3D_z_deg,side1.Col7_2D_x_deg,side1.Col8_2D_y_deg], '-'); 
plot(serial2doy(side1x.time), [side1x.Col4_3D_x_deg,side1x.Col5_3D_y_deg,side1x.Col6_3D_z_deg,side1x.Col7_2D_x_deg,side1x.Col8_2D_y_deg], '-');
hold('off')
%
ax2 = subplot(2,1,2);
plot(serial2doy(level.time), [level.Col4_3D_x_deg,level.Col5_3D_y_deg,level.Col6_3D_z_deg,level.Col7_2D_x_deg,level.Col8_2D_y_deg], '-');legend('3dx','3dy','3dz','2dx','2dy'); 
hold('on')
plot(serial2doy(side2.time), [side2.Col4_3D_x_deg,side2.Col5_3D_y_deg,side2.Col6_3D_z_deg,side2.Col7_2D_x_deg,side2.Col8_2D_y_deg], '-'); 
plot(serial2doy(side2x.time), [side2x.Col4_3D_x_deg,side2x.Col5_3D_y_deg,side2x.Col6_3D_z_deg,side2x.Col7_2D_x_deg,side2x.Col8_2D_y_deg], '-');
hold('off')

%%
level.mean3dx = mean(level.Col4_3D_x_deg);
level.mean3dy = mean(level.Col5_3D_y_deg);
level.mean3dz = mean(level.Col6_3D_z_deg);
level.mean2dx = mean(level.Col7_2D_x_deg);
level.mean2dy = mean(level.Col8_2D_y_deg);

side1.mean3dx = mean(side1.Col4_3D_x_deg);
side1.mean3dy = mean(side1.Col5_3D_y_deg);
side1.mean3dz = mean(side1.Col6_3D_z_deg);
side1.mean2dx = mean(side1.Col7_2D_x_deg);
side1.mean2dy = mean(side1.Col8_2D_y_deg);

side1x.mean3dx = mean(side1x.Col4_3D_x_deg);
side1x.mean3dy = mean(side1x.Col5_3D_y_deg);
side1x.mean3dz = mean(side1x.Col6_3D_z_deg);
side1x.mean2dx = mean(side1x.Col7_2D_x_deg);
side1x.mean2dy = mean(side1x.Col8_2D_y_deg);

side2.mean3dx = mean(side2.Col4_3D_x_deg);
side2.mean3dy = mean(side2.Col5_3D_y_deg);
side2.mean3dz = mean(side2.Col6_3D_z_deg);
side2.mean2dx = mean(side2.Col7_2D_x_deg);
side2.mean2dy = mean(side2.Col8_2D_y_deg);

side2x.mean3dx = mean(side2x.Col4_3D_x_deg);
side2x.mean3dy = mean(side2x.Col5_3D_y_deg);
side2x.mean3dz = mean(side2x.Col6_3D_z_deg);
side2x.mean2dx = mean(side2x.Col7_2D_x_deg);
side2x.mean2dy = mean(side2x.Col8_2D_y_deg);

side1_delts = [side1.mean3dx-level.mean3dx, side1x.mean3dx-side1.mean3dx;...
   side1.mean3dy-level.mean3dy, side1x.mean3dy-side1.mean3dy;...
   side1.mean3dz-level.mean3dz, side1x.mean3dz-side1.mean3dz;...
   side1.mean2dx-level.mean2dx, side1x.mean2dx-side1.mean2dx;...
   side1.mean2dy-level.mean2dy, side1x.mean2dy-side1.mean2dy]

side2_delts = [side2.mean3dx-level.mean3dx, side2x.mean3dx-side2.mean3dx;...
   side2.mean3dy-level.mean3dy, side2x.mean3dy-side2.mean3dy;...
   side2.mean3dz-level.mean3dz, side2x.mean3dz-side2.mean3dz;...
   side2.mean2dx-level.mean2dx, side2x.mean2dx-side2.mean2dx;...
   side2.mean2dy-level.mean2dy, side2x.mean2dy-side2.mean2dy]

%Apparent scale-factor difference between 3D and 2D
side1_delts(5,1)./side1_delts(2,1)
side1_delts(5,2)./side1_delts(2,2)

side2_delts(4,1)./side2_delts(1,1)
side2_delts(4,2)./side2_delts(1,2)
%%
pname = ['C:\case_studies\ARRA\SAS\data_tests\tilt_tests\accelSheilded.txt'];
shielded_3D = loadit(pname);
%%
figure; plot([1:length(shielded_3D.X_space_degree)], [shielded_3D.X_space_degree,shielded_3D.Y_space_degree,shielded_3D.Z_space_degree],'-');
sprintf('Std X %f',std(shielded_3D.X_space_degree))
sprintf('Std Y %f',std(shielded_3D.Y_space_degree))
sprintf('Std Z %f',std(shielded_3D.Z_space_degree))
legend('X','Y','Z')