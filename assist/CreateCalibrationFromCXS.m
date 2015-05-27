function [CalSet] = CreateCalibrationFromCXS(HBB, T_hot, CBB, T_cold);
% Returns complex gain [cts/radiance] and offset [cts]
% HBB is a structure with Header, x and y for the hot calibration target
% T_hot is the temperature of the hot target
% CBB is a structure with Header, x and y for the cold calibration target
% T_cold is the temperature of the cold target
% yields radiance units of mW(m^2 sr cm^-1)

BB_hot = 0.998.*Blackbody(HBB.x, T_hot);
BB_cold = 0.998.*Blackbody(CBB.x, T_cold);

BB_hot = Blackbody(HBB.x, T_hot);
BB_cold = Blackbody(CBB.x, T_cold);

CalSet.Gain = (HBB.y - CBB.y) ./ (BB_hot - BB_cold);
CalSet.Offset = (CBB.y .* BB_hot - HBB.y .* BB_cold) ./ (BB_hot - BB_cold);
CalSet.x = HBB.x;
