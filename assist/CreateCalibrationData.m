function [CalSet] = CreateCalibrationData(RawIgmHot, T_hot, RawIgmCold, T_cold);
% Returns complex gain and offset
% RawIgmHot is a structure with Header, x and y for the hot calibration target
% T_hot is the temperature of the hot target
% RawIgmCold is a structure with Header, x and y for the cold calibration target
% T_cold is the temperature of the cold target

RawSpcHot = CoaddData(RawIgm2RawSpc(RawIgmHot));
RawSpcCold = CoaddData(RawIgm2RawSpc(RawIgmCold));

BB_hot = Blackbody(RawSpcHot.x, T_hot);
BB_cold = Blackbody(RawSpcCold.x, T_cold);

CalSet.Gain = (RawSpcHot.y - RawSpcCold.y) ./ (BB_hot - BB_cold);
CalSet.Offset = (RawSpcCold.y .* BB_hot - RawSpcHot.y .* BB_cold) ./ (BB_hot - BB_cold);
CalSet.x = RawSpcHot.x;
