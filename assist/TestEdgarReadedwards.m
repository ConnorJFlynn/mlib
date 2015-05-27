close all
clear all

%Read ambient (enter ambient file name and scan number)
fileName = 'G:\data\AM1932.igm';
DataABB = ReadEdgarFile(fileName, 1, 350);
[ForwardABB, ReverseABB] = SplitDirections(DataABB);

%Raw foward ambient igm (figure 1)
figure
plot(ForwardABB.x, ForwardABB.y)

%Raw reverse ambient igm (figure 2)
figure
plot(ReverseABB.x, ReverseABB.y)

%Read hot (enter hot file name and scan number)
fileName = 'G:\DATA\AM3515.igm';
DataHBB = ReadEdgarFile(fileName, 1, 350);
[ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);

%Raw foward hot igm (figure 3)
figure
plot(ForwardHBB.x, ForwardHBB.y)

%Raw reverse hot igm (figure 4)
figure
plot(ReverseHBB.x, ReverseHBB.y)

% Calibration targets and scene temperatures (enter temperature in Celsius)
T_hot = 35.15;
T_cold = 19.32;
T_scene = 28.0;

CalSetForward = CreateCalibrationData(ForwardHBB, 273.15+T_hot, ForwardABB, 273.15+T_cold);
CalSetReverse = CreateCalibrationData(ReverseHBB, 273.15+T_hot, ReverseABB, 273.15+T_cold);

%Read measure (enter measurment file name and scan number)
fileName = 'G:\DATA\AM2800.igm';
DataSBB = ReadEdgarFile(fileName, 1, 12);
[ForwardSBB, ReverseSBB] = SplitDirections(RawIgm2RawSpc(DataSBB));

%radiometric calibration
RadianceSpcForward = RadiometricCalibration(ForwardSBB, CalSetForward);
RadianceSpcReverse = RadiometricCalibration(ReverseSBB, CalSetReverse);

%coad radiance
RadianceSpcForwardCoadd = CoaddData(RadianceSpcForward);
RadianceSpcReverseCoadd = CoaddData(RadianceSpcReverse);

%Foward single radiance (figure 5)
figure
plot(RadianceSpcForward.x, real(RadianceSpcForward.y), RadianceSpcForward.x, imag(RadianceSpcForward.y), RadianceSpcForward.x, Blackbody(RadianceSpcForward.x,273.15+T_scene))

%reverse single radiance (figure 6)
figure
plot(RadianceSpcReverse.x, real(RadianceSpcReverse.y), RadianceSpcReverse.x, imag(RadianceSpcReverse.y), RadianceSpcReverse.x, Blackbody(RadianceSpcReverse.x,273.15+T_scene))

%Foward coadded radiance (figure 7)
figure
plot(RadianceSpcForwardCoadd.x, real(RadianceSpcForwardCoadd.y), RadianceSpcForwardCoadd.x, imag(RadianceSpcForwardCoadd.y), RadianceSpcForwardCoadd.x, Blackbody(RadianceSpcForwardCoadd.x,273.15+T_scene))

%reverse coadded radiance (figure 8)
figure
plot(RadianceSpcReverseCoadd.x, real(RadianceSpcReverseCoadd.y), RadianceSpcReverseCoadd.x, imag(RadianceSpcReverseCoadd.y), RadianceSpcReverseCoadd.x, Blackbody(RadianceSpcReverseCoadd.x,273.15+T_scene))

