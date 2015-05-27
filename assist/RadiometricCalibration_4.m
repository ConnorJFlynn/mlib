function [y] = RadiometricCalibration_4(y, CalSet);
% [y] = RadiometricCalibration_4(y, CalSet);
% Returns y: the calibrated radiance
% CalSet is the radiometric calibration dataset with elements
% CalSet.Resp = (HBB.y - CBB.y)./(BB_hot - BB_cold);
% CalSet.Offset_cts =   CBB.y -BB_cold.*CalSet.Resp;
% CalSet.Offset_ru =   CBB.y./CalSet.Resp -BB_cold;

for ll = size(y, 1):-1:1
    y(ll,:) = y(ll,:) ./ CalSet.Resp + CalSet.Offset_ru;
end
